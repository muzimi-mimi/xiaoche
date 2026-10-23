/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2026 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "adc.h"
#include "tim.h"
#include "usart.h"
#include "gpio.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include "OLED.h"
#include "stm32f1xx_it.h"
#include "stdio.h"
#include <stdarg.h>
#include "myI2C.h"
#include "MPU6050.h"
#include "SR04.h"
#include "TB6612.h"
#include "encode.h"
#include "PID.h"
#include "ccd.h"
#include <math.h>
#include <string.h>
#include <stdlib.h>

#include "BlueSerial.h"
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/

/* USER CODE BEGIN PV */

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */

/* ==========================================================================
 *                    两轮自平衡小车 —— 控制结构总览
 * ==========================================================================
 *
 * 硬件：STM32F103C8T6 @72MHz / MPU6050(软件I2C: PB3,PB4) / TB6612 + 双编码器
 *       OLED(软件I2C: PB8,PB9) / USART3 蓝牙(9600) / SR04 超声波 / CCD 线阵(ADC1_IN4)
 *
 * 节拍（唯一时基是 TIM3 中断，见 HAL_TIM_PeriodElapsedCallback）：
 *
 *      TIM3  ── hcount++ ；检查是否摔倒 ；末尾按 CCD_Div 分频采一帧 CCD
 *      10ms  ── 读 MPU6050 -> 姿态解算 -> 偏航积分 -> 直立环 / 自起立
 *      50ms  ── 读编码器 -> 算速度 -> 速度环 + 转向环
 *
 *  ★ TIM3 现在是 10ms 一拍（tim.c: Period = 10000-1），不是 1ms。
 *    改这个周期必须同步改 TICK_10MS / TICK_50MS 两个宏，否则平衡环、
 *    速度环整体差 10 倍。周期放到 10ms 是为了给 CCD 让路：get_CCD()
 *    一帧约 0.7ms，在 1ms 周期下会吃掉 70% 的中断预算并触发 TimerErrorFlag。
 *
 * 串级结构（外环慢、内环快）：
 *
 *      速度环(50ms) ──输出──> AnglePID.Target ──┐
 *                                              ├─> 直立环(10ms) ──> AvePWM ─┐
 *      转向环(50ms) ────────────────────────────┼─> DifPWM ─────────────────┤
 *                                              │                           │
 *                          LeftPWM  = AvePWM + DifPWM/2  <─────────────────┤
 *                          RightPWM = AvePWM - DifPWM/2  <─────────────────┘
 *
 * 三个运行状态由 CarState 管理（见下方状态机定义）。
 * 主循环(while(1))只做两件事：刷 OLED、收蓝牙命令。
 * 所有实时控制 + CCD 采集都在中断里 —— 因为 OLED_Update() 走软件 I2C 推
 * 1024 字节，一次要 ~23ms，是主循环的全部大头。
 * ★ 上位机波形那条阻塞式串口发送已删除（9600 波特下每帧 ~21ms，
 *   和 OLED 合起来把主循环拖到实测 44.6ms）。CCD 波形改在 OLED 上直接画。
 * ========================================================================== */

/* ===== 车辆状态机（取代早期的 runflag 布尔量）=====
 *
 *   ST_IDLE     上电默认。电机断电，等蓝牙指令；每 10ms 也写一次 PWM=0
 *   ST_ERECT    自起立。甩轮把车摆进平衡窗口，最长 ERECT_TIMEOUT_MS(3s)
 *   ST_BALANCE  正常直立行驶。只有这个状态才跑平衡环 + 速度环 + 转向环
 *
 * 迁移路径：
 *   ST_IDLE    --收到 "1"--> StartErect() ------------> ST_ERECT
 *   ST_ERECT   --|Angle| <= ERECT_DONE_ANG---------->  ST_BALANCE
 *   ST_ERECT   --超过 ERECT_TIMEOUT_MS(3s)---------->  StopCar() -> ST_IDLE
 *   ST_BALANCE --|Angle| > ERECT_START_ANG---------->  StopCar() -> ST_IDLE
 *
 * CarState 是单字节：主循环写、中断读。中断要么看到"旧状态"，要么看到
 * "新状态已写好"，两种情况都安全，所以不需要临界区保护。 */
#define ST_IDLE     0u
#define ST_ERECT    1u
#define ST_BALANCE  2u
volatile uint8_t CarState = ST_IDLE;

/* ===== 控制节拍：TIM3 周期 x 下面两个分频 = 实际节拍 =====
 * ★ 改 tim.c 里 TIM3 的 Period 时，必须同步改这两行 —— 它们是"多少拍算一次"，
 *   不是时间。漏改的后果不是"慢一点"，而是平衡环/速度环整体差 10 倍：
 *     TIM3 = 1ms  (Period = 1000-1)   ->  TICK_10MS = 10, TICK_50MS = 50
 *     TIM3 = 10ms (Period = 10000-1)  ->  TICK_10MS = 1,  TICK_50MS = 5   <- 当前
 *   把 TIM3 放到 10ms 是为了给 CCD 让路：get_CCD() 一帧要 ~0.7ms，
 *   在 1ms 周期下会吃掉 70% 的中断预算并触发 TimerErrorFlag。 */
#define TICK_10MS   1
#define TICK_50MS   5

uint32_t hcount = 0, Count1 = 0;

/* CCD 采集节拍：每拍 +1，累计到 CCD_Div 才真采一帧。
 * 曝光时间 = CCD_Div x TIM3 周期(10ms)，完全由中断决定，与主循环无关。 */
static uint16_t CCD_count = 0;
static uint8_t ReviveCount = 0;   // 自动重启次数计数（当前未使用）
char display_buf[128];
uint32_t Rx_buf[300];

//#define RX_BUF_SIZE  128
//char BlueSerial_RxPacket[RX_BUF_SIZE];   // 接收缓存区
//volatile uint8_t BlueSerial_RxFlag = 0;     // 帧完成标志位
//static uint8_t RxState = 0;                 // 状态机状态
//static uint16_t pRxPacket = 0;              // 当前接收数据量


int16_t AX, AY, AZ, GX, GY, GZ;
volatile uint8_t TimerErrorFlag;
volatile uint16_t TimerCount;

float AngleAcc;
float AngleGyro;
float Angle;

/* ================== 偏航角 Yaw：Z 轴陀螺积分 ==================
 * 没有磁力计，纯积分，误差随时间累积。三个关键点：
 *
 * 1) 标度 YAW_LSB_PER_DPS = 16.384
 *      GYRO_CONFIG = 0x18 -> ±2000°/s -> 32768/2000 = 16.384 LSB/(°/s)
 *      参考例程用 ±250°/s 的 131，直接照抄会让偏航角差 8 倍。
 * 2) dt 固定 0.01f，不用 HAL_GetTick() —— 本块就是恒定 10ms 周期，
 *      用 ms 计数反而引入抖动污染积分。
 * 3) 全用 float 不用 double：Cortex-M3 无 FPU，double 走软件模拟，约慢 5 倍。
 *
 * YAW_BIAS_DPS 是 Z 轴零偏，标定方法：车静止 30s，取屏上 GZ 读数的均值 / 16.384。
 *      标定值 41.20 LSB / 16.384 = 2.51 °/s
 *      复测值 39.45 LSB / 16.384 = 2.41 °/s   <- 本值
 *   两次差 1.67 LSB(≈0.10 °/s)，来自温度与上电状态。所以不要指望写死一个值
 *   永远准确 —— 真正稳的做法是上电静止时自动标定。
 *   残余 0.10 °/s 若不处理，就是 6 °/min 的持续漂移。
 *
 * YAW_DEADZONE_DPS 就是压这个残余的：
 *   实测残余 -0.102 °/s 时，无死区漂移 -6.1 °/min；加 0.5 °/s 死区后压到
 *   0.18 °/min —— 抑制 34 倍。代价是慢速段(|ω|<0.5°/s)被截断不积分：
 *   一次 90° 慢转会丢 0.03~0.98°（转得越慢丢得越多，正比于慢速段时间）。
 *   零偏标得越准，死区就能开得越小，这个损失也随之变小。 */
#define YAW_LSB_PER_DPS   16.384f   /* ±2000°/s 量程：32768/2000 = 16.384 */
#define GYRO_LSB_PER_DPS  YAW_LSB_PER_DPS  /* 三轴共用灵敏度(±2000°/s)，GX/GZ 屏显换算 */
#define YAW_BIAS_DPS      2.41f     /* Z 轴零偏(°/s)：静止实测 GZ 均值 39.45 LSB / 16.384 */
#define YAW_DEADZONE_DPS  0.5f      /* 角速度死区(°/s)：压制静止时的积分漂移 */
#define YAW_DT            0.01f     /* 积分周期(s)：与 10ms 控制块一致 */
#define YAW_WRAP          1         /* 1=归算到 ±180°；0=不归算、持续累加 */
float Yaw = 0.0f;                   /* 偏航角(°)：车头左转为正（取决于模块安装方向） */
float YawRate = 0.0f;               /* 偏航角速度(°/s)：已扣零偏、已过死区 */
int16_t LeftPWM, RightPWM;			//左PWM，右PWM
int16_t AvePWM, DifPWM;				//平均PWM，差分PWM
int16_t DifPWMTarget = 0;			//转向环目标（差速），预留量
float DifSpeedFilter = 0.0f;		//转向速度低通滤波值：滤掉左右轮差速的抖动
#define TURN_FF  20.0f						/* 转向前馈：先把轮子推出电机/静摩擦死区，再由 TurnPID 修正。
											 * 没有它，|TurnPID.Out| 小的时候轮子根本不转，转向环会"粘住" */
#define TURN_FB_SIGN  (1)    /* 转向环反馈符号：+1=正接；-1=反馈取反（左右轮装反/拧线接反时用）
                              * 当前值 +1，与下面 joystick 分支的 Target = -RH/50.0 是配套改的。
                              * 这两个符号必须一起考虑：符号链是
                              *   Target -> DifPWM -> LeftPWM/RightPWM -> 实际左右轮 -> DifSpeed
                              * 要求"Target 加大"最终让 DifSpeed 也朝同方向走，否则就是正反馈，
                              * 车会越修越偏、一路打死。若实测发现是正反馈，把此处与本文件
                              * joystick 里 TurnPID.Target 的负号一起取反。 */

/* ---------- CCD 循迹（灰度线阵）----------
 * 约定：TurnPID.Target < 0 = 右转，与 joystick 分支完全一致。
 *   CCD_Zhongzhi > TRACK_CENTER -> 线偏向"符号所指的那一侧" -> Target 取相应符号修正
 *
 * 默认 TrackMode = 0：上电行为和只有摇杆时完全相同，不会自己动。
 * 发送裸字符 'T' 或 't' 才进入循迹，再发一次退出。
 *
 * ★ 为什么把"像素偏差"换算成"目标角速度"而不是直接给 PWM：
 *   循迹直接复用已经调好的转向环这条通路（Target 进 TurnPID，另有 TURN_FF 前馈），
 *   所以只需要一个"像素 -> 转/秒"的比例系数，不必再维护第二套转向 PID。 */
#define TRACK_DIR      (-1)     /* 循迹方向：CCD 第 1 像素在车身左侧时取 -1，装反了取 +1
                                 * 判据：把线放在传感器左半边，OLED 波形下陷出现在左边时
                                 *       TRK 应显示正值；若显示负值就是这个符号反了 */
#define TRACK_GAIN     1.2f     /* 满偏(±63 像素)对应的差速指令：1.2 档
                                 *   前馈 TURN_FF x 1.2 = 24，加 TurnPID 反馈上限 30 共 54，
                                 *   对 ±50 的 DifPWM 限幅还有余量；再大就长期饱和、无法回中 */
#define TRACK_DEAD     2        /* 中线死区(像素)：压掉 CCD_Zhongzhi 的 ±1 像素量化抖动 */
#define TRACK_LOST_MAX 25       /* 连续丢线多少帧后放弃转向：25 帧 x 40ms(CCD_Div=4) = 1s */
#define TRACK_SPEED    0.12f    /* 循迹前进速度：输出轴 转/秒，直接写进 SpeedPID.Target
                                 * ★ 必须给：joystick 分支只在 !TrackMode 时才写 SpeedPID.Target，
                                 *   循迹模式下没人给速度 -> Target 恒 0 -> AnglePID.Target 恒 0
                                 *   -> 车只剩差速、原地打转，不前进。
                                 * 0.08 是"尽可能慢"的下限，不是随手挑的数：
                                 *   44线编码器 x 30减速比，50ms 采样 -> 1 计数 = 0.0152 转/秒；
                                 *   AveSpeed 取两轮平均 -> 量化台阶 0.0076 转/秒。
                                 *   0.08 时每 50ms 只有 5.3 个计数(量化 9.4%)，再低就数不清了。
                                 * 起步靠积分：ErrorInt 每拍涨 Ki*v，约 2.3 秒才攒到 1 度倾角，
                                 *   所以从静止到走起来有约 2 秒的"酝酿"，不是故障。
                                 * 车速换算(轮径 65mm -> 周长 204mm)：0.08 x 204 = 16 mm/s。
                                 * 想调：0.06 更慢(4.0 计数/50ms，起步约 3.3 秒)；一顿一顿就加到 0.10 */
#define TRACK_CENTER   56       /* 循迹零点：直行时 CCD_Zhongzhi 的读数
                                 * 为什么不是 63.5(128 像素的几何中点)：
                                 *   镜头不是严格的中心投影，加上装配同心度、遮光罩、
                                 *   镜头筒遮挡都有固定偏差。实测线在画面居中时读数
                                 *   (45+68)/2 = 56，偏 7 像素(纸面上约 6mm)。
                                 *   用 56 当零点可以把这部分固定偏差直接吃掉。
                                 * 标定：让车对准直线，读 OLED 上的 CCD_Zhongzhi，把数抄到这里 */
/* ---------- 直角转弯：用 Yaw 把 90 度转完 ----------
 *
 * 这条赛道只有 90 度直角。直角对线阵来说是个"奇点"：
 *   线宽 w = w0 / cos(theta)，车转 90 度时 theta 从 0 走到 90，w 趋向无穷。
 *   实测(线宽 22 像素、阵列约 11.6cm 地面)：黑区会从 22 像素一步跳到约 75 像素，
 *   并顶到阵列的一端 —— 于是 CCD_Lost = 1。但这不是"没线"，是"直角"。
 *
 * 所以判据不能是"连续没线"：那分不出直角、脱轨、和发车点离赛道 80cm 三种情况。
 * 真正的判据是黑区的"拓扑形状"：
 *
 *     直道      两端都白，黑像素 22        -> 不算
 *     直角      一端白一端黑，黑像素 75    -> 算
 *     脱轨/发车 两端都白，黑像素 0         -> 不算（否则会在发车点凭空转 90 度）
 *     镜头全黑  两端都黑                   -> 不算（异或正好把它排除）
 *
 * 输出不直接算 PWM，而是写 TurnPID.Target —— 复用已经调好的转向环，
 * 于是转弯时左右轮差速仍然由编码器闭环，电池电压下降、轮子打滑都不改变转角。
 * Yaw 只负责判"什么时候停"(|累计转角| >= 90 度)，不参与控制，所以不用调增益。
 */
#define CCD_EDGE_LO        3        /* 阵列左端取样点（避开最外侧几个容易失真的像素） */
#define CCD_EDGE_HI        124      /* 阵列右端取样点 */
#define CORNER_MIN_DARK    40       /* 直角帧的最少黑像素数：直道 22，直角 75，取中 */
#define CORNER_CONFIRM     2        /* 连续几帧都是直角特征才认账（2 帧 = 80ms） */
#define PIVOT_RATE         1.5f     /* 转弯时写进 TurnPID.Target 的差速指令。
                                     *   单位与 TRACK_GAIN 的输出一致：满偏(63 像素)=1.2。
                                     *   1.5 比满偏大 25%，配合 TURN_FF=20 得到约 30 的前馈量。
                                     *   转得慢就加大；甩尾/打滑就减小。 */
#define PIVOT_DEG          90.0f    /* 目标转角(度) */
#define PIVOT_TIMEOUT_MS   3000     /* 转弯超时：陀螺仪异常/被挡住时兜底 */
#define PIVOT_ADVANCE_MS   0        /* 认出直角后"先直行多少 ms"再开始转。
                                     *
                                     * 为什么需要这个参数：CCD 装在轮轴前方约 L 厘米，而车是
                                     * 绕轮轴原地转的 —— 传感器走的是半径 L 的圆弧。
                                     * 若在"传感器刚看到直角"那一瞬间就转 90 度，转完传感器
                                     * 会停在离新线约 L 厘米处（几何上是切线关系，多转也追不上）：
                                     *     L <= 4 厘米   -> 落在阵列边缘内，循迹能把它拉回来
                                     *     L >  5.8 厘米 -> 完全出视野，SETTLE 里永远等不到线
                                     * 这时就要先直行 (L+1) 厘米，把轮轴压到转角上，
                                     * 转完传感器正好压住新线 —— 这是纯几何，不是调出来的。
                                     *
                                     * 换算：TRACK_SPEED=0.12 转/秒 x 204mm 周长 = 24mm/s，
                                     *       1 厘米约 420ms。所以填 L(厘米) x 42 毫秒。
                                     * 标定：拿尺量轮轴中心到 CCD 镜头的距离 L。
                                     * 先填 0 试：转完能自己找回来就不用管；找不到就按上式填。 */
#define SETTLE_OK_FRAMES   2        /* 转完后连续几帧看到合法细线才算找回线 */
#define SETTLE_TIMEOUT_MS  2000     /* 找回线超时 */

#define CORNER_LINE        0u       /* 正常循迹 */
#define CORNER_PIVOT       1u       /* 正在按 Yaw 转 90 度 */
#define CORNER_SETTLE      2u       /* 转完了，直行等线回来 */

volatile uint8_t TrackMode    = 0;  /* 0 = 摇杆转向；1 = CCD 循迹（'T'/'t' 切换） */
volatile uint8_t TrackLostCnt = 0;  /* 连续丢线帧计数 */

volatile uint8_t CornerState = CORNER_LINE;
volatile int8_t  CornerDir   = 0;   /* +1 = 往高位端转，-1 = 往低位端转 */
volatile float   YawTurned   = 0.0f;/* 本次转弯累计转角(度)：逐拍累加有符号增量 */
float    YawPrev     = 0.0f;        /* 上一拍的 Yaw，用于求增量 */
uint16_t PivotTicks  = 0;           /* 转弯已持续(ms) */
uint16_t SettleTicks = 0;           /* SETTLE 已持续(ms) */
uint8_t  CornerSeen  = 0;           /* 连续直角帧计数 */
uint8_t  SettleOk    = 0;           /* SETTLE 里连续合法帧计数 */

/* ---------- 自起立(Self-Erect)参数 ---------- */
#define ERECT_PWM        100		/* 甩轮PWM(0~100)：起不来找大；太猛会甩过头、电机发热 */
#define ERECT_START_ANG  55.0f	/* 平衡中 |Angle| 超过此值 -> 判定摔倒，进入自起立 */
#define ERECT_DONE_ANG   30.0f	/* 前倒方向：|Angle| 收进此窗口 -> 交回平衡环 */
#define ERECT_DONE_ANG_BACK 45.0f	/* 后倒方向：后侧更难抬，放宽到此角度就交回平衡环 */
#define ERECT_TIMEOUT_MS 3000	/* 甩轮超过此时间还没起来 -> 停机（路面太滑 / 被挡住） */
uint16_t ErectTime = 0;			/* 当前 ERECT 已持续(ms)：每 10ms 加一次，同时用于 LED 闪烁 */
#define ERECT_DIR        (1)		/* 甩轮方向：1=与平衡环同号(默认)；-1=取反(原地转圈/磨轮胎时改 -1) */
#define ERECT_PULSE_MS   400			/* 断续模式：每个周期通电时长(ms)；0=持续通电(一直甩) */
#define ERECT_PERIOD_MS  500		/* 断续周期(ms)：通电 400ms + 断电 100ms */
static uint16_t Count2 = 0;			//转向10ms计数（当前未使用）
float LeftSpeed, RightSpeed;		//左轮速度，右轮速度（输出轴 转/秒）
float AveSpeed, DifSpeed;			//平均速度，差分速度

float G = 0.00;						//加速度计角度零点偏置(°)：机械安装倾斜的补偿，可在蓝牙滑块在线调

/* ---------- 三个 PID 结构体：定义时同时给成员赋初值 ----------
 * 注意 PID_Update() 的两个特性（见 pid.c）：
 *   1) Ki==0 时积分项被强制清零 —— 所以"先关积分调参"是安全的
 *   2) 用微分先行：Out 里的微分项作用在 (Actual - Actual1) 上，而不是误差，
 *      所以改 Target 不会产生微分冲击 */
PID_t AnglePID =  					//角度环（直立环）：输入 Angle，输出 AvePWM。串级结构的内环
{
    .Kp = 16.9,						//比例项权重
    .Ki = 0.06,						//积分项权重
    .Kd = 30.4,						//微分项权重

    .OutMax = 80,					//输出限幅上限 -> 最大 PWM 80
    .OutMin = -80,					//输出限幅下限
	
	.OutOffset = 0,					//输出死区补偿：Out>0 时加、Out<0 时减，用来推开电机静摩擦
	
	.ErrorIntMax = 600,				//积分限幅上限（抗积分饱和）
	.ErrorIntMin = -600,			//积分限幅下限

};
PID_t SpeedPID =  					//速度环：输入 AveSpeed(转/秒)，输出 AnglePID.Target(角度下垂量)
{
    .Kp = 2.7,						//比例项权重
    .Ki = 0.21,						//积分项权重
    .Kd = 0,						//微分项权重

    .OutMax = 5,					//输出限幅 ±5°：限制直立目标的最大倾斜角（当前 ±5，比初版 ±10 更保守）
    .OutMin = -5,					
	
	.ErrorIntMax = 150,				//积分限幅上限
	.ErrorIntMin = -150,			//积分限幅下限

};
PID_t TurnPID =  					//转向环：输入左右轮差速，输出 DifPWM
{
    .Kp = 5.9,						//比例项权重
    .Ki = 0,						//积分项权重（Ki=0 -> 积分自动清零，纯比例控制）
    .Kd = 0,						//微分项权重

    .OutMax = 30,					//输出限幅 ±30
    .OutMin = -30,					
	
	.ErrorIntMax = 20,				//积分限幅上限
	.ErrorIntMin = -20,				//积分限幅下限

};

/* ==========================================================================
 * PID 状态复位 / 角度重对准
 *
 * PID_ResetAll()：把三个 PID 的 Target / Out / 积分 / 误差全部清零，并"预置上次值"
 *   为当前测量值，防止微分项在复位后的第一拍产生巨大冲击。
 *   摔倒(StopCar)、急停("0")、起立超时都会经过 StopCar()，所以都会走到这里。
 *   内部只有赋值，无耗时操作，因此可以从 1ms 中断里安全调用。
 *
 * Angle_Realign()：用加速度计把角度重新对准一次（仅静止时有效）。
 *   互补滤波 Alpha=0.001 的时间常数约 10s，摔倒后靠它自己收敛太慢，
 *   所以起立前主动重对准一次 —— 取 300ms 加速度计角的平均。
 *
 *   ★ 内部是 30 × HAL_Delay(10ms) = 300ms 的阻塞等待，只能放主循环调用，
 *     绝对不能放进 1ms 的 HAL_TIM_PeriodElapsedCallback。
 *   ★ 等待期间必须关掉 TIM3 中断：中断里也会读 MPU6050（同一条 I2C），
 *     两者并发会互相破坏时序。这里只清 DIER 的 UIE 位、不动其他状态，
 *     结束后按进入前的原状恢复。
 * ========================================================================== */
void PID_ResetAll(void)
{
    PID_Init(&AnglePID);
    PID_Init(&SpeedPID);
    PID_Init(&TurnPID);

    /* 预置"上次值"，防止微分项第一拍冲击 */
    AnglePID.Actual  = Angle;
    AnglePID.Actual1 = Angle;
    AnglePID.Error0  = AnglePID.Target - AnglePID.Actual;
    AnglePID.Error1  = AnglePID.Error0;

    SpeedPID.Actual  = AveSpeed;
    SpeedPID.Actual1 = AveSpeed;
    TurnPID.Actual   = DifSpeed;
    TurnPID.Actual1  = DifSpeed;

    DifSpeedFilter = DifSpeed;
    DifPWM         = 0;

    /* 直角转弯状态一起复位：摔车/急停/起立都会经过这里。
     * 否则再发 "1" 时可能从上一次的 PIVOT 状态续上，凭空转一个 90 度。 */
    CornerState    = CORNER_LINE;
    CornerDir      = 0;
    CornerSeen     = 0;
    YawTurned      = 0.0f;
    PivotTicks     = 0;
    SettleTicks    = 0;
    SettleOk       = 0;
}

void Angle_Realign(void)
{
    int32_t  sum = 0;
    int      k;
    uint32_t itWasOn;

    /* 阻塞期间要屏蔽 TIM3 中断：中断里也会读 MPU6050(同一条 I2C)，
     * 两者并发会互相破坏时序。这里只清 DIER 的 UIE 位、不改其他状态，
     * 结束后按进入前的原状恢复（这样上电初始化和运行中调用都适用）。 */
    itWasOn = (htim3.Instance->DIER & TIM_IT_UPDATE) ? 1u : 0u;
    __HAL_TIM_DISABLE_IT(&htim3, TIM_IT_UPDATE);

    for (k = 0; k < 30; k++)              /* 30 x 10ms = 300ms */
    {
        MPU6050_GetData(&AX, &AY, &AZ, &GX, &GY, &GZ);
        sum += (int32_t)(-atan2(AY, AZ) / 3.14159 * 180.0);
        HAL_Delay(10);
    }

    Angle = (float)sum / 30.0f + G;       /* 取平均，并叠加机械零点偏置 */

    if (itWasOn)
    {
        __HAL_TIM_CLEAR_IT(&htim3, TIM_IT_UPDATE);
        __HAL_TIM_ENABLE_IT(&htim3, TIM_IT_UPDATE);
    }
}

/* ==========================================================================
 * 状态迁移接口：StartErect() / StopCar()
 *   StartErect() 只从主循环调用（内部阻塞 300ms 做角度重对准）
 *   StopCar()    主循环和 10ms 中断都会调用，所以只做赋值 + PID 复位 + GPIO 写，
 *                这些在中断里都是安全的
 *   CarState 单字节：中断只会看到"旧状态"或"新状态已写好"，不需要临界区
 * ========================================================================== */
void StopCar(void)
{
    CarState  = ST_IDLE;
    ErectTime = 0;
    PID_ResetAll();               /* 摔倒/急停/超时：把所有环的内部状态一并清干净 */
    TB6612_setPWM(1, 0);          /* 停机PWM=0：IN1/IN2 同时为低 -> 电机自由停转 */
    TB6612_setPWM(2, 0);
}

void StartErect(void)
{
    if (CarState != ST_IDLE)
    {
        return;                   /* 已在运行就忽略，重复收到 "1" 不会重入 */
    }

    /* 先重对准角度，再进起立：摔倒后互补滤波要十几秒才收敛，
     * 不等它就会带着错的初始角度去甩轮。300ms 阻塞，只能主循环调用。 */
    Angle_Realign();

    PID_ResetAll();
    ErectTime = 0;

    CarState = ST_ERECT;          /* 最后一步，让中断开始接管 */
}

static const char *StateStr(void)
{
    if (CarState == ST_BALANCE) return "BAL";
    if (CarState == ST_ERECT)   return "ERECT";
    return "IDLE";
}

/* ==========================================================================
 * TIM3 更新中断：整个系统的唯一时基（10ms）
 *   tim.c: Prescaler = 72-1, Period = 10000-1  ->  72MHz/72/10000 = 10ms
 *
 * 节拍分三层（分频值见文件上方 TICK_10MS / TICK_50MS 两个宏）：
 *   每 1 拍    hcount++，并在末尾检查是否摔倒
 *   每 10ms    读 MPU6050 -> 姿态解算 -> 偏航积分 -> 直立环 / 自起立
 *   每 50ms    读编码器 -> 算速度 -> 速度环 + 转向环
 *   每 1 拍末  按 CCD_Div 分频采一帧 CCD（约 0.7ms）
 *
 * 时间预算（一拍 = 10ms）：
 *   MPU6050 一次 I2C 突发读     ~150us
 *   姿态解算 + 三态控制分派      ~70us
 *   CCD 一帧（仅 1/CCD_Div 拍）  ~700us  -> 按 CCD_Div=4 摊薄约 175us
 *   合计                         ~520us / 10ms ≈ 5.2%
 *   最坏单拍（正好赶上采 CCD）    ~1.0ms = 10%，仍然宽裕。
 * ========================================================================== */
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{
    if (htim != &htim3)
    {
        return;
    }

    hcount++;
    __HAL_TIM_CLEAR_IT(&htim3, TIM_IT_UPDATE);

    if (hcount >= TICK_10MS)                          /* ===== 10ms 层 ===== */
    {
        hcount = 0;
        MPU6050_GetData(&AX, &AY, &AZ, &GX, &GY, &GZ);   /* 一次 I2C 突发读 14 字节，约 150us */
        /* 补偿 X 轴零偏：+10 LSB ≈ 0.61°/s，是实测硬件的固定偏置 */
        GX += 10;

        /* 加速度计角度：atan2 输出弧度，转成角度；G 是机械零点偏置 */
        AngleAcc = -atan2(AY, AZ) / 3.14159 * 180 + G;

        /* 互补滤波 Alpha=0.001：
         *   加速度计长期准但不抗振动（对线加速度敏感）
         *   陀螺积分短期准但会漂
         *   时间常数 ≈ 1/(Alpha * 100Hz) = 10s，即 10s 内信陀螺，更久信加速度计
         * 陀螺预测项的减号来自 Angle 的符号约定（-atan2(AY,AZ)），与 GX 正方向相反。
         * dt 直接写 0.01 而不用变量：本块就是恒定 10ms 周期。 */
        AngleGyro = Angle - GX / 32768.0 * 2000 * 0.01;
        float Alpha = 0.001f;
        Angle = Alpha * AngleAcc + (1 - Alpha) * AngleGyro;

        /* ---------- 偏航角：Z 轴陀螺积分 ----------
         * 标度、零偏、死区、dt 的取值理由见文件上方 YAW_* 宏定义处的注释。
         * 与参考例程的两处关键差异：
         *   1) 量程用 GYRO_CONFIG=0x18(±2000°/s) 的 16.384 LSB/(°/s)，
         *      参考例程是 0x00(±250°/s) 的 131，照抄会让偏航角差 8 倍
         *   2) dt 固定 0.01f，不用 HAL_GetTick() 的 1ms 分辨率去凑 */
        YawRate = GZ / YAW_LSB_PER_DPS - YAW_BIAS_DPS;
        if (YawRate > -YAW_DEADZONE_DPS && YawRate < YAW_DEADZONE_DPS) YawRate = 0.0f;
        Yaw += YawRate * YAW_DT;
#if YAW_WRAP
        if      (Yaw >  180.0f) Yaw -= 360.0f;
        else if (Yaw < -180.0f) Yaw += 360.0f;
#endif

        /* ---------- 偏航增量累加 + 直角转弯的完成判据 ----------
         * Yaw 每拍归算到 ±180 度，所以不能直接算 |Yaw - 转弯起点|：
         * 起点 179 度再左转 90 度会归算成 -91 度，差值变成 270 度而不是 90 度，
         * 判据会当场成立、车只转一点点就停。
         * 改成逐拍累加"有符号增量"，跨 ±180 度时用 ±360 补回来 ——
         * 累加结果就是真实绝对转角，与归算点无关。
         * 放在 10ms 层而不是 CCD 块(40ms)：40ms 判一次，120 度/秒下要过冲 4.8 度。 */
        {
            float dYaw = Yaw - YawPrev;

            if (dYaw >  180.0f) dYaw -= 360.0f;
            if (dYaw < -180.0f) dYaw += 360.0f;
            YawPrev = Yaw;

            if (CornerState == CORNER_PIVOT)
            {
                PivotTicks += 10;

                /* 前进段：先把轮轴送到转角上，再开始转（理由见 PIVOT_ADVANCE_MS）。
                 * 转角只从"开始转"那一刻累加，前进段的偏航抖动不算进 90 度。 */
                if ((int32_t)PivotTicks >= (int32_t)PIVOT_ADVANCE_MS)
                    YawTurned += dYaw;

                if (((int32_t)PivotTicks >= (int32_t)PIVOT_ADVANCE_MS && fabsf(YawTurned) >= PIVOT_DEG)
                    || (int32_t)PivotTicks >= (int32_t)(PIVOT_ADVANCE_MS + PIVOT_TIMEOUT_MS))
                {
                    CornerState    = CORNER_SETTLE;   /* 转角够了：松舵，交给 SETTLE */
                    SettleTicks    = 0;
                    SettleOk       = 0;
                    TurnPID.Target = 0.0f;
                }
            }
            else if (CornerState == CORNER_SETTLE)
            {
                if (SettleTicks < 60000u) SettleTicks += 10;
            }
        }

        /* ================= 控制分派：三态互斥 ================= */
        if (CarState == ST_BALANCE)
        {
            /* ---------- 直立（原平衡环）----------
             * 取负号：AnglePID 的误差定义为 Target-Actual，而轮子正转方向
             * 与 Angle 的正方向相反，所以输出要反一次才对应"往哪边倒就往哪边追"。 */
            AnglePID.Actual = Angle;
            PID_Update(&AnglePID);
            AvePWM = -AnglePID.Out;

            LeftPWM  = AvePWM + DifPWM / 2;
            RightPWM = AvePWM - DifPWM / 2;

            if (LeftPWM > 80)        LeftPWM  = 80;
            else if (LeftPWM < -80)  LeftPWM  = -80;
            if (RightPWM > 80)       RightPWM = 80;
            else if (RightPWM < -80) RightPWM = -80;

            TB6612_setPWM(1, LeftPWM);
            TB6612_setPWM(2, RightPWM);
        }
        else if (CarState == ST_ERECT)
        {
            /* ---------- 自起立：两轮同向同幅给 PWM，用反作用力矩把车甩到竖直 ----------
             * 符号与平衡环一致：Angle>0 往前甩，Angle<0 往后甩。
             * 前后两个方向用不同的"到位角"：后侧更难抬，所以门槛放宽。
             * 起立过程中不允许转向，只让转向环把差速拉回 0。 */
            float erectDoneAng = (Angle > 0.0f) ? ERECT_DONE_ANG : ERECT_DONE_ANG_BACK;

            if (fabsf(Angle) <= erectDoneAng)
            {
                /* 已进入平衡范围 -> 交回平衡环 */
                PID_ResetAll();
                ErectTime = 0;
                CarState  = ST_BALANCE;
            }
            else if (ErectTime < ERECT_TIMEOUT_MS)
            {
                int16_t swing = (Angle > 0.0f) ? ERECT_PWM : -ERECT_PWM;
                if (ERECT_DIR < 0) swing = -swing;      /* 方向不对就取反 */

                if (ERECT_PULSE_MS > 0 && (ErectTime % ERECT_PERIOD_MS) >= ERECT_PULSE_MS)
                    swing = 0;                          /* 断续(脉冲)模式：断电间隙让车靠惯性继续甩过去 */

                /* 转向环在此也运行，但目标固定为 0，只负责把差速压回 0 */
                TurnPID.Target = 0.0f;
                TurnPID.Actual = DifSpeed;
                PID_Update(&TurnPID);
                DifPWM = (int16_t)TurnPID.Out;

                LeftPWM  = swing + DifPWM / 2;
                RightPWM = swing - DifPWM / 2;

                if (LeftPWM > 100)        LeftPWM  = 100;
                else if (LeftPWM < -100)  LeftPWM  = -100;
                if (RightPWM > 100)       RightPWM = 100;
                else if (RightPWM < -100) RightPWM = -100;

                TB6612_setPWM(1, LeftPWM);
                TB6612_setPWM(2, RightPWM);
                ErectTime += 10;                        /* 本块每 10ms 跑一次 */
            }
            else
            {
                /* ---------- 超时：路面太滑/被挡住/轮胎打滑，停车 ----------
                 * 退回 IDLE，再发一次 "1" 可以重试。 */
                StopCar();
            }
        }
        else
        {
            /* ---------- ST_IDLE（上电默认）：电机断电 ----------
             * 每 10ms 主动写一次 0，是防御式写法：任何意外的残留 PWM 都会被抹掉 */
            TB6612_setPWM(1, 0);
            TB6612_setPWM(2, 0);
        }
    }

    Count1 ++;				//计次计数

    if (Count1 >= TICK_50MS)		/* ===== 50ms 层：速度环 + 转向环 ===== */
    {
        Count1 = 0;			//计次清零，用于下次计数

        /* 编码器：每 50ms 读一次增量，读完自动清零计数器
         *   ReadSpeed() 返回 (short)CNT 的增量，带符号（可正可负）
         *   44   = 电机转一圈的计数个数
         *   0.05 = 采样周期 50ms
         *   30   = 减速比
         *   -> 结果是"输出轴 转/秒"
         * 右轮取负号：两个编码器的计数方向相反，这里统一成"前进为正" */
        LeftSpeed = ReadSpeed(&htim2) / 44.0 / 0.05 / 30;
        RightSpeed = -ReadSpeed(&htim4) / 44.0 / 0.05 / 30;

        /*信号反转*/
			AveSpeed = (LeftSpeed + RightSpeed) / 2.0;	
			DifSpeed = TURN_FB_SIGN * (LeftSpeed - RightSpeed);			
			
			/*执行PID主程序*/
			if (CarState == ST_BALANCE)		/* 只有直立行驶时才跑速度环+转向环 */
			{
				/* ---------- 循迹前进速度；丢线超时归零 -> 原地直立 ----------
				 * 摇杆分支不再负责循迹时的前进速度(见 joystick 里的 !TrackMode 判断)，这里必须给。
				 * 否则 SpeedPID.Target 恒 0：速度环把车速稳到 0，AnglePID.Target 跟着变 0，
				 * 车只剩 DifPWM 差速 -> 原地打转、不前进。
				 * 丢线超过 TRACK_LOST_MAX(25 帧 x 40ms = 1s)：这里与 CCD 块里的 TurnPID.Target
				 * 同时归零 -> 车停住并原地直立，不再盲走冲出赛道。 */
				if (TrackMode)
					SpeedPID.Target = (CornerState != CORNER_LINE) ? TRACK_SPEED : ((TrackLostCnt >= TRACK_LOST_MAX) ? 0.0f : TRACK_SPEED);

				/*速度环PID计算*/
				SpeedPID.Actual = AveSpeed;			
				PID_Update(&SpeedPID);				//调用封装好的函数，一步完成PID计算和更新
				AnglePID.Target = SpeedPID.Out;		/* 外环输出当作内环目标：车快了就往前倾一点来减速 */
				
				/*转向PID计算*/
				DifSpeedFilter += 0.5f * (DifSpeed - DifSpeedFilter);	/* 转向速度一阶低通：抑制编码器抖动/打滑毛刺，系数 0.5 可调(0.3 更平滑 / 0.7 更跟手) */
				TurnPID.Actual = DifSpeedFilter;			
				PID_Update(&TurnPID);				//调用封装好的函数，一步完成PID计算和更新
				DifPWM = (int16_t)(TurnPID.Out + TURN_FF * TurnPID.Target);	/* 转向反馈 + 转向前馈 */
				if (DifPWM > 50) DifPWM = 50; else if (DifPWM < -50) DifPWM = -50;	/* 限幅 ±25/轮：前馈+反馈叠加后容易超出，必须夹住 */				

        }

    }


    /* 平衡中倒下超过 ERECT_START_ANG -> StopCar() 停车回 IDLE。
     * 本判断在 1ms 层执行，但 Angle 是 10ms 更新一次，所以实际响应粒度是 10ms。
     * StopCar() 内部会做 PID_ResetAll()，所以再发一次 "1" 时 StartErect()
     * 会重新 Angle_Realign() 重对准一次角度。 */
    if (CarState == ST_BALANCE && fabsf(Angle) > ERECT_START_ANG)
    {
        StopCar();
    }

    /* ================= CCD 线阵采集（本拍的最后一步）=================
     * 位置是刻意选的：本拍该算的控制量（AnglePID -> AvePWM -> TB6612_setPWM）
     * 和 50ms 层的 DifPWM 都已经算完并写进寄存器了，这 ~0.7ms 的阻塞
     * 不会推迟任何一次控制动作，只是吃掉本拍剩余的空闲时间。
     *
     * ★ 曝光 = CCD_Div x TIM3 周期(10ms)，完全由中断决定，与主循环无关。
     *   主循环里 OLED_Update() 要跑 20~24ms，但曝光时间不受它影响 ——
     *   这正是"把采集放进中断"的全部意义。
     *   一帧读出 ≈0.6ms（TIME_us=2 -> CLK 约 110kHz），占 10ms 的 6%。
     *
     * ★ CCD_AutoExposure() 不能放这里。TIM3 优先级 0 会抢占 SysTick(优先级 15)，
     *   中断里 HAL_GetTick() 是冻住的，HAL_Delay() 会死循环。
     *   曝光调节留在主循环，这里只负责"到点就采"。 */
    if (++CCD_count >= CCD_Div)
    {
        CCD_count = 0;
        get_CCD();          /* = RD_TSL()：128 像素读出 + 动态阈值 + 找沿 + 中线 */

        /* ---------- 循迹：中线偏差 -> 转向目标 ----------
         * 放在这里(取完一帧之后)而不是主循环里，是为了"看"和"算"在同一拍完成，
         * 转向指令永远不会比它所依据的那一帧图像晚。
         *
         * 丢线处理：CCD_Lost 时先不动 TurnPID.Target，保持上一帧的转向，
         *   让车按原方向盲走一小段把线找回来；连续 TRACK_LOST_MAX 帧都找不到
         *   才把 Target 归零；同时 50ms 层把前进速度也归零 -> 原地直立，不再盲走。
         *
         * 只在 ST_BALANCE 里生效：起立过程中转向环的目标固定为 0，
         *   不能让循迹在甩轮阶段插手，否则起立会带一个初始角速度。 */
        if (TrackMode && CarState == ST_BALANCE)
        {
            /* ---------- 本帧的"形状"特征：端点黑不黑 + 黑像素总数 ----------
             * 128 次比较在 25Hz 下约十几个 us，可以忽略。
             * darkCnt 是区分"直角"和"线跑到视野边缘"的关键：
             *   直角       黑区顶到一端且很宽(75)
             *   线偏到边缘 也顶到一端，但很窄(约 10) */
            uint8_t eL      = (ccd_adc[CCD_EDGE_LO] < CCD_Yuzhi) ? 1u : 0u;
            uint8_t eR      = (ccd_adc[CCD_EDGE_HI] < CCD_Yuzhi) ? 1u : 0u;
            uint8_t darkCnt = 0;
            uint8_t kk;

            for (kk = 0; kk < CCD_PIXELS; kk++)
                if (ccd_adc[kk] < CCD_Yuzhi) darkCnt++;

            if (CornerState == CORNER_LINE)
            {
                /* 直角确认：本帧没有合法细线 + 黑区只顶住一端 + 黑像素够多。
                 * 用异或而不是"任一端黑"：镜头被遮/过曝时两端都黑，不该算直角。 */
                if (CCD_Lost && (eL ^ eR) && darkCnt >= CORNER_MIN_DARK)
                {
                    if (CornerSeen < 255) CornerSeen++;
                }
                else
                {
                    CornerSeen = 0;
                }

                if (CornerSeen >= CORNER_CONFIRM)
                {
                    /* 黑区压在哪一端，线就往哪边走 -> 朝那边转。
                     * 符号走循迹那条通路(Target = TRACK_DIR x 方向 x 速率)，
                     * 保证"转过去"和"循迹纠偏"用的是同一个旋向约定，不用单独标定。 */
                    CornerDir      = eR ? 1 : -1;
                    CornerState    = CORNER_PIVOT;
                    YawTurned      = 0.0f;
                    YawPrev        = Yaw;       /* 以本拍为起点重新对齐 */
                    PivotTicks     = 0;
                    TrackLostCnt   = 0;
                    CornerSeen     = 0;
                    TurnPID.Target = TRACK_DIR * (float)CornerDir * PIVOT_RATE;
                }
                else if (CCD_Lost)
                {
                    if (TrackLostCnt < 255) TrackLostCnt++;
                    if (TrackLostCnt >= TRACK_LOST_MAX)
                        TurnPID.Target = 0.0f;  /* 丢线太久：转向归零，前进速度在 50ms 层同时归零 */
                    /* 否则保持上一帧的转向，让车按原方向盲走一小段把线找回来 */
                }
                else
                {
                    TrackLostCnt = 0;

                    int16_t err = (int16_t)CCD_Zhongzhi - TRACK_CENTER;  /* 相对零点 TRACK_CENTER 的偏差 */
                    if (err > -TRACK_DEAD && err < TRACK_DEAD) err = 0;  /* 死区：吃掉 ±1 像素量化抖动 */
                    TurnPID.Target = TRACK_DIR * TRACK_GAIN * (float)err / 63.0f;
                }
            }
            else if (CornerState == CORNER_PIVOT)
            {
                /* 转弯中 CCD 不参与，转向目标固定。
                 * 每帧重写一次而不是只在进入时写一次：50ms 层每拍都要拿这个 Target
                 * 乘 TURN_FF 算前馈，被别处改掉就会丢前馈、转不动。 */
                TurnPID.Target = ((int32_t)PivotTicks >= (int32_t)PIVOT_ADVANCE_MS)
                               ? (TRACK_DIR * (float)CornerDir * PIVOT_RATE)
                               : 0.0f;      /* 前进段先直行，把轮轴送到转角上 */
                TrackLostCnt   = 0;         /* 转弯不是"丢线"：别让丢线计数走完把车停住 */
            }
            else /* CORNER_SETTLE */
            {
                /* 转完了：先直行退出直角交点，等 CCD 重新看到一条合法细线。
                 * ★ 关键：不能转完立刻回 CORNER_LINE。刚转过 90 度时车正骑在两条
                 *   线的交点上，画面依然是"黑区顶到一端"的直角特征，会立刻被当成
                 *   下一个直角 -> 无限原地转圈。所以这里把转弯判据整个屏蔽掉。 */
                TurnPID.Target = 0.0f;
                TrackLostCnt   = 0;

                if (!CCD_Lost)
                {
                    if (SettleOk < 255) SettleOk++;
                    if (SettleOk >= SETTLE_OK_FRAMES)
                    {
                        CornerState = CORNER_LINE;   /* 线回来了，交回正常循迹 */
                        CornerSeen  = 0;
                    }
                }
                else
                {
                    SettleOk = 0;
                }

                if (SettleTicks >= SETTLE_TIMEOUT_MS)   /* 超时：认输，回循迹让它自己找 */
                {
                    CornerState = CORNER_LINE;
                    SettleOk    = 0;
                }
            }
        }
    }

    if (__HAL_TIM_GET_FLAG(&htim3, TIM_IT_UPDATE) != RESET)
    {

        if (__HAL_TIM_GET_FLAG(&htim3, TIM_IT_UPDATE) == SET)
        {
            TimerErrorFlag = 1;  // 中断超时标记：本函数跑完时下一拍中断已经又到了
                                  // -> 说明这次中断处理超时了，留给调试观察用

            __HAL_TIM_CLEAR_IT(&htim3, TIM_IT_UPDATE);
        }

        TimerCount = __HAL_TIM_GET_COUNTER(&htim3);
    }
}

/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{

  /* USER CODE BEGIN 1 */

  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_TIM3_Init();
  MX_TIM1_Init();
  MX_TIM2_Init();
  MX_TIM4_Init();
  MX_USART3_UART_Init();
  MX_ADC1_Init();
  /* USER CODE BEGIN 2 */
    HAL_Delay(200);   // 等 OLED 上电稳定，否则首屏可能显示异常
    OLED_Init();
    OLED_Clear();

    MPU6050_Init();
    Angle_Realign();   /* 上电先用加速度计对准角度(静止时有效)，否则互补滤波要十几秒才收敛，
                        * 期间发的"1"会让车带着错误的角度去甩轮。此处 TIM3 中断还没开，安全。 */
    HAL_TIM_PWM_Start(&htim1, TIM_CHANNEL_1);
    HAL_TIM_PWM_Start(&htim1, TIM_CHANNEL_4);
    HAL_TIM_Encoder_Start(&htim2, TIM_CHANNEL_ALL);
    HAL_TIM_Encoder_Start(&htim4, TIM_CHANNEL_ALL);
    Ccd_Init();          /* CCD 空闲电平：CLK=H, SI=L。严格说 RD_TSL() 每帧开头都会
                          * 重新设定这两个电平，所以这一步是冗余的；保留它只是为了
                          * 和 CCD 原工程的初始化序列一致，并给以后改时序一个明确起点。 */
    BlueSerial_Init();   // 初始化蓝牙串口接收
    HAL_TIM_Base_Start(&htim3);
    uint8_t ID;
    ID = MPU6050_GetID();   /* 读 WHO_AM_I：0x68 说明 MPU6050 在线。结果当前未使用，
                             * 需要时可放到 OLED 上看以确认传感器是否应答 */
    OLED_Update();
    MX_TIM3_Init();                  /* 重复初始化一次 TIM3（与上面 MX_TIM3_Init() 同款配置），
                                      * 确保在开中断前寄存器是干净的 */
    HAL_TIM_Base_Start_IT(&htim3);   /* 10ms update interrupt（tim.c: Period = 10000-1）*/
    PID_Init(&AnglePID);
    PID_Init(&SpeedPID);
    PID_Init(&TurnPID);

    CarState = ST_IDLE;          /* 上电默认：电机断电，等蓝牙 "1" 才开始 */

    // 预置角度环误差，抑制微分冲击
    AnglePID.Actual = Angle;
    AnglePID.Actual1 = Angle;   //同步预置上次实际值，防止微分项第一拍冲击
    AnglePID.Error0 = AnglePID.Target - AnglePID.Actual;
    AnglePID.Error1 = AnglePID.Error0;    
  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
    while (1)
    {
        int len;
        uint8_t i;
        static uint32_t lastSendTime = 0;
//	TB6612_setPWM(2,100);

        /* 状态指示灯（PC13，低电平点亮）：
         *   熄灭 = IDLE 待机    闪烁 = ERECT 自起立中    常亮 = BALANCE 直立行驶
         *   闪烁由 ErectTime/150 决定：每 150ms 翻转一次 */
        {
            uint8_t ledOff;
            if (CarState == ST_BALANCE)     ledOff = 0;
            else if (CarState == ST_ERECT)  ledOff = (uint8_t)((ErectTime / 150u) & 1u);
            else                            ledOff = 1;
            HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, ledOff ? GPIO_PIN_SET : GPIO_PIN_RESET);
        }


        /* ---------- OLED 布局（128x64，OLED_6X8 字体每字符 6 像素宽）----------
         *   y=0        CCD: D<曝光Div> <ms>ms  M<Max> m<Min>
         *   y=8        CCD: T<阈值> Z<中线> <左沿>-<右沿> L<丢线>
         *   y=16..31   CCD: 128 像素波形 + 阈值虚线
         *   y=32   T:<角度环目标值>        (x=0,  宽 0..41)
         *          Yaw:<偏航角 度>         (x=60, 宽 60..125)
         *   y=40   Angle:<角度环实际值>    (x=0)
         *   y=48   O:<角度环输出>          S:<右轮转速>      (x=70)
         *   y=56   S<左轮转速>             (x=84)
         *
         * 每行最多 21 个字符（128/6）。最长情形 "T255 Z127 127-127 L1" = 20 字符，
         * 不会越界。字段间距都是按 6 像素/字符算好的，互不重叠。
         * ★ OLED.c 写显存用的是 |= 而不是 =，字段一旦重叠会按"按位或"叠出花屏，
         *   而不是互相覆盖 —— 所以改布局时必须自己算宽度。
         * ★ 想看 PID 那三行被注释掉的 KP/KI/KD，得先把 CCD 的 y=0/y=8 挪走，
         *   否则 y=8 会和 KP 行按位或叠在一起。 */
        OLED_Clear();
/* ===================== CCD 线阵显示 =====================
 * 波形纵轴取 0..CCD_Max，下限取 0 而不是 CCD_Min：
 * 若按 Min..Max 自动拉伸，而 CCD_Yuzhi 又恒等于 (Max+Min)/2，
 * 阈值线就永远落在正中间，等于没画。取 0 作下限后，
 * "阈值切在波形多高的位置"才是有信息量的。
 *
 * ★ ccd_adc[] 由 TIM3 中断写、这里读，理论上有撕裂帧（读到半新半旧）。
 *   概率 ≈ 0.6ms/(CCD_Div x 10ms) ≈ 1.5%，只影响这一屏画面，下一帧即恢复，
 *   所以不做双缓冲。
 * ★ 128 次 OLED_DrawPoint 约 130us，相对 OLED_Update() 的 ~23ms 可忽略。 */
        {
            uint8_t  k;
            uint16_t den = CCD_Max ? CCD_Max : 1u;   /* 纵轴满量程 = 本帧最亮，防除 0 */
            uint8_t  ty;

            OLED_Printf(0, 0, OLED_6X8, "D%u %ums M%u m%u",
                        (unsigned)CCD_Div, (unsigned)(CCD_Div * 10u),
                        (unsigned)CCD_Max, (unsigned)CCD_Min);

            OLED_Printf(0, 8, OLED_6X8, "T%u Z%u %u-%u L%u",
                        (unsigned)CCD_Yuzhi, (unsigned)CCD_Zhongzhi,
                        (unsigned)CCD_Left,  (unsigned)CCD_Right, (unsigned)CCD_Lost);

            /* 直角转弯状态：C0=循迹中 C1=正在转 C2=等线回来；后面跟本次累计转角 */
            OLED_Printf(92, 8, OLED_6X8, "C%u%+03.0f",
                        (unsigned)CornerState, (double)YawTurned);

            /* 波形：一列一点，128 点正好铺满屏宽 */
            for (k = 0; k < CCD_PIXELS; k++)
            {
                uint8_t h = (uint8_t)((uint32_t)ccd_adc[k] * 15u / den);
                if (h > 15) h = 15;
                OLED_DrawPoint(k, (int16_t)(31 - h));
            }

            /* 阈值线：虚线（每 4 像素一点），落在阈值对应的高度上 */
            ty = (uint8_t)(31 - ((uint32_t)CCD_Yuzhi * 15u / den));
            if (ty > 31) ty = 31;
            for (k = 0; k < CCD_PIXELS; k += 4) OLED_DrawPoint(k, (int16_t)ty);
        }

//        OLED_Printf(0, 0, OLED_6X8, "ST:%s %d", StateStr(), (int)ErectTime);   /* 状态 + 起立计时(ms) */
//        OLED_Printf(0, 8, OLED_6X8, "KP:%05.2f//%05.2f//%05.2f ", AnglePID.Kp, SpeedPID.Kp, TurnPID.Kp);		//角度环Kp
//        OLED_Printf(0, 16, OLED_6X8, "KI:%05.2f//%05.2f//%05.2f", AnglePID.Ki, SpeedPID.Ki, TurnPID.Ki);		//角度环Ki
//        OLED_Printf(0, 24, OLED_6X8, "KD:%05.2f//%05.2f//%05.2f", AnglePID.Kd, SpeedPID.Kd, TurnPID.Kd);		//角度环Kd
        OLED_Printf(0, 32, OLED_6X8, "T:%+05.1f", AnglePID.Target);	//角度环目标值
        OLED_Printf(60, 32, OLED_6X8, "Yaw:%+07.2f", Yaw);			//偏航角(°)：车头左转为正
        OLED_Printf(0, 40, OLED_6X8, "Angle:%+05.1f", Angle);			//角度环实际值
        OLED_Printf(0, 48, OLED_6X8, "O:%+05.0f", AnglePID.Out);	//角度环输出值
//        OLED_Printf(0, 56, OLED_6X8, "GX%+05.1f", GX / GYRO_LSB_PER_DPS);  /* X轴角速度(°/s)：静止应为 0 */
//        OLED_Printf(42, 56, OLED_6X8, "GZ%+05.1f", GZ / GYRO_LSB_PER_DPS);  /* Z轴角速度(°/s)：静止读数应接近 YAW_BIAS_DPS */
//        OLED_Printf(70, 40, OLED_6X8, "G:%+02.2f", G);
        OLED_Printf(70, 48, OLED_6X8, "S:%+02.2f", RightSpeed);
        OLED_Printf(84, 56, OLED_6X8, "S%+02.2f", LeftSpeed);
        OLED_Printf(0, 56, OLED_6X8, "TRK%c%+05.2f", TrackMode ? '!' : '-', TurnPID.Target);/* ! = 循迹中，- = 非循迹 */
        OLED_Update();


        /* ---- 蓝牙命令：两种格式都支持 ----
         *   裸字符（手机串口助手直接敲）：'1' = 起立   '0' = 急停   'T'/'t' = 切换循迹
         *   [包]（App/上位机）：[1] / [0] / [t] 含义相同，另外还有滑块和摇杆
         *
         * ★ 'T'/'t' 必须发裸字节。BlueSerial.c 的接收状态机只在"不在 [ ] 包内"
         *   时才把字节送进这个命令通道，所以 "[T]" 会被当成包内容进下面的 Tag 分支，
         *   而 Tag 只认 1/0/t/key/slider/joystick —— "[T]" 无效，"[t]" 有效。 */
        if (BlueSerial_CmdFlag)
        {
            char cmd = BlueSerial_CmdChar;
            BlueSerial_CmdFlag = 0;
            if      (cmd == '1') { StartErect(); }
            else if (cmd == '0') { StopCar(); }
            else if (cmd == 'T' || cmd == 't')
            {
                /* 切换循迹开关。顺手清掉丢线计数和残留的转向目标，
                 * 避免上一次循迹留下的 Target 在切换瞬间造成冲击 */
                TrackMode      = !TrackMode;
                TrackLostCnt   = 0;
                TurnPID.Target = 0.0f;
                CornerState    = CORNER_LINE;   /* 顺手退出直角转弯状态 */
                CornerSeen     = 0;
            }
        }

        /* 遍历两个接收缓冲槽，逐个处理已收完的 [包] */
        for (i = 0; i < 2; i++)
        {
            if (BlueSerial_RxFlag[i] == 1)
            {
                char *Tag = strtok(BlueSerial_RxPacket[i], ",");	//取第1段，作为标签Tag

                if (Tag != NULL)
                {
                    if (strcmp(Tag, "1") == 0)                  /* 收到 [1] -> 起立 */
                    {
                        StartErect();
                    }
                    else if (strcmp(Tag, "0") == 0)             /* 收到 [0] -> 急停 */
                    {
                        StopCar();
                    }
                    else if (strcmp(Tag, "t") == 0)             /* 收到 [t] -> 切换循迹（小写才有效，大写 T 要走裸字节） */
                    {
                        TrackMode      = !TrackMode;
                        TrackLostCnt   = 0;
                        TurnPID.Target = 0.0f;
                        CornerState    = CORNER_LINE;   /* 顺手退出直角转弯状态 */
                        CornerSeen     = 0;
                    }
                    else if (strcmp(Tag, "key") == 0)           /* [key,名称,动作]：按键帧 */
                    {
                        char *Name = strtok(NULL, ",");			//取第2段，作为按键名称
                        char *Action = strtok(NULL, ",");		//取第3段，作为按键动作

                        /*此处执行按键动作，目前按键暂时没有用到*/
                    }
                    else if (strcmp(Tag, "slider") == 0)	//[slider,名称,值]：滑块帧，用于在线调参
                    {
                        char *Name = strtok(NULL, ",");			//取第2段，作为滑块名称
                        char *Value = strtok(NULL, ",");		//取第3段，作为滑块值

                        /*执行滑块操作：把上位机传来的值写进对应的 PID 参数*/
                        if (strcmp(Name, "AngleKp") == 0)	//滑块名称为AngleKp
                        {
                            AnglePID.Kp = atof(Value);		//把滑块值赋给角度环Kp
                        }
                        else if (strcmp(Name, "AngleKi") == 0)	//滑块名称为AngleKi
                        {
                            AnglePID.Ki = atof(Value);		//把滑块值赋给角度环Ki
                        }
                        else if (strcmp(Name, "AngleKd") == 0)	//滑块名称为AngleKd
                        {
                            AnglePID.Kd = atof(Value);		//把滑块值赋给角度环Kd
                        }
                        else if (strcmp(Name, "G") == 0)	//滑块名称为G：角度零点偏置
                        {
                            G = atof(Value);		//把滑块值赋给角度零点偏置
                        }
                        else if (strcmp(Name, "SpeedKp") == 0)		//滑块名称为SpeedKp
                        {
                            SpeedPID.Kp = atof(Value);				//把滑块值赋给速度环Kp
                        }
                        else if (strcmp(Name, "SpeedKi") == 0)		//滑块名称为SpeedKi
                        {
                            SpeedPID.Ki = atof(Value);				//把滑块值赋给速度环Ki
                        }
                        else if (strcmp(Name, "SpeedKd") == 0)		//滑块名称为SpeedKd
                        {
                            SpeedPID.Kd = atof(Value);				//把滑块值赋给速度环Kd
                        }
                        else if (strcmp(Name, "TurnKp") == 0)		//滑块名称为TurnKp
                        {
                            TurnPID.Kp = atof(Value);				//把滑块值赋给转向环Kp
                        }
                        else if (strcmp(Name, "TurnKi") == 0)		//滑块名称为TurnKi
                        {
                            TurnPID.Ki = atof(Value);				//把滑块值赋给转向环Ki
                        }
                        else if (strcmp(Name, "TurnKd") == 0)		//滑块名称为TurnKd
                        {
                            TurnPID.Kd = atof(Value);				//把滑块值赋给转向环Kd
                        }

                    }
                    else if (strcmp(Tag, "joystick") == 0)		//[joystick,LH,LV,RH,RV]：摇杆帧
                    {
                        int8_t LH = atoi(strtok(NULL, ","));		//取第2段，作为摇杆值LH
                        int8_t LV = atoi(strtok(NULL, ","));		//取第3段，作为摇杆值LV
                        int8_t RH = atoi(strtok(NULL, ","));		//取第4段，作为摇杆值RH
                        int8_t RV = atoi(strtok(NULL, ","));		//取第5段，作为摇杆值RV

                        /*执行摇杆操作*/
                        /* 摇杆回中死区：消除 ±5 以内的零漂 */
                        if (LV > -5 && LV < 5) { LV = 0; }
                        if (!TrackMode) SpeedPID.Target = LV / 50.0;   /* 循迹时前进速度由 TRACK_SPEED 在 50ms 层给 */

                        /* 循迹模式下摇杆的左右方向不再插手：
                         *   循迹正用 TurnPID.Target 控制方向，摇杆一打杆就把它的结果盖掉，
                         *   等于两个操作员抢同一个量。所以只在非循迹时才接受 RH。 */
                        if (!TrackMode)
                        {
                            if (RH > -5 && RH < 5) { RH = 0; }
                            TurnPID.Target = -RH / 50.0;   //RH>0=右转，故 Target 取负
                            if (TurnPID.Target != 0.0f && LV == 0)
                                SpeedPID.Target = 0.20f;  /* 只转向不给速度时，补一点前进速度，否则原地打转 */
                        }

                    }
                }

                BlueSerial_RxFlag[i] = 0;				//处理完成后标志位清0，以便接收下一帧数据
            }
        }

        /* ---------- 上位机波形输出（当前两条都关闭）----------
         * 两条路都走 huart3(蓝牙)，载荷差一个数量级：
         *   [plot,GZ,Yaw]    每轮约 19 字节，只有姿态，轻，适合长时间盯着看
         *   CCD_SendFrame()  每帧 270 字节（'*LD' + 264 hex + '00' + '#'），
         *                    带 128 点原始波形，重，只在看 CCD 时用
         *
         * ★ 为什么两条都注释掉了：CCD 采集和三个控制环全在 TIM3 中断里，
         *   节拍由硬件定时器保证，所以"发得慢"不会影响车的控制，只影响
         *   OLED 刷新和蓝牙指令的响应速度。但慢到一定程度就不好用了：
         *     USART3 现在是 9600 波特，270 字节要 281ms，主循环从 ~45ms
         *     直接涨到 ~326ms —— 而 CCD 40ms 就出一帧，等于 8 帧丢掉 7 帧，
         *     OLED 也会肉眼可见地卡。
         *   19 字节的 [plot] 只要 ~20ms，但和 OLED_Update() 的 ~23ms 叠加后
         *   主循环已经到 ~44.6ms，再叠其它就更慢了。
         *   想看密波形，唯一实用的办法是把 USART3 提到 115200
         *   （270 字节 = 23.4ms），同时把蓝牙模块也改成 115200，否则链路直接断。
         *
         * ★ CCD_SendFrame() 只回读最近一次采集的结果(ccd.c:301-319)，不触发
         *   新的采样。所以打开后上位机看到的波形、阈值线、丢线标志与 OLED 是
         *   同一帧，两者对得上。
         *
         * 要用哪一条就去掉对应那几行的注释；两条不要同时开，载荷会翻倍。 */
//        len = sprintf(display_buf, "[plot,%d,%.2f]",GZ,Yaw);//TurnPID.Target,DifSpeed,DifPWM,%d
//        HAL_UART_Transmit(&huart3, (uint8_t *)display_buf, (uint16_t)len, 100);

//      CCD_SendFrame();        /* 270 字节: '*LD' + 264 hex + '00' + '#' */
    }

    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */

  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};
  RCC_PeriphCLKInitTypeDef PeriphClkInit = {0};

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_ON;
  RCC_OscInitStruct.HSEPredivValue = RCC_HSE_PREDIV_DIV1;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
  RCC_OscInitStruct.PLL.PLLMUL = RCC_PLL_MUL9;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_2) != HAL_OK)
  {
    Error_Handler();
  }
  /* ADC 时钟：PCLK2=72MHz 经 6 分频 = 12MHz（ADC 上限 14MHz）
   * 采样时间 1.5 周期 + 转换 12.5 周期 = 14 周期 ≈ 1.17us/次
   * 这套配置是给 CCD 线阵（TSL1401 的 AO 输出）用的 */
  PeriphClkInit.PeriphClockSelection = RCC_PERIPHCLK_ADC;
  PeriphClkInit.AdcClockSelection = RCC_ADCPCLK2_DIV6;
  if (HAL_RCCEx_PeriphCLKConfig(&PeriphClkInit) != HAL_OK)
  {
    Error_Handler();
  }
}

/* USER CODE BEGIN 4 */

/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
    /* User can add his own implementation to report the HAL error return state */
    __disable_irq();

    while (1)
    {
    }

  /* USER CODE END Error_Handler_Debug */
}
#ifdef USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
    /* User can add his own implementation to report the file name and line number,
       ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */

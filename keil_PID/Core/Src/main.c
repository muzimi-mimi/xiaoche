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
 *                    两轮自平衡小车  主控程序结构说明
 * ==========================================================================
 *
 * 硬件：STM32F103C8T6 @72MHz / MPU6050(软件 I2C: PB3,PB4) / TB6612 + 双电机
 *       OLED(软件 I2C: PB8,PB9) / USART3 蓝牙(9600) / CCD 循迹(ADC1_IN4) / PA5 按键
 *
 * 时基：全工程只有一个定时器中断 —— TIM3，入口 HAL_TIM_PeriodElapsedCallback()
 *
 *      TIM3  每 1 拍 hcount++，拍末按 CCD_Div 分频采一帧 CCD
 *      10ms  读 MPU6050 -> 姿态融合 -> 偏航积分 -> 直立环 / 起立环
 *      50ms  读编码器 -> 算速度 -> 速度环 + 转向环
 *
 *  TIM3 定时 10ms（tim.c: 预分频 72-1，Period = 10000-1）
 *      中断里的分频计数用 TICK_10MS / TICK_50MS 表示，改 TIM3 周期要同步改它们
 *      为什么用 10ms 而不是 1ms：get_CCD() 一帧约 0.7ms，1ms 拍会被它吃掉 70% 的
 *      时间余量，容易和中断撞车；拉长到 10ms 后每拍的 CCD 开销只占 7%
 *
 * 控制结构（串级 + 并联合成）：
 *
 *      速度环(50ms) -> AnglePID.Target（目标倾角）
 *                                -> 直立环(10ms) -> AvePWM
 *      转向环(50ms) -> TurnPID.Out + TURN_FF*Target -> DifPWM
 *                                -> LeftPWM  = AvePWM + DifPWM/2
 *                                   RightPWM = AvePWM - DifPWM/2
 *
 * 车的状态用 CarState 表示，上电 / 摔车 / 停车都回到 ST_IDLE。
 * 主循环(while(1)) 只做慢活：刷 OLED、跑串口协议、响应 PA5 按键。
 * 实时控制与 CCD 采集全部放在 TIM3 中断里 —— OLED_Update() 一次刷 1024 字节
 * 约 23ms，蓝牙 9600 波特发一帧约 21ms，最坏一圈主循环约 44.6ms，
 * 任何放进主循环的活都必须能容忍几十毫秒的延迟。
 * ========================================================================== */

/* ===== 运行状态（上电默认 ST_IDLE，由按键或蓝牙指令驱动）=====
 *
 *   ST_IDLE     上电默认；整车断电，每 10ms 也写一次 PWM=0
 *   ST_ERECT    起立中：甩轮把车甩进平衡窗，最长 ERECT_TIMEOUT_MS(3s)
 *   ST_BALANCE  正常直立行驶：直立环 + 速度环 + 转向环 全开
 *
 * 迁移路径：
 *   ST_IDLE    --按键 / 收到 "1"------> StartErect() ----> ST_ERECT
 *   ST_ERECT   --|Angle| <= ERECT_DONE_ANG-------------> ST_BALANCE
 *   ST_ERECT   --超过 ERECT_TIMEOUT_MS(3s)-------------> StopCar() -> ST_IDLE
 *   ST_ERECT   --按键(放弃起立，ErectTime>=300ms)------> StopCar() -> ST_IDLE
 *   ST_BALANCE --|Angle| > ERECT_START_ANG-------------> StopCar() -> ST_IDLE
 *
 * CarState 在主循环和 TIM3 中断里都会被写（起立完成、摔车都在中断里判定），
 * 所以声明成 volatile uint8_t；单字节读写的原子性由 Cortex-M3 保证，不需要加锁。
 * ========================================================================== */
#define ST_IDLE     0u
#define ST_ERECT    1u
#define ST_BALANCE  2u
volatile uint8_t CarState = ST_IDLE;

/* ===== 时钟基准：TIM3 中断周期 x 分频计数 = 实际周期 =====
 *  必须与 tim.c 里 TIM3 的 Period 保持一致，否则"多少拍一次"全是错的。
 *  两个环都按"10ms 的整数倍"推理，改 TIM3 时这里要同步：
 *     TIM3 = 1ms  (Period = 1000-1)   ->  TICK_10MS = 10, TICK_50MS = 50
 *     TIM3 = 10ms (Period = 10000-1)  ->  TICK_10MS = 1,  TICK_50MS = 5   <- 当前
 *  10ms 一拍的理由：get_CCD() 一帧约 0.7ms，1ms 拍会被 CCD 吃掉 70% 的余量，
 *  容易与中断撞车，故拉长到 10ms 并把 CCD 放在拍末。 */
#define TICK_10MS   1
#define TICK_50MS   5

/* 编码器脉冲差值 -> 轮速(转/秒)：44 线 x 30 减速比，50ms 采样
 *   转/秒 = 脉冲数 / 44 / 0.05 / 30 = 脉冲数 x (1/66)
 * 原来写成 /44.0/0.05/30 是 double 三连除；折成一次 float 乘法，
 * 数值等价(1/66 的舍入远小于 1 个脉冲的分辨率)，省软浮点的来回换算。 */
#define ENC_TO_RPS  (1.0f / (44.0f * 0.05f * 30.0f))

static uint32_t hcount = 0, Count1 = 0;  /* TIM3 拍内分频计数(10ms/50ms 段用)，仅本文件可见 */

/* CCD 采样分频：每拍 +1，数到 CCD_Div 才采一帧
 * 实际周期 = CCD_Div x TIM3 周期(10ms)，与中断优先级无关。 */
static uint16_t CCD_count = 0;
static char display_buf[128];             /* 上位机 [plot] 帧组包缓冲，仅主循环用 */

/* 蓝牙接收的旧手写实现，已被 BlueSerial.c 取代，留作参考（勿清） */
//#define RX_BUF_SIZE  128
//char BlueSerial_RxPacket[RX_BUF_SIZE];   // 接收缓冲
//volatile uint8_t BlueSerial_RxFlag = 0;     // 帧接收标志位
//static uint8_t RxState = 0;                 // 状态机状态
//static uint16_t pRxPacket = 0;              // 当前写入位置


int16_t AX, AY, AZ, GX, GY, GZ;
volatile uint8_t TimerErrorFlag;
volatile uint16_t TimerCount;

float AngleAcc;
float AngleGyro;
float Angle;

/* ================== 偏航角 Yaw（Z 轴陀螺仪积分） ==================
 * 没有磁力计/编码器，只靠 Z 轴角速度积分，会随时间漂移（零偏误差）。
 *
 * 1) 标度 YAW_LSB_PER_DPS = 16.384
 *      GYRO_CONFIG = 0x18 -> ±2000°/s 档 -> 32768/2000 = 16.384 LSB/(°/s)
 * 2) dt 固定 0.01f，不读 HAL_GetTick()
 *      这个回调本身就由 10ms 定时器触发，用 ms 差值反而引入抖动
 * 3) 全程 float 不用 double：Cortex-M3 无 FPU，double 走软浮点，
 *      慢 5 倍还会多占栈
 *
 * YAW_BIAS_DPS 是 Z 轴零偏标定值：静止 30s 取所有 GZ 的平均值 / 16.384。
 *      标定值 41.20 LSB / 16.384 = 2.51 °/s
 *      采用值 39.45 LSB / 16.384 = 2.41 °/s   <- 采用值
 *   残差约 1.67 LSB(约 0.10 °/s)。每次上电陀螺仪状态都不一样，
 *   没有一劳永逸的准确值，只能在已知静止时重新标定。
 *   残差 0.10 °/s 意味着约 6 °/min 的慢慢漂移。
 *
 * YAW_DEADZONE_DPS 是死区，用来压住静止时的残差漂移：
 *   实测约 -0.102 °/s 时漂移 -6.1 °/min，加 0.5 °/s 死区后压到 0.18 °/min，
 *   相当于 34 倍。但死区也会吃掉真实的微小转动(|w|<0.5°/s)，
 *   一次 90° 回转会丢 0.03~0.98°，转速越慢丢得越多；这个损失可以接受。
 * ========================================================================== */
#define YAW_LSB_PER_DPS   16.384f   /* ±2000°/s 档位：32768/2000 = 16.384 */
#define GYRO_LSB_PER_DPS  YAW_LSB_PER_DPS  /* 与上面共用同一个档位(±2000°/s)，GX/GZ 都可以用 */
#define YAW_BIAS_DPS      2.41f     /* Z 轴零偏(°/s)：静止实测 GZ 均值 39.45 LSB / 16.384 */
#define YAW_DEADZONE_DPS  1.5f      /* 偏航死区(°/s)：压掉静止时的零偏漂移 */
#define YAW_DT            0.01f     /* 积分步长(s)：每 10ms 一拍 */
#define YAW_WRAP          1         /* 1=归一到 ±180°；0=不归一、连续累加 */
float Yaw = 0.0f;                   /* 偏航角(度)：左转为正、右转为负 */
float YawRate = 0.0f;               /* 偏航角速度(°/s)：由 GZ 去零偏得到 */
int16_t LeftPWM, RightPWM;			// 左 PWM、右 PWM
int16_t AvePWM, DifPWM;				// 平衡 PWM、差速 PWM
float DifSpeedFilter = 0.0f;		// 转向角速度的一阶低通滤波值，抑制编码器量化噪声
float TurnTargetCmd  = 0.0f;		// 转向目标命令值：摇杆/循迹/直角各支路都写这里（期望值）
float TurnTargetRamp = 0.0f;		// 转向目标斜坡值：每 50ms 向 Cmd 限速逼近，实际喂给 TurnPID.Target
#define TURN_FF  18.0f						/* 转向前馈系数：目标转速直接乘它得到 DifPWM 的前馈量
                             * 没有前馈时 |TurnPID.Out| 很小时差速不够，转向环会"粘住"
                             * 历史：20 -> 10 是在 TURN_FB_SIGN 极性还反着的年代打的补丁——
                             * 那时 P 项反向加倍输出，前馈再大就饱和打滑。2026-10-25 极性修正后
                             * P 项回归阻尼，纯前馈 10 只能建立约 0.6 转/秒差速(实测标定
                             * 1 PWM ≈ 0.05 转/秒)，转弯比修正前明显慢，故 10 -> 18：
                             * 转弯时 FF 18 + 起步 P 项约 24，接近旧极性下 22 的实际驱动力。
                             * 偏肉加到 20，打滑/甩尾退到 15。 */
#define TURN_SLEW  0.2f						/* 转向目标每 50ms 最大变化量：0->满打(1.0)约需 5 拍(250ms)，
                             * 消除 TurnPID.Target 阶跃导致的 DifPWM 0->±50 突变冲击 */
float SpeedTargetCmd  = 0.0f;		// 前进速度目标命令值(转/秒)：循迹那一支写这里
float SpeedTargetRamp = 0.0f;		// 斜坡后的前进速度：真正写进 SpeedPID.Target
#define SPEED_SLEW  0.1f					/* 前进速度目标每 50ms 最大变化量(转/秒)：0->TRACK_SPEED(0.5)
                             * 约 5 拍(250ms) 建立，反过来就是"减速到停"。
                             * 目的不是限功率，是不让 Target 在 0 和 0.5 之间硬跳：
                             * 硬跳那一拍误差瞬间变成 -0.5，把 SpeedPID 积分反向灌满，
                             * 车停稳后那份负积分得先倒干净才能再往前走 ——
                             * "停下来容易、再起步慢半拍"就是这么来的。 */
#define TRACK_SEEN_MIN  4					/* 可信区间内 >= 这么多个黑像素 = "线还在画面里"。
                                             * 实测正常线宽 16~30，所以 4 是很松的地板：只有真·空场才算丢。 */
#define TRACK_UNSEEN_MAX 5					/* 掉线迟滞：连续这么多帧黑点数 < TRACK_SEEN_MIN 才把
                                             * TrackLineSeen 拉 0(即速度目标归 0)。5 帧 x 20ms = 100ms，
                                             * 足够跨过单帧/双帧的阈值抖动；恢复不迟滞(1 帧即走)。 */
#define TURN_FB_SIGN  (-1)   /* 转向反馈符号：+1=不取反，-1=取反；接线/装配拧反时用
                              * 判据（很关键）：同一条通路是
                              *   Target -> DifPWM -> LeftPWM/RightPWM -> 实际转向 -> DifSpeed
                              * 要保证 Target 变大时 DifSpeed 也同向变大，否则转向环会正反馈、越转越偏。
                              * 2026-10-25 串口实测翻案：直角右转 Target=-1.0 时 DifSpeed=+1.1、
                              * 左转 Target=+1.0 时 DifSpeed=-0.9，而 Yaw 证实车确实按目标方向在转
                              * —— 反馈极性一直是反的，P 项在反向加倍输出(转向卡顿/画龙的根源)。
                              * 原注释"joystick 能正常转向就说明极性对"是误判：前馈 TURN_FF 主导方向，
                              * 极性反了车照样转，只是 P 项从阻尼变成了助燃。 */

/* ---------- CCD 循迹：只改转向目标 ----------
 * 约定：TurnPID.Target < 0 = 右转（与 joystick 那一支完全一致）。
 *   CCD_Zhongzhi > TRACK_CENTER -> 中线偏右 -> Target 取对应的负值
 *
 * 默认 TrackMode = 0，上电就是只认摇杆的模式。
 * 蓝牙发裸字节 'T'/'t'，或按 PA5 按键走到第②段，都会切换循迹。
 *
 * 为什么循迹不直接改 PWM 而只改"转向目标"：
 *   循迹复用摇杆已经在用的整条转向通路（Target -> TurnPID -> TURN_FF 前馈），
 *   这样只需要调一个"偏差 -> 转向"的映射，不用再维护第二套转向 PID。 */
#define TRACK_DIR      (-1)     /* 循迹方向：CCD 的 index 增大 = 车的右侧时取 -1；装反了取 +1
                                 * 判据：把线放传感器左半边，OLED 上 TRK 应显示负值；
                                 *       若显示正值说明符号反了，会正反馈打死方向 */
#define TRACK_GAIN     1.2f     /* 偏差(满 63 像素)对应的转向目标：1.2 转/秒
                                 *   TURN_FF=18 时满偏前馈 18x1.2=21.6，加 TurnPID 限幅 30 共 51.6，
                                 *   会顶到 ±50 的 DifPWM 限幅 —— 即最大偏差下差速给满，急弯更有力；
                                 *   直道/缓弯远到不了满偏，不受影响 */
#define TRACK_DEAD     2        /* 死区(像素)：压住 CCD_Zhongzhi 的 ±1 抖动，1 像素误差只产生 0.25 PWM */
#define TRACK_KD       3        /* 超前转向系数：偏差变化量乘它叠进偏差里，等效提前 2 帧(40ms)转向；
                                 *   0 = 关掉超前，退回纯比例循迹 */
#define TRACK_LEAD_MAX 12       /* 超前量限幅(像素)：封住中线量化抖动灌进 dErr 的噪声上限 */
#define TRACK_LOST_MAX 50       /* 连续丢线多少帧才放弃：25 帧 x 20ms(CCD_Div=2) = 0.5s
                                   （原 40ms 曝光时是 1s；嫌放弃太快就按比例往上调） */
#define TRACK_SPEED    0.5f    /* 循迹前进速度（转/秒），直接写 SpeedPID.Target
                                 *   摇杆那一支只在 !TrackMode 时才写 SpeedPID.Target，
                                 *   循迹模式下没有速度输入，目标值由这里统一给
                                 * 0.08 太慢：编码器 44 线、30 减速比、50ms 采样，
                                 *   1 个脉冲 = 0.0152 转/秒；AveSpeed 又要左右取平均，
                                 *   0.08 时每 50ms 只有 5.3 个脉冲(误差 9.4%)，抖动很明显。
                                 * 0.12 对应约 24mm/s（轮径 65mm -> 周长 204mm） */
#define TRACK_CENTER   56       /* 循迹中心：CCD_Zhongzhi 的目标值
                                 * 为什么不用 63.5（128 像素的几何中心）：
                                 *   镜头/传感器装配有固定偏置，实测中心落在 45~68 之间，取中值 56，
                                 *   偏 7 像素(纸面约 6mm)。用 56 可以把这个装配偏置直接吃掉。
                                 * 标定：把车放正对准直线，看 OLED 上的 CCD_Zhongzhi，取平均值填这里。 */
/* ---------- 直角转弯：转到 CCD 重新抓到线为止 ----------
 *
 * 直角是唯一需要转 90 度的弯。直角处黑区会明显变宽：
 *   线宽 w = w0 / cos(theta)，theta 越大越宽，接近 90 度时整幅都可能变黑。
 *   所以判据不是"中线偏了多少"，而是"两侧一边有过沿、且黑点数明显多于直道"。
 *
 * 转弯仍然写 TurnPID.Target，走已经调好的转向环，而不是直接给 PWM。
 * 2026-10-25 起不再按 Yaw 硬转固定角度：PIVOT 一直转，转到 CCD 抓到合法
 * 细线(连续 PIVOT_LINE_FRAMES 帧 !CCD_Lost)就立刻回循迹 —— 转多少度由
 * "看到新线"决定。Yaw 只剩两个职责：转过 PIVOT_MIN_DEG 之前不信 CCD
 * (起转时旧线/黑区还糊在画面里，CCD_Lost 本来就是 0，立刻信它会原地退出)，
 * 以及 OLED 上显示累计转角。转不到线也有 PIVOT_TIMEOUT_MS 保底。
 *
 * 两种状态：
 *   CORNER_LINE   正常循迹，顺便每帧判是不是直角
 *   CORNER_PIVOT  定速旋转，等 CCD 抓到新线（或超时保底）
 */
#define CCD_EDGE_LO        5        /* 低端边沿区起点(像素 5..12)：与阈值统计区间一致，避开两端坏点区 */
#define CCD_EDGE_HI        115      /* 高端边沿区起点(像素 115..122) */
#define EDGE_ZONE_N        8        /* 每端参与表决的像素数 */
#define EDGE_ZONE_DARK     5        /* 端区内 >= 这么多像素低于阈值才判"该端压黑"(8 取 5 的严格多数) */
#define CORNER_MIN_DARK    40       /* 判直角要求的最少黑点数：太少说明只是噪点或离线，不是宽黑区 */
#define CORNER_CONFIRM     2        /* 连续满足几帧才算真直角（2 帧 = 40ms，滤掉单帧噪声） */
#define T_MIN_DARK         100      /* 判 T 字路口的黑点数：可信区间一共 118 点，要 100 点发黑
                                     * 才算"横贯整幅的横线"，而不是普通直角那种只糊掉一侧的宽黑区。
                                     * 实跑偏松/偏紧就调这个数：误把直角当 T 就调大，T 认不出就调小。 */
#define T_CONFIRM          2        /* 连续几帧满足才认 T（2 帧 = 40ms） */
#define PIVOT_RATE         0.6f     /* 转弯时写进 TurnPID.Target 的转速
                                     *   1.5(=540°/s) 是实测打滑极限(~0.9 转/秒差速)的 2~3 倍：
                                     *   2026-10-27 面对T字路口的抽搐日志里，命令恒 1.5 持续 3 秒，
                                     *   实测差速只在 +0.89 ~ -0.50 之间乱摆(粘滑极限环)，
                                     *   Yaw 净位移仅 ~20°，直到 PIVOT_TIMEOUT 超时。取 0.6
                                     *   (≈216°/s，转 85° 约 0.4s) 留 1/3 附着余量。
                                     *   配 TURN_FF=18 前馈约 10.8，其余靠转向环补。 */
#define PIVOT_MIN_DEG     45.0f    /* 最小转角门槛(度)：转过这么多才开始信 CCD 的"抓到线"。
                                     * 不是硬停角 —— 停不停由 CCD 说了算，这里只是防起转瞬间
                                     * 旧线/直角黑区还没出画面就被 CCD_Lost==0 骗回去。 */
#define PIVOT_LINE_FRAMES 2        /* 连续几帧抓到合法细线才退出 PIVOT（2 帧 = 40ms） */
#define PIVOT_TIMEOUT_MS   3000     /* 转弯超时：转了 3 秒还没等到线(打滑/卡住/丢线)就保底回循迹 */
#define PIVOT_ADVANCE_MS   0        /* 开始累计 Yaw 之前先空走多少 ms
                                     *
                                     * 为什么要留这段：CCD 装在车头前方约 L 厘米处，原地旋转时传感器的轨迹
                                     * 是半径 L 的圆。要等这一段走完，转过的角度才对应车体真正的 90 度。
                                     * 停转后再走约 L 厘米，靠循迹环把车拉回线上，L 越小弯心越靠近车体、越跟得住。
                                     *
                                     * 估算：TRACK_SPEED=0.12 转/秒 x 204mm 周长 = 24mm/s，
                                     *       1 厘米约 420ms，所以填 L(厘米) x 420 毫秒。
                                     * 标定：量出车轴中心到 CCD 镜头的距离 L。
                                     * 默认 0：不空走，进入 PIVOT 立刻开始累计，最省事。 */
/* ---- 直角转向极性：压黑的那一端 -> 往哪边转 ----
 *
 * CornerDir 的原始来源只是"哪一端发黑"：eR=1(高 index 端) 记 +1，否则 -1，
 * 再乘这个系数。所以本宏唯一的职责是：把"图像里的压黑端"翻成"车该往哪边转"。
 *
 * 为什么必须单独留一个宏：eR 只是"图像高 index 端"，它到底是车的左还是右，
 * 取决于线阵/镜头的装配方向，代码本身推不出来，只能靠实测。
 * 直线循迹的 TRACK_DIR 已经把"图像右 = 车右"钉死过一次，所以理论上
 * 压黑端就是转弯方向(本宏 = +1)。当前填 -1，因为实测直角方向是反的。
 *
 * 判断该改哪一处(别两个都翻，两个都翻等于没改)：
 *   直线循迹正常、只有直角反  -> 翻本宏(+1 / -1 之间换一个数)
 *   直线循迹也在往一边跑      -> 真凶是 TRACK_DIR，本宏保持 -1 不动
 *
 * 20 秒静态判据(不用跑车)：拿纸片遮住传感器"车左侧"那一端，
 *   看 OLED 波形下陷出现在左半边还是右半边，就能定死 index 的方向。
 */
#define CORNER_SIDE_SIGN   (+1)     /* +1 = 压黑端就是转弯方向；-1 = 取反(当前实测) */

/* ---- 转弯时的前进速度：让车"一边转一边往前走"，不停在直角点上 -------------
 *
 * 直角转弯要同时管两件事：转多久(等 CCD 抓到新线)、以及转的时候还往前走多快。
 * 转弯期间 SpeedPID.Target 由本宏给，不再是 0 —— 这就是"保持前进"的落点。
 *
 * 决定"看起来是转弯还是原地打转"的是转弯半径：
 *     R = v / w
 *     v = 本宏(转/秒) x 轮周长(204mm)      [mm/s]
 *     w = PIVOT_RATE                         [rad/s]
 *     转过 90 度期间前进的距离 = R x pi/2
 *
 * 按现在的 PIVOT_RATE=3.0、TRACK_SPEED=0.12 算：
 *     v=24.5mm/s   R=8mm   转完 0.52s   期间只前进 13mm
 * 也就是"前进"是有的，但 13mm 肉眼看不出，车看起来像在原地打转。
 * 想看到明显弧线，只能抬本宏或降 PIVOT_RATE：
 *
 *     本宏    v(mm/s)  R(mm)  90度前进   90度耗时
 *     0.12     24.5      8      13mm     0.52s   <- 现在，接近原地
 *     0.20     40.8     14      21mm     0.52s
 *     0.30     61.2     20      32mm     0.52s
 *     0.20*    40.8     27      43mm     1.05s   <- *同时把 PIVOT_RATE 降到 1.5
 *
 * 选值：直角是"贴着拐点转"，半径比线宽大一点就够(20~30mm)。
 * 半径大到能画出弧线时，车会切内角、转完偏到线外，反而更难循迹。
 * 所以先只调本宏(不改转弯角度，风险最小)，不够再动 PIVOT_RATE(会拉长 90 度的时间)。
 *
 * 默认 = TRACK_SPEED：与加这个宏之前的行为逐字节一致，方便先对照跑一次。
 */
#define CORNER_SPEED   0.2f    /* 转弯期间前进速度(转/秒)。不要跟 TRACK_SPEED 走：
                                 * TRACK_SPEED 涨到 0.5 后，"0.5 前进 + 大差速"的合成侧向
                                 * 附着需求轮胎给不了，轮子直接进入打滑(见 PIVOT_RATE 注释里
                                 * 2026-10-27 的抽搐日志)。转弯时收油到 0.2，让轮子贴住地面。
                                 * 填 0 就是停在直角点，别填。 */

#define CORNER_LINE        0u       /* 平时循迹 */
#define CORNER_PIVOT       1u       /* 转弯中：定速旋转，等 CCD 抓到新线（或超时保底） */

volatile uint8_t TrackMode    = 0;  /* 0 = 摇杆转向，1 = CCD 循迹；'T'/'t' 或 PA5 按键切换 */
volatile uint8_t TrackLostCnt = 0;  /* 连续丢线帧数 */
volatile uint8_t TrackLineSeen = 0; /* 存在性：本帧画面里有没有黑线（与中线几何是否有效无关） */
static uint8_t TrackUnseenCnt = 0; /* 连续没线的帧数：给 TrackLineSeen 做掉线迟滞 */
static int16_t TrackErrPrev = 0;    /* 上一帧(去死区后)的中线偏差，用于算偏差变化率做超前转向 */

volatile uint8_t CornerState = CORNER_LINE;
volatile int8_t  CornerDir   = 0;   /* 本次直角的转向：+1 = 右转，-1 = 左转
                                     * 注意这是"转向"符号，不是"图像哪端发黑"：
                                     * Target = TRACK_DIR x CornerDir x PIVOT_RATE，
                                     * TRACK_DIR = -1，所以 +1 -> Target<0 -> 右转
                                     * 与 TurnPID / 循迹的符号约定完全一致 */
volatile float   YawTurned   = 0.0f;/* 本次转角累计值(度)，进入 PIVOT 时清零 */
float    YawPrev     = 0.0f;        /* 上一拍的 Yaw，用来算增量 */
uint16_t PivotTicks  = 0;           /* 转弯计时(ms) */
uint8_t  CornerSeen  = 0;           /* 连续满足直角条件的帧数 */
uint8_t  TSeen       = 0;           /* 连续满足 T 字路口条件的帧数 */
uint8_t  PivotOk     = 0;           /* PIVOT 中连续抓到线的帧数（CCD 接管转弯的判据） */

/* ---------- 自起立(Self-Erect)参数 ---------- */
#define ERECT_PWM        100		/* 甩轮 PWM(0~100)：太大车轮打滑，太小甩不起来 */
#define ERECT_START_ANG  55.0f	/* 平衡中断阈值：|Angle| 超过它就判定摔倒，直接停车 */
#define ERECT_DONE_ANG   30.0f	/* 前倾起立：|Angle| 收到这个角度内就切平衡环 */
#define ERECT_DONE_ANG_BACK 45.0f	/* 后仰起立：抬到 45 度左右就切平衡环，防止冲过头 */
#define ERECT_TIMEOUT_MS 3000	/* 甩轮超时：3 秒还没起来就停车（电池太弱 / 卡住） */
#define ERECT_ABORT_GUARD_MS 300	/* 起立中按键生效门槛(ms)：ErectTime 到了才允许"放弃起立" */
uint16_t ErectTime = 0;			/* 本次 ERECT 已经跑了多少 ms，每 10ms 加一次；也用于 LED 闪烁 */
#define ERECT_DIR        (1)		/* 甩轮方向：1 = 与平衡环同号(默认)，-1 = 取反(原地转圈/磨胎时用) */
#define ERECT_PULSE_MS   400			/* 脉冲模式：每个周期通电多少 ms；0 = 连续通电(一直甩) */
#define ERECT_PERIOD_MS  500		/* 脉冲周期(ms)：通电 400ms + 断开 100ms */
float LeftSpeed, RightSpeed;		/* 左/右轮速度（转/秒） */
float AveSpeed, DifSpeed;			/* 平均速度、差速 */

float G = 0.00;						/* 角度计安装角的标定偏置(度)：补偿车身机械安装倾斜，可用蓝牙 slider G 在线改 */

/* ================== 电池电压检测 ==================
 * 硬件：电池 +12V 经 10k(上)/2.7k(下) 分压接 PA7 (ADC1_IN7)，
 *   分压比 (10+2.7)/2.7 = 4.704：12.6V(3S 满) -> 2.68V，都在 3.3V 量程内。
 * 软件上 ADC1 与 CCD 共用：CCD 在 TIM3 中断里采 IN4(每 CCD_Div 拍一帧)，
 *   这里在主循环采 IN7。两处都靠 HAL_ADC_ConfigChannel 切通道，并发访问会
 *   互相踩（中断把通道切走 -> CCD 帧里混进电池电压，或电池采到半截 CCD 值），
 *   所以采样全程关掉 TIM3 更新中断(约 0.3ms，控制节拍最多推迟这一点点)，
 *   采完把通道配回 IN4 + 1.5 周期采样，恢复 CCD 的原工作状态。 */
#define BAT_ADC_CH        ADC_CHANNEL_7
#define BAT_DIV_RATIO     4.7037f   /* (10+2.7)/2.7 分压比 */
#define BAT_LOW_V         10.5f     /* 3S 亏电警戒线(V)：低于它屏上电压前缀显示 '!' */
#define BAT_SAMPLE_MS     500u      /* 多久采一轮(ms)：电压变化慢，500ms 足够 */
float BatVoltage = 0.0f;            /* 电池电压(V)：8 次平均 + IIR 平滑后的显示值 */

static float Bat_ReadVoltage(void)
{
    ADC_ChannelConfTypeDef sConfig = {0};
    uint32_t sum = 0;
    int k;

    __HAL_TIM_DISABLE_IT(&htim3, TIM_IT_UPDATE);   /* 与 CCD 的采集中互斥(见上方注释) */

    sConfig.Channel = BAT_ADC_CH;
    sConfig.Rank = ADC_REGULAR_RANK_1;
    sConfig.SamplingTime = ADC_SAMPLETIME_239CYCLES_5;   /* 分压源阻抗约 2.1k，用最长采样时间换精度 */
    HAL_ADC_ConfigChannel(&hadc1, &sConfig);

    for (k = 0; k < 8; k++)
    {
        HAL_ADC_Start(&hadc1);
        HAL_ADC_PollForConversion(&hadc1, 2);
        sum += HAL_ADC_GetValue(&hadc1);
    }

    /* 配回 CCD 用的 IN4 + 1.5 周期(与 MX_ADC1_Init 完全一致)，否则下一帧 CCD 采的是电池 */
    sConfig.Channel = ADC_CHANNEL_4;
    sConfig.SamplingTime = ADC_SAMPLETIME_1CYCLE_5;
    HAL_ADC_ConfigChannel(&hadc1, &sConfig);

    __HAL_TIM_ENABLE_IT(&htim3, TIM_IT_UPDATE);   /* 不清 UIF：窗口内撞上的那一拍照常补跑，只晚 0.3ms */

    return (float)sum / 8.0f * 3.3f / 4095.0f * BAT_DIV_RATIO;
}

/* ---------- 三个 PID 的结构体：定义时直接给成员赋初值 ----------
 * 注意 PID_Update() 的两个行为（见 pid.c）：
 *   1) Ki==0 时积分项被强制清零
 *   2) 微分项用的是 (Actual - Actual1)，不是 (Error - Error1)，
 *      所以 Target 突变不会产生微分冲击 */
PID_t AnglePID =  					// 角度环：输入 Angle，输出 AvePWM（直立控制）
{
    .Kp = 16.9,						// 比例系数
    .Ki = 0.06,						// 积分系数
    .Kd = 30.4,						// 微分系数

    .OutMax = 80,					// 输出限幅 -> 最大 PWM 80
    .OutMin = -80,					// 输出限幅
	
	.OutOffset = 0,					// 输出偏置：抵消 Out 正负不对称造成的静态偏差
	
	.ErrorIntMax = 600,				// 积分限幅
	.ErrorIntMin = -600,			// 积分限幅

};
PID_t SpeedPID =  					// 速度环：输入 AveSpeed(转/秒)，输出 AnglePID.Target(目标倾角)
{
    .Kp = 2.7,						// 比例系数
    .Ki = 0.21,						// 积分系数
    .Kd = 0,						// 微分系数

    .OutMax = 2,					// 输出限幅 5 度：太大车会大幅前后倾，5 度约合 10 个脉冲
    .OutMin = -3,					
	
	.ErrorIntMax = 10,				// 积分限幅
	.ErrorIntMin = -15,			// 积分限幅

};
PID_t TurnPID =  					// 转向环：输入差速，输出 DifPWM
{
    .Kp = 5.9,						// 比例系数
    .Ki = 0,						// Ki=0 -> 无积分，避免转向积分饱和
    .Kd = 0,						// 微分系数

    .OutMax = 30,					// 输出限幅
    .OutMin = -30,					
	
	.ErrorIntMax = 20,				// 积分限幅
	.ErrorIntMin = -20,				// 积分限幅

};

/* ==========================================================================
 * PID 状态复位 / 角度重新对准
 *
 * PID_ResetAll()：把三个 PID 的 Target / Out / 积分 / 上次误差全部清掉，
 *   并用"当前实测值"预置，防止微分项在复位瞬间产生巨大冲击。
 *   摔车(StopCar)、急停("0")、起立超时 都会经过 StopCar()，最终走到这里。
 *   只在有复位动作时调用，不必每个节拍都判断，也不影响响应速度。
 *
 * Angle_Realign()：用加速度计把角度重新对准一次（只在静止时有效）
 *   互补滤波的 Alpha=0.001，时间常数约 10s，摔车后靠它自己纠回来太慢；
 *   所以启动和起立前各调一次，取 300ms 的加速度计角度平均值。
 *
 *   期间要执行 30 次 HAL_Delay(10ms) = 300ms，这段时间只有主循环能跑，
 *   10ms 的 HAL_TIM_PeriodElapsedCallback 帮不上忙；
 *   顺手关掉 TIM3 中断，因为中断里也要读 MPU6050（同一个 I2C），
 *   并发访问会互相打断时序。只清 DIER 的 UIE 位，退出前恢复原状态，
 *   所以调用前是什么状态就恢复成什么状态。
 * ========================================================================== */
void PID_ResetAll(void)
{
    PID_Init(&AnglePID);
    PID_Init(&SpeedPID);
    PID_Init(&TurnPID);

    /* 预置"上次值"，防止微分项第一次就冲击 */
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
    TurnTargetCmd  = 0.0f;
    TurnTargetRamp = 0.0f;
    SpeedTargetCmd  = 0.0f;
    SpeedTargetRamp = 0.0f;
    TrackLineSeen   = 0;   /* 复位后先按"没看见线"处理，等第一帧 CCD 重新确认，避免起步先冲一段 */
    TrackUnseenCnt  = 0;   /* 掉线迟滞计数一并清零 */
    TrackErrPrev    = 0;   /* 偏差历史一并清零，免得重启循迹的第一帧算出一个假的变化率 */

    /* 直角转弯状态一并复位：摔车 / 急停 / 起立 都会经过这里。
     * 否则下次收到 "1" 时会带着上一轮的 PIVOT 状态上场，凭它转一个 90 度。 */
    CornerState    = CORNER_LINE;
    CornerDir      = 0;
    CornerSeen     = 0;
    TSeen          = 0;
    YawTurned      = 0.0f;
    PivotTicks     = 0;
    PivotOk        = 0;
}

void Angle_Realign(void)
{
    int32_t  sum = 0;
    int      k;
    uint32_t itWasOn;

    /* 这里必须关掉 TIM3 中断：中断里也要读 MPU6050(同一个 I2C)，
     * 并发访问会互相打断时序。只清 DIER 的 UIE 位，退出前按原状态恢复，
     * 所以对调用者完全透明。 */
    itWasOn = (htim3.Instance->DIER & TIM_IT_UPDATE) ? 1u : 0u;
    __HAL_TIM_DISABLE_IT(&htim3, TIM_IT_UPDATE);

    for (k = 0; k < 30; k++)              /* 30 x 10ms = 300ms */
    {
        MPU6050_GetData(&AX, &AY, &AZ, &GX, &GY, &GZ);
        sum += (int32_t)(-atan2f((float)AY, (float)AZ) * (180.0f / 3.14159265f));
        HAL_Delay(10);
    }

    Angle = (float)sum / 30.0f + G;       /* 取平均并叠加安装偏置 */

    if (itWasOn)
    {
        __HAL_TIM_CLEAR_IT(&htim3, TIM_IT_UPDATE);
        __HAL_TIM_ENABLE_IT(&htim3, TIM_IT_UPDATE);
    }
}

/* ==========================================================================
 * 状态迁移接口：StartErect() / StopCar()
 *   StartErect() 只负责启动流程，内部有 300ms 的角度对准阻塞
 *   StopCar()    可以在 10ms 中断里调用：关电机 + PID 复位 + GPIO 写 0，
 *                这几个动作都是安全可重入的
 *   CarState 是单字节，读写只需要保证"看不到中间状态"，不需要关中断
 * ========================================================================== */
void StopCar(void)
{
    CarState  = ST_IDLE;
    /* 停车 = 循迹一并关闭。
     * 不写这两句的话，摔车（平衡环里 |Angle| 超限）自动 StopCar 之后
     * TrackMode 仍然是 1，会留下两个后果：
     *   1) 主循环处理摇杆那两支被 if (!TrackMode) 挡住，车已经回到 IDLE，
     *      却既改不了前进速度也转不了向；
     *   2) 下次按键起立会带着循迹直接进 BALANCE，车一立起来就自己冲出去。 */
    TrackMode    = 0;
    TrackLostCnt = 0;
    ErectTime = 0;
    PID_ResetAll();               /* 摔车 / 急停 / 起立完成 都要把 PID 清到干净状态 */
    TB6612_setPWM(1, 0);          /* 停：PWM=0，IN1/IN2 同时为低 -> 电机自由停转 */
    TB6612_setPWM(2, 0);
}

void StartErect(void)
{
    if (CarState != ST_IDLE)
    {
        return;                   /* 已经在跑（或正在起立），直接丢掉重复的 "1" */
    }

    /* 先对准角度：加速度计在静止时才准，刚摔过或刚上电都需要十几秒才收敛，
     * 所以每次起立前先用 300ms 的一次性对准把起始角度摆正（这段只阻塞主循环）。 */
    Angle_Realign();

    PID_ResetAll();
    ErectTime = 0;

    CarState = ST_ERECT;          /* 状态最后切换，避免中断在 ERECT 里看到半初始化的数据 */
}

/* ==========================================================================
 * PA5 用户按键：EXTI5 下降沿 -> 启动 / 停止 切换
 *
 * 分工（关键）：
 *   中断回调 只置 KeyFlag 就返回，耗时 < 2us，不碰电机、不读 I2C。
 *   主循环   消费 KeyFlag，再调 StartErect() / StopCar()。
 *
 * 为什么不能在中断里直接调 StartErect()：
 *   它内部 Angle_Realign() 有 300ms 阻塞（读 MPU6050，期间关掉 TIM3 中断），
 *   放进 ISR 会让 10ms 平衡节拍停摆 300ms，正在直立行驶的车会当场倒下。
 *
 * 消抖：机械按键抖动 5~20ms，窗口内重复边沿只认第一次。
 *       EXTI5 优先级 0（与 TIM1/TIM3 同级），所以 ISR 越短越好。
 * ========================================================================== */
#define KEY_DEBOUNCE_MS   50      /* 按键软消抖窗口(ms) */

volatile uint8_t KeyFlag = 0;     /* 1 = 有一次有效按键；主循环消费后清零 */

void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin)
{
    static uint32_t KeyTick = 0;
    uint32_t now;

    if (GPIO_Pin != GPIO_PIN_5)
    {
        return;                   /* 本工程目前只有 PA5 走 EXTI */
    }

    now = HAL_GetTick();
    if ((uint32_t)(now - KeyTick) >= KEY_DEBOUNCE_MS)
    {
        KeyTick = now;
        KeyFlag = 1;
    }
}
/* 调试用：状态名缩写。仅被注释掉的 OLED 行引用，保留（勿清） */
static const char *StateStr(void)
{
    if (CarState == ST_BALANCE) return "BAL";
    if (CarState == ST_ERECT)   return "ERECT";
    return "IDLE";
}

/* ==========================================================================
 * ===== 实时控制三段式（都由 TIM3 回调分频调用，先后顺序即执行顺序）=====
 *
 *   Tick10_Attitude()   每 10ms：读 MPU6050 -> 姿态融合 -> 偏航积分
 *                              -> 偏航增量/转弯计时 -> 直立环或起立环 -> 写 PWM
 *   Tick50_SpeedTurn()  每 50ms：读编码器 -> 算速度 -> 速度环 + 转向环
 *   Ccd_Frame()         每 CCD_Div 拍(当前 20ms)：采一帧 CCD
 *                              -> 存在性/直角/T 判定 -> 写转向目标
 *   分发层在文件下方 HAL_TIM_PeriodElapsedCallback()，只做分频和调用
 *
 * 时间预算（一拍 = 10ms，最坏情况几段全撞上）：
 *   MPU6050 一次 I2C 突发读    ~150us
 *   姿态融合 + 偏航积分         ~70us（已全 float，见函数内注释）
 *   CCD 一帧                    ~700us（每 CCD_Div 拍才来一次）
 *   小计约 1.0ms = 10%，还有余量
 * ========================================================================== */
static void Tick10_Attitude(void)
{
        MPU6050_GetData(&AX, &AY, &AZ, &GX, &GY, &GZ);   /* 一次 I2C 突发读 14 字节，约 150us */
        /* 读取 X 轴零偏：+10 LSB 约 0.61°/s，用来补偿硬件的固有偏置 */
        GX += 10;

        /* 用加速度计算角度：atan2 出来的就是倾角，G 是机械安装补偿。
         * 用 atan2f 而不是 atan2：int 参数会被提升成 double 走软浮点，
         * M3 无 FPU 时慢约 5 倍；float 精度(约 7 位)对倾角绰绰有余。 */
        AngleAcc = -atan2f((float)AY, (float)AZ) * (180.0f / 3.14159265f) + G;

        /* 互补滤波 Alpha=0.001：
         *   加速度计长期准、短期噪声大（车体振动）
         *   陀螺仪短期准、长期漂
         *   时间常数 = 1/(Alpha*100Hz) = 10s，即 10s 内相信陀螺仪，10s 外拉回加速度计
         * 这里的 Gyro 分支是"用上一拍 Angle 减去角速度积分"的写法，
         *   dt 直接写 0.01，因为本回调就是 10ms 一拍。 */
        AngleGyro = Angle - (float)GX * (2000.0f * 0.01f / 32768.0f);   /* 常量折叠成一次 float 乘法 */
        float Alpha = 0.001f;
        Angle = Alpha * AngleAcc + (1 - Alpha) * AngleGyro;

        /* ---------- 偏航角：Z 轴陀螺仪积分 ----------
         * 这里只用固定的 dt，不做额外滤波；参数与取舍见文件头的 YAW_* 注释。
         * 三步：
         *   1) 用 YAW_LSB_PER_DPS 把 LSB 换成 °/s
         *   2) 减掉零偏，过死区压掉静止漂移
         *   3) 按固定 dt 积分 */
        YawRate = (float)GZ * (1.0f / YAW_LSB_PER_DPS) - YAW_BIAS_DPS;  /* 1/16.384 是二进制精确值，除法折乘法完全等价 */
        if (YawRate > -YAW_DEADZONE_DPS && YawRate < YAW_DEADZONE_DPS) YawRate = 0.0f;
        Yaw += YawRate * YAW_DT;
#if YAW_WRAP
        if      (Yaw >  180.0f) Yaw -= 360.0f;
        else if (Yaw < -180.0f) Yaw += 360.0f;
#endif

        /* ---------- 偏航增量 + 直角转弯计时 ----------
         * Yaw 每拍归一到 ±180°，用增量 dYaw 累加出"本次转过多少度"更稳：
         * 比如从 179 度再转 90 度会变成 -91 度，直接相减得到 270 度，
         * 用增量累加就是 90 度。
         * 累计角现在只当 PIVOT_MIN_DEG 门槛用(防起转瞬间被旧线骗退)，不再当停转条件
         * —— 停不停由 CCD 段判"抓到新线"决定；这里只留超时保底。
         * 增量计算放在 10ms 节拍里，比 CCD 帧细，积分不丢角。 */
        {
            float dYaw = Yaw - YawPrev;

            if (dYaw >  180.0f) dYaw -= 360.0f;
            if (dYaw < -180.0f) dYaw += 360.0f;
            YawPrev = Yaw;

            if (CornerState == CORNER_PIVOT)
            {
                PivotTicks += 10;

                /* 前馈段：等车头越过直角之后再开始累计 Yaw 的角度，见 PIVOT_ADVANCE_MS */
                if ((int32_t)PivotTicks >= (int32_t)PIVOT_ADVANCE_MS)
                    YawTurned += dYaw;

                if ((int32_t)PivotTicks >= (int32_t)(PIVOT_ADVANCE_MS + PIVOT_TIMEOUT_MS))
                {
                    CornerState    = CORNER_LINE;   /* 保底：转太久还没等到线，回循迹自己纠 */
                    TurnTargetCmd  = 0.0f;
                    CornerSeen     = 0;
                    PivotOk        = 0;
                }
            }
        }

        /* ================= 执行器分发：按状态出 PWM ================= */
        if (CarState == ST_BALANCE)
        {
            /* ---------- 直立环（原平衡环）----------
             * AnglePID 的输入是 Angle，输出取负后作为 AvePWM。
             * 符号反了车会立刻往倾倒方向加速，这一处只能用实测确认。 */
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
            /* ---------- 起立环：给一个和倾斜方向相反的 PWM，靠反作用把车甩起来 ----------
             * 方向：Angle>0 往前甩、Angle<0 往后甩
             * 前后用不同的到位角度，因为抬起时重心位置不同，收的角度也不同
             * 起立过程中不做转向：TurnPID.Target 固定 0 */
            float erectDoneAng = (Angle > 0.0f) ? ERECT_DONE_ANG : ERECT_DONE_ANG_BACK;

            if (fabsf(Angle) <= erectDoneAng)
            {
                /* 已经进入平衡范围 -> 切平衡环 */
                PID_ResetAll();
                ErectTime = 0;
                CarState  = ST_BALANCE;
            }
            else if (ErectTime < ERECT_TIMEOUT_MS)
            {
                int16_t swing = (Angle > 0.0f) ? ERECT_PWM : -ERECT_PWM;
                if (ERECT_DIR < 0) swing = -swing;      /* 甩轮方向取反 */

                if (ERECT_PULSE_MS > 0 && (ErectTime % ERECT_PERIOD_MS) >= ERECT_PULSE_MS)
                    swing = 0;                          /* 脉冲(断续)模式：只有高电平段才通电，模拟人甩车的节奏 */

                /* 起立段强制不转向，且必须是硬 0 而不是 TurnTargetRamp：
                 * 摇杆那支写 TurnTargetCmd 时没有 CarState 门禁，起立期间斜坡照跑，
                 * 若这里跟斜坡走，车就会一边甩起立一边转，直接把人带倒。 */
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
                ErectTime += 10;                        /* 每 10ms 加一次 */
            }
            else
            {
                /* ---------- 超时：电池太弱 / 卡住 / 轮胎打滑，停车 ----------
                 * 回 IDLE，等下一条 "1" 或再按一次按键。 */
                StopCar();
            }
        }
        else
        {
            /* ---------- ST_IDLE：上电默认，整车断电 ----------
             * 每 10ms 都写一次 0，把外部残留的 PWM 彻底抹掉 */
            TB6612_setPWM(1, 0);
            TB6612_setPWM(2, 0);
        }
}

/* ---- 50ms 段：读编码器 -> 算速度 -> 速度环 + 转向环（TIM3 回调分频调用）---- */
static void Tick50_SpeedTurn(void)
{
        /* 编码器每 50ms 读一次，算出转速：
         *   ReadSpeed() 返回 (short)CNT 的差值
         *   44   = 编码器一圈的脉冲数
         *   0.05 = 采样周期 50ms
         *   30   = 减速比
         *   -> 得到"转/秒"
         * 右轮取负号：两轮编码器安装方向相反，统一成"前进为正" */
        LeftSpeed  = (float)ReadSpeed(&htim2) * ENC_TO_RPS;
        RightSpeed = (float)(-ReadSpeed(&htim4)) * ENC_TO_RPS;

        /* 求平均与差速 */
			AveSpeed = (LeftSpeed + RightSpeed) * 0.5f;	
			DifSpeed = TURN_FB_SIGN * (LeftSpeed - RightSpeed);			
			
        /* ---- 转向目标斜坡限速：每 50ms 最多变 TURN_SLEW，把 Cmd 渐变送到 Ramp ----
         * 无条件更新(不受 CarState 限制)：起立/急停时 Cmd 已被 PID_ResetAll 清 0，
         * Ramp 会跟着收敛到 0；这样进平衡环那一刻差速是从 0 平滑建立的，不再阶跃。 */
        {
            float dCmd = TurnTargetCmd - TurnTargetRamp;
            if      (dCmd >  TURN_SLEW) TurnTargetRamp += TURN_SLEW;
            else if (dCmd < -TURN_SLEW) TurnTargetRamp -= TURN_SLEW;
            else                        TurnTargetRamp  = TurnTargetCmd;
        }

/* 执行 PID 计算 */
			if (CarState == ST_BALANCE)		/* 只在直立行驶时才算速度环 + 转向环 */
			{
/* ---------- 循迹前进速度：存在性判据 + 斜坡 ----------
 * 停车条件从"中线几何校验没过(CCD_Lost)"换成"画面里根本没有黑线(TrackLineSeen)"：
 *   校验没过只说明这帧的中线不能拿来纠偏，不代表车离开了线。
 *   斜着追线、进直角前黑区变宽、左右沿配对抖动，都会让 CCD_Lost 短暂为 1，
 *   老逻辑把这些一律当作出循迹区，于是一秒一停地踩死 —— 走走停停的来源就在这。
 * 直角转弯期间用 CORNER_SPEED 而不是 0：车一边转一边往前走，不会停在直角点上。
 * 归零改成斜坡(见 SPEED_SLEW)：停是"减速到停"，再起步也不必先把反向积分倒干净。
 * 注意转向那一路仍然按 CCD_Lost 走(下面 TrackLostCnt 那段)：坏中线不许用来打舵。 */
				if (TrackMode)
				{
					float dSpd;

					SpeedTargetCmd = (CornerState != CORNER_LINE) ? CORNER_SPEED
					               : (TrackLineSeen ? TRACK_SPEED : 0.0f);

					dSpd = SpeedTargetCmd - SpeedTargetRamp;
					if      (dSpd >  SPEED_SLEW) SpeedTargetRamp += SPEED_SLEW;
					else if (dSpd < -SPEED_SLEW) SpeedTargetRamp -= SPEED_SLEW;
					else                         SpeedTargetRamp  = SpeedTargetCmd;

					SpeedPID.Target = SpeedTargetRamp;
				}
				else
				{
					/* 不循迹时把斜坡跟到实际车速上，切进循迹那一拍不会突然跳变 */
					SpeedTargetRamp = AveSpeed;
				}

/* 速度环 PID 计算 */
				SpeedPID.Actual = AveSpeed;			
				PID_Update(&SpeedPID);				// 把组装好的速度喂给 PID 计算
				AnglePID.Target = SpeedPID.Out;		/* 串级：速度环的输出就是直立环的目标倾角 */
				
/* 转向 PID 计算 */
				TurnPID.Target = TurnTargetRamp;	/* 用斜坡后的目标；前馈 TURN_FF*Target 也跟着渐变，不再阶跃 */
				DifSpeedFilter += 0.5f * (DifSpeed - DifSpeedFilter);	/* 转向角速度一阶低通，滤掉编码器量化噪声 */
				TurnPID.Actual = DifSpeedFilter;			
				PID_Update(&TurnPID);				// 转向 PID 计算
				DifPWM = (int16_t)(TurnPID.Out + TURN_FF * TurnPID.Target);	/* 转向输出 + 转向前馈 */
				if (DifPWM > 50) DifPWM = 50; else if (DifPWM < -50) DifPWM = -50;	/* 限幅 ±50：前馈+反馈叠加会超 */
        }
}

/* ---- CCD 段：采一帧 + 循迹/直角/T 状态机（TIM3 回调分频调用，放每拍末尾）----
 * 位置很关键：它排在 10ms/50ms 段之后，PWM 已经写进电机，
 * 再花 ~0.7ms 采一帧也不会让执行滞后一拍。反过来放最前面就会把执行往后推。
 *
 * 采样周期 = CCD_Div x TIM3 周期(10ms)，与中断优先级无关。
 *   主循环里 OLED_Update() 要约 20~24ms，只要不关中断就不影响采样。
 *   一帧真的只有 ~0.6ms(TIME_us=2 -> CLK 约 110kHz)，只占 10ms 的 6%。
 *   CCD_AutoExposure() 也在里面跑。TIM3 优先级是 0，会抢占 SysTick(优先级 15)，
 *   所以 HAL_Delay() 不能在循环里用；采样窗口很小，别在里面加长延时或串口打印。 */
static void Ccd_Frame(void)
{
    get_CCD();          /* = RD_TSL()：128 像素读数 + 自动曝光 + 阈值 + 中线 */

        /* ---------- 循迹：中线偏差 -> 转向目标 ----------
         * 每一帧都重新判一次(取最新一帧)，因为循迹、直角用的是同一个"中线"。
         * 转向目标按偏差线性映射，偏差越大转得越急。
         *
         * 丢线(CCD_Lost)时先不清 TurnPID.Target，保持上一帧的转向多走一小段，
         *   靠这个惯性把车带过盲区一小段，超过 TRACK_LOST_MAX 帧才放弃：
         *   同时 50ms 段会把速度目标拉 0 -> 原地直立，不再盲冲。
         *
         * 只在 ST_BALANCE 时生效：起立阶段不做转向，转向目标固定 0。 */
        if (TrackMode && CarState == ST_BALANCE)
        {
            /* ---------- 每帧判"直角"：两侧端点 + 黑点数 ----------
             * 128 像素按 25Hz 扫完约几十 us，可以接受。
             * darkCnt 是区分"直角"和"普通偏线"的关键：
             *   直道        黑点数是一窄条
             *   直角/黑区   黑点数明显变多(宽黑区) */
            /* ---------- 边沿证据：两端各 8 个可信像素做多数表决 ----------
             * 原来只采第 3/124 两个单点，恰好落在阈值算法自己都弃用的两端坏点区
             * ([0,5) 和 [123,128))：端点发暗/坏点会把直角方向判到反方向，
             * "右直角往左转"的根源就在这。表决取严格多数(5/8)，少量坏点翻不了案。 */
            uint8_t darkL = 0, darkR = 0;
            uint8_t darkCnt = 0;
            uint8_t eL, eR;
            uint8_t kk;
            uint8_t tIsT = 0;           /* 本帧已确认证据构成 T 字路口，用来抑制同帧的直角触发 */

            for (kk = CCD_EDGE_LO; kk < CCD_EDGE_LO + EDGE_ZONE_N; kk++)
                if (ccd_adc[kk] < CCD_Yuzhi) darkL++;
            for (kk = CCD_EDGE_HI; kk < CCD_EDGE_HI + EDGE_ZONE_N; kk++)
                if (ccd_adc[kk] < CCD_Yuzhi) darkR++;
            eL = (darkL >= EDGE_ZONE_DARK) ? 1u : 0u;
            eR = (darkR >= EDGE_ZONE_DARK) ? 1u : 0u;

            /* 黑点数也只统计可信区间，不让两端坏点常年灌水虚增 */
            for (kk = 5; kk < 123; kk++)
                if (ccd_adc[kk] < CCD_Yuzhi) darkCnt++;

            /* 存在性判据：画面里到底有没有黑。前进/停车只看这个，
             * 纠偏才看 CCD_Lost —— 两件事以前混用一个标志，才导致走走停停。
             * 带迟滞：连续 TRACK_UNSEEN_MAX 帧没线才判"丢线"，恢复则是 1 帧立即。
             * 单帧黑点数抖到 4 以下(反光/阈值抖动)不再立刻踩刹车 ——
             * 那一脚刹车会把速度环积分灌反，车就得先倒干净再能走。 */
            if (darkCnt >= TRACK_SEEN_MIN)
            {
                TrackLineSeen  = 1u;
                TrackUnseenCnt = 0;
            }
            else
            {
                if (TrackUnseenCnt < 255) TrackUnseenCnt++;
                if (TrackUnseenCnt >= TRACK_UNSEEN_MAX) TrackLineSeen = 0u;
            }

            /* ---------- T 字路口：先累积证据，稍后再分派 ----------
             * 和普通直角的几何区别本身是互斥的：
             *   普通直角：线往一侧拐走 -> 只有一侧边沿区发黑 -> (eL ^ eR) 为真
             *   T 字路口：前方横线平行于线阵 -> 整幅一起黑 -> eL && eR 且近满幅
             * 但"略歪的 T"在横线还没铺满视场的那几帧，会长得极像直角(一侧先黑+黑区变宽)，
             * 会被下面的 CORNER_CONFIRM 抢跑，所以这里先攒出 T 证据，用 tIsT 去抑制同帧的
             * 直角触发。抑制落在链内部的触发条件上，不改链首 —— 改链首会让命中那帧掉进
             * 链尾的 PIVOT 分支，那是靠巧合而不是靠逻辑。
             * 只在 CORNER_LINE 态累积：PIVOT 期间整幅发黑是正常现象，
             * 不设这道门的话转完一个弯回来会被瞬间再判一次 T。 */
            if (CornerState == CORNER_LINE)
            {
                if (eL && eR && darkCnt >= T_MIN_DARK)
                {
                    if (TSeen < 255) TSeen++;
                }
                else
                {
                    TSeen = 0;
                }

                tIsT = (TSeen >= T_CONFIRM) ? 1u : 0u;
            }

            if (CornerState == CORNER_LINE)
            {
                /* 直角确认：本帧没有合法细线 + 只有一侧有过沿 + 黑区足够宽。
                 * 连续满足 CORNER_CONFIRM 帧才认，滤掉"单帧噪点/反光"造成的误判。 */
                if (CCD_Lost && (eL ^ eR) && darkCnt >= CORNER_MIN_DARK)
                {
                    /* 方向在首个疑似帧锁定，之后只认同侧帧：
                     * 贴近直角后的临界帧(整幅发黑/阈值漂移)没机会再把方向翻面 */
                    int8_t side = (int8_t)((eR ? 1 : -1) * CORNER_SIDE_SIGN);
                    if (CornerSeen == 0)
                        CornerDir = side;
                    if (side == CornerDir)
                    {
                        if (CornerSeen < 255) CornerSeen++;
                    }
                    else
                    {
                        CornerSeen = 0;   /* 异侧帧：作废重新锁方向 */
                    }
                }
                else
                {
                    CornerSeen = 0;
                }

                if (CornerSeen >= CORNER_CONFIRM && !tIsT)
                {
                    /* 连续压过阈值两次，确认是直角 -> 进入转弯
                     * 方向沿用循迹环的转向通路(Target = TRACK_DIR x 方向 x 转速)，
                     * 保证"转过去"和"循迹纠偏"用的是同一套符号约定。 */
                    CornerDir      = (int8_t)((eR ? 1 : -1) * CORNER_SIDE_SIGN);
                    CornerState    = CORNER_PIVOT;
                    YawTurned      = 0.0f;
                    YawPrev        = Yaw;       /* 记下当前 Yaw 作为增量起点 */
                    PivotTicks     = 0;
                    PivotOk        = 0;         /* 新一轮转弯，抓线确认计数从头来 */
                    TrackLostCnt   = 0;
                    CornerSeen     = 0;
                    TurnTargetCmd  = TRACK_DIR * (float)CornerDir * PIVOT_RATE;
                }
                else if (CCD_Lost)
                {
                    if (TrackLostCnt < 255) TrackLostCnt++;
                    if (TrackLostCnt >= TRACK_LOST_MAX)
                        TurnTargetCmd  = 0.0f;  /* 丢线太久：转向目标回 0，等 50ms 段把速度也拉 0 */
                    /* 没到放弃阈值就保持上一帧的转向，靠惯性带你一小段 */
                }
                else
                {
                    TrackLostCnt = 0;

                    int16_t err = (int16_t)CCD_Zhongzhi - TRACK_CENTER;  /* 偏差 = 中线 - TRACK_CENTER */
                    if (err > -TRACK_DEAD && err < TRACK_DEAD) err = 0;  /* ±TRACK_DEAD 内归零 */

                    /* ---------- 超前转向(PD 里的 D)：让转向"更提前" ----------
                     * dErr = 本帧偏差 - 上一帧偏差(都去过死区，静止在死区内时 dErr 恒 0)。
                     *   入弯：偏差刚开始涨，dErr 与 err 同号 -> 提前加转，不等偏差拉大才动手；
                     *   回正：偏差还在但开始回收，dErr 反号 -> 提前收转，压掉过冲摆振。
                     * 等效于把响应提前 TRACK_KD 帧(1 帧 = CCD_Div x 10ms = 20ms)。
                     * 中线有 ±1~3 像素量化抖动，dErr 会被灌进 ±3 像素噪声，
                     * 所以先乘 TRACK_KD 再用 TRACK_LEAD_MAX 硬限幅，
                     * 超前量的上限也就 12 像素(x TRACK_GAIN/63 约 0.23 转/秒)，翻不了车。
                     * 太灵敏就把 TRACK_KD 降到 1，还不够提前就升到 3。 */
                    int16_t dErr = err - TrackErrPrev;
                    TrackErrPrev = err;
                    int16_t lead = TRACK_KD * dErr;
                    if      (lead >  TRACK_LEAD_MAX) lead =  TRACK_LEAD_MAX;
                    else if (lead < -TRACK_LEAD_MAX) lead = -TRACK_LEAD_MAX;

                    TurnTargetCmd  = TRACK_DIR * TRACK_GAIN * (float)(err + lead) / 63.0f;
                }
            }
            else if (CornerState == CORNER_PIVOT)
            {
                /* 转弯时转向目标固定：
                 * 每帧都写一次而不是只在开始时写一次，50ms 段每拍都要用 Target，
                 * 而且 TURN_FF 前馈要一直跟着，中途改成 0 会丢前馈、转不动 */
                TurnTargetCmd  = ((int32_t)PivotTicks >= (int32_t)PIVOT_ADVANCE_MS)
                               ? (TRACK_DIR * (float)CornerDir * PIVOT_RATE)
                               : 0.0f;      /* 前馈段内：先直行不动，等车头越过直角再转 */
                TrackLostCnt   = 0;         /* 转弯不参与"丢线"计数，否则会把直角误判成丢线 */

                /* ---------- CCD 接管：转到重新抓到线为止 ----------
                 * 越过 PIVOT_MIN_DEG 之后，连续 PIVOT_LINE_FRAMES 帧拿到合法细线
                 * (!CCD_Lost：沿配对 + 线宽 + 对比度都过)就立刻回循迹。
                 * 停转角由"看到新线"决定，不再硬算 85 度 —— 弯缓弯急都能贴住。
                 * 门槛之前旧线/黑区还在画面里，CCD_Lost 本来就是 0，不能信。 */
                if (fabsf(YawTurned) >= PIVOT_MIN_DEG && !CCD_Lost)
                {
                    if (PivotOk < 255) PivotOk++;
                    if (PivotOk >= PIVOT_LINE_FRAMES)
                    {
                        CornerState = CORNER_LINE;   /* 抓到新线：立刻回循迹接管 */
                        CornerSeen  = 0;
                        PivotOk     = 0;
                    }
                }
                else
                {
                    PivotOk = 0;
                }
            }

            /* ---------- T 分派：排在整条状态机链之后 ----------
             * 上面的直角触发已经被 !tIsT 挡掉了，但同帧它仍可能走"丢线计数"或
             * "按坏中线纠偏"这两条分支并写 TurnTargetCmd。分派放链尾，由这里覆盖
             * 成 T 自己的动作，顺序上就有最终话语权，不用再去改链首的判定条件。
             * 行为：每个确认的 T 都固定左转(CornerDir=-1)，转到 CCD 抓到新线为止，
             * 没有"第二个 T 停车"。
             * 方向写死 -1(左转)：直角的方向是靠"哪端发黑"推出来的，
             * T 是整幅黑、推不出来；CornerDir=-1 配 TRACK_DIR=-1 -> Target=+PIVOT_RATE，
             * 与"Target>0 = 左转"的约定一致。 */
            if (tIsT)
            {
                TSeen        = 0;
                CornerSeen   = 0;
                TrackLostCnt = 0;

                CornerDir      = -1;
                CornerState    = CORNER_PIVOT;
                YawTurned      = 0.0f;
                YawPrev        = Yaw;       /* 与直角触发同款：以当前 Yaw 为增量起点 */
                PivotTicks     = 0;
                PivotOk        = 0;         /* 同上：新一轮转弯，抓线确认计数从头来 */
                TurnTargetCmd  = TRACK_DIR * (float)CornerDir * PIVOT_RATE;
            }
        }
}

/* ==========================================================================
 * TIM3 中断：整个系统唯一的时间基准（10ms），现在只做分频分发
 *   tim.c: Prescaler = 72-1, Period = 10000-1  ->  72MHz/72/10000 = 10ms
 *
 *   每 1 拍    hcount++ / Count1++（分频计数）
 *   每 10ms    Tick10_Attitude()   姿态 -> 直立/起立环 -> PWM
 *   每 50ms    Tick50_SpeedTurn()  测速 -> 速度环 + 转向环
 *   每拍       摔车检测（|Angle| 超限 -> StopCar）
 *   每拍末     Ccd_Frame()         采一帧 CCD -> 循迹状态机
 *
 * 摔车检测每拍都判，但 Angle 是 10ms 才更新一次，实际响应约 10ms。
 * StopCar() 内部会调 PID_ResetAll()，下次收到 "1" 时 StartErect()
 * 会先做 Angle_Realign() 重新对准角度。
 * ========================================================================== */
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{
    if (htim != &htim3)
    {
        return;
    }

    hcount++;
    __HAL_TIM_CLEAR_IT(&htim3, TIM_IT_UPDATE);

    if (hcount >= TICK_10MS)                          /* ===== 10ms 段 ===== */
    {
        hcount = 0;
        Tick10_Attitude();
    }

    Count1++;                                         /* ===== 50ms 段 ===== */
    if (Count1 >= TICK_50MS)
    {
        Count1 = 0;
        Tick50_SpeedTurn();
    }

    /* 平衡中断：|Angle| 超过 ERECT_START_ANG -> StopCar() 停车回 IDLE */
    if (CarState == ST_BALANCE && fabsf(Angle) > ERECT_START_ANG)
    {
        StopCar();
    }

    /* CCD 放每拍末尾：PWM 已写完，采一帧不推迟执行 */
    if (++CCD_count >= CCD_Div)
    {
        CCD_count = 0;
        Ccd_Frame();
    }

    if (__HAL_TIM_GET_FLAG(&htim3, TIM_IT_UPDATE) != RESET)
    {

        if (__HAL_TIM_GET_FLAG(&htim3, TIM_IT_UPDATE) == SET)
        {
            TimerErrorFlag = 1;  // 中断超时保护：这一拍被别的中断拖了很久，可用来观察
                                  // -> 说明有中断把它拖慢了，这里只做观察记录，不改变控制

            __HAL_TIM_CLEAR_IT(&htim3, TIM_IT_UPDATE);
        }

        TimerCount = __HAL_TIM_GET_COUNTER(&htim3);
    }
}

/* ==========================================================================
 * ===== 以下三个函数只被主循环调用（慢路径，容忍几十毫秒延迟）=====
 * ========================================================================== */

/* ---------- OLED 状态屏：整屏重画一遍 + 电池电压巡检 ----------
 * 布局 128x64，OLED_6X8 字体每字 6 像素宽：
 *   y=0        D<Div> <ms>ms  M<Max> m<Min>         采样分频/周期/灰度范围
 *   y=8        T<阈值> Z<中线> <左>-<右> L<丢线>     x=92: C<状态> <转角>
 *   y=16..31   128 像素灰度波形（黑线表现为下陷）
 *   y=32       T:<角度环目标>       x=60: Yaw:<偏航角>
 *   y=40       Angle:<倾角实测>
 *   y=48       O:<角度环输出>       x=64: B<电池电压>/!<亏电>
 *   y=56       TRK<!/-><转向目标>
 *
 * 每行最多 21 个字符（128/6），最长的是 "T255 Z127 127-127 L1" = 20 字符，
 * 刚好不越界。改格式前先数长度。
 * OLED.c 写缓冲用的是 |=，所以每帧必须先 OLED_Clear()，否则上一帧的字会重影。
 * 想看 PID 参数时把下面 KP/KI/KD 那几行注释放开，
 * 同时把 CCD 的 y=0/y=8 挪开，别让 y=8 撞到 KP 那一行。 */
static void OLED_RenderStatus(void)
{
    uint8_t  k;
    uint16_t den;   /* 防除零：本帧最大灰度可能为 0 */
    uint8_t  ty;

    OLED_Clear();

    OLED_Printf(0, 0, OLED_6X8, "D%u %ums M%u m%u",
                (unsigned)CCD_Div, (unsigned)(CCD_Div * 10u),
                (unsigned)CCD_Max, (unsigned)CCD_Min);

    OLED_Printf(0, 8, OLED_6X8, "T%u Z%u %u-%u L%u",
                (unsigned)CCD_Yuzhi, (unsigned)CCD_Zhongzhi,
                (unsigned)CCD_Left,  (unsigned)CCD_Right, (unsigned)CCD_Lost);

    /* 直角状态与转角：C0=循迹中 C1=转弯中，后面是累计转角 */
    OLED_Printf(92, 8, OLED_6X8, "C%u%+03.0f",
                (unsigned)CornerState, (double)YawTurned);

    /* ===================== CCD 波形显示 =====================
     * 灰度值 0..CCD_Max 线性映射到 0..15 像素高，画成柱状图：
     * 越黑(灰度越低)柱子越短，所以黑线在画面上表现为"下陷"。
     * 阈值线单独用点线画出来（每 4 像素一个点），方便看阈值卡在哪里。
     *
     * ccd_adc[] 由 TIM3 中断写、主循环读，可能读到半帧，
     *   误差只有 0.6ms/(CCD_Div x 10ms) 约 1.5%，只影响最后一列，一帧就恢复。
     * 128 个 OLED_DrawPoint 约 130us，相对 OLED_Update() 的 ~23ms 可以忽略。 */
    den = CCD_Max ? CCD_Max : 1u;
    for (k = 0; k < CCD_PIXELS; k++)
    {
        uint8_t h = (uint8_t)((uint32_t)ccd_adc[k] * 15u / den);
        if (h > 15) h = 15;
        OLED_DrawPoint(k, (int16_t)(31 - h));
    }

    /* 阈值线（点线，每 4 像素一个点）：对应灰度高低的基准 */
    ty = (uint8_t)(31 - ((uint32_t)CCD_Yuzhi * 15u / den));
    if (ty > 31) ty = 31;
    for (k = 0; k < CCD_PIXELS; k += 4) OLED_DrawPoint(k, (int16_t)ty);

//        OLED_Printf(0, 0, OLED_6X8, "ST:%s %d", StateStr(), (int)ErectTime);   /* 状态 + 起立计时(ms) */
//        OLED_Printf(0, 8, OLED_6X8, "KP:%05.2f//%05.2f//%05.2f ", AnglePID.Kp, SpeedPID.Kp, TurnPID.Kp);  // 三个环的 Kp
//        OLED_Printf(0, 16, OLED_6X8, "KI:%05.2f//%05.2f//%05.2f", AnglePID.Ki, SpeedPID.Ki, TurnPID.Ki);  // 三个环的 Ki
//        OLED_Printf(0, 24, OLED_6X8, "KD:%05.2f//%05.2f//%05.2f", AnglePID.Kd, SpeedPID.Kd, TurnPID.Kd);  // 三个环的 Kd
    OLED_Printf(0, 32, OLED_6X8, "T:%+05.1f", AnglePID.Target);	// 角度环目标值（也就是目标倾角）
    OLED_Printf(60, 32, OLED_6X8, "Yaw:%+07.2f", Yaw);			// 偏航角(度)：左转为正
    OLED_Printf(0, 40, OLED_6X8, "Angle:%+05.1f", Angle);			// 倾角实测值
    OLED_Printf(0, 48, OLED_6X8, "O:%+05.0f", AnglePID.Out);	// 角度环输出
//        OLED_Printf(0, 56, OLED_6X8, "GX%+05.1f", GX / GYRO_LSB_PER_DPS);  /* X 角速度(°/s)，静止应为 0 */
//        OLED_Printf(42, 56, OLED_6X8, "GZ%+05.1f", GZ / GYRO_LSB_PER_DPS);  /* Z 角速度(°/s)，静止时应接近 YAW_BIAS_DPS */
//        OLED_Printf(70, 40, OLED_6X8, "G:%+02.2f", G);
//        OLED_Printf(70, 48, OLED_6X8, "S:%+02.2f", RightSpeed);   /* 右轮转速：让位给电池电压，要看就放开 */
//        OLED_Printf(84, 56, OLED_6X8, "S%+02.2f", LeftSpeed);     /* 左轮转速：同上 */

    /* 电池电压：每 BAT_SAMPLE_MS 采一轮(8 次平均)，IIR 平滑后显示在原右轮速位置。
     * 首轮直接采用实测值，免去从 0 爬到真实电压的那两三秒。 */
    {
        static uint32_t lastBatTick = 0;
        uint32_t now = HAL_GetTick();
        if ((uint32_t)(now - lastBatTick) >= BAT_SAMPLE_MS)
        {
            float v = Bat_ReadVoltage();
            lastBatTick = now;
            BatVoltage = (BatVoltage <= 0.1f) ? v : BatVoltage + 0.3f * (v - BatVoltage);
        }
        if (BatVoltage < BAT_LOW_V)
            OLED_Printf(64, 48, OLED_6X8, "!%04.1fV", BatVoltage);   /* '!': 低于亏电线 */
        else
            OLED_Printf(64, 48, OLED_6X8, "B%04.1fV", BatVoltage);
    }
    OLED_Printf(0, 56, OLED_6X8, "TRK%c%+05.2f", TrackMode ? '!' : '-', TurnPID.Target);/* ! = 循迹中，- = 不循迹 */
    OLED_Update();
}

/* ---------- 循迹开关统一入口：开/关都先把状态清干净 ----------
 * 三处切换点(按键第②击、裸字节 'T'/'t'、包 [t])共用这一份：
 *   TrackLostCnt 丢线计数、TurnTargetCmd 转向命令、直角/T 证据与状态机、
 *   PivotOk 抓线确认计数。不清的话会带着上一轮的指令和 PIVOT 状态
 * 瞬间抢一下（刚开循迹就转一个 90 度之类）。 */
static void Track_Reset(uint8_t on)
{
    TrackMode     = on;
    TrackLostCnt  = 0;
    TurnTargetCmd = 0.0f;
    CornerState   = CORNER_LINE;
    CornerSeen    = 0;
    TSeen         = 0;
    PivotOk       = 0;
}

/* ---------- 蓝牙 [包] 处理：轮询两个接收缓冲并分派 ----------
 * 包格式与裸字节命令的对照、大小写陷阱见主循环里那段总注释。
 * strtok 会改写缓冲内容，只能在主循环里做（中断收完了才轮到它）。 */
static void Blue_ProcessPackets(void)
{
    uint8_t i;

    for (i = 0; i < 2; i++)
    {
        if (BlueSerial_RxFlag[i] == 1)
        {
            char *Tag = strtok(BlueSerial_RxPacket[i], ",");	// 取第 1 段，作为标签 Tag

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
                else if (strcmp(Tag, "t") == 0)             /* 收到 [t] -> 切换循迹（只认小写；大写 T 请发裸字节） */
                {
                    Track_Reset(!TrackMode);
                }
                else if (strcmp(Tag, "key") == 0)           /* [key,名称,动作]：按键事件帧 */
                {
                    char *Name = strtok(NULL, ",");			// 取第 2 段，作为按键名称
                    char *Action = strtok(NULL, ",");		// 取第 3 段，作为按键动作

                    /* 这里执行按键对应的动作，目前没有需要处理的 */
                }
                else if (strcmp(Tag, "slider") == 0)	// [slider,名称,值]：滑块帧，用来在线改参数
                {
                    char *Name = strtok(NULL, ",");			// 取第 2 段，作为参数名
                    char *Value = strtok(NULL, ",");		// 取第 3 段，作为参数值

                    /* 执行滑块对应的动作，把新值写到对应的 PID 参数 */
                    if (strcmp(Name, "AngleKp") == 0)	// 参数名为 AngleKp
                    {
                        AnglePID.Kp = atof(Value);		// 写入角度环 Kp
                    }
                    else if (strcmp(Name, "AngleKi") == 0)	// 参数名为 AngleKi
                    {
                        AnglePID.Ki = atof(Value);		// 写入角度环 Ki
                    }
                    else if (strcmp(Name, "AngleKd") == 0)	// 参数名为 AngleKd
                    {
                        AnglePID.Kd = atof(Value);		// 写入角度环 Kd
                    }
                    else if (strcmp(Name, "G") == 0)	// 参数名为 G（角度计安装偏置）
                    {
                        G = atof(Value);		// 写入安装偏置
                    }
                    else if (strcmp(Name, "SpeedKp") == 0)		// 参数名为 SpeedKp
                    {
                        SpeedPID.Kp = atof(Value);				// 写入速度环 Kp
                    }
                    else if (strcmp(Name, "SpeedKi") == 0)		// 参数名为 SpeedKi
                    {
                        SpeedPID.Ki = atof(Value);				// 写入速度环 Ki
                    }
                    else if (strcmp(Name, "SpeedKd") == 0)		// 参数名为 SpeedKd
                    {
                        SpeedPID.Kd = atof(Value);				// 写入速度环 Kd
                    }
                    else if (strcmp(Name, "TurnKp") == 0)		// 参数名为 TurnKp
                    {
                        TurnPID.Kp = atof(Value);				// 写入转向环 Kp
                    }
                    else if (strcmp(Name, "TurnKi") == 0)		// 参数名为 TurnKi
                    {
                        TurnPID.Ki = atof(Value);				// 写入转向环 Ki
                    }
                    else if (strcmp(Name, "TurnKd") == 0)		// 参数名为 TurnKd
                    {
                        TurnPID.Kd = atof(Value);				// 写入转向环 Kd
                    }

                }
                else if (strcmp(Tag, "joystick") == 0)		// [joystick,LH,LV,RH,RV]：摇杆帧
                {
                    int8_t LH = atoi(strtok(NULL, ","));		// 取第 2 段，作为摇杆值 LH
                    int8_t LV = atoi(strtok(NULL, ","));		// 取第 3 段，作为摇杆值 LV
                    int8_t RH = atoi(strtok(NULL, ","));		// 取第 4 段，作为摇杆值 RH
                    int8_t RV = atoi(strtok(NULL, ","));		// 取第 5 段，作为摇杆值 RV

                    /* 执行摇杆动作 */
                    /* 摇杆死区：按 ±5 抖动漂移 */
                    if (LV > -5 && LV < 5) { LV = 0; }
                    if (!TrackMode) SpeedPID.Target = LV / 50.0;   /* 循迹时前进速度由 TRACK_SPEED 给，50ms 段会覆盖 */

                    /* 循迹模式下摇杆的转向被屏蔽：
                     *   循迹自己写 TurnPID.Target 来纠偏，摇杆再写一次会打架；
                     *   两者共用同一个变量，所以只在非循迹时接受 RH */
                    if (!TrackMode)
                    {
                        if (RH > -5 && RH < 5) { RH = 0; }
                        TurnTargetCmd = RH / 60.0;   // RH>0 = 右转；/60 比原 /50 稍软，配合斜坡减少打滑
                        if (TurnTargetCmd != 0.0f && LV == 0)
                            SpeedPID.Target = 0.20f;  /* 只转向不前进时给一点前进速度，避免原地打转 */
                    }

                }
            }

            BlueSerial_RxFlag[i] = 0;				// 处理完清除标志位，等待下一次
        }
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
    /* PA7 -> ADC1_IN7 模拟输入：电池 10k/2.7k 分压检测(见 Bat_ReadVoltage 上方注释) */
    {
        GPIO_InitTypeDef gpioBat = {0};
        gpioBat.Pin = GPIO_PIN_7;
        gpioBat.Mode = GPIO_MODE_ANALOG;
        HAL_GPIO_Init(GPIOA, &gpioBat);
    }

    HAL_Delay(200);   // 给 OLED 上电留点时间，否则首帧显示异常
    OLED_Init();
    OLED_Clear();

    MPU6050_Init();
    Angle_Realign();   /* 上电只做一次角度对准(静止时有效)；不做的话互补滤波要十几秒才收敛，
                        * 期间收到 "1" 会用错误的起点角度甩轮，容易把车甩倒。 */
    HAL_TIM_PWM_Start(&htim1, TIM_CHANNEL_1);
    HAL_TIM_PWM_Start(&htim1, TIM_CHANNEL_4);
    HAL_TIM_Encoder_Start(&htim2, TIM_CHANNEL_ALL);
    HAL_TIM_Encoder_Start(&htim4, TIM_CHANNEL_ALL);
    Ccd_Init();          /* CCD 上电钳电平：CLK=H, SI=L，之后 RD_TSL() 每帧先补一个复位脉冲。
                          * 不然第一个时钟的前几个像素会被上次的残留电平带偏。 */
    BlueSerial_Init();   // 初始化蓝牙接收（USART3 + 接收中断）
    HAL_TIM_Base_Start(&htim3);
    (void)MPU6050_GetID();  /* 读 WHO_AM_I(0x68=在线)：上电顺手探一次 I2C 应答，
                             * 返回值暂不用；需要确认传感器时把它显示到 OLED 即可。 */
    OLED_Update();
    MX_TIM3_Init();                  /* 重复初始化一次 TIM3 的计数器，与 MX_TIM3_Init() 同步，
                                      * 确保开中断之前的计数是干净的。 */
    HAL_TIM_Base_Start_IT(&htim3);   /* 10ms update interrupt：tim.c: Period = 10000-1 */
    PID_Init(&AnglePID);
    PID_Init(&SpeedPID);
    PID_Init(&TurnPID);

    CarState = ST_IDLE;          /* 上电默认：整车断电，等 "1" 或按键启动 */

    // 预置角度环的实际值
    AnglePID.Actual = Angle;
    AnglePID.Actual1 = Angle;   // 同上：预置上次实测值，防止微分项第一次就冲击
    AnglePID.Error0 = AnglePID.Target - AnglePID.Actual;
    AnglePID.Error1 = AnglePID.Error0;    
  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
    while (1)
    {
        int len;
//	TB6612_setPWM(2,100);

        /* 状态指示灯：PC13 的板载 LED
         *   熄灭 = IDLE 停车     闪烁 = ERECT 起立中     常亮 = BALANCE 直立行驶
         *   闪烁用 ErectTime/150 取反，每 150ms 翻一次 */
        {
            uint8_t ledOff;
            if (CarState == ST_BALANCE)     ledOff = 0;
            else if (CarState == ST_ERECT)  ledOff = (uint8_t)((ErectTime / 150u) & 1u);
            else                            ledOff = 1;
            HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, ledOff ? GPIO_PIN_SET : GPIO_PIN_RESET);
        }


        /* 整屏状态渲染（布局注释见 OLED_RenderStatus 函数头）：刷新 + 电池巡检 */
        OLED_RenderStatus();


        /* ---- 蓝牙命令：两种发法都支持 ----
         *   裸字节（不进方括号）：'1' = 起立   '0' = 急停   'T'/'t' = 切换循迹
         *   打包（App/上位机）：[1] / [0] / [t] 与上面等价，
         *                      另外还有 [key,...] [slider,...] [joystick,...]
         *
         * 注意大小写：裸字节 'T' 和 't' 都能切换，但包里的 Tag 只认小写 "t"，
         *   "[T]" 不会生效 —— BlueSerial.c 只捕获 '0'/'1'/'T'/'t' 四种裸字节，
         *   而包内容是按 Tag 逐个 strcmp 的，大写 T 没有对应分支。
         *   要支持 "[T]" 得在这里再加一支。 */
        /* ---- PA5 用户按键：三段循环  启动 -> 循迹 -> 关闭 -> 回到启动 ----
         * 中断只置标志，这里消费（原因见 HAL_GPIO_EXTI_Callback 上方注释）。
         *
         * 不额外记一个 KeyStage 变量，而是直接从 CarState + TrackMode 推：
         *   ① IDLE                     -> StartErect()   甩轮起立
         *   ② BALANCE 且 TrackMode==0  -> TrackMode=1    进循迹
         *   ③ BALANCE 且 TrackMode==1  -> StopCar()      关循迹+停车 -> 回 IDLE
         *   ④ ERECT                    -> StopCar()      放弃起立 -> 回 IDLE
         * 这样"按键走到第几段"和"车真实处于哪一步"永远是同一份数据，
         * 不会出现两边打架、按了第四次却还停在第二段的情形。
         *
         * OLED 对照（第 0 行 ST: + 第 7 行 TRK）：
         *   ST:IDLE        -> 等第①击
         *   ST:BAL + TRK-  -> 等第②击
         *   ST:BAL + TRK!  -> 等第③击
         *
         * ST_ERECT（起立中）的按键 = 放弃起立（第④击），不再无视：
         *   生效门槛 ErectTime >= ERECT_ABORT_GUARD_MS(300)。
         *   StartErect() 内部 Angle_Realign() 有 300ms 阻塞，这段里车完全不动，
         *   很容易被当成"没响应"再按一次；那次 KeyFlag 会在 StartErect 返回后
         *   立刻被消费，而此刻 ErectTime 还是 0 —— 没有门槛的话，刚甩起来的车
         *   会被这一下直接按停。 */
        if (KeyFlag)
        {
            KeyFlag = 0;

            if (CarState == ST_IDLE)
            {
                /* ① 起立。顺手关掉循迹：上一轮若是摔车/超时从 ST_BALANCE
                 * 掉回来的，StopCar() 已经清过 TrackMode；这里再写一次是让
                 * "起立时不带循迹"这条约束在代码上看得见（双保险）。 */
                TrackMode    = 0;
                TrackLostCnt = 0;
                StartErect();
            }
            else if (CarState == ST_BALANCE)
            {
                if (!TrackMode)
                {
                    /* ② 进循迹：状态清零逻辑见 Track_Reset() 注释 */
                    Track_Reset(1u);
                }
                else
                {
                    /* ③ 关循迹 + 停车。TrackLostCnt 与 TurnPID.Target 由
                     * StopCar() -> PID_ResetAll() 一并清掉，这里只说意图。 */
                    TrackMode = 0;
                    StopCar();
                }
            }
            else
            {
                /* ④ 放弃起立。门槛见上方注释：ErectTime 是进入 ERECT 后的毫秒
                 * 计数（StartErect 里清零、10ms 节拍里累加），用来挡掉 ① 之后
                 * 那段 300ms 阻塞期里"以为没响应"的第二次按键。
                 *
                 * StopCar() 会一并清掉 TrackMode / TrackLostCnt / ErectTime，
                 * 所以放弃起立后必定回到干净的 IDLE，下次按键还是从第①击开始。 */
                if (ErectTime >= ERECT_ABORT_GUARD_MS)
                {
                    StopCar();
                }
            }
        }
        if (BlueSerial_CmdFlag)
        {
            char cmd = BlueSerial_CmdChar;
            BlueSerial_CmdFlag = 0;
            if      (cmd == '1') { StartErect(); }
            else if (cmd == '0') { StopCar(); }
            else if (cmd == 'T' || cmd == 't')
            {
                /* 切换循迹开关（状态清零逻辑见 Track_Reset 注释） */
                Track_Reset(!TrackMode);
            }
        }

        /* 轮询接收缓冲，处理收到的 [包]（分派逻辑见 Blue_ProcessPackets 函数头） */
        Blue_ProcessPackets();

        /* ---------- 上位机链路：蓝牙调试口（可选）---------*/
        len = sprintf(display_buf, "[plot:%f,%f,%d,%d,%d,%f,%f\n]",TurnPID.Target,TurnPID.Actual1,LeftPWM,RightPWM,DifPWM,Angle,Yaw);//GX,GZ,%dGZ,Yaw,DifSpeed,DifPWM,Angle
//        len = sprintf(display_buf, "[plot:%f\n]",Yaw);//,TurnPID.Target,TurnPID.Actual1,LeftPWM,RightPWM,DifPWM,AngleGX,GZ,%dGZ,DifSpeed,DifPWM,Angle
        HAL_UART_Transmit(&huart3, (uint8_t *)display_buf, (uint16_t)len, 100);

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

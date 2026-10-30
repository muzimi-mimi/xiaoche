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
#include "car.h"
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

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

/* 本地起立中止保护窗口(ms)：ErectTime 超过它仍未进入平衡就判"起立失败"，
 * 只供 main.c 的本地分支使用，所以定义在这里而不是 tim3_pid.c。 */
#define ERECT_ABORT_GUARD_MS 300

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
 * 硬件平台：STM32F103C8T6 @72MHz / MPU6050(模拟 I2C: PB3,PB4) / TB6612 + 双路电机
 *       OLED(模拟 I2C: PB8,PB9) / USART3 蓝牙串口(115200) / CCD 模拟量(ADC1_IN4) / PA5 按键输入
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
 * 约 23ms，蓝牙 115200 波特发一帧(7 通道约 55 字节)约 4.8ms，最坏一圈主循环约 28ms，
 * 任何放进主循环的活都必须能容忍几十毫秒的延迟。
 * ========================================================================== */

volatile uint8_t CarState = ST_IDLE;



uint32_t hcount = 0, Count1 = 0;  /* TIM3 中断节拍分频计数(10ms/50ms 两种节拍)，定义在此、供 tim3_pid.c 使用 */

/* CCD 采样分频：每拍 +1，数到 CCD_Div 才采一帧
 * 实际周期 = CCD_Div x TIM3 周期(10ms)，与中断优先级无关。 */
uint16_t CCD_count = 0;
char display_buf[128];             /* 串口 [plot] 帧的格式化缓冲区，主循环里复用 */

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




float Yaw = 0.0f;                   /* 偏航角(度)：左转为正、右转为负 */
float YawRate = 0.0f;               /* 偏航角速度(°/s)：由 GZ 去零偏得到 */
float YawBias = YAW_BIAS_DPS;       /* 运行期 Z 轴零偏(°/s)：上电取标定值，ZUPT 在线更新 */
float PitchBiasDps = 0.0f;          /* 运行期 X 轴(俯仰)零偏(°/s)：由 Angle_Realign() 现场标定。
                                     * 没有上电初值 —— 俯仰零偏每次上电都不同，固定常量没有意义，
                                     * 必须现场测。0 = 不补偿 = 与旧固件数值等价。
                                     * 为什么不给 YAW_BIAS_DPS 那样的常量：Z 轴有出厂标定值可用，
                                     * X 轴从来没有，这也是它一直漂 3° 的原因，详见 tim3_pid.c
                                     * 的 PITCH_BIAS_ENABLE 注释。 */
float YawRatePrev = 0.0f;           /* 上一拍偏航角速度(°/s)：梯形积分用 */
float YawRateEnc = 0.0f;            /* 编码器几何推的偏航角速度(°/s)：无零偏，仅作参考 */
uint16_t ZuptCnt = 0;        /* ZUPT 判定窗口内的样本计数 */
float    ZuptSum = 0.0f;     /* ZUPT 窗口内角速度残差之和(°/s) */
float    ZuptSq  = 0.0f;     /* ZUPT 窗口内角速度残差平方和 */
int16_t LeftPWM, RightPWM;			// 左 PWM、右 PWM
int16_t AvePWM, DifPWM;				// 平衡 PWM、差速 PWM
volatile int16_t TestPWM = 0;		// 开环测试 PWM：仅在 ST_IDLE 生效，0=关闭；由 [slider,TestPWM,值] 写入（见 car.h）
volatile int16_t InnerLockMode = 1;	// 内轮强制不转(方案三)：0=关 1=只钳弱反转段 2=内轮钳0；[slider,InnerLock,值] 在线切
									// 默认 0：模式2 在直角转弯里会破坏 (L+R)/2==AvePWM，实测摔车，见 Ccd_Frame.h 的 INNER_LOCK_MAX_AVE
float DifSpeedFilter = 0.0f;		// 转向角速度的一阶低通滤波值，抑制编码器量化噪声
float TurnTargetCmd  = 0.0f;		// 转向目标命令值：摇杆/循迹/直角各支路都写这里（期望值）
float TurnTargetRamp = 0.0f;		// 转向目标斜坡值：每 50ms 向 Cmd 限速逼近，实际喂给 TurnPID.Target
float SpeedTargetCmd  = 0.0f;		// 前进速度目标命令值(转/秒)：循迹那一支写这里
float SpeedTargetRamp = 0.0f;		// 斜坡后的前进速度：真正写进 SpeedPID.Target




volatile uint8_t TrackMode    = 0;  /* 0 = 摇杆转向，1 = CCD 循迹；'T'/'t' 或 PA5 按键切换 */
volatile uint8_t TrackLostCnt = 0;  /* 连续丢线帧数 */
volatile uint8_t TrackLineSeen = 0; /* 存在性：本帧画面里有没有黑线（与中线几何是否有效无关） */
volatile uint8_t darkCnt = 0;       /* 本帧可信区间([5,123))内的黑点数：>=TRACK_SEEN_MIN 即判"线还在画面里"。
                                     * 它是 TrackLineSeen 的输入，提成全局只为上报遥测，
                                     * 用来区分"真没线"和"有黑但几何校验没过"。 */
uint8_t TrackUnseenCnt = 0; /* 连续没见到线的帧数，与 TrackLineSeen 配合做丢线超时 */
int16_t TrackErrPrev = 0;    /* 上一帧(去极值后)的中线偏差，用来算偏差变化量做前转补偿 */

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

uint16_t ErectTime = 0;			/* 本次 ERECT 已经跑了多少 ms，每 10ms 加一次；也用于 LED 闪烁 */
float LeftSpeed, RightSpeed;		/* 左/右轮速度（转/秒） */
float AveSpeed, DifSpeed;			/* 平均速度、差速 */

float G = 0.00;						/* 角度计安装角的标定偏置(度)：车体静止时读到的倾斜角不是零，用 slider G 在线改 */

float BatVoltage = 0.0f;            /* 电池电压(V)：8 次平均 + IIR 平滑后的显示值 */


/* ---------- 三个 PID 的结构体：定义时直接给成员赋初值 ----------
 * 注意 PID_Update() 的两个行为（见 pid.c）：
 *   1) Ki==0 时积分项被强制清零
 *   2) 微分项用的是 (Actual - Actual1)，不是 (Error - Error1)，
 *      所以 Target 突变不会产生微分冲击 */
PID_t AnglePID =  					// 角度环：输入 Angle，输出 AvePWM（直立控制）
{
    .Kp = 14.6,						// 比例系数
    .Ki = 0.06,						// 积分系数
    .Kd = 10.0,						// 微分系数

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





/* ==========================================================================
 * ===== 以下三个函数只被主循环调用（慢路径，容忍几十毫秒延迟）=====
 * ========================================================================== */




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
    /* 先清零计数器 + 清掉 UG 产生的 UIF，再开中断。
     *
     * 原因：上一步 MX_TIM3_Init() 的注释说"确保开中断之前计数器是干净的"，
     * 但真正去做这事的是 TIM_Base_SetConfig()，它会置一次 TIMx->EGR = TIM_EGR_UG
     * 把计数器归零，顺带把 UIF 置起来；而 HAL_TIM_Base_Start_IT() 只开 UIE，不清标志。
     * 如果带着 UIE 开中断，就会立刻进一次中断，那时 AnglePID 还没初始化。
     * 这一步之后 ST_IDLE 分支只写 PWM=0，不会有任何输出，所以前面是安全的；
     * 而且不能再调一次 HAL 的初始化接口，因为 HAL_TIM_Base_Init 时状态已经是 BUSY。
     * 所以直接写 CNT 寄存器 + 显式清标志，等价于"开中断前确实没有挂起的中断"。 */
    __HAL_TIM_SET_COUNTER(&htim3, 0);
    __HAL_TIM_CLEAR_FLAG(&htim3, TIM_FLAG_UPDATE);
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
//	TB6612_setPWM(1,-50);
//	TB6612_setPWM(2,-50);

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
        len = sprintf(display_buf, "[plot:%f,%f,\t%d,%d,\t%d,%d,\t%f,%f,%.6f,%.6f,%d\n]",
TurnPID.Target,TurnPID.Actual1,LeftPWM,RightPWM,DifPWM,AvePWM,Angle,Yaw,RightSpeed,LeftSpeed,GX);//GX,GZ,%dGZ,Yaw,DifSpeed,DifPWM,Angle
//        len = sprintf(display_buf, "[plot:%f,%f,%f,%.2f,%d,%d,%d,%d,%d,%d,%d,%d\n]",AveSpeed, SpeedPID.Target, SpeedPID.Out, Angle,
//darkCnt, TrackLineSeen, CCD_Lost, CCD_Width, CCD_Zhongzhi,LeftPWM,RightPWM,AvePWM);//,TurnPID.Target,TurnPID.Actual1,DifPWM,AngleGX,GZ,%dGZ,DifSpeed,DifPWM,Angle
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

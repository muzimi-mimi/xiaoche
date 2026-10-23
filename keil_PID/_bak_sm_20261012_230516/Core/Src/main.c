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
volatile uint8_t runflag = 1;
uint32_t hcount = 0, Count1 = 0;
static uint8_t ReviveCount = 0;   // 自动复活计数
char display_buf[128];
uint32_t Rx_buf[300];

//#define RX_BUF_SIZE  128
//char BlueSerial_RxPacket[RX_BUF_SIZE];   // 接收缓冲�??
//volatile uint8_t BlueSerial_RxFlag = 0;     // 帧完成标�??
//static uint8_t RxState = 0;                 // 状�?�机状�??
//static uint16_t pRxPacket = 0;              // 当前缓冲区索�??


int16_t AX, AY, AZ, GX, GY, GZ;
volatile uint8_t TimerErrorFlag;
volatile uint16_t TimerCount;

float AngleAcc;
float AngleGyro;
float Angle;
int16_t LeftPWM, RightPWM;			//左PWM，右PWM
int16_t AvePWM, DifPWM;				//平均PWM，差分PWM
int16_t DifPWMTarget = 0;			//转向环输出目标�??
float DifSpeedFilter = 0.0f;		//转向速度滤波�?
#define TURN_FF  20.0f						/* 转向差�?�前馈：跨越电机/静摩擦死区，先把轮子推活(15~30可调) */
/* ---------- 自起�?(Self-Erect)参数 ---------- */
#define ERECT_PWM        100		/* 甩轮PWM(0~100)：起不来找大；太猛会甩过头�?�电机发�? */
#define ERECT_START_ANG  55.0f	/* 平衡中�?�角超过此�?? �? 判定摔�?�，进入自起�? */
#define ERECT_DONE_ANG   30.0f	/* 甩回到此角度以内 �? 交回平衡�? */
#define ERECT_DONE_ANG_BACK 45.0f	/* 后�?�方向：后侧更难抬，到这个角度就交回平衡环接�?�? */
#define ERECT_TIMEOUT_MS 2000	/* 连续甩超过这个时间还没起�? �? 停机保护(轮子离地/被卡�?) */
uint16_t ErectTime = 0;			/* 自起立计�?(ms) */
#define ERECT_DIR        (1)		/* 甩轮方向�?1=与平衡环同向(默认)�?-1=反向(原地转圈/磨地起不来时�? -1) */
#define ERECT_PULSE_MS   0			/* 脉冲(�?)模式：每周期只�?�电这么�?(�?150~200)�?0=持续�? */
#define ERECT_PERIOD_MS  500		/* 脉冲周期 ms */
static uint16_t Count2 = 0;			//转向�?10ms计数
float LeftSpeed, RightSpeed;		//左�?�度，右速度
float AveSpeed, DifSpeed;			//平均速度，差分�?�度

float G = 0.00;

/*定义PID结构体变�??*/
PID_t AnglePID =  					//角度环PID结构体变量，定义的时候同时给部分成员赋初�??
{
    .Kp = 16.9,						//比例项权�??
    .Ki = 0.06,						//积分项权�??
    .Kd = 30.4,						//微分项权�??

    .OutMax = 80,					//输出限幅的最大�??
    .OutMin = -80,					//输出限幅的最小�??
	
	.OutOffset = 0,					//输出偏移
	
	.ErrorIntMax = 600,				//误差积分的最大�??
	.ErrorIntMin = -600,			//误差积分的最小�??

};
PID_t SpeedPID =  					//角度环PID结构体变量，定义的时候同时给部分成员赋初�?
{
    .Kp = 2.6,						//比例项权�?
    .Ki = 0.21,						//积分项权�?
    .Kd = 0,						//微分项权�?

    .OutMax = 10,					//输出限幅的最大�??
    .OutMin = -10,					//输出限幅的最小�??
	
	.ErrorIntMax = 150,				//误差积分的最大�??
	.ErrorIntMin = -150,			//误差积分的最小�??

};
PID_t TurnPID =  					//转向环PID结构体变量，定义的时候同时给部分成员赋初�?
{
    .Kp = 5.9,						//比例项权�?
    .Ki = 0,						//积分项权�?
    .Kd = 0,						//微分项权�?

    .OutMax = 30,					//输出限幅的最大�??
    .OutMin = -30,					//输出限幅的最小�??
	
	.ErrorIntMax = 20,				//误差积分的最大�??
	.ErrorIntMin = -20,				//误差积分的最小�??

};

void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{
    if (htim != &htim3)
    {
        return;
    }

    hcount++;
    __HAL_TIM_CLEAR_IT(&htim3, TIM_IT_UPDATE);

    if (hcount >= 10)
    {
        hcount = 0;
        MPU6050_GetData(&AX, &AY, &AZ, &GX, &GY, &GZ);
        /* �?螺仪Y轴零漂，按实际硬件调�? */
        GX += 10;

        /* 加�?�度计计算得到的角度 */
        AngleAcc = -atan2(AY, AZ) / 3.14159 * 180 + G;

        /* 互补滤波 */
        AngleGyro = Angle - GX / 32768.0 * 2000 * 0.01;
        float Alpha = 0.001f;
        Angle = Alpha * AngleAcc + (1 - Alpha) * AngleGyro;

        if (runflag)					//RunFlag�?0时，启动PID程序
        {
            /*角度环PID控制*/
            AnglePID.Actual = Angle;	//角度环实际�?�为Angle
            PID_Update(&AnglePID);		//调用封装好的函数，一步完成PID计算和更�?
            AvePWM = -AnglePID.Out;		//角度环的输出值给到电机平均PWM，用于控制前后行�?

            /*控制量转�?*/
            LeftPWM = AvePWM + DifPWM / 2;		//由平均PWM和差分PWM计算得到左轮PWM
            RightPWM = AvePWM - DifPWM / 2;		//由平均PWM和差分PWM计算得到右轮PWM

            /*PWM限幅*/
            /*上式计算后，LeftPWM和RightPWM可能会超出电机允许的PWM范围，此处将PWM值范围限制在-100~100之内*/
            if (LeftPWM > 80)
                LeftPWM = 80;
            else if (LeftPWM < -80)
                LeftPWM = -80;
            if (RightPWM > 80)
                RightPWM = 80;
            else if (RightPWM < -80)
                RightPWM = -80;

            /*PWM输出给电�?*/
            TB6612_setPWM(1, LeftPWM);		//LeftPWM输出给左轮电�?
            TB6612_setPWM(2, RightPWM);		//RightPWM输出给右轮电�?
        }



//        else
//        {
//            /* 未在平衡(runflag=0)：进入自起立流程 */
//            /* ===== 自起�? Self-Erect =====
//               摔�??(runflag=0)时，两轮同向给大PWM，靠电机反扭矩把车身甩回竖直�?
//               方向与平衡环�?致：Angle>0(�?前�??)就往前甩，Angle<0 �?后甩�? */
//                        float erectDoneAng = (Angle > 0.0f) ? ERECT_DONE_ANG : ERECT_DONE_ANG_BACK;
//            if (fabsf(Angle) > erectDoneAng && ErectTime < ERECT_TIMEOUT_MS)
//            {
//                int16_t swing = (Angle > 0.0f) ? ERECT_PWM : -ERECT_PWM;
//                if (ERECT_DIR < 0) swing = -swing;		/* 方向�?键取�? */
//                if (ERECT_PULSE_MS > 0 && (ErectTime % ERECT_PERIOD_MS) >= ERECT_PULSE_MS)
//                    swing = 0;							/* 脉冲(�?)模式：到点断电，靠惯性甩上去 */
//                /* 防自转：起立过程不响应摇杆，只把左右轮�?�差拉回 0 */
//                TurnPID.Target = 0.0f;
//                TurnPID.Actual = DifSpeed;
//                PID_Update(&TurnPID);
//                DifPWM = (int16_t)TurnPID.Out;						/* 起立过程只做差�?�修�? */
//                LeftPWM  = swing + DifPWM / 2;
//                RightPWM = swing - DifPWM / 2;
//                TB6612_setPWM(1, LeftPWM);
//                TB6612_setPWM(2, RightPWM);
//                ErectTime += 10;				/* 本段�?10ms进一�? */
//            }
//            else if (fabsf(Angle) <= erectDoneAng)
//            {
//                /* 已甩进可平衡范围 �? 交回平衡�?(PID清零，避免�?�度环积分残留窜�?) */
//                PID_Init(&AnglePID);
//                PID_Init(&SpeedPID);
//                PID_Init(&TurnPID);
//                AnglePID.Actual  = Angle;
//                AnglePID.Actual1 = Angle;		/* 防微分项第一次冲�? */
//                AnglePID.Error0  = AnglePID.Target - AnglePID.Actual;
//                AnglePID.Error1  = AnglePID.Error0;
//                DifSpeedFilter = DifSpeed;
//                ErectTime = 0;
//                runflag = 1;
//            }
//            else
//            {
//                /* 超时仍起不来(轮子离地/打滑/被卡�?)：停机保护电�? */
//                TB6612_setPWM(1, 0);
//                TB6612_setPWM(2, 0);
//            }

//        }
    }

    Count1 ++;				//计次自增

    if (Count1 >= 50)		//如果计次50次，则if成立，即if每隔50ms进一�?
    {
        Count1 = 0;			//计次清零，便于下次计�?

        /*获取编码器的计次值增量，并计算电机旋转�?�度*/
        /*Encoder_Get函数，可以获取两次读取编码器的计次�?�增�?*/
        /*编码器磁铁旋转一圈，计次增量�?44，编码器读取间隔�?50ms�?0.05s�?*/
        /*因此磁铁旋转速度 = 计次增量 / 44 / 0.05，单位是转每�?*/
        /*平衡车使用的电机带有减�?�箱，减速比�?30*/
        /*因此电机输出轴旋转�?�度 = 磁铁旋转速度 / 30，单位是转每�?*/
        LeftSpeed = ReadSpeed(&htim2) / 44.0 / 0.05 / 30;
        RightSpeed = -ReadSpeed(&htim4) / 44.0 / 0.05 / 30;

        /*信号量转�?*/
			AveSpeed = (LeftSpeed + RightSpeed) / 2.0;	//由左轮�?�度和右轮�?�度计算得到平均速度
			DifSpeed = LeftSpeed - RightSpeed;			//由左轮�?�度和右轮�?�度计算得到差分速度
			
			/*执行PID调控程序*/
			if (runflag)					//RunFlag�?0时，启动PID程序
			{
				/*速度环PID控制*/
				SpeedPID.Actual = AveSpeed;			//速度环实际�?�为AveSpeed
				PID_Update(&SpeedPID);				//调用封装好的函数，一步完成PID计算和更�?
				AnglePID.Target = SpeedPID.Out;		//速度环的输出值给到角度环的目标�?�，构成串级PID
				
				/*转向环PID控制*/
				DifSpeedFilter += 0.5f * (DifSpeed - DifSpeedFilter);	/* 转向速度�?阶低通：抑制编码器噪�?/抖动，系�? 0.5 可调(0.3更平�?/0.7更跟�?) */
				TurnPID.Actual = DifSpeedFilter;			//转向环实际�?�为DifSpeed
				PID_Update(&TurnPID);				//调用封装好的函数，一步完成PID计算和更�?
				DifPWM = (int16_t)(TurnPID.Out + TURN_FF * TurnPID.Target);	/* 转向环输�? + 死区前馈 */
				if (DifPWM > 50) DifPWM = 50; else if (DifPWM < -50) DifPWM = -50;	/* 限幅±25/轮，避免前馈+反馈叠加过大 */				

        }

    }


    /* 倾角保护：平衡中倒出 ERECT_START_ANG �? 交给自起立流程接�? */
    if (runflag && fabsf(Angle) > ERECT_START_ANG)
    {
        runflag = 0;
        ErectTime = 0;
    }



    if (__HAL_TIM_GET_FLAG(&htim3, TIM_IT_UPDATE) != RESET)
    {

        if (__HAL_TIM_GET_FLAG(&htim3, TIM_IT_UPDATE) == SET)
        {
            TimerErrorFlag = 1;  // 标记错误

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
  /* USER CODE BEGIN 2 */
    HAL_Delay(200);   // 等待 OLED 上电稳定，避免冷启动不显�?
    OLED_Init();
    OLED_Clear();

    MPU6050_Init();
    /* 上电用加速度计把倾角对准(静止时可�?)：否则陀螺积分要十几秒才收敛，躺倒上电会误判 */
    {
        int k;
        for (k = 0; k < 30; k++)			/* 30 × 10ms = 300ms */
        {
            MPU6050_GetData(&AX, &AY, &AZ, &GX, &GY, &GZ);
            Angle = -atan2(AY, AZ) / 3.14159 * 180 + G;
            HAL_Delay(10);
        }
    }
    HAL_TIM_PWM_Start(&htim1, TIM_CHANNEL_1);
    HAL_TIM_PWM_Start(&htim1, TIM_CHANNEL_4);
    HAL_TIM_Encoder_Start(&htim2, TIM_CHANNEL_ALL);
    HAL_TIM_Encoder_Start(&htim4, TIM_CHANNEL_ALL);
    BlueSerial_Init();   // 初始化蓝牙串口接�?
    HAL_TIM_Base_Start(&htim3);
    uint8_t ID;
    ID = MPU6050_GetID();
    OLED_Update();
    MX_TIM3_Init();
    HAL_TIM_Base_Start_IT(&htim3);   /* 1ms update interrupt */
    PID_Init(&AnglePID);
    PID_Init(&SpeedPID);
    PID_Init(&TurnPID);

    runflag = 1;

    // 预置角度环误差，避免微分项冲�?
    AnglePID.Actual = Angle;
    AnglePID.Actual1 = Angle;   //同样预置上次实际值，防止微分项第�?次冲�?
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

        HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, runflag ? GPIO_PIN_RESET : GPIO_PIN_SET);

        if (runflag == 0)		//如果RunFlag�?0
        {
            PID_Init(&AnglePID);//启动程序时给PID初始化，清除之前可能遗留的参�?
            PID_Init(&SpeedPID);
//				runflag= 1;		//则RunFlag�?1
        }


        OLED_Clear();
        OLED_Printf(0, 0, OLED_6X8, "  Angle");						//OLED左侧显示角度环参�??
        OLED_Printf(0, 8, OLED_6X8, "KP:%05.2f//%05.2f//%05.2f ", AnglePID.Kp, SpeedPID.Kp, TurnPID.Kp);		//角度环Kp
        OLED_Printf(0, 16, OLED_6X8, "KI:%05.2f//%05.2f//%05.2f", AnglePID.Ki, SpeedPID.Ki, TurnPID.Ki);		//角度环Ki
        OLED_Printf(0, 24, OLED_6X8, "KD:%05.2f//%05.2f//%05.2f", AnglePID.Kd, SpeedPID.Kd, TurnPID.Kd);		//角度环Kd
        OLED_Printf(0, 32, OLED_6X8, "T:%+05.1f", AnglePID.Target);	//角度环目标�??
        OLED_Printf(0, 40, OLED_6X8, "Angle:%+05.1f", Angle);			//角度环实际�??
        OLED_Printf(0, 48, OLED_6X8, "O:%+05.0f", AnglePID.Out);	//角度环输出�??
        OLED_Printf(0, 56, OLED_6X8, "GX:%+05d", GX);				//显示GY，便于校准陀螺仪零漂
        OLED_Printf(70, 40, OLED_6X8, "G:%+02.2f", G);
        OLED_Printf(70, 48, OLED_6X8, "S:%+02.2f", RightSpeed);
        OLED_Printf(70, 56, OLED_6X8, "S:%+02.2f", LeftSpeed);
        OLED_Update();


        for (i = 0; i < 2; i++)
        {
            if (BlueSerial_RxFlag[i] == 1)
            {
                char *Tag = strtok(BlueSerial_RxPacket[i], ",");	//提取数据1，定义为标签Tag

                if (Tag != NULL)
                {
                    if (strcmp(Tag, "key") == 0)				//Tag为key，收到按键数据包
                    {
                        char *Name = strtok(NULL, ",");			//提取数据2，定义为按键名称
                        char *Action = strtok(NULL, ",");		//提取数据3，定义为按键动作

                        /*此处可执行按键操作，目前程序暂时没用到按�??*/
                    }
                    else if (strcmp(Tag, "slider") == 0)	//Tag为slider/alider，收到滑杆数据包
                    {
                        char *Name = strtok(NULL, ",");			//提取数据2，定义为滑杆名称
                        char *Value = strtok(NULL, ",");		//提取数据3，定义为滑杆�??

                        /*执行滑杆操作*/
                        if (strcmp(Name, "AngleKp") == 0)	//如果滑杆名称是AngleKp
                        {
                            AnglePID.Kp = atof(Value);		//则把滑杆值赋值给角度环Kp
                        }
                        else if (strcmp(Name, "AngleKi") == 0)	//如果滑杆名称是AngleKi
                        {
                            AnglePID.Ki = atof(Value);		//则把滑杆值赋值给角度环Ki
                        }
                        else if (strcmp(Name, "AngleKd") == 0)	//如果滑杆名称是AngleKd
                        {
                            AnglePID.Kd = atof(Value);		//则把滑杆值赋值给角度环Kd
                        }
                        else if (strcmp(Name, "G") == 0)	//如果滑杆名称是AngleKd
                        {
                            G = atof(Value);		//则把滑杆值赋值给角度环Kd
                        }
                        else if (strcmp(Name, "SpeedKp") == 0)		//如果滑杆名称是SpeedKp
                        {
                            SpeedPID.Kp = atof(Value);				//则把滑杆值赋值给速度环Kp
                        }
                        else if (strcmp(Name, "SpeedKi") == 0)		//如果滑杆名称是SpeedKi
                        {
                            SpeedPID.Ki = atof(Value);				//则把滑杆值赋值给速度环Ki
                        }
                        else if (strcmp(Name, "SpeedKd") == 0)		//如果滑杆名称是SpeedKd
                        {
                            SpeedPID.Kd = atof(Value);				//则把滑杆值赋值给速度环Kd
                        }
                        else if (strcmp(Name, "TurnKp") == 0)		//如果滑杆名称是TurnKp
                        {
                            TurnPID.Kp = atof(Value);				//则把滑杆值赋值给转向环Kp
                        }
                        else if (strcmp(Name, "TurnKi") == 0)		//如果滑杆名称是TurnKi
                        {
                            TurnPID.Ki = atof(Value);				//则把滑杆值赋值给转向环Ki
                        }
                        else if (strcmp(Name, "TurnKd") == 0)		//如果滑杆名称是TurnKd
                        {
                            TurnPID.Kd = atof(Value);				//则把滑杆值赋值给转向环Kd
                        }

                    }
                    else if (strcmp(Tag, "joystick") == 0)		//Tag为joystick，收到摇杆数据包
                    {
                        int8_t LH = atoi(strtok(NULL, ","));		//提取数据2，定义为摇杆值LH
                        int8_t LV = atoi(strtok(NULL, ","));		//提取数据3，定义为摇杆值LV
                        int8_t RH = atoi(strtok(NULL, ","));		//提取数据4，定义为摇杆值RH
                        int8_t RV = atoi(strtok(NULL, ","));		//提取数据5，定义为摇杆值RV

                        /*执行摇杆操作*/
                        /* 摇杆死区，避免中位抖�? */
                        if (LV > -5 && LV < 5) { LV = 0; }
                        if (RH > -5 && RH < 5) { RH = 0; }

                        SpeedPID.Target = LV / 50.0;		//摇杆值LV缩放后，控制速度环目标�?�，前后行进控制
                        TurnPID.Target   = -RH / 50.0;				//摇杆值RH缩放后，控制转向环目标�?�，左右转弯控制
                        /* 只打转向、不打前进时，自动给�?点前进�?�度：原地转要两轮反搓地面，静摩�?+横向刮擦扭矩不够就会卡死 */
                        if (TurnPID.Target != 0.0f && LV == 0)
                            SpeedPID.Target = 0.20f;		/* 前进蠕动量，0.15~0.4 可调 */

                    }
                }

                BlueSerial_RxFlag[i] = 0;				//处理完成后，标志位置0，允许接收下�??个数据包
            }
        }

        len = sprintf(display_buf, "[plot,%f,%f,%d]",TurnPID.Target,DifSpeed,DifPWM);//AnglePID.Target,, Angle, SpeedPID.Target
        HAL_UART_Transmit(&huart3, (uint8_t *)display_buf, (uint16_t)len, 100);
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

#ifdef  USE_FULL_ASSERT
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

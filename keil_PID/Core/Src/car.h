#ifndef __CAR_H
#define __CAR_H

/* ==========================================================================
 * car.h —— 整车共享层：公共包含、运行状态、全局变量 extern、跨模块接口。
 *
 * ★ 参数宏一律压在各自的 .c 文件顶部，这里一个参数宏都不留。要调参数就开
 *   对应的那个 .c，从头到尾只改一个文件：
 *     tim3_pid.c            时基 / 编码器测速 / 姿态与偏航 / 三环 / 起立
 *     Ccd_Frame.c           线存在性 / 循迹 / 直角与 T 字判定
 *     main.c                PA5 按键消抖 / 起立中放弃门槛
 *     OLED_RenderStatus.c   电池电压检测
 *
 * 本文件只留两类东西：
 *   1) 被 2 个以上 .c 在代码里同时读的状态常量（ST_* / CORNER_*）——
 *      宏不能跨 .c，只放头文件；
 *   2) 全局变量的 extern，以及四个模块接口的汇总 include。
 * ==========================================================================*/

#include "main.h"
#include "adc.h"
#include "tim.h"
#include "usart.h"
#include "gpio.h"
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

/* ===== 直角转弯的两个状态 =====
 * 这两个状态被 tim3_pid.c(10ms 计时)、Ccd_Frame.c(状态机)、main.c(复位) 共用，
 * 属于共享层；转弯的其余参数在 Ccd_Frame.h。 */
#define CORNER_LINE        0u       /* 平时循迹 */
#define CORNER_PIVOT       1u       /* 转弯中：定速旋转，等 CCD 抓到新线（或超时保底） */

/* ---------- 全局变量：定义在 main.c ---------- */
extern volatile uint8_t CarState;
extern uint32_t hcount, Count1;
extern uint16_t CCD_count;
extern char display_buf[128];
extern int16_t AX, AY, AZ, GX, GY, GZ;
extern volatile uint8_t TimerErrorFlag;
extern volatile uint16_t TimerCount;
extern float AngleAcc;
extern float AngleGyro;
extern float Angle;
extern float Yaw;
extern float YawRate;
extern float YawBias;
extern float PitchBiasDps;      /* X 轴(俯仰)零偏(°/s)：Angle_Realign() 标定，定义在 main.c。
                                 * 与 YawBias 是一对：Z 轴有常量+ZUPT，X 轴只有现场标定。 */
extern float YawRatePrev;
extern float YawRateEnc;
extern uint16_t ZuptCnt;
extern float    ZuptSum;
extern float    ZuptSq;
extern int16_t LeftPWM, RightPWM;
extern int16_t AvePWM, DifPWM;
/* ★ TestPWM：开环 PWM 测试量，用来在台架上量"电机死区 + 正反向对称性"。
 *
 *   谁写它：蓝牙 [slider,TestPWM,值]（Blue_ProcessPackets.c）
 *   谁用它：只有 tim3_pid.c 的 ST_IDLE 分支，其余状态一次都不读
 *   谁清它：StartErect() / StopCar() —— 这是"只在停车状态生效"的硬保证
 *
 *   0 = 关闭（上电默认）。超越 ±100 的部分由 ST_IDLE 分支裁掉，不在这里裁，
 *   这样滑块回读到的就是用户原样输入的数。 */
extern volatile int16_t TestPWM;

/* ★ InnerLockMode：内轮强制不转（方案三）的模式开关，只在 CORNER_PIVOT 期间生效。
 *
 *   谁写它：蓝牙 [slider,InnerLock,值]（Blue_ProcessPackets.c），运行时切，不用重编
 *   谁用它：只有 tim3_pid.c 的执行器分发（ST_BALANCE 分支）
 *
 *   0 = 关闭（上电默认）。内轮照常反转，是真正的原地转，车心不动。
 *   1 = 模式B。内轮指令落在 [-INNER_LOCK_DZ, 0) 的"弱反转段"时抬到 0，
 *       更深的反转原样保留。差速几乎不变，只是内轮不再卡在死区里拖。
 *   2 = 模式A。内轮一律 >= 0，变成单轮驱动。
 *       好处：绕内轮接触点转，转角完全可重复。
 *       代价：车心随转弯平移约 0.707 倍轮距（按 100~150mm 轮距 = 70~106mm），
 *             可能转完就把线甩出视场；且整车倒退时钳 0 会造成一次明显前冲。
 *
 *   台架实测依据（[slider,TestPWM,±20/±10] 日志）：两轮正反转对称到 3%，
 *     speed ≈ 0.060*PWM - 0.17，死区只有 2~3 个数。
 *   所以"内轮反转没劲"不是执行器故障，方案三是几何选择而不是故障规避。 */
extern volatile int16_t InnerLockMode;
extern float DifSpeedFilter;
extern float TurnTargetCmd;
extern float TurnTargetRamp;
extern float SpeedTargetCmd;
extern float SpeedTargetRamp;
extern volatile uint8_t TrackMode;
extern volatile uint8_t TrackLostCnt;
extern volatile uint8_t TrackLineSeen;
extern volatile uint8_t darkCnt;
extern uint8_t TrackUnseenCnt;
extern int16_t TrackErrPrev;
extern volatile uint8_t CornerState;
extern volatile int8_t  CornerDir;
extern volatile float   YawTurned;
extern float    YawPrev;
extern uint16_t PivotTicks;
extern uint8_t  CornerSeen;
extern uint8_t  TSeen;
extern uint8_t  PivotOk;
extern uint16_t ErectTime;
extern float LeftSpeed, RightSpeed;
extern float AveSpeed, DifSpeed;
extern float G;
extern float BatVoltage;
extern volatile uint8_t KeyFlag;
extern PID_t AnglePID;
extern PID_t SpeedPID;
extern PID_t TurnPID;

/* ---------- 各模块的参数宏与接口（按模块归档，统一在这里汇总）---------- */
#include "tim3_pid.h"            /* 时基 / 测速 / 偏航 / 三个环 / 起立 */
#include "Ccd_Frame.h"           /* 循迹 / 直角与 T 字 / 转弯参数 */
#include "Blue_ProcessPackets.h" /* 蓝牙下行协议 */
#include "OLED_RenderStatus.h"   /* 状态屏 / 电池检测 */

#endif /* __CAR_H */

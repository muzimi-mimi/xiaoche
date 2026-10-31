/* ============================================================================
 * tim3_pid.c —— TIM3 中断实时控制：10ms 姿态/平衡、50ms 速度/转向、
 *               起立/停车/PID 复位。从 main.c 拆出，逻辑未改。
 * ==========================================================================*/
#include "car.h"

/* ==========================================================================
 * ★ 本模块的参数宏全部集中在下面这一段 —— 调参数只改这里。
 *   每个宏的原理、实测依据、为什么取这个值，都写在它自己上面。
 *   只有 YAW_BIAS_DPS 例外：它在 tim3_pid.h（main.c 要给全局 YawBias 赋初值）。
 * ==========================================================================*/

/* ===== 时钟基准：TIM3 中断周期 x 分频计数 = 实际周期 =====
 *  必须与 tim.c 里 TIM3 的 Period 保持一致，否则"多少拍一次"全是错的。
 *  两个环都按"10ms 的整数倍"推理，改 TIM3 时这里要同步：
 *     TIM3 = 1ms  (Period = 1000-1)   ->  TICK_10MS = 10, TICK_50MS = 50
 *     TIM3 = 10ms (Period = 10000-1)  ->  TICK_10MS = 1,  TICK_50MS = 5   <- 当前
 *  10ms 一拍的理由：get_CCD() 一帧约 0.7ms，1ms 拍会被 CCD 吃掉 70% 的余量，
 *  容易与中断撞车，故拉长到 10ms 并把 CCD 放在拍末。 */
#define TICK_10MS   1
#define TICK_50MS   5

/* ===== 编码器脉冲差值 -> 轮速(转/秒)：44 线 x 30 减速比，50ms 采样 =====
 *   转/秒 = 脉冲数 / 44 / 0.05 / 30 = 脉冲数 x (1/66)
 * 原来写成 /44.0/0.05/30 是 double 三连除；折成一次 float 乘法，
 * 数值等价(1/66 的舍入远小于 1 个脉冲的分辨率)，省软浮点的来回换算。 */
#define ENC_TO_RPS  (1.0f / (44.0f * 0.05f * 30.0f))

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
/* YAW_BIAS_DPS 不在这里：它在 tim3_pid.h（main.c 要用它给全局 YawBias 赋上电初值）。 */
#define YAW_DEADZONE_DPS  1.5f      /* 偏航死区(°/s)：压掉静止时的零偏漂移 */
#define YAW_DT            0.01f     /* 积分步长(s)：每 10ms 一拍 */
#define YAW_WRAP          1         /* 1=归一到 ±180°；0=不归一、连续累加 */

/* ---- 俯仰轴(X 轴)陀螺零偏补偿 ---------------------------------------------
 * 病根：X 轴和 Z 轴是同一颗 MPU6050，零偏量级也一样，但 Z 轴有 YawBias+ZUPT
 *   在线学习，X 轴此前**一个字节都没扣** —— 原始 GX 直接进积分。
 * 为什么后果被放大 999 倍：Alpha=0.001 意味着每拍只让加速度计纠 0.1%，
 *   剩下的 99.9% 全靠陀螺积分。稳态解
 *       A∞ = Acc - 999 * b_LSB * (2000*0.01/32768) = Acc - 0.61 * b_LSB
 *   即零偏每 1 LSB(0.061°/s)，静态角度就偏 0.61°。
 *   零偏 0.25°/s(约 4 LSB) -> 静态角度偏约 2.5~3°。
 * 实测证据(2026-10-30 静止 844 拍约 38s，100% 零 PWM、两轮转速均 0.000)：
 *   Yaw  (Z 轴，已标定)   -72.68 -> -72.72   漂 0.04°
 *   Angle(X 轴，未标定)  0.0032 ->  2.914   漂 2.91° 且末尾仍在上升
 *   同一颗芯片、同一段时间、同样静止，相差 73 倍 —— 差异只在"有没有扣零偏"。
 * 为什么这个量级很要命：SpeedPID 的 OutMax/OutMin 只有 +2/-3°，
 *   也就是说角度估计自己就能漂掉速度环的全部权限，平衡点整体偏移，
 *   表现为"车总往一边缓慢加速，越跑越快"。
 * 方案：Angle_Realign() 的 30 次静止采样里顺手把 GX 也平均掉存成零偏，
 *   滤波器里减去。PitchBiasDps=0 时与原式数值等价(仅差 float 舍入)。
 * 未做：温度漂移(±0.24 (°/s)/°C)。那需要给俯仰轴补一套 ZUPT，
 *   属于第二步；先把这静态的 3° 消掉，再看残差还值不值得做。 */
#ifndef PITCH_BIAS_ENABLE
#define PITCH_BIAS_ENABLE   1       /* 1=启用俯仰零偏补偿；0=回到旧行为(零偏恒视为 0)。
                                     * 用 #ifndef 包一层，是为了能不碰源码就做 A/B：
                                     * 命令行加 -DPITCH_BIAS_ENABLE=0 即可，编译出的代码
                                     * 与改动前逐拍等价。 */
#endif
#define PITCH_BIAS_MAX_DPS  5.0f    /* 零偏可信上限(°/s)：正常 <1；超了说明对准时车在动或传感器坏了，
                                     * 此时保留旧值，不写入这个可疑值 */

/* ---- X 轴陀螺手调修剪量：全工程只允许定义这一处 ----
 * Tick10_Attitude() 读完 MPU6050 后执行 GX += PITCH_GX_TRIM，作为硬件固有偏置的手调补偿；
 * Angle_Realign() 标定零偏时，必须作用在"滤波器实际看到的那个信号"上，即同样要加这一项。
 * 踩过的坑：标定用原始 GX、滤波器用 GX+PITCH_GX_TRIM，两者差一个 PITCH_GX_TRIM。
 *   实测零偏 -12.9 LSB 被标定完整减掉后，只剩 +10 LSB(0.61°/s) 在推角度，
 *   表现就是"上电标定完成后角度照样匀速漂"，而且方向和没标定时相反。
 * 所以两处都引用这个宏，不要再写字面量 10。 */
#define PITCH_GX_TRIM   10

/* ---- 静止自校准(ZUPT)：把"上电标一次、之后永远不变"的零偏改成在线跟踪 ----
 * 为什么必须做：MPU6050 数据手册 ZRO 温度系数 ±0.24 (°/s)/°C。
 *   电机跑热 10 °C → 零偏移 ±2.4 °/s，比 YAW_BIAS_DPS 那 0.10 °/s
 *   的标定残差大 24 倍。固定零偏只在冷机成立，跑起来就废了。
 * 判据用"窗内标准差 + 均值"，不用"离旧零偏多远"：
 *   前者与零偏本身无关，零偏漂多远都判得出静止；后者会死锁
 *   （零偏漂到 2.4 °/s 而门限是 1 °/s 时，永远判不出静止，永远学不到）。
 * 双保险：还要求编码器也认为没动，防止缓慢真实转动被当成静止吸收进零偏。
 * 学习只在编码器停住时进行 → 运动中一个字节都不动，与原逻辑逐拍等价。 */
#define ZUPT_WIN        50      /* 判定窗(拍)：50 x 10ms = 0.5s */
#define ZUPT_STD_MAX    0.6f    /* 窗内标准差上限(°/s)：实测静止残差 0.03~0.09 */
#define ZUPT_MEAN_MAX   8.0f    /* 窗内均值上限(°/s)：超过说明不是静止，不学 */
#define ZUPT_SPEED_MAX  0.03f   /* 编码器门限(转/秒)：0.03 x 204mm ≈ 6mm/s，等于没动 */
#define ZUPT_LEARN      0.5f    /* 零偏跟入系数：单次误判最多带偏一半 */

/* ---- 轮速 -> 车身偏航角速度（几何，无零偏）--------------------------------
 * 差速轮速 DifSpeed 的单位是"转/秒"，不是车身转速。换算关系只有一条：
 *     两轮差 n 转/秒  ->  左右轮线速度差 = n * C        [mm/s]
 *     ->  车身转速  w = (n * C) / L                    [rad/s]
 * 所以 ENC_TO_DPS = C / L * 57.29578                     ["°/s" per 转/秒]
 *
 * 参数来源（2026-10-28）：
 *   C = 204mm   轮径 65mm 的周长，与 TRACK_SPEED 的换算注释一致
 *   L = 195.5mm 实测两轮接地点中心距
 *   交叉验证：一次回转中编码器积分出 2.897682 转差，按 L=195.5mm 折算车身
 *             转过 173.2°；若那次基准是 180°，几何误差仅 3.8%，说明 C/L 这条
 *             换算可信，编码器可以当陀螺的独立参考。
 *
 * 意义：编码器这条通路没有零偏（温度、上电漂移都不影响它），陀螺短期准但
 *       零偏会漂。两者之差就是零偏误差，见下面的 ENC_YAW_FUSE。
 *
 * 注意 ENC_YAW_SIGN：DifSpeed = TURN_FB_SIGN * (LeftSpeed - RightSpeed)，而
 *   Yaw 的符号约定是"左转为正"，两者是否一致只能看数据：历史地面日志里
 *   Actual1(=DifSpeed) 均值为正的那一段，Yaw 从 -16.74 升到 -10.01，同号，
 *   故取 +1。**改完必须用一份日志复核**：看第 9 列 YawRateEnc 与 Yaw 的实际
 *   变化方向是否同号；若反号就把本宏改成 -1。 */
#define WHEEL_CIRC_MM   204.0f   /* 轮周长(mm)：轮径 65mm */
#define TRACK_WIDTH_MM  195.5f   /* 轮距 L(mm)：两轮接地点中心距，实测 */
#define ENC_TO_DPS      (WHEEL_CIRC_MM / TRACK_WIDTH_MM * 57.29578f)  /* 1 转/秒差速 = 59.79 °/s */
#define ENC_YAW_SIGN    (-1.0f)  /* 编码器偏航方向：-1 = 与 Yaw 同号（见上面说明）
                                  * ★ 2026-10-28：TURN_FB_SIGN 由 -1 翻成 +1 后 DifSpeed 整体取反，
                                  *   本宏必须跟着取反，第 9 列 YawRateEnc 才仍然与 Yaw 同号。 */

/* ---- 编码器辅助零偏跟踪：默认关闭，先看数据再开 ------------------------
 * 0 = 只算 YawRateEnc 送到第 9 列，不碰 YawBias（零风险）
 * 1 = 打开零偏跟踪。打开前必须先确认 ENC_YAW_SIGN 的方向是对的。
 * 真正的收益取决于"温度零偏漂移有多大"：静止实测残差只有 0.03~0.09 °/s，
 * 若跑热后仍是这个量级，本项收益有限；若漂到 +-2 °/s，本项就是必需的。 */
#define ENC_YAW_FUSE    0
#define ENC_YAW_LEARN   0.02f    /* 跟入系数：比 ZUPT 的 0.5 慢 25 倍，防打滑被吃成零偏 */
#define ENC_YAW_MIN_DPS 3.0f     /* 差速信号门限(°/s)：太小时几何算不出方向 */
#define ENC_YAW_ANGLE_MAX 25.0f  /* 车身倾角门限(度)：倒下时编码器不可信 */
#define ENC_YAW_BIAS_MAX 10.0f   /* 零偏夹紧上限(°/s) */

/* ===== 转向环 / 速度环 ===== */
#define TURN_FF  18.0f						/* 转向前馈系数：目标转速直接乘它得到 DifPWM 的前馈量
                             * 没有前馈时 |TurnPID.Out| 很小时差速不够，转向环会"粘住"
                             * 历史：20 -> 10 是在 TURN_FB_SIGN 极性还反着的年代打的补丁——
                             * 那时 P 项反向加倍输出，前馈再大就饱和打滑。2026-10-25 极性修正后
                             * P 项回归阻尼，纯前馈 10 只能建立约 0.6 转/秒差速(实测标定
                             * 1 PWM ≈ 0.05 转/秒)，转弯比修正前明显慢，故 10 -> 18：
                             * 转弯时 FF 18 + 起步 P 项约 24，接近旧极性下 22 的实际驱动力。
                             * 偏肉加到 20，打滑/甩尾退到 15。 */
#define TURN_SLEW  0.2f						/* 转向目标每 50ms 最大变化量(转/秒)：
                             *   0->0.6(PIVOT_RATE) 约 3 拍(150ms)，0->1.2(循迹满偏) 约 6 拍(300ms)。
                             * 消除 TurnPID.Target 阶跃导致的 DifPWM 0->±50 突变冲击 */
#define SPEED_SLEW  0.1f					/* 前进速度目标每 50ms 最大变化量(转/秒)：0->TRACK_SPEED(0.5)
                             * 约 5 拍(250ms) 建立，反过来就是"减速到停"。
                             * 目的不是限功率，是不让 Target 在 0 和 0.5 之间硬跳：
                             * 硬跳那一拍误差瞬间变成 -0.5，把 SpeedPID 积分反向灌满，
                             * 车停稳后那份负积分得先倒干净才能再往前走 ——
                             * "停下来容易、再起步慢半拍"就是这么来的。 */
/* ★ 2026-10-28 翻符号：TB6612 两路电机通道对调(LeftPWM 改走 BIN/TIM_CH4)后，
 *   同一个 DifPWM 产生的物理转向整体取反，原来的 -1 在新接线下变成**正反馈**
 *   —— 正是下面 10-28 注释里"越转越快直到翻车"那条。故翻成 +1。
 *   同批改动：Ccd_Frame.c 的 TRACK_DIR、Blue_ProcessPackets.c 的摇杆 RH、本文件的 ENC_YAW_SIGN。 */
#define TURN_FB_SIGN  (+1)   /* 转向反馈符号：+1=不取反，-1=取反；接线/装配拧反时用
                              * 判据（很关键）：同一条通路是
                              *   Target -> DifPWM -> LeftPWM/RightPWM -> 实际转向 -> DifSpeed
                              * 要保证 Target 变大时 DifSpeed 也同向变大，否则转向环会正反馈、越转越偏。
                              * 2026-10-25 串口实测翻案：直角右转 Target=-1.0 时 DifSpeed=+1.1、
                              * 左转 Target=+1.0 时 DifSpeed=-0.9，而 Yaw 证实车确实按目标方向在转
                              * —— 反馈极性一直是反的，P 项在反向加倍输出(转向卡顿/画龙的根源)。
                              * 原注释"joystick 能正常转向就说明极性对"是误判：前馈 TURN_FF 主导方向，
                              * 极性反了车照样转，只是 P 项从阻尼变成了助燃。
                              * 2026-10-28 二次实测复现同一现象(Target=+0.9 -> DifSpeed=-1.13)：
                              *   +1 会正反馈跑飞、越转越快直到翻车，必须 -1。 */

/* ===== 自起立(Self-Erect)参数 ===== */
#define ERECT_PWM        100		/* 甩轮 PWM(0~100)：太大车轮打滑，太小甩不起来 */
#define ERECT_START_ANG  50.0f	/* 平衡中断阈值：|Angle| 超过它就判定摔倒，直接停车。
                                 * 必须大于 ERECT_DONE_ANG_BACK(45)：后仰起立收到 45° 就切
                                 * 平衡环，阈值再低(<45)会把刚起立的车立刻误判成摔车。
                                 * 2026-10-31 由 55 收紧到 50：配合大偏差快速重同步，
                                 * 摔车/提起后 Angle 1 秒内重锁真值，这条保护才真正生效。 */
#define ERECT_DONE_ANG   30.0f	/* 前倾起立：|Angle| 收到这个角度内就切平衡环 */
#define ERECT_DONE_ANG_BACK 45.0f	/* 后仰起立：抬到 45 度左右就切平衡环，防止冲过头 */
#define ERECT_TIMEOUT_MS 3000	/* 甩轮超时：3 秒还没起来就停车（电池太弱 / 卡住） */
/* ERECT_ABORT_GUARD_MS 不在这里：只有 main.c 用它（起立中按键放弃的生效门槛）。 */
#define ERECT_DIR        (1)		/* 甩轮方向：1 = 与平衡环同号(默认)，-1 = 取反(原地转圈/磨胎时用) */
#define ERECT_PULSE_MS   400			/* 脉冲模式：每个周期通电多少 ms；0 = 连续通电(一直甩) */
#define ERECT_PERIOD_MS  500		/* 脉冲周期(ms)：通电 400ms + 断开 100ms */

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
/* ==========================================================================
 * PID_ClearIntegral()：切状态时清掉上一个状态残留的积分。
 *
 * 为什么不能只写 p->ErrorInt = 0：
 *   Kd 项用的是 (Actual - Actual1)。只清积分而让 Actual1 停在旧值，下一拍
 *   微分项会把"这段时间的实际变化"当成一次瞬时跳变输出；AnglePID.Kd=30.4，
 *   这一下足以把车顶翻。所以同时用当前实测值预置 Actual1，并把 Error0/Error1
 *   对齐，让下一拍的比例/微分从"零误差"起步。
 *   Out 不用动：每次 PID_Update 都会整份重算，留着旧值不会被误用。
 *
 * 用在哪（都是"控制目标整个换掉"的时刻）：
 *   Track_Reset()   开/关循迹：前进速度来源整个换掉（摇杆 <-> 循迹）
 *   PIVOT 进入      转向目标从"跟踪中线偏差"变成"固定转速"，转向环旧积分无意义
 *   PIVOT 退出      转弯打滑时 AveSpeed 偏低，SpeedPID 积分会在弯中被灌满，
 *                   一出弯恢复抓地就往前冲 —— 这条最值得清
 * ========================================================================== */
void PID_ClearIntegral(PID_t *p)
{
    p->ErrorInt = 0.0f;
    p->Actual1  = p->Actual;
    p->Error0   = p->Target - p->Actual;
    p->Error1   = p->Error0;
}

void Angle_Realign(void)
{
    int32_t  sum   = 0;
    int32_t  gxSum = 0;                   /* X 轴陀螺原始值累加：顺手标定俯仰零偏 */
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
        sum   += (int32_t)(-atan2f((float)AY, (float)AZ) * (180.0f / 3.14159265f));
        gxSum += (int32_t)GX + PITCH_GX_TRIM; /* 必须补上 Tick10 里的修剪量：标定要作用在
                                               * 滤波器实际看到的信号上，否则那个常量永远减不掉 */
        HAL_Delay(10);
    }

    Angle = (float)sum / 30.0f + G;       /* 取平均并叠加安装偏置 */

#if PITCH_BIAS_ENABLE
    /* 同一批静止采样顺手标定 X 轴零偏(°/s)。
     * 与 Angle 共用一个 300ms 窗口：Realign 本来就只允许静止时调用，
     * 若真在动，角度和零偏会一起被污染 —— 那是用法问题，不是这里的额外风险。
     * 超过 ±PITCH_BIAS_MAX_DPS 就不采信：正常零偏 <1°/s，能超 5°/s 只有两种可能，
     * 对准时车在动、或传感器坏了。保留旧值比写入一个错值安全。 */
    {
        float bias = ((float)gxSum / 30.0f) * (1.0f / GYRO_LSB_PER_DPS);
        if (fabsf(bias) < PITCH_BIAS_MAX_DPS)
            PitchBiasDps = bias;
    }
#endif

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
    TestPWM   = 0;                /* ★ 安全闸：急停连台架测试用的开环 PWM 一起清掉 */
    TB6612_setPWM(1, 0);          /* 停：PWM=0，IN1/IN2 同时为低 -> 电机自由停转 */
    TB6612_setPWM(2, 0);
}
void StartErect(void)
{
    if (CarState != ST_IDLE)
    {
        return;                   /* 已经在跑（或正在起立），直接丢掉重复的 "1" */
    }

    /* ★ 安全闸：TestPWM 只在停车状态有效，一开始起立就立刻清零。
     *   不清的话有两个后果：
     *     1) 起立失败掉回 IDLE 时，上一次的测试 PWM 会突然复活，车自己冲出去；
     *     2) 测试时留下的非零值会一直挂在那里，下一次上电测试就带着它跑。 */
    TestPWM = 0;

    /* 先对准角度：加速度计在静止时才准，刚摔过或刚上电都需要十几秒才收敛，
     * 所以每次起立前先用 300ms 的一次性对准把起始角度摆正（这段只阻塞主循环）。 */
    Angle_Realign();

    PID_ResetAll();
    ErectTime = 0;

    CarState = ST_ERECT;          /* 状态最后切换，避免中断在 ERECT 里看到半初始化的数据 */
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
        /* 手调补偿硬件固有偏置：PITCH_GX_TRIM = 10 LSB 约 0.61°/s。
         * Angle_Realign() 标定零偏时必须用同一个修剪量，否则这个常量永远抵消不掉 */
        GX += PITCH_GX_TRIM;

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
#if PITCH_BIAS_ENABLE
        /* 先扣 X 轴零偏再积分(零偏来源/标定时机/为什么必须是 999 倍放大见 PITCH_BIAS_* 宏注释)。
         *   (GX/16.384 - b) * 0.01  ==  GX*(0.01/16.384) - b*0.01
         *   b=0 时与原式 GX*(2000*0.01/32768) 数值等价(仅差 float 舍入)，
         *   所以这是一次纯增量的修正，关掉 PITCH_BIAS_ENABLE 就逐字节回到旧行为。 */
        AngleGyro = Angle - (((float)GX * (1.0f / GYRO_LSB_PER_DPS)) - PitchBiasDps) * 0.01f;
#else
        AngleGyro = Angle - (float)GX * (2000.0f * 0.01f / 32768.0f);   /* 常量折叠成一次 float 乘法 */
#endif
        float Alpha = 0.001f;
        Angle = Alpha * AngleAcc + (1 - Alpha) * AngleGyro;

        /* ---------- 大偏差快速重同步：摔车/提起后"假角锁死"的解药 ----------
         * Alpha=0.001 的互补滤波对大角度偏差的拉回速率只有约 10°/s：
         * 摔车或被提起来后真实姿态瞬间到几十度，估计角要 20 秒+ 才爬过去，
         * 期间直立环对着假角满幅输出(车暴走后退/轮子疯转)，摔车保护
         * (|Angle|>ERECT_START_ANG) 看着假角也永远不触发 —— 2026-10-30 实测复现：
         * 车体提至垂直，Angle 纹丝不动卡在 -10°。
         * 正常行驶时 AngleAcc 与 Angle 差 <5°(运动加速度冲击只有单拍毛刺)，
         * 连续 10 拍(100ms)都超 30° 只可能是摔车/提起/卡死 —— 直接采信加速度计，
         * 1 秒内重锁真值，直立环立刻收敛，保护判据恢复可信。
         * (2026-10-31 按 AGENTS.md 7.3 恢复：本修复曾被 58fb8e8 的整文件保存覆盖) */
        {
            static uint8_t angResyncCnt = 0;
            if (fabsf(AngleAcc - Angle) > 30.0f)
            {
                if (angResyncCnt < 255) angResyncCnt++;
                if (angResyncCnt >= 10)
                {
                    Angle = AngleAcc;      /* 姿态失锁：直接采信加速度计 */
                    angResyncCnt = 0;
                }
            }
            else
            {
                angResyncCnt = 0;
            }
        }

        /* ---------- 偏航角：Z 轴陀螺仪积分 ----------
         * 这里只用固定的 dt，不做额外滤波；参数与取舍见文件头的 YAW_* 注释。
         * 三步：
         *   1) 用 YAW_LSB_PER_DPS 把 LSB 换成 °/s
         *   2) 减掉零偏，过死区压掉静止漂移
         *   3) 按固定 dt 积分 */
        {
            float gz_dps = (float)GZ * (1.0f / YAW_LSB_PER_DPS);   /* 原始角速度，不扣零偏 */
            float dev    = gz_dps - YawBias;
            YawRateEnc = ENC_YAW_SIGN * DifSpeed * ENC_TO_DPS;   /* 几何推的偏航角速度，无零偏 */

            /* ---- ZUPT：只在编码器确认停住时学习零偏 ----
             * 运动中这一段完全不碰 YawBias，行为与原逻辑逐拍一致。 */
            if (fabsf(AveSpeed) < ZUPT_SPEED_MAX && fabsf(DifSpeed) < ZUPT_SPEED_MAX)
            {
                ZuptSum += dev;
                ZuptSq  += dev * dev;
                ZuptCnt++;
                if (ZuptCnt >= ZUPT_WIN)
                {
                    float mean = ZuptSum / (float)ZUPT_WIN;
                    float var  = ZuptSq  / (float)ZUPT_WIN - mean * mean;

                    /* 方差判静止 + 均值幅值兜底：两者都过才认，防单次极端误判 */
                    if (var < ZUPT_STD_MAX * ZUPT_STD_MAX && fabsf(mean) < ZUPT_MEAN_MAX)
                        YawBias += mean * ZUPT_LEARN;

                    ZuptSum = 0.0f;
                    ZuptSq  = 0.0f;
                    ZuptCnt = 0;
                }
            }
            else
            {
                ZuptSum = 0.0f;   /* 只要动了就作废整窗，避免运动样本混进均值 */
                ZuptSq  = 0.0f;
                ZuptCnt = 0;
            }

#if ENC_YAW_FUSE
            /* ---- 编码器辅助零偏跟踪（ENC_YAW_FUSE=1 才编进去）---------------
             * 三重门限，任何一条不满足就整拍放弃：
             *   1) 差速要有信号：|enc| > ENC_YAW_MIN_DPS
             *   2) 不能是打滑：|残差| < 0.25*|enc| + 1.5
             *      打滑是"成比例放大"，残差会跟着比例放大，这个比例门限能把
             *      "零偏（绝对值小）"和"打滑（相对值大）"分开。
             *   3) 车不能在倒：|Angle| < ENC_YAW_ANGLE_MAX
             * 跟入系数 0.02，宁可慢也不要把一次打滑当成零偏吃进去。 */
            if (fabsf(YawRateEnc) > ENC_YAW_MIN_DPS && fabsf(Angle) < ENC_YAW_ANGLE_MAX)
            {
                float resid = dev - YawRateEnc;
                float lim   = 0.25f * fabsf(YawRateEnc) + 1.5f;

                if (fabsf(resid) < lim)
                {
                    YawBias += resid * ENC_YAW_LEARN;
                    if (YawBias < 0.0f)              YawBias = 0.0f;
                    if (YawBias > ENC_YAW_BIAS_MAX)  YawBias = ENC_YAW_BIAS_MAX;
                    dev = gz_dps - YawBias;      /* 本拍立刻用新零偏 */
                }
            }
#endif
            /* ---- 积分：原死区逻辑不变，只把矩形积分换成梯形 ----
             * 起转/停转的斜坡上，矩形积分每拍固定少算半个采样；梯形没有这一项。 */
            YawRate = dev;
            if (YawRate > -YAW_DEADZONE_DPS && YawRate < YAW_DEADZONE_DPS) YawRate = 0.0f;
            Yaw += 0.5f * (YawRate + YawRatePrev) * YAW_DT;
            YawRatePrev = YawRate;
        }
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

            /* ---------- 方案三：内轮强制不转（只在直角转弯期间） ----------
             * 内轮 = 转弯里较慢的那个轮子，由 DifPWM 的符号直接决定：
             *   DifPWM > 0 -> LeftPWM > RightPWM -> 内轮是右轮
             *   DifPWM < 0 -> 内轮是左轮
             * 这里判的是 PWM 的符号，不是"物理左/右"，所以编码器与电机
             * 是否交叉配对都不影响这段的正确性。
             *
             * 0 = 关：内轮照常反转，是真正的原地转，车心不动（默认）
             * 1 = 模式B：只把内轮落在 [-INNER_LOCK_DZ, 0) 的弱反转段抬到 0，
             *     更深的反转原样保留 -> 差速几乎不变，内轮不再卡在死区里拖
             * 2 = 模式A：内轮一律 >= 0，变成单轮驱动
             *     -> 绕内轮接触点转，角度完全可重复；代价是车心随转弯平移约
             *        0.707 倍轮距，可能转完就把线甩出视场。
             *        另：整车倒退（AvePWM 很负）而内轮指令很深时，钳到 0 会
             *        造成一次明显前冲，那种情况用模式B 更稳。
             * 切换：[slider,InnerLock,0|1|2]，不用重编。
             *
             * ★ 安全门限（务必保留）：钳内轮会破坏 (L+R)/2 == AvePWM 这条
             *   平衡方向的不变量，实发平均变成 AvePWM/2 + |DifPWM|/4，
             *   也就是"刹车砍半 + 附加一个恒定前冲偏置"。倒立摆拿这种输入
             *   只会单向漂到摔车（推导与实测见 INNER_LOCK_MAX_AVE 的注释）。
             *   所以只有当平衡环几乎不出力时才允许锁内轮。
             *
             * 放在 ±80 限幅之后：先保证不削顶，再钳内轮，顺序上内轮一定是
             * 最终下发值；串口 [plot:] 的 LeftPWM/RightPWM 两列也就是钳后的值。 */
            if (InnerLockMode != 0 && CornerState == CORNER_PIVOT && DifPWM != 0
                && AvePWM > -INNER_LOCK_MAX_AVE && AvePWM < INNER_LOCK_MAX_AVE)
            {
                int16_t *pInner = (DifPWM > 0) ? &RightPWM : &LeftPWM;

                if (InnerLockMode == 1)
                {
                    /* 模式B：只抬弱反转段，深度反转（< -INNER_LOCK_DZ）保留 */
                    if (*pInner < 0 && *pInner >= -INNER_LOCK_DZ) *pInner = 0;
                }
                else
                {
                    /* 模式A：内轮一律 >= 0，单轮驱动 */
                    if (*pInner < 0) *pInner = 0;
                }
            }

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
             * 每 10ms 都写一次 PWM，把外部残留的 PWM 彻底抹掉。
             * 写的是 TestPWM（默认 0），给台架上量"电机死区 + 正反向对称性"留一个入口。
             *
             * ★ TestPWM 只在这个分支里被读。ST_ERECT / ST_BALANCE 一次都不看它，
             *   而且 StartErect() / StopCar() 都会把它清零 —— 这是"只在停车
             *   状态生效"的硬保证，不是靠调用方自觉。
             *
             * 为什么必须每拍重写、而不是写一次就不管：
             *   本函数是整机唯一的执行器出口，主循环写什么都会在 10ms 内被这里
             *   覆盖。让 IDLE 分支成为唯一出口，PWM 就不可能残留。
             *
             * 限幅 ±100：PWM 满量程 = ARR+1 = 100（见 tim.c 的 TIM1 Period），
             * 而 TB6612_setPWM 的第二参数是 int8_t，超范围会被截断成反方向，
             * 所以必须在传进去之前裁掉。 */
            int16_t idlePwm = TestPWM;
            if (idlePwm > 100)        idlePwm = 100;
            else if (idlePwm < -100)  idlePwm = -100;

            /* 让串口 [plot:] 的 LeftPWM / RightPWM 两列显示真实下发的值。
             * 不写这两句，IDLE 期间那两列永远是 0 —— 看日志会误以为"没给 PWM"，
             * 从而把"PWM 没下发"和"电机堵转"混为一谈（上一轮就是这么误判的）。 */
            LeftPWM  = idlePwm;
            RightPWM = idlePwm;

            TB6612_setPWM(1, idlePwm);
            TB6612_setPWM(2, idlePwm);
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
    /* ---- 旧的调试残留：原本是这里裸写两行 TB6612_setPWM(1,-30)/(2,-30) ----
     * 它没有注释、没有状态门禁，位置又在状态机之前；因为本文件紧接着就在
     * 同一拍里调 Tick10_Attitude()，把那两行覆盖掉了（相隔几微秒），
     * 所以它从来没有真正驱动过电机，属于死代码。
     *
     * 关掉而不是删除：保留现场便于对照，也让"PWM 只从状态机来"这条事实更显眼。
     * 以后要测开环 PWM，请用 [slider,TestPWM,值] —— 它走的是带门禁的 IDLE 分支。 */
#if 0
	TB6612_setPWM(1,-30);
	TB6612_setPWM(2,-30);
#endif

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

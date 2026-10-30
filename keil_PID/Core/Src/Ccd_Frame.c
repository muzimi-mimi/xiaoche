/* ============================================================================
 * Ccd_Frame.c —— CCD 采帧 + 循迹纠偏 + 直角/T 字路口状态机。
 *              从 main.c 拆出，逻辑未改。
 * ==========================================================================*/
#include "car.h"

/* ==========================================================================
 * ★ 本模块的参数宏全部集中在下面这一段 —— 调循迹/直角参数只改这里。
 *   例外（tim3_pid.c 的 10ms/50ms 拍也要读，只能放头文件）：
 *     TRACK_SPEED / CORNER_SPEED / PIVOT_TIMEOUT_MS / PIVOT_ADVANCE_MS
 *   见 Ccd_Frame.h。
 * ==========================================================================*/

/* ---- 线存在性：与"中线几何是否有效(CCD_Lost)"是两件事 ---- */
#define TRACK_SEEN_MIN  4					/* 可信区间内 >= 这么多个黑像素 = "线还在画面里"。
                                             * 实测正常线宽 16~30，所以 4 是很松的地板：只有真·空场才算丢。 */
#define TRACK_UNSEEN_MAX 5					/* 掉线迟滞：连续这么多帧黑点数 < TRACK_SEEN_MIN 才把
                                             * TrackLineSeen 拉 0(即速度目标归 0)。5 帧 x 20ms = 100ms，
                                             * 足够跨过单帧/双帧的阈值抖动；恢复不迟滞(1 帧即走)。 */

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
/* ★ 2026-10-28 翻符号：TB6612 两路电机通道对调后差速方向整体取反，本宏必须跟着取反，
 *   否则循迹与直角会朝**背离线的方向**纠偏。与 tim3_pid.c 的 TURN_FB_SIGN 同批改动。 */
#define TRACK_DIR      (+1)     /* 循迹方向：当前取值 +1；若循迹往一边跑死就翻成 -1
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
 * ★ 2026-10-28 回退：停转角改回固定角度 PIVOT_FIXED_DEG(默认 90 度)，
 * 不再由 CCD 抓到线决定 —— 原因见 PIVOT_USE_CCD_STOP 处的说明。
 * 旧的动态实现在状态机里用 #if 完整保留，把 PIVOT_USE_CCD_STOP 改成 1 即恢复。
 * Yaw 的职责随之变回主停转判据：累计转角到 PIVOT_FIXED_DEG 就收舵；
 * PIVOT_TIMEOUT_MS 仍是保底(打滑 / 转不动到不了目标角)。
 *
 * 两种状态：
 *   CORNER_LINE   正常循迹，顺便每帧判是不是直角
 *   CORNER_PIVOT  定速旋转，转到 PIVOT_FIXED_DEG 或超时保底
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
#define PIVOT_RATE         0.9f     /* 转弯时写进 TurnPID.Target 的转速(转/秒)
                                     *   1.5(=540°/s) 是实测打滑极限(~0.9 转/秒差速)的 2~3 倍：
                                     *   2026-10-27 面对 T 字路口的抽搐日志里，命令恒 1.5 持续 3 秒，
                                     *   实测差速只在 +0.89 ~ -0.50 之间乱摆(粘滑极限环)，
                                     *   Yaw 净位移仅 ~20°，直到 PIVOT_TIMEOUT 超时。
                                     *   取 0.6(≈216°/s)：转完 PIVOT_MIN_DEG 只需零点几秒，
                                     *   同时给轮胎留 1/3 附着余量。配 TURN_FF=18 前馈约 10.8。
                                     *   转得太猛会甩尾/打滑就继续往下调。 */
#define PIVOT_MIN_DEG     40.0f    /* 最小转角门槛(度)：转过这么多才开始信 CCD 的"抓到线"。
                                     * 不是硬停角 —— 停不停由 CCD 说了算，这里只是防起转瞬间
                                     * 旧线/直角黑区还没出画面就被 CCD_Lost==0 骗回去。
                                     * ★ 仅 PIVOT_USE_CCD_STOP=1 时生效；固定角度模式下不用。 */
#define PIVOT_LINE_FRAMES 2        /* 连续几帧抓到合法细线才退出 PIVOT（2 帧 = 40ms） */
/* ---- 转角终止方式：固定角度 vs CCD 动态接手（2026-10-28 回退） ----
 *
 * 1 = 固定角度（当前）：转过 PIVOT_FIXED_DEG 就退出 PIVOT，不看 CCD。
 * 0 = CCD 动态（2026-10-25 起的行为）：转过 PIVOT_MIN_DEG 之后，连续
 *     PIVOT_LINE_FRAMES 帧抓到合法细线(!CCD_Lost)才退出。
 *
 * 为什么回退：动态模式的停转角由"能不能看见新线"决定，前提是转弯过程本身
 * 要把线带进视场。当前 CORNER_SPEED=0.9、PIVOT_RATE=0.9 时
 *     R = (CORNER_SPEED / PIVOT_RATE) x L = 195.5mm，
 * 而线阵视场半宽只有约 55mm，车转过 90 度已横移约 195mm —— CCD 在弯中
 * 根本等不到线，只能靠 PIVOT_TIMEOUT_MS(3s) 保底退出，效果等于"随机转角"。
 * 固定角度把停转判据收回代码，不再依赖 CCD 在弯中能不能看见线。
 *
 * ★ 两种模式的退出条件互斥，切换只改 PIVOT_USE_CCD_STOP 这一个数，
 *   状态机里两条分支都用 #if 保留，不用动别的地方。
 */
#define PIVOT_USE_CCD_STOP 0
#define PIVOT_FIXED_DEG    84.0f   /* 固定模式的停转角(度)：90 = 直角 / T 字路口的理论值
                                    *
                                    * 会过冲：退出瞬间 TurnTargetCmd 已清 0，但 TurnTargetRamp
                                    * 仍按 TURN_SLEW=0.2/50ms 往 0 滑，从 0.9 滑到 0 要 225ms，
                                    * 期间平均 0.45 转/秒差速，约 27°/s，再多转约 6 度。
                                    * 所以最终朝向要按实测校这个数：转多了减小(如 84)，
                                    * 转少了加大(如 95)。
                                    * 标定：跑一次，看 OLED 的 YawTurned 停在哪、车头实际朝哪。 */

/* ---- 直角转向极性：压黑的那一端 -> 往哪边转 ----
 *
 * CornerDir 的原始来源只是"哪一端发黑"：eR=1(高 index 端) 记 +1，否则 -1，
 * 再乘这个系数。所以本宏唯一的职责是：把"图像里的压黑端"翻成"车该往哪边转"。
 *
 * 为什么必须单独留一个宏：eR 只是"图像高 index 端"，它到底是车的左还是右，
 * 取决于线阵/镜头的装配方向，代码本身推不出来，只能靠实测。
 * 直线循迹的 TRACK_DIR 已经把"图像右 = 车右"钉死过一次，所以理论上
 * 压黑端就是转弯方向(本宏 = +1)。当前填 +1，与实测一致；若实测发现直角方向相反就改成 -1。
 *
 * 判断该改哪一处(别两个都翻，两个都翻等于没改)：
 *   直线循迹正常、只有直角反  -> 翻本宏(+1 / -1 之间换一个数)
 *   直线循迹也在往一边跑      -> 真凶是 TRACK_DIR，本宏保持 -1 不动
 *
 * 20 秒静态判据(不用跑车)：拿纸片遮住传感器"车左侧"那一端，
 *   看 OLED 波形下陷出现在左半边还是右半边，就能定死 index 的方向。
 */
#define CORNER_SIDE_SIGN   (+1)     /* +1 = 压黑端就是转弯方向（当前取值）；-1 = 取反 */


/* ---- CCD 段：采一帧 + 循迹/直角/T 状态机（TIM3 回调分频调用，放每拍末尾）----
 * 位置很关键：它排在 10ms/50ms 段之后，PWM 已经写进电机，
 * 再花 ~0.7ms 采一帧也不会让执行滞后一拍。反过来放最前面就会把执行往后推。
 *
 * 采样周期 = CCD_Div x TIM3 周期(10ms)，与中断优先级无关。
 *   主循环里 OLED_Update() 要约 20~24ms，只要不关中断就不影响采样。
 *   一帧真的只有 ~0.6ms(TIME_us=2 -> CLK 约 110kHz)，只占 10ms 的 6%。
 *   CCD_AutoExposure() 也在里面跑。TIM3 优先级是 0，会抢占 SysTick(优先级 15)，
 *   所以 HAL_Delay() 不能在循环里用；采样窗口很小，别在里面加长延时或串口打印。 */
void Ccd_Frame(void)
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
            uint8_t eL, eR;
            uint8_t kk;
            uint8_t tIsT = 0;           /* 本帧已确认证据构成 T 字路口，用来抑制同帧的直角触发 */

            for (kk = CCD_EDGE_LO; kk < CCD_EDGE_LO + EDGE_ZONE_N; kk++)
                if (ccd_adc[kk] < CCD_Yuzhi) darkL++;
            for (kk = CCD_EDGE_HI; kk < CCD_EDGE_HI + EDGE_ZONE_N; kk++)
                if (ccd_adc[kk] < CCD_Yuzhi) darkR++;
            eL = (darkL >= EDGE_ZONE_DARK) ? 1u : 0u;
            eR = (darkR >= EDGE_ZONE_DARK) ? 1u : 0u;

            /* 黑点数也只统计可信区间，不让两端坏点常年灌水虚增。
             * darkCnt 现在是全局(要上报遥测)，局部变量才会每帧自动清零 ——
             * 这里必须显式清 0，否则它会跨帧累加到 255 卡死。 */
            darkCnt = 0;
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
                    PID_ClearIntegral(&TurnPID);   /* 转向目标从"跟踪中线偏差"换成"固定转速"，旧积分作废 */
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

                /* ---------- 停转判据：两模式互斥，由 PIVOT_USE_CCD_STOP 选择 ---------- */
#if PIVOT_USE_CCD_STOP
                /* ---------- 动态模式：转到重新抓到线为止（原实现，完整保留） ----------
                 * 越过 PIVOT_MIN_DEG 之后，连续 PIVOT_LINE_FRAMES 帧拿到合法细线
                 * (!CCD_Lost：沿配对 + 线宽 + 对比度都过)就立刻回循迹。
                 * 停转角由看到新线决定，弯缓弯急都能贴住。
                 * 门槛之前旧线/黑区还在画面里，CCD_Lost 本来就是 0，不能信。 */
                if (fabsf(YawTurned) >= PIVOT_MIN_DEG && !CCD_Lost)
                {
                    if (PivotOk < 255) PivotOk++;
                    if (PivotOk >= PIVOT_LINE_FRAMES)
                    {
                        CornerState = CORNER_LINE;   /* 抓到新线：立刻回循迹接管 */
                        CornerSeen  = 0;
                        PivotOk     = 0;
                        PID_ClearIntegral(&TurnPID);    /* 松舵回循迹：转向环从零开始 */
                        PID_ClearIntegral(&SpeedPID);   /* 弯中打滑会把速度积分灌满，出弯不清就往前冲 */
                    }
                }
                else
                {
                    PivotOk = 0;
                }
#else
                /* ---------- 固定角度模式（当前）：转过 PIVOT_FIXED_DEG 就收舵 ----------
                 * 不看 CCD：弯中看不到线也照样按角度收住，停转判据不再依赖视场。
                 * 退出时立刻把 TurnTargetCmd 清 0，不等下一帧 CCD —— CCD 帧周期 20ms，
                 * 等它就等于白转 1 度多。
                 * 角度到不了(打滑 / 卡住)由 10ms 层的 PIVOT_TIMEOUT_MS 保底退回。 */
                PivotOk = 0;                    /* 本模式不用这个计数，保持干净 */
                if (fabsf(YawTurned) >= PIVOT_FIXED_DEG)
                {
                    CornerState    = CORNER_LINE;
                    CornerSeen     = 0;
                    TurnTargetCmd  = 0.0f;      /* 立刻松舵，下一帧循迹重算目标 */
                    PID_ClearIntegral(&TurnPID);    /* 松舵回循迹：转向环从零开始 */
                    PID_ClearIntegral(&SpeedPID);   /* 弯中打滑会把速度积分灌满，出弯不清就往前冲 */
                }
#endif
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
                PID_ClearIntegral(&TurnPID);   /* 同直角触发：换目标前把转向环旧积分清掉 */
            }
        }
}
/* ---------- 循迹开关统一入口：开/关都先把状态清干净 ----------
 * 三处切换点(按键第②击、裸字节 'T'/'t'、包 [t])共用这一份：
 *   TrackLostCnt 丢线计数、TurnTargetCmd 转向命令、直角/T 证据与状态机、
 *   PivotOk 抓线确认计数。不清的话会带着上一轮的指令和 PIVOT 状态
 * 瞬间抢一下（刚开循迹就转一个 90 度之类）。
 *
 * ★ 2026-10-29 补上三个漏清的（与 PID_ResetAll() 对齐，那边一直是全的）：
 *   TrackLineSeen  -- 残留 1 会让"根本没线"也按 TRACK_SPEED 冲
 *                     TRACK_UNSEEN_MAX(5) 帧 = 100ms；
 *   TrackUnseenCnt -- 残留计数还会吃掉这 5 帧迟滞的头几帧；
 *   TrackErrPrev   -- 残留偏差让重开循迹的第一帧 dErr 是个假跳变，
 *                     超前量 lead 顶到 ±TRACK_LEAD_MAX，多打约 0.23 转/秒方向。
 *   这条路径只经过 Track_Reset()、不经过 PID_ResetAll()，所以必须在这里清。 */
void Track_Reset(uint8_t on)
{
    TrackMode     = on;
    TrackLostCnt  = 0;
    TurnTargetCmd = 0.0f;
    TrackLineSeen  = 0u;        /* 先按"没看见线"起步，等第一帧 CCD 重新确认 */
    TrackUnseenCnt = 0;         /* 掉线迟滞计数一并清零 */
    TrackErrPrev   = 0;         /* 偏差历史一并清零，免得第一帧算出一个假的变化率 */
    CornerState   = CORNER_LINE;
    CornerSeen    = 0;
    TSeen         = 0;
    PivotOk       = 0;

    /* 开/关循迹把前进速度的来源整个换掉（摇杆 <-> 循迹），
     * 两个环的积分都属于上一个状态，一并清干净，避免切换瞬间冲一下。 */
    PID_ClearIntegral(&TurnPID);
    PID_ClearIntegral(&SpeedPID);
}

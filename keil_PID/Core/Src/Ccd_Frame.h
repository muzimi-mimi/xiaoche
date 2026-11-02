#ifndef __CCD_FRAME_H
#define __CCD_FRAME_H

/* ==========================================================================
 * Ccd_Frame.h —— CCD 感知与循迹决策的对外接口（Ccd_Frame.c 的配套头）。
 *
 * ★ 本模块的参数宏全部在 Ccd_Frame.c 顶部，这里只留 4 个跨 .c 的：
 *     TRACK_SPEED / CORNER_SPEED / PIVOT_TIMEOUT_MS / PIVOT_ADVANCE_MS / INNER_LOCK_DZ
 *   它们是 tim3_pid.c 的 10ms / 50ms 拍要读的量（算转弯计时、给前进速度目标），
 *   宏跨不了 .c，只能放头文件。循迹/直角的其余参数都在 Ccd_Frame.c。
 *
 * 本头由 car.h 统一 include，模块 .c 仍然只写 #include "car.h"。
 * ==========================================================================*/

#include "main.h"

#define TRACK_SPEED    0.35f    /* 循迹前进速度（转/秒）：写进 SpeedTargetCmd，再经 SPEED_SLEW
                                 *   斜坡后才落到 SpeedPID.Target
                                 *   摇杆那一支只在 !TrackMode 时才动速度目标，
                                 *   循迹模式下没有速度输入，目标值由这里统一给
                                 * 量化下限：编码器 44 线、30 减速比、50ms 采样，
                                 *   1 个脉冲 = 0.0152 转/秒；AveSpeed 又要左右取平均，
                                 *   0.08 时每 50ms 只有 5.3 个脉冲(误差 9.4%)，抖动很明显。
                                 * 0.5 对应约 102mm/s（轮径 65mm -> 周长 204mm），
                                 *   每 50ms 约 33 个脉冲，量化误差 3%。 */

/* ---- 内轮强制不转（方案三）的"弱反转段"宽度，单位 PWM ----------------------
 *
 * 只在 CORNER_PIVOT 期间、且 InnerLockMode==1（模式B）时用到：
 * 内轮指令落在 [-INNER_LOCK_DZ, 0) 就抬到 0，更深的反转保留。
 *
 * 为什么按 PWM 而不按转速：内轮在转弯里本来就该慢，钳的是**指令**，
 * 目的是不让它停在"发着 PWM 却转不动"的那一段。
 *
 * 取值依据（台架 [slider,TestPWM,±20/±10] 实测）：
 *   speed ≈ 0.060*PWM - 0.17，零点在 PWM 2.3~3.3，空载死区只有 2~3 个数。
 *   贴地带负载时死区会更大，取 10 是留约 3 倍余量。
 *   调太大 -> 内轮被抬得过高，差速缩水、车往内轮一侧偏；
 *   调太小 -> 内轮仍会在死区里"嗡"着不转。
 */
#define INNER_LOCK_DZ   10

/* ---- 内锁的安全门限：|AvePWM| 超过它就放开内轮 ----------------------------
 * 为什么必须有（据 2026-10-28 直角转弯摔车日志反推）：
 *   垂直时两轮指令满足  (LeftPWM + RightPWM)/2 == AvePWM
 *   内锁把内轮钳到 0 就破坏了这个不变量，实际下发变成
 *       (0 + (AvePWM - DifPWM/2)) / 2  ==  AvePWM/2 + |DifPWM|/4
 *   其中 |DifPWM|/4 是一个恒定朝前的偏置。实测（|DifPWM|≈21，偏置 +5.25）：
 *       指令 -5  -> 实发 +2.6   （符号翻转）
 *       指令 -17 -> 实发 -3.2   （只执行 19%）
 *       指令 -80 -> 实发 -34.7  （丢掉 57% 刹车）
 *   倒立摆收到这种输入只会单向漂移：那一次从 +5 漂到 -17 用了 68 拍，
 *   再 6 拍 Angle 就从 0 冲到 -54°，触发 ERECT_START_ANG 保护停车。
 * 门限的作用：平衡环几乎不出力（车正立、匀速）时才允许单轮驱动；
 *   一旦它开始抢救，立刻把完整权限还回去。调大更"敢锁"但更容易摔。 */
#define INNER_LOCK_MAX_AVE  15      /* 2026-11-01 由 10 调到 15，且门限比较改为含边界 >=/<=（原先严格 >/< 会把 |AvePWM| 恰好为 10 的帧误判成超限）。 */

/* ---- 内轮下限（模式C，2026-11-01 新增，借 MSG3507_car 的 line_follow.c）----
 * 只在 InnerLockMode==3 时用：内轮不再是"钳到 0"，而是"抬到下限"
 *     下限 = max(INNER_LOCK_FLOOR_RATIO * |AvePWM|, INNER_LOCK_FLOOR_PWM)
 * 参照值：MSG3507_car 的 LINE_INNER_WHEEL_MIN_RATIO=0.30、LINE_INNER_WHEEL_MIN_SPEED=4.0，
 *   这里换成 PWM 单位：比例仍取 0.30，绝对值取 6 —— 本车空载死区 2~3 个数，
 *   INNER_LOCK_DZ=10 是贴地余量，6 落在两者之间：够把内轮推出死区，
 *   又不至于把差速吃掉一半。
 * 与模式A 的区别：模式A 内轮可以到 0（纯转轴），模式C 内轮始终有正向出力，
 *   转弯半径比模式A 大、车心横移小；这是"不绕轴"换"不打滑"的取舍。
 * 与换轴的关系：PIVOT_LOCK_SEGS 的奇偶段换轴只认 InnerLockMode==2，
 *   模式C 不参与换轴。 */
#define INNER_LOCK_FLOOR_RATIO  0.30f
#define INNER_LOCK_FLOOR_PWM    6

#define PIVOT_TIMEOUT_MS   6000     /* 转弯超时：转了 6 秒还没等到线(打滑/卡住/丢线)就保底回循迹
                                     * 2026-11-01 3000->6000：实测一次正常转角要 2.6s，加上 PIVOT_LOCK_SEGS
                                     * 换轴开销(~0.1s/次)余量只剩 0.1s；上一份日志就在弯中被 3s 超时截断
                                     * (Target=0.9 持续 3.8s，Yaw 只走了 11°)。 */

/* PIVOT_FIXED_DEG 原在 Ccd_Frame.c，2026-11-01 移到头文件：
 *   内轮锁分段 PIVOT_LOCK_SEGS 要按它算"段长"，tim3_pid.c 也要读。
 * 固定模式的停转角(度)：90 = 直角 / T 字路口的理论值
 *   会过冲：退出瞬间 TurnTargetCmd 已清 0，但 TurnTargetRamp 仍按
 *   TURN_SLEW=0.2/50ms 往 0 滑，从 0.9 滑到 0 要 225ms，期间平均
 *   0.45 转/秒差速，约 27°/s，再多转约 6 度。
 *   所以最终朝向要按实测校这个数：转多了减小(如 84)，转少了加大(如 95)。
 *   标定：跑一次，看 OLED 的 YawTurned 停在哪、车头实际朝哪。 */
#define PIVOT_FIXED_DEG    84.0f
/* ★ 2026-11-02 原地转向角度精度三项（都作用于 PIVOT 定角转，可在线改）
 *   1) 目标角改用 PivotTargetDeg（默认 = PIVOT_FIXED_DEG），串口 [slider,PivotDeg,值] 改
 *   2) 剩余角 < PIVOT_CREEP_DEG 后转速由 PIVOT_RATE 线性降到 PIVOT_RATE_CREEP
 *   3) 停转按当前角速度提前 PIVOT_STOP_LEAD_MS 收舵，抵消收舵后的惯性余转
 * 依据：84° 定速转实测稳定超调，根因是收舵时轮子还在 0.9 转/秒上，不是 Yaw 算不准。 */
#define PIVOT_CREEP_DEG      12.0f   /* 进入爬行的剩余角(度) */
#define PIVOT_RATE_CREEP     0.30f   /* 爬行段差速目标(转/秒) */
#define PIVOT_STOP_LEAD_MS   80.0f   /* 停转提前量(ms)：按 |YawRate| 折算 */

extern volatile float PivotTargetDeg;  /* 原地转向目标角(度)，默认 84，[slider,PivotDeg,值] 在线改 */

/* ★ 内轮锁分段数 N（2026-11-01 新增）：把一次原地转切成 N 段，每段换一只轮子当转轴
 *   单轮死锁时车心被迫绕被锁的那个轮子画弧，84° 转完横移约 131mm(几何值 W*sin(θ/2))，
 *   远超 CCD 视场半宽(约 55mm)。分成 N 段后两段的平移方向相反、互相抵消，末位移约
 *   W*θ²/(4N)：  N=2 -> 约53mm   N=4 -> 约26mm   N=8 -> 约13mm
 *   代价：①每次换轴是一次阶跃，DIFPWM_SLEW 管不到单轮跳变；
 *         ②每一瞬间仍只有一只轮子出力，共模只剩 50%（单轮路线改不掉）。
 *   有效转角时间 = (84/N)/32 秒，换轴开销约 0.1 秒 -> N 超过约 26 就亏本。推荐 4~8。
 *   填 1 = 完全回到"始终锁同一只轮子"的老行为。只作用于 InnerLockMode=2，模式1 不受影响。 */
#define PIVOT_LOCK_SEGS    8
/* ★ 换轴后静止窗口（2026-11-02 新增）：刚进入奇数段(段号为奇)的瞬间，把前进速度、差速、
 *   转向目标同时清零并保持 PIVOT_SWAP_HOLD_MS 毫秒，让车真的站住，等平衡环把 AvePWM
 *   收回 0 —— 换轴门限 |AvePWM| < |DifPWM|/2 - 2 只有在 |AvePWM| 接近 0 时才成立。
 *   为什么需要它：N=4 的实测日志里 ph=1 那 12 拍 |AvePWM| 全程 9~22，门限 6~8 一次都没进；
 *   车一直被速度环推着往前走，AvePWM 就下不来。先停住再换轴，门限才有机会开。
 *   ⚠ 每个奇数段都停一次。N=8 时是 4 次 x 0.5s = 2s 纯停 + 两次加减速斜坡，
 *     必须对照 PIVOT_TIMEOUT_MS(6000) 重算总时长，必要时把 N 降到 2~4。
 *   填 0 = 关闭，回到旧的"进段立刻换轴"行为。只作用于 InnerLockMode=2。 */
#define PIVOT_SWAP_HOLD_MS  500
/* ★ 内轮锁是否也作用于第四关 NAV 转弯（2026-11-01 新增，默认 1）
 *   状态4 的 NAV 转弯与 PIVOT 走的是同一条执行链：Ccd_Frame.c:287 和 :300 都是
 *     TurnTargetCmd = TRACK_DIR * (float)CornerDir * PIVOT_RATE;
 *   之后共用同一个 TurnPID + TURN_FF。差别只在"停止判据"：
 *     NAV   : fabsf(YawTurned) >= NAV_TURN_DEG(115°) / 2500ms
 *     PIVOT : 固定角 PIVOT_FIXED_DEG(84°) / PIVOT_TIMEOUT_MS
 *   所以原先只写 CornerState == CORNER_PIVOT 的卫语句，会让左直角(被 NAV 接管)
 *   永远测不到内轮锁和分段 N —— 2026-11-01 实测 151 帧日志就是这种情况。
 *   填 0 = 内轮锁只作用于 PIVOT，NAV 回到第四关原行为（回退开关）。 */
#define PIVOT_LOCK_NAV     1
#define PIVOT_ADVANCE_MS   0        /* 开始累计 Yaw 之前先空走多少 ms
                                     *
                                     * 为什么要留这段：CCD 装在车头前方约 L 厘米处，原地旋转时传感器的轨迹
                                     * 是半径 L 的圆。要等这一段走完，转过的角度才对应车体真正的转角。
                                     * 停转后再走约 L 厘米，靠循迹环把车拉回线上，L 越小弯心越靠近车体、越跟得住。
                                     *
                                     * 估算：TRACK_SPEED=0.5 转/秒 x 204mm 周长 = 102mm/s，
                                     *       1 厘米约 98ms，所以填 L(厘米) x 98 毫秒。
                                     * 标定：量出车轴中心到 CCD 镜头的距离 L。
                                     * 默认 0：不空走，进入 PIVOT 立刻开始累计，最省事。 */

/* ---- 转弯时的前进速度：让车"一边转一边往前走"，不停在直角点上 -------------
 *
 * 直角转弯要同时管两件事：转多快(PIVOT_RATE)、以及转的时候还往前走多快(本宏)。
 * 转弯期间 SpeedPID.Target 由本宏给，不再是 0 —— 这就是"保持前进"的落点。
 *
 * 决定"看起来是转弯还是原地打转"的是转弯半径：
 *     R = v / w
 *     v = 本宏(转/秒) x 轮周长 C(204mm)        [mm/s]
 *     w = PIVOT_RATE(转/秒) x C / L            [rad/s]
 *     =>  R = (本宏 / PIVOT_RATE) x L
 *
 * ★ 2026-10-28 修正：旧注释写的是 w = PIVOT_RATE x 2π，量纲是错的。
 *   PIVOT_RATE 喂给 TurnPID.Target，那是**差速轮速(转/秒)**，不是车身转速。
 *   两轮差 n 转/秒等于左右轮线速度差 n*C，车身转速 w = (n*C)/L。
 *   x2π 只在 L 恰好等于 C 时才成立；本车 L=195.5mm、C=204mm，
 *   2πL/C = 6.02，旧注释把 w 高估 6.02 倍、把 R 低估 6.02 倍。
 *
 * 按现在 CORNER_SPEED=0.9、PIVOT_RATE=0.9、L=195.5mm 算：
 *     v = 183.6mm/s    w = 0.939rad/s = 53.8°/s
 *     R = 195.5mm  == 轮距 L 本身（本宏等于 PIVOT_RATE 时 R 恒等于 L）
 *     转过 90°：约 1.67s，弧长约 307mm
 *   ★ 这个半径对视场半宽只有约 55mm 的线阵（1 像素约 0.86mm，128 像素约 110mm）来说太宽，转完必然甩到线外。
 *   想要 R≈30mm，本宏应取 0.9 x 30/195.5 ≈ 0.14。旧组合 0.2/0.6 对应 R≈65mm，比现在还小 3 倍。
 *
 * 也就是说"前进"是有的，只是十几毫米肉眼看不出，车看起来仍像贴点转身 ——
 * 这正是直角该有的样子：半径比线宽大一点就够(20~30mm)。半径再大就会切内角、
 * 转完偏到线外，反而更难循迹。
 *
 * ---- 2026-10-30：为"循迹匀速"改回与 TRACK_SPEED 相等 ----
 * 按现在的 TRACK_SPEED=0.3、PIVOT_RATE=1.2：
 *     R = L x (CORNER_SPEED / PIVOT_RATE) = 195.5 x 0.25 ≈ 49mm
 *     R 仍小于线阵视场半宽(~55mm)，转过 90 度时线还在画面里，接得住。
 *
 * 收益：整个循迹过程 SpeedTargetCmd 恒为 0.3，斜坡不再动作，速度环只抵抗扰动 ——
 *       "匀速"只能这么做出来。旧值 0 意味着每次转弯都先减速到停、再重新加速。
 * 代价：过弯变成弧线，弯心外扩约 49mm。要更贴拐点就降本宏（R 随它线性下降），
 *       但每降一次就多一分"过弯减速"，匀速性跟着变差。
 *
 * ★ 本宏填 0 = 原地转身（右轮必须反转，且必然走走停停）；
 *   等于 TRACK_SPEED = 匀速。两者不可兼得，按当前目标选"匀速"。
 */
#define CORNER_SPEED   0.35f /* 转弯期间前进速度：与 TRACK_SPEED 相等 -> 全程恒速。
                                    * 想单独调就换成具体数字（如 0.18f -> R≈30mm），
                                    * 但那样过弯会减速，匀速性变差。 */

/* ==========================================================================
 * ★★★ 第四关：惯性导航（识别到左直角 -> 右转 -> 定距直行(数贴纸) -> 停）
 *
 * 为什么叫"惯性"：这一段**不靠 CCD 纠偏**，靠陀螺 Yaw 累计转角 + 编码器里程
 * 推进。理由和直角转弯用固定角度停是同一个：
 *   转过 115° 之后车头已横移约 L 量级，线根本不在 110mm 视场内，
 *   拿 CCD 当地图只会得到"丢线"，所以要有一段自持航位推算。
 *
 * 时序：CORNER_LINE --左直角确认--> CORNER_NAV
 *         └ NavPhase = TURN  右转，累计 |YawTurned| >= NAV_TURN_DEG
 *         └ NavPhase = RUN   直行，NavDist >= NAV_DIST_MM，期间数贴纸
 *         └ NavPhase = STOP  速度目标 0，原地直立（平衡车不能直接断电，否则立刻倒）
 *
 * 进入条件写死在状态机里：**只认左直角**（CornerDir == -1）。右直角仍走原来的 PIVOT。
 * 退出：Toggle 循迹（'T'/'t'）或 StopCar，都会经 Track_Reset / PID_ResetAll 复位。
 * ==========================================================================*/
#define NAV_ENABLE          1       /* 0 = 完全关掉第四关，左直角退回普通 PIVOT 左转 */
#define NAV_ONE_SHOT        1       /* 1 = 只认第一个左直角（进过一次就不再进）；0 = 每个左直角都进 */

#define NAV_TURN_DEG        115.0f  /* 右转的目标角(度)。★ 这是"停转触发值"，不是净转角：
                                     *   退出瞬间 TurnTargetCmd 清 0，但 TurnTargetRamp 仍按
                                     *   TURN_SLEW=0.2/50ms 从 0.9 滑到 0（225ms），
                                     *   期间平均 0.45 转/秒差速约 27°/s，会再多转 6~8°。
                                     *   要净转 115° 就把这里往下减到 107~109。
                                     *   标定：跑一次看 OLED 的 C2 行 YawTurned 停在哪。 */

#define NAV_DIST_MM         800.0f  /* RUN 段要走完的距离(mm) = 80cm。按 0.35 转/秒、
                                     *   轮周长 204mm 算约 71mm/s，全程约 11 秒。
                                     *   里程由编码器 AveSpeed 积分得到，见 tim3_pid.c。 */

#define NAV_SPEED           0.35f   /* RUN 段前进速度(转/秒)：默认与 TRACK_SPEED 一致，
                                     *   速度环就是按这个量级标定的，别超过 0.5。 */

#define NAV_TURN_TIMEOUT_MS 2500    /* TURN 段保底(ms)：打滑/卡住转不到目标角就强行进 RUN，
                                     *   不能像 PIVOT 那样退回循迹 —— 这时早就没线可循了。 */
#define NAV_RUN_TIMEOUT_MS  20000   /* RUN 段保底(ms)：里程算不出来（编码器丢了/原地空转）时
                                     *   到点强制进 STOP。80cm 正常约 11s，给到 20s。 */

/* ---- 黑贴纸计数：贴纸贴在线上，使线"明显变宽"，用黑像素总数判 ----
 * 正常线宽实测 16~30 像素（ccd.h 的 CCD_LW_MAX=30 就是按这个定的），
 * 贴纸叠上去会跳到 40 以上。所以判据是 darkCnt 越过一个高一档的门限。 */
#define NAV_STICKER_DARK    45      /* darkCnt >= 这个值 = 正压在一张贴纸上（上限判据） */
#define NAV_STICKER_REL     30      /* 回差：darkCnt 掉回这个值以下才允许数下一张。
                                     *   一高一低两个门限是必须的 —— 只有一个门限时，
                                     *   贴纸边缘那几帧 darkCnt 在门限上下抖，
                                     *   一张贴纸会被数成 3~5 张。 */
#define NAV_STICKER_SETTLE_MM 80.0f /* 刚从 TURN 切进 RUN 的这段里程内不计数：转弯末段
                                     *   整个画面都可能发黑，否则一进 RUN 就先白送一张。 */

/* ---- RUN 段的航向保持 ----
 * 800mm 要走 11 秒，两轮电机/地面不完全对称，纯"差分给 0"会一路漂。
 * 所以用 Yaw 误差做一个小比例修正，把车头锁在进 RUN 那一刻的朝向上。
 * 符号：Target > 0 = 右转（已由 2026-11-01 的 T 路口日志确认），
 *   Yaw 偏大 = 车头偏左 -> 需要右转 -> 给正值，故用 +Kp x (Yaw - NavYawHold)。 */
#define NAV_HEADING_KP      0.30f   /* 每偏 1 度给多少转/秒差速目标 */
#define NAV_HEADING_MAX     0.20f   /* 修正量限幅(转/秒)：别让航向纠偏盖过直行速度控制 */

#define WHEEL_CIRC_MM       204.0f  /* 轮周长(mm)：轮径 65mm -> pi x 65 = 204。
                                     *   里程积分 NavDist += AveSpeed(转/秒) x 204 x 0.05s。
                                     * ★ 换轮子必须同步改这里，否则 80cm 会按比例走偏。 */

/* ---------- 对外接口（定义在 Ccd_Frame.c） ---------- */
void Ccd_Frame(void);           /* 采一帧 + 循迹/直角/T 状态机，TIM3 每拍末尾调用 */
void Track_Reset(uint8_t on);   /* 循迹开关统一入口：开/关都先把状态清干净 */

#endif /* __CCD_FRAME_H */

/* ============================================================================
 * OLED_RenderStatus.c —— 状态屏整屏渲染 + 电池电压巡检。
 *                      从 main.c 拆出，逻辑未改。
 * ==========================================================================*/
#include "car.h"

/* ==========================================================================
 * ★ 本模块的参数宏集中在这里 —— 调电池检测只改这一段。
 * ==========================================================================*/

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
/* 调试用：状态名缩写。仅被注释掉的 OLED 行引用，保留（勿清） */
static const char *StateStr(void)
{
    if (CarState == ST_BALANCE) return "BAL";
    if (CarState == ST_ERECT)   return "ERECT";
    return "IDLE";
}
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
void OLED_RenderStatus(void)
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
//        OLED_Printf(0, 56, OLED_6X8, "GX%+05.1f", GX / 16.384f);  /* X 角速度(°/s)，静止应为 0 */
//        OLED_Printf(42, 56, OLED_6X8, "GZ%+05.1f", GZ / 16.384f);  /* Z 角速度(°/s)，静止时应接近 YAW_BIAS_DPS */
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

/* ============================================================================
 * Blue_ProcessPackets.c —— 蓝牙下行：裸字节命令与 [包] 解析。
 *                        从 main.c 拆出，逻辑未改。
 * ==========================================================================*/
#include "car.h"

/* ---------- 蓝牙 [包] 处理：轮询两个接收缓冲并分派 ----------
 * 包格式与裸字节命令的对照、大小写陷阱见主循环里那段总注释。
 * strtok 会改写缓冲内容，只能在主循环里做（中断收完了才轮到它）。 */
void Blue_ProcessPackets(void)
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
                    /* ★ 段数不足时 strtok 返回 NULL：缺名会走到 strcmp(NULL,..) 读地址 0，
                     * 缺值会走到 atof(NULL)。两种都直接丢弃本条，别让 PID 参数被写坏。
                     * 先清接收标志再 continue，否则这一条会被反复重处理。 */
                    if (Name == NULL || Value == NULL)
                    {
                        BlueSerial_RxFlag[i] = 0;
                        continue;
                    }

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
                    else if (strcmp(Name, "TestPWM") == 0)	// ★ 开环 PWM 测试量：台架上量电机死区用
                    {
                        /* 只在停车状态（ST_IDLE）生效：
                         *   写 → tim3_pid.c 的 ST_IDLE 分支每 10ms 把它送进电机
                         *   清 → StartErect() / StopCar() 都会清零
                         * 所以它出不了停车状态，不需要在这里判 CarState。
                         *
                         * 这里原样存，±100 的限幅放在 IDLE 分支做 —— 让滑块回读到的
                         * 就是用户输入的原数，超范围时能在串口上立刻看出来。 */
                        TestPWM = (int16_t)atof(Value);		// 写入开环 PWM 测试量
                    }
                    else if (strcmp(Name, "InnerLock") == 0)	// ★ 内轮强制不转模式 0/1/2
                    {
                        /* 运行时切换，改完立刻生效，不用重编也不用停车。
                         * 取值含义见 car.h 的 InnerLockMode 说明。
                         * 越界直接裁到 [0,2]：模式号没有别的安全含义，
                         * 但非法值会让执行器分发落到未定义的分支上。 */
                        int16_t m = (int16_t)atof(Value);
                        if (m < 0) m = 0;
                        if (m > 2) m = 2;
                        InnerLockMode = m;
                    }

                }
                else if (strcmp(Tag, "joystick") == 0)		// [joystick,LH,LV,RH,RV]：摇杆帧
                {
                    char *pLH = strtok(NULL, ",");   /* 取第 2 段，作为摇杆值 LH */
                    char *pLV = strtok(NULL, ",");   /* 取第 3 段，作为摇杆值 LV */
                    char *pRH = strtok(NULL, ",");   /* 取第 4 段，作为摇杆值 RH */
                    char *pRV = strtok(NULL, ",");   /* 取第 5 段，作为摇杆值 RV */
                    int8_t LH, LV, RH, RV;

                    /* ★ 同上：段数不足时 strtok 返回 NULL，atoi(NULL) 会读地址 0。
                     * 摇杆帧缺段没有合理的默认值，整条丢弃。 */
                    if (pLH == NULL || pLV == NULL || pRH == NULL || pRV == NULL)
                    {
                        BlueSerial_RxFlag[i] = 0;
                        continue;
                    }

                    LH = (int8_t)atoi(pLH);
                    LV = (int8_t)atoi(pLV);
                    RH = (int8_t)atoi(pRH);
                    RV = (int8_t)atoi(pRV);

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
                        /* ★ 2026-10-28：电机通道对调后差速取反，摇杆这条不走 TRACK_DIR，
                         *   必须自己取负号，才能保持 RH>0 = 右转 的原有手感。 */
                        TurnTargetCmd = -RH / 60.0;  // RH>0 = 右转；/60 比原 /50 稍软，配合斜坡减少打滑
                        if (TurnTargetCmd != 0.0f && LV == 0)
                            SpeedPID.Target = 0.20f;  /* 只转向不前进时给一点前进速度，避免原地打转 */
                    }

                }
            }

            BlueSerial_RxFlag[i] = 0;				// 处理完清除标志位，等待下一次
        }
    }
}

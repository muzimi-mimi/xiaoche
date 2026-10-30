#ifndef __TIM3_PID_H
#define __TIM3_PID_H

/* ==========================================================================
 * tim3_pid.h —— 实时控制内环的对外接口（tim3_pid.c 的配套头）。
 *
 * ★ 本模块的参数宏全部在 tim3_pid.c 顶部，这里不留参数。
 *   唯一例外是 YAW_BIAS_DPS：main.c 要拿它给全局 YawBias 赋上电初值，
 *   而宏跨不了 .c，所以它必须留在头文件里。
 *
 * 本头由 car.h 统一 include，模块 .c 仍然只写 #include "car.h"。
 * ==========================================================================*/

#include "main.h"

/* ---- 陀螺 Z 轴零偏标定值(°/s)：唯一留在头文件的本模块参数 ----
 * 为什么在这儿：main.c 里那句 `float YawBias = YAW_BIAS_DPS;` 要用它，
 *   而宏跨不了 .c。完整说明见 tim3_pid.c 的"偏航角 Yaw"那一段。
 * 标定：静止 30s，取所有 GZ 的平均值 / 16.384。
 *   每次上电陀螺仪状态都不一样，没有一劳永逸的准确值，只能在已知静止时重标。 */
#define YAW_BIAS_DPS      2.41f     /* Z 轴零偏(°/s)：静止实测 GZ 均值 39.45 LSB / 16.384 */

/* ---------- 对外接口（定义在 tim3_pid.c） ---------- */
void PID_ResetAll(void);        /* 三个环清到干净状态 + 转角/循迹状态复位 */
void PID_ClearIntegral(PID_t *p); /* 清积分并预置 Actual1/Error：切状态时清掉上个状态的残留 */
void Angle_Realign(void);       /* 300ms 加速度计对准，只在静止时有效 */
void StopCar(void);             /* 停车 -> ST_IDLE，可从中断里调用 */
void StartErect(void);          /* 起立 -> ST_ERECT，内部有 300ms 阻塞 */

#endif /* __TIM3_PID_H */

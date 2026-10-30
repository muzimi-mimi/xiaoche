#ifndef __OLED_RENDERSTATUS_H
#define __OLED_RENDERSTATUS_H

/* ==========================================================================
 * OLED_RenderStatus.h —— 状态屏与电池检测的对外接口（配 OLED_RenderStatus.c）。
 *
 * ★ 本模块的参数宏（BAT_*）在 OLED_RenderStatus.c 顶部，这里没有参数。
 *
 * 本头由 car.h 统一 include，模块 .c 仍然只写 #include "car.h"。
 * ==========================================================================*/

#include "main.h"

/* ---------- 对外接口 ---------- */
void OLED_RenderStatus(void);   /* 整屏重画 + 电池巡检，只在主循环调用 */

#endif /* __OLED_RENDERSTATUS_H */

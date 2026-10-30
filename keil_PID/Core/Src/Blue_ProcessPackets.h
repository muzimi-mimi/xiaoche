#ifndef __BLUE_PROCESSPACKETS_H
#define __BLUE_PROCESSPACKETS_H

/* ==========================================================================
 * Blue_ProcessPackets.h —— 蓝牙下行协议解析（Blue_ProcessPackets.c 的配套头）。
 *
 * 域：裸字节命令之外的 [包] 分派 —— [1] [0] [t] [key,..] [slider,..] [joystick,..]。
 * 目前没有本模块独占的参数宏（用到的手上都是别模块的参数），
 * 建这个头是为了让四个模块的配对关系一致，以后协议相关的宏放这里。
 *
 * 本头由 car.h 统一 include，模块 .c 仍然只写 #include "car.h"。
 * ==========================================================================*/
#include "main.h"

/* ---------- 对外接口 ---------- */
void Blue_ProcessPackets(void);  /* 轮询两个接收缓冲并分派，只在主循环调用 */

#endif /* __BLUE_PROCESSPACKETS_H */

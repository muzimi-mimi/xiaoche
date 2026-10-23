#ifndef __SR04_H
#define __SR04_H

void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin);
uint32_t SR04_Init(void);
uint32_t SR04_GetDistance(void);

#endif
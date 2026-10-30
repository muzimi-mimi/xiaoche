#include "gpio.h"
#include "tim.h"
#include "main.h"

/* TIM3: prescaler 72-1 -> 1MHz, counter counts microseconds.
   ARR is 65535 so one echo (up to ~65ms) does not wrap. */

static volatile uint8_t EchoDone = 0;
uint32_t distance = 0;

void delay_us(uint32_t us)
{
    __HAL_TIM_SET_COUNTER(&htim3, 0);
    HAL_TIM_Base_Start(&htim3);
    while (__HAL_TIM_GET_COUNTER(&htim3) < us);
    HAL_TIM_Base_Stop(&htim3);
}

/* HAL_GPIO_EXTI_Callback 已移到 main.c 统一实现（PA5 用户按键）。
   本文件原来的 PA2 echo 分支随之移除 —— PA2 的 EXTI 与 PA3 的推挽输出
   在 MX_GPIO_Init 里从未被配置过，SR04 这条链路本来就没有工作。
   若将来要启用超声波，请先补上这两处 GPIO 配置，再把 GPIO_PIN_2 分支
   加回 main.c 的那个回调里。 */

/* Non-blocking measurement: starts one trigger when idle and returns the
   latest distance meanwhile. Call it once per main-loop iteration. */
uint32_t SR04_GetDistance(void)
{
    static uint8_t Measuring = 0;
    static uint32_t t0 = 0;
    static uint32_t lastTrig = 0;

    if (Measuring == 0)
    {
        /* HC-SR04 needs >=50ms between triggers */
        if ((HAL_GetTick() - lastTrig) < 50)
        {
            return distance;
        }

        EchoDone = 0;

        HAL_GPIO_WritePin(GPIOA, GPIO_PIN_3, GPIO_PIN_SET);
        delay_us(15);
        HAL_GPIO_WritePin(GPIOA, GPIO_PIN_3, GPIO_PIN_RESET);

        lastTrig = HAL_GetTick();
        t0 = lastTrig;
        Measuring = 1;
    }
    else if (EchoDone == 1)
    {
        Measuring = 0;
    }
    else if ((HAL_GetTick() - t0) > 30)
    {
        Measuring = 0;
        distance = 0;
        HAL_TIM_Base_Stop(&htim3);
    }

    return distance;
}

/* Keep this name for compatibility with main.c */
uint32_t SR04_Init(void)
{
    return SR04_GetDistance();
}

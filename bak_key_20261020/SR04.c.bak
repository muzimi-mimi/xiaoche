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

void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin)
{
    if (GPIO_Pin == GPIO_PIN_2)
    {
        if (HAL_GPIO_ReadPin(GPIOA, GPIO_PIN_2) == GPIO_PIN_SET)
        {
            /* echo rising edge: start timing */
            __HAL_TIM_SET_COUNTER(&htim3, 0);
            EchoDone = 0;
            HAL_TIM_Base_Start(&htim3);
        }
        else
        {
            /* echo falling edge: stop and convert us -> mm */
            HAL_TIM_Base_Stop(&htim3);
            distance = (uint32_t)(__HAL_TIM_GetCounter(&htim3) * 0.34f / 2.0f);
            EchoDone = 1;
        }
    }
}

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
#include "main.h"
#include "tim.h"
#include "gpio.h"
#include "encode.h"


int32_t ReadSpeed(TIM_HandleTypeDef *htim){
	int32_t tmp;
	tmp=(short)__HAL_TIM_GET_COUNTER(htim);
	__HAL_TIM_SET_COUNTER(htim,0);
	return tmp;
}
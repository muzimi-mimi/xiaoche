#include "main.h"
#include "tim.h"
#include "gpio.h"
#include "stm32f1xx_it.h"
#include "TB6612.h"
#include "STM32F1xx_HAL_TIM.h"

void TB6612_setPWM(int n,int PWM){
//	if(M1>0){
//		HAL_GPIO_WritePin(AIN1_GPIO_Port,AIN1_Pin,GPIO_PIN_SET);
//		HAL_GPIO_WritePin(AIN2_GPIO_Port,AIN2_Pin,GPIO_PIN_RESET);
//		__HAL_TIM_SetCompare(&htim1,TIM_CHANNEL_1,M1);
//	}
//	else if(M1<0){
//		HAL_GPIO_WritePin(AIN1_GPIO_Port,AIN1_Pin,GPIO_PIN_RESET);
//		HAL_GPIO_WritePin(AIN2_GPIO_Port,AIN2_Pin,GPIO_PIN_SET);
//		__HAL_TIM_SetCompare(&htim1,TIM_CHANNEL_1,-(M1));
//	}

//	if(M2>0){
//		HAL_GPIO_WritePin(BIN1_GPIO_Port,BIN1_Pin,GPIO_PIN_SET);
//		HAL_GPIO_WritePin(BIN2_GPIO_Port,BIN2_Pin,GPIO_PIN_RESET);
//		__HAL_TIM_SetCompare(&htim1,TIM_CHANNEL_4,M2);
//	}
//	else if(M2<0){
//		HAL_GPIO_WritePin(BIN1_GPIO_Port,BIN1_Pin,GPIO_PIN_RESET);
//		HAL_GPIO_WritePin(BIN2_GPIO_Port,BIN2_Pin,GPIO_PIN_SET);
//		__HAL_TIM_SetCompare(&htim1,TIM_CHANNEL_4,-(M2));
//	}
	if (n == 1)			//指定左电机
	{
		if (PWM >= 0)							//如果设置正转的PWM
		{
		HAL_GPIO_WritePin(AIN1_GPIO_Port,AIN1_Pin,GPIO_PIN_SET);
		HAL_GPIO_WritePin(AIN2_GPIO_Port,AIN2_Pin,GPIO_PIN_RESET);
		__HAL_TIM_SetCompare(&htim1,TIM_CHANNEL_1,PWM);
		}
		else									//否则，即设置反转的PWM
		{
		HAL_GPIO_WritePin(AIN1_GPIO_Port,AIN1_Pin,GPIO_PIN_RESET);
		HAL_GPIO_WritePin(AIN2_GPIO_Port,AIN2_Pin,GPIO_PIN_SET);
		__HAL_TIM_SetCompare(&htim1,TIM_CHANNEL_1,-(PWM));
		}
	}
	else if (n == 2)	//指定右电机
	{
		if (PWM >= 0)							//如果设置正转的PWM
		{
		HAL_GPIO_WritePin(BIN1_GPIO_Port,BIN1_Pin,GPIO_PIN_SET);
		HAL_GPIO_WritePin(BIN2_GPIO_Port,BIN2_Pin,GPIO_PIN_RESET);
		__HAL_TIM_SetCompare(&htim1,TIM_CHANNEL_4,PWM);
		}
		else									//否则，即设置反转的PWM
		{
		HAL_GPIO_WritePin(BIN1_GPIO_Port,BIN1_Pin,GPIO_PIN_RESET);
		HAL_GPIO_WritePin(BIN2_GPIO_Port,BIN2_Pin,GPIO_PIN_SET);
		__HAL_TIM_SetCompare(&htim1,TIM_CHANNEL_4,-(PWM));
		}
	}

}
	

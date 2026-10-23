                 // Device header
#include "gpio.h"

void MYI2C_W_SCL(GPIO_PinState BitValue){
	HAL_GPIO_WritePin(SCL_GPIO_Port,SCL_Pin,BitValue);
}

void MYI2C_W_SDA(GPIO_PinState BitValue){
	HAL_GPIO_WritePin(SDA_GPIO_Port,SDA_Pin,BitValue);
}

void I2C_Init(void){
	HAL_GPIO_WritePin(SCL_GPIO_Port,SCL_Pin,GPIO_PIN_SET);
	HAL_GPIO_WritePin(SDA_GPIO_Port,SDA_Pin,GPIO_PIN_SET);
}

uint8_t MYI2C_R_SDA(void){
	uint8_t BitValue;
	if(HAL_GPIO_ReadPin(SDA_GPIO_Port,SDA_Pin)==GPIO_PIN_RESET)
		BitValue=0;
	else
		BitValue=1;
	return BitValue;
}

void I2C_start(void){
	MYI2C_W_SCL(1);
	MYI2C_W_SDA(1);
	MYI2C_W_SDA(0);
	MYI2C_W_SCL(0);
}

void I2C_stop(void){
	
	MYI2C_W_SDA(0);

	MYI2C_W_SCL(1);	MYI2C_W_SDA(1);
}

void I2C_sendbyte(uint8_t byte){
	for(int i=0;i<8;i++){
		MYI2C_W_SDA((byte&(0x80>>i))?GPIO_PIN_SET:GPIO_PIN_RESET);
		MYI2C_W_SCL(1);
		MYI2C_W_SCL(0);
	}
}

uint8_t I2C_receivebyte(void){
	uint8_t byte=0x00;
	MYI2C_W_SDA(1);
	for(int i=0;i<8;i++){
		MYI2C_W_SCL(1);
		if(MYI2C_R_SDA()==1)
			byte|=(uint8_t)(0x80>>i);
		MYI2C_W_SCL(0);
	}
	return byte;
}

void I2C_sendAck(uint8_t byte){
		MYI2C_W_SDA(byte);
		MYI2C_W_SCL(1);
		MYI2C_W_SCL(0);
	
}

uint8_t I2C_receiveAck(void){
	uint8_t byte;
	MYI2C_W_SDA(1);
		MYI2C_W_SCL(1);
		byte=MYI2C_R_SDA();
		MYI2C_W_SCL(0);
	
	return byte;
}


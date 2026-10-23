#ifndef __MYI2C_H
#define __MYI2C_H

void MYI2C_W_SCL(GPIO_PinState BitValue);
void MYI2C_W_SDA(GPIO_PinState BitValue);
uint8_t MYI2C_R_SDA(void);
void I2C_start(void);
void I2C_stop(void);
void I2C_sendbyte(uint8_t byte);
uint8_t I2C_receivebyte(void);
void I2C_sendAck(uint8_t byte);
uint8_t I2C_receiveAck(void);
void I2C_Init(void);


#endif
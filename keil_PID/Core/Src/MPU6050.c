#include "gpio.h"
#include "myI2C.h"
#include "MPU6050_Reg.h"
#define MPU6050_address	0xD0

void MPU6050_WriteReg(uint8_t regaddress,uint8_t data){
	I2C_start();
	I2C_sendbyte(MPU6050_address);
	I2C_receiveAck();
	I2C_sendbyte(regaddress);
	I2C_receiveAck();
	I2C_sendbyte(data);
	I2C_receiveAck();
	I2C_stop();
}

uint8_t MPU6050_ReadReg(uint8_t regaddress){
	uint8_t data;
	I2C_start();
	I2C_sendbyte(MPU6050_address);
	I2C_receiveAck();
	I2C_sendbyte(regaddress);
	I2C_receiveAck();
	
	I2C_start();
	I2C_sendbyte(MPU6050_address|0x01);
	I2C_receiveAck();
	data=I2C_receivebyte();
	I2C_sendAck(1);
	I2C_stop();
	return data;
}

void MPU6050_ReadRegs(uint8_t RegAddress, uint8_t *DataArray, uint8_t Count)
{
	uint8_t i;
	
	I2C_start();						//I2C起始
	I2C_sendbyte(MPU6050_address);	//发送从机地址，读写位为0，表示即将写入
	I2C_receiveAck();					//接收应答
	I2C_sendbyte(RegAddress);			//发送寄存器地址
	I2C_receiveAck();					//接收应答
	
	I2C_start();						//I2C重复起始
	I2C_sendbyte(MPU6050_address | 0x01);	//发送从机地址，读写位为1，表示即将读取
	I2C_receiveAck();					//接收应答
	for (i = 0; i < Count; i ++)		//循环Count次，连续读取多个字节，MPU6050内部地址指针会自动自增
	{
		DataArray[i] = I2C_receivebyte();	//接收指定寄存器的数据，存入数组第i个数据
		if (i < Count - 1)				//未读取到最后一个字节
		{
			I2C_sendAck(0);			//正常发送应答，从机后续会继续输出下一个字节数据
		}
		else							//读取到了最后一个字节
		{
			I2C_sendAck(1);			//给非应答，从机后续将不会输出数据，主机收回总线控制权
		}
	}
	I2C_stop();						//I2C终止
}

void MPU6050_Init(void){
	I2C_Init();
	MPU6050_WriteReg(MPU6050_PWR_MGMT_1, 0x01);
	MPU6050_WriteReg(MPU6050_PWR_MGMT_2, 0x00);
	MPU6050_WriteReg(MPU6050_SMPLRT_DIV, 0x07);
	MPU6050_WriteReg(MPU6050_CONFIG, 0x00);
	MPU6050_WriteReg(MPU6050_GYRO_CONFIG, 0x18);
	MPU6050_WriteReg(MPU6050_ACCEL_CONFIG, 0x18);
}
uint8_t MPU6050_GetID(void)
{
	return MPU6050_ReadReg(MPU6050_WHO_AM_I);
}

void MPU6050_GetData(int16_t *AccX, int16_t *AccY, int16_t *AccZ, 
						int16_t *GyroX, int16_t *GyroY, int16_t *GyroZ)
{
//	uint8_t DataH, DataL;
//	
//	DataH = MPU6050_ReadReg(MPU6050_ACCEL_XOUT_H);
//	DataL = MPU6050_ReadReg(MPU6050_ACCEL_XOUT_L);
//	*AccX = (DataH << 8) | DataL;
//	
//	DataH = MPU6050_ReadReg(MPU6050_ACCEL_YOUT_H);
//	DataL = MPU6050_ReadReg(MPU6050_ACCEL_YOUT_L);
//	*AccY = (DataH << 8) | DataL;
//	
//	DataH = MPU6050_ReadReg(MPU6050_ACCEL_ZOUT_H);
//	DataL = MPU6050_ReadReg(MPU6050_ACCEL_ZOUT_L);
//	*AccZ = (DataH << 8) | DataL;
//	
//	DataH = MPU6050_ReadReg(MPU6050_GYRO_XOUT_H);
//	DataL = MPU6050_ReadReg(MPU6050_GYRO_XOUT_L);
//	*GyroX = (DataH << 8) | DataL;
//	
//	DataH = MPU6050_ReadReg(MPU6050_GYRO_YOUT_H);
//	DataL = MPU6050_ReadReg(MPU6050_GYRO_YOUT_L);
//	*GyroY = (DataH << 8) | DataL;
//	
//	DataH = MPU6050_ReadReg(MPU6050_GYRO_ZOUT_H);
//	DataL = MPU6050_ReadReg(MPU6050_GYRO_ZOUT_L);
//	*GyroZ = (DataH << 8) | DataL;


	uint8_t Data[14];
	
	/*通过MPU6050_ReadRegs连续读取多个数据，效率更高*/
	MPU6050_ReadRegs(MPU6050_ACCEL_XOUT_H, Data, 14);	//从MPU6050_ACCEL_XOUT_H开始，连续读取14个字节，存入Data数组里
	
	/*数据拼接，通过输出参数返回*/
	*AccX = (Data[0] << 8) | Data[1];		//Data[0]和Data[1]为加速度计X轴数据
	*AccY = (Data[2] << 8) | Data[3];		//Data[2]和Data[3]为加速度计Y轴数据
	*AccZ = (Data[4] << 8) | Data[5];		//Data[4]和Data[5]为加速度计Z轴数据
	
											//Data[6]和Data[7]为温度数据，此处暂时不用
	
	*GyroX = (Data[8] << 8) | Data[9];		//Data[8]和Data[9]为陀螺仪X轴数据
	*GyroY = (Data[10] << 8) | Data[11];	//Data[10]和Data[11]为陀螺仪Y轴数据
	*GyroZ = (Data[12] << 8) | Data[13];	//Data[12]和Data[13]为陀螺仪Z轴数据
}




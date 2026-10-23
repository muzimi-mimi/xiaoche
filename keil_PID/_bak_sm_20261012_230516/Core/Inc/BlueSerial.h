#ifndef __BLUE_SERIAL_H
#define __BLUE_SERIAL_H

#include <stdint.h>
#include <stdio.h>

#define BLUE_SERIAL_RX_NUM   2
#define BLUE_SERIAL_RX_SIZE  100

extern char BlueSerial_RxPacket[BLUE_SERIAL_RX_NUM][BLUE_SERIAL_RX_SIZE];
extern volatile uint8_t BlueSerial_RxFlag[BLUE_SERIAL_RX_NUM];

void BlueSerial_Init(void);
void BlueSerial_SendByte(uint8_t Byte);
void BlueSerial_SendArray(uint8_t *Array, uint16_t Length);
void BlueSerial_SendString(char *String);
void BlueSerial_SendNumber(uint32_t Number, uint8_t Length);
void BlueSerial_Printf(char *format, ...);

#endif

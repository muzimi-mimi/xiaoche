#ifndef __BLUE_SERIAL_H
#define __BLUE_SERIAL_H

#include <stdint.h>
#include <stdio.h>

#define BLUE_SERIAL_RX_NUM   2
#define BLUE_SERIAL_RX_SIZE  100

extern char BlueSerial_RxPacket[BLUE_SERIAL_RX_NUM][BLUE_SERIAL_RX_SIZE];
extern volatile uint8_t BlueSerial_RxFlag[BLUE_SERIAL_RX_NUM];

/* ===== bare-byte command channel (phone serial terminal, no brackets) =====
 * A byte arriving OUTSIDE a [ ... ] packet is captured here.
 * '1' = self-erect, '0' = emergency stop, 'T'/'t' = toggle line tracking
 * (the meaning of each byte is decided in main.c).
 * This runs in parallel with the [xxx] packet path, so BOTH forms work:
 *      send   [1]        or just    1
 *      send   [T]  does NOT work - only the bare byte toggles tracking
 * Only '0', '1', 'T' and 't' are captured, so CR/LF from the terminal is
 * ignored.  Anything else arriving outside [ ] is silently dropped. */
extern volatile uint8_t BlueSerial_CmdFlag;
extern volatile char    BlueSerial_CmdChar;

void BlueSerial_Init(void);
void BlueSerial_SendByte(uint8_t Byte);
void BlueSerial_SendArray(uint8_t *Array, uint16_t Length);
void BlueSerial_SendString(char *String);
void BlueSerial_SendNumber(uint32_t Number, uint8_t Length);
void BlueSerial_Printf(char *format, ...);

#endif

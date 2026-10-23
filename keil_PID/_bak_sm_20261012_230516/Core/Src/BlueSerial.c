#include "usart.h"
#include "BlueSerial.h"
#include <stdarg.h>
#include <string.h>

char BlueSerial_RxPacket[BLUE_SERIAL_RX_NUM][BLUE_SERIAL_RX_SIZE];
volatile uint8_t BlueSerial_RxFlag[BLUE_SERIAL_RX_NUM];

static uint8_t RxState = 0;
static uint16_t pRxPacket = 0;
static uint8_t rxBufIndex = 0;
static uint8_t BlueSerial_RxData;

void BlueSerial_Init(void)
{
    BlueSerial_RxFlag[0] = 0;
    BlueSerial_RxFlag[1] = 0;
    RxState = 0;
    pRxPacket = 0;
    rxBufIndex = 0;
    HAL_UART_Receive_IT(&huart3, &BlueSerial_RxData, 1);
}

void BlueSerial_SendByte(uint8_t Byte)
{
    HAL_UART_Transmit(&huart3, &Byte, 1, 10);
}

void BlueSerial_SendArray(uint8_t *Array, uint16_t Length)
{
    HAL_UART_Transmit(&huart3, Array, Length, 10);
}

void BlueSerial_SendString(char *String)
{
    HAL_UART_Transmit(&huart3, (uint8_t *)String, (uint16_t)strlen(String), 10);
}

uint32_t BlueSerial_Pow(uint32_t X, uint32_t Y)
{
    uint32_t Result = 1;
    while (Y--)
    {
        Result *= X;
    }
    return Result;
}

void BlueSerial_SendNumber(uint32_t Number, uint8_t Length)
{
    uint8_t i;
    for (i = 0; i < Length; i++)
    {
        BlueSerial_SendByte((uint8_t)(Number / BlueSerial_Pow(10, Length - i - 1) % 10 + '0'));
    }
}

void BlueSerial_Printf(char *format, ...)
{
    char String[100];
    va_list arg;
    va_start(arg, format);
    vsprintf(String, format, arg);
    va_end(arg);
    BlueSerial_SendString(String);
}

void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart)
{
    if (huart->Instance == USART3)
    {
        if (RxState == 0)
        {
            if (BlueSerial_RxData == '[')
            {
                if (BlueSerial_RxFlag[rxBufIndex])
                {
                    rxBufIndex = (rxBufIndex + 1) % BLUE_SERIAL_RX_NUM;
                }
                RxState = 1;
                pRxPacket = 0;
            }
        }
        else if (RxState == 1)
        {
            if (BlueSerial_RxData == ']')
            {
                RxState = 0;
                BlueSerial_RxPacket[rxBufIndex][pRxPacket] = '\0';
                BlueSerial_RxFlag[rxBufIndex] = 1;
                rxBufIndex = (rxBufIndex + 1) % BLUE_SERIAL_RX_NUM;
            }
            else
            {
                if (pRxPacket < BLUE_SERIAL_RX_SIZE - 1)
                {
                    BlueSerial_RxPacket[rxBufIndex][pRxPacket] = BlueSerial_RxData;
                    pRxPacket++;
                }
                else
                {
                    RxState = 0;
                    pRxPacket = 0;
                }
            }
        }

        HAL_UART_Receive_IT(&huart3, &BlueSerial_RxData, 1);
    }
}

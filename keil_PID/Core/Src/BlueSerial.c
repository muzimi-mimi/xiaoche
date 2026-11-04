#include "usart.h"
#include "BlueSerial.h"
#include <stdarg.h>
#include <string.h>

char BlueSerial_RxPacket[BLUE_SERIAL_RX_NUM][BLUE_SERIAL_RX_SIZE];
volatile uint8_t BlueSerial_RxFlag[BLUE_SERIAL_RX_NUM];

/* bare-byte command channel: see BlueSerial.h */
volatile uint8_t BlueSerial_CmdFlag = 0;
volatile char    BlueSerial_CmdChar = 0;

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

/* ★ 2026-11-04 新增：串口溢出后的"装死"救援。
 * 现象：发多字节包([joystick,...])时偶发收不到后续任何命令，SpeedPID.Target 被
 *   最后一条包锁死（实测锁在 1.4），必须断电重启才恢复。
 * 原因：HAL_UART_Receive_IT 会同时打开 PEIE/EIE，一旦 ORE(溢出) 触发，
 *   HAL_UART_IRQHandler 会调 UART_EndRxTransfer 把 RxState 退回 READY 并调用
 *   本回调——而工程原先没有这个回调，走的是 weak 空实现，于是**再也没有人
 *   重新调用 Receive_IT**，接收从此永久哑掉。AGENTS §5 记的就是这个坑。
 * 处置：清掉错误标志、丢弃半条包、把单字节接收重新挂上。 */
void HAL_UART_ErrorCallback(UART_HandleTypeDef *huart)
{
    if (huart->Instance == USART3)
    {
        __HAL_UART_CLEAR_OREFLAG(huart);
        __HAL_UART_CLEAR_FEFLAG(huart);
        __HAL_UART_CLEAR_NEFLAG(huart);
        __HAL_UART_CLEAR_PEFLAG(huart);

        huart->RxState = HAL_UART_STATE_READY;   /* HAL 已 EndRxTransfer，强制回到就绪 */
        RxState   = 0;                           /* 半条包丢掉，别把后续字节当包体 */
        pRxPacket = 0;

        HAL_UART_Receive_IT(&huart3, &BlueSerial_RxData, 1);
    }
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
            else if (BlueSerial_RxData == '0' || BlueSerial_RxData == '1' ||
                     BlueSerial_RxData == 'T' || BlueSerial_RxData == 't')
            {
                /* Bare command byte (not inside a packet): hand it to main.c.
                 *   '0'      emergency stop
                 *   '1'      self-erect
                 *   'T'/'t'  toggle line tracking  (handled in main.c)
                 * Only these four bytes are captured, so terminal CR/LF is ignored.
                 * A '1' inside "[joystick,1,2,3,4]" is NOT caught here,
                 * because those bytes arrive while RxState == 1.  Likewise a 'T'
                 * inside "[T]": that goes to the packet buffer instead. */
                BlueSerial_CmdChar = (char)BlueSerial_RxData;
                BlueSerial_CmdFlag = 1;
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

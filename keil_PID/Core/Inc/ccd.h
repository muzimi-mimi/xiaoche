#ifndef __CCD_H__
#define __CCD_H__

/* ============================================================================
 * TSL1401 线性 CCD 模块（HAL 版）
 *
 * 完全模仿参考工程：
 *   D:\Users\huang\Desktop\keil\CCD控制舵机\HARDWARE\CCD\ccd.c   (XJU 2017)
 * 变量名、函数名、算法结构（动态阈值 / 左右跳变沿 / 中线 / 野值抑制）以及
 * 上位机通信协议全部保留，只把标准外设库的 GPIO 换成 HAL。
 *
 * 引脚 —— 沿用本工程，也就是考试板 CN3：
 *     CLK = PB0      SI = PB1      AO = PA4 (ADC1_IN4)
 * 参考工程是 PA2 / PA3 / PA1，接线不通用，别照抄。
 *
 * 与参考工程的三处有意偏离（每一处都在 .c 里就地注明）：
 *   1) Dly_us() 用 DWT 周期计数器，不是空的 for 循环；
 *   2) 找沿前复位 Left/Right，并新增 CCD_Lost 丢线标志；
 *   3) 阈值统计从 ccd_adc[5] 起算，不用被排除在统计区间外的 ccd_adc[0]。
 * ==========================================================================*/

#include "main.h"

#define CCD_PIXELS      128

/* ---------------- 与参考工程同名的全局量 ---------------- */
extern uint8_t  ccd_adc[CCD_PIXELS];   /* 8 位像素 = Get_Adc()>>4，与参考一致 */
extern uint8_t  SciBuf[200];           /* 上位机帧缓冲，与参考一致 */
extern int      TIME_us;               /* CLK 半周期延时(us)，与参考同名 */

extern uint8_t  CCD_Zhongzhi;          /* 中线位置 0..127 */
extern uint8_t  CCD_Yuzhi;             /* 本帧动态阈值 */
extern uint8_t  CCD_Left;              /* 左跳变沿索引 */
extern uint8_t  CCD_Right;             /* 右跳变沿索引 */
extern uint16_t CCD_Max;               /* 本帧最亮（统计区间内） */
extern uint16_t CCD_Min;               /* 本帧最暗（统计区间内） */

/* 兼容旧名字：原工程里这个数组叫 CCD[] */
#define CCD  ccd_adc

/* ---------------- 新增（参考工程没有） ---------------- */
extern volatile uint8_t CCD_Lost;      /* 1 = 本帧没找到有效的线 */
extern uint16_t ccd_raw[CCD_PIXELS];   /* 12 位原始值，只给自动曝光用 */

extern uint8_t  CCD_Width;             /* 本帧通过检查的线宽 = Right-Left */

/* ---------------- 找沿的合理性门限 ---------------- */

/* 局部对比度下限：现在量的是"线左侧的白 - 线内的黑"，不再量 max-min。
 * 原因：max - min = c + g，光照梯度会被算进"对比度"里 —— 画面越不匀，
 * 门限越松，而实际检测越难，两者方向相反。
 * 原值 20 从未被满足过：实测 max-min 只有 10~13，所以中线一直冻在初值 64。 */
#define CCD_CONTRAST_MIN   4

/* 线宽合法区间（像素）。实测有效线宽 16~28、峰值 22，这里放宽到 8~45。
 * 主要用来挡掉"右沿落在左沿左边"那种帧 —— 左右两次搜索各自独立扫描，
 * 中间没有配对约束，实测 19.5% 的帧会这样（还有 13.6% 一帧都找不到）。 */
#define CCD_LW_MIN         16
#define CCD_LW_MAX         30

/* 阈值帧间平滑的移位量：T 取 1/4 新值 + 3/4 旧值。
 * 找沿用的是"连续 3 个 + 严格不等号"，有效阈值是一排离散的齿，齿间有洞：
 * 过渡像素恰好等于阈值时，> 和 < 同时不成立，整条沿直接消失。
 * 所以 T 帧间抖 1 级就足以在齿间跳，沿位置跟着跳 1~2 像素。低通把 T 按在一个齿里。
 * 代价：时间常数约 2^CCD_TH_SHIFT 帧（4 帧 ≈ 0.2s）。 */
#define CCD_TH_SHIFT       2

/* ---------------- 与参考工程同名的函数 ---------------- */
void  Ccd_Init(void);
void  Dly_us(int a);
void  RD_TSL(void);
void  slove_data(void);
void  sendToPc(void);
char  binToHex_high(uint8_t num);
char  binToHex_low(uint8_t num);
int   myabs(int a);

/* ---------------- 本工程扩展 ---------------- */
void  get_CCD(void);          /* 等价于 RD_TSL()，兼容 main.c 里的旧调用 */
void  CCD_SendFrame(void);    /* 只发帧、不重新采集，配合 TIM3 采集使用 */
void  CCD_AutoExposure(void);
extern volatile uint16_t CCD_Div;   /* 曝光 = CCD_Div x 10ms（TIM3 周期） */

#endif /* __CCD_H__ */

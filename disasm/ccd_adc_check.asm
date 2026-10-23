
========================================================================

** ELF Header Information

    File Name: D:\Users\huang\Desktop\keil\test\ccd\MDK-ARM\ccd\ccd.axf

    Machine class: ELFCLASS32 (32-bit)
    Data encoding: ELFDATA2LSB (Little endian)
    Header version: EV_CURRENT (Current version)
    Operating System ABI: none
    ABI Version: 0
    File Type: ET_EXEC (Executable) (2)
    Machine: EM_ARM (ARM)

    Image Entry point: 0x080000ed
    Flags: EF_ARM_HASENTRY + EF_ARM_ABI_FLOAT_SOFT (0x05000202)

    ARM ELF revision: 5 (ABI version 2)

    Conforms to Soft float procedure-call standard

    Built with
    Component: ARM Compiler 5.06 update 5 (build 528) Tool: armasm [4d35e1]
    Component: ARM Compiler 5.06 update 5 (build 528) Tool: armlink [4d35e2]

    Header size: 52 bytes (0x34)
    Program header entry size: 32 bytes (0x20)
    Section header entry size: 40 bytes (0x28)

    Program header entries: 1
    Section header entries: 16

    Program header offset: 614872 (0x000961d8)
    Section header offset: 614904 (0x000961f8)

    Section header string table index: 15

========================================================================

** Program header #0 (PT_LOAD) [PF_X + PF_W + PF_R + PF_ARM_ENTRY]
    Size : 14804 bytes (12732 bytes in file)
    Virtual address: 0x08000000 (Alignment 8)


========================================================================

** Section #1 'ER_IROM1' (SHT_PROGBITS) [SHF_ALLOC + SHF_EXECINSTR]
    Size   : 12684 bytes (alignment 4)
    Address: 0x08000000

    $d.realdata
    RESET
    __Vectors
        0x08000000:    20000848    H..     DCD    536873032
        0x08000004:    08000101    ....    DCD    134217985
        0x08000008:    08001d77    w...    DCD    134225271
        0x0800000c:    08001bbd    ....    DCD    134224829
        0x08000010:    08001d75    u...    DCD    134225269
        0x08000014:    080002f1    ....    DCD    134218481
        0x08000018:    080025bd    .%..    DCD    134227389
        0x0800001c:    00000000    ....    DCD    0
        0x08000020:    00000000    ....    DCD    0
        0x08000024:    00000000    ....    DCD    0
        0x08000028:    00000000    ....    DCD    0
        0x0800002c:    080021f5    .!..    DCD    134226421
        0x08000030:    080002f3    ....    DCD    134218483
        0x08000034:    00000000    ....    DCD    0
        0x08000038:    08002011    . ..    DCD    134225937
        0x0800003c:    080021f7    .!..    DCD    134226423
        0x08000040:    0800011b    ....    DCD    134218011
        0x08000044:    0800011b    ....    DCD    134218011
        0x08000048:    0800011b    ....    DCD    134218011
        0x0800004c:    0800011b    ....    DCD    134218011
        0x08000050:    0800011b    ....    DCD    134218011
        0x08000054:    0800011b    ....    DCD    134218011
        0x08000058:    0800011b    ....    DCD    134218011
        0x0800005c:    0800011b    ....    DCD    134218011
        0x08000060:    0800011b    ....    DCD    134218011
        0x08000064:    0800011b    ....    DCD    134218011
        0x08000068:    0800011b    ....    DCD    134218011
        0x0800006c:    0800011b    ....    DCD    134218011
        0x08000070:    0800011b    ....    DCD    134218011
        0x08000074:    0800011b    ....    DCD    134218011
        0x08000078:    0800011b    ....    DCD    134218011
        0x0800007c:    0800011b    ....    DCD    134218011
        0x08000080:    0800011b    ....    DCD    134218011
        0x08000084:    0800011b    ....    DCD    134218011
        0x08000088:    08000211    ....    DCD    134218257
        0x0800008c:    0800011b    ....    DCD    134218011
        0x08000090:    0800011b    ....    DCD    134218011
        0x08000094:    0800011b    ....    DCD    134218011
        0x08000098:    0800011b    ....    DCD    134218011
        0x0800009c:    0800011b    ....    DCD    134218011
        0x080000a0:    0800011b    ....    DCD    134218011
        0x080000a4:    0800011b    ....    DCD    134218011
        0x080000a8:    0800011b    ....    DCD    134218011
        0x080000ac:    0800011b    ....    DCD    134218011
        0x080000b0:    0800011b    ....    DCD    134218011
        0x080000b4:    08002275    u"..    DCD    134226549
        0x080000b8:    0800011b    ....    DCD    134218011
        0x080000bc:    0800011b    ....    DCD    134218011
        0x080000c0:    0800011b    ....    DCD    134218011
        0x080000c4:    0800011b    ....    DCD    134218011
        0x080000c8:    0800011b    ....    DCD    134218011
        0x080000cc:    0800011b    ....    DCD    134218011
        0x080000d0:    0800011b    ....    DCD    134218011
        0x080000d4:    080025b1    .%..    DCD    134227377
        0x080000d8:    0800011b    ....    DCD    134218011
        0x080000dc:    0800011b    ....    DCD    134218011
        0x080000e0:    0800011b    ....    DCD    134218011
        0x080000e4:    0800011b    ....    DCD    134218011
        0x080000e8:    0800011b    ....    DCD    134218011
    $t
    .ARM.Collect$$$$00000000
    .ARM.Collect$$$$00000001
    __Vectors_End
    __main
    _main_stk
        0x080000ec:    f8dfd00c    ....    LDR      sp,__lit__00000000 ; [0x80000fc] = 0x20000848
    .ARM.Collect$$$$00000004
    _main_scatterload
        0x080000f0:    f000f86c    ..l.    BL       __scatterload ; 0x80001cc
    .ARM.Collect$$$$00000008
    .ARM.Collect$$$$0000000A
    .ARM.Collect$$$$0000000B
    __main_after_scatterload
    _main_clock
    _main_cpp_init
    _main_init
        0x080000f4:    4800        .H      LDR      r0,[pc,#0] ; [0x80000f8] = 0x8002aa1
        0x080000f6:    4700        .G      BX       r0
    $d
        0x080000f8:    08002aa1    .*..    DCD    134228641
    .ARM.Collect$$$$00002712
    __lit__00000000
    .ARM.Collect$$$$0000000D
    .ARM.Collect$$$$0000000F
    __rt_final_cpp
    __rt_final_exit
        0x080000fc:    20000848    H..     DCD    536873032
    $t
    .text
    Reset_Handler
        0x08000100:    4806        .H      LDR      r0,[pc,#24] ; [0x800011c] = 0x8002273
        0x08000102:    4780        .G      BLX      r0
        0x08000104:    4806        .H      LDR      r0,[pc,#24] ; [0x8000120] = 0x80000ed
        0x08000106:    4700        .G      BX       r0
        0x08000108:    e7fe        ..      B        0x8000108 ; Reset_Handler + 8
        0x0800010a:    e7fe        ..      B        0x800010a ; Reset_Handler + 10
        0x0800010c:    e7fe        ..      B        0x800010c ; Reset_Handler + 12
        0x0800010e:    e7fe        ..      B        0x800010e ; Reset_Handler + 14
        0x08000110:    e7fe        ..      B        0x8000110 ; Reset_Handler + 16
        0x08000112:    e7fe        ..      B        0x8000112 ; Reset_Handler + 18
        0x08000114:    e7fe        ..      B        0x8000114 ; Reset_Handler + 20
        0x08000116:    e7fe        ..      B        0x8000116 ; Reset_Handler + 22
        0x08000118:    e7fe        ..      B        0x8000118 ; Reset_Handler + 24
    CAN1_RX1_IRQHandler
    CAN1_SCE_IRQHandler
    DMA1_Channel1_IRQHandler
    DMA1_Channel2_IRQHandler
    DMA1_Channel3_IRQHandler
    DMA1_Channel4_IRQHandler
    DMA1_Channel5_IRQHandler
    DMA1_Channel6_IRQHandler
    DMA1_Channel7_IRQHandler
    EXTI0_IRQHandler
    EXTI15_10_IRQHandler
    EXTI1_IRQHandler
    EXTI2_IRQHandler
    EXTI3_IRQHandler
    EXTI4_IRQHandler
    EXTI9_5_IRQHandler
    FLASH_IRQHandler
    I2C1_ER_IRQHandler
    I2C1_EV_IRQHandler
    I2C2_ER_IRQHandler
    I2C2_EV_IRQHandler
    PVD_IRQHandler
    RCC_IRQHandler
    RTC_Alarm_IRQHandler
    RTC_IRQHandler
    SPI1_IRQHandler
    SPI2_IRQHandler
    TAMPER_IRQHandler
    TIM1_BRK_IRQHandler
    TIM1_CC_IRQHandler
    TIM1_TRG_COM_IRQHandler
    TIM1_UP_IRQHandler
    TIM2_IRQHandler
    TIM4_IRQHandler
    USART2_IRQHandler
    USART3_IRQHandler
    USBWakeUp_IRQHandler
    USB_HP_CAN1_TX_IRQHandler
    USB_LP_CAN1_RX0_IRQHandler
    WWDG_IRQHandler
        0x0800011a:    e7fe        ..      B        CAN1_RX1_IRQHandler ; 0x800011a
    $d
        0x0800011c:    08002273    s"..    DCD    134226547
        0x08000120:    080000ed    ....    DCD    134217965
    $t
    .text
    __aeabi_llsr
    _ll_ushift_r
        0x08000124:    2a20         *      CMP      r2,#0x20
        0x08000126:    db04        ..      BLT      0x8000132 ; __aeabi_llsr + 14
        0x08000128:    3a20         :      SUBS     r2,r2,#0x20
        0x0800012a:    fa21f002    !...    LSR      r0,r1,r2
        0x0800012e:    2100        .!      MOVS     r1,#0
        0x08000130:    4770        pG      BX       lr
        0x08000132:    fa21f302    !...    LSR      r3,r1,r2
        0x08000136:    40d0        .@      LSRS     r0,r0,r2
        0x08000138:    f1c20220    .. .    RSB      r2,r2,#0x20
        0x0800013c:    4091        .@      LSLS     r1,r1,r2
        0x0800013e:    4308        .C      ORRS     r0,r0,r1
        0x08000140:    4619        .F      MOV      r1,r3
        0x08000142:    4770        pG      BX       lr
    .text
    __aeabi_memset
    __aeabi_memset4
    __aeabi_memset8
        0x08000144:    b2d2        ..      UXTB     r2,r2
        0x08000146:    e001        ..      B        0x800014c ; __aeabi_memset + 8
        0x08000148:    f8002b01    ...+    STRB     r2,[r0],#1
        0x0800014c:    1e49        I.      SUBS     r1,r1,#1
        0x0800014e:    d2fb        ..      BCS      0x8000148 ; __aeabi_memset + 4
        0x08000150:    4770        pG      BX       lr
    __aeabi_memclr
    __aeabi_memclr4
    __aeabi_memclr8
        0x08000152:    2200        ."      MOVS     r2,#0
        0x08000154:    e7f6        ..      B        __aeabi_memset ; 0x8000144
    _memset$wrapper
        0x08000156:    b510        ..      PUSH     {r4,lr}
        0x08000158:    4613        .F      MOV      r3,r2
        0x0800015a:    460a        .F      MOV      r2,r1
        0x0800015c:    4604        .F      MOV      r4,r0
        0x0800015e:    4619        .F      MOV      r1,r3
        0x08000160:    f7fffff0    ....    BL       __aeabi_memset ; 0x8000144
        0x08000164:    4620         F      MOV      r0,r4
        0x08000166:    bd10        ..      POP      {r4,pc}
    .text
    __aeabi_uldivmod
        0x08000168:    e92d5ff0    -.._    PUSH     {r4-r12,lr}
        0x0800016c:    4605        .F      MOV      r5,r0
        0x0800016e:    2000        .       MOVS     r0,#0
        0x08000170:    4692        .F      MOV      r10,r2
        0x08000172:    469b        .F      MOV      r11,r3
        0x08000174:    4688        .F      MOV      r8,r1
        0x08000176:    4606        .F      MOV      r6,r0
        0x08000178:    4681        .F      MOV      r9,r0
        0x0800017a:    2440        @$      MOVS     r4,#0x40
        0x0800017c:    e01b        ..      B        0x80001b6 ; __aeabi_uldivmod + 78
        0x0800017e:    4628        (F      MOV      r0,r5
        0x08000180:    4641        AF      MOV      r1,r8
        0x08000182:    4647        GF      MOV      r7,r8
        0x08000184:    4622        "F      MOV      r2,r4
        0x08000186:    f7ffffcd    ....    BL       __aeabi_llsr ; 0x8000124
        0x0800018a:    4653        SF      MOV      r3,r10
        0x0800018c:    465a        ZF      MOV      r2,r11
        0x0800018e:    1ac0        ..      SUBS     r0,r0,r3
        0x08000190:    4191        .A      SBCS     r1,r1,r2
        0x08000192:    d310        ..      BCC      0x80001b6 ; __aeabi_uldivmod + 78
        0x08000194:    4611        .F      MOV      r1,r2
        0x08000196:    4618        .F      MOV      r0,r3
        0x08000198:    4622        "F      MOV      r2,r4
        0x0800019a:    f000f829    ..).    BL       __aeabi_llsl ; 0x80001f0
        0x0800019e:    1a2d        -.      SUBS     r5,r5,r0
        0x080001a0:    eb670801    g...    SBC      r8,r7,r1
        0x080001a4:    464f        OF      MOV      r7,r9
        0x080001a6:    4622        "F      MOV      r2,r4
        0x080001a8:    2001        .       MOVS     r0,#1
        0x080001aa:    2100        .!      MOVS     r1,#0
        0x080001ac:    f000f820    .. .    BL       __aeabi_llsl ; 0x80001f0
        0x080001b0:    eb170900    ....    ADDS     r9,r7,r0
        0x080001b4:    414e        NA      ADCS     r6,r6,r1
        0x080001b6:    1e20         .      SUBS     r0,r4,#0
        0x080001b8:    f1a40401    ....    SUB      r4,r4,#1
        0x080001bc:    dcdf        ..      BGT      0x800017e ; __aeabi_uldivmod + 22
        0x080001be:    4648        HF      MOV      r0,r9
        0x080001c0:    4631        1F      MOV      r1,r6
        0x080001c2:    462a        *F      MOV      r2,r5
        0x080001c4:    4643        CF      MOV      r3,r8
        0x080001c6:    e8bd9ff0    ....    POP      {r4-r12,pc}
        0x080001ca:    0000        ..      MOVS     r0,r0
    .text
    __scatterload
    __scatterload_rt2
        0x080001cc:    4c06        .L      LDR      r4,[pc,#24] ; [0x80001e8] = 0x800316c
        0x080001ce:    4d07        .M      LDR      r5,[pc,#28] ; [0x80001ec] = 0x800318c
        0x080001d0:    e006        ..      B        0x80001e0 ; __scatterload + 20
        0x080001d2:    68e0        .h      LDR      r0,[r4,#0xc]
        0x080001d4:    f0400301    @...    ORR      r3,r0,#1
        0x080001d8:    e8940007    ....    LDM      r4,{r0-r2}
        0x080001dc:    4798        .G      BLX      r3
        0x080001de:    3410        .4      ADDS     r4,r4,#0x10
        0x080001e0:    42ac        .B      CMP      r4,r5
        0x080001e2:    d3f6        ..      BCC      0x80001d2 ; __scatterload + 6
        0x080001e4:    f7ffff86    ....    BL       __main_after_scatterload ; 0x80000f4
    $d
        0x080001e8:    0800316c    l1..    DCD    134230380
        0x080001ec:    0800318c    .1..    DCD    134230412
    $t
    .text
    __aeabi_llsl
    _ll_shift_l
        0x080001f0:    2a20         *      CMP      r2,#0x20
        0x080001f2:    db04        ..      BLT      0x80001fe ; __aeabi_llsl + 14
        0x080001f4:    3a20         :      SUBS     r2,r2,#0x20
        0x080001f6:    fa00f102    ....    LSL      r1,r0,r2
        0x080001fa:    2000        .       MOVS     r0,#0
        0x080001fc:    4770        pG      BX       lr
        0x080001fe:    4091        .@      LSLS     r1,r1,r2
        0x08000200:    f1c20320    .. .    RSB      r3,r2,#0x20
        0x08000204:    fa20f303     ...    LSR      r3,r0,r3
        0x08000208:    4319        .C      ORRS     r1,r1,r3
        0x0800020a:    4090        .@      LSLS     r0,r0,r2
        0x0800020c:    4770        pG      BX       lr
        0x0800020e:    0000        ..      MOVS     r0,r0
    i.ADC1_2_IRQHandler
    ADC1_2_IRQHandler
        0x08000210:    4801        .H      LDR      r0,[pc,#4] ; [0x8000218] = 0x20000388
        0x08000212:    f000b98b    ....    B.W      HAL_ADC_IRQHandler ; 0x800052c
    $d
        0x08000216:    0000        ..      DCW    0
        0x08000218:    20000388    ...     DCD    536871816
    $t
    i.ADC_ConversionStop_Disable
    ADC_ConversionStop_Disable
        0x0800021c:    b570        p.      PUSH     {r4-r6,lr}
        0x0800021e:    4604        .F      MOV      r4,r0
        0x08000220:    6800        .h      LDR      r0,[r0,#0]
        0x08000222:    6881        .h      LDR      r1,[r0,#8]
        0x08000224:    43c9        .C      MVNS     r1,r1
        0x08000226:    07c9        ..      LSLS     r1,r1,#31
        0x08000228:    d117        ..      BNE      0x800025a ; ADC_ConversionStop_Disable + 62
        0x0800022a:    6881        .h      LDR      r1,[r0,#8]
        0x0800022c:    f0210101    !...    BIC      r1,r1,#1
        0x08000230:    6081        .`      STR      r1,[r0,#8]
        0x08000232:    f000fd11    ....    BL       HAL_GetTick ; 0x8000c58
        0x08000236:    4605        .F      MOV      r5,r0
        0x08000238:    e00a        ..      B        0x8000250 ; ADC_ConversionStop_Disable + 52
        0x0800023a:    bf00        ..      NOP      
        0x0800023c:    f000fd0c    ....    BL       HAL_GetTick ; 0x8000c58
        0x08000240:    1b40        @.      SUBS     r0,r0,r5
        0x08000242:    2802        .(      CMP      r0,#2
        0x08000244:    d904        ..      BLS      0x8000250 ; ADC_ConversionStop_Disable + 52
        0x08000246:    6820         h      LDR      r0,[r4,#0]
        0x08000248:    6880        .h      LDR      r0,[r0,#8]
        0x0800024a:    43c0        .C      MVNS     r0,r0
        0x0800024c:    07c0        ..      LSLS     r0,r0,#31
        0x0800024e:    d006        ..      BEQ      0x800025e ; ADC_ConversionStop_Disable + 66
        0x08000250:    6820         h      LDR      r0,[r4,#0]
        0x08000252:    6880        .h      LDR      r0,[r0,#8]
        0x08000254:    43c0        .C      MVNS     r0,r0
        0x08000256:    07c0        ..      LSLS     r0,r0,#31
        0x08000258:    d0f0        ..      BEQ      0x800023c ; ADC_ConversionStop_Disable + 32
        0x0800025a:    2000        .       MOVS     r0,#0
        0x0800025c:    bd70        p.      POP      {r4-r6,pc}
        0x0800025e:    6aa0        .j      LDR      r0,[r4,#0x28]
        0x08000260:    f0400010    @...    ORR      r0,r0,#0x10
        0x08000264:    62a0        .b      STR      r0,[r4,#0x28]
        0x08000266:    6ae0        .j      LDR      r0,[r4,#0x2c]
        0x08000268:    f0400001    @...    ORR      r0,r0,#1
        0x0800026c:    62e0        .b      STR      r0,[r4,#0x2c]
        0x0800026e:    2001        .       MOVS     r0,#1
        0x08000270:    bd70        p.      POP      {r4-r6,pc}
        0x08000272:    0000        ..      MOVS     r0,r0
    i.ADC_Enable
    ADC_Enable
        0x08000274:    b5f8        ..      PUSH     {r3-r7,lr}
        0x08000276:    2600        .&      MOVS     r6,#0
        0x08000278:    4604        .F      MOV      r4,r0
        0x0800027a:    9600        ..      STR      r6,[sp,#0]
        0x0800027c:    6800        .h      LDR      r0,[r0,#0]
        0x0800027e:    6881        .h      LDR      r1,[r0,#8]
        0x08000280:    43c9        .C      MVNS     r1,r1
        0x08000282:    07c9        ..      LSLS     r1,r1,#31
        0x08000284:    d02d        -.      BEQ      0x80002e2 ; ADC_Enable + 110
        0x08000286:    6881        .h      LDR      r1,[r0,#8]
        0x08000288:    f0410101    A...    ORR      r1,r1,#1
        0x0800028c:    6081        .`      STR      r1,[r0,#8]
        0x0800028e:    4816        .H      LDR      r0,[pc,#88] ; [0x80002e8] = 0x20000028
        0x08000290:    4916        .I      LDR      r1,[pc,#88] ; [0x80002ec] = 0xf4240
        0x08000292:    6800        .h      LDR      r0,[r0,#0]
        0x08000294:    fbb0f0f1    ....    UDIV     r0,r0,r1
        0x08000298:    e000        ..      B        0x800029c ; ADC_Enable + 40
        0x0800029a:    1e40        @.      SUBS     r0,r0,#1
        0x0800029c:    9000        ..      STR      r0,[sp,#0]
        0x0800029e:    2800        .(      CMP      r0,#0
        0x080002a0:    d1fb        ..      BNE      0x800029a ; ADC_Enable + 38
        0x080002a2:    f000fcd9    ....    BL       HAL_GetTick ; 0x8000c58
        0x080002a6:    4605        .F      MOV      r5,r0
        0x080002a8:    e016        ..      B        0x80002d8 ; ADC_Enable + 100
        0x080002aa:    bf00        ..      NOP      
        0x080002ac:    f000fcd4    ....    BL       HAL_GetTick ; 0x8000c58
        0x080002b0:    1b40        @.      SUBS     r0,r0,r5
        0x080002b2:    2802        .(      CMP      r0,#2
        0x080002b4:    d910        ..      BLS      0x80002d8 ; ADC_Enable + 100
        0x080002b6:    6820         h      LDR      r0,[r4,#0]
        0x080002b8:    6880        .h      LDR      r0,[r0,#8]
        0x080002ba:    43c0        .C      MVNS     r0,r0
        0x080002bc:    07c0        ..      LSLS     r0,r0,#31
        0x080002be:    d00b        ..      BEQ      0x80002d8 ; ADC_Enable + 100
        0x080002c0:    6aa0        .j      LDR      r0,[r4,#0x28]
        0x080002c2:    f0400010    @...    ORR      r0,r0,#0x10
        0x080002c6:    62a0        .b      STR      r0,[r4,#0x28]
        0x080002c8:    6ae0        .j      LDR      r0,[r4,#0x2c]
        0x080002ca:    f0400001    @...    ORR      r0,r0,#1
        0x080002ce:    62e0        .b      STR      r0,[r4,#0x2c]
        0x080002d0:    f8846024    ..$`    STRB     r6,[r4,#0x24]
        0x080002d4:    2001        .       MOVS     r0,#1
        0x080002d6:    bdf8        ..      POP      {r3-r7,pc}
        0x080002d8:    6820         h      LDR      r0,[r4,#0]
        0x080002da:    6880        .h      LDR      r0,[r0,#8]
        0x080002dc:    43c0        .C      MVNS     r0,r0
        0x080002de:    07c0        ..      LSLS     r0,r0,#31
        0x080002e0:    d1e4        ..      BNE      0x80002ac ; ADC_Enable + 56
        0x080002e2:    2000        .       MOVS     r0,#0
        0x080002e4:    bdf8        ..      POP      {r3-r7,pc}
    $d
        0x080002e6:    0000        ..      DCW    0
        0x080002e8:    20000028    (..     DCD    536870952
        0x080002ec:    000f4240    @B..    DCD    1000000
    $t
    i.BusFault_Handler
    BusFault_Handler
        0x080002f0:    e7fe        ..      B        BusFault_Handler ; 0x80002f0
    i.DebugMon_Handler
    DebugMon_Handler
        0x080002f2:    4770        pG      BX       lr
    i.Dly_us
    Dly_us
        0x080002f4:    b510        ..      PUSH     {r4,lr}
        0x080002f6:    2800        .(      CMP      r0,#0
        0x080002f8:    dd1b        ..      BLE      0x8000332 ; Dly_us + 62
        0x080002fa:    4a0e        .J      LDR      r2,[pc,#56] ; [0x8000334] = 0x20000000
        0x080002fc:    490e        .I      LDR      r1,[pc,#56] ; [0x8000338] = 0xe0001000
        0x080002fe:    7953        Sy      LDRB     r3,[r2,#5]
        0x08000300:    b963        c.      CBNZ     r3,0x800031c ; Dly_us + 40
        0x08000302:    4b0e        .K      LDR      r3,[pc,#56] ; [0x800033c] = 0xe000edfc
        0x08000304:    681c        .h      LDR      r4,[r3,#0]
        0x08000306:    f0447480    D..t    ORR      r4,r4,#0x1000000
        0x0800030a:    601c        .`      STR      r4,[r3,#0]
        0x0800030c:    2300        .#      MOVS     r3,#0
        0x0800030e:    604b        K`      STR      r3,[r1,#4]
        0x08000310:    680b        .h      LDR      r3,[r1,#0]
        0x08000312:    f0430301    C...    ORR      r3,r3,#1
        0x08000316:    600b        .`      STR      r3,[r1,#0]
        0x08000318:    2301        .#      MOVS     r3,#1
        0x0800031a:    7153        Sq      STRB     r3,[r2,#5]
        0x0800031c:    684b        Kh      LDR      r3,[r1,#4]
        0x0800031e:    4a08        .J      LDR      r2,[pc,#32] ; [0x8000340] = 0x20000028
        0x08000320:    4c08        .L      LDR      r4,[pc,#32] ; [0x8000344] = 0xf4240
        0x08000322:    6812        .h      LDR      r2,[r2,#0]
        0x08000324:    fbb2f2f4    ....    UDIV     r2,r2,r4
        0x08000328:    4342        BC      MULS     r2,r0,r2
        0x0800032a:    6848        Hh      LDR      r0,[r1,#4]
        0x0800032c:    1ac0        ..      SUBS     r0,r0,r3
        0x0800032e:    4290        .B      CMP      r0,r2
        0x08000330:    d3fb        ..      BCC      0x800032a ; Dly_us + 54
        0x08000332:    bd10        ..      POP      {r4,pc}
    $d
        0x08000334:    20000000    ...     DCD    536870912
        0x08000338:    e0001000    ....    DCD    3758100480
        0x0800033c:    e000edfc    ....    DCD    3758157308
        0x08000340:    20000028    (..     DCD    536870952
        0x08000344:    000f4240    @B..    DCD    1000000
    $t
    i.Error_Handler
    Error_Handler
        0x08000348:    b672        r.      CPSID    i
        0x0800034a:    e7fe        ..      B        0x800034a ; Error_Handler + 2
    i.HAL_ADCEx_Calibration_Start
    HAL_ADCEx_Calibration_Start
        0x0800034c:    b5f8        ..      PUSH     {r3-r7,lr}
        0x0800034e:    2500        .%      MOVS     r5,#0
        0x08000350:    4604        .F      MOV      r4,r0
        0x08000352:    9500        ..      STR      r5,[sp,#0]
        0x08000354:    f8900024    ..$.    LDRB     r0,[r0,#0x24]
        0x08000358:    2801        .(      CMP      r0,#1
        0x0800035a:    d00b        ..      BEQ      0x8000374 ; HAL_ADCEx_Calibration_Start + 40
        0x0800035c:    2001        .       MOVS     r0,#1
        0x0800035e:    f8840024    ..$.    STRB     r0,[r4,#0x24]
        0x08000362:    4620         F      MOV      r0,r4
        0x08000364:    f7ffff5a    ..Z.    BL       ADC_ConversionStop_Disable ; 0x800021c
        0x08000368:    4620         F      MOV      r0,r4
        0x0800036a:    f7ffff83    ....    BL       ADC_Enable ; 0x8000274
        0x0800036e:    0006        ..      MOVS     r6,r0
        0x08000370:    d002        ..      BEQ      0x8000378 ; HAL_ADCEx_Calibration_Start + 44
        0x08000372:    e050        P.      B        0x8000416 ; HAL_ADCEx_Calibration_Start + 202
        0x08000374:    2002        .       MOVS     r0,#2
        0x08000376:    bdf8        ..      POP      {r3-r7,pc}
        0x08000378:    6aa0        .j      LDR      r0,[r4,#0x28]
        0x0800037a:    f4205088     ..P    BIC      r0,r0,#0x1100
        0x0800037e:    f0400002    @...    ORR      r0,r0,#2
        0x08000382:    62a0        .b      STR      r0,[r4,#0x28]
        0x08000384:    2002        .       MOVS     r0,#2
        0x08000386:    f000fd05    ....    BL       HAL_RCCEx_GetPeriphCLKFreq ; 0x8000d94
        0x0800038a:    4925        %I      LDR      r1,[pc,#148] ; [0x8000420] = 0x20000028
        0x0800038c:    6809        .h      LDR      r1,[r1,#0]
        0x0800038e:    fbb1f0f0    ....    UDIV     r0,r1,r0
        0x08000392:    0040        @.      LSLS     r0,r0,#1
        0x08000394:    e000        ..      B        0x8000398 ; HAL_ADCEx_Calibration_Start + 76
        0x08000396:    1e40        @.      SUBS     r0,r0,#1
        0x08000398:    9000        ..      STR      r0,[sp,#0]
        0x0800039a:    2800        .(      CMP      r0,#0
        0x0800039c:    d1fb        ..      BNE      0x8000396 ; HAL_ADCEx_Calibration_Start + 74
        0x0800039e:    6820         h      LDR      r0,[r4,#0]
        0x080003a0:    6881        .h      LDR      r1,[r0,#8]
        0x080003a2:    f0410108    A...    ORR      r1,r1,#8
        0x080003a6:    6081        .`      STR      r1,[r0,#8]
        0x080003a8:    f000fc56    ..V.    BL       HAL_GetTick ; 0x8000c58
        0x080003ac:    4607        .F      MOV      r7,r0
        0x080003ae:    e008        ..      B        0x80003c2 ; HAL_ADCEx_Calibration_Start + 118
        0x080003b0:    f000fc52    ..R.    BL       HAL_GetTick ; 0x8000c58
        0x080003b4:    1bc0        ..      SUBS     r0,r0,r7
        0x080003b6:    280a        .(      CMP      r0,#0xa
        0x080003b8:    d903        ..      BLS      0x80003c2 ; HAL_ADCEx_Calibration_Start + 118
        0x080003ba:    6820         h      LDR      r0,[r4,#0]
        0x080003bc:    6880        .h      LDR      r0,[r0,#8]
        0x080003be:    0700        ..      LSLS     r0,r0,#28
        0x080003c0:    d415        ..      BMI      0x80003ee ; HAL_ADCEx_Calibration_Start + 162
        0x080003c2:    6820         h      LDR      r0,[r4,#0]
        0x080003c4:    6880        .h      LDR      r0,[r0,#8]
        0x080003c6:    0700        ..      LSLS     r0,r0,#28
        0x080003c8:    d4f2        ..      BMI      0x80003b0 ; HAL_ADCEx_Calibration_Start + 100
        0x080003ca:    6820         h      LDR      r0,[r4,#0]
        0x080003cc:    6881        .h      LDR      r1,[r0,#8]
        0x080003ce:    f0410104    A...    ORR      r1,r1,#4
        0x080003d2:    6081        .`      STR      r1,[r0,#8]
        0x080003d4:    f000fc40    ..@.    BL       HAL_GetTick ; 0x8000c58
        0x080003d8:    4607        .F      MOV      r7,r0
        0x080003da:    e012        ..      B        0x8000402 ; HAL_ADCEx_Calibration_Start + 182
        0x080003dc:    f000fc3c    ..<.    BL       HAL_GetTick ; 0x8000c58
        0x080003e0:    1bc0        ..      SUBS     r0,r0,r7
        0x080003e2:    280a        .(      CMP      r0,#0xa
        0x080003e4:    d90d        ..      BLS      0x8000402 ; HAL_ADCEx_Calibration_Start + 182
        0x080003e6:    6820         h      LDR      r0,[r4,#0]
        0x080003e8:    6880        .h      LDR      r0,[r0,#8]
        0x080003ea:    0740        @.      LSLS     r0,r0,#29
        0x080003ec:    d509        ..      BPL      0x8000402 ; HAL_ADCEx_Calibration_Start + 182
        0x080003ee:    6aa0        .j      LDR      r0,[r4,#0x28]
        0x080003f0:    f0200002     ...    BIC      r0,r0,#2
        0x080003f4:    f0400010    @...    ORR      r0,r0,#0x10
        0x080003f8:    62a0        .b      STR      r0,[r4,#0x28]
        0x080003fa:    f8845024    ..$P    STRB     r5,[r4,#0x24]
        0x080003fe:    2001        .       MOVS     r0,#1
        0x08000400:    bdf8        ..      POP      {r3-r7,pc}
        0x08000402:    6820         h      LDR      r0,[r4,#0]
        0x08000404:    6880        .h      LDR      r0,[r0,#8]
        0x08000406:    0740        @.      LSLS     r0,r0,#29
        0x08000408:    d4e8        ..      BMI      0x80003dc ; HAL_ADCEx_Calibration_Start + 144
        0x0800040a:    6aa0        .j      LDR      r0,[r4,#0x28]
        0x0800040c:    f0200002     ...    BIC      r0,r0,#2
        0x08000410:    f0400001    @...    ORR      r0,r0,#1
        0x08000414:    62a0        .b      STR      r0,[r4,#0x28]
        0x08000416:    f8845024    ..$P    STRB     r5,[r4,#0x24]
        0x0800041a:    4630        0F      MOV      r0,r6
        0x0800041c:    bdf8        ..      POP      {r3-r7,pc}
    $d
        0x0800041e:    0000        ..      DCW    0
        0x08000420:    20000028    (..     DCD    536870952
    $t
    i.HAL_ADCEx_InjectedConvCpltCallback
    HAL_ADCEx_InjectedConvCpltCallback
        0x08000424:    4770        pG      BX       lr
        0x08000426:    0000        ..      MOVS     r0,r0
    i.HAL_ADC_ConfigChannel
    HAL_ADC_ConfigChannel
        0x08000428:    b5f8        ..      PUSH     {r3-r7,lr}
        0x0800042a:    2400        .$      MOVS     r4,#0
        0x0800042c:    9400        ..      STR      r4,[sp,#0]
        0x0800042e:    f8902024    ..$     LDRB     r2,[r0,#0x24]
        0x08000432:    4625        %F      MOV      r5,r4
        0x08000434:    2a01        .*      CMP      r2,#1
        0x08000436:    d012        ..      BEQ      0x800045e ; HAL_ADC_ConfigChannel + 54
        0x08000438:    2201        ."      MOVS     r2,#1
        0x0800043a:    f8802024    ..$     STRB     r2,[r0,#0x24]
        0x0800043e:    684a        Jh      LDR      r2,[r1,#4]
        0x08000440:    231f        .#      MOVS     r3,#0x1f
        0x08000442:    2a07        .*      CMP      r2,#7
        0x08000444:    d20d        ..      BCS      0x8000462 ; HAL_ADC_ConfigChannel + 58
        0x08000446:    6806        .h      LDR      r6,[r0,#0]
        0x08000448:    6b77        wk      LDR      r7,[r6,#0x34]
        0x0800044a:    1e52        R.      SUBS     r2,r2,#1
        0x0800044c:    eb020282    ....    ADD      r2,r2,r2,LSL #2
        0x08000450:    4093        .@      LSLS     r3,r3,r2
        0x08000452:    439f        .C      BICS     r7,r7,r3
        0x08000454:    680b        .h      LDR      r3,[r1,#0]
        0x08000456:    4093        .@      LSLS     r3,r3,r2
        0x08000458:    431f        .C      ORRS     r7,r7,r3
        0x0800045a:    6377        wc      STR      r7,[r6,#0x34]
        0x0800045c:    e019        ..      B        0x8000492 ; HAL_ADC_ConfigChannel + 106
        0x0800045e:    2002        .       MOVS     r0,#2
        0x08000460:    bdf8        ..      POP      {r3-r7,pc}
        0x08000462:    6806        .h      LDR      r6,[r0,#0]
        0x08000464:    2a0d        .*      CMP      r2,#0xd
        0x08000466:    d20a        ..      BCS      0x800047e ; HAL_ADC_ConfigChannel + 86
        0x08000468:    6b37        7k      LDR      r7,[r6,#0x30]
        0x0800046a:    1fd2        ..      SUBS     r2,r2,#7
        0x0800046c:    eb020282    ....    ADD      r2,r2,r2,LSL #2
        0x08000470:    4093        .@      LSLS     r3,r3,r2
        0x08000472:    439f        .C      BICS     r7,r7,r3
        0x08000474:    680b        .h      LDR      r3,[r1,#0]
        0x08000476:    4093        .@      LSLS     r3,r3,r2
        0x08000478:    431f        .C      ORRS     r7,r7,r3
        0x0800047a:    6337        7c      STR      r7,[r6,#0x30]
        0x0800047c:    e009        ..      B        0x8000492 ; HAL_ADC_ConfigChannel + 106
        0x0800047e:    6af7        .j      LDR      r7,[r6,#0x2c]
        0x08000480:    3a0d        .:      SUBS     r2,r2,#0xd
        0x08000482:    eb020282    ....    ADD      r2,r2,r2,LSL #2
        0x08000486:    4093        .@      LSLS     r3,r3,r2
        0x08000488:    439f        .C      BICS     r7,r7,r3
        0x0800048a:    680b        .h      LDR      r3,[r1,#0]
        0x0800048c:    4093        .@      LSLS     r3,r3,r2
        0x0800048e:    431f        .C      ORRS     r7,r7,r3
        0x08000490:    62f7        .b      STR      r7,[r6,#0x2c]
        0x08000492:    680a        .h      LDR      r2,[r1,#0]
        0x08000494:    2307        .#      MOVS     r3,#7
        0x08000496:    6806        .h      LDR      r6,[r0,#0]
        0x08000498:    2a0a        .*      CMP      r2,#0xa
        0x0800049a:    d30a        ..      BCC      0x80004b2 ; HAL_ADC_ConfigChannel + 138
        0x0800049c:    68f7        .h      LDR      r7,[r6,#0xc]
        0x0800049e:    3a0a        .:      SUBS     r2,r2,#0xa
        0x080004a0:    eb020242    ..B.    ADD      r2,r2,r2,LSL #1
        0x080004a4:    4093        .@      LSLS     r3,r3,r2
        0x080004a6:    439f        .C      BICS     r7,r7,r3
        0x080004a8:    688b        .h      LDR      r3,[r1,#8]
        0x080004aa:    4093        .@      LSLS     r3,r3,r2
        0x080004ac:    431f        .C      ORRS     r7,r7,r3
        0x080004ae:    60f7        .`      STR      r7,[r6,#0xc]
        0x080004b0:    e008        ..      B        0x80004c4 ; HAL_ADC_ConfigChannel + 156
        0x080004b2:    6937        7i      LDR      r7,[r6,#0x10]
        0x080004b4:    eb020242    ..B.    ADD      r2,r2,r2,LSL #1
        0x080004b8:    4093        .@      LSLS     r3,r3,r2
        0x080004ba:    439f        .C      BICS     r7,r7,r3
        0x080004bc:    688b        .h      LDR      r3,[r1,#8]
        0x080004be:    4093        .@      LSLS     r3,r3,r2
        0x080004c0:    431f        .C      ORRS     r7,r7,r3
        0x080004c2:    6137        7a      STR      r7,[r6,#0x10]
        0x080004c4:    680a        .h      LDR      r2,[r1,#0]
        0x080004c6:    2a10        .*      CMP      r2,#0x10
        0x080004c8:    d001        ..      BEQ      0x80004ce ; HAL_ADC_ConfigChannel + 166
        0x080004ca:    2a11        .*      CMP      r2,#0x11
        0x080004cc:    d120         .      BNE      0x8000510 ; HAL_ADC_ConfigChannel + 232
        0x080004ce:    4b12        .K      LDR      r3,[pc,#72] ; [0x8000518] = 0x40012400
        0x080004d0:    6802        .h      LDR      r2,[r0,#0]
        0x080004d2:    429a        .B      CMP      r2,r3
        0x080004d4:    d117        ..      BNE      0x8000506 ; HAL_ADC_ConfigChannel + 222
        0x080004d6:    6893        .h      LDR      r3,[r2,#8]
        0x080004d8:    021b        ..      LSLS     r3,r3,#8
        0x080004da:    d419        ..      BMI      0x8000510 ; HAL_ADC_ConfigChannel + 232
        0x080004dc:    6893        .h      LDR      r3,[r2,#8]
        0x080004de:    f4430300    C...    ORR      r3,r3,#0x800000
        0x080004e2:    6093        .`      STR      r3,[r2,#8]
        0x080004e4:    6809        .h      LDR      r1,[r1,#0]
        0x080004e6:    2910        .)      CMP      r1,#0x10
        0x080004e8:    d112        ..      BNE      0x8000510 ; HAL_ADC_ConfigChannel + 232
        0x080004ea:    490c        .I      LDR      r1,[pc,#48] ; [0x800051c] = 0x20000028
        0x080004ec:    4a0c        .J      LDR      r2,[pc,#48] ; [0x8000520] = 0xf4240
        0x080004ee:    6809        .h      LDR      r1,[r1,#0]
        0x080004f0:    fbb1f1f2    ....    UDIV     r1,r1,r2
        0x080004f4:    eb010181    ....    ADD      r1,r1,r1,LSL #2
        0x080004f8:    0049        I.      LSLS     r1,r1,#1
        0x080004fa:    e000        ..      B        0x80004fe ; HAL_ADC_ConfigChannel + 214
        0x080004fc:    1e49        I.      SUBS     r1,r1,#1
        0x080004fe:    9100        ..      STR      r1,[sp,#0]
        0x08000500:    2900        .)      CMP      r1,#0
        0x08000502:    d1fb        ..      BNE      0x80004fc ; HAL_ADC_ConfigChannel + 212
        0x08000504:    e004        ..      B        0x8000510 ; HAL_ADC_ConfigChannel + 232
        0x08000506:    6a81        .j      LDR      r1,[r0,#0x28]
        0x08000508:    f0410120    A. .    ORR      r1,r1,#0x20
        0x0800050c:    6281        .b      STR      r1,[r0,#0x28]
        0x0800050e:    2401        .$      MOVS     r4,#1
        0x08000510:    f8805024    ..$P    STRB     r5,[r0,#0x24]
        0x08000514:    4620         F      MOV      r0,r4
        0x08000516:    bdf8        ..      POP      {r3-r7,pc}
    $d
        0x08000518:    40012400    .$.@    DCD    1073816576
        0x0800051c:    20000028    (..     DCD    536870952
        0x08000520:    000f4240    @B..    DCD    1000000
    $t
    i.HAL_ADC_ConvCpltCallback
    HAL_ADC_ConvCpltCallback
        0x08000524:    4770        pG      BX       lr
    i.HAL_ADC_GetValue
    HAL_ADC_GetValue
        0x08000526:    6800        .h      LDR      r0,[r0,#0]
        0x08000528:    6cc0        .l      LDR      r0,[r0,#0x4c]
        0x0800052a:    4770        pG      BX       lr
    i.HAL_ADC_IRQHandler
    HAL_ADC_IRQHandler
        0x0800052c:    b570        p.      PUSH     {r4-r6,lr}
        0x0800052e:    4604        .F      MOV      r4,r0
        0x08000530:    6800        .h      LDR      r0,[r0,#0]
        0x08000532:    6806        .h      LDR      r6,[r0,#0]
        0x08000534:    6845        Eh      LDR      r5,[r0,#4]
        0x08000536:    06a9        ..      LSLS     r1,r5,#26
        0x08000538:    d525        %.      BPL      0x8000586 ; HAL_ADC_IRQHandler + 90
        0x0800053a:    07b1        ..      LSLS     r1,r6,#30
        0x0800053c:    d523        #.      BPL      0x8000586 ; HAL_ADC_IRQHandler + 90
        0x0800053e:    6aa1        .j      LDR      r1,[r4,#0x28]
        0x08000540:    06c9        ..      LSLS     r1,r1,#27
        0x08000542:    d403        ..      BMI      0x800054c ; HAL_ADC_IRQHandler + 32
        0x08000544:    6aa1        .j      LDR      r1,[r4,#0x28]
        0x08000546:    f4417100    A..q    ORR      r1,r1,#0x200
        0x0800054a:    62a1        .b      STR      r1,[r4,#0x28]
        0x0800054c:    6881        .h      LDR      r1,[r0,#8]
        0x0800054e:    f3c14142    ..BA    UBFX     r1,r1,#17,#3
        0x08000552:    2907        .)      CMP      r1,#7
        0x08000554:    d110        ..      BNE      0x8000578 ; HAL_ADC_IRQHandler + 76
        0x08000556:    7b21        !{      LDRB     r1,[r4,#0xc]
        0x08000558:    b971        q.      CBNZ     r1,0x8000578 ; HAL_ADC_IRQHandler + 76
        0x0800055a:    6841        Ah      LDR      r1,[r0,#4]
        0x0800055c:    f0210120    !. .    BIC      r1,r1,#0x20
        0x08000560:    6041        A`      STR      r1,[r0,#4]
        0x08000562:    6aa0        .j      LDR      r0,[r4,#0x28]
        0x08000564:    f4207080     ..p    BIC      r0,r0,#0x100
        0x08000568:    62a0        .b      STR      r0,[r4,#0x28]
        0x0800056a:    6aa0        .j      LDR      r0,[r4,#0x28]
        0x0800056c:    04c0        ..      LSLS     r0,r0,#19
        0x0800056e:    d403        ..      BMI      0x8000578 ; HAL_ADC_IRQHandler + 76
        0x08000570:    6aa0        .j      LDR      r0,[r4,#0x28]
        0x08000572:    f0400001    @...    ORR      r0,r0,#1
        0x08000576:    62a0        .b      STR      r0,[r4,#0x28]
        0x08000578:    4620         F      MOV      r0,r4
        0x0800057a:    f7ffffd3    ....    BL       HAL_ADC_ConvCpltCallback ; 0x8000524
        0x0800057e:    6821        !h      LDR      r1,[r4,#0]
        0x08000580:    f06f0012    o...    MVN      r0,#0x12
        0x08000584:    6008        .`      STR      r0,[r1,#0]
        0x08000586:    0628        (.      LSLS     r0,r5,#24
        0x08000588:    d52e        ..      BPL      0x80005e8 ; HAL_ADC_IRQHandler + 188
        0x0800058a:    0770        p.      LSLS     r0,r6,#29
        0x0800058c:    d52c        ,.      BPL      0x80005e8 ; HAL_ADC_IRQHandler + 188
        0x0800058e:    6aa0        .j      LDR      r0,[r4,#0x28]
        0x08000590:    06c0        ..      LSLS     r0,r0,#27
        0x08000592:    d403        ..      BMI      0x800059c ; HAL_ADC_IRQHandler + 112
        0x08000594:    6aa0        .j      LDR      r0,[r4,#0x28]
        0x08000596:    f4405000    @..P    ORR      r0,r0,#0x2000
        0x0800059a:    62a0        .b      STR      r0,[r4,#0x28]
        0x0800059c:    6820         h      LDR      r0,[r4,#0]
        0x0800059e:    6881        .h      LDR      r1,[r0,#8]
        0x080005a0:    f3c13102    ...1    UBFX     r1,r1,#12,#3
        0x080005a4:    2907        .)      CMP      r1,#7
        0x080005a6:    d009        ..      BEQ      0x80005bc ; HAL_ADC_IRQHandler + 144
        0x080005a8:    6841        Ah      LDR      r1,[r0,#4]
        0x080005aa:    0549        I.      LSLS     r1,r1,#21
        0x080005ac:    d415        ..      BMI      0x80005da ; HAL_ADC_IRQHandler + 174
        0x080005ae:    6881        .h      LDR      r1,[r0,#8]
        0x080005b0:    f3c14142    ..BA    UBFX     r1,r1,#17,#3
        0x080005b4:    2907        .)      CMP      r1,#7
        0x080005b6:    d110        ..      BNE      0x80005da ; HAL_ADC_IRQHandler + 174
        0x080005b8:    7b21        !{      LDRB     r1,[r4,#0xc]
        0x080005ba:    b971        q.      CBNZ     r1,0x80005da ; HAL_ADC_IRQHandler + 174
        0x080005bc:    6841        Ah      LDR      r1,[r0,#4]
        0x080005be:    f0210180    !...    BIC      r1,r1,#0x80
        0x080005c2:    6041        A`      STR      r1,[r0,#4]
        0x080005c4:    6aa0        .j      LDR      r0,[r4,#0x28]
        0x080005c6:    f4205080     ..P    BIC      r0,r0,#0x1000
        0x080005ca:    62a0        .b      STR      r0,[r4,#0x28]
        0x080005cc:    6aa0        .j      LDR      r0,[r4,#0x28]
        0x080005ce:    05c0        ..      LSLS     r0,r0,#23
        0x080005d0:    d403        ..      BMI      0x80005da ; HAL_ADC_IRQHandler + 174
        0x080005d2:    6aa0        .j      LDR      r0,[r4,#0x28]
        0x080005d4:    f0400001    @...    ORR      r0,r0,#1
        0x080005d8:    62a0        .b      STR      r0,[r4,#0x28]
        0x080005da:    4620         F      MOV      r0,r4
        0x080005dc:    f7ffff22    ..".    BL       HAL_ADCEx_InjectedConvCpltCallback ; 0x8000424
        0x080005e0:    6821        !h      LDR      r1,[r4,#0]
        0x080005e2:    f06f000c    o...    MVN      r0,#0xc
        0x080005e6:    6008        .`      STR      r0,[r1,#0]
        0x080005e8:    0668        h.      LSLS     r0,r5,#25
        0x080005ea:    d50c        ..      BPL      0x8000606 ; HAL_ADC_IRQHandler + 218
        0x080005ec:    07f0        ..      LSLS     r0,r6,#31
        0x080005ee:    d00a        ..      BEQ      0x8000606 ; HAL_ADC_IRQHandler + 218
        0x080005f0:    6aa0        .j      LDR      r0,[r4,#0x28]
        0x080005f2:    f4403080    @..0    ORR      r0,r0,#0x10000
        0x080005f6:    62a0        .b      STR      r0,[r4,#0x28]
        0x080005f8:    4620         F      MOV      r0,r4
        0x080005fa:    f000f893    ....    BL       HAL_ADC_LevelOutOfWindowCallback ; 0x8000724
        0x080005fe:    6821        !h      LDR      r1,[r4,#0]
        0x08000600:    f06f0001    o...    MVN      r0,#1
        0x08000604:    6008        .`      STR      r0,[r1,#0]
        0x08000606:    bd70        p.      POP      {r4-r6,pc}
    i.HAL_ADC_Init
    HAL_ADC_Init
        0x08000608:    e92d41f0    -..A    PUSH     {r4-r8,lr}
        0x0800060c:    f04f0700    O...    MOV      r7,#0
        0x08000610:    0004        ..      MOVS     r4,r0
        0x08000612:    463d        =F      MOV      r5,r7
        0x08000614:    d07e        ~.      BEQ      0x8000714 ; HAL_ADC_Init + 268
        0x08000616:    6aa0        .j      LDR      r0,[r4,#0x28]
        0x08000618:    2600        .&      MOVS     r6,#0
        0x0800061a:    b928        (.      CBNZ     r0,0x8000628 ; HAL_ADC_Init + 32
        0x0800061c:    62e6        .b      STR      r6,[r4,#0x2c]
        0x0800061e:    f8846024    ..$`    STRB     r6,[r4,#0x24]
        0x08000622:    4620         F      MOV      r0,r4
        0x08000624:    f000f880    ....    BL       HAL_ADC_MspInit ; 0x8000728
        0x08000628:    4620         F      MOV      r0,r4
        0x0800062a:    f7fffdf7    ....    BL       ADC_ConversionStop_Disable ; 0x800021c
        0x0800062e:    6aa1        .j      LDR      r1,[r4,#0x28]
        0x08000630:    06c9        ..      LSLS     r1,r1,#27
        0x08000632:    d400        ..      BMI      0x8000636 ; HAL_ADC_Init + 46
        0x08000634:    b120         .      CBZ      r0,0x8000640 ; HAL_ADC_Init + 56
        0x08000636:    6aa0        .j      LDR      r0,[r4,#0x28]
        0x08000638:    f0400010    @...    ORR      r0,r0,#0x10
        0x0800063c:    62a0        .b      STR      r0,[r4,#0x28]
        0x0800063e:    e069        i.      B        0x8000714 ; HAL_ADC_Init + 268
        0x08000640:    6aa1        .j      LDR      r1,[r4,#0x28]
        0x08000642:    f4215188    !..Q    BIC      r1,r1,#0x1100
        0x08000646:    f0410102    A...    ORR      r1,r1,#2
        0x0800064a:    62a1        .b      STR      r1,[r4,#0x28]
        0x0800064c:    6862        bh      LDR      r2,[r4,#4]
        0x0800064e:    69e1        .i      LDR      r1,[r4,#0x1c]
        0x08000650:    7b23        #{      LDRB     r3,[r4,#0xc]
        0x08000652:    430a        .C      ORRS     r2,r2,r1
        0x08000654:    ea470143    G.C.    ORR      r1,r7,r3,LSL #1
        0x08000658:    430a        .C      ORRS     r2,r2,r1
        0x0800065a:    68a1        .h      LDR      r1,[r4,#8]
        0x0800065c:    f44f7780    O..w    MOV      r7,#0x100
        0x08000660:    42b9        .B      CMP      r1,r7
        0x08000662:    d009        ..      BEQ      0x8000678 ; HAL_ADC_Init + 112
        0x08000664:    2901        .)      CMP      r1,#1
        0x08000666:    d007        ..      BEQ      0x8000678 ; HAL_ADC_Init + 112
        0x08000668:    f05f0100    _...    MOVS.W   r1,#0
        0x0800066c:    f894c014    ....    LDRB     r12,[r4,#0x14]
        0x08000670:    f1bc0f01    ....    CMP      r12,#1
        0x08000674:    d002        ..      BEQ      0x800067c ; HAL_ADC_Init + 116
        0x08000676:    e00a        ..      B        0x800068e ; HAL_ADC_Init + 134
        0x08000678:    4639        9F      MOV      r1,r7
        0x0800067a:    e7f7        ..      B        0x800066c ; HAL_ADC_Init + 100
        0x0800067c:    b1f3        ..      CBZ      r3,0x80006bc ; HAL_ADC_Init + 180
        0x0800067e:    6aa3        .j      LDR      r3,[r4,#0x28]
        0x08000680:    f0430320    C. .    ORR      r3,r3,#0x20
        0x08000684:    62a3        .b      STR      r3,[r4,#0x28]
        0x08000686:    6ae3        .j      LDR      r3,[r4,#0x2c]
        0x08000688:    f0430301    C...    ORR      r3,r3,#1
        0x0800068c:    62e3        .b      STR      r3,[r4,#0x2c]
        0x0800068e:    6823        #h      LDR      r3,[r4,#0]
        0x08000690:    f8d3c004    ....    LDR      r12,[r3,#4]
        0x08000694:    f42c4c69    ,.iL    BIC      r12,r12,#0xe900
        0x08000698:    ea4c0c01    L...    ORR      r12,r12,r1
        0x0800069c:    f8c3c004    ....    STR      r12,[r3,#4]
        0x080006a0:    6821        !h      LDR      r1,[r4,#0]
        0x080006a2:    688b        .h      LDR      r3,[r1,#8]
        0x080006a4:    f8dfc070    ..p.    LDR      r12,[pc,#112] ; [0x8000718] = 0xffe1f7fd
        0x080006a8:    ea03030c    ....    AND      r3,r3,r12
        0x080006ac:    4313        .C      ORRS     r3,r3,r2
        0x080006ae:    608b        .`      STR      r3,[r1,#8]
        0x080006b0:    68a1        .h      LDR      r1,[r4,#8]
        0x080006b2:    42b9        .B      CMP      r1,r7
        0x080006b4:    d00b        ..      BEQ      0x80006ce ; HAL_ADC_Init + 198
        0x080006b6:    2901        .)      CMP      r1,#1
        0x080006b8:    d009        ..      BEQ      0x80006ce ; HAL_ADC_Init + 198
        0x080006ba:    e00c        ..      B        0x80006d6 ; HAL_ADC_Init + 206
        0x080006bc:    f8dfc05c    ..\.    LDR      r12,[pc,#92] ; [0x800071c] = 0xffffe000
        0x080006c0:    69a3        .i      LDR      r3,[r4,#0x18]
        0x080006c2:    eb0c3343    ..C3    ADD      r3,r12,r3,LSL #13
        0x080006c6:    430b        .C      ORRS     r3,r3,r1
        0x080006c8:    f4436100    C..a    ORR      r1,r3,#0x800
        0x080006cc:    e7df        ..      B        0x800068e ; HAL_ADC_Init + 134
        0x080006ce:    8a21        !.      LDRH     r1,[r4,#0x10]
        0x080006d0:    050d        ..      LSLS     r5,r1,#20
        0x080006d2:    f5a51580    ....    SUB      r5,r5,#0x100000
        0x080006d6:    6821        !h      LDR      r1,[r4,#0]
        0x080006d8:    6acb        .j      LDR      r3,[r1,#0x2c]
        0x080006da:    f4230370    #.p.    BIC      r3,r3,#0xf00000
        0x080006de:    432b        +C      ORRS     r3,r3,r5
        0x080006e0:    62cb        .b      STR      r3,[r1,#0x2c]
        0x080006e2:    6821        !h      LDR      r1,[r4,#0]
        0x080006e4:    6889        .h      LDR      r1,[r1,#8]
        0x080006e6:    4b0e        .K      LDR      r3,[pc,#56] ; [0x8000720] = 0xff1f0efe
        0x080006e8:    4019        .@      ANDS     r1,r1,r3
        0x080006ea:    4291        .B      CMP      r1,r2
        0x080006ec:    d108        ..      BNE      0x8000700 ; HAL_ADC_Init + 248
        0x080006ee:    62e6        .b      STR      r6,[r4,#0x2c]
        0x080006f0:    6aa1        .j      LDR      r1,[r4,#0x28]
        0x080006f2:    f0210102    !...    BIC      r1,r1,#2
        0x080006f6:    f0410101    A...    ORR      r1,r1,#1
        0x080006fa:    62a1        .b      STR      r1,[r4,#0x28]
        0x080006fc:    e8bd81f0    ....    POP      {r4-r8,pc}
        0x08000700:    6aa0        .j      LDR      r0,[r4,#0x28]
        0x08000702:    f0200002     ...    BIC      r0,r0,#2
        0x08000706:    f0400010    @...    ORR      r0,r0,#0x10
        0x0800070a:    62a0        .b      STR      r0,[r4,#0x28]
        0x0800070c:    6ae0        .j      LDR      r0,[r4,#0x2c]
        0x0800070e:    f0400001    @...    ORR      r0,r0,#1
        0x08000712:    62e0        .b      STR      r0,[r4,#0x2c]
        0x08000714:    2001        .       MOVS     r0,#1
        0x08000716:    e7f1        ..      B        0x80006fc ; HAL_ADC_Init + 244
    $d
        0x08000718:    ffe1f7fd    ....    DCD    4292999165
        0x0800071c:    ffffe000    ....    DCD    4294959104
        0x08000720:    ff1f0efe    ....    DCD    4280225534
    $t
    i.HAL_ADC_LevelOutOfWindowCallback
    HAL_ADC_LevelOutOfWindowCallback
        0x08000724:    4770        pG      BX       lr
        0x08000726:    0000        ..      MOVS     r0,r0
    i.HAL_ADC_MspInit
    HAL_ADC_MspInit
        0x08000728:    b500        ..      PUSH     {lr}
        0x0800072a:    b085        ..      SUB      sp,sp,#0x14
        0x0800072c:    2100        .!      MOVS     r1,#0
        0x0800072e:    9100        ..      STR      r1,[sp,#0]
        0x08000730:    9101        ..      STR      r1,[sp,#4]
        0x08000732:    9102        ..      STR      r1,[sp,#8]
        0x08000734:    9103        ..      STR      r1,[sp,#0xc]
        0x08000736:    6800        .h      LDR      r0,[r0,#0]
        0x08000738:    4912        .I      LDR      r1,[pc,#72] ; [0x8000784] = 0x40012400
        0x0800073a:    4288        .B      CMP      r0,r1
        0x0800073c:    d120         .      BNE      0x8000780 ; HAL_ADC_MspInit + 88
        0x0800073e:    4812        .H      LDR      r0,[pc,#72] ; [0x8000788] = 0x40021000
        0x08000740:    6981        .i      LDR      r1,[r0,#0x18]
        0x08000742:    f4417100    A..q    ORR      r1,r1,#0x200
        0x08000746:    6181        .a      STR      r1,[r0,#0x18]
        0x08000748:    6981        .i      LDR      r1,[r0,#0x18]
        0x0800074a:    f4017100    ...q    AND      r1,r1,#0x200
        0x0800074e:    9104        ..      STR      r1,[sp,#0x10]
        0x08000750:    6981        .i      LDR      r1,[r0,#0x18]
        0x08000752:    f0410104    A...    ORR      r1,r1,#4
        0x08000756:    6181        .a      STR      r1,[r0,#0x18]
        0x08000758:    6980        .i      LDR      r0,[r0,#0x18]
        0x0800075a:    4669        iF      MOV      r1,sp
        0x0800075c:    f0000004    ....    AND      r0,r0,#4
        0x08000760:    9004        ..      STR      r0,[sp,#0x10]
        0x08000762:    2010        .       MOVS     r0,#0x10
        0x08000764:    9000        ..      STR      r0,[sp,#0]
        0x08000766:    2003        .       MOVS     r0,#3
        0x08000768:    9001        ..      STR      r0,[sp,#4]
        0x0800076a:    4808        .H      LDR      r0,[pc,#32] ; [0x800078c] = 0x40010800
        0x0800076c:    f000f97e    ..~.    BL       HAL_GPIO_Init ; 0x8000a6c
        0x08000770:    2200        ."      MOVS     r2,#0
        0x08000772:    4611        .F      MOV      r1,r2
        0x08000774:    2012        .       MOVS     r0,#0x12
        0x08000776:    f000fadb    ....    BL       HAL_NVIC_SetPriority ; 0x8000d30
        0x0800077a:    2012        .       MOVS     r0,#0x12
        0x0800077c:    f000faca    ....    BL       HAL_NVIC_EnableIRQ ; 0x8000d14
        0x08000780:    b005        ..      ADD      sp,sp,#0x14
        0x08000782:    bd00        ..      POP      {pc}
    $d
        0x08000784:    40012400    .$.@    DCD    1073816576
        0x08000788:    40021000    ...@    DCD    1073876992
        0x0800078c:    40010800    ...@    DCD    1073809408
    $t
    i.HAL_ADC_PollForConversion
    HAL_ADC_PollForConversion
        0x08000790:    e92d43f8    -..C    PUSH     {r3-r9,lr}
        0x08000794:    2700        .'      MOVS     r7,#0
        0x08000796:    460d        .F      MOV      r5,r1
        0x08000798:    4604        .F      MOV      r4,r0
        0x0800079a:    9700        ..      STR      r7,[sp,#0]
        0x0800079c:    f000fa5c    ..\.    BL       HAL_GetTick ; 0x8000c58
        0x080007a0:    4680        .F      MOV      r8,r0
        0x080007a2:    6820         h      LDR      r0,[r4,#0]
        0x080007a4:    6881        .h      LDR      r1,[r0,#8]
        0x080007a6:    05c9        ..      LSLS     r1,r1,#23
        0x080007a8:    d508        ..      BPL      0x80007bc ; HAL_ADC_PollForConversion + 44
        0x080007aa:    6aa0        .j      LDR      r0,[r4,#0x28]
        0x080007ac:    f0400020    @. .    ORR      r0,r0,#0x20
        0x080007b0:    62a0        .b      STR      r0,[r4,#0x28]
        0x080007b2:    f8847024    ..$p    STRB     r7,[r4,#0x24]
        0x080007b6:    2001        .       MOVS     r0,#1
        0x080007b8:    e8bd83f8    ....    POP      {r3-r9,pc}
        0x080007bc:    6841        Ah      LDR      r1,[r0,#4]
        0x080007be:    05c9        ..      LSLS     r1,r1,#23
        0x080007c0:    d403        ..      BMI      0x80007ca ; HAL_ADC_PollForConversion + 58
        0x080007c2:    6ac0        .j      LDR      r0,[r0,#0x2c]
        0x080007c4:    f4100f70    ..p.    TST      r0,#0xf00000
        0x080007c8:    d02a        *.      BEQ      0x8000820 ; HAL_ADC_PollForConversion + 144
        0x080007ca:    2002        .       MOVS     r0,#2
        0x080007cc:    f000fae2    ....    BL       HAL_RCCEx_GetPeriphCLKFreq ; 0x8000d94
        0x080007d0:    493b        ;I      LDR      r1,[pc,#236] ; [0x80008c0] = 0x20000028
        0x080007d2:    6809        .h      LDR      r1,[r1,#0]
        0x080007d4:    fbb1f6f0    ....    UDIV     r6,r1,r0
        0x080007d8:    6820         h      LDR      r0,[r4,#0]
        0x080007da:    6903        .i      LDR      r3,[r0,#0x10]
        0x080007dc:    4939        9I      LDR      r1,[pc,#228] ; [0x80008c4] = 0x24924924
        0x080007de:    420b        .B      TST      r3,r1
        0x080007e0:    ea4f0161    O.a.    ASR      r1,r1,#1
        0x080007e4:    ea4f12a1    O...    ASR      r2,r1,#6
        0x080007e8:    d11f        ..      BNE      0x800082a ; HAL_ADC_PollForConversion + 154
        0x080007ea:    68c3        .h      LDR      r3,[r0,#0xc]
        0x080007ec:    ea4f1c61    O.a.    ASR      r12,r1,#5
        0x080007f0:    ea130f0c    ....    TST      r3,r12
        0x080007f4:    d119        ..      BNE      0x800082a ; HAL_ADC_PollForConversion + 154
        0x080007f6:    6903        .i      LDR      r3,[r0,#0x10]
        0x080007f8:    420b        .B      TST      r3,r1
        0x080007fa:    d125        %.      BNE      0x8000848 ; HAL_ADC_PollForConversion + 184
        0x080007fc:    68c0        .h      LDR      r0,[r0,#0xc]
        0x080007fe:    4210        .B      TST      r0,r2
        0x08000800:    d122        ".      BNE      0x8000848 ; HAL_ADC_PollForConversion + 184
        0x08000802:    2014        .       MOVS     r0,#0x14
        0x08000804:    e023        #.      B        0x800084e ; HAL_ADC_PollForConversion + 190
        0x08000806:    1c68        h.      ADDS     r0,r5,#1
        0x08000808:    d00a        ..      BEQ      0x8000820 ; HAL_ADC_PollForConversion + 144
        0x0800080a:    b12d        -.      CBZ      r5,0x8000818 ; HAL_ADC_PollForConversion + 136
        0x0800080c:    f000fa24    ..$.    BL       HAL_GetTick ; 0x8000c58
        0x08000810:    eba00008    ....    SUB      r0,r0,r8
        0x08000814:    42a8        .B      CMP      r0,r5
        0x08000816:    d903        ..      BLS      0x8000820 ; HAL_ADC_PollForConversion + 144
        0x08000818:    6820         h      LDR      r0,[r4,#0]
        0x0800081a:    6800        .h      LDR      r0,[r0,#0]
        0x0800081c:    0780        ..      LSLS     r0,r0,#30
        0x0800081e:    d525        %.      BPL      0x800086c ; HAL_ADC_PollForConversion + 220
        0x08000820:    6820         h      LDR      r0,[r4,#0]
        0x08000822:    6800        .h      LDR      r0,[r0,#0]
        0x08000824:    0780        ..      LSLS     r0,r0,#30
        0x08000826:    d5ee        ..      BPL      0x8000806 ; HAL_ADC_PollForConversion + 118
        0x08000828:    e02d        -.      B        0x8000886 ; HAL_ADC_PollForConversion + 246
        0x0800082a:    6903        .i      LDR      r3,[r0,#0x10]
        0x0800082c:    420b        .B      TST      r3,r1
        0x0800082e:    d102        ..      BNE      0x8000836 ; HAL_ADC_PollForConversion + 166
        0x08000830:    68c1        .h      LDR      r1,[r0,#0xc]
        0x08000832:    4211        .B      TST      r1,r2
        0x08000834:    d006        ..      BEQ      0x8000844 ; HAL_ADC_PollForConversion + 180
        0x08000836:    6902        .i      LDR      r2,[r0,#0x10]
        0x08000838:    4923        #I      LDR      r1,[pc,#140] ; [0x80008c8] = 0x249249
        0x0800083a:    420a        .B      TST      r2,r1
        0x0800083c:    d106        ..      BNE      0x800084c ; HAL_ADC_PollForConversion + 188
        0x0800083e:    68c0        .h      LDR      r0,[r0,#0xc]
        0x08000840:    4208        .B      TST      r0,r1
        0x08000842:    d103        ..      BNE      0x800084c ; HAL_ADC_PollForConversion + 188
        0x08000844:    2054        T       MOVS     r0,#0x54
        0x08000846:    e002        ..      B        0x800084e ; HAL_ADC_PollForConversion + 190
        0x08000848:    2029        )       MOVS     r0,#0x29
        0x0800084a:    e000        ..      B        0x800084e ; HAL_ADC_PollForConversion + 190
        0x0800084c:    20fc        .       MOVS     r0,#0xfc
        0x0800084e:    4346        FC      MULS     r6,r0,r6
        0x08000850:    9800        ..      LDR      r0,[sp,#0]
        0x08000852:    e016        ..      B        0x8000882 ; HAL_ADC_PollForConversion + 242
        0x08000854:    1c68        h.      ADDS     r0,r5,#1
        0x08000856:    d011        ..      BEQ      0x800087c ; HAL_ADC_PollForConversion + 236
        0x08000858:    b12d        -.      CBZ      r5,0x8000866 ; HAL_ADC_PollForConversion + 214
        0x0800085a:    f000f9fd    ....    BL       HAL_GetTick ; 0x8000c58
        0x0800085e:    eba00008    ....    SUB      r0,r0,r8
        0x08000862:    42a8        .B      CMP      r0,r5
        0x08000864:    d90a        ..      BLS      0x800087c ; HAL_ADC_PollForConversion + 236
        0x08000866:    9800        ..      LDR      r0,[sp,#0]
        0x08000868:    42b0        .B      CMP      r0,r6
        0x0800086a:    d207        ..      BCS      0x800087c ; HAL_ADC_PollForConversion + 236
        0x0800086c:    6aa0        .j      LDR      r0,[r4,#0x28]
        0x0800086e:    f0400004    @...    ORR      r0,r0,#4
        0x08000872:    62a0        .b      STR      r0,[r4,#0x28]
        0x08000874:    f8847024    ..$p    STRB     r7,[r4,#0x24]
        0x08000878:    2003        .       MOVS     r0,#3
        0x0800087a:    e79d        ..      B        0x80007b8 ; HAL_ADC_PollForConversion + 40
        0x0800087c:    9800        ..      LDR      r0,[sp,#0]
        0x0800087e:    1c40        @.      ADDS     r0,r0,#1
        0x08000880:    9000        ..      STR      r0,[sp,#0]
        0x08000882:    42b0        .B      CMP      r0,r6
        0x08000884:    d3e6        ..      BCC      0x8000854 ; HAL_ADC_PollForConversion + 196
        0x08000886:    6821        !h      LDR      r1,[r4,#0]
        0x08000888:    f06f0012    o...    MVN      r0,#0x12
        0x0800088c:    6008        .`      STR      r0,[r1,#0]
        0x0800088e:    6aa0        .j      LDR      r0,[r4,#0x28]
        0x08000890:    f4407000    @..p    ORR      r0,r0,#0x200
        0x08000894:    62a0        .b      STR      r0,[r4,#0x28]
        0x08000896:    6820         h      LDR      r0,[r4,#0]
        0x08000898:    6880        .h      LDR      r0,[r0,#8]
        0x0800089a:    f3c04042    ..B@    UBFX     r0,r0,#17,#3
        0x0800089e:    2807        .(      CMP      r0,#7
        0x080008a0:    d10c        ..      BNE      0x80008bc ; HAL_ADC_PollForConversion + 300
        0x080008a2:    7b20         {      LDRB     r0,[r4,#0xc]
        0x080008a4:    b950        P.      CBNZ     r0,0x80008bc ; HAL_ADC_PollForConversion + 300
        0x080008a6:    6aa0        .j      LDR      r0,[r4,#0x28]
        0x080008a8:    f4207080     ..p    BIC      r0,r0,#0x100
        0x080008ac:    62a0        .b      STR      r0,[r4,#0x28]
        0x080008ae:    6aa0        .j      LDR      r0,[r4,#0x28]
        0x080008b0:    04c0        ..      LSLS     r0,r0,#19
        0x080008b2:    d403        ..      BMI      0x80008bc ; HAL_ADC_PollForConversion + 300
        0x080008b4:    6aa0        .j      LDR      r0,[r4,#0x28]
        0x080008b6:    f0400001    @...    ORR      r0,r0,#1
        0x080008ba:    62a0        .b      STR      r0,[r4,#0x28]
        0x080008bc:    2000        .       MOVS     r0,#0
        0x080008be:    e77b        {.      B        0x80007b8 ; HAL_ADC_PollForConversion + 40
    $d
        0x080008c0:    20000028    (..     DCD    536870952
        0x080008c4:    24924924    $I.$    DCD    613566756
        0x080008c8:    00249249    I.$.    DCD    2396745
    $t
    i.HAL_ADC_Start
    HAL_ADC_Start
        0x080008cc:    b570        p.      PUSH     {r4-r6,lr}
        0x080008ce:    4604        .F      MOV      r4,r0
        0x080008d0:    f8900024    ..$.    LDRB     r0,[r0,#0x24]
        0x080008d4:    2801        .(      CMP      r0,#1
        0x080008d6:    d00d        ..      BEQ      0x80008f4 ; HAL_ADC_Start + 40
        0x080008d8:    2001        .       MOVS     r0,#1
        0x080008da:    f8840024    ..$.    STRB     r0,[r4,#0x24]
        0x080008de:    4620         F      MOV      r0,r4
        0x080008e0:    f7fffcc8    ....    BL       ADC_Enable ; 0x8000274
        0x080008e4:    0002        ..      MOVS     r2,r0
        0x080008e6:    f04f0000    O...    MOV      r0,#0
        0x080008ea:    d005        ..      BEQ      0x80008f8 ; HAL_ADC_Start + 44
        0x080008ec:    f8840024    ..$.    STRB     r0,[r4,#0x24]
        0x080008f0:    4610        .F      MOV      r0,r2
        0x080008f2:    bd70        p.      POP      {r4-r6,pc}
        0x080008f4:    2002        .       MOVS     r0,#2
        0x080008f6:    bd70        p.      POP      {r4-r6,pc}
        0x080008f8:    6aa1        .j      LDR      r1,[r4,#0x28]
        0x080008fa:    f2402301    @..#    MOV      r3,#0x201
        0x080008fe:    4399        .C      BICS     r1,r1,r3
        0x08000900:    f4417180    A..q    ORR      r1,r1,#0x100
        0x08000904:    62a1        .b      STR      r1,[r4,#0x28]
        0x08000906:    4d1f        .M      LDR      r5,[pc,#124] ; [0x8000984] = 0x40012800
        0x08000908:    6823        #h      LDR      r3,[r4,#0]
        0x0800090a:    491f        .I      LDR      r1,[pc,#124] ; [0x8000988] = 0x40012404
        0x0800090c:    42ab        .B      CMP      r3,r5
        0x0800090e:    d118        ..      BNE      0x8000942 ; HAL_ADC_Start + 118
        0x08000910:    680e        .h      LDR      r6,[r1,#0]
        0x08000912:    f4162f70    ..p/    TST      r6,#0xf0000
        0x08000916:    d014        ..      BEQ      0x8000942 ; HAL_ADC_Start + 118
        0x08000918:    6aa6        .j      LDR      r6,[r4,#0x28]
        0x0800091a:    f4461680    F...    ORR      r6,r6,#0x100000
        0x0800091e:    62a6        .b      STR      r6,[r4,#0x28]
        0x08000920:    680e        .h      LDR      r6,[r1,#0]
        0x08000922:    0576        v.      LSLS     r6,r6,#21
        0x08000924:    d505        ..      BPL      0x8000932 ; HAL_ADC_Start + 102
        0x08000926:    6aa6        .j      LDR      r6,[r4,#0x28]
        0x08000928:    f4265600    &..V    BIC      r6,r6,#0x2000
        0x0800092c:    f4465680    F..V    ORR      r6,r6,#0x1000
        0x08000930:    62a6        .b      STR      r6,[r4,#0x28]
        0x08000932:    6aa6        .j      LDR      r6,[r4,#0x28]
        0x08000934:    04f6        ..      LSLS     r6,r6,#19
        0x08000936:    d50a        ..      BPL      0x800094e ; HAL_ADC_Start + 130
        0x08000938:    6ae6        .j      LDR      r6,[r4,#0x2c]
        0x0800093a:    f0260606    &...    BIC      r6,r6,#6
        0x0800093e:    62e6        .b      STR      r6,[r4,#0x2c]
        0x08000940:    e006        ..      B        0x8000950 ; HAL_ADC_Start + 132
        0x08000942:    6aa6        .j      LDR      r6,[r4,#0x28]
        0x08000944:    f4261680    &...    BIC      r6,r6,#0x100000
        0x08000948:    62a6        .b      STR      r6,[r4,#0x28]
        0x0800094a:    685e        ^h      LDR      r6,[r3,#4]
        0x0800094c:    e7e9        ..      B        0x8000922 ; HAL_ADC_Start + 86
        0x0800094e:    62e0        .b      STR      r0,[r4,#0x2c]
        0x08000950:    f8840024    ..$.    STRB     r0,[r4,#0x24]
        0x08000954:    f06f0002    o...    MVN      r0,#2
        0x08000958:    6018        .`      STR      r0,[r3,#0]
        0x0800095a:    6820         h      LDR      r0,[r4,#0]
        0x0800095c:    6883        .h      LDR      r3,[r0,#8]
        0x0800095e:    f3c34342    ..BC    UBFX     r3,r3,#17,#3
        0x08000962:    2b07        .+      CMP      r3,#7
        0x08000964:    d105        ..      BNE      0x8000972 ; HAL_ADC_Start + 166
        0x08000966:    42a8        .B      CMP      r0,r5
        0x08000968:    d108        ..      BNE      0x800097c ; HAL_ADC_Start + 176
        0x0800096a:    6809        .h      LDR      r1,[r1,#0]
        0x0800096c:    f4112f70    ..p/    TST      r1,#0xf0000
        0x08000970:    d004        ..      BEQ      0x800097c ; HAL_ADC_Start + 176
        0x08000972:    6881        .h      LDR      r1,[r0,#8]
        0x08000974:    f4411180    A...    ORR      r1,r1,#0x100000
        0x08000978:    6081        .`      STR      r1,[r0,#8]
        0x0800097a:    e7b9        ..      B        0x80008f0 ; HAL_ADC_Start + 36
        0x0800097c:    6881        .h      LDR      r1,[r0,#8]
        0x0800097e:    f44101a0    A...    ORR      r1,r1,#0x500000
        0x08000982:    e7f9        ..      B        0x8000978 ; HAL_ADC_Start + 172
    $d
        0x08000984:    40012800    .(.@    DCD    1073817600
        0x08000988:    40012404    .$.@    DCD    1073816580
    $t
    i.HAL_DMA_Abort
    HAL_DMA_Abort
        0x0800098c:    b510        ..      PUSH     {r4,lr}
        0x0800098e:    f8901021    ..!.    LDRB     r1,[r0,#0x21]
        0x08000992:    2200        ."      MOVS     r2,#0
        0x08000994:    2902        .)      CMP      r1,#2
        0x08000996:    d005        ..      BEQ      0x80009a4 ; HAL_DMA_Abort + 24
        0x08000998:    2104        .!      MOVS     r1,#4
        0x0800099a:    6381        .c      STR      r1,[r0,#0x38]
        0x0800099c:    f8802020    ..      STRB     r2,[r0,#0x20]
        0x080009a0:    2001        .       MOVS     r0,#1
        0x080009a2:    bd10        ..      POP      {r4,pc}
        0x080009a4:    6801        .h      LDR      r1,[r0,#0]
        0x080009a6:    680b        .h      LDR      r3,[r1,#0]
        0x080009a8:    f023030e    #...    BIC      r3,r3,#0xe
        0x080009ac:    600b        .`      STR      r3,[r1,#0]
        0x080009ae:    6801        .h      LDR      r1,[r0,#0]
        0x080009b0:    680b        .h      LDR      r3,[r1,#0]
        0x080009b2:    f0230301    #...    BIC      r3,r3,#1
        0x080009b6:    600b        .`      STR      r3,[r1,#0]
        0x080009b8:    f8903040    ..@0    LDRB     r3,[r0,#0x40]
        0x080009bc:    6bc4        .k      LDR      r4,[r0,#0x3c]
        0x080009be:    2101        .!      MOVS     r1,#1
        0x080009c0:    fa01f303    ....    LSL      r3,r1,r3
        0x080009c4:    6063        c`      STR      r3,[r4,#4]
        0x080009c6:    f8801021    ..!.    STRB     r1,[r0,#0x21]
        0x080009ca:    f8802020    ..      STRB     r2,[r0,#0x20]
        0x080009ce:    4610        .F      MOV      r0,r2
        0x080009d0:    bd10        ..      POP      {r4,pc}
        0x080009d2:    0000        ..      MOVS     r0,r0
    i.HAL_DMA_Abort_IT
    HAL_DMA_Abort_IT
        0x080009d4:    b510        ..      PUSH     {r4,lr}
        0x080009d6:    f8901021    ..!.    LDRB     r1,[r0,#0x21]
        0x080009da:    2400        .$      MOVS     r4,#0
        0x080009dc:    2902        .)      CMP      r1,#2
        0x080009de:    d003        ..      BEQ      0x80009e8 ; HAL_DMA_Abort_IT + 20
        0x080009e0:    2104        .!      MOVS     r1,#4
        0x080009e2:    6381        .c      STR      r1,[r0,#0x38]
        0x080009e4:    2401        .$      MOVS     r4,#1
        0x080009e6:    e03d        =.      B        0x8000a64 ; HAL_DMA_Abort_IT + 144
        0x080009e8:    6801        .h      LDR      r1,[r0,#0]
        0x080009ea:    680a        .h      LDR      r2,[r1,#0]
        0x080009ec:    f022020e    "...    BIC      r2,r2,#0xe
        0x080009f0:    600a        .`      STR      r2,[r1,#0]
        0x080009f2:    6801        .h      LDR      r1,[r0,#0]
        0x080009f4:    680a        .h      LDR      r2,[r1,#0]
        0x080009f6:    f0220201    "...    BIC      r2,r2,#1
        0x080009fa:    600a        .`      STR      r2,[r1,#0]
        0x080009fc:    4a1a        .J      LDR      r2,[pc,#104] ; [0x8000a68] = 0x40020008
        0x080009fe:    6801        .h      LDR      r1,[r0,#0]
        0x08000a00:    4291        .B      CMP      r1,r2
        0x08000a02:    d101        ..      BNE      0x8000a08 ; HAL_DMA_Abort_IT + 52
        0x08000a04:    2101        .!      MOVS     r1,#1
        0x08000a06:    e021        !.      B        0x8000a4c ; HAL_DMA_Abort_IT + 120
        0x08000a08:    4a17        .J      LDR      r2,[pc,#92] ; [0x8000a68] = 0x40020008
        0x08000a0a:    3214        .2      ADDS     r2,r2,#0x14
        0x08000a0c:    4291        .B      CMP      r1,r2
        0x08000a0e:    d101        ..      BNE      0x8000a14 ; HAL_DMA_Abort_IT + 64
        0x08000a10:    2110        .!      MOVS     r1,#0x10
        0x08000a12:    e01b        ..      B        0x8000a4c ; HAL_DMA_Abort_IT + 120
        0x08000a14:    4a14        .J      LDR      r2,[pc,#80] ; [0x8000a68] = 0x40020008
        0x08000a16:    3228        (2      ADDS     r2,r2,#0x28
        0x08000a18:    4291        .B      CMP      r1,r2
        0x08000a1a:    d101        ..      BNE      0x8000a20 ; HAL_DMA_Abort_IT + 76
        0x08000a1c:    1589        ..      ASRS     r1,r1,#22
        0x08000a1e:    e015        ..      B        0x8000a4c ; HAL_DMA_Abort_IT + 120
        0x08000a20:    4a11        .J      LDR      r2,[pc,#68] ; [0x8000a68] = 0x40020008
        0x08000a22:    323c        <2      ADDS     r2,r2,#0x3c
        0x08000a24:    4291        .B      CMP      r1,r2
        0x08000a26:    d101        ..      BNE      0x8000a2c ; HAL_DMA_Abort_IT + 88
        0x08000a28:    1489        ..      ASRS     r1,r1,#18
        0x08000a2a:    e00f        ..      B        0x8000a4c ; HAL_DMA_Abort_IT + 120
        0x08000a2c:    4a0e        .J      LDR      r2,[pc,#56] ; [0x8000a68] = 0x40020008
        0x08000a2e:    3250        P2      ADDS     r2,r2,#0x50
        0x08000a30:    4291        .B      CMP      r1,r2
        0x08000a32:    d102        ..      BNE      0x8000a3a ; HAL_DMA_Abort_IT + 102
        0x08000a34:    f44f3180    O..1    MOV      r1,#0x10000
        0x08000a38:    e008        ..      B        0x8000a4c ; HAL_DMA_Abort_IT + 120
        0x08000a3a:    4a0b        .J      LDR      r2,[pc,#44] ; [0x8000a68] = 0x40020008
        0x08000a3c:    3264        d2      ADDS     r2,r2,#0x64
        0x08000a3e:    4291        .B      CMP      r1,r2
        0x08000a40:    d102        ..      BNE      0x8000a48 ; HAL_DMA_Abort_IT + 116
        0x08000a42:    f44f1180    O...    MOV      r1,#0x100000
        0x08000a46:    e001        ..      B        0x8000a4c ; HAL_DMA_Abort_IT + 120
        0x08000a48:    f04f7180    O..q    MOV      r1,#0x1000000
        0x08000a4c:    4a06        .J      LDR      r2,[pc,#24] ; [0x8000a68] = 0x40020008
        0x08000a4e:    3a08        .:      SUBS     r2,r2,#8
        0x08000a50:    6051        Q`      STR      r1,[r2,#4]
        0x08000a52:    2101        .!      MOVS     r1,#1
        0x08000a54:    f8801021    ..!.    STRB     r1,[r0,#0x21]
        0x08000a58:    2100        .!      MOVS     r1,#0
        0x08000a5a:    f8801020    .. .    STRB     r1,[r0,#0x20]
        0x08000a5e:    6b41        Ak      LDR      r1,[r0,#0x34]
        0x08000a60:    b101        ..      CBZ      r1,0x8000a64 ; HAL_DMA_Abort_IT + 144
        0x08000a62:    4788        .G      BLX      r1
        0x08000a64:    4620         F      MOV      r0,r4
        0x08000a66:    bd10        ..      POP      {r4,pc}
    $d
        0x08000a68:    40020008    ...@    DCD    1073872904
    $t
    i.HAL_GPIO_Init
    HAL_GPIO_Init
        0x08000a6c:    e92d4ff8    -..O    PUSH     {r3-r11,lr}
        0x08000a70:    f8df91b8    ....    LDR      r9,[pc,#440] ; [0x8000c2c] = 0x40010408
        0x08000a74:    2400        .$      MOVS     r4,#0
        0x08000a76:    f1a90b04    ....    SUB      r11,r9,#4
        0x08000a7a:    4623        #F      MOV      r3,r4
        0x08000a7c:    270f        .'      MOVS     r7,#0xf
        0x08000a7e:    f1090a04    ....    ADD      r10,r9,#4
        0x08000a82:    f1ab0e04    ....    SUB      lr,r11,#4
        0x08000a86:    e0c9        ..      B        0x8000c1c ; HAL_GPIO_Init + 432
        0x08000a88:    2501        .%      MOVS     r5,#1
        0x08000a8a:    40a5        .@      LSLS     r5,r5,r4
        0x08000a8c:    402a        *@      ANDS     r2,r2,r5
        0x08000a8e:    42aa        .B      CMP      r2,r5
        0x08000a90:    d17d        }.      BNE      0x8000b8e ; HAL_GPIO_Init + 290
        0x08000a92:    4e67        gN      LDR      r6,[pc,#412] ; [0x8000c30] = 0x10110000
        0x08000a94:    f8d1c004    ....    LDR      r12,[r1,#4]
        0x08000a98:    ebac0806    ....    SUB      r8,r12,r6
        0x08000a9c:    45b4        .E      CMP      r12,r6
        0x08000a9e:    d032        2.      BEQ      0x8000b06 ; HAL_GPIO_Init + 154
        0x08000aa0:    dc14        ..      BGT      0x8000acc ; HAL_GPIO_Init + 96
        0x08000aa2:    f1bc0f03    ....    CMP      r12,#3
        0x08000aa6:    d03a        :.      BEQ      0x8000b1e ; HAL_GPIO_Init + 178
        0x08000aa8:    dc09        ..      BGT      0x8000abe ; HAL_GPIO_Init + 82
        0x08000aaa:    f1bc0f00    ....    CMP      r12,#0
        0x08000aae:    d02a        *.      BEQ      0x8000b06 ; HAL_GPIO_Init + 154
        0x08000ab0:    f1bc0f01    ....    CMP      r12,#1
        0x08000ab4:    d01c        ..      BEQ      0x8000af0 ; HAL_GPIO_Init + 132
        0x08000ab6:    f1bc0f02    ....    CMP      r12,#2
        0x08000aba:    d131        1.      BNE      0x8000b20 ; HAL_GPIO_Init + 180
        0x08000abc:    e01d        ..      B        0x8000afa ; HAL_GPIO_Init + 142
        0x08000abe:    f1bc0f11    ....    CMP      r12,#0x11
        0x08000ac2:    d017        ..      BEQ      0x8000af4 ; HAL_GPIO_Init + 136
        0x08000ac4:    f1bc0f12    ....    CMP      r12,#0x12
        0x08000ac8:    d12a        *.      BNE      0x8000b20 ; HAL_GPIO_Init + 180
        0x08000aca:    e019        ..      B        0x8000b00 ; HAL_GPIO_Init + 148
        0x08000acc:    f5b81f88    ....    CMP      r8,#0x110000
        0x08000ad0:    d019        ..      BEQ      0x8000b06 ; HAL_GPIO_Init + 154
        0x08000ad2:    dc06        ..      BGT      0x8000ae2 ; HAL_GPIO_Init + 118
        0x08000ad4:    f5b83f80    ...?    CMP      r8,#0x10000
        0x08000ad8:    d015        ..      BEQ      0x8000b06 ; HAL_GPIO_Init + 154
        0x08000ada:    f5b81f80    ....    CMP      r8,#0x100000
        0x08000ade:    d11f        ..      BNE      0x8000b20 ; HAL_GPIO_Init + 180
        0x08000ae0:    e011        ..      B        0x8000b06 ; HAL_GPIO_Init + 154
        0x08000ae2:    f5b81f00    ....    CMP      r8,#0x200000
        0x08000ae6:    d00e        ..      BEQ      0x8000b06 ; HAL_GPIO_Init + 154
        0x08000ae8:    f5b81f04    ....    CMP      r8,#0x210000
        0x08000aec:    d118        ..      BNE      0x8000b20 ; HAL_GPIO_Init + 180
        0x08000aee:    e00a        ..      B        0x8000b06 ; HAL_GPIO_Init + 154
        0x08000af0:    68cb        .h      LDR      r3,[r1,#0xc]
        0x08000af2:    e015        ..      B        0x8000b20 ; HAL_GPIO_Init + 180
        0x08000af4:    68cb        .h      LDR      r3,[r1,#0xc]
        0x08000af6:    1d1b        ..      ADDS     r3,r3,#4
        0x08000af8:    e012        ..      B        0x8000b20 ; HAL_GPIO_Init + 180
        0x08000afa:    68cb        .h      LDR      r3,[r1,#0xc]
        0x08000afc:    3308        .3      ADDS     r3,r3,#8
        0x08000afe:    e00f        ..      B        0x8000b20 ; HAL_GPIO_Init + 180
        0x08000b00:    68cb        .h      LDR      r3,[r1,#0xc]
        0x08000b02:    330c        .3      ADDS     r3,r3,#0xc
        0x08000b04:    e00c        ..      B        0x8000b20 ; HAL_GPIO_Init + 180
        0x08000b06:    688b        .h      LDR      r3,[r1,#8]
        0x08000b08:    b12b        +.      CBZ      r3,0x8000b16 ; HAL_GPIO_Init + 170
        0x08000b0a:    2b01        .+      CMP      r3,#1
        0x08000b0c:    f04f0308    O...    MOV      r3,#8
        0x08000b10:    d003        ..      BEQ      0x8000b1a ; HAL_GPIO_Init + 174
        0x08000b12:    6145        Ea      STR      r5,[r0,#0x14]
        0x08000b14:    e004        ..      B        0x8000b20 ; HAL_GPIO_Init + 180
        0x08000b16:    2304        .#      MOVS     r3,#4
        0x08000b18:    e002        ..      B        0x8000b20 ; HAL_GPIO_Init + 180
        0x08000b1a:    6105        .a      STR      r5,[r0,#0x10]
        0x08000b1c:    e000        ..      B        0x8000b20 ; HAL_GPIO_Init + 180
        0x08000b1e:    2300        .#      MOVS     r3,#0
        0x08000b20:    2aff        .*      CMP      r2,#0xff
        0x08000b22:    d801        ..      BHI      0x8000b28 ; HAL_GPIO_Init + 188
        0x08000b24:    4606        .F      MOV      r6,r0
        0x08000b26:    e001        ..      B        0x8000b2c ; HAL_GPIO_Init + 192
        0x08000b28:    f1000604    ....    ADD      r6,r0,#4
        0x08000b2c:    ea4f0584    O...    LSL      r5,r4,#2
        0x08000b30:    d901        ..      BLS      0x8000b36 ; HAL_GPIO_Init + 202
        0x08000b32:    f1a50520    .. .    SUB      r5,r5,#0x20
        0x08000b36:    f8d68000    ....    LDR      r8,[r6,#0]
        0x08000b3a:    fa07fc05    ....    LSL      r12,r7,r5
        0x08000b3e:    ea28080c    (...    BIC      r8,r8,r12
        0x08000b42:    fa03f505    ....    LSL      r5,r3,r5
        0x08000b46:    ea480805    H...    ORR      r8,r8,r5
        0x08000b4a:    f8c68000    ....    STR      r8,[r6,#0]
        0x08000b4e:    684d        Mh      LDR      r5,[r1,#4]
        0x08000b50:    00ed        ..      LSLS     r5,r5,#3
        0x08000b52:    d562        b.      BPL      0x8000c1a ; HAL_GPIO_Init + 430
        0x08000b54:    4d37        7M      LDR      r5,[pc,#220] ; [0x8000c34] = 0x40021000
        0x08000b56:    69ae        .i      LDR      r6,[r5,#0x18]
        0x08000b58:    f0460601    F...    ORR      r6,r6,#1
        0x08000b5c:    61ae        .a      STR      r6,[r5,#0x18]
        0x08000b5e:    69ad        .i      LDR      r5,[r5,#0x18]
        0x08000b60:    f0240603    $...    BIC      r6,r4,#3
        0x08000b64:    f0050501    ....    AND      r5,r5,#1
        0x08000b68:    9500        ..      STR      r5,[sp,#0]
        0x08000b6a:    4d33        3M      LDR      r5,[pc,#204] ; [0x8000c38] = 0x40010000
        0x08000b6c:    eb060c05    ....    ADD      r12,r6,r5
        0x08000b70:    f8dc5008    ...P    LDR      r5,[r12,#8]
        0x08000b74:    07a6        ..      LSLS     r6,r4,#30
        0x08000b76:    0f36        6.      LSRS     r6,r6,#28
        0x08000b78:    fa07f806    ....    LSL      r8,r7,r6
        0x08000b7c:    ea250508    %...    BIC      r5,r5,r8
        0x08000b80:    f8df80b8    ....    LDR      r8,[pc,#184] ; [0x8000c3c] = 0x40010800
        0x08000b84:    4540        @E      CMP      r0,r8
        0x08000b86:    d103        ..      BNE      0x8000b90 ; HAL_GPIO_Init + 292
        0x08000b88:    f04f0800    O...    MOV      r8,#0
        0x08000b8c:    e017        ..      B        0x8000bbe ; HAL_GPIO_Init + 338
        0x08000b8e:    e044        D.      B        0x8000c1a ; HAL_GPIO_Init + 430
        0x08000b90:    f8df80ac    ....    LDR      r8,[pc,#172] ; [0x8000c40] = 0x40010c00
        0x08000b94:    4540        @E      CMP      r0,r8
        0x08000b96:    d102        ..      BNE      0x8000b9e ; HAL_GPIO_Init + 306
        0x08000b98:    f04f0801    O...    MOV      r8,#1
        0x08000b9c:    e00f        ..      B        0x8000bbe ; HAL_GPIO_Init + 338
        0x08000b9e:    f8df80a4    ....    LDR      r8,[pc,#164] ; [0x8000c44] = 0x40011000
        0x08000ba2:    4540        @E      CMP      r0,r8
        0x08000ba4:    d102        ..      BNE      0x8000bac ; HAL_GPIO_Init + 320
        0x08000ba6:    f04f0802    O...    MOV      r8,#2
        0x08000baa:    e008        ..      B        0x8000bbe ; HAL_GPIO_Init + 338
        0x08000bac:    f8df8098    ....    LDR      r8,[pc,#152] ; [0x8000c48] = 0x40011400
        0x08000bb0:    4540        @E      CMP      r0,r8
        0x08000bb2:    d102        ..      BNE      0x8000bba ; HAL_GPIO_Init + 334
        0x08000bb4:    f04f0803    O...    MOV      r8,#3
        0x08000bb8:    e001        ..      B        0x8000bbe ; HAL_GPIO_Init + 338
        0x08000bba:    f04f0804    O...    MOV      r8,#4
        0x08000bbe:    fa08f806    ....    LSL      r8,r8,r6
        0x08000bc2:    ea480805    H...    ORR      r8,r8,r5
        0x08000bc6:    f8cc8008    ....    STR      r8,[r12,#8]
        0x08000bca:    684d        Mh      LDR      r5,[r1,#4]
        0x08000bcc:    f8d96000    ...`    LDR      r6,[r9,#0]
        0x08000bd0:    02ed        ..      LSLS     r5,r5,#11
        0x08000bd2:    464d        MF      MOV      r5,r9
        0x08000bd4:    d501        ..      BPL      0x8000bda ; HAL_GPIO_Init + 366
        0x08000bd6:    4316        .C      ORRS     r6,r6,r2
        0x08000bd8:    e000        ..      B        0x8000bdc ; HAL_GPIO_Init + 368
        0x08000bda:    4396        .C      BICS     r6,r6,r2
        0x08000bdc:    602e        .`      STR      r6,[r5,#0]
        0x08000bde:    684d        Mh      LDR      r5,[r1,#4]
        0x08000be0:    f8da6000    ...`    LDR      r6,[r10,#0]
        0x08000be4:    02ad        ..      LSLS     r5,r5,#10
        0x08000be6:    4655        UF      MOV      r5,r10
        0x08000be8:    d501        ..      BPL      0x8000bee ; HAL_GPIO_Init + 386
        0x08000bea:    4316        .C      ORRS     r6,r6,r2
        0x08000bec:    e000        ..      B        0x8000bf0 ; HAL_GPIO_Init + 388
        0x08000bee:    4396        .C      BICS     r6,r6,r2
        0x08000bf0:    602e        .`      STR      r6,[r5,#0]
        0x08000bf2:    684d        Mh      LDR      r5,[r1,#4]
        0x08000bf4:    f8db6000    ...`    LDR      r6,[r11,#0]
        0x08000bf8:    03ad        ..      LSLS     r5,r5,#14
        0x08000bfa:    465d        ]F      MOV      r5,r11
        0x08000bfc:    d501        ..      BPL      0x8000c02 ; HAL_GPIO_Init + 406
        0x08000bfe:    4316        .C      ORRS     r6,r6,r2
        0x08000c00:    e000        ..      B        0x8000c04 ; HAL_GPIO_Init + 408
        0x08000c02:    4396        .C      BICS     r6,r6,r2
        0x08000c04:    602e        .`      STR      r6,[r5,#0]
        0x08000c06:    684d        Mh      LDR      r5,[r1,#4]
        0x08000c08:    f8de6000    ...`    LDR      r6,[lr,#0]
        0x08000c0c:    03ed        ..      LSLS     r5,r5,#15
        0x08000c0e:    4675        uF      MOV      r5,lr
        0x08000c10:    d501        ..      BPL      0x8000c16 ; HAL_GPIO_Init + 426
        0x08000c12:    4316        .C      ORRS     r6,r6,r2
        0x08000c14:    e000        ..      B        0x8000c18 ; HAL_GPIO_Init + 428
        0x08000c16:    4396        .C      BICS     r6,r6,r2
        0x08000c18:    602e        .`      STR      r6,[r5,#0]
        0x08000c1a:    1c64        d.      ADDS     r4,r4,#1
        0x08000c1c:    680d        .h      LDR      r5,[r1,#0]
        0x08000c1e:    462a        *F      MOV      r2,r5
        0x08000c20:    40e5        .@      LSRS     r5,r5,r4
        0x08000c22:    f47faf31    ..1.    BNE      0x8000a88 ; HAL_GPIO_Init + 28
        0x08000c26:    e8bd8ff8    ....    POP      {r3-r11,pc}
    $d
        0x08000c2a:    0000        ..      DCW    0
        0x08000c2c:    40010408    ...@    DCD    1073808392
        0x08000c30:    10110000    ....    DCD    269549568
        0x08000c34:    40021000    ...@    DCD    1073876992
        0x08000c38:    40010000    ...@    DCD    1073807360
        0x08000c3c:    40010800    ...@    DCD    1073809408
        0x08000c40:    40010c00    ...@    DCD    1073810432
        0x08000c44:    40011000    ...@    DCD    1073811456
        0x08000c48:    40011400    ...@    DCD    1073812480
    $t
    i.HAL_GPIO_WritePin
    HAL_GPIO_WritePin
        0x08000c4c:    b10a        ..      CBZ      r2,0x8000c52 ; HAL_GPIO_WritePin + 6
        0x08000c4e:    6101        .a      STR      r1,[r0,#0x10]
        0x08000c50:    4770        pG      BX       lr
        0x08000c52:    0409        ..      LSLS     r1,r1,#16
        0x08000c54:    e7fb        ..      B        0x8000c4e ; HAL_GPIO_WritePin + 2
        0x08000c56:    0000        ..      MOVS     r0,r0
    i.HAL_GetTick
    HAL_GetTick
        0x08000c58:    4801        .H      LDR      r0,[pc,#4] ; [0x8000c60] = 0x2000001c
        0x08000c5a:    6880        .h      LDR      r0,[r0,#8]
        0x08000c5c:    4770        pG      BX       lr
    $d
        0x08000c5e:    0000        ..      DCW    0
        0x08000c60:    2000001c    ...     DCD    536870940
    $t
    i.HAL_IncTick
    HAL_IncTick
        0x08000c64:    4802        .H      LDR      r0,[pc,#8] ; [0x8000c70] = 0x2000001c
        0x08000c66:    6881        .h      LDR      r1,[r0,#8]
        0x08000c68:    7802        .x      LDRB     r2,[r0,#0]
        0x08000c6a:    4411        .D      ADD      r1,r1,r2
        0x08000c6c:    6081        .`      STR      r1,[r0,#8]
        0x08000c6e:    4770        pG      BX       lr
    $d
        0x08000c70:    2000001c    ...     DCD    536870940
    $t
    i.HAL_Init
    HAL_Init
        0x08000c74:    4807        .H      LDR      r0,[pc,#28] ; [0x8000c94] = 0x40022000
        0x08000c76:    b510        ..      PUSH     {r4,lr}
        0x08000c78:    6801        .h      LDR      r1,[r0,#0]
        0x08000c7a:    f0410110    A...    ORR      r1,r1,#0x10
        0x08000c7e:    6001        .`      STR      r1,[r0,#0]
        0x08000c80:    2003        .       MOVS     r0,#3
        0x08000c82:    f000f875    ..u.    BL       HAL_NVIC_SetPriorityGrouping ; 0x8000d70
        0x08000c86:    200f        .       MOVS     r0,#0xf
        0x08000c88:    f000f806    ....    BL       HAL_InitTick ; 0x8000c98
        0x08000c8c:    f000f824    ..$.    BL       HAL_MspInit ; 0x8000cd8
        0x08000c90:    2000        .       MOVS     r0,#0
        0x08000c92:    bd10        ..      POP      {r4,pc}
    $d
        0x08000c94:    40022000    . .@    DCD    1073881088
    $t
    i.HAL_InitTick
    HAL_InitTick
        0x08000c98:    b570        p.      PUSH     {r4-r6,lr}
        0x08000c9a:    4d0d        .M      LDR      r5,[pc,#52] ; [0x8000cd0] = 0x2000001c
        0x08000c9c:    4604        .F      MOV      r4,r0
        0x08000c9e:    f44f717a    O.zq    MOV      r1,#0x3e8
        0x08000ca2:    7828        (x      LDRB     r0,[r5,#0]
        0x08000ca4:    fbb1f0f0    ....    UDIV     r0,r1,r0
        0x08000ca8:    490a        .I      LDR      r1,[pc,#40] ; [0x8000cd4] = 0x20000028
        0x08000caa:    6809        .h      LDR      r1,[r1,#0]
        0x08000cac:    fbb1f0f0    ....    UDIV     r0,r1,r0
        0x08000cb0:    f000fba4    ....    BL       HAL_SYSTICK_Config ; 0x80013fc
        0x08000cb4:    b948        H.      CBNZ     r0,0x8000cca ; HAL_InitTick + 50
        0x08000cb6:    2c10        .,      CMP      r4,#0x10
        0x08000cb8:    d207        ..      BCS      0x8000cca ; HAL_InitTick + 50
        0x08000cba:    2200        ."      MOVS     r2,#0
        0x08000cbc:    4621        !F      MOV      r1,r4
        0x08000cbe:    1e50        P.      SUBS     r0,r2,#1
        0x08000cc0:    f000f836    ..6.    BL       HAL_NVIC_SetPriority ; 0x8000d30
        0x08000cc4:    2000        .       MOVS     r0,#0
        0x08000cc6:    606c        l`      STR      r4,[r5,#4]
        0x08000cc8:    bd70        p.      POP      {r4-r6,pc}
        0x08000cca:    2001        .       MOVS     r0,#1
        0x08000ccc:    bd70        p.      POP      {r4-r6,pc}
    $d
        0x08000cce:    0000        ..      DCW    0
        0x08000cd0:    2000001c    ...     DCD    536870940
        0x08000cd4:    20000028    (..     DCD    536870952
    $t
    i.HAL_MspInit
    HAL_MspInit
        0x08000cd8:    480c        .H      LDR      r0,[pc,#48] ; [0x8000d0c] = 0x40021000
        0x08000cda:    b508        ..      PUSH     {r3,lr}
        0x08000cdc:    6981        .i      LDR      r1,[r0,#0x18]
        0x08000cde:    f0410101    A...    ORR      r1,r1,#1
        0x08000ce2:    6181        .a      STR      r1,[r0,#0x18]
        0x08000ce4:    6981        .i      LDR      r1,[r0,#0x18]
        0x08000ce6:    f0010101    ....    AND      r1,r1,#1
        0x08000cea:    9100        ..      STR      r1,[sp,#0]
        0x08000cec:    69c1        .i      LDR      r1,[r0,#0x1c]
        0x08000cee:    f0415180    A..Q    ORR      r1,r1,#0x10000000
        0x08000cf2:    61c1        .a      STR      r1,[r0,#0x1c]
        0x08000cf4:    69c0        .i      LDR      r0,[r0,#0x1c]
        0x08000cf6:    f0005080    ...P    AND      r0,r0,#0x10000000
        0x08000cfa:    9000        ..      STR      r0,[sp,#0]
        0x08000cfc:    4804        .H      LDR      r0,[pc,#16] ; [0x8000d10] = 0x40010000
        0x08000cfe:    6841        Ah      LDR      r1,[r0,#4]
        0x08000d00:    f02161e0    !..a    BIC      r1,r1,#0x7000000
        0x08000d04:    f0417100    A..q    ORR      r1,r1,#0x2000000
        0x08000d08:    6041        A`      STR      r1,[r0,#4]
        0x08000d0a:    bd08        ..      POP      {r3,pc}
    $d
        0x08000d0c:    40021000    ...@    DCD    1073876992
        0x08000d10:    40010000    ...@    DCD    1073807360
    $t
    i.HAL_NVIC_EnableIRQ
    HAL_NVIC_EnableIRQ
        0x08000d14:    2800        .(      CMP      r0,#0
        0x08000d16:    db09        ..      BLT      0x8000d2c ; HAL_NVIC_EnableIRQ + 24
        0x08000d18:    f000021f    ....    AND      r2,r0,#0x1f
        0x08000d1c:    2101        .!      MOVS     r1,#1
        0x08000d1e:    4091        .@      LSLS     r1,r1,r2
        0x08000d20:    0940        @.      LSRS     r0,r0,#5
        0x08000d22:    0080        ..      LSLS     r0,r0,#2
        0x08000d24:    f10020e0    ...     ADD      r0,r0,#0xe000e000
        0x08000d28:    f8c01100    ....    STR      r1,[r0,#0x100]
        0x08000d2c:    4770        pG      BX       lr
        0x08000d2e:    0000        ..      MOVS     r0,r0
    i.HAL_NVIC_SetPriority
    HAL_NVIC_SetPriority
        0x08000d30:    b4f0        ..      PUSH     {r4-r7}
        0x08000d32:    4b0e        .K      LDR      r3,[pc,#56] ; [0x8000d6c] = 0xe000ed0c
        0x08000d34:    681b        .h      LDR      r3,[r3,#0]
        0x08000d36:    460c        .F      MOV      r4,r1
        0x08000d38:    f3c32302    ...#    UBFX     r3,r3,#8,#3
        0x08000d3c:    f1c30507    ....    RSB      r5,r3,#7
        0x08000d40:    2d04        .-      CMP      r5,#4
        0x08000d42:    d900        ..      BLS      0x8000d46 ; HAL_NVIC_SetPriority + 22
        0x08000d44:    2504        .%      MOVS     r5,#4
        0x08000d46:    1d19        ..      ADDS     r1,r3,#4
        0x08000d48:    2907        .)      CMP      r1,#7
        0x08000d4a:    d201        ..      BCS      0x8000d50 ; HAL_NVIC_SetPriority + 32
        0x08000d4c:    2300        .#      MOVS     r3,#0
        0x08000d4e:    e000        ..      B        0x8000d52 ; HAL_NVIC_SetPriority + 34
        0x08000d50:    1edb        ..      SUBS     r3,r3,#3
        0x08000d52:    2601        .&      MOVS     r6,#1
        0x08000d54:    fa06f105    ....    LSL      r1,r6,r5
        0x08000d58:    1e49        I.      SUBS     r1,r1,#1
        0x08000d5a:    4021        !@      ANDS     r1,r1,r4
        0x08000d5c:    4099        .@      LSLS     r1,r1,r3
        0x08000d5e:    409e        .@      LSLS     r6,r6,r3
        0x08000d60:    1e76        v.      SUBS     r6,r6,#1
        0x08000d62:    4016        .@      ANDS     r6,r6,r2
        0x08000d64:    4331        1C      ORRS     r1,r1,r6
        0x08000d66:    bcf0        ..      POP      {r4-r7}
        0x08000d68:    f001bc3a    ..:.    B.W      __NVIC_SetPriority ; 0x80025e0
    $d
        0x08000d6c:    e000ed0c    ....    DCD    3758157068
    $t
    i.HAL_NVIC_SetPriorityGrouping
    HAL_NVIC_SetPriorityGrouping
        0x08000d70:    4906        .I      LDR      r1,[pc,#24] ; [0x8000d8c] = 0xe000ed0c
        0x08000d72:    f0000207    ....    AND      r2,r0,#7
        0x08000d76:    6808        .h      LDR      r0,[r1,#0]
        0x08000d78:    f64f03ff    O...    MOV      r3,#0xf8ff
        0x08000d7c:    4018        .@      ANDS     r0,r0,r3
        0x08000d7e:    ea402002    @..     ORR      r0,r0,r2,LSL #8
        0x08000d82:    4a03        .J      LDR      r2,[pc,#12] ; [0x8000d90] = 0x5fa0000
        0x08000d84:    4310        .C      ORRS     r0,r0,r2
        0x08000d86:    6008        .`      STR      r0,[r1,#0]
        0x08000d88:    4770        pG      BX       lr
    $d
        0x08000d8a:    0000        ..      DCW    0
        0x08000d8c:    e000ed0c    ....    DCD    3758157068
        0x08000d90:    05fa0000    ....    DCD    100270080
    $t
    i.HAL_RCCEx_GetPeriphCLKFreq
    HAL_RCCEx_GetPeriphCLKFreq
        0x08000d94:    b510        ..      PUSH     {r4,lr}
        0x08000d96:    4601        .F      MOV      r1,r0
        0x08000d98:    2000        .       MOVS     r0,#0
        0x08000d9a:    4c23        #L      LDR      r4,[pc,#140] ; [0x8000e28] = 0x40021000
        0x08000d9c:    2901        .)      CMP      r1,#1
        0x08000d9e:    d022        ".      BEQ      0x8000de6 ; HAL_RCCEx_GetPeriphCLKFreq + 82
        0x08000da0:    2902        .)      CMP      r1,#2
        0x08000da2:    d039        9.      BEQ      0x8000e18 ; HAL_RCCEx_GetPeriphCLKFreq + 132
        0x08000da4:    2910        .)      CMP      r1,#0x10
        0x08000da6:    d11d        ..      BNE      0x8000de4 ; HAL_RCCEx_GetPeriphCLKFreq + 80
        0x08000da8:    6861        ah      LDR      r1,[r4,#4]
        0x08000daa:    6822        "h      LDR      r2,[r4,#0]
        0x08000dac:    01d2        ..      LSLS     r2,r2,#7
        0x08000dae:    d519        ..      BPL      0x8000de4 ; HAL_RCCEx_GetPeriphCLKFreq + 80
        0x08000db0:    481e        .H      LDR      r0,[pc,#120] ; [0x8000e2c] = 0x8003144
        0x08000db2:    f3c14283    ...B    UBFX     r2,r1,#18,#4
        0x08000db6:    03c9        ..      LSLS     r1,r1,#15
        0x08000db8:    5c80        .\      LDRB     r0,[r0,r2]
        0x08000dba:    d50a        ..      BPL      0x8000dd2 ; HAL_RCCEx_GetPeriphCLKFreq + 62
        0x08000dbc:    6861        ah      LDR      r1,[r4,#4]
        0x08000dbe:    4a1b        .J      LDR      r2,[pc,#108] ; [0x8000e2c] = 0x8003144
        0x08000dc0:    f3c14140    ..@A    UBFX     r1,r1,#17,#1
        0x08000dc4:    1e92        ..      SUBS     r2,r2,#2
        0x08000dc6:    5c51        Q\      LDRB     r1,[r2,r1]
        0x08000dc8:    4a19        .J      LDR      r2,[pc,#100] ; [0x8000e30] = 0x7a1200
        0x08000dca:    fbb2f1f1    ....    UDIV     r1,r2,r1
        0x08000dce:    4348        HC      MULS     r0,r1,r0
        0x08000dd0:    e001        ..      B        0x8000dd6 ; HAL_RCCEx_GetPeriphCLKFreq + 66
        0x08000dd2:    4918        .I      LDR      r1,[pc,#96] ; [0x8000e34] = 0x3d0900
        0x08000dd4:    4348        HC      MULS     r0,r1,r0
        0x08000dd6:    6861        ah      LDR      r1,[r4,#4]
        0x08000dd8:    0249        I.      LSLS     r1,r1,#9
        0x08000dda:    d403        ..      BMI      0x8000de4 ; HAL_RCCEx_GetPeriphCLKFreq + 80
        0x08000ddc:    0040        @.      LSLS     r0,r0,#1
        0x08000dde:    2103        .!      MOVS     r1,#3
        0x08000de0:    fbb0f0f1    ....    UDIV     r0,r0,r1
        0x08000de4:    bd10        ..      POP      {r4,pc}
        0x08000de6:    6a22        "j      LDR      r2,[r4,#0x20]
        0x08000de8:    f3c22101    ...!    UBFX     r1,r2,#8,#2
        0x08000dec:    2901        .)      CMP      r1,#1
        0x08000dee:    d103        ..      BNE      0x8000df8 ; HAL_RCCEx_GetPeriphCLKFreq + 100
        0x08000df0:    0792        ..      LSLS     r2,r2,#30
        0x08000df2:    d501        ..      BPL      0x8000df8 ; HAL_RCCEx_GetPeriphCLKFreq + 100
        0x08000df4:    03c8        ..      LSLS     r0,r1,#15
        0x08000df6:    bd10        ..      POP      {r4,pc}
        0x08000df8:    2902        .)      CMP      r1,#2
        0x08000dfa:    d105        ..      BNE      0x8000e08 ; HAL_RCCEx_GetPeriphCLKFreq + 116
        0x08000dfc:    6a62        bj      LDR      r2,[r4,#0x24]
        0x08000dfe:    0792        ..      LSLS     r2,r2,#30
        0x08000e00:    d502        ..      BPL      0x8000e08 ; HAL_RCCEx_GetPeriphCLKFreq + 116
        0x08000e02:    f6494040    I.@@    MOV      r0,#0x9c40
        0x08000e06:    bd10        ..      POP      {r4,pc}
        0x08000e08:    2903        .)      CMP      r1,#3
        0x08000e0a:    d1fc        ..      BNE      0x8000e06 ; HAL_RCCEx_GetPeriphCLKFreq + 114
        0x08000e0c:    6821        !h      LDR      r1,[r4,#0]
        0x08000e0e:    0389        ..      LSLS     r1,r1,#14
        0x08000e10:    d5f9        ..      BPL      0x8000e06 ; HAL_RCCEx_GetPeriphCLKFreq + 114
        0x08000e12:    f24f4024    O.$@    MOV      r0,#0xf424
        0x08000e16:    bd10        ..      POP      {r4,pc}
        0x08000e18:    f000f92a    ..*.    BL       HAL_RCC_GetPCLK2Freq ; 0x8001070
        0x08000e1c:    6861        ah      LDR      r1,[r4,#4]
        0x08000e1e:    f3c13181    ...1    UBFX     r1,r1,#14,#2
        0x08000e22:    1c49        I.      ADDS     r1,r1,#1
        0x08000e24:    0049        I.      LSLS     r1,r1,#1
        0x08000e26:    e7db        ..      B        0x8000de0 ; HAL_RCCEx_GetPeriphCLKFreq + 76
    $d
        0x08000e28:    40021000    ...@    DCD    1073876992
        0x08000e2c:    08003144    D1..    DCD    134230340
        0x08000e30:    007a1200    ..z.    DCD    8000000
        0x08000e34:    003d0900    ..=.    DCD    4000000
    $t
    i.HAL_RCCEx_PeriphCLKConfig
    HAL_RCCEx_PeriphCLKConfig
        0x08000e38:    e92d43f8    -..C    PUSH     {r3-r9,lr}
        0x08000e3c:    4605        .F      MOV      r5,r0
        0x08000e3e:    7800        .x      LDRB     r0,[r0,#0]
        0x08000e40:    4c35        5L      LDR      r4,[pc,#212] ; [0x8000f18] = 0x40021000
        0x08000e42:    07c0        ..      LSLS     r0,r0,#31
        0x08000e44:    d054        T.      BEQ      0x8000ef0 ; HAL_RCCEx_PeriphCLKConfig + 184
        0x08000e46:    69e0        .i      LDR      r0,[r4,#0x1c]
        0x08000e48:    2600        .&      MOVS     r6,#0
        0x08000e4a:    00c0        ..      LSLS     r0,r0,#3
        0x08000e4c:    d408        ..      BMI      0x8000e60 ; HAL_RCCEx_PeriphCLKConfig + 40
        0x08000e4e:    69e0        .i      LDR      r0,[r4,#0x1c]
        0x08000e50:    f0405080    @..P    ORR      r0,r0,#0x10000000
        0x08000e54:    61e0        .a      STR      r0,[r4,#0x1c]
        0x08000e56:    69e0        .i      LDR      r0,[r4,#0x1c]
        0x08000e58:    2601        .&      MOVS     r6,#1
        0x08000e5a:    f0005080    ...P    AND      r0,r0,#0x10000000
        0x08000e5e:    9000        ..      STR      r0,[sp,#0]
        0x08000e60:    482e        .H      LDR      r0,[pc,#184] ; [0x8000f1c] = 0x40007000
        0x08000e62:    6801        .h      LDR      r1,[r0,#0]
        0x08000e64:    05c9        ..      LSLS     r1,r1,#23
        0x08000e66:    d412        ..      BMI      0x8000e8e ; HAL_RCCEx_PeriphCLKConfig + 86
        0x08000e68:    6801        .h      LDR      r1,[r0,#0]
        0x08000e6a:    4680        .F      MOV      r8,r0
        0x08000e6c:    f4417180    A..q    ORR      r1,r1,#0x100
        0x08000e70:    6001        .`      STR      r1,[r0,#0]
        0x08000e72:    f7fffef1    ....    BL       HAL_GetTick ; 0x8000c58
        0x08000e76:    4607        .F      MOV      r7,r0
        0x08000e78:    e005        ..      B        0x8000e86 ; HAL_RCCEx_PeriphCLKConfig + 78
        0x08000e7a:    bf00        ..      NOP      
        0x08000e7c:    f7fffeec    ....    BL       HAL_GetTick ; 0x8000c58
        0x08000e80:    1bc0        ..      SUBS     r0,r0,r7
        0x08000e82:    2864        d(      CMP      r0,#0x64
        0x08000e84:    d823        #.      BHI      0x8000ece ; HAL_RCCEx_PeriphCLKConfig + 150
        0x08000e86:    f8d80000    ....    LDR      r0,[r8,#0]
        0x08000e8a:    05c0        ..      LSLS     r0,r0,#23
        0x08000e8c:    d5f6        ..      BPL      0x8000e7c ; HAL_RCCEx_PeriphCLKConfig + 68
        0x08000e8e:    6a20         j      LDR      r0,[r4,#0x20]
        0x08000e90:    f4107040    ..@p    ANDS     r0,r0,#0x300
        0x08000e94:    d021        !.      BEQ      0x8000eda ; HAL_RCCEx_PeriphCLKConfig + 162
        0x08000e96:    88a9        ..      LDRH     r1,[r5,#4]
        0x08000e98:    f4017140    ..@q    AND      r1,r1,#0x300
        0x08000e9c:    4281        .B      CMP      r1,r0
        0x08000e9e:    d01c        ..      BEQ      0x8000eda ; HAL_RCCEx_PeriphCLKConfig + 162
        0x08000ea0:    6a20         j      LDR      r0,[r4,#0x20]
        0x08000ea2:    491f        .I      LDR      r1,[pc,#124] ; [0x8000f20] = 0x42420440
        0x08000ea4:    2201        ."      MOVS     r2,#1
        0x08000ea6:    f4207040     .@p    BIC      r0,r0,#0x300
        0x08000eaa:    600a        .`      STR      r2,[r1,#0]
        0x08000eac:    2200        ."      MOVS     r2,#0
        0x08000eae:    600a        .`      STR      r2,[r1,#0]
        0x08000eb0:    6220         b      STR      r0,[r4,#0x20]
        0x08000eb2:    07c0        ..      LSLS     r0,r0,#31
        0x08000eb4:    d011        ..      BEQ      0x8000eda ; HAL_RCCEx_PeriphCLKConfig + 162
        0x08000eb6:    f7fffecf    ....    BL       HAL_GetTick ; 0x8000c58
        0x08000eba:    4607        .F      MOV      r7,r0
        0x08000ebc:    f2413888    A..8    MOV      r8,#0x1388
        0x08000ec0:    e008        ..      B        0x8000ed4 ; HAL_RCCEx_PeriphCLKConfig + 156
        0x08000ec2:    bf00        ..      NOP      
        0x08000ec4:    f7fffec8    ....    BL       HAL_GetTick ; 0x8000c58
        0x08000ec8:    1bc1        ..      SUBS     r1,r0,r7
        0x08000eca:    4541        AE      CMP      r1,r8
        0x08000ecc:    d902        ..      BLS      0x8000ed4 ; HAL_RCCEx_PeriphCLKConfig + 156
        0x08000ece:    2003        .       MOVS     r0,#3
        0x08000ed0:    e8bd83f8    ....    POP      {r3-r9,pc}
        0x08000ed4:    6a20         j      LDR      r0,[r4,#0x20]
        0x08000ed6:    0780        ..      LSLS     r0,r0,#30
        0x08000ed8:    d5f4        ..      BPL      0x8000ec4 ; HAL_RCCEx_PeriphCLKConfig + 140
        0x08000eda:    6a20         j      LDR      r0,[r4,#0x20]
        0x08000edc:    6869        ih      LDR      r1,[r5,#4]
        0x08000ede:    f4207040     .@p    BIC      r0,r0,#0x300
        0x08000ee2:    4308        .C      ORRS     r0,r0,r1
        0x08000ee4:    6220         b      STR      r0,[r4,#0x20]
        0x08000ee6:    b11e        ..      CBZ      r6,0x8000ef0 ; HAL_RCCEx_PeriphCLKConfig + 184
        0x08000ee8:    69e0        .i      LDR      r0,[r4,#0x1c]
        0x08000eea:    f0205080     ..P    BIC      r0,r0,#0x10000000
        0x08000eee:    61e0        .a      STR      r0,[r4,#0x1c]
        0x08000ef0:    7828        (x      LDRB     r0,[r5,#0]
        0x08000ef2:    0780        ..      LSLS     r0,r0,#30
        0x08000ef4:    d505        ..      BPL      0x8000f02 ; HAL_RCCEx_PeriphCLKConfig + 202
        0x08000ef6:    6860        `h      LDR      r0,[r4,#4]
        0x08000ef8:    68a9        .h      LDR      r1,[r5,#8]
        0x08000efa:    f4204040     .@@    BIC      r0,r0,#0xc000
        0x08000efe:    4308        .C      ORRS     r0,r0,r1
        0x08000f00:    6060        ``      STR      r0,[r4,#4]
        0x08000f02:    7828        (x      LDRB     r0,[r5,#0]
        0x08000f04:    06c0        ..      LSLS     r0,r0,#27
        0x08000f06:    d505        ..      BPL      0x8000f14 ; HAL_RCCEx_PeriphCLKConfig + 220
        0x08000f08:    6860        `h      LDR      r0,[r4,#4]
        0x08000f0a:    68e9        .h      LDR      r1,[r5,#0xc]
        0x08000f0c:    f4200080     ...    BIC      r0,r0,#0x400000
        0x08000f10:    4308        .C      ORRS     r0,r0,r1
        0x08000f12:    6060        ``      STR      r0,[r4,#4]
        0x08000f14:    2000        .       MOVS     r0,#0
        0x08000f16:    e7db        ..      B        0x8000ed0 ; HAL_RCCEx_PeriphCLKConfig + 152
    $d
        0x08000f18:    40021000    ...@    DCD    1073876992
        0x08000f1c:    40007000    .p.@    DCD    1073770496
        0x08000f20:    42420440    @.BB    DCD    1111622720
    $t
    i.HAL_RCC_ClockConfig
    HAL_RCC_ClockConfig
        0x08000f24:    e92d47f0    -..G    PUSH     {r4-r10,lr}
        0x08000f28:    460f        .F      MOV      r7,r1
        0x08000f2a:    0005        ..      MOVS     r5,r0
        0x08000f2c:    d061        a.      BEQ      0x8000ff2 ; HAL_RCC_ClockConfig + 206
        0x08000f2e:    4e43        CN      LDR      r6,[pc,#268] ; [0x800103c] = 0x40022000
        0x08000f30:    6830        0h      LDR      r0,[r6,#0]
        0x08000f32:    f0000007    ....    AND      r0,r0,#7
        0x08000f36:    42b8        .B      CMP      r0,r7
        0x08000f38:    d209        ..      BCS      0x8000f4e ; HAL_RCC_ClockConfig + 42
        0x08000f3a:    6830        0h      LDR      r0,[r6,#0]
        0x08000f3c:    f0200007     ...    BIC      r0,r0,#7
        0x08000f40:    4338        8C      ORRS     r0,r0,r7
        0x08000f42:    6030        0`      STR      r0,[r6,#0]
        0x08000f44:    6830        0h      LDR      r0,[r6,#0]
        0x08000f46:    f0000007    ....    AND      r0,r0,#7
        0x08000f4a:    42b8        .B      CMP      r0,r7
        0x08000f4c:    d151        Q.      BNE      0x8000ff2 ; HAL_RCC_ClockConfig + 206
        0x08000f4e:    6828        (h      LDR      r0,[r5,#0]
        0x08000f50:    4c3b        ;L      LDR      r4,[pc,#236] ; [0x8001040] = 0x40021000
        0x08000f52:    0781        ..      LSLS     r1,r0,#30
        0x08000f54:    d512        ..      BPL      0x8000f7c ; HAL_RCC_ClockConfig + 88
        0x08000f56:    0740        @.      LSLS     r0,r0,#29
        0x08000f58:    d503        ..      BPL      0x8000f62 ; HAL_RCC_ClockConfig + 62
        0x08000f5a:    6860        `h      LDR      r0,[r4,#4]
        0x08000f5c:    f44060e0    @..`    ORR      r0,r0,#0x700
        0x08000f60:    6060        ``      STR      r0,[r4,#4]
        0x08000f62:    7828        (x      LDRB     r0,[r5,#0]
        0x08000f64:    0700        ..      LSLS     r0,r0,#28
        0x08000f66:    d503        ..      BPL      0x8000f70 ; HAL_RCC_ClockConfig + 76
        0x08000f68:    6860        `h      LDR      r0,[r4,#4]
        0x08000f6a:    f4405060    @.`P    ORR      r0,r0,#0x3800
        0x08000f6e:    6060        ``      STR      r0,[r4,#4]
        0x08000f70:    6860        `h      LDR      r0,[r4,#4]
        0x08000f72:    68a9        .h      LDR      r1,[r5,#8]
        0x08000f74:    f02000f0     ...    BIC      r0,r0,#0xf0
        0x08000f78:    4308        .C      ORRS     r0,r0,r1
        0x08000f7a:    6060        ``      STR      r0,[r4,#4]
        0x08000f7c:    7828        (x      LDRB     r0,[r5,#0]
        0x08000f7e:    07c0        ..      LSLS     r0,r0,#31
        0x08000f80:    d028        (.      BEQ      0x8000fd4 ; HAL_RCC_ClockConfig + 176
        0x08000f82:    6868        hh      LDR      r0,[r5,#4]
        0x08000f84:    2801        .(      CMP      r0,#1
        0x08000f86:    d010        ..      BEQ      0x8000faa ; HAL_RCC_ClockConfig + 134
        0x08000f88:    6821        !h      LDR      r1,[r4,#0]
        0x08000f8a:    2802        .(      CMP      r0,#2
        0x08000f8c:    d010        ..      BEQ      0x8000fb0 ; HAL_RCC_ClockConfig + 140
        0x08000f8e:    0789        ..      LSLS     r1,r1,#30
        0x08000f90:    2900        .)      CMP      r1,#0
        0x08000f92:    da2e        ..      BGE      0x8000ff2 ; HAL_RCC_ClockConfig + 206
        0x08000f94:    6861        ah      LDR      r1,[r4,#4]
        0x08000f96:    f0210103    !...    BIC      r1,r1,#3
        0x08000f9a:    4301        .C      ORRS     r1,r1,r0
        0x08000f9c:    6061        a`      STR      r1,[r4,#4]
        0x08000f9e:    f7fffe5b    ..[.    BL       HAL_GetTick ; 0x8000c58
        0x08000fa2:    4680        .F      MOV      r8,r0
        0x08000fa4:    f2413988    A..9    MOV      r9,#0x1388
        0x08000fa8:    e00d        ..      B        0x8000fc6 ; HAL_RCC_ClockConfig + 162
        0x08000faa:    6821        !h      LDR      r1,[r4,#0]
        0x08000fac:    0389        ..      LSLS     r1,r1,#14
        0x08000fae:    e7ef        ..      B        0x8000f90 ; HAL_RCC_ClockConfig + 108
        0x08000fb0:    0189        ..      LSLS     r1,r1,#6
        0x08000fb2:    e7ed        ..      B        0x8000f90 ; HAL_RCC_ClockConfig + 108
        0x08000fb4:    f7fffe50    ..P.    BL       HAL_GetTick ; 0x8000c58
        0x08000fb8:    eba00108    ....    SUB      r1,r0,r8
        0x08000fbc:    4549        IE      CMP      r1,r9
        0x08000fbe:    d902        ..      BLS      0x8000fc6 ; HAL_RCC_ClockConfig + 162
        0x08000fc0:    2003        .       MOVS     r0,#3
        0x08000fc2:    e8bd87f0    ....    POP      {r4-r10,pc}
        0x08000fc6:    6860        `h      LDR      r0,[r4,#4]
        0x08000fc8:    6869        ih      LDR      r1,[r5,#4]
        0x08000fca:    f000000c    ....    AND      r0,r0,#0xc
        0x08000fce:    ebb00f81    ....    CMP      r0,r1,LSL #2
        0x08000fd2:    d1ef        ..      BNE      0x8000fb4 ; HAL_RCC_ClockConfig + 144
        0x08000fd4:    6830        0h      LDR      r0,[r6,#0]
        0x08000fd6:    f0000007    ....    AND      r0,r0,#7
        0x08000fda:    42b8        .B      CMP      r0,r7
        0x08000fdc:    d90b        ..      BLS      0x8000ff6 ; HAL_RCC_ClockConfig + 210
        0x08000fde:    6830        0h      LDR      r0,[r6,#0]
        0x08000fe0:    f0200007     ...    BIC      r0,r0,#7
        0x08000fe4:    4338        8C      ORRS     r0,r0,r7
        0x08000fe6:    6030        0`      STR      r0,[r6,#0]
        0x08000fe8:    6830        0h      LDR      r0,[r6,#0]
        0x08000fea:    f0000007    ....    AND      r0,r0,#7
        0x08000fee:    42b8        .B      CMP      r0,r7
        0x08000ff0:    d001        ..      BEQ      0x8000ff6 ; HAL_RCC_ClockConfig + 210
        0x08000ff2:    2001        .       MOVS     r0,#1
        0x08000ff4:    e7e5        ..      B        0x8000fc2 ; HAL_RCC_ClockConfig + 158
        0x08000ff6:    7828        (x      LDRB     r0,[r5,#0]
        0x08000ff8:    0740        @.      LSLS     r0,r0,#29
        0x08000ffa:    d505        ..      BPL      0x8001008 ; HAL_RCC_ClockConfig + 228
        0x08000ffc:    6860        `h      LDR      r0,[r4,#4]
        0x08000ffe:    68e9        .h      LDR      r1,[r5,#0xc]
        0x08001000:    f42060e0     ..`    BIC      r0,r0,#0x700
        0x08001004:    4308        .C      ORRS     r0,r0,r1
        0x08001006:    6060        ``      STR      r0,[r4,#4]
        0x08001008:    7828        (x      LDRB     r0,[r5,#0]
        0x0800100a:    0700        ..      LSLS     r0,r0,#28
        0x0800100c:    d506        ..      BPL      0x800101c ; HAL_RCC_ClockConfig + 248
        0x0800100e:    6860        `h      LDR      r0,[r4,#4]
        0x08001010:    6929        )i      LDR      r1,[r5,#0x10]
        0x08001012:    f4205060     .`P    BIC      r0,r0,#0x3800
        0x08001016:    ea4000c1    @...    ORR      r0,r0,r1,LSL #3
        0x0800101a:    6060        ``      STR      r0,[r4,#4]
        0x0800101c:    f000f838    ..8.    BL       HAL_RCC_GetSysClockFreq ; 0x8001090
        0x08001020:    6861        ah      LDR      r1,[r4,#4]
        0x08001022:    4a08        .J      LDR      r2,[pc,#32] ; [0x8001044] = 0x8003154
        0x08001024:    f3c11103    ....    UBFX     r1,r1,#4,#4
        0x08001028:    5c51        Q\      LDRB     r1,[r2,r1]
        0x0800102a:    40c8        .@      LSRS     r0,r0,r1
        0x0800102c:    4906        .I      LDR      r1,[pc,#24] ; [0x8001048] = 0x20000028
        0x0800102e:    6008        .`      STR      r0,[r1,#0]
        0x08001030:    4806        .H      LDR      r0,[pc,#24] ; [0x800104c] = 0x20000020
        0x08001032:    6800        .h      LDR      r0,[r0,#0]
        0x08001034:    f7fffe30    ..0.    BL       HAL_InitTick ; 0x8000c98
        0x08001038:    2000        .       MOVS     r0,#0
        0x0800103a:    e7c2        ..      B        0x8000fc2 ; HAL_RCC_ClockConfig + 158
    $d
        0x0800103c:    40022000    . .@    DCD    1073881088
        0x08001040:    40021000    ...@    DCD    1073876992
        0x08001044:    08003154    T1..    DCD    134230356
        0x08001048:    20000028    (..     DCD    536870952
        0x0800104c:    20000020     ..     DCD    536870944
    $t
    i.HAL_RCC_GetPCLK1Freq
    HAL_RCC_GetPCLK1Freq
        0x08001050:    4804        .H      LDR      r0,[pc,#16] ; [0x8001064] = 0x20000028
        0x08001052:    4905        .I      LDR      r1,[pc,#20] ; [0x8001068] = 0x40021000
        0x08001054:    6800        .h      LDR      r0,[r0,#0]
        0x08001056:    6849        Ih      LDR      r1,[r1,#4]
        0x08001058:    4a04        .J      LDR      r2,[pc,#16] ; [0x800106c] = 0x8003164
        0x0800105a:    f3c12102    ...!    UBFX     r1,r1,#8,#3
        0x0800105e:    5c51        Q\      LDRB     r1,[r2,r1]
        0x08001060:    40c8        .@      LSRS     r0,r0,r1
        0x08001062:    4770        pG      BX       lr
    $d
        0x08001064:    20000028    (..     DCD    536870952
        0x08001068:    40021000    ...@    DCD    1073876992
        0x0800106c:    08003164    d1..    DCD    134230372
    $t
    i.HAL_RCC_GetPCLK2Freq
    HAL_RCC_GetPCLK2Freq
        0x08001070:    4804        .H      LDR      r0,[pc,#16] ; [0x8001084] = 0x20000028
        0x08001072:    4905        .I      LDR      r1,[pc,#20] ; [0x8001088] = 0x40021000
        0x08001074:    6800        .h      LDR      r0,[r0,#0]
        0x08001076:    6849        Ih      LDR      r1,[r1,#4]
        0x08001078:    4a04        .J      LDR      r2,[pc,#16] ; [0x800108c] = 0x8003164
        0x0800107a:    f3c121c2    ...!    UBFX     r1,r1,#11,#3
        0x0800107e:    5c51        Q\      LDRB     r1,[r2,r1]
        0x08001080:    40c8        .@      LSRS     r0,r0,r1
        0x08001082:    4770        pG      BX       lr
    $d
        0x08001084:    20000028    (..     DCD    536870952
        0x08001088:    40021000    ...@    DCD    1073876992
        0x0800108c:    08003164    d1..    DCD    134230372
    $t
    i.HAL_RCC_GetSysClockFreq
    HAL_RCC_GetSysClockFreq
        0x08001090:    4a0e        .J      LDR      r2,[pc,#56] ; [0x80010cc] = 0x40021000
        0x08001092:    6851        Qh      LDR      r1,[r2,#4]
        0x08001094:    480e        .H      LDR      r0,[pc,#56] ; [0x80010d0] = 0x7a1200
        0x08001096:    f001030c    ....    AND      r3,r1,#0xc
        0x0800109a:    2b04        .+      CMP      r3,#4
        0x0800109c:    d011        ..      BEQ      0x80010c2 ; HAL_RCC_GetSysClockFreq + 50
        0x0800109e:    2b08        .+      CMP      r3,#8
        0x080010a0:    d10f        ..      BNE      0x80010c2 ; HAL_RCC_GetSysClockFreq + 50
        0x080010a2:    480c        .H      LDR      r0,[pc,#48] ; [0x80010d4] = 0x8003132
        0x080010a4:    f3c14383    ...C    UBFX     r3,r1,#18,#4
        0x080010a8:    03c9        ..      LSLS     r1,r1,#15
        0x080010aa:    5cc0        .\      LDRB     r0,[r0,r3]
        0x080010ac:    d50a        ..      BPL      0x80010c4 ; HAL_RCC_GetSysClockFreq + 52
        0x080010ae:    6851        Qh      LDR      r1,[r2,#4]
        0x080010b0:    4a08        .J      LDR      r2,[pc,#32] ; [0x80010d4] = 0x8003132
        0x080010b2:    f3c14140    ..@A    UBFX     r1,r1,#17,#1
        0x080010b6:    1e92        ..      SUBS     r2,r2,#2
        0x080010b8:    5c51        Q\      LDRB     r1,[r2,r1]
        0x080010ba:    4a05        .J      LDR      r2,[pc,#20] ; [0x80010d0] = 0x7a1200
        0x080010bc:    4350        PC      MULS     r0,r2,r0
        0x080010be:    fbb0f0f1    ....    UDIV     r0,r0,r1
        0x080010c2:    4770        pG      BX       lr
        0x080010c4:    4904        .I      LDR      r1,[pc,#16] ; [0x80010d8] = 0x3d0900
        0x080010c6:    4348        HC      MULS     r0,r1,r0
        0x080010c8:    4770        pG      BX       lr
    $d
        0x080010ca:    0000        ..      DCW    0
        0x080010cc:    40021000    ...@    DCD    1073876992
        0x080010d0:    007a1200    ..z.    DCD    8000000
        0x080010d4:    08003132    21..    DCD    134230322
        0x080010d8:    003d0900    ..=.    DCD    4000000
    $t
    i.HAL_RCC_OscConfig
    HAL_RCC_OscConfig
        0x080010dc:    e92d4ff8    -..O    PUSH     {r3-r11,lr}
        0x080010e0:    0004        ..      MOVS     r4,r0
        0x080010e2:    d070        p.      BEQ      0x80011c6 ; HAL_RCC_OscConfig + 234
        0x080010e4:    7820         x      LDRB     r0,[r4,#0]
        0x080010e6:    4dc0        .M      LDR      r5,[pc,#768] ; [0x80013e8] = 0x40021000
        0x080010e8:    07c0        ..      LSLS     r0,r0,#31
        0x080010ea:    d049        I.      BEQ      0x8001180 ; HAL_RCC_OscConfig + 164
        0x080010ec:    6868        hh      LDR      r0,[r5,#4]
        0x080010ee:    f3c00081    ....    UBFX     r0,r0,#2,#2
        0x080010f2:    2801        .(      CMP      r0,#1
        0x080010f4:    d007        ..      BEQ      0x8001106 ; HAL_RCC_OscConfig + 42
        0x080010f6:    6868        hh      LDR      r0,[r5,#4]
        0x080010f8:    f3c00081    ....    UBFX     r0,r0,#2,#2
        0x080010fc:    2802        .(      CMP      r0,#2
        0x080010fe:    d109        ..      BNE      0x8001114 ; HAL_RCC_OscConfig + 56
        0x08001100:    6868        hh      LDR      r0,[r5,#4]
        0x08001102:    03c0        ..      LSLS     r0,r0,#15
        0x08001104:    d506        ..      BPL      0x8001114 ; HAL_RCC_OscConfig + 56
        0x08001106:    6828        (h      LDR      r0,[r5,#0]
        0x08001108:    0380        ..      LSLS     r0,r0,#14
        0x0800110a:    d539        9.      BPL      0x8001180 ; HAL_RCC_OscConfig + 164
        0x0800110c:    6860        `h      LDR      r0,[r4,#4]
        0x0800110e:    2800        .(      CMP      r0,#0
        0x08001110:    d0e7        ..      BEQ      0x80010e2 ; HAL_RCC_OscConfig + 6
        0x08001112:    e035        5.      B        0x8001180 ; HAL_RCC_OscConfig + 164
        0x08001114:    6860        `h      LDR      r0,[r4,#4]
        0x08001116:    f5b03f80    ...?    CMP      r0,#0x10000
        0x0800111a:    d00b        ..      BEQ      0x8001134 ; HAL_RCC_OscConfig + 88
        0x0800111c:    b110        ..      CBZ      r0,0x8001124 ; HAL_RCC_OscConfig + 72
        0x0800111e:    f5b02fa0    .../    CMP      r0,#0x50000
        0x08001122:    d011        ..      BEQ      0x8001148 ; HAL_RCC_OscConfig + 108
        0x08001124:    6828        (h      LDR      r0,[r5,#0]
        0x08001126:    f4203080     ..0    BIC      r0,r0,#0x10000
        0x0800112a:    6028        (`      STR      r0,[r5,#0]
        0x0800112c:    6828        (h      LDR      r0,[r5,#0]
        0x0800112e:    f4202080     ..     BIC      r0,r0,#0x40000
        0x08001132:    e002        ..      B        0x800113a ; HAL_RCC_OscConfig + 94
        0x08001134:    6828        (h      LDR      r0,[r5,#0]
        0x08001136:    f4403080    @..0    ORR      r0,r0,#0x10000
        0x0800113a:    6028        (`      STR      r0,[r5,#0]
        0x0800113c:    6860        `h      LDR      r0,[r4,#4]
        0x0800113e:    b190        ..      CBZ      r0,0x8001166 ; HAL_RCC_OscConfig + 138
        0x08001140:    f7fffd8a    ....    BL       HAL_GetTick ; 0x8000c58
        0x08001144:    4606        .F      MOV      r6,r0
        0x08001146:    e00a        ..      B        0x800115e ; HAL_RCC_OscConfig + 130
        0x08001148:    6828        (h      LDR      r0,[r5,#0]
        0x0800114a:    f4402080    @..     ORR      r0,r0,#0x40000
        0x0800114e:    6028        (`      STR      r0,[r5,#0]
        0x08001150:    e7f0        ..      B        0x8001134 ; HAL_RCC_OscConfig + 88
        0x08001152:    bf00        ..      NOP      
        0x08001154:    f7fffd80    ....    BL       HAL_GetTick ; 0x8000c58
        0x08001158:    1b80        ..      SUBS     r0,r0,r6
        0x0800115a:    2864        d(      CMP      r0,#0x64
        0x0800115c:    d873        s.      BHI      0x8001246 ; HAL_RCC_OscConfig + 362
        0x0800115e:    6828        (h      LDR      r0,[r5,#0]
        0x08001160:    0380        ..      LSLS     r0,r0,#14
        0x08001162:    d5f7        ..      BPL      0x8001154 ; HAL_RCC_OscConfig + 120
        0x08001164:    e00c        ..      B        0x8001180 ; HAL_RCC_OscConfig + 164
        0x08001166:    f7fffd77    ..w.    BL       HAL_GetTick ; 0x8000c58
        0x0800116a:    4606        .F      MOV      r6,r0
        0x0800116c:    e005        ..      B        0x800117a ; HAL_RCC_OscConfig + 158
        0x0800116e:    bf00        ..      NOP      
        0x08001170:    f7fffd72    ..r.    BL       HAL_GetTick ; 0x8000c58
        0x08001174:    1b80        ..      SUBS     r0,r0,r6
        0x08001176:    2864        d(      CMP      r0,#0x64
        0x08001178:    d8f0        ..      BHI      0x800115c ; HAL_RCC_OscConfig + 128
        0x0800117a:    6828        (h      LDR      r0,[r5,#0]
        0x0800117c:    0380        ..      LSLS     r0,r0,#14
        0x0800117e:    d4f7        ..      BMI      0x8001170 ; HAL_RCC_OscConfig + 148
        0x08001180:    7820         x      LDRB     r0,[r4,#0]
        0x08001182:    4e9a        .N      LDR      r6,[pc,#616] ; [0x80013ec] = 0x42420000
        0x08001184:    0780        ..      LSLS     r0,r0,#30
        0x08001186:    f04f0901    O...    MOV      r9,#1
        0x0800118a:    f04f0800    O...    MOV      r8,#0
        0x0800118e:    d539        9.      BPL      0x8001204 ; HAL_RCC_OscConfig + 296
        0x08001190:    6868        hh      LDR      r0,[r5,#4]
        0x08001192:    f0100f0c    ....    TST      r0,#0xc
        0x08001196:    d007        ..      BEQ      0x80011a8 ; HAL_RCC_OscConfig + 204
        0x08001198:    6868        hh      LDR      r0,[r5,#4]
        0x0800119a:    f3c00081    ....    UBFX     r0,r0,#2,#2
        0x0800119e:    2802        .(      CMP      r0,#2
        0x080011a0:    d109        ..      BNE      0x80011b6 ; HAL_RCC_OscConfig + 218
        0x080011a2:    6868        hh      LDR      r0,[r5,#4]
        0x080011a4:    03c0        ..      LSLS     r0,r0,#15
        0x080011a6:    d406        ..      BMI      0x80011b6 ; HAL_RCC_OscConfig + 218
        0x080011a8:    6828        (h      LDR      r0,[r5,#0]
        0x080011aa:    0780        ..      LSLS     r0,r0,#30
        0x080011ac:    d514        ..      BPL      0x80011d8 ; HAL_RCC_OscConfig + 252
        0x080011ae:    6920         i      LDR      r0,[r4,#0x10]
        0x080011b0:    2801        .(      CMP      r0,#1
        0x080011b2:    d108        ..      BNE      0x80011c6 ; HAL_RCC_OscConfig + 234
        0x080011b4:    e010        ..      B        0x80011d8 ; HAL_RCC_OscConfig + 252
        0x080011b6:    6920         i      LDR      r0,[r4,#0x10]
        0x080011b8:    b1b0        ..      CBZ      r0,0x80011e8 ; HAL_RCC_OscConfig + 268
        0x080011ba:    f8c69000    ....    STR      r9,[r6,#0]
        0x080011be:    f7fffd4b    ..K.    BL       HAL_GetTick ; 0x8000c58
        0x080011c2:    4607        .F      MOV      r7,r0
        0x080011c4:    e005        ..      B        0x80011d2 ; HAL_RCC_OscConfig + 246
        0x080011c6:    e10a        ..      B        0x80013de ; HAL_RCC_OscConfig + 770
        0x080011c8:    f7fffd46    ..F.    BL       HAL_GetTick ; 0x8000c58
        0x080011cc:    1bc0        ..      SUBS     r0,r0,r7
        0x080011ce:    2802        .(      CMP      r0,#2
        0x080011d0:    d8c4        ..      BHI      0x800115c ; HAL_RCC_OscConfig + 128
        0x080011d2:    6828        (h      LDR      r0,[r5,#0]
        0x080011d4:    0780        ..      LSLS     r0,r0,#30
        0x080011d6:    d5f7        ..      BPL      0x80011c8 ; HAL_RCC_OscConfig + 236
        0x080011d8:    6828        (h      LDR      r0,[r5,#0]
        0x080011da:    6961        ai      LDR      r1,[r4,#0x14]
        0x080011dc:    f02000f8     ...    BIC      r0,r0,#0xf8
        0x080011e0:    ea4000c1    @...    ORR      r0,r0,r1,LSL #3
        0x080011e4:    6028        (`      STR      r0,[r5,#0]
        0x080011e6:    e00d        ..      B        0x8001204 ; HAL_RCC_OscConfig + 296
        0x080011e8:    f8c68000    ....    STR      r8,[r6,#0]
        0x080011ec:    f7fffd34    ..4.    BL       HAL_GetTick ; 0x8000c58
        0x080011f0:    4607        .F      MOV      r7,r0
        0x080011f2:    e004        ..      B        0x80011fe ; HAL_RCC_OscConfig + 290
        0x080011f4:    f7fffd30    ..0.    BL       HAL_GetTick ; 0x8000c58
        0x080011f8:    1bc0        ..      SUBS     r0,r0,r7
        0x080011fa:    2802        .(      CMP      r0,#2
        0x080011fc:    d823        #.      BHI      0x8001246 ; HAL_RCC_OscConfig + 362
        0x080011fe:    6828        (h      LDR      r0,[r5,#0]
        0x08001200:    0780        ..      LSLS     r0,r0,#30
        0x08001202:    d4f7        ..      BMI      0x80011f4 ; HAL_RCC_OscConfig + 280
        0x08001204:    7820         x      LDRB     r0,[r4,#0]
        0x08001206:    0700        ..      LSLS     r0,r0,#28
        0x08001208:    d52c        ,.      BPL      0x8001264 ; HAL_RCC_OscConfig + 392
        0x0800120a:    4879        yH      LDR      r0,[pc,#484] ; [0x80013f0] = 0x42420480
        0x0800120c:    69a1        .i      LDR      r1,[r4,#0x18]
        0x0800120e:    b1d9        ..      CBZ      r1,0x8001248 ; HAL_RCC_OscConfig + 364
        0x08001210:    f8c09000    ....    STR      r9,[r0,#0]
        0x08001214:    f7fffd20    .. .    BL       HAL_GetTick ; 0x8000c58
        0x08001218:    4607        .F      MOV      r7,r0
        0x0800121a:    e004        ..      B        0x8001226 ; HAL_RCC_OscConfig + 330
        0x0800121c:    f7fffd1c    ....    BL       HAL_GetTick ; 0x8000c58
        0x08001220:    1bc0        ..      SUBS     r0,r0,r7
        0x08001222:    2802        .(      CMP      r0,#2
        0x08001224:    d80f        ..      BHI      0x8001246 ; HAL_RCC_OscConfig + 362
        0x08001226:    6a68        hj      LDR      r0,[r5,#0x24]
        0x08001228:    0780        ..      LSLS     r0,r0,#30
        0x0800122a:    d5f7        ..      BPL      0x800121c ; HAL_RCC_OscConfig + 320
        0x0800122c:    4871        qH      LDR      r0,[pc,#452] ; [0x80013f4] = 0x20000028
        0x0800122e:    f44f51fa    O..Q    MOV      r1,#0x1f40
        0x08001232:    6800        .h      LDR      r0,[r0,#0]
        0x08001234:    fbb0f0f1    ....    UDIV     r0,r0,r1
        0x08001238:    9000        ..      STR      r0,[sp,#0]
        0x0800123a:    bf00        ..      NOP      
        0x0800123c:    9800        ..      LDR      r0,[sp,#0]
        0x0800123e:    1e41        A.      SUBS     r1,r0,#1
        0x08001240:    9100        ..      STR      r1,[sp,#0]
        0x08001242:    d2fa        ..      BCS      0x800123a ; HAL_RCC_OscConfig + 350
        0x08001244:    e00e        ..      B        0x8001264 ; HAL_RCC_OscConfig + 392
        0x08001246:    e080        ..      B        0x800134a ; HAL_RCC_OscConfig + 622
        0x08001248:    f8c08000    ....    STR      r8,[r0,#0]
        0x0800124c:    f7fffd04    ....    BL       HAL_GetTick ; 0x8000c58
        0x08001250:    4607        .F      MOV      r7,r0
        0x08001252:    e004        ..      B        0x800125e ; HAL_RCC_OscConfig + 386
        0x08001254:    f7fffd00    ....    BL       HAL_GetTick ; 0x8000c58
        0x08001258:    1bc0        ..      SUBS     r0,r0,r7
        0x0800125a:    2802        .(      CMP      r0,#2
        0x0800125c:    d875        u.      BHI      0x800134a ; HAL_RCC_OscConfig + 622
        0x0800125e:    6a68        hj      LDR      r0,[r5,#0x24]
        0x08001260:    0780        ..      LSLS     r0,r0,#30
        0x08001262:    d4f7        ..      BMI      0x8001254 ; HAL_RCC_OscConfig + 376
        0x08001264:    7820         x      LDRB     r0,[r4,#0]
        0x08001266:    0740        @.      LSLS     r0,r0,#29
        0x08001268:    d560        `.      BPL      0x800132c ; HAL_RCC_OscConfig + 592
        0x0800126a:    69e8        .i      LDR      r0,[r5,#0x1c]
        0x0800126c:    2700        .'      MOVS     r7,#0
        0x0800126e:    00c0        ..      LSLS     r0,r0,#3
        0x08001270:    d408        ..      BMI      0x8001284 ; HAL_RCC_OscConfig + 424
        0x08001272:    69e8        .i      LDR      r0,[r5,#0x1c]
        0x08001274:    f0405080    @..P    ORR      r0,r0,#0x10000000
        0x08001278:    61e8        .a      STR      r0,[r5,#0x1c]
        0x0800127a:    69e8        .i      LDR      r0,[r5,#0x1c]
        0x0800127c:    2701        .'      MOVS     r7,#1
        0x0800127e:    f0005080    ...P    AND      r0,r0,#0x10000000
        0x08001282:    9000        ..      STR      r0,[sp,#0]
        0x08001284:    485c        \H      LDR      r0,[pc,#368] ; [0x80013f8] = 0x40007000
        0x08001286:    6801        .h      LDR      r1,[r0,#0]
        0x08001288:    05c9        ..      LSLS     r1,r1,#23
        0x0800128a:    d413        ..      BMI      0x80012b4 ; HAL_RCC_OscConfig + 472
        0x0800128c:    6801        .h      LDR      r1,[r0,#0]
        0x0800128e:    4683        .F      MOV      r11,r0
        0x08001290:    f4417180    A..q    ORR      r1,r1,#0x100
        0x08001294:    6001        .`      STR      r1,[r0,#0]
        0x08001296:    f7fffcdf    ....    BL       HAL_GetTick ; 0x8000c58
        0x0800129a:    4682        .F      MOV      r10,r0
        0x0800129c:    e006        ..      B        0x80012ac ; HAL_RCC_OscConfig + 464
        0x0800129e:    bf00        ..      NOP      
        0x080012a0:    f7fffcda    ....    BL       HAL_GetTick ; 0x8000c58
        0x080012a4:    eba0000a    ....    SUB      r0,r0,r10
        0x080012a8:    2864        d(      CMP      r0,#0x64
        0x080012aa:    d84e        N.      BHI      0x800134a ; HAL_RCC_OscConfig + 622
        0x080012ac:    f8db0000    ....    LDR      r0,[r11,#0]
        0x080012b0:    05c0        ..      LSLS     r0,r0,#23
        0x080012b2:    d5f5        ..      BPL      0x80012a0 ; HAL_RCC_OscConfig + 452
        0x080012b4:    68e0        .h      LDR      r0,[r4,#0xc]
        0x080012b6:    2801        .(      CMP      r0,#1
        0x080012b8:    d00a        ..      BEQ      0x80012d0 ; HAL_RCC_OscConfig + 500
        0x080012ba:    b108        ..      CBZ      r0,0x80012c0 ; HAL_RCC_OscConfig + 484
        0x080012bc:    2805        .(      CMP      r0,#5
        0x080012be:    d013        ..      BEQ      0x80012e8 ; HAL_RCC_OscConfig + 524
        0x080012c0:    6a28        (j      LDR      r0,[r5,#0x20]
        0x080012c2:    f0200001     ...    BIC      r0,r0,#1
        0x080012c6:    6228        (b      STR      r0,[r5,#0x20]
        0x080012c8:    6a28        (j      LDR      r0,[r5,#0x20]
        0x080012ca:    f0200004     ...    BIC      r0,r0,#4
        0x080012ce:    e002        ..      B        0x80012d6 ; HAL_RCC_OscConfig + 506
        0x080012d0:    6a28        (j      LDR      r0,[r5,#0x20]
        0x080012d2:    f0400001    @...    ORR      r0,r0,#1
        0x080012d6:    6228        (b      STR      r0,[r5,#0x20]
        0x080012d8:    68e0        .h      LDR      r0,[r4,#0xc]
        0x080012da:    f2413b88    A..;    MOV      r11,#0x1388
        0x080012de:    b198        ..      CBZ      r0,0x8001308 ; HAL_RCC_OscConfig + 556
        0x080012e0:    f7fffcba    ....    BL       HAL_GetTick ; 0x8000c58
        0x080012e4:    4682        .F      MOV      r10,r0
        0x080012e6:    e00b        ..      B        0x8001300 ; HAL_RCC_OscConfig + 548
        0x080012e8:    6a28        (j      LDR      r0,[r5,#0x20]
        0x080012ea:    f0400004    @...    ORR      r0,r0,#4
        0x080012ee:    6228        (b      STR      r0,[r5,#0x20]
        0x080012f0:    e7ee        ..      B        0x80012d0 ; HAL_RCC_OscConfig + 500
        0x080012f2:    bf00        ..      NOP      
        0x080012f4:    f7fffcb0    ....    BL       HAL_GetTick ; 0x8000c58
        0x080012f8:    eba0010a    ....    SUB      r1,r0,r10
        0x080012fc:    4559        YE      CMP      r1,r11
        0x080012fe:    d85a        Z.      BHI      0x80013b6 ; HAL_RCC_OscConfig + 730
        0x08001300:    6a28        (j      LDR      r0,[r5,#0x20]
        0x08001302:    0780        ..      LSLS     r0,r0,#30
        0x08001304:    d5f6        ..      BPL      0x80012f4 ; HAL_RCC_OscConfig + 536
        0x08001306:    e00c        ..      B        0x8001322 ; HAL_RCC_OscConfig + 582
        0x08001308:    f7fffca6    ....    BL       HAL_GetTick ; 0x8000c58
        0x0800130c:    4682        .F      MOV      r10,r0
        0x0800130e:    e005        ..      B        0x800131c ; HAL_RCC_OscConfig + 576
        0x08001310:    f7fffca2    ....    BL       HAL_GetTick ; 0x8000c58
        0x08001314:    eba0010a    ....    SUB      r1,r0,r10
        0x08001318:    4559        YE      CMP      r1,r11
        0x0800131a:    d84c        L.      BHI      0x80013b6 ; HAL_RCC_OscConfig + 730
        0x0800131c:    6a28        (j      LDR      r0,[r5,#0x20]
        0x0800131e:    0780        ..      LSLS     r0,r0,#30
        0x08001320:    d4f6        ..      BMI      0x8001310 ; HAL_RCC_OscConfig + 564
        0x08001322:    b11f        ..      CBZ      r7,0x800132c ; HAL_RCC_OscConfig + 592
        0x08001324:    69e8        .i      LDR      r0,[r5,#0x1c]
        0x08001326:    f0205080     ..P    BIC      r0,r0,#0x10000000
        0x0800132a:    61e8        .a      STR      r0,[r5,#0x1c]
        0x0800132c:    69e0        .i      LDR      r0,[r4,#0x1c]
        0x0800132e:    b388        ..      CBZ      r0,0x8001394 ; HAL_RCC_OscConfig + 696
        0x08001330:    6869        ih      LDR      r1,[r5,#4]
        0x08001332:    f3c10181    ....    UBFX     r1,r1,#2,#2
        0x08001336:    2902        .)      CMP      r1,#2
        0x08001338:    d044        D.      BEQ      0x80013c4 ; HAL_RCC_OscConfig + 744
        0x0800133a:    2802        .(      CMP      r0,#2
        0x0800133c:    f8c68060    ..`.    STR      r8,[r6,#0x60]
        0x08001340:    d004        ..      BEQ      0x800134c ; HAL_RCC_OscConfig + 624
        0x08001342:    f7fffc89    ....    BL       HAL_GetTick ; 0x8000c58
        0x08001346:    4604        .F      MOV      r4,r0
        0x08001348:    e038        8.      B        0x80013bc ; HAL_RCC_OscConfig + 736
        0x0800134a:    e034        4.      B        0x80013b6 ; HAL_RCC_OscConfig + 730
        0x0800134c:    f7fffc84    ....    BL       HAL_GetTick ; 0x8000c58
        0x08001350:    4607        .F      MOV      r7,r0
        0x08001352:    e004        ..      B        0x800135e ; HAL_RCC_OscConfig + 642
        0x08001354:    f7fffc80    ....    BL       HAL_GetTick ; 0x8000c58
        0x08001358:    1bc0        ..      SUBS     r0,r0,r7
        0x0800135a:    2802        .(      CMP      r0,#2
        0x0800135c:    d82b        +.      BHI      0x80013b6 ; HAL_RCC_OscConfig + 730
        0x0800135e:    6828        (h      LDR      r0,[r5,#0]
        0x08001360:    0180        ..      LSLS     r0,r0,#6
        0x08001362:    d4f7        ..      BMI      0x8001354 ; HAL_RCC_OscConfig + 632
        0x08001364:    6a20         j      LDR      r0,[r4,#0x20]
        0x08001366:    f5b03f80    ...?    CMP      r0,#0x10000
        0x0800136a:    d105        ..      BNE      0x8001378 ; HAL_RCC_OscConfig + 668
        0x0800136c:    6868        hh      LDR      r0,[r5,#4]
        0x0800136e:    68a1        .h      LDR      r1,[r4,#8]
        0x08001370:    f4203000     ..0    BIC      r0,r0,#0x20000
        0x08001374:    4308        .C      ORRS     r0,r0,r1
        0x08001376:    6068        h`      STR      r0,[r5,#4]
        0x08001378:    e9d40108    ....    LDRD     r0,r1,[r4,#0x20]
        0x0800137c:    4308        .C      ORRS     r0,r0,r1
        0x0800137e:    6869        ih      LDR      r1,[r5,#4]
        0x08001380:    f4211174    !.t.    BIC      r1,r1,#0x3d0000
        0x08001384:    4308        .C      ORRS     r0,r0,r1
        0x08001386:    6068        h`      STR      r0,[r5,#4]
        0x08001388:    f8c69060    ..`.    STR      r9,[r6,#0x60]
        0x0800138c:    f7fffc64    ..d.    BL       HAL_GetTick ; 0x8000c58
        0x08001390:    4604        .F      MOV      r4,r0
        0x08001392:    e006        ..      B        0x80013a2 ; HAL_RCC_OscConfig + 710
        0x08001394:    e025        %.      B        0x80013e2 ; HAL_RCC_OscConfig + 774
        0x08001396:    bf00        ..      NOP      
        0x08001398:    f7fffc5e    ..^.    BL       HAL_GetTick ; 0x8000c58
        0x0800139c:    1b00        ..      SUBS     r0,r0,r4
        0x0800139e:    2802        .(      CMP      r0,#2
        0x080013a0:    d809        ..      BHI      0x80013b6 ; HAL_RCC_OscConfig + 730
        0x080013a2:    6828        (h      LDR      r0,[r5,#0]
        0x080013a4:    0180        ..      LSLS     r0,r0,#6
        0x080013a6:    d5f7        ..      BPL      0x8001398 ; HAL_RCC_OscConfig + 700
        0x080013a8:    e01b        ..      B        0x80013e2 ; HAL_RCC_OscConfig + 774
        0x080013aa:    bf00        ..      NOP      
        0x080013ac:    f7fffc54    ..T.    BL       HAL_GetTick ; 0x8000c58
        0x080013b0:    1b00        ..      SUBS     r0,r0,r4
        0x080013b2:    2802        .(      CMP      r0,#2
        0x080013b4:    d902        ..      BLS      0x80013bc ; HAL_RCC_OscConfig + 736
        0x080013b6:    2003        .       MOVS     r0,#3
        0x080013b8:    e8bd8ff8    ....    POP      {r3-r11,pc}
        0x080013bc:    6828        (h      LDR      r0,[r5,#0]
        0x080013be:    0180        ..      LSLS     r0,r0,#6
        0x080013c0:    d4f4        ..      BMI      0x80013ac ; HAL_RCC_OscConfig + 720
        0x080013c2:    e00e        ..      B        0x80013e2 ; HAL_RCC_OscConfig + 774
        0x080013c4:    2801        .(      CMP      r0,#1
        0x080013c6:    d0f7        ..      BEQ      0x80013b8 ; HAL_RCC_OscConfig + 732
        0x080013c8:    6868        hh      LDR      r0,[r5,#4]
        0x080013ca:    6a22        "j      LDR      r2,[r4,#0x20]
        0x080013cc:    f4003180    ...1    AND      r1,r0,#0x10000
        0x080013d0:    4291        .B      CMP      r1,r2
        0x080013d2:    d104        ..      BNE      0x80013de ; HAL_RCC_OscConfig + 770
        0x080013d4:    6a61        aj      LDR      r1,[r4,#0x24]
        0x080013d6:    f4001070    ..p.    AND      r0,r0,#0x3c0000
        0x080013da:    4288        .B      CMP      r0,r1
        0x080013dc:    d001        ..      BEQ      0x80013e2 ; HAL_RCC_OscConfig + 774
        0x080013de:    2001        .       MOVS     r0,#1
        0x080013e0:    e7ea        ..      B        0x80013b8 ; HAL_RCC_OscConfig + 732
        0x080013e2:    2000        .       MOVS     r0,#0
        0x080013e4:    e7e8        ..      B        0x80013b8 ; HAL_RCC_OscConfig + 732
    $d
        0x080013e6:    0000        ..      DCW    0
        0x080013e8:    40021000    ...@    DCD    1073876992
        0x080013ec:    42420000    ..BB    DCD    1111621632
        0x080013f0:    42420480    ..BB    DCD    1111622784
        0x080013f4:    20000028    (..     DCD    536870952
        0x080013f8:    40007000    .p.@    DCD    1073770496
    $t
    i.HAL_SYSTICK_Config
    HAL_SYSTICK_Config
        0x080013fc:    b510        ..      PUSH     {r4,lr}
        0x080013fe:    1e40        @.      SUBS     r0,r0,#1
        0x08001400:    f1b07f80    ....    CMP      r0,#0x1000000
        0x08001404:    d301        ..      BCC      0x800140a ; HAL_SYSTICK_Config + 14
        0x08001406:    2001        .       MOVS     r0,#1
        0x08001408:    bd10        ..      POP      {r4,pc}
        0x0800140a:    f04f24e0    O..$    MOV      r4,#0xe000e000
        0x0800140e:    6160        `a      STR      r0,[r4,#0x14]
        0x08001410:    210f        .!      MOVS     r1,#0xf
        0x08001412:    1760        `.      ASRS     r0,r4,#29
        0x08001414:    f001f8e4    ....    BL       __NVIC_SetPriority ; 0x80025e0
        0x08001418:    2000        .       MOVS     r0,#0
        0x0800141a:    61a0        .a      STR      r0,[r4,#0x18]
        0x0800141c:    2007        .       MOVS     r0,#7
        0x0800141e:    6120         a      STR      r0,[r4,#0x10]
        0x08001420:    2000        .       MOVS     r0,#0
        0x08001422:    bd10        ..      POP      {r4,pc}
    i.HAL_TIMEx_BreakCallback
    HAL_TIMEx_BreakCallback
        0x08001424:    4770        pG      BX       lr
    i.HAL_TIMEx_CommutCallback
    HAL_TIMEx_CommutCallback
        0x08001426:    4770        pG      BX       lr
    i.HAL_TIMEx_MasterConfigSynchronization
    HAL_TIMEx_MasterConfigSynchronization
        0x08001428:    b570        p.      PUSH     {r4-r6,lr}
        0x0800142a:    f890203c    ..<     LDRB     r2,[r0,#0x3c]
        0x0800142e:    2a01        .*      CMP      r2,#1
        0x08001430:    d026        &.      BEQ      0x8001480 ; HAL_TIMEx_MasterConfigSynchronization + 88
        0x08001432:    2401        .$      MOVS     r4,#1
        0x08001434:    f880403c    ..<@    STRB     r4,[r0,#0x3c]
        0x08001438:    2202        ."      MOVS     r2,#2
        0x0800143a:    f880203d    ..=     STRB     r2,[r0,#0x3d]
        0x0800143e:    6803        .h      LDR      r3,[r0,#0]
        0x08001440:    685a        Zh      LDR      r2,[r3,#4]
        0x08001442:    689d        .h      LDR      r5,[r3,#8]
        0x08001444:    f0220670    ".p.    BIC      r6,r2,#0x70
        0x08001448:    680a        .h      LDR      r2,[r1,#0]
        0x0800144a:    4332        2C      ORRS     r2,r2,r6
        0x0800144c:    605a        Z`      STR      r2,[r3,#4]
        0x0800144e:    4b0d        .K      LDR      r3,[pc,#52] ; [0x8001484] = 0x40012c00
        0x08001450:    6802        .h      LDR      r2,[r0,#0]
        0x08001452:    429a        .B      CMP      r2,r3
        0x08001454:    d008        ..      BEQ      0x8001468 ; HAL_TIMEx_MasterConfigSynchronization + 64
        0x08001456:    f1b24f80    ...O    CMP      r2,#0x40000000
        0x0800145a:    d005        ..      BEQ      0x8001468 ; HAL_TIMEx_MasterConfigSynchronization + 64
        0x0800145c:    4b0a        .K      LDR      r3,[pc,#40] ; [0x8001488] = 0x40000400
        0x0800145e:    429a        .B      CMP      r2,r3
        0x08001460:    d002        ..      BEQ      0x8001468 ; HAL_TIMEx_MasterConfigSynchronization + 64
        0x08001462:    4b0a        .K      LDR      r3,[pc,#40] ; [0x800148c] = 0x40000800
        0x08001464:    429a        .B      CMP      r2,r3
        0x08001466:    d104        ..      BNE      0x8001472 ; HAL_TIMEx_MasterConfigSynchronization + 74
        0x08001468:    6849        Ih      LDR      r1,[r1,#4]
        0x0800146a:    f0250380    %...    BIC      r3,r5,#0x80
        0x0800146e:    4319        .C      ORRS     r1,r1,r3
        0x08001470:    6091        .`      STR      r1,[r2,#8]
        0x08001472:    f880403d    ..=@    STRB     r4,[r0,#0x3d]
        0x08001476:    2100        .!      MOVS     r1,#0
        0x08001478:    f880103c    ..<.    STRB     r1,[r0,#0x3c]
        0x0800147c:    4608        .F      MOV      r0,r1
        0x0800147e:    bd70        p.      POP      {r4-r6,pc}
        0x08001480:    2002        .       MOVS     r0,#2
        0x08001482:    bd70        p.      POP      {r4-r6,pc}
    $d
        0x08001484:    40012c00    .,.@    DCD    1073818624
        0x08001488:    40000400    ...@    DCD    1073742848
        0x0800148c:    40000800    ...@    DCD    1073743872
    $t
    i.HAL_TIM_Base_Init
    HAL_TIM_Base_Init
        0x08001490:    b510        ..      PUSH     {r4,lr}
        0x08001492:    0004        ..      MOVS     r4,r0
        0x08001494:    d003        ..      BEQ      0x800149e ; HAL_TIM_Base_Init + 14
        0x08001496:    f894003d    ..=.    LDRB     r0,[r4,#0x3d]
        0x0800149a:    b110        ..      CBZ      r0,0x80014a2 ; HAL_TIM_Base_Init + 18
        0x0800149c:    e007        ..      B        0x80014ae ; HAL_TIM_Base_Init + 30
        0x0800149e:    2001        .       MOVS     r0,#1
        0x080014a0:    bd10        ..      POP      {r4,pc}
        0x080014a2:    2000        .       MOVS     r0,#0
        0x080014a4:    f884003c    ..<.    STRB     r0,[r4,#0x3c]
        0x080014a8:    4620         F      MOV      r0,r4
        0x080014aa:    f000f81f    ....    BL       HAL_TIM_Base_MspInit ; 0x80014ec
        0x080014ae:    2002        .       MOVS     r0,#2
        0x080014b0:    f884003d    ..=.    STRB     r0,[r4,#0x3d]
        0x080014b4:    1d21        !.      ADDS     r1,r4,#4
        0x080014b6:    6820         h      LDR      r0,[r4,#0]
        0x080014b8:    f000fee2    ....    BL       TIM_Base_SetConfig ; 0x8002280
        0x080014bc:    2001        .       MOVS     r0,#1
        0x080014be:    f8840046    ..F.    STRB     r0,[r4,#0x46]
        0x080014c2:    f884003e    ..>.    STRB     r0,[r4,#0x3e]
        0x080014c6:    f884003f    ..?.    STRB     r0,[r4,#0x3f]
        0x080014ca:    f8840040    ..@.    STRB     r0,[r4,#0x40]
        0x080014ce:    f8840041    ..A.    STRB     r0,[r4,#0x41]
        0x080014d2:    f8840042    ..B.    STRB     r0,[r4,#0x42]
        0x080014d6:    f8840043    ..C.    STRB     r0,[r4,#0x43]
        0x080014da:    f8840044    ..D.    STRB     r0,[r4,#0x44]
        0x080014de:    f8840045    ..E.    STRB     r0,[r4,#0x45]
        0x080014e2:    f884003d    ..=.    STRB     r0,[r4,#0x3d]
        0x080014e6:    2000        .       MOVS     r0,#0
        0x080014e8:    bd10        ..      POP      {r4,pc}
        0x080014ea:    0000        ..      MOVS     r0,r0
    i.HAL_TIM_Base_MspInit
    HAL_TIM_Base_MspInit
        0x080014ec:    b508        ..      PUSH     {r3,lr}
        0x080014ee:    6800        .h      LDR      r0,[r0,#0]
        0x080014f0:    490b        .I      LDR      r1,[pc,#44] ; [0x8001520] = 0x40000400
        0x080014f2:    4288        .B      CMP      r0,r1
        0x080014f4:    d112        ..      BNE      0x800151c ; HAL_TIM_Base_MspInit + 48
        0x080014f6:    480b        .H      LDR      r0,[pc,#44] ; [0x8001524] = 0x40021000
        0x080014f8:    69c1        .i      LDR      r1,[r0,#0x1c]
        0x080014fa:    f0410102    A...    ORR      r1,r1,#2
        0x080014fe:    61c1        .a      STR      r1,[r0,#0x1c]
        0x08001500:    69c0        .i      LDR      r0,[r0,#0x1c]
        0x08001502:    2200        ."      MOVS     r2,#0
        0x08001504:    f0000002    ....    AND      r0,r0,#2
        0x08001508:    9000        ..      STR      r0,[sp,#0]
        0x0800150a:    4611        .F      MOV      r1,r2
        0x0800150c:    201d        .       MOVS     r0,#0x1d
        0x0800150e:    f7fffc0f    ....    BL       HAL_NVIC_SetPriority ; 0x8000d30
        0x08001512:    e8bd4008    ...@    POP      {r3,lr}
        0x08001516:    201d        .       MOVS     r0,#0x1d
        0x08001518:    f7ffbbfc    ....    B        HAL_NVIC_EnableIRQ ; 0x8000d14
        0x0800151c:    bd08        ..      POP      {r3,pc}
    $d
        0x0800151e:    0000        ..      DCW    0
        0x08001520:    40000400    ...@    DCD    1073742848
        0x08001524:    40021000    ...@    DCD    1073876992
    $t
    i.HAL_TIM_Base_Start_IT
    HAL_TIM_Base_Start_IT
        0x08001528:    f890103d    ..=.    LDRB     r1,[r0,#0x3d]
        0x0800152c:    2901        .)      CMP      r1,#1
        0x0800152e:    d001        ..      BEQ      0x8001534 ; HAL_TIM_Base_Start_IT + 12
        0x08001530:    2001        .       MOVS     r0,#1
        0x08001532:    4770        pG      BX       lr
        0x08001534:    2102        .!      MOVS     r1,#2
        0x08001536:    f880103d    ..=.    STRB     r1,[r0,#0x3d]
        0x0800153a:    6801        .h      LDR      r1,[r0,#0]
        0x0800153c:    68ca        .h      LDR      r2,[r1,#0xc]
        0x0800153e:    f0420201    B...    ORR      r2,r2,#1
        0x08001542:    60ca        .`      STR      r2,[r1,#0xc]
        0x08001544:    6800        .h      LDR      r0,[r0,#0]
        0x08001546:    490b        .I      LDR      r1,[pc,#44] ; [0x8001574] = 0x40012c00
        0x08001548:    4288        .B      CMP      r0,r1
        0x0800154a:    d008        ..      BEQ      0x800155e ; HAL_TIM_Base_Start_IT + 54
        0x0800154c:    f1b04f80    ...O    CMP      r0,#0x40000000
        0x08001550:    d005        ..      BEQ      0x800155e ; HAL_TIM_Base_Start_IT + 54
        0x08001552:    4909        .I      LDR      r1,[pc,#36] ; [0x8001578] = 0x40000400
        0x08001554:    4288        .B      CMP      r0,r1
        0x08001556:    d002        ..      BEQ      0x800155e ; HAL_TIM_Base_Start_IT + 54
        0x08001558:    4908        .I      LDR      r1,[pc,#32] ; [0x800157c] = 0x40000800
        0x0800155a:    4288        .B      CMP      r0,r1
        0x0800155c:    d104        ..      BNE      0x8001568 ; HAL_TIM_Base_Start_IT + 64
        0x0800155e:    6881        .h      LDR      r1,[r0,#8]
        0x08001560:    f0010107    ....    AND      r1,r1,#7
        0x08001564:    2906        .)      CMP      r1,#6
        0x08001566:    d003        ..      BEQ      0x8001570 ; HAL_TIM_Base_Start_IT + 72
        0x08001568:    6801        .h      LDR      r1,[r0,#0]
        0x0800156a:    f0410101    A...    ORR      r1,r1,#1
        0x0800156e:    6001        .`      STR      r1,[r0,#0]
        0x08001570:    2000        .       MOVS     r0,#0
        0x08001572:    4770        pG      BX       lr
    $d
        0x08001574:    40012c00    .,.@    DCD    1073818624
        0x08001578:    40000400    ...@    DCD    1073742848
        0x0800157c:    40000800    ...@    DCD    1073743872
    $t
    i.HAL_TIM_ConfigClockSource
    HAL_TIM_ConfigClockSource
        0x08001580:    b570        p.      PUSH     {r4-r6,lr}
        0x08001582:    4604        .F      MOV      r4,r0
        0x08001584:    f890003c    ..<.    LDRB     r0,[r0,#0x3c]
        0x08001588:    2500        .%      MOVS     r5,#0
        0x0800158a:    2801        .(      CMP      r0,#1
        0x0800158c:    d017        ..      BEQ      0x80015be ; HAL_TIM_ConfigClockSource + 62
        0x0800158e:    2601        .&      MOVS     r6,#1
        0x08001590:    f884603c    ..<`    STRB     r6,[r4,#0x3c]
        0x08001594:    2002        .       MOVS     r0,#2
        0x08001596:    f884003d    ..=.    STRB     r0,[r4,#0x3d]
        0x0800159a:    6820         h      LDR      r0,[r4,#0]
        0x0800159c:    6882        .h      LDR      r2,[r0,#8]
        0x0800159e:    f0220277    ".w.    BIC      r2,r2,#0x77
        0x080015a2:    f422427f    "..B    BIC      r2,r2,#0xff00
        0x080015a6:    6082        .`      STR      r2,[r0,#8]
        0x080015a8:    6808        .h      LDR      r0,[r1,#0]
        0x080015aa:    2850        P(      CMP      r0,#0x50
        0x080015ac:    d038        8.      BEQ      0x8001620 ; HAL_TIM_ConfigClockSource + 160
        0x080015ae:    dc0d        ..      BGT      0x80015cc ; HAL_TIM_ConfigClockSource + 76
        0x080015b0:    2820         (      CMP      r0,#0x20
        0x080015b2:    d04f        O.      BEQ      0x8001654 ; HAL_TIM_ConfigClockSource + 212
        0x080015b4:    dc05        ..      BGT      0x80015c2 ; HAL_TIM_ConfigClockSource + 66
        0x080015b6:    b390        ..      CBZ      r0,0x800161e ; HAL_TIM_ConfigClockSource + 158
        0x080015b8:    2810        .(      CMP      r0,#0x10
        0x080015ba:    d111        ..      BNE      0x80015e0 ; HAL_TIM_ConfigClockSource + 96
        0x080015bc:    e04a        J.      B        0x8001654 ; HAL_TIM_ConfigClockSource + 212
        0x080015be:    2002        .       MOVS     r0,#2
        0x080015c0:    bd70        p.      POP      {r4-r6,pc}
        0x080015c2:    2830        0(      CMP      r0,#0x30
        0x080015c4:    d046        F.      BEQ      0x8001654 ; HAL_TIM_ConfigClockSource + 212
        0x080015c6:    2840        @(      CMP      r0,#0x40
        0x080015c8:    d10a        ..      BNE      0x80015e0 ; HAL_TIM_ConfigClockSource + 96
        0x080015ca:    e03b        ;.      B        0x8001644 ; HAL_TIM_ConfigClockSource + 196
        0x080015cc:    2860        `(      CMP      r0,#0x60
        0x080015ce:    d02f        /.      BEQ      0x8001630 ; HAL_TIM_ConfigClockSource + 176
        0x080015d0:    2870        p(      CMP      r0,#0x70
        0x080015d2:    d00d        ..      BEQ      0x80015f0 ; HAL_TIM_ConfigClockSource + 112
        0x080015d4:    f5b05f80    ..._    CMP      r0,#0x1000
        0x080015d8:    d003        ..      BEQ      0x80015e2 ; HAL_TIM_ConfigClockSource + 98
        0x080015da:    f5b05f00    ..._    CMP      r0,#0x2000
        0x080015de:    d012        ..      BEQ      0x8001606 ; HAL_TIM_ConfigClockSource + 134
        0x080015e0:    2501        .%      MOVS     r5,#1
        0x080015e2:    f884603d    ..=`    STRB     r6,[r4,#0x3d]
        0x080015e6:    2000        .       MOVS     r0,#0
        0x080015e8:    f884003c    ..<.    STRB     r0,[r4,#0x3c]
        0x080015ec:    4628        (F      MOV      r0,r5
        0x080015ee:    bd70        p.      POP      {r4-r6,pc}
        0x080015f0:    68cb        .h      LDR      r3,[r1,#0xc]
        0x080015f2:    e9d12101    ...!    LDRD     r2,r1,[r1,#4]
        0x080015f6:    6820         h      LDR      r0,[r4,#0]
        0x080015f8:    f000fe7e    ..~.    BL       TIM_ETR_SetConfig ; 0x80022f8
        0x080015fc:    6820         h      LDR      r0,[r4,#0]
        0x080015fe:    6881        .h      LDR      r1,[r0,#8]
        0x08001600:    f0410177    A.w.    ORR      r1,r1,#0x77
        0x08001604:    e009        ..      B        0x800161a ; HAL_TIM_ConfigClockSource + 154
        0x08001606:    68cb        .h      LDR      r3,[r1,#0xc]
        0x08001608:    e9d12101    ...!    LDRD     r2,r1,[r1,#4]
        0x0800160c:    6820         h      LDR      r0,[r4,#0]
        0x0800160e:    f000fe73    ..s.    BL       TIM_ETR_SetConfig ; 0x80022f8
        0x08001612:    6820         h      LDR      r0,[r4,#0]
        0x08001614:    6881        .h      LDR      r1,[r0,#8]
        0x08001616:    f4414180    A..A    ORR      r1,r1,#0x4000
        0x0800161a:    6081        .`      STR      r1,[r0,#8]
        0x0800161c:    e7e1        ..      B        0x80015e2 ; HAL_TIM_ConfigClockSource + 98
        0x0800161e:    e019        ..      B        0x8001654 ; HAL_TIM_ConfigClockSource + 212
        0x08001620:    68ca        .h      LDR      r2,[r1,#0xc]
        0x08001622:    6849        Ih      LDR      r1,[r1,#4]
        0x08001624:    6820         h      LDR      r0,[r4,#0]
        0x08001626:    f000fe79    ..y.    BL       TIM_TI1_ConfigInputStage ; 0x800231c
        0x0800162a:    2150        P!      MOVS     r1,#0x50
        0x0800162c:    6820         h      LDR      r0,[r4,#0]
        0x0800162e:    e006        ..      B        0x800163e ; HAL_TIM_ConfigClockSource + 190
        0x08001630:    68ca        .h      LDR      r2,[r1,#0xc]
        0x08001632:    6849        Ih      LDR      r1,[r1,#4]
        0x08001634:    6820         h      LDR      r0,[r4,#0]
        0x08001636:    f000fe82    ....    BL       TIM_TI2_ConfigInputStage ; 0x800233e
        0x0800163a:    2160        `!      MOVS     r1,#0x60
        0x0800163c:    6820         h      LDR      r0,[r4,#0]
        0x0800163e:    f000fe65    ..e.    BL       TIM_ITRx_SetConfig ; 0x800230c
        0x08001642:    e7ce        ..      B        0x80015e2 ; HAL_TIM_ConfigClockSource + 98
        0x08001644:    68ca        .h      LDR      r2,[r1,#0xc]
        0x08001646:    6849        Ih      LDR      r1,[r1,#4]
        0x08001648:    6820         h      LDR      r0,[r4,#0]
        0x0800164a:    f000fe67    ..g.    BL       TIM_TI1_ConfigInputStage ; 0x800231c
        0x0800164e:    2140        @!      MOVS     r1,#0x40
        0x08001650:    6820         h      LDR      r0,[r4,#0]
        0x08001652:    e7f4        ..      B        0x800163e ; HAL_TIM_ConfigClockSource + 190
        0x08001654:    6822        "h      LDR      r2,[r4,#0]
        0x08001656:    4601        .F      MOV      r1,r0
        0x08001658:    4610        .F      MOV      r0,r2
        0x0800165a:    e7f0        ..      B        0x800163e ; HAL_TIM_ConfigClockSource + 190
    i.HAL_TIM_IC_CaptureCallback
    HAL_TIM_IC_CaptureCallback
        0x0800165c:    4770        pG      BX       lr
    i.HAL_TIM_IRQHandler
    HAL_TIM_IRQHandler
        0x0800165e:    e92d41f0    -..A    PUSH     {r4-r8,lr}
        0x08001662:    4604        .F      MOV      r4,r0
        0x08001664:    6800        .h      LDR      r0,[r0,#0]
        0x08001666:    68c6        .h      LDR      r6,[r0,#0xc]
        0x08001668:    6905        .i      LDR      r5,[r0,#0x10]
        0x0800166a:    f04f0700    O...    MOV      r7,#0
        0x0800166e:    07a9        ..      LSLS     r1,r5,#30
        0x08001670:    d513        ..      BPL      0x800169a ; HAL_TIM_IRQHandler + 60
        0x08001672:    07b1        ..      LSLS     r1,r6,#30
        0x08001674:    d511        ..      BPL      0x800169a ; HAL_TIM_IRQHandler + 60
        0x08001676:    1ef9        ..      SUBS     r1,r7,#3
        0x08001678:    6101        .a      STR      r1,[r0,#0x10]
        0x0800167a:    2001        .       MOVS     r0,#1
        0x0800167c:    7720         w      STRB     r0,[r4,#0x1c]
        0x0800167e:    6820         h      LDR      r0,[r4,#0]
        0x08001680:    6980        .i      LDR      r0,[r0,#0x18]
        0x08001682:    0780        ..      LSLS     r0,r0,#30
        0x08001684:    4620         F      MOV      r0,r4
        0x08001686:    d002        ..      BEQ      0x800168e ; HAL_TIM_IRQHandler + 48
        0x08001688:    f7ffffe8    ....    BL       HAL_TIM_IC_CaptureCallback ; 0x800165c
        0x0800168c:    e004        ..      B        0x8001698 ; HAL_TIM_IRQHandler + 58
        0x0800168e:    f000f87e    ..~.    BL       HAL_TIM_OC_DelayElapsedCallback ; 0x800178e
        0x08001692:    4620         F      MOV      r0,r4
        0x08001694:    f000f87c    ..|.    BL       HAL_TIM_PWM_PulseFinishedCallback ; 0x8001790
        0x08001698:    7727        'w      STRB     r7,[r4,#0x1c]
        0x0800169a:    0768        h.      LSLS     r0,r5,#29
        0x0800169c:    d516        ..      BPL      0x80016cc ; HAL_TIM_IRQHandler + 110
        0x0800169e:    0770        p.      LSLS     r0,r6,#29
        0x080016a0:    d514        ..      BPL      0x80016cc ; HAL_TIM_IRQHandler + 110
        0x080016a2:    6821        !h      LDR      r1,[r4,#0]
        0x080016a4:    f06f0004    o...    MVN      r0,#4
        0x080016a8:    6108        .a      STR      r0,[r1,#0x10]
        0x080016aa:    2002        .       MOVS     r0,#2
        0x080016ac:    7720         w      STRB     r0,[r4,#0x1c]
        0x080016ae:    6820         h      LDR      r0,[r4,#0]
        0x080016b0:    6980        .i      LDR      r0,[r0,#0x18]
        0x080016b2:    f4107f40    ..@.    TST      r0,#0x300
        0x080016b6:    4620         F      MOV      r0,r4
        0x080016b8:    d002        ..      BEQ      0x80016c0 ; HAL_TIM_IRQHandler + 98
        0x080016ba:    f7ffffcf    ....    BL       HAL_TIM_IC_CaptureCallback ; 0x800165c
        0x080016be:    e004        ..      B        0x80016ca ; HAL_TIM_IRQHandler + 108
        0x080016c0:    f000f865    ..e.    BL       HAL_TIM_OC_DelayElapsedCallback ; 0x800178e
        0x080016c4:    4620         F      MOV      r0,r4
        0x080016c6:    f000f863    ..c.    BL       HAL_TIM_PWM_PulseFinishedCallback ; 0x8001790
        0x080016ca:    7727        'w      STRB     r7,[r4,#0x1c]
        0x080016cc:    0728        (.      LSLS     r0,r5,#28
        0x080016ce:    d515        ..      BPL      0x80016fc ; HAL_TIM_IRQHandler + 158
        0x080016d0:    0730        0.      LSLS     r0,r6,#28
        0x080016d2:    d513        ..      BPL      0x80016fc ; HAL_TIM_IRQHandler + 158
        0x080016d4:    6821        !h      LDR      r1,[r4,#0]
        0x080016d6:    f06f0008    o...    MVN      r0,#8
        0x080016da:    6108        .a      STR      r0,[r1,#0x10]
        0x080016dc:    2004        .       MOVS     r0,#4
        0x080016de:    7720         w      STRB     r0,[r4,#0x1c]
        0x080016e0:    6820         h      LDR      r0,[r4,#0]
        0x080016e2:    69c0        .i      LDR      r0,[r0,#0x1c]
        0x080016e4:    0780        ..      LSLS     r0,r0,#30
        0x080016e6:    4620         F      MOV      r0,r4
        0x080016e8:    d002        ..      BEQ      0x80016f0 ; HAL_TIM_IRQHandler + 146
        0x080016ea:    f7ffffb7    ....    BL       HAL_TIM_IC_CaptureCallback ; 0x800165c
        0x080016ee:    e004        ..      B        0x80016fa ; HAL_TIM_IRQHandler + 156
        0x080016f0:    f000f84d    ..M.    BL       HAL_TIM_OC_DelayElapsedCallback ; 0x800178e
        0x080016f4:    4620         F      MOV      r0,r4
        0x080016f6:    f000f84b    ..K.    BL       HAL_TIM_PWM_PulseFinishedCallback ; 0x8001790
        0x080016fa:    7727        'w      STRB     r7,[r4,#0x1c]
        0x080016fc:    06e8        ..      LSLS     r0,r5,#27
        0x080016fe:    d516        ..      BPL      0x800172e ; HAL_TIM_IRQHandler + 208
        0x08001700:    06f0        ..      LSLS     r0,r6,#27
        0x08001702:    d514        ..      BPL      0x800172e ; HAL_TIM_IRQHandler + 208
        0x08001704:    6821        !h      LDR      r1,[r4,#0]
        0x08001706:    f06f0010    o...    MVN      r0,#0x10
        0x0800170a:    6108        .a      STR      r0,[r1,#0x10]
        0x0800170c:    2008        .       MOVS     r0,#8
        0x0800170e:    7720         w      STRB     r0,[r4,#0x1c]
        0x08001710:    6820         h      LDR      r0,[r4,#0]
        0x08001712:    69c0        .i      LDR      r0,[r0,#0x1c]
        0x08001714:    f4107f40    ..@.    TST      r0,#0x300
        0x08001718:    4620         F      MOV      r0,r4
        0x0800171a:    d002        ..      BEQ      0x8001722 ; HAL_TIM_IRQHandler + 196
        0x0800171c:    f7ffff9e    ....    BL       HAL_TIM_IC_CaptureCallback ; 0x800165c
        0x08001720:    e004        ..      B        0x800172c ; HAL_TIM_IRQHandler + 206
        0x08001722:    f000f834    ..4.    BL       HAL_TIM_OC_DelayElapsedCallback ; 0x800178e
        0x08001726:    4620         F      MOV      r0,r4
        0x08001728:    f000f832    ..2.    BL       HAL_TIM_PWM_PulseFinishedCallback ; 0x8001790
        0x0800172c:    7727        'w      STRB     r7,[r4,#0x1c]
        0x0800172e:    07e8        ..      LSLS     r0,r5,#31
        0x08001730:    d008        ..      BEQ      0x8001744 ; HAL_TIM_IRQHandler + 230
        0x08001732:    07f0        ..      LSLS     r0,r6,#31
        0x08001734:    d006        ..      BEQ      0x8001744 ; HAL_TIM_IRQHandler + 230
        0x08001736:    6821        !h      LDR      r1,[r4,#0]
        0x08001738:    f06f0001    o...    MVN      r0,#1
        0x0800173c:    6108        .a      STR      r0,[r1,#0x10]
        0x0800173e:    4620         F      MOV      r0,r4
        0x08001740:    f000f828    ..(.    BL       HAL_TIM_PeriodElapsedCallback ; 0x8001794
        0x08001744:    0628        (.      LSLS     r0,r5,#24
        0x08001746:    d508        ..      BPL      0x800175a ; HAL_TIM_IRQHandler + 252
        0x08001748:    0630        0.      LSLS     r0,r6,#24
        0x0800174a:    d506        ..      BPL      0x800175a ; HAL_TIM_IRQHandler + 252
        0x0800174c:    6821        !h      LDR      r1,[r4,#0]
        0x0800174e:    f06f0080    o...    MVN      r0,#0x80
        0x08001752:    6108        .a      STR      r0,[r1,#0x10]
        0x08001754:    4620         F      MOV      r0,r4
        0x08001756:    f7fffe65    ..e.    BL       HAL_TIMEx_BreakCallback ; 0x8001424
        0x0800175a:    0668        h.      LSLS     r0,r5,#25
        0x0800175c:    d508        ..      BPL      0x8001770 ; HAL_TIM_IRQHandler + 274
        0x0800175e:    0670        p.      LSLS     r0,r6,#25
        0x08001760:    d506        ..      BPL      0x8001770 ; HAL_TIM_IRQHandler + 274
        0x08001762:    6821        !h      LDR      r1,[r4,#0]
        0x08001764:    f06f0040    o.@.    MVN      r0,#0x40
        0x08001768:    6108        .a      STR      r0,[r1,#0x10]
        0x0800176a:    4620         F      MOV      r0,r4
        0x0800176c:    f000f828    ..(.    BL       HAL_TIM_TriggerCallback ; 0x80017c0
        0x08001770:    06a8        ..      LSLS     r0,r5,#26
        0x08001772:    d50a        ..      BPL      0x800178a ; HAL_TIM_IRQHandler + 300
        0x08001774:    06b0        ..      LSLS     r0,r6,#26
        0x08001776:    d508        ..      BPL      0x800178a ; HAL_TIM_IRQHandler + 300
        0x08001778:    6821        !h      LDR      r1,[r4,#0]
        0x0800177a:    f06f0020    o. .    MVN      r0,#0x20
        0x0800177e:    6108        .a      STR      r0,[r1,#0x10]
        0x08001780:    4620         F      MOV      r0,r4
        0x08001782:    e8bd41f0    ...A    POP      {r4-r8,lr}
        0x08001786:    f7ffbe4e    ..N.    B.W      HAL_TIMEx_CommutCallback ; 0x8001426
        0x0800178a:    e8bd81f0    ....    POP      {r4-r8,pc}
    i.HAL_TIM_OC_DelayElapsedCallback
    HAL_TIM_OC_DelayElapsedCallback
        0x0800178e:    4770        pG      BX       lr
    i.HAL_TIM_PWM_PulseFinishedCallback
    HAL_TIM_PWM_PulseFinishedCallback
        0x08001790:    4770        pG      BX       lr
        0x08001792:    0000        ..      MOVS     r0,r0
    i.HAL_TIM_PeriodElapsedCallback
    HAL_TIM_PeriodElapsedCallback
        0x08001794:    4907        .I      LDR      r1,[pc,#28] ; [0x80017b4] = 0x200003b8
        0x08001796:    4288        .B      CMP      r0,r1
        0x08001798:    d10b        ..      BNE      0x80017b2 ; HAL_TIM_PeriodElapsedCallback + 30
        0x0800179a:    4907        .I      LDR      r1,[pc,#28] ; [0x80017b8] = 0x20000018
        0x0800179c:    4a07        .J      LDR      r2,[pc,#28] ; [0x80017bc] = 0x2000000c
        0x0800179e:    6808        .h      LDR      r0,[r1,#0]
        0x080017a0:    1c40        @.      ADDS     r0,r0,#1
        0x080017a2:    6008        .`      STR      r0,[r1,#0]
        0x080017a4:    8812        ..      LDRH     r2,[r2,#0]
        0x080017a6:    4290        .B      CMP      r0,r2
        0x080017a8:    db03        ..      BLT      0x80017b2 ; HAL_TIM_PeriodElapsedCallback + 30
        0x080017aa:    2000        .       MOVS     r0,#0
        0x080017ac:    6008        .`      STR      r0,[r1,#0]
        0x080017ae:    f001b975    ..u.    B.W      get_CCD ; 0x8002a9c
        0x080017b2:    4770        pG      BX       lr
    $d
        0x080017b4:    200003b8    ...     DCD    536871864
        0x080017b8:    20000018    ...     DCD    536870936
        0x080017bc:    2000000c    ...     DCD    536870924
    $t
    i.HAL_TIM_TriggerCallback
    HAL_TIM_TriggerCallback
        0x080017c0:    4770        pG      BX       lr
    i.HAL_UARTEx_RxEventCallback
    HAL_UARTEx_RxEventCallback
        0x080017c2:    4770        pG      BX       lr
    i.HAL_UART_ErrorCallback
    HAL_UART_ErrorCallback
        0x080017c4:    4770        pG      BX       lr
        0x080017c6:    0000        ..      MOVS     r0,r0
    i.HAL_UART_IRQHandler
    HAL_UART_IRQHandler
        0x080017c8:    b5f8        ..      PUSH     {r3-r7,lr}
        0x080017ca:    6801        .h      LDR      r1,[r0,#0]
        0x080017cc:    4604        .F      MOV      r4,r0
        0x080017ce:    6808        .h      LDR      r0,[r1,#0]
        0x080017d0:    68ca        .h      LDR      r2,[r1,#0xc]
        0x080017d2:    694b        Ki      LDR      r3,[r1,#0x14]
        0x080017d4:    f0100f0f    ....    TST      r0,#0xf
        0x080017d8:    f04f0500    O...    MOV      r5,#0
        0x080017dc:    d059        Y.      BEQ      0x8001892 ; HAL_UART_IRQHandler + 202
        0x080017de:    f0030601    ....    AND      r6,r3,#1
        0x080017e2:    f4027790    ...w    AND      r7,r2,#0x120
        0x080017e6:    4337        7C      ORRS     r7,r7,r6
        0x080017e8:    d065        e.      BEQ      0x80018b6 ; HAL_UART_IRQHandler + 238
        0x080017ea:    07c1        ..      LSLS     r1,r0,#31
        0x080017ec:    d005        ..      BEQ      0x80017fa ; HAL_UART_IRQHandler + 50
        0x080017ee:    05d1        ..      LSLS     r1,r2,#23
        0x080017f0:    d503        ..      BPL      0x80017fa ; HAL_UART_IRQHandler + 50
        0x080017f2:    6c61        al      LDR      r1,[r4,#0x44]
        0x080017f4:    f0410101    A...    ORR      r1,r1,#1
        0x080017f8:    6461        ad      STR      r1,[r4,#0x44]
        0x080017fa:    0741        A.      LSLS     r1,r0,#29
        0x080017fc:    d505        ..      BPL      0x800180a ; HAL_UART_IRQHandler + 66
        0x080017fe:    07d9        ..      LSLS     r1,r3,#31
        0x08001800:    d003        ..      BEQ      0x800180a ; HAL_UART_IRQHandler + 66
        0x08001802:    6c61        al      LDR      r1,[r4,#0x44]
        0x08001804:    f0410102    A...    ORR      r1,r1,#2
        0x08001808:    6461        ad      STR      r1,[r4,#0x44]
        0x0800180a:    0781        ..      LSLS     r1,r0,#30
        0x0800180c:    d505        ..      BPL      0x800181a ; HAL_UART_IRQHandler + 82
        0x0800180e:    07d9        ..      LSLS     r1,r3,#31
        0x08001810:    d003        ..      BEQ      0x800181a ; HAL_UART_IRQHandler + 82
        0x08001812:    6c61        al      LDR      r1,[r4,#0x44]
        0x08001814:    f0410104    A...    ORR      r1,r1,#4
        0x08001818:    6461        ad      STR      r1,[r4,#0x44]
        0x0800181a:    0701        ..      LSLS     r1,r0,#28
        0x0800181c:    d507        ..      BPL      0x800182e ; HAL_UART_IRQHandler + 102
        0x0800181e:    f0020120    .. .    AND      r1,r2,#0x20
        0x08001822:    4331        1C      ORRS     r1,r1,r6
        0x08001824:    d003        ..      BEQ      0x800182e ; HAL_UART_IRQHandler + 102
        0x08001826:    6c61        al      LDR      r1,[r4,#0x44]
        0x08001828:    f0410108    A...    ORR      r1,r1,#8
        0x0800182c:    6461        ad      STR      r1,[r4,#0x44]
        0x0800182e:    6c61        al      LDR      r1,[r4,#0x44]
        0x08001830:    2900        .)      CMP      r1,#0
        0x08001832:    d03a        :.      BEQ      0x80018aa ; HAL_UART_IRQHandler + 226
        0x08001834:    0680        ..      LSLS     r0,r0,#26
        0x08001836:    d504        ..      BPL      0x8001842 ; HAL_UART_IRQHandler + 122
        0x08001838:    0690        ..      LSLS     r0,r2,#26
        0x0800183a:    d502        ..      BPL      0x8001842 ; HAL_UART_IRQHandler + 122
        0x0800183c:    4620         F      MOV      r0,r4
        0x0800183e:    f000fdbf    ....    BL       UART_Receive_IT ; 0x80023c0
        0x08001842:    6820         h      LDR      r0,[r4,#0]
        0x08001844:    6940        @i      LDR      r0,[r0,#0x14]
        0x08001846:    6c61        al      LDR      r1,[r4,#0x44]
        0x08001848:    f3c01080    ....    UBFX     r0,r0,#6,#1
        0x0800184c:    0709        ..      LSLS     r1,r1,#28
        0x0800184e:    d400        ..      BMI      0x8001852 ; HAL_UART_IRQHandler + 138
        0x08001850:    b360        `.      CBZ      r0,0x80018ac ; HAL_UART_IRQHandler + 228
        0x08001852:    4620         F      MOV      r0,r4
        0x08001854:    f000fd8d    ....    BL       UART_EndRxTransfer ; 0x8002372
        0x08001858:    6820         h      LDR      r0,[r4,#0]
        0x0800185a:    6940        @i      LDR      r0,[r0,#0x14]
        0x0800185c:    0640        @.      LSLS     r0,r0,#25
        0x0800185e:    d521        !.      BPL      0x80018a4 ; HAL_UART_IRQHandler + 220
        0x08001860:    6820         h      LDR      r0,[r4,#0]
        0x08001862:    3014        .0      ADDS     r0,r0,#0x14
        0x08001864:    e8501f00    P...    LDREX    r1,[r0]
        0x08001868:    f0210140    !.@.    BIC      r1,r1,#0x40
        0x0800186c:    e8401200    @...    STREX    r2,r1,[r0]
        0x08001870:    2a00        .*      CMP      r2,#0
        0x08001872:    d1f5        ..      BNE      0x8001860 ; HAL_UART_IRQHandler + 152
        0x08001874:    6be0        .k      LDR      r0,[r4,#0x3c]
        0x08001876:    b1a8        ..      CBZ      r0,0x80018a4 ; HAL_UART_IRQHandler + 220
        0x08001878:    496d        mI      LDR      r1,[pc,#436] ; [0x8001a30] = 0x8002363
        0x0800187a:    6341        Ac      STR      r1,[r0,#0x34]
        0x0800187c:    6be0        .k      LDR      r0,[r4,#0x3c]
        0x0800187e:    f7fff8a9    ....    BL       HAL_DMA_Abort_IT ; 0x80009d4
        0x08001882:    2800        .(      CMP      r0,#0
        0x08001884:    d011        ..      BEQ      0x80018aa ; HAL_UART_IRQHandler + 226
        0x08001886:    6be0        .k      LDR      r0,[r4,#0x3c]
        0x08001888:    6b41        Ak      LDR      r1,[r0,#0x34]
        0x0800188a:    b001        ..      ADD      sp,sp,#4
        0x0800188c:    e8bd40f0    ...@    POP      {r4-r7,lr}
        0x08001890:    4708        .G      BX       r1
        0x08001892:    0683        ..      LSLS     r3,r0,#26
        0x08001894:    d50f        ..      BPL      0x80018b6 ; HAL_UART_IRQHandler + 238
        0x08001896:    0693        ..      LSLS     r3,r2,#26
        0x08001898:    d50d        ..      BPL      0x80018b6 ; HAL_UART_IRQHandler + 238
        0x0800189a:    4620         F      MOV      r0,r4
        0x0800189c:    e8bd40f8    ...@    POP      {r3-r7,lr}
        0x080018a0:    f000bd8e    ....    B.W      UART_Receive_IT ; 0x80023c0
        0x080018a4:    4620         F      MOV      r0,r4
        0x080018a6:    f7ffff8d    ....    BL       HAL_UART_ErrorCallback ; 0x80017c4
        0x080018aa:    bdf8        ..      POP      {r3-r7,pc}
        0x080018ac:    4620         F      MOV      r0,r4
        0x080018ae:    f7ffff89    ....    BL       HAL_UART_ErrorCallback ; 0x80017c4
        0x080018b2:    6465        ed      STR      r5,[r4,#0x44]
        0x080018b4:    bdf8        ..      POP      {r3-r7,pc}
        0x080018b6:    6b26        &k      LDR      r6,[r4,#0x30]
        0x080018b8:    2320         #      MOVS     r3,#0x20
        0x080018ba:    2e01        ..      CMP      r6,#1
        0x080018bc:    d17c        |.      BNE      0x80019b8 ; HAL_UART_IRQHandler + 496
        0x080018be:    06c6        ..      LSLS     r6,r0,#27
        0x080018c0:    d57a        z.      BPL      0x80019b8 ; HAL_UART_IRQHandler + 496
        0x080018c2:    06d6        ..      LSLS     r6,r2,#27
        0x080018c4:    d578        x.      BPL      0x80019b8 ; HAL_UART_IRQHandler + 496
        0x080018c6:    6808        .h      LDR      r0,[r1,#0]
        0x080018c8:    6848        Hh      LDR      r0,[r1,#4]
        0x080018ca:    9000        ..      STR      r0,[sp,#0]
        0x080018cc:    6948        Hi      LDR      r0,[r1,#0x14]
        0x080018ce:    f04f0602    O...    MOV      r6,#2
        0x080018d2:    0640        @.      LSLS     r0,r0,#25
        0x080018d4:    d540        @.      BPL      0x8001958 ; HAL_UART_IRQHandler + 400
        0x080018d6:    6be1        .k      LDR      r1,[r4,#0x3c]
        0x080018d8:    6808        .h      LDR      r0,[r1,#0]
        0x080018da:    6840        @h      LDR      r0,[r0,#4]
        0x080018dc:    0400        ..      LSLS     r0,r0,#16
        0x080018de:    0c00        ..      LSRS     r0,r0,#16
        0x080018e0:    d0e8        ..      BEQ      0x80018b4 ; HAL_UART_IRQHandler + 236
        0x080018e2:    8da2        ..      LDRH     r2,[r4,#0x2c]
        0x080018e4:    4282        .B      CMP      r2,r0
        0x080018e6:    d9e5        ..      BLS      0x80018b4 ; HAL_UART_IRQHandler + 236
        0x080018e8:    85e0        ..      STRH     r0,[r4,#0x2e]
        0x080018ea:    6988        .i      LDR      r0,[r1,#0x18]
        0x080018ec:    2820         (      CMP      r0,#0x20
        0x080018ee:    d02d        -.      BEQ      0x800194c ; HAL_UART_IRQHandler + 388
        0x080018f0:    6820         h      LDR      r0,[r4,#0]
        0x080018f2:    300c        .0      ADDS     r0,r0,#0xc
        0x080018f4:    e8501f00    P...    LDREX    r1,[r0]
        0x080018f8:    f4217180    !..q    BIC      r1,r1,#0x100
        0x080018fc:    e8401200    @...    STREX    r2,r1,[r0]
        0x08001900:    2a00        .*      CMP      r2,#0
        0x08001902:    d1f5        ..      BNE      0x80018f0 ; HAL_UART_IRQHandler + 296
        0x08001904:    6820         h      LDR      r0,[r4,#0]
        0x08001906:    3014        .0      ADDS     r0,r0,#0x14
        0x08001908:    e8501f00    P...    LDREX    r1,[r0]
        0x0800190c:    f0210101    !...    BIC      r1,r1,#1
        0x08001910:    e8401200    @...    STREX    r2,r1,[r0]
        0x08001914:    2a00        .*      CMP      r2,#0
        0x08001916:    d1f5        ..      BNE      0x8001904 ; HAL_UART_IRQHandler + 316
        0x08001918:    6820         h      LDR      r0,[r4,#0]
        0x0800191a:    3014        .0      ADDS     r0,r0,#0x14
        0x0800191c:    e8501f00    P...    LDREX    r1,[r0]
        0x08001920:    f0210140    !.@.    BIC      r1,r1,#0x40
        0x08001924:    e8401200    @...    STREX    r2,r1,[r0]
        0x08001928:    2a00        .*      CMP      r2,#0
        0x0800192a:    d1f5        ..      BNE      0x8001918 ; HAL_UART_IRQHandler + 336
        0x0800192c:    f8843042    ..B0    STRB     r3,[r4,#0x42]
        0x08001930:    6325        %c      STR      r5,[r4,#0x30]
        0x08001932:    6820         h      LDR      r0,[r4,#0]
        0x08001934:    300c        .0      ADDS     r0,r0,#0xc
        0x08001936:    e8501f00    P...    LDREX    r1,[r0]
        0x0800193a:    f0210110    !...    BIC      r1,r1,#0x10
        0x0800193e:    e8401200    @...    STREX    r2,r1,[r0]
        0x08001942:    2a00        .*      CMP      r2,#0
        0x08001944:    d1f5        ..      BNE      0x8001932 ; HAL_UART_IRQHandler + 362
        0x08001946:    6be0        .k      LDR      r0,[r4,#0x3c]
        0x08001948:    f7fff820    .. .    BL       HAL_DMA_Abort ; 0x800098c
        0x0800194c:    6366        fc      STR      r6,[r4,#0x34]
        0x0800194e:    8da0        ..      LDRH     r0,[r4,#0x2c]
        0x08001950:    8de1        ..      LDRH     r1,[r4,#0x2e]
        0x08001952:    1a40        @.      SUBS     r0,r0,r1
        0x08001954:    b281        ..      UXTH     r1,r0
        0x08001956:    e02a        *.      B        0x80019ae ; HAL_UART_IRQHandler + 486
        0x08001958:    8da0        ..      LDRH     r0,[r4,#0x2c]
        0x0800195a:    8de1        ..      LDRH     r1,[r4,#0x2e]
        0x0800195c:    1a40        @.      SUBS     r0,r0,r1
        0x0800195e:    b281        ..      UXTH     r1,r0
        0x08001960:    8de0        ..      LDRH     r0,[r4,#0x2e]
        0x08001962:    2800        .(      CMP      r0,#0
        0x08001964:    d0a6        ..      BEQ      0x80018b4 ; HAL_UART_IRQHandler + 236
        0x08001966:    2900        .)      CMP      r1,#0
        0x08001968:    d0a4        ..      BEQ      0x80018b4 ; HAL_UART_IRQHandler + 236
        0x0800196a:    6822        "h      LDR      r2,[r4,#0]
        0x0800196c:    320c        .2      ADDS     r2,r2,#0xc
        0x0800196e:    e8520f00    R...    LDREX    r0,[r2]
        0x08001972:    f4207090     ..p    BIC      r0,r0,#0x120
        0x08001976:    e8420700    B...    STREX    r7,r0,[r2]
        0x0800197a:    2f00        ./      CMP      r7,#0
        0x0800197c:    d1f5        ..      BNE      0x800196a ; HAL_UART_IRQHandler + 418
        0x0800197e:    6820         h      LDR      r0,[r4,#0]
        0x08001980:    3014        .0      ADDS     r0,r0,#0x14
        0x08001982:    e8502f00    P../    LDREX    r2,[r0]
        0x08001986:    f0220201    "...    BIC      r2,r2,#1
        0x0800198a:    e8402700    @..'    STREX    r7,r2,[r0]
        0x0800198e:    2f00        ./      CMP      r7,#0
        0x08001990:    d1f5        ..      BNE      0x800197e ; HAL_UART_IRQHandler + 438
        0x08001992:    f8843042    ..B0    STRB     r3,[r4,#0x42]
        0x08001996:    6325        %c      STR      r5,[r4,#0x30]
        0x08001998:    6820         h      LDR      r0,[r4,#0]
        0x0800199a:    300c        .0      ADDS     r0,r0,#0xc
        0x0800199c:    e8502f00    P../    LDREX    r2,[r0]
        0x080019a0:    f0220210    "...    BIC      r2,r2,#0x10
        0x080019a4:    e8402300    @..#    STREX    r3,r2,[r0]
        0x080019a8:    2b00        .+      CMP      r3,#0
        0x080019aa:    d1f5        ..      BNE      0x8001998 ; HAL_UART_IRQHandler + 464
        0x080019ac:    6366        fc      STR      r6,[r4,#0x34]
        0x080019ae:    4620         F      MOV      r0,r4
        0x080019b0:    f7ffff07    ....    BL       HAL_UARTEx_RxEventCallback ; 0x80017c2
        0x080019b4:    bdf8        ..      POP      {r3-r7,pc}
        0x080019b6:    e7ff        ..      B        0x80019b8 ; HAL_UART_IRQHandler + 496
        0x080019b8:    0605        ..      LSLS     r5,r0,#24
        0x080019ba:    d52b        +.      BPL      0x8001a14 ; HAL_UART_IRQHandler + 588
        0x080019bc:    0615        ..      LSLS     r5,r2,#24
        0x080019be:    d529        ).      BPL      0x8001a14 ; HAL_UART_IRQHandler + 588
        0x080019c0:    f8940041    ..A.    LDRB     r0,[r4,#0x41]
        0x080019c4:    2821        !(      CMP      r0,#0x21
        0x080019c6:    d1f5        ..      BNE      0x80019b4 ; HAL_UART_IRQHandler + 492
        0x080019c8:    68a0        .h      LDR      r0,[r4,#8]
        0x080019ca:    f5b05f80    ..._    CMP      r0,#0x1000
        0x080019ce:    d101        ..      BNE      0x80019d4 ; HAL_UART_IRQHandler + 524
        0x080019d0:    6920         i      LDR      r0,[r4,#0x10]
        0x080019d2:    b1b0        ..      CBZ      r0,0x8001a02 ; HAL_UART_IRQHandler + 570
        0x080019d4:    6a20         j      LDR      r0,[r4,#0x20]
        0x080019d6:    1c41        A.      ADDS     r1,r0,#1
        0x080019d8:    6221        !b      STR      r1,[r4,#0x20]
        0x080019da:    6821        !h      LDR      r1,[r4,#0]
        0x080019dc:    7800        .x      LDRB     r0,[r0,#0]
        0x080019de:    6048        H`      STR      r0,[r1,#4]
        0x080019e0:    8ce0        ..      LDRH     r0,[r4,#0x26]
        0x080019e2:    1e40        @.      SUBS     r0,r0,#1
        0x080019e4:    0400        ..      LSLS     r0,r0,#16
        0x080019e6:    0c00        ..      LSRS     r0,r0,#16
        0x080019e8:    84e0        ..      STRH     r0,[r4,#0x26]
        0x080019ea:    d1e3        ..      BNE      0x80019b4 ; HAL_UART_IRQHandler + 492
        0x080019ec:    6820         h      LDR      r0,[r4,#0]
        0x080019ee:    68c1        .h      LDR      r1,[r0,#0xc]
        0x080019f0:    f0210180    !...    BIC      r1,r1,#0x80
        0x080019f4:    60c1        .`      STR      r1,[r0,#0xc]
        0x080019f6:    6820         h      LDR      r0,[r4,#0]
        0x080019f8:    68c1        .h      LDR      r1,[r0,#0xc]
        0x080019fa:    f0410140    A.@.    ORR      r1,r1,#0x40
        0x080019fe:    60c1        .`      STR      r1,[r0,#0xc]
        0x08001a00:    e7d8        ..      B        0x80019b4 ; HAL_UART_IRQHandler + 492
        0x08001a02:    6a20         j      LDR      r0,[r4,#0x20]
        0x08001a04:    8800        ..      LDRH     r0,[r0,#0]
        0x08001a06:    f3c00008    ....    UBFX     r0,r0,#0,#9
        0x08001a0a:    6048        H`      STR      r0,[r1,#4]
        0x08001a0c:    6a20         j      LDR      r0,[r4,#0x20]
        0x08001a0e:    1c80        ..      ADDS     r0,r0,#2
        0x08001a10:    6220         b      STR      r0,[r4,#0x20]
        0x08001a12:    e7e5        ..      B        0x80019e0 ; HAL_UART_IRQHandler + 536
        0x08001a14:    0640        @.      LSLS     r0,r0,#25
        0x08001a16:    d5cd        ..      BPL      0x80019b4 ; HAL_UART_IRQHandler + 492
        0x08001a18:    0650        P.      LSLS     r0,r2,#25
        0x08001a1a:    d5cb        ..      BPL      0x80019b4 ; HAL_UART_IRQHandler + 492
        0x08001a1c:    68ca        .h      LDR      r2,[r1,#0xc]
        0x08001a1e:    4620         F      MOV      r0,r4
        0x08001a20:    f0220240    ".@.    BIC      r2,r2,#0x40
        0x08001a24:    60ca        .`      STR      r2,[r1,#0xc]
        0x08001a26:    f8843041    ..A0    STRB     r3,[r4,#0x41]
        0x08001a2a:    f000f8c6    ....    BL       HAL_UART_TxCpltCallback ; 0x8001bba
        0x08001a2e:    e7c1        ..      B        0x80019b4 ; HAL_UART_IRQHandler + 492
    $d
        0x08001a30:    08002363    c#..    DCD    134226787
    $t
    i.HAL_UART_Init
    HAL_UART_Init
        0x08001a34:    b570        p.      PUSH     {r4-r6,lr}
        0x08001a36:    0004        ..      MOVS     r4,r0
        0x08001a38:    d004        ..      BEQ      0x8001a44 ; HAL_UART_Init + 16
        0x08001a3a:    f8940041    ..A.    LDRB     r0,[r4,#0x41]
        0x08001a3e:    2500        .%      MOVS     r5,#0
        0x08001a40:    b110        ..      CBZ      r0,0x8001a48 ; HAL_UART_Init + 20
        0x08001a42:    e006        ..      B        0x8001a52 ; HAL_UART_Init + 30
        0x08001a44:    2001        .       MOVS     r0,#1
        0x08001a46:    bd70        p.      POP      {r4-r6,pc}
        0x08001a48:    f8845040    ..@P    STRB     r5,[r4,#0x40]
        0x08001a4c:    4620         F      MOV      r0,r4
        0x08001a4e:    f000f823    ..#.    BL       HAL_UART_MspInit ; 0x8001a98
        0x08001a52:    2024        $       MOVS     r0,#0x24
        0x08001a54:    f8840041    ..A.    STRB     r0,[r4,#0x41]
        0x08001a58:    6820         h      LDR      r0,[r4,#0]
        0x08001a5a:    68c1        .h      LDR      r1,[r0,#0xc]
        0x08001a5c:    f4215100    !..Q    BIC      r1,r1,#0x2000
        0x08001a60:    60c1        .`      STR      r1,[r0,#0xc]
        0x08001a62:    4620         F      MOV      r0,r4
        0x08001a64:    f000fd0e    ....    BL       UART_SetConfig ; 0x8002484
        0x08001a68:    6820         h      LDR      r0,[r4,#0]
        0x08001a6a:    6901        .i      LDR      r1,[r0,#0x10]
        0x08001a6c:    f4214190    !..A    BIC      r1,r1,#0x4800
        0x08001a70:    6101        .a      STR      r1,[r0,#0x10]
        0x08001a72:    6820         h      LDR      r0,[r4,#0]
        0x08001a74:    6941        Ai      LDR      r1,[r0,#0x14]
        0x08001a76:    f021012a    !.*.    BIC      r1,r1,#0x2a
        0x08001a7a:    6141        Aa      STR      r1,[r0,#0x14]
        0x08001a7c:    6820         h      LDR      r0,[r4,#0]
        0x08001a7e:    68c1        .h      LDR      r1,[r0,#0xc]
        0x08001a80:    f4415100    A..Q    ORR      r1,r1,#0x2000
        0x08001a84:    60c1        .`      STR      r1,[r0,#0xc]
        0x08001a86:    6465        ed      STR      r5,[r4,#0x44]
        0x08001a88:    2020                MOVS     r0,#0x20
        0x08001a8a:    f8840041    ..A.    STRB     r0,[r4,#0x41]
        0x08001a8e:    f8840042    ..B.    STRB     r0,[r4,#0x42]
        0x08001a92:    6365        ec      STR      r5,[r4,#0x34]
        0x08001a94:    2000        .       MOVS     r0,#0
        0x08001a96:    bd70        p.      POP      {r4-r6,pc}
    i.HAL_UART_MspInit
    HAL_UART_MspInit
        0x08001a98:    b530        0.      PUSH     {r4,r5,lr}
        0x08001a9a:    b085        ..      SUB      sp,sp,#0x14
        0x08001a9c:    2400        .$      MOVS     r4,#0
        0x08001a9e:    9400        ..      STR      r4,[sp,#0]
        0x08001aa0:    9401        ..      STR      r4,[sp,#4]
        0x08001aa2:    9402        ..      STR      r4,[sp,#8]
        0x08001aa4:    9403        ..      STR      r4,[sp,#0xc]
        0x08001aa6:    6800        .h      LDR      r0,[r0,#0]
        0x08001aa8:    4918        .I      LDR      r1,[pc,#96] ; [0x8001b0c] = 0x40013800
        0x08001aaa:    4288        .B      CMP      r0,r1
        0x08001aac:    d12c        ,.      BNE      0x8001b08 ; HAL_UART_MspInit + 112
        0x08001aae:    4818        .H      LDR      r0,[pc,#96] ; [0x8001b10] = 0x40021000
        0x08001ab0:    6981        .i      LDR      r1,[r0,#0x18]
        0x08001ab2:    f4414180    A..A    ORR      r1,r1,#0x4000
        0x08001ab6:    6181        .a      STR      r1,[r0,#0x18]
        0x08001ab8:    6981        .i      LDR      r1,[r0,#0x18]
        0x08001aba:    f4014180    ...A    AND      r1,r1,#0x4000
        0x08001abe:    9104        ..      STR      r1,[sp,#0x10]
        0x08001ac0:    6981        .i      LDR      r1,[r0,#0x18]
        0x08001ac2:    f0410104    A...    ORR      r1,r1,#4
        0x08001ac6:    6181        .a      STR      r1,[r0,#0x18]
        0x08001ac8:    6980        .i      LDR      r0,[r0,#0x18]
        0x08001aca:    4d12        .M      LDR      r5,[pc,#72] ; [0x8001b14] = 0x40010800
        0x08001acc:    f0000004    ....    AND      r0,r0,#4
        0x08001ad0:    9004        ..      STR      r0,[sp,#0x10]
        0x08001ad2:    f44f7000    O..p    MOV      r0,#0x200
        0x08001ad6:    9000        ..      STR      r0,[sp,#0]
        0x08001ad8:    2002        .       MOVS     r0,#2
        0x08001ada:    9001        ..      STR      r0,[sp,#4]
        0x08001adc:    2003        .       MOVS     r0,#3
        0x08001ade:    9003        ..      STR      r0,[sp,#0xc]
        0x08001ae0:    4669        iF      MOV      r1,sp
        0x08001ae2:    4628        (F      MOV      r0,r5
        0x08001ae4:    f7feffc2    ....    BL       HAL_GPIO_Init ; 0x8000a6c
        0x08001ae8:    1528        (.      ASRS     r0,r5,#20
        0x08001aea:    e9cd0400    ....    STRD     r0,r4,[sp,#0]
        0x08001aee:    4669        iF      MOV      r1,sp
        0x08001af0:    4628        (F      MOV      r0,r5
        0x08001af2:    9402        ..      STR      r4,[sp,#8]
        0x08001af4:    f7feffba    ....    BL       HAL_GPIO_Init ; 0x8000a6c
        0x08001af8:    2200        ."      MOVS     r2,#0
        0x08001afa:    4611        .F      MOV      r1,r2
        0x08001afc:    2025        %       MOVS     r0,#0x25
        0x08001afe:    f7fff917    ....    BL       HAL_NVIC_SetPriority ; 0x8000d30
        0x08001b02:    2025        %       MOVS     r0,#0x25
        0x08001b04:    f7fff906    ....    BL       HAL_NVIC_EnableIRQ ; 0x8000d14
        0x08001b08:    b005        ..      ADD      sp,sp,#0x14
        0x08001b0a:    bd30        0.      POP      {r4,r5,pc}
    $d
        0x08001b0c:    40013800    .8.@    DCD    1073821696
        0x08001b10:    40021000    ...@    DCD    1073876992
        0x08001b14:    40010800    ...@    DCD    1073809408
    $t
    i.HAL_UART_RxCpltCallback
    HAL_UART_RxCpltCallback
        0x08001b18:    4770        pG      BX       lr
    i.HAL_UART_Transmit
    HAL_UART_Transmit
        0x08001b1a:    e92d43f8    -..C    PUSH     {r3-r9,lr}
        0x08001b1e:    4604        .F      MOV      r4,r0
        0x08001b20:    f8900041    ..A.    LDRB     r0,[r0,#0x41]
        0x08001b24:    4698        .F      MOV      r8,r3
        0x08001b26:    4616        .F      MOV      r6,r2
        0x08001b28:    460d        .F      MOV      r5,r1
        0x08001b2a:    2820         (      CMP      r0,#0x20
        0x08001b2c:    d002        ..      BEQ      0x8001b34 ; HAL_UART_Transmit + 26
        0x08001b2e:    2002        .       MOVS     r0,#2
        0x08001b30:    e8bd83f8    ....    POP      {r3-r9,pc}
        0x08001b34:    b185        ..      CBZ      r5,0x8001b58 ; HAL_UART_Transmit + 62
        0x08001b36:    b17e        ~.      CBZ      r6,0x8001b58 ; HAL_UART_Transmit + 62
        0x08001b38:    2000        .       MOVS     r0,#0
        0x08001b3a:    6460        `d      STR      r0,[r4,#0x44]
        0x08001b3c:    2021        !       MOVS     r0,#0x21
        0x08001b3e:    f8840041    ..A.    STRB     r0,[r4,#0x41]
        0x08001b42:    f7fff889    ....    BL       HAL_GetTick ; 0x8000c58
        0x08001b46:    84a6        ..      STRH     r6,[r4,#0x24]
        0x08001b48:    4681        .F      MOV      r9,r0
        0x08001b4a:    84e6        ..      STRH     r6,[r4,#0x26]
        0x08001b4c:    68a0        .h      LDR      r0,[r4,#8]
        0x08001b4e:    2720         '      MOVS     r7,#0x20
        0x08001b50:    f5b05f80    ..._    CMP      r0,#0x1000
        0x08001b54:    d002        ..      BEQ      0x8001b5c ; HAL_UART_Transmit + 66
        0x08001b56:    e003        ..      B        0x8001b60 ; HAL_UART_Transmit + 70
        0x08001b58:    2001        .       MOVS     r0,#1
        0x08001b5a:    e7e9        ..      B        0x8001b30 ; HAL_UART_Transmit + 22
        0x08001b5c:    6920         i      LDR      r0,[r4,#0x10]
        0x08001b5e:    b110        ..      CBZ      r0,0x8001b66 ; HAL_UART_Transmit + 76
        0x08001b60:    462e        .F      MOV      r6,r5
        0x08001b62:    2500        .%      MOVS     r5,#0
        0x08001b64:    e00e        ..      B        0x8001b84 ; HAL_UART_Transmit + 106
        0x08001b66:    2600        .&      MOVS     r6,#0
        0x08001b68:    e00c        ..      B        0x8001b84 ; HAL_UART_Transmit + 106
        0x08001b6a:    2180        .!      MOVS     r1,#0x80
        0x08001b6c:    4620         F      MOV      r0,r4
        0x08001b6e:    f000fce5    ....    BL       UART_WaitOnFlagUntilTimeout ; 0x800253c
        0x08001b72:    b9a8        ..      CBNZ     r0,0x8001ba0 ; HAL_UART_Transmit + 134
        0x08001b74:    b1c6        ..      CBZ      r6,0x8001ba8 ; HAL_UART_Transmit + 142
        0x08001b76:    f8160b01    ....    LDRB     r0,[r6],#1
        0x08001b7a:    6821        !h      LDR      r1,[r4,#0]
        0x08001b7c:    6048        H`      STR      r0,[r1,#4]
        0x08001b7e:    8ce0        ..      LDRH     r0,[r4,#0x26]
        0x08001b80:    1e40        @.      SUBS     r0,r0,#1
        0x08001b82:    84e0        ..      STRH     r0,[r4,#0x26]
        0x08001b84:    8ce0        ..      LDRH     r0,[r4,#0x26]
        0x08001b86:    464b        KF      MOV      r3,r9
        0x08001b88:    f04f0200    O...    MOV      r2,#0
        0x08001b8c:    f8cd8000    ....    STR      r8,[sp,#0]
        0x08001b90:    2800        .(      CMP      r0,#0
        0x08001b92:    d1ea        ..      BNE      0x8001b6a ; HAL_UART_Transmit + 80
        0x08001b94:    f04f0140    O.@.    MOV      r1,#0x40
        0x08001b98:    4620         F      MOV      r0,r4
        0x08001b9a:    f000fccf    ....    BL       UART_WaitOnFlagUntilTimeout ; 0x800253c
        0x08001b9e:    b140        @.      CBZ      r0,0x8001bb2 ; HAL_UART_Transmit + 152
        0x08001ba0:    f8847041    ..Ap    STRB     r7,[r4,#0x41]
        0x08001ba4:    2003        .       MOVS     r0,#3
        0x08001ba6:    e7c3        ..      B        0x8001b30 ; HAL_UART_Transmit + 22
        0x08001ba8:    f8350b02    5...    LDRH     r0,[r5],#2
        0x08001bac:    f3c00008    ....    UBFX     r0,r0,#0,#9
        0x08001bb0:    e7e3        ..      B        0x8001b7a ; HAL_UART_Transmit + 96
        0x08001bb2:    f8847041    ..Ap    STRB     r7,[r4,#0x41]
        0x08001bb6:    2000        .       MOVS     r0,#0
        0x08001bb8:    e7ba        ..      B        0x8001b30 ; HAL_UART_Transmit + 22
    i.HAL_UART_TxCpltCallback
    HAL_UART_TxCpltCallback
        0x08001bba:    4770        pG      BX       lr
    i.HardFault_Handler
    HardFault_Handler
        0x08001bbc:    e7fe        ..      B        HardFault_Handler ; 0x8001bbc
        0x08001bbe:    0000        ..      MOVS     r0,r0
    i.MX_ADC1_Init
    MX_ADC1_Init
        0x08001bc0:    b53e        >.      PUSH     {r1-r5,lr}
        0x08001bc2:    2100        .!      MOVS     r1,#0
        0x08001bc4:    4812        .H      LDR      r0,[pc,#72] ; [0x8001c10] = 0x20000388
        0x08001bc6:    9100        ..      STR      r1,[sp,#0]
        0x08001bc8:    9101        ..      STR      r1,[sp,#4]
        0x08001bca:    4a10        .J      LDR      r2,[pc,#64] ; [0x8001c0c] = 0x40012400
        0x08001bcc:    9102        ..      STR      r1,[sp,#8]
        0x08001bce:    6002        .`      STR      r2,[r0,#0]
        0x08001bd0:    6081        .`      STR      r1,[r0,#8]
        0x08001bd2:    7301        .s      STRB     r1,[r0,#0xc]
        0x08001bd4:    7501        .u      STRB     r1,[r0,#0x14]
        0x08001bd6:    2401        .$      MOVS     r4,#1
        0x08001bd8:    f44f2260    O.`"    MOV      r2,#0xe0000
        0x08001bdc:    6104        .a      STR      r4,[r0,#0x10]
        0x08001bde:    61c2        .a      STR      r2,[r0,#0x1c]
        0x08001be0:    6041        A`      STR      r1,[r0,#4]
        0x08001be2:    f7fefd11    ....    BL       HAL_ADC_Init ; 0x8000608
        0x08001be6:    b108        ..      CBZ      r0,0x8001bec ; MX_ADC1_Init + 44
        0x08001be8:    f7fefbae    ....    BL       Error_Handler ; 0x8000348
        0x08001bec:    2004        .       MOVS     r0,#4
        0x08001bee:    e9cd0400    ....    STRD     r0,r4,[sp,#0]
        0x08001bf2:    2006        .       MOVS     r0,#6
        0x08001bf4:    9002        ..      STR      r0,[sp,#8]
        0x08001bf6:    4669        iF      MOV      r1,sp
        0x08001bf8:    4805        .H      LDR      r0,[pc,#20] ; [0x8001c10] = 0x20000388
        0x08001bfa:    f7fefc15    ....    BL       HAL_ADC_ConfigChannel ; 0x8000428
        0x08001bfe:    b108        ..      CBZ      r0,0x8001c04 ; MX_ADC1_Init + 68
        0x08001c00:    f7fefba2    ....    BL       Error_Handler ; 0x8000348
        0x08001c04:    4802        .H      LDR      r0,[pc,#8] ; [0x8001c10] = 0x20000388
        0x08001c06:    f7fefba1    ....    BL       HAL_ADCEx_Calibration_Start ; 0x800034c
        0x08001c0a:    bd3e        >.      POP      {r1-r5,pc}
    $d
        0x08001c0c:    40012400    .$.@    DCD    1073816576
        0x08001c10:    20000388    ...     DCD    536871816
    $t
    i.MX_GPIO_Init
    MX_GPIO_Init
        0x08001c14:    e92d41f0    -..A    PUSH     {r4-r8,lr}
        0x08001c18:    b086        ..      SUB      sp,sp,#0x18
        0x08001c1a:    2400        .$      MOVS     r4,#0
        0x08001c1c:    482a        *H      LDR      r0,[pc,#168] ; [0x8001cc8] = 0x40021000
        0x08001c1e:    9400        ..      STR      r4,[sp,#0]
        0x08001c20:    9401        ..      STR      r4,[sp,#4]
        0x08001c22:    9402        ..      STR      r4,[sp,#8]
        0x08001c24:    9403        ..      STR      r4,[sp,#0xc]
        0x08001c26:    6981        .i      LDR      r1,[r0,#0x18]
        0x08001c28:    f0410110    A...    ORR      r1,r1,#0x10
        0x08001c2c:    6181        .a      STR      r1,[r0,#0x18]
        0x08001c2e:    6981        .i      LDR      r1,[r0,#0x18]
        0x08001c30:    f0010110    ....    AND      r1,r1,#0x10
        0x08001c34:    9104        ..      STR      r1,[sp,#0x10]
        0x08001c36:    6981        .i      LDR      r1,[r0,#0x18]
        0x08001c38:    f0410120    A. .    ORR      r1,r1,#0x20
        0x08001c3c:    6181        .a      STR      r1,[r0,#0x18]
        0x08001c3e:    6981        .i      LDR      r1,[r0,#0x18]
        0x08001c40:    f0010120    .. .    AND      r1,r1,#0x20
        0x08001c44:    9104        ..      STR      r1,[sp,#0x10]
        0x08001c46:    6981        .i      LDR      r1,[r0,#0x18]
        0x08001c48:    f0410104    A...    ORR      r1,r1,#4
        0x08001c4c:    6181        .a      STR      r1,[r0,#0x18]
        0x08001c4e:    6981        .i      LDR      r1,[r0,#0x18]
        0x08001c50:    f0010104    ....    AND      r1,r1,#4
        0x08001c54:    9104        ..      STR      r1,[sp,#0x10]
        0x08001c56:    6981        .i      LDR      r1,[r0,#0x18]
        0x08001c58:    f0410108    A...    ORR      r1,r1,#8
        0x08001c5c:    6181        .a      STR      r1,[r0,#0x18]
        0x08001c5e:    6980        .i      LDR      r0,[r0,#0x18]
        0x08001c60:    4f1a        .O      LDR      r7,[pc,#104] ; [0x8001ccc] = 0x40011000
        0x08001c62:    f0000008    ....    AND      r0,r0,#8
        0x08001c66:    f44f5500    O..U    MOV      r5,#0x2000
        0x08001c6a:    9004        ..      STR      r0,[sp,#0x10]
        0x08001c6c:    2200        ."      MOVS     r2,#0
        0x08001c6e:    4629        )F      MOV      r1,r5
        0x08001c70:    4638        8F      MOV      r0,r7
        0x08001c72:    f7feffeb    ....    BL       HAL_GPIO_WritePin ; 0x8000c4c
        0x08001c76:    f8df8058    ..X.    LDR      r8,[pc,#88] ; [0x8001cd0] = 0x40010c00
        0x08001c7a:    2200        ."      MOVS     r2,#0
        0x08001c7c:    f2403103    @..1    MOV      r1,#0x303
        0x08001c80:    4640        @F      MOV      r0,r8
        0x08001c82:    f7feffe3    ....    BL       HAL_GPIO_WritePin ; 0x8000c4c
        0x08001c86:    2601        .&      MOVS     r6,#1
        0x08001c88:    e9cd5600    ...V    STRD     r5,r6,[sp,#0]
        0x08001c8c:    2502        .%      MOVS     r5,#2
        0x08001c8e:    4669        iF      MOV      r1,sp
        0x08001c90:    4638        8F      MOV      r0,r7
        0x08001c92:    e9cd4502    ...E    STRD     r4,r5,[sp,#8]
        0x08001c96:    f7fefee9    ....    BL       HAL_GPIO_Init ; 0x8000a6c
        0x08001c9a:    2003        .       MOVS     r0,#3
        0x08001c9c:    e9cd0600    ....    STRD     r0,r6,[sp,#0]
        0x08001ca0:    4669        iF      MOV      r1,sp
        0x08001ca2:    4640        @F      MOV      r0,r8
        0x08001ca4:    e9cd4502    ...E    STRD     r4,r5,[sp,#8]
        0x08001ca8:    f7fefee0    ....    BL       HAL_GPIO_Init ; 0x8000a6c
        0x08001cac:    f44f7040    O.@p    MOV      r0,#0x300
        0x08001cb0:    9000        ..      STR      r0,[sp,#0]
        0x08001cb2:    aa01        ..      ADD      r2,sp,#4
        0x08001cb4:    2011        .       MOVS     r0,#0x11
        0x08001cb6:    e8820031    ..1.    STM      r2,{r0,r4,r5}
        0x08001cba:    4669        iF      MOV      r1,sp
        0x08001cbc:    4640        @F      MOV      r0,r8
        0x08001cbe:    f7fefed5    ....    BL       HAL_GPIO_Init ; 0x8000a6c
        0x08001cc2:    b006        ..      ADD      sp,sp,#0x18
        0x08001cc4:    e8bd81f0    ....    POP      {r4-r8,pc}
    $d
        0x08001cc8:    40021000    ...@    DCD    1073876992
        0x08001ccc:    40011000    ...@    DCD    1073811456
        0x08001cd0:    40010c00    ...@    DCD    1073810432
    $t
    i.MX_TIM3_Init
    MX_TIM3_Init
        0x08001cd4:    b510        ..      PUSH     {r4,lr}
        0x08001cd6:    b086        ..      SUB      sp,sp,#0x18
        0x08001cd8:    2400        .$      MOVS     r4,#0
        0x08001cda:    4817        .H      LDR      r0,[pc,#92] ; [0x8001d38] = 0x200003b8
        0x08001cdc:    9400        ..      STR      r4,[sp,#0]
        0x08001cde:    9401        ..      STR      r4,[sp,#4]
        0x08001ce0:    9402        ..      STR      r4,[sp,#8]
        0x08001ce2:    9403        ..      STR      r4,[sp,#0xc]
        0x08001ce4:    9404        ..      STR      r4,[sp,#0x10]
        0x08001ce6:    4913        .I      LDR      r1,[pc,#76] ; [0x8001d34] = 0x40000400
        0x08001ce8:    9405        ..      STR      r4,[sp,#0x14]
        0x08001cea:    6001        .`      STR      r1,[r0,#0]
        0x08001cec:    2147        G!      MOVS     r1,#0x47
        0x08001cee:    e9c01401    ....    STRD     r1,r4,[r0,#4]
        0x08001cf2:    f242710f    B..q    MOV      r1,#0x270f
        0x08001cf6:    e9c01403    ....    STRD     r1,r4,[r0,#0xc]
        0x08001cfa:    6184        .a      STR      r4,[r0,#0x18]
        0x08001cfc:    f7fffbc8    ....    BL       HAL_TIM_Base_Init ; 0x8001490
        0x08001d00:    b108        ..      CBZ      r0,0x8001d06 ; MX_TIM3_Init + 50
        0x08001d02:    f7fefb21    ..!.    BL       Error_Handler ; 0x8000348
        0x08001d06:    f44f5080    O..P    MOV      r0,#0x1000
        0x08001d0a:    9000        ..      STR      r0,[sp,#0]
        0x08001d0c:    4669        iF      MOV      r1,sp
        0x08001d0e:    480a        .H      LDR      r0,[pc,#40] ; [0x8001d38] = 0x200003b8
        0x08001d10:    f7fffc36    ..6.    BL       HAL_TIM_ConfigClockSource ; 0x8001580
        0x08001d14:    b108        ..      CBZ      r0,0x8001d1a ; MX_TIM3_Init + 70
        0x08001d16:    f7fefb17    ....    BL       Error_Handler ; 0x8000348
        0x08001d1a:    9404        ..      STR      r4,[sp,#0x10]
        0x08001d1c:    a904        ..      ADD      r1,sp,#0x10
        0x08001d1e:    4806        .H      LDR      r0,[pc,#24] ; [0x8001d38] = 0x200003b8
        0x08001d20:    9405        ..      STR      r4,[sp,#0x14]
        0x08001d22:    f7fffb81    ....    BL       HAL_TIMEx_MasterConfigSynchronization ; 0x8001428
        0x08001d26:    2800        .(      CMP      r0,#0
        0x08001d28:    d001        ..      BEQ      0x8001d2e ; MX_TIM3_Init + 90
        0x08001d2a:    f7fefb0d    ....    BL       Error_Handler ; 0x8000348
        0x08001d2e:    b006        ..      ADD      sp,sp,#0x18
        0x08001d30:    bd10        ..      POP      {r4,pc}
    $d
        0x08001d32:    0000        ..      DCW    0
        0x08001d34:    40000400    ...@    DCD    1073742848
        0x08001d38:    200003b8    ...     DCD    536871864
    $t
    i.MX_USART1_UART_Init
    MX_USART1_UART_Init
        0x08001d3c:    480c        .H      LDR      r0,[pc,#48] ; [0x8001d70] = 0x20000400
        0x08001d3e:    b510        ..      PUSH     {r4,lr}
        0x08001d40:    490a        .I      LDR      r1,[pc,#40] ; [0x8001d6c] = 0x40013800
        0x08001d42:    6001        .`      STR      r1,[r0,#0]
        0x08001d44:    f44f21e1    O..!    MOV      r1,#0x70800
        0x08001d48:    6041        A`      STR      r1,[r0,#4]
        0x08001d4a:    2100        .!      MOVS     r1,#0
        0x08001d4c:    6081        .`      STR      r1,[r0,#8]
        0x08001d4e:    220c        ."      MOVS     r2,#0xc
        0x08001d50:    60c1        .`      STR      r1,[r0,#0xc]
        0x08001d52:    e9c01204    ....    STRD     r1,r2,[r0,#0x10]
        0x08001d56:    6181        .a      STR      r1,[r0,#0x18]
        0x08001d58:    61c1        .a      STR      r1,[r0,#0x1c]
        0x08001d5a:    f7fffe6b    ..k.    BL       HAL_UART_Init ; 0x8001a34
        0x08001d5e:    2800        .(      CMP      r0,#0
        0x08001d60:    d003        ..      BEQ      0x8001d6a ; MX_USART1_UART_Init + 46
        0x08001d62:    e8bd4010    ...@    POP      {r4,lr}
        0x08001d66:    f7febaef    ....    B        Error_Handler ; 0x8000348
        0x08001d6a:    bd10        ..      POP      {r4,pc}
    $d
        0x08001d6c:    40013800    .8.@    DCD    1073821696
        0x08001d70:    20000400    ...     DCD    536871936
    $t
    i.MemManage_Handler
    MemManage_Handler
        0x08001d74:    e7fe        ..      B        MemManage_Handler ; 0x8001d74
    i.NMI_Handler
    NMI_Handler
        0x08001d76:    e7fe        ..      B        NMI_Handler ; 0x8001d76
    i.OLED_Clear
    OLED_Clear
        0x08001d78:    b570        p.      PUSH     {r4-r6,lr}
        0x08001d7a:    2400        .$      MOVS     r4,#0
        0x08001d7c:    2100        .!      MOVS     r1,#0
        0x08001d7e:    4620         F      MOV      r0,r4
        0x08001d80:    f000f8ad    ....    BL       OLED_SetCursor ; 0x8001ede
        0x08001d84:    2500        .%      MOVS     r5,#0
        0x08001d86:    2000        .       MOVS     r0,#0
        0x08001d88:    f000f931    ..1.    BL       OLED_WriteData ; 0x8001fee
        0x08001d8c:    1c6d        m.      ADDS     r5,r5,#1
        0x08001d8e:    b2ed        ..      UXTB     r5,r5
        0x08001d90:    2d80        .-      CMP      r5,#0x80
        0x08001d92:    d3f8        ..      BCC      0x8001d86 ; OLED_Clear + 14
        0x08001d94:    1c64        d.      ADDS     r4,r4,#1
        0x08001d96:    b2e4        ..      UXTB     r4,r4
        0x08001d98:    2c08        .,      CMP      r4,#8
        0x08001d9a:    d3ef        ..      BCC      0x8001d7c ; OLED_Clear + 4
        0x08001d9c:    bd70        p.      POP      {r4-r6,pc}
    i.OLED_I2C_Init
    OLED_I2C_Init
        0x08001d9e:    b510        ..      PUSH     {r4,lr}
        0x08001da0:    f7ffff38    ..8.    BL       MX_GPIO_Init ; 0x8001c14
        0x08001da4:    2001        .       MOVS     r0,#1
        0x08001da6:    f000f901    ....    BL       OLED_W_SCL ; 0x8001fac
        0x08001daa:    e8bd4010    ...@    POP      {r4,lr}
        0x08001dae:    2001        .       MOVS     r0,#1
        0x08001db0:    f000b904    ....    B.W      OLED_W_SDA ; 0x8001fbc
    i.OLED_I2C_SendByte
    OLED_I2C_SendByte
        0x08001db4:    b570        p.      PUSH     {r4-r6,lr}
        0x08001db6:    2400        .$      MOVS     r4,#0
        0x08001db8:    4606        .F      MOV      r6,r0
        0x08001dba:    2580        .%      MOVS     r5,#0x80
        0x08001dbc:    fa25f004    %...    LSR      r0,r5,r4
        0x08001dc0:    4030        0@      ANDS     r0,r0,r6
        0x08001dc2:    d000        ..      BEQ      0x8001dc6 ; OLED_I2C_SendByte + 18
        0x08001dc4:    2001        .       MOVS     r0,#1
        0x08001dc6:    f000f8f9    ....    BL       OLED_W_SDA ; 0x8001fbc
        0x08001dca:    2001        .       MOVS     r0,#1
        0x08001dcc:    f000f8ee    ....    BL       OLED_W_SCL ; 0x8001fac
        0x08001dd0:    2000        .       MOVS     r0,#0
        0x08001dd2:    f000f8eb    ....    BL       OLED_W_SCL ; 0x8001fac
        0x08001dd6:    1c64        d.      ADDS     r4,r4,#1
        0x08001dd8:    b2e4        ..      UXTB     r4,r4
        0x08001dda:    2c08        .,      CMP      r4,#8
        0x08001ddc:    d3ee        ..      BCC      0x8001dbc ; OLED_I2C_SendByte + 8
        0x08001dde:    2001        .       MOVS     r0,#1
        0x08001de0:    f000f8e4    ....    BL       OLED_W_SCL ; 0x8001fac
        0x08001de4:    e8bd4070    ..p@    POP      {r4-r6,lr}
        0x08001de8:    2000        .       MOVS     r0,#0
        0x08001dea:    f000b8df    ....    B.W      OLED_W_SCL ; 0x8001fac
    i.OLED_I2C_Start
    OLED_I2C_Start
        0x08001dee:    b510        ..      PUSH     {r4,lr}
        0x08001df0:    2001        .       MOVS     r0,#1
        0x08001df2:    f000f8e3    ....    BL       OLED_W_SDA ; 0x8001fbc
        0x08001df6:    2001        .       MOVS     r0,#1
        0x08001df8:    f000f8d8    ....    BL       OLED_W_SCL ; 0x8001fac
        0x08001dfc:    2000        .       MOVS     r0,#0
        0x08001dfe:    f000f8dd    ....    BL       OLED_W_SDA ; 0x8001fbc
        0x08001e02:    e8bd4010    ...@    POP      {r4,lr}
        0x08001e06:    2000        .       MOVS     r0,#0
        0x08001e08:    f000b8d0    ....    B.W      OLED_W_SCL ; 0x8001fac
    i.OLED_I2C_Stop
    OLED_I2C_Stop
        0x08001e0c:    b510        ..      PUSH     {r4,lr}
        0x08001e0e:    2000        .       MOVS     r0,#0
        0x08001e10:    f000f8d4    ....    BL       OLED_W_SDA ; 0x8001fbc
        0x08001e14:    2001        .       MOVS     r0,#1
        0x08001e16:    f000f8c9    ....    BL       OLED_W_SCL ; 0x8001fac
        0x08001e1a:    e8bd4010    ...@    POP      {r4,lr}
        0x08001e1e:    2001        .       MOVS     r0,#1
        0x08001e20:    f000b8cc    ....    B.W      OLED_W_SDA ; 0x8001fbc
    i.OLED_Init
    OLED_Init
        0x08001e24:    b510        ..      PUSH     {r4,lr}
        0x08001e26:    2000        .       MOVS     r0,#0
        0x08001e28:    f44f727a    O.zr    MOV      r2,#0x3e8
        0x08001e2c:    2100        .!      MOVS     r1,#0
        0x08001e2e:    1c49        I.      ADDS     r1,r1,#1
        0x08001e30:    4291        .B      CMP      r1,r2
        0x08001e32:    d3fc        ..      BCC      0x8001e2e ; OLED_Init + 10
        0x08001e34:    1c40        @.      ADDS     r0,r0,#1
        0x08001e36:    4290        .B      CMP      r0,r2
        0x08001e38:    d3f8        ..      BCC      0x8001e2c ; OLED_Init + 8
        0x08001e3a:    f7ffffb0    ....    BL       OLED_I2C_Init ; 0x8001d9e
        0x08001e3e:    20ae        .       MOVS     r0,#0xae
        0x08001e40:    f000f8c4    ....    BL       OLED_WriteCommand ; 0x8001fcc
        0x08001e44:    20d5        .       MOVS     r0,#0xd5
        0x08001e46:    f000f8c1    ....    BL       OLED_WriteCommand ; 0x8001fcc
        0x08001e4a:    2080        .       MOVS     r0,#0x80
        0x08001e4c:    f000f8be    ....    BL       OLED_WriteCommand ; 0x8001fcc
        0x08001e50:    20a8        .       MOVS     r0,#0xa8
        0x08001e52:    f000f8bb    ....    BL       OLED_WriteCommand ; 0x8001fcc
        0x08001e56:    203f        ?       MOVS     r0,#0x3f
        0x08001e58:    f000f8b8    ....    BL       OLED_WriteCommand ; 0x8001fcc
        0x08001e5c:    20d3        .       MOVS     r0,#0xd3
        0x08001e5e:    f000f8b5    ....    BL       OLED_WriteCommand ; 0x8001fcc
        0x08001e62:    2000        .       MOVS     r0,#0
        0x08001e64:    f000f8b2    ....    BL       OLED_WriteCommand ; 0x8001fcc
        0x08001e68:    2040        @       MOVS     r0,#0x40
        0x08001e6a:    f000f8af    ....    BL       OLED_WriteCommand ; 0x8001fcc
        0x08001e6e:    20a1        .       MOVS     r0,#0xa1
        0x08001e70:    f000f8ac    ....    BL       OLED_WriteCommand ; 0x8001fcc
        0x08001e74:    20c8        .       MOVS     r0,#0xc8
        0x08001e76:    f000f8a9    ....    BL       OLED_WriteCommand ; 0x8001fcc
        0x08001e7a:    20da        .       MOVS     r0,#0xda
        0x08001e7c:    f000f8a6    ....    BL       OLED_WriteCommand ; 0x8001fcc
        0x08001e80:    2012        .       MOVS     r0,#0x12
        0x08001e82:    f000f8a3    ....    BL       OLED_WriteCommand ; 0x8001fcc
        0x08001e86:    2081        .       MOVS     r0,#0x81
        0x08001e88:    f000f8a0    ....    BL       OLED_WriteCommand ; 0x8001fcc
        0x08001e8c:    20cf        .       MOVS     r0,#0xcf
        0x08001e8e:    f000f89d    ....    BL       OLED_WriteCommand ; 0x8001fcc
        0x08001e92:    20d9        .       MOVS     r0,#0xd9
        0x08001e94:    f000f89a    ....    BL       OLED_WriteCommand ; 0x8001fcc
        0x08001e98:    20f1        .       MOVS     r0,#0xf1
        0x08001e9a:    f000f897    ....    BL       OLED_WriteCommand ; 0x8001fcc
        0x08001e9e:    20db        .       MOVS     r0,#0xdb
        0x08001ea0:    f000f894    ....    BL       OLED_WriteCommand ; 0x8001fcc
        0x08001ea4:    2030        0       MOVS     r0,#0x30
        0x08001ea6:    f000f891    ....    BL       OLED_WriteCommand ; 0x8001fcc
        0x08001eaa:    20a4        .       MOVS     r0,#0xa4
        0x08001eac:    f000f88e    ....    BL       OLED_WriteCommand ; 0x8001fcc
        0x08001eb0:    20a6        .       MOVS     r0,#0xa6
        0x08001eb2:    f000f88b    ....    BL       OLED_WriteCommand ; 0x8001fcc
        0x08001eb6:    208d        .       MOVS     r0,#0x8d
        0x08001eb8:    f000f888    ....    BL       OLED_WriteCommand ; 0x8001fcc
        0x08001ebc:    2014        .       MOVS     r0,#0x14
        0x08001ebe:    f000f885    ....    BL       OLED_WriteCommand ; 0x8001fcc
        0x08001ec2:    20af        .       MOVS     r0,#0xaf
        0x08001ec4:    f000f882    ....    BL       OLED_WriteCommand ; 0x8001fcc
        0x08001ec8:    e8bd4010    ...@    POP      {r4,lr}
        0x08001ecc:    f7ffbf54    ..T.    B.W      OLED_Clear ; 0x8001d78
    i.OLED_Pow
    OLED_Pow
        0x08001ed0:    4602        .F      MOV      r2,r0
        0x08001ed2:    2001        .       MOVS     r0,#1
        0x08001ed4:    e000        ..      B        0x8001ed8 ; OLED_Pow + 8
        0x08001ed6:    4350        PC      MULS     r0,r2,r0
        0x08001ed8:    1e49        I.      SUBS     r1,r1,#1
        0x08001eda:    d2fc        ..      BCS      0x8001ed6 ; OLED_Pow + 6
        0x08001edc:    4770        pG      BX       lr
    i.OLED_SetCursor
    OLED_SetCursor
        0x08001ede:    b510        ..      PUSH     {r4,lr}
        0x08001ee0:    460c        .F      MOV      r4,r1
        0x08001ee2:    f04000b0    @...    ORR      r0,r0,#0xb0
        0x08001ee6:    f000f871    ..q.    BL       OLED_WriteCommand ; 0x8001fcc
        0x08001eea:    2010        .       MOVS     r0,#0x10
        0x08001eec:    ea401014    @...    ORR      r0,r0,r4,LSR #4
        0x08001ef0:    f000f86c    ..l.    BL       OLED_WriteCommand ; 0x8001fcc
        0x08001ef4:    f004000f    ....    AND      r0,r4,#0xf
        0x08001ef8:    e8bd4010    ...@    POP      {r4,lr}
        0x08001efc:    f000b866    ..f.    B.W      OLED_WriteCommand ; 0x8001fcc
    i.OLED_ShowChar
    OLED_ShowChar
        0x08001f00:    e92d41f0    -..A    PUSH     {r4-r8,lr}
        0x08001f04:    4607        .F      MOV      r7,r0
        0x08001f06:    00ce        ..      LSLS     r6,r1,#3
        0x08001f08:    0040        @.      LSLS     r0,r0,#1
        0x08001f0a:    3e08        .>      SUBS     r6,r6,#8
        0x08001f0c:    1e80        ..      SUBS     r0,r0,#2
        0x08001f0e:    4615        .F      MOV      r5,r2
        0x08001f10:    f04f38ff    O..8    MOV      r8,#0xffffffff
        0x08001f14:    b2f1        ..      UXTB     r1,r6
        0x08001f16:    b2c0        ..      UXTB     r0,r0
        0x08001f18:    f7ffffe1    ....    BL       OLED_SetCursor ; 0x8001ede
        0x08001f1c:    4811        .H      LDR      r0,[pc,#68] ; [0x8001f64] = 0x8002b40
        0x08001f1e:    2400        .$      MOVS     r4,#0
        0x08001f20:    eb001505    ....    ADD      r5,r0,r5,LSL #4
        0x08001f24:    1928        (.      ADDS     r0,r5,r4
        0x08001f26:    f5a05080    ...P    SUB      r0,r0,#0x1000
        0x08001f2a:    f8900e00    ....    LDRB     r0,[r0,#0xe00]
        0x08001f2e:    f000f85e    ..^.    BL       OLED_WriteData ; 0x8001fee
        0x08001f32:    1c64        d.      ADDS     r4,r4,#1
        0x08001f34:    b2e4        ..      UXTB     r4,r4
        0x08001f36:    2c08        .,      CMP      r4,#8
        0x08001f38:    d3f4        ..      BCC      0x8001f24 ; OLED_ShowChar + 36
        0x08001f3a:    eb080047    ..G.    ADD      r0,r8,r7,LSL #1
        0x08001f3e:    b2f1        ..      UXTB     r1,r6
        0x08001f40:    b2c0        ..      UXTB     r0,r0
        0x08001f42:    f7ffffcc    ....    BL       OLED_SetCursor ; 0x8001ede
        0x08001f46:    2400        .$      MOVS     r4,#0
        0x08001f48:    1928        (.      ADDS     r0,r5,r4
        0x08001f4a:    f5a05080    ...P    SUB      r0,r0,#0x1000
        0x08001f4e:    f8900e08    ....    LDRB     r0,[r0,#0xe08]
        0x08001f52:    f000f84c    ..L.    BL       OLED_WriteData ; 0x8001fee
        0x08001f56:    1c64        d.      ADDS     r4,r4,#1
        0x08001f58:    b2e4        ..      UXTB     r4,r4
        0x08001f5a:    2c08        .,      CMP      r4,#8
        0x08001f5c:    d3f4        ..      BCC      0x8001f48 ; OLED_ShowChar + 72
        0x08001f5e:    e8bd81f0    ....    POP      {r4-r8,pc}
    $d
        0x08001f62:    0000        ..      DCW    0
        0x08001f64:    08002b40    @+..    DCD    134228800
    $t
    i.OLED_ShowNum
    OLED_ShowNum
        0x08001f68:    e92d47f0    -..G    PUSH     {r4-r10,lr}
        0x08001f6c:    2400        .$      MOVS     r4,#0
        0x08001f6e:    461d        .F      MOV      r5,r3
        0x08001f70:    4616        .F      MOV      r6,r2
        0x08001f72:    4688        .F      MOV      r8,r1
        0x08001f74:    4681        .F      MOV      r9,r0
        0x08001f76:    270a        .'      MOVS     r7,#0xa
        0x08001f78:    e013        ..      B        0x8001fa2 ; OLED_ShowNum + 58
        0x08001f7a:    1b29        ).      SUBS     r1,r5,r4
        0x08001f7c:    200a        .       MOVS     r0,#0xa
        0x08001f7e:    1e49        I.      SUBS     r1,r1,#1
        0x08001f80:    f7ffffa6    ....    BL       OLED_Pow ; 0x8001ed0
        0x08001f84:    fbb6f0f0    ....    UDIV     r0,r6,r0
        0x08001f88:    fbb0f1f7    ....    UDIV     r1,r0,r7
        0x08001f8c:    fb070211    ....    MLS      r2,r7,r1,r0
        0x08001f90:    eb080004    ....    ADD      r0,r8,r4
        0x08001f94:    b2c1        ..      UXTB     r1,r0
        0x08001f96:    4648        HF      MOV      r0,r9
        0x08001f98:    3230        02      ADDS     r2,r2,#0x30
        0x08001f9a:    f7ffffb1    ....    BL       OLED_ShowChar ; 0x8001f00
        0x08001f9e:    1c64        d.      ADDS     r4,r4,#1
        0x08001fa0:    b2e4        ..      UXTB     r4,r4
        0x08001fa2:    42ac        .B      CMP      r4,r5
        0x08001fa4:    d3e9        ..      BCC      0x8001f7a ; OLED_ShowNum + 18
        0x08001fa6:    e8bd87f0    ....    POP      {r4-r10,pc}
        0x08001faa:    0000        ..      MOVS     r0,r0
    i.OLED_W_SCL
    OLED_W_SCL
        0x08001fac:    4602        .F      MOV      r2,r0
        0x08001fae:    f44f7180    O..q    MOV      r1,#0x100
        0x08001fb2:    4801        .H      LDR      r0,[pc,#4] ; [0x8001fb8] = 0x40010c00
        0x08001fb4:    f7febe4a    ..J.    B        HAL_GPIO_WritePin ; 0x8000c4c
    $d
        0x08001fb8:    40010c00    ...@    DCD    1073810432
    $t
    i.OLED_W_SDA
    OLED_W_SDA
        0x08001fbc:    4602        .F      MOV      r2,r0
        0x08001fbe:    f44f7100    O..q    MOV      r1,#0x200
        0x08001fc2:    4801        .H      LDR      r0,[pc,#4] ; [0x8001fc8] = 0x40010c00
        0x08001fc4:    f7febe42    ..B.    B        HAL_GPIO_WritePin ; 0x8000c4c
    $d
        0x08001fc8:    40010c00    ...@    DCD    1073810432
    $t
    i.OLED_WriteCommand
    OLED_WriteCommand
        0x08001fcc:    b510        ..      PUSH     {r4,lr}
        0x08001fce:    4604        .F      MOV      r4,r0
        0x08001fd0:    f7ffff0d    ....    BL       OLED_I2C_Start ; 0x8001dee
        0x08001fd4:    2078        x       MOVS     r0,#0x78
        0x08001fd6:    f7fffeed    ....    BL       OLED_I2C_SendByte ; 0x8001db4
        0x08001fda:    2000        .       MOVS     r0,#0
        0x08001fdc:    f7fffeea    ....    BL       OLED_I2C_SendByte ; 0x8001db4
        0x08001fe0:    4620         F      MOV      r0,r4
        0x08001fe2:    f7fffee7    ....    BL       OLED_I2C_SendByte ; 0x8001db4
        0x08001fe6:    e8bd4010    ...@    POP      {r4,lr}
        0x08001fea:    f7ffbf0f    ....    B.W      OLED_I2C_Stop ; 0x8001e0c
    i.OLED_WriteData
    OLED_WriteData
        0x08001fee:    b510        ..      PUSH     {r4,lr}
        0x08001ff0:    4604        .F      MOV      r4,r0
        0x08001ff2:    f7fffefc    ....    BL       OLED_I2C_Start ; 0x8001dee
        0x08001ff6:    2078        x       MOVS     r0,#0x78
        0x08001ff8:    f7fffedc    ....    BL       OLED_I2C_SendByte ; 0x8001db4
        0x08001ffc:    2040        @       MOVS     r0,#0x40
        0x08001ffe:    f7fffed9    ....    BL       OLED_I2C_SendByte ; 0x8001db4
        0x08002002:    4620         F      MOV      r0,r4
        0x08002004:    f7fffed6    ....    BL       OLED_I2C_SendByte ; 0x8001db4
        0x08002008:    e8bd4010    ...@    POP      {r4,lr}
        0x0800200c:    f7ffbefe    ....    B.W      OLED_I2C_Stop ; 0x8001e0c
    i.PendSV_Handler
    PendSV_Handler
        0x08002010:    4770        pG      BX       lr
        0x08002012:    0000        ..      MOVS     r0,r0
    i.RD_TSL
    RD_TSL
        0x08002014:    e92d47f0    -..G    PUSH     {r4-r10,lr}
        0x08002018:    4f72        rO      LDR      r7,[pc,#456] ; [0x80021e4] = 0x40010c00
        0x0800201a:    2600        .&      MOVS     r6,#0
        0x0800201c:    2201        ."      MOVS     r2,#1
        0x0800201e:    4635        5F      MOV      r5,r6
        0x08002020:    4611        .F      MOV      r1,r2
        0x08002022:    4638        8F      MOV      r0,r7
        0x08002024:    f7fefe12    ....    BL       HAL_GPIO_WritePin ; 0x8000c4c
        0x08002028:    2200        ."      MOVS     r2,#0
        0x0800202a:    2102        .!      MOVS     r1,#2
        0x0800202c:    4638        8F      MOV      r0,r7
        0x0800202e:    f7fefe0d    ....    BL       HAL_GPIO_WritePin ; 0x8000c4c
        0x08002032:    4c6d        mL      LDR      r4,[pc,#436] ; [0x80021e8] = 0x20000000
        0x08002034:    6960        `i      LDR      r0,[r4,#0x14]
        0x08002036:    f7fef95d    ..].    BL       Dly_us ; 0x80002f4
        0x0800203a:    2201        ."      MOVS     r2,#1
        0x0800203c:    2102        .!      MOVS     r1,#2
        0x0800203e:    4638        8F      MOV      r0,r7
        0x08002040:    f7fefe04    ....    BL       HAL_GPIO_WritePin ; 0x8000c4c
        0x08002044:    2200        ."      MOVS     r2,#0
        0x08002046:    2101        .!      MOVS     r1,#1
        0x08002048:    4638        8F      MOV      r0,r7
        0x0800204a:    f7fefdff    ....    BL       HAL_GPIO_WritePin ; 0x8000c4c
        0x0800204e:    6960        `i      LDR      r0,[r4,#0x14]
        0x08002050:    f7fef950    ..P.    BL       Dly_us ; 0x80002f4
        0x08002054:    2201        ."      MOVS     r2,#1
        0x08002056:    4611        .F      MOV      r1,r2
        0x08002058:    4638        8F      MOV      r0,r7
        0x0800205a:    f7fefdf7    ....    BL       HAL_GPIO_WritePin ; 0x8000c4c
        0x0800205e:    2200        ."      MOVS     r2,#0
        0x08002060:    2102        .!      MOVS     r1,#2
        0x08002062:    4638        8F      MOV      r0,r7
        0x08002064:    f7fefdf2    ....    BL       HAL_GPIO_WritePin ; 0x8000c4c
        0x08002068:    6960        `i      LDR      r0,[r4,#0x14]
        0x0800206a:    f7fef943    ..C.    BL       Dly_us ; 0x80002f4
        0x0800206e:    f8df917c    ..|.    LDR      r9,[pc,#380] ; [0x80021ec] = 0x200000b0
        0x08002072:    f1a90880    ....    SUB      r8,r9,#0x80
        0x08002076:    2200        ."      MOVS     r2,#0
        0x08002078:    2101        .!      MOVS     r1,#1
        0x0800207a:    4638        8F      MOV      r0,r7
        0x0800207c:    f7fefde6    ....    BL       HAL_GPIO_WritePin ; 0x8000c4c
        0x08002080:    6960        `i      LDR      r0,[r4,#0x14]
        0x08002082:    f7fef937    ..7.    BL       Dly_us ; 0x80002f4
        0x08002086:    485a        ZH      LDR      r0,[pc,#360] ; [0x80021f0] = 0x20000388
        0x08002088:    f7fefc20    .. .    BL       HAL_ADC_Start ; 0x80008cc
        0x0800208c:    2132        2!      MOVS     r1,#0x32
        0x0800208e:    4858        XH      LDR      r0,[pc,#352] ; [0x80021f0] = 0x20000388
        0x08002090:    f7fefb7e    ..~.    BL       HAL_ADC_PollForConversion ; 0x8000790
        0x08002094:    4856        VH      LDR      r0,[pc,#344] ; [0x80021f0] = 0x20000388
        0x08002096:    f7fefa46    ..F.    BL       HAL_ADC_GetValue ; 0x8000526
        0x0800209a:    f8290015    )...    STRH     r0,[r9,r5,LSL #1]
        0x0800209e:    0901        ..      LSRS     r1,r0,#4
        0x080020a0:    f8081005    ....    STRB     r1,[r8,r5]
        0x080020a4:    1c6d        m.      ADDS     r5,r5,#1
        0x080020a6:    2201        ."      MOVS     r2,#1
        0x080020a8:    b2ed        ..      UXTB     r5,r5
        0x080020aa:    4611        .F      MOV      r1,r2
        0x080020ac:    4638        8F      MOV      r0,r7
        0x080020ae:    f7fefdcd    ....    BL       HAL_GPIO_WritePin ; 0x8000c4c
        0x080020b2:    6960        `i      LDR      r0,[r4,#0x14]
        0x080020b4:    f7fef91e    ....    BL       Dly_us ; 0x80002f4
        0x080020b8:    1c76        v.      ADDS     r6,r6,#1
        0x080020ba:    b2f6        ..      UXTB     r6,r6
        0x080020bc:    2e80        ..      CMP      r6,#0x80
        0x080020be:    d3da        ..      BCC      0x8002076 ; RD_TSL + 98
        0x080020c0:    2200        ."      MOVS     r2,#0
        0x080020c2:    2101        .!      MOVS     r1,#1
        0x080020c4:    4638        8F      MOV      r0,r7
        0x080020c6:    f7fefdc1    ....    BL       HAL_GPIO_WritePin ; 0x8000c4c
        0x080020ca:    6960        `i      LDR      r0,[r4,#0x14]
        0x080020cc:    f7fef912    ....    BL       Dly_us ; 0x80002f4
        0x080020d0:    2201        ."      MOVS     r2,#1
        0x080020d2:    4611        .F      MOV      r1,r2
        0x080020d4:    4638        8F      MOV      r0,r7
        0x080020d6:    f7fefdb9    ....    BL       HAL_GPIO_WritePin ; 0x8000c4c
        0x080020da:    6960        `i      LDR      r0,[r4,#0x14]
        0x080020dc:    f7fef90a    ....    BL       Dly_us ; 0x80002f4
        0x080020e0:    f8983005    ...0    LDRB     r3,[r8,#5]
        0x080020e4:    4641        AF      MOV      r1,r8
        0x080020e6:    81e3        ..      STRH     r3,[r4,#0xe]
        0x080020e8:    2205        ."      MOVS     r2,#5
        0x080020ea:    4618        .F      MOV      r0,r3
        0x080020ec:    5c8d        .\      LDRB     r5,[r1,r2]
        0x080020ee:    4285        .B      CMP      r5,r0
        0x080020f0:    d300        ..      BCC      0x80020f4 ; RD_TSL + 224
        0x080020f2:    4628        (F      MOV      r0,r5
        0x080020f4:    1c52        R.      ADDS     r2,r2,#1
        0x080020f6:    b2d2        ..      UXTB     r2,r2
        0x080020f8:    2a7b        {*      CMP      r2,#0x7b
        0x080020fa:    d3f7        ..      BCC      0x80020ec ; RD_TSL + 216
        0x080020fc:    81e0        ..      STRH     r0,[r4,#0xe]
        0x080020fe:    8223        #.      STRH     r3,[r4,#0x10]
        0x08002100:    2205        ."      MOVS     r2,#5
        0x08002102:    5c8d        .\      LDRB     r5,[r1,r2]
        0x08002104:    429d        .B      CMP      r5,r3
        0x08002106:    d800        ..      BHI      0x800210a ; RD_TSL + 246
        0x08002108:    462b        +F      MOV      r3,r5
        0x0800210a:    1c52        R.      ADDS     r2,r2,#1
        0x0800210c:    b2d2        ..      UXTB     r2,r2
        0x0800210e:    2a7b        {*      CMP      r2,#0x7b
        0x08002110:    d3f7        ..      BCC      0x8002102 ; RD_TSL + 238
        0x08002112:    8223        #.      STRH     r3,[r4,#0x10]
        0x08002114:    18c2        ..      ADDS     r2,r0,r3
        0x08002116:    8120         .      STRH     r0,[r4,#8]
        0x08002118:    0855        U.      LSRS     r5,r2,#1
        0x0800211a:    2700        .'      MOVS     r7,#0
        0x0800211c:    8163        c.      STRH     r3,[r4,#0xa]
        0x0800211e:    7065        ep      STRB     r5,[r4,#1]
        0x08002120:    463e        >F      MOV      r6,r7
        0x08002122:    2205        ."      MOVS     r2,#5
        0x08002124:    f811c002    ....    LDRB     r12,[r1,r2]
        0x08002128:    45ac        .E      CMP      r12,r5
        0x0800212a:    d918        ..      BLS      0x800215e ; RD_TSL + 330
        0x0800212c:    eb010902    ....    ADD      r9,r1,r2
        0x08002130:    f899c001    ....    LDRB     r12,[r9,#1]
        0x08002134:    45ac        .E      CMP      r12,r5
        0x08002136:    d912        ..      BLS      0x800215e ; RD_TSL + 330
        0x08002138:    f899c002    ....    LDRB     r12,[r9,#2]
        0x0800213c:    45ac        .E      CMP      r12,r5
        0x0800213e:    d90e        ..      BLS      0x800215e ; RD_TSL + 330
        0x08002140:    f899c003    ....    LDRB     r12,[r9,#3]
        0x08002144:    45ac        .E      CMP      r12,r5
        0x08002146:    d20a        ..      BCS      0x800215e ; RD_TSL + 330
        0x08002148:    f899c004    ....    LDRB     r12,[r9,#4]
        0x0800214c:    45ac        .E      CMP      r12,r5
        0x0800214e:    d206        ..      BCS      0x800215e ; RD_TSL + 330
        0x08002150:    f899c005    ....    LDRB     r12,[r9,#5]
        0x08002154:    45ac        .E      CMP      r12,r5
        0x08002156:    d202        ..      BCS      0x800215e ; RD_TSL + 330
        0x08002158:    70a2        .p      STRB     r2,[r4,#2]
        0x0800215a:    2701        .'      MOVS     r7,#1
        0x0800215c:    e003        ..      B        0x8002166 ; RD_TSL + 338
        0x0800215e:    1c52        R.      ADDS     r2,r2,#1
        0x08002160:    b2d2        ..      UXTB     r2,r2
        0x08002162:    2a76        v*      CMP      r2,#0x76
        0x08002164:    d3de        ..      BCC      0x8002124 ; RD_TSL + 272
        0x08002166:    2276        v"      MOVS     r2,#0x76
        0x08002168:    f811c002    ....    LDRB     r12,[r1,r2]
        0x0800216c:    45ac        .E      CMP      r12,r5
        0x0800216e:    d218        ..      BCS      0x80021a2 ; RD_TSL + 398
        0x08002170:    eb010c02    ....    ADD      r12,r1,r2
        0x08002174:    f89c8001    ....    LDRB     r8,[r12,#1]
        0x08002178:    45a8        .E      CMP      r8,r5
        0x0800217a:    d212        ..      BCS      0x80021a2 ; RD_TSL + 398
        0x0800217c:    f89c8002    ....    LDRB     r8,[r12,#2]
        0x08002180:    45a8        .E      CMP      r8,r5
        0x08002182:    d20e        ..      BCS      0x80021a2 ; RD_TSL + 398
        0x08002184:    f89c8003    ....    LDRB     r8,[r12,#3]
        0x08002188:    45a8        .E      CMP      r8,r5
        0x0800218a:    d90a        ..      BLS      0x80021a2 ; RD_TSL + 398
        0x0800218c:    f89c8004    ....    LDRB     r8,[r12,#4]
        0x08002190:    45a8        .E      CMP      r8,r5
        0x08002192:    d906        ..      BLS      0x80021a2 ; RD_TSL + 398
        0x08002194:    f89cc005    ....    LDRB     r12,[r12,#5]
        0x08002198:    45ac        .E      CMP      r12,r5
        0x0800219a:    d902        ..      BLS      0x80021a2 ; RD_TSL + 398
        0x0800219c:    70e2        .p      STRB     r2,[r4,#3]
        0x0800219e:    2601        .&      MOVS     r6,#1
        0x080021a0:    e003        ..      B        0x80021aa ; RD_TSL + 406
        0x080021a2:    1e52        R.      SUBS     r2,r2,#1
        0x080021a4:    b2d2        ..      UXTB     r2,r2
        0x080021a6:    2a05        .*      CMP      r2,#5
        0x080021a8:    d8de        ..      BHI      0x8002168 ; RD_TSL + 340
        0x080021aa:    b15f        _.      CBZ      r7,0x80021c4 ; RD_TSL + 432
        0x080021ac:    b156        V.      CBZ      r6,0x80021c4 ; RD_TSL + 432
        0x080021ae:    1ac0        ..      SUBS     r0,r0,r3
        0x080021b0:    b280        ..      UXTH     r0,r0
        0x080021b2:    2814        .(      CMP      r0,#0x14
        0x080021b4:    d306        ..      BCC      0x80021c4 ; RD_TSL + 432
        0x080021b6:    78e0        .x      LDRB     r0,[r4,#3]
        0x080021b8:    78a1        .x      LDRB     r1,[r4,#2]
        0x080021ba:    4408        .D      ADD      r0,r0,r1
        0x080021bc:    0840        @.      LSRS     r0,r0,#1
        0x080021be:    7020         p      STRB     r0,[r4,#0]
        0x080021c0:    2000        .       MOVS     r0,#0
        0x080021c2:    e000        ..      B        0x80021c6 ; RD_TSL + 434
        0x080021c4:    2001        .       MOVS     r0,#1
        0x080021c6:    7120         q      STRB     r0,[r4,#4]
        0x080021c8:    7820         x      LDRB     r0,[r4,#0]
        0x080021ca:    79a1        .y      LDRB     r1,[r4,#6]
        0x080021cc:    1a40        @.      SUBS     r0,r0,r1
        0x080021ce:    f000fcb3    ....    BL       myabs ; 0x8002b38
        0x080021d2:    2846        F(      CMP      r0,#0x46
        0x080021d4:    dd01        ..      BLE      0x80021da ; RD_TSL + 454
        0x080021d6:    79a0        .y      LDRB     r0,[r4,#6]
        0x080021d8:    7020         p      STRB     r0,[r4,#0]
        0x080021da:    7820         x      LDRB     r0,[r4,#0]
        0x080021dc:    71a0        .q      STRB     r0,[r4,#6]
        0x080021de:    e8bd87f0    ....    POP      {r4-r10,pc}
    $d
        0x080021e2:    0000        ..      DCW    0
        0x080021e4:    40010c00    ...@    DCD    1073810432
        0x080021e8:    20000000    ...     DCD    536870912
        0x080021ec:    200000b0    ...     DCD    536871088
        0x080021f0:    20000388    ...     DCD    536871816
    $t
    i.SVC_Handler
    SVC_Handler
        0x080021f4:    4770        pG      BX       lr
    i.SysTick_Handler
    SysTick_Handler
        0x080021f6:    f7febd35    ..5.    B        HAL_IncTick ; 0x8000c64
    i.SystemClock_Config
    SystemClock_Config
        0x080021fa:    b530        0.      PUSH     {r4,r5,lr}
        0x080021fc:    b093        ..      SUB      sp,sp,#0x4c
        0x080021fe:    2128        (!      MOVS     r1,#0x28
        0x08002200:    4668        hF      MOV      r0,sp
        0x08002202:    f7fdffa6    ....    BL       __aeabi_memclr ; 0x8000152
        0x08002206:    2114        .!      MOVS     r1,#0x14
        0x08002208:    a80a        ..      ADD      r0,sp,#0x28
        0x0800220a:    f7fdffa2    ....    BL       __aeabi_memclr ; 0x8000152
        0x0800220e:    2500        .%      MOVS     r5,#0
        0x08002210:    2001        .       MOVS     r0,#1
        0x08002212:    950f        ..      STR      r5,[sp,#0x3c]
        0x08002214:    9510        ..      STR      r5,[sp,#0x40]
        0x08002216:    9511        ..      STR      r5,[sp,#0x44]
        0x08002218:    0401        ..      LSLS     r1,r0,#16
        0x0800221a:    9512        ..      STR      r5,[sp,#0x48]
        0x0800221c:    e88d0023    ..#.    STM      sp,{r0,r1,r5}
        0x08002220:    9004        ..      STR      r0,[sp,#0x10]
        0x08002222:    f44f10e0    O...    MOV      r0,#0x1c0000
        0x08002226:    e9cd1008    ....    STRD     r1,r0,[sp,#0x20]
        0x0800222a:    2402        .$      MOVS     r4,#2
        0x0800222c:    9407        ..      STR      r4,[sp,#0x1c]
        0x0800222e:    4668        hF      MOV      r0,sp
        0x08002230:    f7feff54    ..T.    BL       HAL_RCC_OscConfig ; 0x80010dc
        0x08002234:    b108        ..      CBZ      r0,0x800223a ; SystemClock_Config + 64
        0x08002236:    b672        r.      CPSID    i
        0x08002238:    e7fe        ..      B        0x8002238 ; SystemClock_Config + 62
        0x0800223a:    a90a        ..      ADD      r1,sp,#0x28
        0x0800223c:    200f        .       MOVS     r0,#0xf
        0x0800223e:    e8810031    ..1.    STM      r1,{r0,r4,r5}
        0x08002242:    f44f6080    O..`    MOV      r0,#0x400
        0x08002246:    e9cd050d    ....    STRD     r0,r5,[sp,#0x34]
        0x0800224a:    2102        .!      MOVS     r1,#2
        0x0800224c:    a80a        ..      ADD      r0,sp,#0x28
        0x0800224e:    f7fefe69    ..i.    BL       HAL_RCC_ClockConfig ; 0x8000f24
        0x08002252:    b108        ..      CBZ      r0,0x8002258 ; SystemClock_Config + 94
        0x08002254:    b672        r.      CPSID    i
        0x08002256:    e7fe        ..      B        0x8002256 ; SystemClock_Config + 92
        0x08002258:    f44f4000    O..@    MOV      r0,#0x8000
        0x0800225c:    9011        ..      STR      r0,[sp,#0x44]
        0x0800225e:    940f        ..      STR      r4,[sp,#0x3c]
        0x08002260:    a80f        ..      ADD      r0,sp,#0x3c
        0x08002262:    f7fefde9    ....    BL       HAL_RCCEx_PeriphCLKConfig ; 0x8000e38
        0x08002266:    2800        .(      CMP      r0,#0
        0x08002268:    d001        ..      BEQ      0x800226e ; SystemClock_Config + 116
        0x0800226a:    b672        r.      CPSID    i
        0x0800226c:    e7fe        ..      B        0x800226c ; SystemClock_Config + 114
        0x0800226e:    b013        ..      ADD      sp,sp,#0x4c
        0x08002270:    bd30        0.      POP      {r4,r5,pc}
    i.SystemInit
    SystemInit
        0x08002272:    4770        pG      BX       lr
    i.TIM3_IRQHandler
    TIM3_IRQHandler
        0x08002274:    4801        .H      LDR      r0,[pc,#4] ; [0x800227c] = 0x200003b8
        0x08002276:    f7ffb9f2    ....    B        HAL_TIM_IRQHandler ; 0x800165e
    $d
        0x0800227a:    0000        ..      DCW    0
        0x0800227c:    200003b8    ...     DCD    536871864
    $t
    i.TIM_Base_SetConfig
    TIM_Base_SetConfig
        0x08002280:    b5f0        ..      PUSH     {r4-r7,lr}
        0x08002282:    6802        .h      LDR      r2,[r0,#0]
        0x08002284:    4b19        .K      LDR      r3,[pc,#100] ; [0x80022ec] = 0x40012c00
        0x08002286:    4c1a        .L      LDR      r4,[pc,#104] ; [0x80022f0] = 0x40000400
        0x08002288:    4d1a        .M      LDR      r5,[pc,#104] ; [0x80022f4] = 0x40000800
        0x0800228a:    f04f4780    O..G    MOV      r7,#0x40000000
        0x0800228e:    4298        .B      CMP      r0,r3
        0x08002290:    d005        ..      BEQ      0x800229e ; TIM_Base_SetConfig + 30
        0x08002292:    42b8        .B      CMP      r0,r7
        0x08002294:    d003        ..      BEQ      0x800229e ; TIM_Base_SetConfig + 30
        0x08002296:    42a0        .B      CMP      r0,r4
        0x08002298:    d001        ..      BEQ      0x800229e ; TIM_Base_SetConfig + 30
        0x0800229a:    42a8        .B      CMP      r0,r5
        0x0800229c:    d103        ..      BNE      0x80022a6 ; TIM_Base_SetConfig + 38
        0x0800229e:    f0220670    ".p.    BIC      r6,r2,#0x70
        0x080022a2:    684a        Jh      LDR      r2,[r1,#4]
        0x080022a4:    4332        2C      ORRS     r2,r2,r6
        0x080022a6:    4298        .B      CMP      r0,r3
        0x080022a8:    d005        ..      BEQ      0x80022b6 ; TIM_Base_SetConfig + 54
        0x080022aa:    42b8        .B      CMP      r0,r7
        0x080022ac:    d003        ..      BEQ      0x80022b6 ; TIM_Base_SetConfig + 54
        0x080022ae:    42a0        .B      CMP      r0,r4
        0x080022b0:    d001        ..      BEQ      0x80022b6 ; TIM_Base_SetConfig + 54
        0x080022b2:    42a8        .B      CMP      r0,r5
        0x080022b4:    d103        ..      BNE      0x80022be ; TIM_Base_SetConfig + 62
        0x080022b6:    f4227440    ".@t    BIC      r4,r2,#0x300
        0x080022ba:    68ca        .h      LDR      r2,[r1,#0xc]
        0x080022bc:    4322        "C      ORRS     r2,r2,r4
        0x080022be:    694c        Li      LDR      r4,[r1,#0x14]
        0x080022c0:    f0220280    "...    BIC      r2,r2,#0x80
        0x080022c4:    4322        "C      ORRS     r2,r2,r4
        0x080022c6:    6002        .`      STR      r2,[r0,#0]
        0x080022c8:    688a        .h      LDR      r2,[r1,#8]
        0x080022ca:    62c2        .b      STR      r2,[r0,#0x2c]
        0x080022cc:    680a        .h      LDR      r2,[r1,#0]
        0x080022ce:    6282        .b      STR      r2,[r0,#0x28]
        0x080022d0:    4298        .B      CMP      r0,r3
        0x080022d2:    d101        ..      BNE      0x80022d8 ; TIM_Base_SetConfig + 88
        0x080022d4:    6909        .i      LDR      r1,[r1,#0x10]
        0x080022d6:    6301        .c      STR      r1,[r0,#0x30]
        0x080022d8:    2101        .!      MOVS     r1,#1
        0x080022da:    6141        Aa      STR      r1,[r0,#0x14]
        0x080022dc:    6901        .i      LDR      r1,[r0,#0x10]
        0x080022de:    07c9        ..      LSLS     r1,r1,#31
        0x080022e0:    d003        ..      BEQ      0x80022ea ; TIM_Base_SetConfig + 106
        0x080022e2:    6901        .i      LDR      r1,[r0,#0x10]
        0x080022e4:    f0210101    !...    BIC      r1,r1,#1
        0x080022e8:    6101        .a      STR      r1,[r0,#0x10]
        0x080022ea:    bdf0        ..      POP      {r4-r7,pc}
    $d
        0x080022ec:    40012c00    .,.@    DCD    1073818624
        0x080022f0:    40000400    ...@    DCD    1073742848
        0x080022f4:    40000800    ...@    DCD    1073743872
    $t
    i.TIM_ETR_SetConfig
    TIM_ETR_SetConfig
        0x080022f8:    b510        ..      PUSH     {r4,lr}
        0x080022fa:    6884        .h      LDR      r4,[r0,#8]
        0x080022fc:    ea422203    B.."    ORR      r2,r2,r3,LSL #8
        0x08002300:    f424447f    $..D    BIC      r4,r4,#0xff00
        0x08002304:    430a        .C      ORRS     r2,r2,r1
        0x08002306:    4322        "C      ORRS     r2,r2,r4
        0x08002308:    6082        .`      STR      r2,[r0,#8]
        0x0800230a:    bd10        ..      POP      {r4,pc}
    i.TIM_ITRx_SetConfig
    TIM_ITRx_SetConfig
        0x0800230c:    6882        .h      LDR      r2,[r0,#8]
        0x0800230e:    f0220270    ".p.    BIC      r2,r2,#0x70
        0x08002312:    430a        .C      ORRS     r2,r2,r1
        0x08002314:    f0420107    B...    ORR      r1,r2,#7
        0x08002318:    6081        .`      STR      r1,[r0,#8]
        0x0800231a:    4770        pG      BX       lr
    i.TIM_TI1_ConfigInputStage
    TIM_TI1_ConfigInputStage
        0x0800231c:    b510        ..      PUSH     {r4,lr}
        0x0800231e:    6a03        .j      LDR      r3,[r0,#0x20]
        0x08002320:    6a04        .j      LDR      r4,[r0,#0x20]
        0x08002322:    f0240401    $...    BIC      r4,r4,#1
        0x08002326:    6204        .b      STR      r4,[r0,#0x20]
        0x08002328:    6984        .i      LDR      r4,[r0,#0x18]
        0x0800232a:    f02404f0    $...    BIC      r4,r4,#0xf0
        0x0800232e:    ea441402    D...    ORR      r4,r4,r2,LSL #4
        0x08002332:    f023020a    #...    BIC      r2,r3,#0xa
        0x08002336:    430a        .C      ORRS     r2,r2,r1
        0x08002338:    6184        .a      STR      r4,[r0,#0x18]
        0x0800233a:    6202        .b      STR      r2,[r0,#0x20]
        0x0800233c:    bd10        ..      POP      {r4,pc}
    i.TIM_TI2_ConfigInputStage
    TIM_TI2_ConfigInputStage
        0x0800233e:    b510        ..      PUSH     {r4,lr}
        0x08002340:    6a03        .j      LDR      r3,[r0,#0x20]
        0x08002342:    6a04        .j      LDR      r4,[r0,#0x20]
        0x08002344:    f0240410    $...    BIC      r4,r4,#0x10
        0x08002348:    6204        .b      STR      r4,[r0,#0x20]
        0x0800234a:    6984        .i      LDR      r4,[r0,#0x18]
        0x0800234c:    f02303a0    #...    BIC      r3,r3,#0xa0
        0x08002350:    f4244470    $.pD    BIC      r4,r4,#0xf000
        0x08002354:    ea443202    D..2    ORR      r2,r4,r2,LSL #12
        0x08002358:    ea431101    C...    ORR      r1,r3,r1,LSL #4
        0x0800235c:    6182        .a      STR      r2,[r0,#0x18]
        0x0800235e:    6201        .b      STR      r1,[r0,#0x20]
        0x08002360:    bd10        ..      POP      {r4,pc}
    i.UART_DMAAbortOnError
    UART_DMAAbortOnError
        0x08002362:    b510        ..      PUSH     {r4,lr}
        0x08002364:    6a40        @j      LDR      r0,[r0,#0x24]
        0x08002366:    2100        .!      MOVS     r1,#0
        0x08002368:    85c1        ..      STRH     r1,[r0,#0x2e]
        0x0800236a:    84c1        ..      STRH     r1,[r0,#0x26]
        0x0800236c:    f7fffa2a    ..*.    BL       HAL_UART_ErrorCallback ; 0x80017c4
        0x08002370:    bd10        ..      POP      {r4,pc}
    i.UART_EndRxTransfer
    UART_EndRxTransfer
        0x08002372:    6801        .h      LDR      r1,[r0,#0]
        0x08002374:    310c        .1      ADDS     r1,r1,#0xc
        0x08002376:    e8512f00    Q../    LDREX    r2,[r1]
        0x0800237a:    f4227290    "..r    BIC      r2,r2,#0x120
        0x0800237e:    e8412300    A..#    STREX    r3,r2,[r1]
        0x08002382:    2b00        .+      CMP      r3,#0
        0x08002384:    d1f5        ..      BNE      UART_EndRxTransfer ; 0x8002372
        0x08002386:    6801        .h      LDR      r1,[r0,#0]
        0x08002388:    3114        .1      ADDS     r1,r1,#0x14
        0x0800238a:    e8512f00    Q../    LDREX    r2,[r1]
        0x0800238e:    f0220201    "...    BIC      r2,r2,#1
        0x08002392:    e8412300    A..#    STREX    r3,r2,[r1]
        0x08002396:    2b00        .+      CMP      r3,#0
        0x08002398:    d1f5        ..      BNE      0x8002386 ; UART_EndRxTransfer + 20
        0x0800239a:    6b01        .k      LDR      r1,[r0,#0x30]
        0x0800239c:    2901        .)      CMP      r1,#1
        0x0800239e:    d109        ..      BNE      0x80023b4 ; UART_EndRxTransfer + 66
        0x080023a0:    6801        .h      LDR      r1,[r0,#0]
        0x080023a2:    310c        .1      ADDS     r1,r1,#0xc
        0x080023a4:    e8512f00    Q../    LDREX    r2,[r1]
        0x080023a8:    f0220210    "...    BIC      r2,r2,#0x10
        0x080023ac:    e8412300    A..#    STREX    r3,r2,[r1]
        0x080023b0:    2b00        .+      CMP      r3,#0
        0x080023b2:    d1f5        ..      BNE      0x80023a0 ; UART_EndRxTransfer + 46
        0x080023b4:    2120         !      MOVS     r1,#0x20
        0x080023b6:    f8801042    ..B.    STRB     r1,[r0,#0x42]
        0x080023ba:    2100        .!      MOVS     r1,#0
        0x080023bc:    6301        .c      STR      r1,[r0,#0x30]
        0x080023be:    4770        pG      BX       lr
    i.UART_Receive_IT
    UART_Receive_IT
        0x080023c0:    b508        ..      PUSH     {r3,lr}
        0x080023c2:    f8901042    ..B.    LDRB     r1,[r0,#0x42]
        0x080023c6:    2922        ")      CMP      r1,#0x22
        0x080023c8:    d001        ..      BEQ      0x80023ce ; UART_Receive_IT + 14
        0x080023ca:    2002        .       MOVS     r0,#2
        0x080023cc:    bd08        ..      POP      {r3,pc}
        0x080023ce:    6882        .h      LDR      r2,[r0,#8]
        0x080023d0:    f44f5380    O..S    MOV      r3,#0x1000
        0x080023d4:    429a        .B      CMP      r2,r3
        0x080023d6:    d101        ..      BNE      0x80023dc ; UART_Receive_IT + 28
        0x080023d8:    6901        .i      LDR      r1,[r0,#0x10]
        0x080023da:    b121        !.      CBZ      r1,0x80023e6 ; UART_Receive_IT + 38
        0x080023dc:    6a81        .j      LDR      r1,[r0,#0x28]
        0x080023de:    429a        .B      CMP      r2,r3
        0x080023e0:    d01b        ..      BEQ      0x800241a ; UART_Receive_IT + 90
        0x080023e2:    b14a        J.      CBZ      r2,0x80023f8 ; UART_Receive_IT + 56
        0x080023e4:    e00a        ..      B        0x80023fc ; UART_Receive_IT + 60
        0x080023e6:    6802        .h      LDR      r2,[r0,#0]
        0x080023e8:    6a81        .j      LDR      r1,[r0,#0x28]
        0x080023ea:    6852        Rh      LDR      r2,[r2,#4]
        0x080023ec:    f3c20208    ....    UBFX     r2,r2,#0,#9
        0x080023f0:    800a        ..      STRH     r2,[r1,#0]
        0x080023f2:    6a81        .j      LDR      r1,[r0,#0x28]
        0x080023f4:    1c89        ..      ADDS     r1,r1,#2
        0x080023f6:    e008        ..      B        0x800240a ; UART_Receive_IT + 74
        0x080023f8:    6902        .i      LDR      r2,[r0,#0x10]
        0x080023fa:    b172        r.      CBZ      r2,0x800241a ; UART_Receive_IT + 90
        0x080023fc:    6802        .h      LDR      r2,[r0,#0]
        0x080023fe:    6852        Rh      LDR      r2,[r2,#4]
        0x08002400:    f002027f    ....    AND      r2,r2,#0x7f
        0x08002404:    700a        .p      STRB     r2,[r1,#0]
        0x08002406:    6a81        .j      LDR      r1,[r0,#0x28]
        0x08002408:    1c49        I.      ADDS     r1,r1,#1
        0x0800240a:    6281        .b      STR      r1,[r0,#0x28]
        0x0800240c:    8dc1        ..      LDRH     r1,[r0,#0x2e]
        0x0800240e:    1e49        I.      SUBS     r1,r1,#1
        0x08002410:    0409        ..      LSLS     r1,r1,#16
        0x08002412:    0c09        ..      LSRS     r1,r1,#16
        0x08002414:    85c1        ..      STRH     r1,[r0,#0x2e]
        0x08002416:    d003        ..      BEQ      0x8002420 ; UART_Receive_IT + 96
        0x08002418:    e01b        ..      B        0x8002452 ; UART_Receive_IT + 146
        0x0800241a:    6802        .h      LDR      r2,[r0,#0]
        0x0800241c:    6852        Rh      LDR      r2,[r2,#4]
        0x0800241e:    e7f1        ..      B        0x8002404 ; UART_Receive_IT + 68
        0x08002420:    6801        .h      LDR      r1,[r0,#0]
        0x08002422:    68ca        .h      LDR      r2,[r1,#0xc]
        0x08002424:    f0220220    ". .    BIC      r2,r2,#0x20
        0x08002428:    60ca        .`      STR      r2,[r1,#0xc]
        0x0800242a:    6801        .h      LDR      r1,[r0,#0]
        0x0800242c:    68ca        .h      LDR      r2,[r1,#0xc]
        0x0800242e:    f4227280    "..r    BIC      r2,r2,#0x100
        0x08002432:    60ca        .`      STR      r2,[r1,#0xc]
        0x08002434:    6801        .h      LDR      r1,[r0,#0]
        0x08002436:    694a        Ji      LDR      r2,[r1,#0x14]
        0x08002438:    f0220201    "...    BIC      r2,r2,#1
        0x0800243c:    614a        Ja      STR      r2,[r1,#0x14]
        0x0800243e:    2120         !      MOVS     r1,#0x20
        0x08002440:    f8801042    ..B.    STRB     r1,[r0,#0x42]
        0x08002444:    2100        .!      MOVS     r1,#0
        0x08002446:    6341        Ac      STR      r1,[r0,#0x34]
        0x08002448:    6b02        .k      LDR      r2,[r0,#0x30]
        0x0800244a:    2a01        .*      CMP      r2,#1
        0x0800244c:    d003        ..      BEQ      0x8002456 ; UART_Receive_IT + 150
        0x0800244e:    f7fffb63    ..c.    BL       HAL_UART_RxCpltCallback ; 0x8001b18
        0x08002452:    2000        .       MOVS     r0,#0
        0x08002454:    bd08        ..      POP      {r3,pc}
        0x08002456:    6301        .c      STR      r1,[r0,#0x30]
        0x08002458:    6801        .h      LDR      r1,[r0,#0]
        0x0800245a:    310c        .1      ADDS     r1,r1,#0xc
        0x0800245c:    e8512f00    Q../    LDREX    r2,[r1]
        0x08002460:    f0220210    "...    BIC      r2,r2,#0x10
        0x08002464:    e8412300    A..#    STREX    r3,r2,[r1]
        0x08002468:    2b00        .+      CMP      r3,#0
        0x0800246a:    d1f5        ..      BNE      0x8002458 ; UART_Receive_IT + 152
        0x0800246c:    6801        .h      LDR      r1,[r0,#0]
        0x0800246e:    680a        .h      LDR      r2,[r1,#0]
        0x08002470:    06d2        ..      LSLS     r2,r2,#27
        0x08002472:    d502        ..      BPL      0x800247a ; UART_Receive_IT + 186
        0x08002474:    680a        .h      LDR      r2,[r1,#0]
        0x08002476:    6849        Ih      LDR      r1,[r1,#4]
        0x08002478:    9100        ..      STR      r1,[sp,#0]
        0x0800247a:    8d81        ..      LDRH     r1,[r0,#0x2c]
        0x0800247c:    f7fff9a1    ....    BL       HAL_UARTEx_RxEventCallback ; 0x80017c2
        0x08002480:    e7e7        ..      B        0x8002452 ; UART_Receive_IT + 146
        0x08002482:    0000        ..      MOVS     r0,r0
    i.UART_SetConfig
    UART_SetConfig
        0x08002484:    b570        p.      PUSH     {r4-r6,lr}
        0x08002486:    4604        .F      MOV      r4,r0
        0x08002488:    6800        .h      LDR      r0,[r0,#0]
        0x0800248a:    6901        .i      LDR      r1,[r0,#0x10]
        0x0800248c:    68e2        .h      LDR      r2,[r4,#0xc]
        0x0800248e:    f4215140    !.@Q    BIC      r1,r1,#0x3000
        0x08002492:    4311        .C      ORRS     r1,r1,r2
        0x08002494:    6101        .a      STR      r1,[r0,#0x10]
        0x08002496:    6921        !i      LDR      r1,[r4,#0x10]
        0x08002498:    68a0        .h      LDR      r0,[r4,#8]
        0x0800249a:    4308        .C      ORRS     r0,r0,r1
        0x0800249c:    6961        ai      LDR      r1,[r4,#0x14]
        0x0800249e:    4308        .C      ORRS     r0,r0,r1
        0x080024a0:    6821        !h      LDR      r1,[r4,#0]
        0x080024a2:    68ca        .h      LDR      r2,[r1,#0xc]
        0x080024a4:    f241630c    A..c    MOV      r3,#0x160c
        0x080024a8:    439a        .C      BICS     r2,r2,r3
        0x080024aa:    4302        .C      ORRS     r2,r2,r0
        0x080024ac:    60ca        .`      STR      r2,[r1,#0xc]
        0x080024ae:    6820         h      LDR      r0,[r4,#0]
        0x080024b0:    6941        Ai      LDR      r1,[r0,#0x14]
        0x080024b2:    69a2        .i      LDR      r2,[r4,#0x18]
        0x080024b4:    f4217140    !.@q    BIC      r1,r1,#0x300
        0x080024b8:    4311        .C      ORRS     r1,r1,r2
        0x080024ba:    6141        Aa      STR      r1,[r0,#0x14]
        0x080024bc:    491e        .I      LDR      r1,[pc,#120] ; [0x8002538] = 0x40013800
        0x080024be:    6820         h      LDR      r0,[r4,#0]
        0x080024c0:    4288        .B      CMP      r0,r1
        0x080024c2:    d102        ..      BNE      0x80024ca ; UART_SetConfig + 70
        0x080024c4:    f7fefdd4    ....    BL       HAL_RCC_GetPCLK2Freq ; 0x8001070
        0x080024c8:    e001        ..      B        0x80024ce ; UART_SetConfig + 74
        0x080024ca:    f7fefdc1    ....    BL       HAL_RCC_GetPCLK1Freq ; 0x8001050
        0x080024ce:    eb0001c0    ....    ADD      r1,r0,r0,LSL #3
        0x080024d2:    eb011200    ....    ADD      r2,r1,r0,LSL #4
        0x080024d6:    6860        `h      LDR      r0,[r4,#4]
        0x080024d8:    2164        d!      MOVS     r1,#0x64
        0x080024da:    0080        ..      LSLS     r0,r0,#2
        0x080024dc:    fbb2f3f0    ....    UDIV     r3,r2,r0
        0x080024e0:    fbb3f3f1    ....    UDIV     r3,r3,r1
        0x080024e4:    f06f0618    o...    MVN      r6,#0x18
        0x080024e8:    4373        sC      MULS     r3,r6,r3
        0x080024ea:    fbb2f5f0    ....    UDIV     r5,r2,r0
        0x080024ee:    fbb2f6f0    ....    UDIV     r6,r2,r0
        0x080024f2:    eb050583    ....    ADD      r5,r5,r3,LSL #2
        0x080024f6:    2332        2#      MOVS     r3,#0x32
        0x080024f8:    eb031505    ....    ADD      r5,r3,r5,LSL #4
        0x080024fc:    fbb5f5f1    ....    UDIV     r5,r5,r1
        0x08002500:    fbb6f6f1    ....    UDIV     r6,r6,r1
        0x08002504:    f00505f0    ....    AND      r5,r5,#0xf0
        0x08002508:    eb051506    ....    ADD      r5,r5,r6,LSL #4
        0x0800250c:    fbb2f6f0    ....    UDIV     r6,r2,r0
        0x08002510:    fbb2f0f0    ....    UDIV     r0,r2,r0
        0x08002514:    fbb0f0f1    ....    UDIV     r0,r0,r1
        0x08002518:    f06f0218    o...    MVN      r2,#0x18
        0x0800251c:    4350        PC      MULS     r0,r2,r0
        0x0800251e:    eb060080    ....    ADD      r0,r6,r0,LSL #2
        0x08002522:    eb031000    ....    ADD      r0,r3,r0,LSL #4
        0x08002526:    fbb0f0f1    ....    UDIV     r0,r0,r1
        0x0800252a:    6821        !h      LDR      r1,[r4,#0]
        0x0800252c:    f000000f    ....    AND      r0,r0,#0xf
        0x08002530:    4428        (D      ADD      r0,r0,r5
        0x08002532:    6088        .`      STR      r0,[r1,#8]
        0x08002534:    bd70        p.      POP      {r4-r6,pc}
    $d
        0x08002536:    0000        ..      DCW    0
        0x08002538:    40013800    .8.@    DCD    1073821696
    $t
    i.UART_WaitOnFlagUntilTimeout
    UART_WaitOnFlagUntilTimeout
        0x0800253c:    e92d43f8    -..C    PUSH     {r3-r9,lr}
        0x08002540:    4698        .F      MOV      r8,r3
        0x08002542:    4617        .F      MOV      r7,r2
        0x08002544:    460d        .F      MOV      r5,r1
        0x08002546:    4604        .F      MOV      r4,r0
        0x08002548:    9e08        ..      LDR      r6,[sp,#0x20]
        0x0800254a:    e024        $.      B        0x8002596 ; UART_WaitOnFlagUntilTimeout + 90
        0x0800254c:    1c70        p.      ADDS     r0,r6,#1
        0x0800254e:    d022        ".      BEQ      0x8002596 ; UART_WaitOnFlagUntilTimeout + 90
        0x08002550:    f7fefb82    ....    BL       HAL_GetTick ; 0x8000c58
        0x08002554:    eba00008    ....    SUB      r0,r0,r8
        0x08002558:    42b0        .B      CMP      r0,r6
        0x0800255a:    d81a        ..      BHI      0x8002592 ; UART_WaitOnFlagUntilTimeout + 86
        0x0800255c:    b1ce        ..      CBZ      r6,0x8002592 ; UART_WaitOnFlagUntilTimeout + 86
        0x0800255e:    6820         h      LDR      r0,[r4,#0]
        0x08002560:    68c1        .h      LDR      r1,[r0,#0xc]
        0x08002562:    0749        I.      LSLS     r1,r1,#29
        0x08002564:    d517        ..      BPL      0x8002596 ; UART_WaitOnFlagUntilTimeout + 90
        0x08002566:    2d80        .-      CMP      r5,#0x80
        0x08002568:    d015        ..      BEQ      0x8002596 ; UART_WaitOnFlagUntilTimeout + 90
        0x0800256a:    2d40        @-      CMP      r5,#0x40
        0x0800256c:    d013        ..      BEQ      0x8002596 ; UART_WaitOnFlagUntilTimeout + 90
        0x0800256e:    6801        .h      LDR      r1,[r0,#0]
        0x08002570:    43c9        .C      MVNS     r1,r1
        0x08002572:    0709        ..      LSLS     r1,r1,#28
        0x08002574:    d40f        ..      BMI      0x8002596 ; UART_WaitOnFlagUntilTimeout + 90
        0x08002576:    6801        .h      LDR      r1,[r0,#0]
        0x08002578:    2500        .%      MOVS     r5,#0
        0x0800257a:    6840        @h      LDR      r0,[r0,#4]
        0x0800257c:    9000        ..      STR      r0,[sp,#0]
        0x0800257e:    4620         F      MOV      r0,r4
        0x08002580:    f7fffef7    ....    BL       UART_EndRxTransfer ; 0x8002372
        0x08002584:    2008        .       MOVS     r0,#8
        0x08002586:    6460        `d      STR      r0,[r4,#0x44]
        0x08002588:    f8845040    ..@P    STRB     r5,[r4,#0x40]
        0x0800258c:    2001        .       MOVS     r0,#1
        0x0800258e:    e8bd83f8    ....    POP      {r3-r9,pc}
        0x08002592:    2003        .       MOVS     r0,#3
        0x08002594:    e7fb        ..      B        0x800258e ; UART_WaitOnFlagUntilTimeout + 82
        0x08002596:    6820         h      LDR      r0,[r4,#0]
        0x08002598:    6800        .h      LDR      r0,[r0,#0]
        0x0800259a:    ea350000    5...    BICS     r0,r5,r0
        0x0800259e:    d004        ..      BEQ      0x80025aa ; UART_WaitOnFlagUntilTimeout + 110
        0x080025a0:    2000        .       MOVS     r0,#0
        0x080025a2:    42b8        .B      CMP      r0,r7
        0x080025a4:    d0d2        ..      BEQ      0x800254c ; UART_WaitOnFlagUntilTimeout + 16
        0x080025a6:    2000        .       MOVS     r0,#0
        0x080025a8:    e7f1        ..      B        0x800258e ; UART_WaitOnFlagUntilTimeout + 82
        0x080025aa:    2001        .       MOVS     r0,#1
        0x080025ac:    e7f9        ..      B        0x80025a2 ; UART_WaitOnFlagUntilTimeout + 102
        0x080025ae:    0000        ..      MOVS     r0,r0
    i.USART1_IRQHandler
    USART1_IRQHandler
        0x080025b0:    4801        .H      LDR      r0,[pc,#4] ; [0x80025b8] = 0x20000400
        0x080025b2:    f7ffb909    ....    B        HAL_UART_IRQHandler ; 0x80017c8
    $d
        0x080025b6:    0000        ..      DCW    0
        0x080025b8:    20000400    ...     DCD    536871936
    $t
    i.UsageFault_Handler
    UsageFault_Handler
        0x080025bc:    e7fe        ..      B        UsageFault_Handler ; 0x80025bc
        0x080025be:    0000        ..      MOVS     r0,r0
    i.__0printf$8
    __0printf$8
    __1printf$8
    __2printf
        0x080025c0:    b40f        ..      PUSH     {r0-r3}
        0x080025c2:    4b05        .K      LDR      r3,[pc,#20] ; [0x80025d8] = 0x8002a85
        0x080025c4:    b510        ..      PUSH     {r4,lr}
        0x080025c6:    a903        ..      ADD      r1,sp,#0xc
        0x080025c8:    4a04        .J      LDR      r2,[pc,#16] ; [0x80025dc] = 0x2000002c
        0x080025ca:    9802        ..      LDR      r0,[sp,#8]
        0x080025cc:    f000f828    ..(.    BL       _printf_core ; 0x8002620
        0x080025d0:    bc10        ..      POP      {r4}
        0x080025d2:    f85dfb14    ]...    LDR      pc,[sp],#0x14
    $d
        0x080025d6:    0000        ..      DCW    0
        0x080025d8:    08002a85    .*..    DCD    134228613
        0x080025dc:    2000002c    ,..     DCD    536870956
    $t
    i.__NVIC_SetPriority
    __NVIC_SetPriority
        0x080025e0:    0709        ..      LSLS     r1,r1,#28
        0x080025e2:    0e09        ..      LSRS     r1,r1,#24
        0x080025e4:    2800        .(      CMP      r0,#0
        0x080025e6:    db04        ..      BLT      0x80025f2 ; __NVIC_SetPriority + 18
        0x080025e8:    f10020e0    ...     ADD      r0,r0,#0xe000e000
        0x080025ec:    f8801400    ....    STRB     r1,[r0,#0x400]
        0x080025f0:    4770        pG      BX       lr
        0x080025f2:    f000000f    ....    AND      r0,r0,#0xf
        0x080025f6:    f10020e0    ...     ADD      r0,r0,#0xe000e000
        0x080025fa:    f8801d14    ....    STRB     r1,[r0,#0xd14]
        0x080025fe:    4770        pG      BX       lr
    i.__scatterload_copy
    __scatterload_copy
        0x08002600:    e002        ..      B        0x8002608 ; __scatterload_copy + 8
        0x08002602:    c808        ..      LDM      r0!,{r3}
        0x08002604:    1f12        ..      SUBS     r2,r2,#4
        0x08002606:    c108        ..      STM      r1!,{r3}
        0x08002608:    2a00        .*      CMP      r2,#0
        0x0800260a:    d1fa        ..      BNE      0x8002602 ; __scatterload_copy + 2
        0x0800260c:    4770        pG      BX       lr
    i.__scatterload_null
    __scatterload_null
        0x0800260e:    4770        pG      BX       lr
    i.__scatterload_zeroinit
    __scatterload_zeroinit
        0x08002610:    2000        .       MOVS     r0,#0
        0x08002612:    e001        ..      B        0x8002618 ; __scatterload_zeroinit + 8
        0x08002614:    c101        ..      STM      r1!,{r0}
        0x08002616:    1f12        ..      SUBS     r2,r2,#4
        0x08002618:    2a00        .*      CMP      r2,#0
        0x0800261a:    d1fb        ..      BNE      0x8002614 ; __scatterload_zeroinit + 4
        0x0800261c:    4770        pG      BX       lr
        0x0800261e:    0000        ..      MOVS     r0,r0
    i._printf_core
    _printf_core
        0x08002620:    e92d4fff    -..O    PUSH     {r0-r11,lr}
        0x08002624:    b08d        ..      SUB      sp,sp,#0x34
        0x08002626:    460f        .F      MOV      r7,r1
        0x08002628:    4605        .F      MOV      r5,r0
        0x0800262a:    2600        .&      MOVS     r6,#0
        0x0800262c:    e006        ..      B        0x800263c ; _printf_core + 28
        0x0800262e:    2825        %(      CMP      r0,#0x25
        0x08002630:    d00b        ..      BEQ      0x800264a ; _printf_core + 42
        0x08002632:    e9dd120f    ....    LDRD     r1,r2,[sp,#0x3c]
        0x08002636:    4790        .G      BLX      r2
        0x08002638:    1c6d        m.      ADDS     r5,r5,#1
        0x0800263a:    1c76        v.      ADDS     r6,r6,#1
        0x0800263c:    7828        (x      LDRB     r0,[r5,#0]
        0x0800263e:    2800        .(      CMP      r0,#0
        0x08002640:    d1f5        ..      BNE      0x800262e ; _printf_core + 14
        0x08002642:    b011        ..      ADD      sp,sp,#0x44
        0x08002644:    4630        0F      MOV      r0,r6
        0x08002646:    e8bd8ff0    ....    POP      {r4-r11,pc}
        0x0800264a:    2400        .$      MOVS     r4,#0
        0x0800264c:    46a2        .F      MOV      r10,r4
        0x0800264e:    46a1        .F      MOV      r9,r4
        0x08002650:    2201        ."      MOVS     r2,#1
        0x08002652:    49ec        .I      LDR      r1,[pc,#944] ; [0x8002a04] = 0x12809
        0x08002654:    e000        ..      B        0x8002658 ; _printf_core + 56
        0x08002656:    4304        .C      ORRS     r4,r4,r0
        0x08002658:    f8153f01    ...?    LDRB     r3,[r5,#1]!
        0x0800265c:    3b20         ;      SUBS     r3,r3,#0x20
        0x0800265e:    fa02f003    ....    LSL      r0,r2,r3
        0x08002662:    4208        .B      TST      r0,r1
        0x08002664:    d1f7        ..      BNE      0x8002656 ; _printf_core + 54
        0x08002666:    7828        (x      LDRB     r0,[r5,#0]
        0x08002668:    282a        *(      CMP      r0,#0x2a
        0x0800266a:    d010        ..      BEQ      0x800268e ; _printf_core + 110
        0x0800266c:    f06f022f    o./.    MVN      r2,#0x2f
        0x08002670:    7828        (x      LDRB     r0,[r5,#0]
        0x08002672:    f1a00130    ..0.    SUB      r1,r0,#0x30
        0x08002676:    2909        .)      CMP      r1,#9
        0x08002678:    d814        ..      BHI      0x80026a4 ; _printf_core + 132
        0x0800267a:    eb0a018a    ....    ADD      r1,r10,r10,LSL #2
        0x0800267e:    eb020141    ..A.    ADD      r1,r2,r1,LSL #1
        0x08002682:    f0440402    D...    ORR      r4,r4,#2
        0x08002686:    eb000a01    ....    ADD      r10,r0,r1
        0x0800268a:    1c6d        m.      ADDS     r5,r5,#1
        0x0800268c:    e7f0        ..      B        0x8002670 ; _printf_core + 80
        0x0800268e:    cf01        ..      LDM      r7!,{r0}
        0x08002690:    ea5f0a00    _...    MOVS     r10,r0
        0x08002694:    d503        ..      BPL      0x800269e ; _printf_core + 126
        0x08002696:    f4445400    D..T    ORR      r4,r4,#0x2000
        0x0800269a:    f1ca0a00    ....    RSB      r10,r10,#0
        0x0800269e:    f0440402    D...    ORR      r4,r4,#2
        0x080026a2:    1c6d        m.      ADDS     r5,r5,#1
        0x080026a4:    7828        (x      LDRB     r0,[r5,#0]
        0x080026a6:    282e        .(      CMP      r0,#0x2e
        0x080026a8:    d117        ..      BNE      0x80026da ; _printf_core + 186
        0x080026aa:    f8150f01    ....    LDRB     r0,[r5,#1]!
        0x080026ae:    f0440404    D...    ORR      r4,r4,#4
        0x080026b2:    282a        *(      CMP      r0,#0x2a
        0x080026b4:    d00e        ..      BEQ      0x80026d4 ; _printf_core + 180
        0x080026b6:    f06f022f    o./.    MVN      r2,#0x2f
        0x080026ba:    7828        (x      LDRB     r0,[r5,#0]
        0x080026bc:    f1a00130    ..0.    SUB      r1,r0,#0x30
        0x080026c0:    2909        .)      CMP      r1,#9
        0x080026c2:    d80a        ..      BHI      0x80026da ; _printf_core + 186
        0x080026c4:    eb090189    ....    ADD      r1,r9,r9,LSL #2
        0x080026c8:    eb020141    ..A.    ADD      r1,r2,r1,LSL #1
        0x080026cc:    eb000901    ....    ADD      r9,r0,r1
        0x080026d0:    1c6d        m.      ADDS     r5,r5,#1
        0x080026d2:    e7f2        ..      B        0x80026ba ; _printf_core + 154
        0x080026d4:    f8579b04    W...    LDR      r9,[r7],#4
        0x080026d8:    1c6d        m.      ADDS     r5,r5,#1
        0x080026da:    7828        (x      LDRB     r0,[r5,#0]
        0x080026dc:    286c        l(      CMP      r0,#0x6c
        0x080026de:    d00f        ..      BEQ      0x8002700 ; _printf_core + 224
        0x080026e0:    dc06        ..      BGT      0x80026f0 ; _printf_core + 208
        0x080026e2:    284c        L(      CMP      r0,#0x4c
        0x080026e4:    d017        ..      BEQ      0x8002716 ; _printf_core + 246
        0x080026e6:    2868        h(      CMP      r0,#0x68
        0x080026e8:    d00d        ..      BEQ      0x8002706 ; _printf_core + 230
        0x080026ea:    286a        j(      CMP      r0,#0x6a
        0x080026ec:    d114        ..      BNE      0x8002718 ; _printf_core + 248
        0x080026ee:    e004        ..      B        0x80026fa ; _printf_core + 218
        0x080026f0:    2874        t(      CMP      r0,#0x74
        0x080026f2:    d010        ..      BEQ      0x8002716 ; _printf_core + 246
        0x080026f4:    287a        z(      CMP      r0,#0x7a
        0x080026f6:    d10f        ..      BNE      0x8002718 ; _printf_core + 248
        0x080026f8:    e00d        ..      B        0x8002716 ; _printf_core + 246
        0x080026fa:    f4441400    D...    ORR      r4,r4,#0x200000
        0x080026fe:    e00a        ..      B        0x8002716 ; _printf_core + 246
        0x08002700:    f4441480    D...    ORR      r4,r4,#0x100000
        0x08002704:    e001        ..      B        0x800270a ; _printf_core + 234
        0x08002706:    f4441440    D.@.    ORR      r4,r4,#0x300000
        0x0800270a:    7869        ix      LDRB     r1,[r5,#1]
        0x0800270c:    4281        .B      CMP      r1,r0
        0x0800270e:    d102        ..      BNE      0x8002716 ; _printf_core + 246
        0x08002710:    f5041480    ....    ADD      r4,r4,#0x100000
        0x08002714:    1c6d        m.      ADDS     r5,r5,#1
        0x08002716:    1c6d        m.      ADDS     r5,r5,#1
        0x08002718:    782a        *x      LDRB     r2,[r5,#0]
        0x0800271a:    2a6e        n*      CMP      r2,#0x6e
        0x0800271c:    d01f        ..      BEQ      0x800275e ; _printf_core + 318
        0x0800271e:    dc0c        ..      BGT      0x800273a ; _printf_core + 282
        0x08002720:    2a63        c*      CMP      r2,#0x63
        0x08002722:    d031        1.      BEQ      0x8002788 ; _printf_core + 360
        0x08002724:    dc04        ..      BGT      0x8002730 ; _printf_core + 272
        0x08002726:    2a00        .*      CMP      r2,#0
        0x08002728:    d08b        ..      BEQ      0x8002642 ; _printf_core + 34
        0x0800272a:    2a58        X*      CMP      r2,#0x58
        0x0800272c:    d111        ..      BNE      0x8002752 ; _printf_core + 306
        0x0800272e:    e0a3        ..      B        0x8002878 ; _printf_core + 600
        0x08002730:    2a64        d*      CMP      r2,#0x64
        0x08002732:    d068        h.      BEQ      0x8002806 ; _printf_core + 486
        0x08002734:    2a69        i*      CMP      r2,#0x69
        0x08002736:    d10c        ..      BNE      0x8002752 ; _printf_core + 306
        0x08002738:    e065        e.      B        0x8002806 ; _printf_core + 486
        0x0800273a:    2a73        s*      CMP      r2,#0x73
        0x0800273c:    d02e        ..      BEQ      0x800279c ; _printf_core + 380
        0x0800273e:    dc04        ..      BGT      0x800274a ; _printf_core + 298
        0x08002740:    2a6f        o*      CMP      r2,#0x6f
        0x08002742:    d073        s.      BEQ      0x800282c ; _printf_core + 524
        0x08002744:    2a70        p*      CMP      r2,#0x70
        0x08002746:    d104        ..      BNE      0x8002752 ; _printf_core + 306
        0x08002748:    e09b        ..      B        0x8002882 ; _printf_core + 610
        0x0800274a:    2a75        u*      CMP      r2,#0x75
        0x0800274c:    d06f        o.      BEQ      0x800282e ; _printf_core + 526
        0x0800274e:    2a78        x*      CMP      r2,#0x78
        0x08002750:    d06e        n.      BEQ      0x8002830 ; _printf_core + 528
        0x08002752:    4610        .F      MOV      r0,r2
        0x08002754:    e9dd120f    ....    LDRD     r1,r2,[sp,#0x3c]
        0x08002758:    4790        .G      BLX      r2
        0x0800275a:    1c76        v.      ADDS     r6,r6,#1
        0x0800275c:    e150        P.      B        0x8002a00 ; _printf_core + 992
        0x0800275e:    f3c45002    ...P    UBFX     r0,r4,#20,#3
        0x08002762:    2802        .(      CMP      r0,#2
        0x08002764:    d006        ..      BEQ      0x8002774 ; _printf_core + 340
        0x08002766:    2803        .(      CMP      r0,#3
        0x08002768:    d009        ..      BEQ      0x800277e ; _printf_core + 350
        0x0800276a:    2804        .(      CMP      r0,#4
        0x0800276c:    cf01        ..      LDM      r7!,{r0}
        0x0800276e:    d009        ..      BEQ      0x8002784 ; _printf_core + 356
        0x08002770:    6006        .`      STR      r6,[r0,#0]
        0x08002772:    e145        E.      B        0x8002a00 ; _printf_core + 992
        0x08002774:    cf01        ..      LDM      r7!,{r0}
        0x08002776:    17f1        ..      ASRS     r1,r6,#31
        0x08002778:    e9c06100    ...a    STRD     r6,r1,[r0,#0]
        0x0800277c:    e140        @.      B        0x8002a00 ; _printf_core + 992
        0x0800277e:    cf01        ..      LDM      r7!,{r0}
        0x08002780:    8006        ..      STRH     r6,[r0,#0]
        0x08002782:    e13d        =.      B        0x8002a00 ; _printf_core + 992
        0x08002784:    7006        .p      STRB     r6,[r0,#0]
        0x08002786:    e13b        ;.      B        0x8002a00 ; _printf_core + 992
        0x08002788:    f8170b04    ....    LDRB     r0,[r7],#4
        0x0800278c:    f88d0000    ....    STRB     r0,[sp,#0]
        0x08002790:    2000        .       MOVS     r0,#0
        0x08002792:    f88d0001    ....    STRB     r0,[sp,#1]
        0x08002796:    46eb        .F      MOV      r11,sp
        0x08002798:    2001        .       MOVS     r0,#1
        0x0800279a:    e003        ..      B        0x80027a4 ; _printf_core + 388
        0x0800279c:    f857bb04    W...    LDR      r11,[r7],#4
        0x080027a0:    f04f30ff    O..0    MOV      r0,#0xffffffff
        0x080027a4:    0761        a.      LSLS     r1,r4,#29
        0x080027a6:    f04f0100    O...    MOV      r1,#0
        0x080027aa:    d402        ..      BMI      0x80027b2 ; _printf_core + 402
        0x080027ac:    e00d        ..      B        0x80027ca ; _printf_core + 426
        0x080027ae:    f1080101    ....    ADD      r1,r8,#1
        0x080027b2:    4688        .F      MOV      r8,r1
        0x080027b4:    4549        IE      CMP      r1,r9
        0x080027b6:    da0f        ..      BGE      0x80027d8 ; _printf_core + 440
        0x080027b8:    4580        .E      CMP      r8,r0
        0x080027ba:    dbf8        ..      BLT      0x80027ae ; _printf_core + 398
        0x080027bc:    f81b1008    ....    LDRB     r1,[r11,r8]
        0x080027c0:    2900        .)      CMP      r1,#0
        0x080027c2:    d1f4        ..      BNE      0x80027ae ; _printf_core + 398
        0x080027c4:    e008        ..      B        0x80027d8 ; _printf_core + 440
        0x080027c6:    f1080101    ....    ADD      r1,r8,#1
        0x080027ca:    4688        .F      MOV      r8,r1
        0x080027cc:    4281        .B      CMP      r1,r0
        0x080027ce:    dbfa        ..      BLT      0x80027c6 ; _printf_core + 422
        0x080027d0:    f81b1008    ....    LDRB     r1,[r11,r8]
        0x080027d4:    2900        .)      CMP      r1,#0
        0x080027d6:    d1f6        ..      BNE      0x80027c6 ; _printf_core + 422
        0x080027d8:    e9dd230f    ...#    LDRD     r2,r3,[sp,#0x3c]
        0x080027dc:    ebaa0008    ....    SUB      r0,r10,r8
        0x080027e0:    4681        .F      MOV      r9,r0
        0x080027e2:    4621        !F      MOV      r1,r4
        0x080027e4:    f000f936    ..6.    BL       _printf_pre_padding ; 0x8002a54
        0x080027e8:    4430        0D      ADD      r0,r0,r6
        0x080027ea:    eb000608    ....    ADD      r6,r0,r8
        0x080027ee:    e004        ..      B        0x80027fa ; _printf_core + 474
        0x080027f0:    e9dd120f    ....    LDRD     r1,r2,[sp,#0x3c]
        0x080027f4:    f81b0b01    ....    LDRB     r0,[r11],#1
        0x080027f8:    4790        .G      BLX      r2
        0x080027fa:    f1b80801    ....    SUBS     r8,r8,#1
        0x080027fe:    d2f7        ..      BCS      0x80027f0 ; _printf_core + 464
        0x08002800:    4621        !F      MOV      r1,r4
        0x08002802:    4648        HF      MOV      r0,r9
        0x08002804:    e0f7        ..      B        0x80029f6 ; _printf_core + 982
        0x08002806:    210a        .!      MOVS     r1,#0xa
        0x08002808:    f3c45302    ...S    UBFX     r3,r4,#20,#3
        0x0800280c:    f04f0b00    O...    MOV      r11,#0
        0x08002810:    9108        ..      STR      r1,[sp,#0x20]
        0x08002812:    2b02        .+      CMP      r3,#2
        0x08002814:    d004        ..      BEQ      0x8002820 ; _printf_core + 512
        0x08002816:    cf01        ..      LDM      r7!,{r0}
        0x08002818:    17c1        ..      ASRS     r1,r0,#31
        0x0800281a:    2b03        .+      CMP      r3,#3
        0x0800281c:    d009        ..      BEQ      0x8002832 ; _printf_core + 530
        0x0800281e:    e00a        ..      B        0x8002836 ; _printf_core + 534
        0x08002820:    1dff        ..      ADDS     r7,r7,#7
        0x08002822:    f0270707    '...    BIC      r7,r7,#7
        0x08002826:    e8f70102    ....    LDRD     r0,r1,[r7],#8
        0x0800282a:    e008        ..      B        0x800283e ; _printf_core + 542
        0x0800282c:    e032        2.      B        0x8002894 ; _printf_core + 628
        0x0800282e:    e01f        ..      B        0x8002870 ; _printf_core + 592
        0x08002830:    e020         .      B        0x8002874 ; _printf_core + 596
        0x08002832:    b200        ..      SXTH     r0,r0
        0x08002834:    17c1        ..      ASRS     r1,r0,#31
        0x08002836:    2b04        .+      CMP      r3,#4
        0x08002838:    d101        ..      BNE      0x800283e ; _printf_core + 542
        0x0800283a:    b240        @.      SXTB     r0,r0
        0x0800283c:    17c1        ..      ASRS     r1,r0,#31
        0x0800283e:    1e03        ..      SUBS     r3,r0,#0
        0x08002840:    f1710300    q...    SBCS     r3,r1,#0
        0x08002844:    da07        ..      BGE      0x8002856 ; _printf_core + 566
        0x08002846:    f04f0c00    O...    MOV      r12,#0
        0x0800284a:    ebd0000c    ....    RSBS     r0,r0,r12
        0x0800284e:    eb6c0101    l...    SBC      r1,r12,r1
        0x08002852:    232d        -#      MOVS     r3,#0x2d
        0x08002854:    e002        ..      B        0x800285c ; _printf_core + 572
        0x08002856:    0523        #.      LSLS     r3,r4,#20
        0x08002858:    d504        ..      BPL      0x8002864 ; _printf_core + 580
        0x0800285a:    232b        +#      MOVS     r3,#0x2b
        0x0800285c:    f88d3024    ..$0    STRB     r3,[sp,#0x24]
        0x08002860:    2301        .#      MOVS     r3,#1
        0x08002862:    e003        ..      B        0x800286c ; _printf_core + 588
        0x08002864:    07e3        ..      LSLS     r3,r4,#31
        0x08002866:    d001        ..      BEQ      0x800286c ; _printf_core + 588
        0x08002868:    2320         #      MOVS     r3,#0x20
        0x0800286a:    e7f7        ..      B        0x800285c ; _printf_core + 572
        0x0800286c:    4698        .F      MOV      r8,r3
        0x0800286e:    e058        X.      B        0x8002922 ; _printf_core + 770
        0x08002870:    210a        .!      MOVS     r1,#0xa
        0x08002872:    e010        ..      B        0x8002896 ; _printf_core + 630
        0x08002874:    2110        .!      MOVS     r1,#0x10
        0x08002876:    e00e        ..      B        0x8002896 ; _printf_core + 630
        0x08002878:    2010        .       MOVS     r0,#0x10
        0x0800287a:    f04f0b00    O...    MOV      r11,#0
        0x0800287e:    9008        ..      STR      r0,[sp,#0x20]
        0x08002880:    e00c        ..      B        0x800289c ; _printf_core + 636
        0x08002882:    2110        .!      MOVS     r1,#0x10
        0x08002884:    f04f0b00    O...    MOV      r11,#0
        0x08002888:    f0440404    D...    ORR      r4,r4,#4
        0x0800288c:    f04f0908    O...    MOV      r9,#8
        0x08002890:    9108        ..      STR      r1,[sp,#0x20]
        0x08002892:    e003        ..      B        0x800289c ; _printf_core + 636
        0x08002894:    2108        .!      MOVS     r1,#8
        0x08002896:    f04f0b00    O...    MOV      r11,#0
        0x0800289a:    9108        ..      STR      r1,[sp,#0x20]
        0x0800289c:    f3c45302    ...S    UBFX     r3,r4,#20,#3
        0x080028a0:    2b02        .+      CMP      r3,#2
        0x080028a2:    d004        ..      BEQ      0x80028ae ; _printf_core + 654
        0x080028a4:    cf01        ..      LDM      r7!,{r0}
        0x080028a6:    2100        .!      MOVS     r1,#0
        0x080028a8:    2b03        .+      CMP      r3,#3
        0x080028aa:    d006        ..      BEQ      0x80028ba ; _printf_core + 666
        0x080028ac:    e006        ..      B        0x80028bc ; _printf_core + 668
        0x080028ae:    1dff        ..      ADDS     r7,r7,#7
        0x080028b0:    f0270707    '...    BIC      r7,r7,#7
        0x080028b4:    e8f70102    ....    LDRD     r0,r1,[r7],#8
        0x080028b8:    e003        ..      B        0x80028c2 ; _printf_core + 674
        0x080028ba:    b280        ..      UXTH     r0,r0
        0x080028bc:    2b04        .+      CMP      r3,#4
        0x080028be:    d100        ..      BNE      0x80028c2 ; _printf_core + 674
        0x080028c0:    b2c0        ..      UXTB     r0,r0
        0x080028c2:    f04f0800    O...    MOV      r8,#0
        0x080028c6:    0723        #.      LSLS     r3,r4,#28
        0x080028c8:    d52b        +.      BPL      0x8002922 ; _printf_core + 770
        0x080028ca:    2a70        p*      CMP      r2,#0x70
        0x080028cc:    d007        ..      BEQ      0x80028de ; _printf_core + 702
        0x080028ce:    f8ddc020    .. .    LDR      r12,[sp,#0x20]
        0x080028d2:    f08c0c10    ....    EOR      r12,r12,#0x10
        0x080028d6:    ea5c0c0b    \...    ORRS     r12,r12,r11
        0x080028da:    d005        ..      BEQ      0x80028e8 ; _printf_core + 712
        0x080028dc:    e00e        ..      B        0x80028fc ; _printf_core + 732
        0x080028de:    2340        @#      MOVS     r3,#0x40
        0x080028e0:    f88d3024    ..$0    STRB     r3,[sp,#0x24]
        0x080028e4:    2301        .#      MOVS     r3,#1
        0x080028e6:    e008        ..      B        0x80028fa ; _printf_core + 730
        0x080028e8:    ea500301    P...    ORRS     r3,r0,r1
        0x080028ec:    d006        ..      BEQ      0x80028fc ; _printf_core + 732
        0x080028ee:    2330        0#      MOVS     r3,#0x30
        0x080028f0:    f88d3024    ..$0    STRB     r3,[sp,#0x24]
        0x080028f4:    f88d2025    ..%     STRB     r2,[sp,#0x25]
        0x080028f8:    2302        .#      MOVS     r3,#2
        0x080028fa:    4698        .F      MOV      r8,r3
        0x080028fc:    f8ddc020    .. .    LDR      r12,[sp,#0x20]
        0x08002900:    f08c0c08    ....    EOR      r12,r12,#8
        0x08002904:    ea5c0c0b    \...    ORRS     r12,r12,r11
        0x08002908:    d10b        ..      BNE      0x8002922 ; _printf_core + 770
        0x0800290a:    ea500301    P...    ORRS     r3,r0,r1
        0x0800290e:    d101        ..      BNE      0x8002914 ; _printf_core + 756
        0x08002910:    0763        c.      LSLS     r3,r4,#29
        0x08002912:    d506        ..      BPL      0x8002922 ; _printf_core + 770
        0x08002914:    2330        0#      MOVS     r3,#0x30
        0x08002916:    f88d3024    ..$0    STRB     r3,[sp,#0x24]
        0x0800291a:    f04f0801    O...    MOV      r8,#1
        0x0800291e:    f1a90901    ....    SUB      r9,r9,#1
        0x08002922:    2a58        X*      CMP      r2,#0x58
        0x08002924:    d004        ..      BEQ      0x8002930 ; _printf_core + 784
        0x08002926:    a238        8.      ADR      r2,{pc}+0xe2 ; 0x8002a08
        0x08002928:    920b        ..      STR      r2,[sp,#0x2c]
        0x0800292a:    aa08        ..      ADD      r2,sp,#0x20
        0x0800292c:    920a        ..      STR      r2,[sp,#0x28]
        0x0800292e:    e00b        ..      B        0x8002948 ; _printf_core + 808
        0x08002930:    a23a        :.      ADR      r2,{pc}+0xec ; 0x8002a1c
        0x08002932:    e7f9        ..      B        0x8002928 ; _printf_core + 776
        0x08002934:    465b        [F      MOV      r3,r11
        0x08002936:    9a08        ..      LDR      r2,[sp,#0x20]
        0x08002938:    f7fdfc16    ....    BL       __aeabi_uldivmod ; 0x8000168
        0x0800293c:    9b0b        ..      LDR      r3,[sp,#0x2c]
        0x0800293e:    5c9b        .\      LDRB     r3,[r3,r2]
        0x08002940:    9a0a        ..      LDR      r2,[sp,#0x28]
        0x08002942:    1e52        R.      SUBS     r2,r2,#1
        0x08002944:    920a        ..      STR      r2,[sp,#0x28]
        0x08002946:    7013        .p      STRB     r3,[r2,#0]
        0x08002948:    ea500201    P...    ORRS     r2,r0,r1
        0x0800294c:    d1f2        ..      BNE      0x8002934 ; _printf_core + 788
        0x0800294e:    980a        ..      LDR      r0,[sp,#0x28]
        0x08002950:    ebad0000    ....    SUB      r0,sp,r0
        0x08002954:    f1000b20    .. .    ADD      r11,r0,#0x20
        0x08002958:    0760        `.      LSLS     r0,r4,#29
        0x0800295a:    d502        ..      BPL      0x8002962 ; _printf_core + 834
        0x0800295c:    f4243480    $..4    BIC      r4,r4,#0x10000
        0x08002960:    e001        ..      B        0x8002966 ; _printf_core + 838
        0x08002962:    f04f0901    O...    MOV      r9,#1
        0x08002966:    45d9        .E      CMP      r9,r11
        0x08002968:    dd02        ..      BLE      0x8002970 ; _printf_core + 848
        0x0800296a:    eba9000b    ....    SUB      r0,r9,r11
        0x0800296e:    e000        ..      B        0x8002972 ; _printf_core + 850
        0x08002970:    2000        .       MOVS     r0,#0
        0x08002972:    eb00010b    ....    ADD      r1,r0,r11
        0x08002976:    4441        AD      ADD      r1,r1,r8
        0x08002978:    9008        ..      STR      r0,[sp,#0x20]
        0x0800297a:    ebaa0a01    ....    SUB      r10,r10,r1
        0x0800297e:    03e0        ..      LSLS     r0,r4,#15
        0x08002980:    d406        ..      BMI      0x8002990 ; _printf_core + 880
        0x08002982:    e9dd230f    ...#    LDRD     r2,r3,[sp,#0x3c]
        0x08002986:    4621        !F      MOV      r1,r4
        0x08002988:    4650        PF      MOV      r0,r10
        0x0800298a:    f000f863    ..c.    BL       _printf_pre_padding ; 0x8002a54
        0x0800298e:    4406        .D      ADD      r6,r6,r0
        0x08002990:    f04f0900    O...    MOV      r9,#0
        0x08002994:    e008        ..      B        0x80029a8 ; _printf_core + 904
        0x08002996:    a909        ..      ADD      r1,sp,#0x24
        0x08002998:    f8110009    ....    LDRB     r0,[r1,r9]
        0x0800299c:    e9dd120f    ....    LDRD     r1,r2,[sp,#0x3c]
        0x080029a0:    4790        .G      BLX      r2
        0x080029a2:    f1090901    ....    ADD      r9,r9,#1
        0x080029a6:    1c76        v.      ADDS     r6,r6,#1
        0x080029a8:    45c1        .E      CMP      r9,r8
        0x080029aa:    dbf4        ..      BLT      0x8002996 ; _printf_core + 886
        0x080029ac:    03e0        ..      LSLS     r0,r4,#15
        0x080029ae:    d50c        ..      BPL      0x80029ca ; _printf_core + 938
        0x080029b0:    e9dd230f    ...#    LDRD     r2,r3,[sp,#0x3c]
        0x080029b4:    4621        !F      MOV      r1,r4
        0x080029b6:    4650        PF      MOV      r0,r10
        0x080029b8:    f000f84c    ..L.    BL       _printf_pre_padding ; 0x8002a54
        0x080029bc:    4406        .D      ADD      r6,r6,r0
        0x080029be:    e004        ..      B        0x80029ca ; _printf_core + 938
        0x080029c0:    e9dd120f    ....    LDRD     r1,r2,[sp,#0x3c]
        0x080029c4:    2030        0       MOVS     r0,#0x30
        0x080029c6:    4790        .G      BLX      r2
        0x080029c8:    1c76        v.      ADDS     r6,r6,#1
        0x080029ca:    9908        ..      LDR      r1,[sp,#0x20]
        0x080029cc:    1e48        H.      SUBS     r0,r1,#1
        0x080029ce:    9008        ..      STR      r0,[sp,#0x20]
        0x080029d0:    2900        .)      CMP      r1,#0
        0x080029d2:    dcf5        ..      BGT      0x80029c0 ; _printf_core + 928
        0x080029d4:    e008        ..      B        0x80029e8 ; _printf_core + 968
        0x080029d6:    980a        ..      LDR      r0,[sp,#0x28]
        0x080029d8:    990a        ..      LDR      r1,[sp,#0x28]
        0x080029da:    7800        .x      LDRB     r0,[r0,#0]
        0x080029dc:    1c49        I.      ADDS     r1,r1,#1
        0x080029de:    910a        ..      STR      r1,[sp,#0x28]
        0x080029e0:    e9dd120f    ....    LDRD     r1,r2,[sp,#0x3c]
        0x080029e4:    4790        .G      BLX      r2
        0x080029e6:    1c76        v.      ADDS     r6,r6,#1
        0x080029e8:    f1bb0100    ....    SUBS     r1,r11,#0
        0x080029ec:    f1ab0b01    ....    SUB      r11,r11,#1
        0x080029f0:    dcf1        ..      BGT      0x80029d6 ; _printf_core + 950
        0x080029f2:    4621        !F      MOV      r1,r4
        0x080029f4:    4650        PF      MOV      r0,r10
        0x080029f6:    e9dd230f    ...#    LDRD     r2,r3,[sp,#0x3c]
        0x080029fa:    f000f819    ....    BL       _printf_post_padding ; 0x8002a30
        0x080029fe:    4406        .D      ADD      r6,r6,r0
        0x08002a00:    1c6d        m.      ADDS     r5,r5,#1
        0x08002a02:    e61b        ..      B        0x800263c ; _printf_core + 28
    $d
        0x08002a04:    00012809    .(..    DCD    75785
        0x08002a08:    33323130    0123    DCD    858927408
        0x08002a0c:    37363534    4567    DCD    926299444
        0x08002a10:    62613938    89ab    DCD    1650538808
        0x08002a14:    66656463    cdef    DCD    1717920867
        0x08002a18:    00000000    ....    DCD    0
        0x08002a1c:    33323130    0123    DCD    858927408
        0x08002a20:    37363534    4567    DCD    926299444
        0x08002a24:    42413938    89AB    DCD    1111570744
        0x08002a28:    46454443    CDEF    DCD    1178944579
        0x08002a2c:    00000000    ....    DCD    0
    $t
    i._printf_post_padding
    _printf_post_padding
        0x08002a30:    e92d41f0    -..A    PUSH     {r4-r8,lr}
        0x08002a34:    4604        .F      MOV      r4,r0
        0x08002a36:    2500        .%      MOVS     r5,#0
        0x08002a38:    461e        .F      MOV      r6,r3
        0x08002a3a:    4617        .F      MOV      r7,r2
        0x08002a3c:    0488        ..      LSLS     r0,r1,#18
        0x08002a3e:    d404        ..      BMI      0x8002a4a ; _printf_post_padding + 26
        0x08002a40:    e005        ..      B        0x8002a4e ; _printf_post_padding + 30
        0x08002a42:    4639        9F      MOV      r1,r7
        0x08002a44:    2020                MOVS     r0,#0x20
        0x08002a46:    47b0        .G      BLX      r6
        0x08002a48:    1c6d        m.      ADDS     r5,r5,#1
        0x08002a4a:    1e64        d.      SUBS     r4,r4,#1
        0x08002a4c:    d5f9        ..      BPL      0x8002a42 ; _printf_post_padding + 18
        0x08002a4e:    4628        (F      MOV      r0,r5
        0x08002a50:    e8bd81f0    ....    POP      {r4-r8,pc}
    i._printf_pre_padding
    _printf_pre_padding
        0x08002a54:    e92d41f0    -..A    PUSH     {r4-r8,lr}
        0x08002a58:    4604        .F      MOV      r4,r0
        0x08002a5a:    2500        .%      MOVS     r5,#0
        0x08002a5c:    461e        .F      MOV      r6,r3
        0x08002a5e:    4690        .F      MOV      r8,r2
        0x08002a60:    03c8        ..      LSLS     r0,r1,#15
        0x08002a62:    d501        ..      BPL      0x8002a68 ; _printf_pre_padding + 20
        0x08002a64:    2730        0'      MOVS     r7,#0x30
        0x08002a66:    e000        ..      B        0x8002a6a ; _printf_pre_padding + 22
        0x08002a68:    2720         '      MOVS     r7,#0x20
        0x08002a6a:    0488        ..      LSLS     r0,r1,#18
        0x08002a6c:    d504        ..      BPL      0x8002a78 ; _printf_pre_padding + 36
        0x08002a6e:    e005        ..      B        0x8002a7c ; _printf_pre_padding + 40
        0x08002a70:    4641        AF      MOV      r1,r8
        0x08002a72:    4638        8F      MOV      r0,r7
        0x08002a74:    47b0        .G      BLX      r6
        0x08002a76:    1c6d        m.      ADDS     r5,r5,#1
        0x08002a78:    1e64        d.      SUBS     r4,r4,#1
        0x08002a7a:    d5f9        ..      BPL      0x8002a70 ; _printf_pre_padding + 28
        0x08002a7c:    4628        (F      MOV      r0,r5
        0x08002a7e:    e8bd81f0    ....    POP      {r4-r8,pc}
        0x08002a82:    0000        ..      MOVS     r0,r0
    i.fputc
    fputc
        0x08002a84:    b513        ..      PUSH     {r0,r1,r4,lr}
        0x08002a86:    f64f73ff    O..s    MOV      r3,#0xffff
        0x08002a8a:    2201        ."      MOVS     r2,#1
        0x08002a8c:    4669        iF      MOV      r1,sp
        0x08002a8e:    4802        .H      LDR      r0,[pc,#8] ; [0x8002a98] = 0x20000400
        0x08002a90:    f7fff843    ..C.    BL       HAL_UART_Transmit ; 0x8001b1a
        0x08002a94:    9800        ..      LDR      r0,[sp,#0]
        0x08002a96:    bd1c        ..      POP      {r2-r4,pc}
    $d
        0x08002a98:    20000400    ...     DCD    536871936
    $t
    i.get_CCD
    get_CCD
        0x08002a9c:    f7ffbaba    ....    B        RD_TSL ; 0x8002014
    i.main
    main
        0x08002aa0:    f7fef8e8    ....    BL       HAL_Init ; 0x8000c74
        0x08002aa4:    f7fffba9    ....    BL       SystemClock_Config ; 0x80021fa
        0x08002aa8:    f7fff8b4    ....    BL       MX_GPIO_Init ; 0x8001c14
        0x08002aac:    f7fff946    ..F.    BL       MX_USART1_UART_Init ; 0x8001d3c
        0x08002ab0:    f7fff886    ....    BL       MX_ADC1_Init ; 0x8001bc0
        0x08002ab4:    f7fff90e    ....    BL       MX_TIM3_Init ; 0x8001cd4
        0x08002ab8:    4814        .H      LDR      r0,[pc,#80] ; [0x8002b0c] = 0x200003b8
        0x08002aba:    f7fefd35    ..5.    BL       HAL_TIM_Base_Start_IT ; 0x8001528
        0x08002abe:    f7fff9b1    ....    BL       OLED_Init ; 0x8001e24
        0x08002ac2:    4d13        .M      LDR      r5,[pc,#76] ; [0x8002b10] = 0x20000030
        0x08002ac4:    4e13        .N      LDR      r6,[pc,#76] ; [0x8002b14] = 0x20000008
        0x08002ac6:    4f14        .O      LDR      r7,[pc,#80] ; [0x8002b18] = 0x2000000a
        0x08002ac8:    a014        ..      ADR      r0,{pc}+0x54 ; 0x8002b1c
        0x08002aca:    f7fffd79    ..y.    BL       __0printf$8 ; 0x80025c0
        0x08002ace:    a014        ..      ADR      r0,{pc}+0x52 ; 0x8002b20
        0x08002ad0:    f7fffd76    ..v.    BL       __0printf$8 ; 0x80025c0
        0x08002ad4:    2400        .$      MOVS     r4,#0
        0x08002ad6:    a015        ..      ADR      r0,{pc}+0x56 ; 0x8002b2c
        0x08002ad8:    5d29        )]      LDRB     r1,[r5,r4]
        0x08002ada:    f7fffd71    ..q.    BL       __0printf$8 ; 0x80025c0
        0x08002ade:    1c64        d.      ADDS     r4,r4,#1
        0x08002ae0:    2c80        .,      CMP      r4,#0x80
        0x08002ae2:    dbf8        ..      BLT      0x8002ad6 ; main + 54
        0x08002ae4:    a010        ..      ADR      r0,{pc}+0x44 ; 0x8002b28
        0x08002ae6:    f7fffd6b    ..k.    BL       __0printf$8 ; 0x80025c0
        0x08002aea:    a012        ..      ADR      r0,{pc}+0x4a ; 0x8002b34
        0x08002aec:    f7fffd68    ..h.    BL       __0printf$8 ; 0x80025c0
        0x08002af0:    2101        .!      MOVS     r1,#1
        0x08002af2:    2303        .#      MOVS     r3,#3
        0x08002af4:    8832        2.      LDRH     r2,[r6,#0]
        0x08002af6:    4608        .F      MOV      r0,r1
        0x08002af8:    f7fffa36    ..6.    BL       OLED_ShowNum ; 0x8001f68
        0x08002afc:    2303        .#      MOVS     r3,#3
        0x08002afe:    883a        :.      LDRH     r2,[r7,#0]
        0x08002b00:    2101        .!      MOVS     r1,#1
        0x08002b02:    2002        .       MOVS     r0,#2
        0x08002b04:    f7fffa30    ..0.    BL       OLED_ShowNum ; 0x8001f68
        0x08002b08:    e7de        ..      B        0x8002ac8 ; main + 40
    $d
        0x08002b0a:    0000        ..      DCW    0
        0x08002b0c:    200003b8    ...     DCD    536871864
        0x08002b10:    20000030    0..     DCD    536870960
        0x08002b14:    20000008    ...     DCD    536870920
        0x08002b18:    2000000a    ...     DCD    536870922
        0x08002b1c:    0000002a    *...    DCD    42
        0x08002b20:    3030444c    LD00    DCD    808469580
        0x08002b24:    30303030    0000    DCD    808464432
        0x08002b28:    00003030    00..    DCD    12336
        0x08002b2c:    58323025    %02X    DCD    1479684133
        0x08002b30:    00000000    ....    DCD    0
        0x08002b34:    00000023    #...    DCD    35
    $t
    i.myabs
    myabs
        0x08002b38:    2800        .(      CMP      r0,#0
        0x08002b3a:    da00        ..      BGE      0x8002b3e ; myabs + 6
        0x08002b3c:    4240        @B      RSBS     r0,r0,#0
        0x08002b3e:    4770        pG      BX       lr
    $d.realdata
    .constdata
    OLED_F8x16
        0x08002b40:    00000000    ....    DCD    0
        0x08002b44:    00000000    ....    DCD    0
        0x08002b48:    00000000    ....    DCD    0
        0x08002b4c:    00000000    ....    DCD    0
        0x08002b50:    f8000000    ....    DCD    4160749568
        0x08002b54:    00000000    ....    DCD    0
        0x08002b58:    33000000    ...3    DCD    855638016
        0x08002b5c:    00000030    0...    DCD    48
        0x08002b60:    060c1000    ....    DCD    101453824
        0x08002b64:    00060c10    ....    DCD    396304
        0x08002b68:    00000000    ....    DCD    0
        0x08002b6c:    00000000    ....    DCD    0
        0x08002b70:    4078c040    @.x@    DCD    1081655360
        0x08002b74:    004078c0    .x@.    DCD    4225216
        0x08002b78:    04043f04    .?..    DCD    67387140
        0x08002b7c:    0004043f    ?...    DCD    263231
        0x08002b80:    fc887000    .p..    DCD    4236800000
        0x08002b84:    00003008    .0..    DCD    12296
        0x08002b88:    ff201800    .. .    DCD    4280293376
        0x08002b8c:    00001e21    !...    DCD    7713
        0x08002b90:    00f008f0    ....    DCD    15730928
        0x08002b94:    000018e0    ....    DCD    6368
        0x08002b98:    031c2100    .!..    DCD    52175104
        0x08002b9c:    001e211e    .!..    DCD    1974558
        0x08002ba0:    8808f000    ....    DCD    2282287104
        0x08002ba4:    00000070    p...    DCD    112
        0x08002ba8:    2423211e    .!#$    DCD    606282014
        0x08002bac:    10212719    .'!.    DCD    270608153
        0x08002bb0:    000e1610    ....    DCD    923152
        0x08002bb4:    00000000    ....    DCD    0
        0x08002bb8:    00000000    ....    DCD    0
        0x08002bbc:    00000000    ....    DCD    0
        0x08002bc0:    e0000000    ....    DCD    3758096384
        0x08002bc4:    00020418    ....    DCD    132120
        0x08002bc8:    07000000    ....    DCD    117440512
        0x08002bcc:    00402018    . @.    DCD    4202520
        0x08002bd0:    18040200    ....    DCD    402915840
        0x08002bd4:    000000e0    ....    DCD    224
        0x08002bd8:    18204000    .@ .    DCD    404766720
        0x08002bdc:    00000007    ....    DCD    7
        0x08002be0:    f0804040    @@..    DCD    4034936896
        0x08002be4:    00404080    .@@.    DCD    4210816
        0x08002be8:    0f010202    ....    DCD    251724290
        0x08002bec:    00020201    ....    DCD    131585
        0x08002bf0:    f0000000    ....    DCD    4026531840
        0x08002bf4:    00000000    ....    DCD    0
        0x08002bf8:    1f010101    ....    DCD    520159489
        0x08002bfc:    00010101    ....    DCD    65793
        0x08002c00:    00000000    ....    DCD    0
        0x08002c04:    00000000    ....    DCD    0
        0x08002c08:    0070b080    ..p.    DCD    7385216
        0x08002c0c:    00000000    ....    DCD    0
        0x08002c10:    00000000    ....    DCD    0
        0x08002c14:    00000000    ....    DCD    0
        0x08002c18:    01010100    ....    DCD    16843008
        0x08002c1c:    01010101    ....    DCD    16843009
        0x08002c20:    00000000    ....    DCD    0
        0x08002c24:    00000000    ....    DCD    0
        0x08002c28:    00303000    .00.    DCD    3158016
        0x08002c2c:    00000000    ....    DCD    0
        0x08002c30:    00000000    ....    DCD    0
        0x08002c34:    04186080    .`..    DCD    68706432
        0x08002c38:    06186000    .`..    DCD    102260736
        0x08002c3c:    00000001    ....    DCD    1
        0x08002c40:    0810e000    ....    DCD    135323648
        0x08002c44:    00e01008    ....    DCD    14684168
        0x08002c48:    20100f00    ...     DCD    537923328
        0x08002c4c:    000f1020     ...    DCD    987168
        0x08002c50:    f8101000    ....    DCD    4161802240
        0x08002c54:    00000000    ....    DCD    0
        0x08002c58:    3f202000    .  ?    DCD    1059069952
        0x08002c5c:    00002020      ..    DCD    8224
        0x08002c60:    08087000    .p..    DCD    134770688
        0x08002c64:    00708808    ..p.    DCD    7374856
        0x08002c68:    24283000    .0($    DCD    606613504
        0x08002c6c:    00302122    "!0.    DCD    3154210
        0x08002c70:    88083000    .0..    DCD    2282237952
        0x08002c74:    00304888    .H0.    DCD    3164296
        0x08002c78:    20201800    ..      DCD    538974208
        0x08002c7c:    000e1120     ...    DCD    921888
        0x08002c80:    20c00000    ...     DCD    549453824
        0x08002c84:    0000f810    ....    DCD    63504
        0x08002c88:    24040700    ...$    DCD    604243712
        0x08002c8c:    00243f24    $?$.    DCD    2375460
        0x08002c90:    8808f800    ....    DCD    2282289152
        0x08002c94:    00080888    ....    DCD    526472
        0x08002c98:    20211900    ..!     DCD    539040000
        0x08002c9c:    000e1120     ...    DCD    921888
        0x08002ca0:    8810e000    ....    DCD    2282807296
        0x08002ca4:    00001888    ....    DCD    6280
        0x08002ca8:    20110f00    ...     DCD    537988864
        0x08002cac:    000e1120     ...    DCD    921888
        0x08002cb0:    08083800    .8..    DCD    134756352
        0x08002cb4:    000838c8    .8..    DCD    538824
        0x08002cb8:    3f000000    ...?    DCD    1056964608
        0x08002cbc:    00000000    ....    DCD    0
        0x08002cc0:    08887000    .p..    DCD    143159296
        0x08002cc4:    00708808    ..p.    DCD    7374856
        0x08002cc8:    21221c00    .."!    DCD    555883520
        0x08002ccc:    001c2221    !"..    DCD    1843745
        0x08002cd0:    0810e000    ....    DCD    135323648
        0x08002cd4:    00e01008    ....    DCD    14684168
        0x08002cd8:    22310000    ..1"    DCD    573636608
        0x08002cdc:    000f1122    "...    DCD    987426
        0x08002ce0:    c0000000    ....    DCD    3221225472
        0x08002ce4:    000000c0    ....    DCD    192
        0x08002ce8:    30000000    ...0    DCD    805306368
        0x08002cec:    00000030    0...    DCD    48
        0x08002cf0:    80000000    ....    DCD    2147483648
        0x08002cf4:    00000000    ....    DCD    0
        0x08002cf8:    60800000    ...`    DCD    1619001344
        0x08002cfc:    00000000    ....    DCD    0
        0x08002d00:    40800000    ...@    DCD    1082130432
        0x08002d04:    00081020     ...    DCD    528416
        0x08002d08:    04020100    ....    DCD    67240192
        0x08002d0c:    00201008    .. .    DCD    2101256
        0x08002d10:    40404040    @@@@    DCD    1077952576
        0x08002d14:    00404040    @@@.    DCD    4210752
        0x08002d18:    04040404    ....    DCD    67372036
        0x08002d1c:    00040404    ....    DCD    263172
        0x08002d20:    20100800    ...     DCD    537921536
        0x08002d24:    00008040    @...    DCD    32832
        0x08002d28:    08102000    . ..    DCD    135274496
        0x08002d2c:    00010204    ....    DCD    66052
        0x08002d30:    08487000    .pH.    DCD    138964992
        0x08002d34:    00f00808    ....    DCD    15730696
        0x08002d38:    30000000    ...0    DCD    805306368
        0x08002d3c:    00000136    6...    DCD    310
        0x08002d40:    28c830c0    .0.(    DCD    684208320
        0x08002d44:    00e010e8    ....    DCD    14684392
        0x08002d48:    24271807    ..'$    DCD    606541831
        0x08002d4c:    000b1423    #...    DCD    726051
        0x08002d50:    38c00000    ...8    DCD    952107008
        0x08002d54:    000000e0    ....    DCD    224
        0x08002d58:    02233c20     <#.    DCD    35863584
        0x08002d5c:    20382702    .'8     DCD    540550914
        0x08002d60:    8888f808    ....    DCD    2290677768
        0x08002d64:    00007088    .p..    DCD    28808
        0x08002d68:    20203f20     ?      DCD    538984224
        0x08002d6c:    000e1120     ...    DCD    921888
        0x08002d70:    080830c0    .0..    DCD    134754496
        0x08002d74:    00380808    ..8.    DCD    3672072
        0x08002d78:    20201807    ..      DCD    538974215
        0x08002d7c:    00081020     ...    DCD    528416
        0x08002d80:    0808f808    ....    DCD    134805512
        0x08002d84:    00e01008    ....    DCD    14684168
        0x08002d88:    20203f20     ?      DCD    538984224
        0x08002d8c:    000f1020     ...    DCD    987168
        0x08002d90:    8888f808    ....    DCD    2290677768
        0x08002d94:    001008e8    ....    DCD    1050856
        0x08002d98:    20203f20     ?      DCD    538984224
        0x08002d9c:    00182023    # ..    DCD    1581091
        0x08002da0:    8888f808    ....    DCD    2290677768
        0x08002da4:    001008e8    ....    DCD    1050856
        0x08002da8:    00203f20     ? .    DCD    2113312
        0x08002dac:    00000003    ....    DCD    3
        0x08002db0:    080830c0    .0..    DCD    134754496
        0x08002db4:    00003808    .8..    DCD    14344
        0x08002db8:    20201807    ..      DCD    538974215
        0x08002dbc:    00021e22    "...    DCD    138786
        0x08002dc0:    0008f808    ....    DCD    587784
        0x08002dc4:    08f80800    ....    DCD    150472704
        0x08002dc8:    01213f20     ?!.    DCD    18956064
        0x08002dcc:    203f2101    .!?     DCD    541008129
        0x08002dd0:    f8080800    ....    DCD    4161275904
        0x08002dd4:    00000808    ....    DCD    2056
        0x08002dd8:    3f202000    .  ?    DCD    1059069952
        0x08002ddc:    00002020      ..    DCD    8224
        0x08002de0:    08080000    ....    DCD    134742016
        0x08002de4:    000808f8    ....    DCD    526584
        0x08002de8:    808080c0    ....    DCD    2155905216
        0x08002dec:    0000007f    ....    DCD    127
        0x08002df0:    c088f808    ....    DCD    3230201864
        0x08002df4:    00081828    (...    DCD    530472
        0x08002df8:    01203f20     ? .    DCD    18890528
        0x08002dfc:    00203826    &8 .    DCD    2111526
        0x08002e00:    0008f808    ....    DCD    587784
        0x08002e04:    00000000    ....    DCD    0
        0x08002e08:    20203f20     ?      DCD    538984224
        0x08002e0c:    00302020      0.    DCD    3153952
        0x08002e10:    00f8f808    ....    DCD    16316424
        0x08002e14:    0008f8f8    ....    DCD    588024
        0x08002e18:    3f003f20     ?.?    DCD    1056980768
        0x08002e1c:    00203f00    .? .    DCD    2113280
        0x08002e20:    c030f808    ..0.    DCD    3224434696
        0x08002e24:    08f80800    ....    DCD    150472704
        0x08002e28:    00203f20     ? .    DCD    2113312
        0x08002e2c:    003f1807    ..?.    DCD    4134919
        0x08002e30:    080810e0    ....    DCD    134746336
        0x08002e34:    00e01008    ....    DCD    14684168
        0x08002e38:    2020100f    ..      DCD    538972175
        0x08002e3c:    000f1020     ...    DCD    987168
        0x08002e40:    0808f808    ....    DCD    134805512
        0x08002e44:    00f00808    ....    DCD    15730696
        0x08002e48:    01213f20     ?!.    DCD    18956064
        0x08002e4c:    00000101    ....    DCD    257
        0x08002e50:    080810e0    ....    DCD    134746336
        0x08002e54:    00e01008    ....    DCD    14684168
        0x08002e58:    2424180f    ..$$    DCD    606345231
        0x08002e5c:    004f5038    8PO.    DCD    5197880
        0x08002e60:    8888f808    ....    DCD    2290677768
        0x08002e64:    00708888    ..p.    DCD    7374984
        0x08002e68:    00203f20     ? .    DCD    2113312
        0x08002e6c:    20300c03    ..0     DCD    540019715
        0x08002e70:    08887000    .p..    DCD    143159296
        0x08002e74:    00380808    ..8.    DCD    3672072
        0x08002e78:    21203800    .8 !    DCD    555759616
        0x08002e7c:    001c2221    !"..    DCD    1843745
        0x08002e80:    f8080818    ....    DCD    4161275928
        0x08002e84:    00180808    ....    DCD    1574920
        0x08002e88:    3f200000    .. ?    DCD    1059061760
        0x08002e8c:    00000020     ...    DCD    32
        0x08002e90:    0008f808    ....    DCD    587784
        0x08002e94:    08f80800    ....    DCD    150472704
        0x08002e98:    20201f00    ..      DCD    538976000
        0x08002e9c:    001f2020      ..    DCD    2039840
        0x08002ea0:    00887808    .x..    DCD    8943624
        0x08002ea4:    0838c800    ..8.    DCD    137938944
        0x08002ea8:    38070000    ...8    DCD    939982848
        0x08002eac:    0000010e    ....    DCD    270
        0x08002eb0:    f80008f8    ....    DCD    4160751864
        0x08002eb4:    00f80800    ....    DCD    16254976
        0x08002eb8:    00073c03    .<..    DCD    474115
        0x08002ebc:    00033c07    .<..    DCD    211975
        0x08002ec0:    80681808    ..h.    DCD    2154305544
        0x08002ec4:    08186880    .h..    DCD    135817344
        0x08002ec8:    032c3020     0,.    DCD    53227552
        0x08002ecc:    20302c03    .,0     DCD    540027907
        0x08002ed0:    00c83808    .8..    DCD    13121544
        0x08002ed4:    000838c8    .8..    DCD    538824
        0x08002ed8:    3f200000    .. ?    DCD    1059061760
        0x08002edc:    00000020     ...    DCD    32
        0x08002ee0:    08080810    ....    DCD    134744080
        0x08002ee4:    000838c8    .8..    DCD    538824
        0x08002ee8:    21263820     8&!    DCD    556152864
        0x08002eec:    00182020      ..    DCD    1581088
        0x08002ef0:    fe000000    ....    DCD    4261412864
        0x08002ef4:    00020202    ....    DCD    131586
        0x08002ef8:    7f000000    ....    DCD    2130706432
        0x08002efc:    00404040    @@@.    DCD    4210752
        0x08002f00:    c0300c00    ..0.    DCD    3224374272
        0x08002f04:    00000000    ....    DCD    0
        0x08002f08:    01000000    ....    DCD    16777216
        0x08002f0c:    00c03806    .8..    DCD    12597254
        0x08002f10:    02020200    ....    DCD    33686016
        0x08002f14:    000000fe    ....    DCD    254
        0x08002f18:    40404000    .@@@    DCD    1077952512
        0x08002f1c:    0000007f    ....    DCD    127
        0x08002f20:    02040000    ....    DCD    33816576
        0x08002f24:    00040202    ....    DCD    262658
        0x08002f28:    00000000    ....    DCD    0
        0x08002f2c:    00000000    ....    DCD    0
        0x08002f30:    00000000    ....    DCD    0
        0x08002f34:    00000000    ....    DCD    0
        0x08002f38:    80808080    ....    DCD    2155905152
        0x08002f3c:    80808080    ....    DCD    2155905152
        0x08002f40:    04020200    ....    DCD    67240448
        0x08002f44:    00000000    ....    DCD    0
        0x08002f48:    00000000    ....    DCD    0
        0x08002f4c:    00000000    ....    DCD    0
        0x08002f50:    80800000    ....    DCD    2155872256
        0x08002f54:    00008080    ....    DCD    32896
        0x08002f58:    22241900    ..$"    DCD    572791040
        0x08002f5c:    203f2222    ""?     DCD    541008418
        0x08002f60:    8000f808    ....    DCD    2147547144
        0x08002f64:    00000080    ....    DCD    128
        0x08002f68:    20113f00    .?.     DCD    538001152
        0x08002f6c:    000e1120     ...    DCD    921888
        0x08002f70:    80000000    ....    DCD    2147483648
        0x08002f74:    00008080    ....    DCD    32896
        0x08002f78:    20110e00    ...     DCD    537988608
        0x08002f7c:    00112020      ..    DCD    1122336
        0x08002f80:    80000000    ....    DCD    2147483648
        0x08002f84:    00f88880    ....    DCD    16287872
        0x08002f88:    20110e00    ...     DCD    537988608
        0x08002f8c:    203f1020     .?     DCD    541003808
        0x08002f90:    80800000    ....    DCD    2155872256
        0x08002f94:    00008080    ....    DCD    32896
        0x08002f98:    22221f00    ..""    DCD    572661504
        0x08002f9c:    00132222    ""..    DCD    1253922
        0x08002fa0:    f0808000    ....    DCD    4034953216
        0x08002fa4:    18888888    ....    DCD    411601032
        0x08002fa8:    3f202000    .  ?    DCD    1059069952
        0x08002fac:    00002020      ..    DCD    8224
        0x08002fb0:    80800000    ....    DCD    2155872256
        0x08002fb4:    00808080    ....    DCD    8421504
        0x08002fb8:    94946b00    .k..    DCD    2492754688
        0x08002fbc:    00609394    ..`.    DCD    6329236
        0x08002fc0:    8000f808    ....    DCD    2147547144
        0x08002fc4:    00008080    ....    DCD    32896
        0x08002fc8:    00213f20     ?!.    DCD    2178848
        0x08002fcc:    203f2000    . ?     DCD    541007872
        0x08002fd0:    98988000    ....    DCD    2560131072
        0x08002fd4:    00000000    ....    DCD    0
        0x08002fd8:    3f202000    .  ?    DCD    1059069952
        0x08002fdc:    00002020      ..    DCD    8224
        0x08002fe0:    80000000    ....    DCD    2147483648
        0x08002fe4:    00009898    ....    DCD    39064
        0x08002fe8:    8080c000    ....    DCD    2155921408
        0x08002fec:    00007f80    ....    DCD    32640
        0x08002ff0:    0000f808    ....    DCD    63496
        0x08002ff4:    00808080    ....    DCD    8421504
        0x08002ff8:    02243f20     ?$.    DCD    35929888
        0x08002ffc:    0020302d    -0 .    DCD    2109485
        0x08003000:    f8080800    ....    DCD    4161275904
        0x08003004:    00000000    ....    DCD    0
        0x08003008:    3f202000    .  ?    DCD    1059069952
        0x0800300c:    00002020      ..    DCD    8224
        0x08003010:    80808080    ....    DCD    2155905152
        0x08003014:    00808080    ....    DCD    8421504
        0x08003018:    00203f20     ? .    DCD    2113312
        0x0800301c:    3f00203f    ? .?    DCD    1056972863
        0x08003020:    80008080    ....    DCD    2147516544
        0x08003024:    00008080    ....    DCD    32896
        0x08003028:    00213f20     ?!.    DCD    2178848
        0x0800302c:    203f2000    . ?     DCD    541007872
        0x08003030:    80800000    ....    DCD    2155872256
        0x08003034:    00008080    ....    DCD    32896
        0x08003038:    20201f00    ..      DCD    538976000
        0x0800303c:    001f2020      ..    DCD    2039840
        0x08003040:    80008080    ....    DCD    2147516544
        0x08003044:    00000080    ....    DCD    128
        0x08003048:    20a1ff80    ...     DCD    547487616
        0x0800304c:    000e1120     ...    DCD    921888
        0x08003050:    80000000    ....    DCD    2147483648
        0x08003054:    00808080    ....    DCD    8421504
        0x08003058:    20110e00    ...     DCD    537988608
        0x0800305c:    80ffa020     ...    DCD    2164236320
        0x08003060:    00808080    ....    DCD    8421504
        0x08003064:    00808080    ....    DCD    8421504
        0x08003068:    213f2020      ?!    DCD    557785120
        0x0800306c:    00010020     ...    DCD    65568
        0x08003070:    80800000    ....    DCD    2155872256
        0x08003074:    00808080    ....    DCD    8421504
        0x08003078:    24243300    .3$$    DCD    606352128
        0x0800307c:    00192424    $$..    DCD    1647652
        0x08003080:    e0808000    ....    DCD    3766517760
        0x08003084:    00008080    ....    DCD    32896
        0x08003088:    1f000000    ....    DCD    520093696
        0x0800308c:    00002020      ..    DCD    8224
        0x08003090:    00008080    ....    DCD    32896
        0x08003094:    00808000    ....    DCD    8421376
        0x08003098:    20201f00    ..      DCD    538976000
        0x0800309c:    203f1020     .?     DCD    541003808
        0x080030a0:    00808080    ....    DCD    8421504
        0x080030a4:    80808000    ....    DCD    2155905024
        0x080030a8:    300e0100    ...0    DCD    806224128
        0x080030ac:    00010608    ....    DCD    67080
        0x080030b0:    80008080    ....    DCD    2147516544
        0x080030b4:    80808000    ....    DCD    2155905024
        0x080030b8:    030c300f    .0..    DCD    51130383
        0x080030bc:    000f300c    .0..    DCD    995340
        0x080030c0:    00808000    ....    DCD    8421376
        0x080030c4:    00808080    ....    DCD    8421504
        0x080030c8:    2e312000    . 1.    DCD    774971392
        0x080030cc:    0020310e    .1 .    DCD    2109710
        0x080030d0:    00808080    ....    DCD    8421504
        0x080030d4:    80808000    ....    DCD    2155905024
        0x080030d8:    708e8180    ...p    DCD    1888387456
        0x080030dc:    00010618    ....    DCD    67096
        0x080030e0:    80808000    ....    DCD    2155905024
        0x080030e4:    00808080    ....    DCD    8421504
        0x080030e8:    2c302100    .!0,    DCD    741351680
        0x080030ec:    00302122    "!0.    DCD    3154210
        0x080030f0:    00000000    ....    DCD    0
        0x080030f4:    02027c80    .|..    DCD    33717376
        0x080030f8:    00000000    ....    DCD    0
        0x080030fc:    40403f00    .?@@    DCD    1077952256
        0x08003100:    00000000    ....    DCD    0
        0x08003104:    000000ff    ....    DCD    255
        0x08003108:    00000000    ....    DCD    0
        0x0800310c:    000000ff    ....    DCD    255
        0x08003110:    7c020200    ...|    DCD    2080506368
        0x08003114:    00000080    ....    DCD    128
        0x08003118:    3f404000    .@@?    DCD    1061175296
        0x0800311c:    00000000    ....    DCD    0
        0x08003120:    01010600    ....    DCD    16844288
        0x08003124:    04040202    ....    DCD    67371522
        0x08003128:    00000000    ....    DCD    0
        0x0800312c:    00000000    ....    DCD    0
    .constdata
    aPredivFactorTable
        0x08003130:    0201        ..      DCW    513
    aPLLMULFactorTable
        0x08003132:    0302        ..      DCW    770
        0x08003134:    07060504    ....    DCD    117835012
        0x08003138:    0b0a0908    ....    DCD    185207048
        0x0800313c:    0f0e0d0c    ....    DCD    252579084
        0x08003140:    1010        ..      DCW    4112
    .constdata
    aPredivFactorTable
        0x08003142:    0201        ..      DCW    513
    aPLLMULFactorTable
        0x08003144:    05040302    ....    DCD    84148994
        0x08003148:    09080706    ....    DCD    151521030
        0x0800314c:    0d0c0b0a    ....    DCD    218893066
        0x08003150:    10100f0e    ....    DCD    269487886
    .constdata
    AHBPrescTable
        0x08003154:    00000000    ....    DCD    0
        0x08003158:    00000000    ....    DCD    0
        0x0800315c:    04030201    ....    DCD    67305985
        0x08003160:    09080706    ....    DCD    151521030
    .constdata
    APBPrescTable
        0x08003164:    00000000    ....    DCD    0
        0x08003168:    04030201    ....    DCD    67305985
    Region$$Table$$Base
        0x0800316c:    0800318c    .1..    DCD    134230412
        0x08003170:    20000000    ...     DCD    536870912
        0x08003174:    00000030    0...    DCD    48
        0x08003178:    08002600    .&..    DCD    134227456
        0x0800317c:    080031bc    .1..    DCD    134230460
        0x08003180:    20000030    0..     DCD    536870960
        0x08003184:    00000818    ....    DCD    2072
        0x08003188:    08002610    .&..    DCD    134227472
    Region$$Table$$Limit

** Section #2 'RW_IRAM1' (SHT_PROGBITS) [SHF_ALLOC + SHF_WRITE]
    Size   : 48 bytes (alignment 4)
    Address: 0x20000000


** Section #3 'RW_IRAM1' (SHT_NOBITS) [SHF_ALLOC + SHF_WRITE]
    Size   : 2072 bytes (alignment 8)
    Address: 0x20000030


** Section #4 '.debug_abbrev' (SHT_PROGBITS)
    Size   : 1476 bytes


** Section #5 '.debug_frame' (SHT_PROGBITS)
    Size   : 3536 bytes


** Section #6 '.debug_info' (SHT_PROGBITS)
    Size   : 56484 bytes


** Section #7 '.debug_line' (SHT_PROGBITS)
    Size   : 22516 bytes


** Section #8 '.debug_loc' (SHT_PROGBITS)
    Size   : 8000 bytes


** Section #9 '.debug_macinfo' (SHT_PROGBITS)
    Size   : 454208 bytes


** Section #10 '.debug_pubnames' (SHT_PROGBITS)
    Size   : 4367 bytes


** Section #11 '.symtab' (SHT_SYMTAB)
    Size   : 9632 bytes (alignment 4)
    String table #12 '.strtab'
    Last local symbol no. 363


** Section #12 '.strtab' (SHT_STRTAB)
    Size   : 9604 bytes


** Section #13 '.note' (SHT_NOTE)
    Size   : 28 bytes (alignment 4)


** Section #14 '.comment' (SHT_PROGBITS)
    Size   : 32080 bytes


** Section #15 '.shstrtab' (SHT_STRTAB)
    Size   : 156 bytes



.syntax unified
.cpu cortex-m3
.thumb

RCC_APB2ENR = 0x40021018
RCC_APB2ENR_IOPAEN = 4
GPIOA_CRH = 0x40010804

GPIOA_BSRR = 0x40010810
GPIOx_BSRR_BS8 = 0x100
GPIOx_BSRR_BR8 = 0x1000000

GPIOx_CRx_GP_PP_10MHz = 1
GPIOx_CRx_GP_PP_2MHz = 2
GPIOx_CRx_GP_PP_50MHz = 3

GPIOx_CRx_GP_OD_10MHz = 1|4
GPIOx_CRx_GP_OD_2MHz = 2|4
GPIOx_CRx_GP_OD_50MHz = 3|4

GPIOx_CRx_AF_PP_10MHz = 1|8
GPIOx_CRx_AF_PP_2MHz = 2|8
GPIOx_CRx_AF_PP_50MHz = 3|8

GPIOx_CRx_AF_OD_10MHz = 1|4|8
GPIOx_CRx_AF_OD_2MHz = 2|4|8
GPIOx_CRx_AF_OD_50MHz = 3|4|8

GPIOx_CRx_IN_ANLG = 0
GPIOx_CRx_IN_FLOAT = 4
GPIOx_CRx_IN_PULL = 8


DelayLoopIterations = 1000000

.text
.type Reset_Handler, %function
.global Reset_Handler
Reset_Handler:

ldr r1, =RCC_APB2ENR
ldr r0, [r1]
orr r0, r0, #RCC_APB2ENR_IOPAEN
str r0, [r1]					@ Set IOPAEN bit in RCC_APB2ENR to 1 to enable GPIOA

ldr r1, =GPIOA_CRH
ldr r0, [r1]
and r0, #0xfffffff0
orr r0, #GPIOx_CRx_GP_PP_2MHz
str r0, [r1]					@ Set CNF8:MODE8 in GPIOA_CRH to 2


ldr r0, =GPIOA_BSRR				@ Load address of GPIOA_BSRR
ldr r1, =GPIOx_BSRR_BS8			@ Register value to set pin to high
ldr r2, =GPIOx_BSRR_BR8			@ Register value to set pin to low
ldr r3, =DelayLoopIterations	@ Iterations for delay loop

BlinkLoop:
str r1, [r0]					@ Set BS8 in GPIOA_BSRR to 1 to set PA8 high

mov r4, r3
delay1:
subs r4, #1
bne delay1						@ Iterate delay loop

str r2, [r0]					@ Set BR8 in GPIOA_BSRR to 1 to set PA8 low

mov r4, r3
delay2:
subs r4, #1
bne delay2						@ Iterate delay loop

b BlinkLoop


.syntax unified
.cpu cortex-m3
.thumb

RCC_APB2ENR = 0x40021018
RCC_APB2ENR_IOPAEN = 4

GPIOA=0x40010800
GPIOx_CRH = 0x04
GPIOx_BSRR = 0x10

GPIOx_BSRR_BS8 = 0x100
GPIOx_BSRR_BR8 = 0x1000000

GPIOx_CRx_GP_PP_2MHz = 2

.text
.type Reset_Handler, %function
.global Reset_Handler
Reset_Handler:
	bl EnableClockGPIOA

	ldr r1, =GPIOA
	
	ldr r0, [r1, #GPIOx_CRH]
	and r0, #0xfffffff0
	orr r0, #GPIOx_CRx_GP_PP_2MHz
	str r0, [r1, #GPIOx_CRH]		@ Set CNF8:MODE8 in GPIOA_CRH to 2
	
	ldr r0, =GPIOx_BSRR_BS8			@ Register value to set pin to high
	str r0, [r1, #GPIOx_BSRR]		@ Set BS8 in GPIOA_BSRR to 1 to set PA8 high

	b .

.type EnableClockGPIOA, %function
EnableClockGPIOA:
	ldr r1, =RCC_APB2ENR
	ldr r0, [r1]
	orr r0, r0, #RCC_APB2ENR_IOPAEN
	str r0, [r1]					@ Set IOPAEN bit in RCC_APB2ENR to 1 to enable GPIOA
	bx lr	@ Return to caller


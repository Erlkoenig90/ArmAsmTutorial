.syntax unified
.cpu cortex-m3
.thumb

RCC_APB2ENR = 0x40021018
RCC_APB2ENR_IOPAEN = 4
GPIOA_CRH = 0x40010804

GPIOA_BSRR = 0x40010810
GPIOx_BSRR_BS8 = 0x100
GPIOx_BSRR_BR8 = 0x1000000

GPIOx_CRx_GP_PP_2MHz = 2

DelayLoopIterations = 1000000

.text
.type Reset_Handler, %function
.global Reset_Handler
Reset_Handler:
	bl EnableClockGPIOA
	bl ConfigurePA8
	ldr r0, =5
	bl Blink
	b .

.type Blink, %function
Blink:
	push { r4-r8, lr }
	ldr r4, =GPIOA_BSRR		@ Load address of GPIOA_BSRR
	ldr r5, =GPIOx_BSRR_BS8			@ Register value to set pin to high
	ldr r6, =GPIOx_BSRR_BR8		@ Register value to set pin to low
	ldr r7, =BlinkTable				@ Move address of "BlinkTable" into r7
	ldr r8, =BlinkTableEnd			@ Move address of "BlinkTableEnd" into r8


	BlinkLoop:
		str r5, [r4]			@ Set BS8 in GPIOA_BSRR to 1 to set PA8 high

		ldr r0, [r7], #4		@ Load delay iterations from table and increment address
		bl Delay

		str r6, [r4]			@ Set BR8 in GPIOA_BSRR to 1 to set PA8 low

		ldr r0, [r7], #4		@ Load delay iterations from table and increment address
		bl Delay

		cmp r7, r8
		blo BlinkLoop
	
	pop { r4-r8, pc }

.align 2
.type BlinkTable, %object
BlinkTable:
	.word	1000000, 1000000, 1000000, 1000000, 1000000, 1000000
	.word	2500000, 1000000, 2500000, 1000000, 2500000, 1000000
	.word	1000000, 1000000, 1000000, 1000000, 1000000, 1000000
BlinkTableEnd:


.type EnableClockGPIOA, %function
EnableClockGPIOA:
	ldr r1, =RCC_APB2ENR
	ldr r0, [r1]
	orr r0, r0, #RCC_APB2ENR_IOPAEN
	str r0, [r1]	@ Set IOPAEN bit in RCC_APB2ENR to 1 to enable GPIOA
	bx lr			@ Return to caller

.type ConfigurePA8, %function
ConfigurePA8:
	ldr r1, =GPIOA_CRH
	ldr r0, [r1]
	and r0, #0xfffffff0
	orr r0, #GPIOx_CRx_GP_PP_2MHz
	str r0, [r1]			@ Set CNF8:MODE8 in GPIOA_CRH to 2
	bx lr

@ Parameters: r0 = Number of iterations
.type Delay, %function
Delay:
	DelayLoop:
	subs r0, #1
	bne DelayLoop			@ Iterate delay loop
	bx lr


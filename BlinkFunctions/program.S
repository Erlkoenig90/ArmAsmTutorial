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
	ldr r5, =5						@ Number of LED flashes.
	bl Blink
	b .

.type Blink, %function
Blink:
	push { lr }
	ldr r0, =GPIOA_BSRR				@ Load address of GPIOA_BSRR
	ldr r1, =GPIOx_BSRR_BS8			@ Register value to set pin to high
	ldr r2, =GPIOx_BSRR_BR8			@ Register value to set pin to low
	ldr r3, =DelayLoopIterations	@ Iterations for delay loop

	BlinkLoop:
		str r1, [r0]				@ Set BS8 in GPIOA_BSRR to 1 to set PA8 high

		bl Delay

		str r2, [r0]				@ Set BR8 in GPIOA_BSRR to 1 to set PA8 low

		bl Delay

		subs r5, #1
		bne BlinkLoop
	
	pop { lr }
	bx lr

.type EnableClockGPIOA, %function
EnableClockGPIOA:
	ldr r1, =RCC_APB2ENR
	ldr r0, [r1]
	orr r0, r0, #RCC_APB2ENR_IOPAEN
	str r0, [r1]					@ Set IOPAEN bit in RCC_APB2ENR to 1 to enable GPIOA
	bx lr	@ Return to caller


.type ConfigurePA8, %function
ConfigurePA8:
	ldr r1, =GPIOA_CRH
	ldr r0, [r1]
	and r0, #0xfffffff0
	orr r0, #GPIOx_CRx_GP_PP_2MHz
	str r0, [r1]					@ Set CNF8:MODE8 in GPIOA_CRH to 2
	bx lr

.type Delay, %function
Delay:
	mov r4, r3
	DelayLoop:
	subs r4, #1
	bne DelayLoop					@ Iterate delay loop
	bx lr


.syntax unified
.cpu cortex-m3
.thumb

.include "stm32f103.inc"

TimerValue=1500000

.data
Variables:
BlinkStep:
	.space 1
TimerEvents:
	.space 1

.text
.type Reset_Handler, %function
.global Reset_Handler
Reset_Handler:
	ldr r0, =Variables
	ldr r1, =0
	str r1, [r0, #(BlinkStep-Variables)]
	ldr r1, BlinkTable
	str r1, [r0, #(TimerEvents-Variables)]
	
	bl EnableClockGPIOA
	bl ConfigurePA8
	
	ldr r1, =GPIOx_BSRR_BS8
	ldr r0, =GPIOA
	str r1, [r0, #GPIOx_BSRR]

	
	ldr r0, =TimerValue
	bl StartSysTick
	1:
		wfi
		b 1b


.type SysTick_Handler, %function
.global SysTick_Handler
SysTick_Handler:
	ldr r0, =SCS
	ldr r0, [r0, #SCS_SYST_CSR]
	tst r0, #0x10000
	beq 2f
	
	ldr r0, =Variables
	
	ldrb r1, [r0, #(BlinkStep-Variables)]
	
	cmp r1, #(BlinkTableEnd-BlinkTable)
	bhs 2f
	
	ldrb r3, [r0, #(TimerEvents-Variables)]
	subs r3, #1
	
	itt ne
	strbne r3, [r0, #(TimerEvents-Variables)]
	bne 2f
	
	add r1, #1
	cmp r1, #(BlinkTableEnd-BlinkTable)
	bhs 1f
	
	ldr r2, =BlinkTable
	ldrb r3, [r2, r1]
	strb r3, [r0, #(TimerEvents-Variables)]

1:
	strb r1, [r0, #(BlinkStep-Variables)]
	
	ands r1, #1
	ite eq
	ldreq r1, =GPIOx_BSRR_BS8
	ldrne r1, =GPIOx_BSRR_BR8
	
	ldr r0, =GPIOA
	str r1, [r0, #GPIOx_BSRR]

2:
	bx lr

.align 2
.type BlinkTable,%object	
BlinkTable:
	.byte	2, 2, 2, 2, 2, 2
	.byte	5, 2, 5, 2, 5, 2
	.byte	2, 2, 2, 2, 2
BlinkTableEnd:

.align 2

.type EnableClockGPIOA, %function
EnableClockGPIOA:
	ldr r1, =RCC
	ldr r0, [r1, #RCC_APB2ENR]
	orr r0, r0, #(1 << RCC_APB2ENR_IOPAEN)
	str r0, [r1, #RCC_APB2ENR]			@ Set IOPAEN bit in RCC_APB2ENR to 1 to enable GPIOA
	bx lr	@ Return to caller

.type ConfigurePA8, %function
ConfigurePA8:
	ldr r1, =GPIOA
	ldr r0, [r1, #GPIOx_CRH]
	and r0, #0xfffffff0
	orr r0, #GPIOx_CRx_GP_PP_2MHz
	str r0, [r1, #GPIOx_CRH]			@ Set CNF8:MODE8 in GPIOA_CRH to 2
	bx lr
	.ltorg

@ r0 = Count-Down value for timer
.type InitializeSysTick, %function
StartSysTick:
	ldr r1, =SCS

	str r0, [r1, #SCS_SYST_RVR]
	ldr r0, =0
	str r0, [r1, #SCS_SYST_CVR]

	ldr r0, =7
	str r0, [r1, #SCS_SYST_CSR]

	bx lr


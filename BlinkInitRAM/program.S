.syntax unified
.cpu cortex-m3
.thumb

.include "stm32f103.inc"

TimerValue=1500000

.data
TimerEvents:
	.byte 2

.bss
BlinkStep:
	.space 1
	.space 100

.text
.type Reset_Handler, %function
.global Reset_Handler
Reset_Handler:
	ldr r0, =_DataStart
	ldr r1, =_DataEnd
	ldr r2, =_DataLoad

	b 2f
1:	ldr r3, [r2], #4
	str r3, [r0], #4
2:	cmp r0, r1
	blo 1b
	
	ldr r0, =_BssStart
	ldr r1, =_BssEnd
	ldr r2, =0

	b 2f
1:	str r2, [r0], #4
2:	cmp r0, r1
	blo 1b

	bl EnableClockGPIOA
	bl ConfigurePA8

	ldr r1, =GPIOx_BSRR_BS8
	ldr r0, =GPIOA					@ Load address of GPIOA_BSRR
	str r1, [r0, #GPIOx_BSRR]

	ldr r0, =TimerValue
	bl StartSysTick
	1:
		wfi
		b 1b
	.ltorg

.type SysTick_Handler, %function
.global SysTick_Handler
SysTick_Handler:
	ldr r0, =SCS
	ldr r0, [r0, #SCS_SYST_CSR]
	tst r0, #0x10000
	beq 2f
	
	ldr r0, =BlinkStep
	
	ldrb r1, [r0]
	
	cmp r1, #(BlinkTableEnd-BlinkTable)
	bhs 2f
	
	ldr r0, =TimerEvents
	ldrb r3, [r0]
	subs r3, #1
	
	itt ne
	strbne r3, [r0]
	bne 2f
	
	add r1, #1
	cmp r1, #(BlinkTableEnd-BlinkTable)
	bhs 1f
	
	ldr r2, =BlinkTable
	ldrb r3, [r2, r1]
	strb r3, [r0]

1:
	ldr r0, =BlinkStep
	strb r1, [r0]
	
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


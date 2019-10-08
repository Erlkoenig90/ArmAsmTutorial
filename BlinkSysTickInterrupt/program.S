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

SCS = 0xe000e000
SCS_SYST_CSR = 0x10
SCS_SYST_RVR = 0x14
SCS_SYST_CVR = 0x18
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
	ldr r0, =GPIOA_BSRR			@ Load address of GPIOA_BSRR
	str r1, [r0]

	
	ldr r0, =TimerValue
	bl StartSysTick
	SleepLoop:
		wfi
		b SleepLoop


.type SysTick_Handler, %function
.global SysTick_Handler
SysTick_Handler:
	ldr r0, =SCS
	ldr r0, [r0, #SCS_SYST_CSR]
	tst r0, #0x10000
	beq Return
	
	ldr r0, =Variables
	
	ldrb r1, [r0, #(BlinkStep-Variables)]
	
	cmp r1, #(BlinkTableEnd-BlinkTable)
	bhs Return
	
	ldrb r3, [r0, #(TimerEvents-Variables)]
	subs r3, #1
	
	itt ne
	strbne r3, [r0, #(TimerEvents-Variables)]
	bne Return
	
	add r1, #1
	cmp r1, #(BlinkTableEnd-BlinkTable)
	bhs SkipRestart
	
	ldr r2, =BlinkTable
	ldrb r3, [r2, r1]
	strb r3, [r0, #(TimerEvents-Variables)]

SkipRestart:
	strb r1, [r0, #(BlinkStep-Variables)]
	
	ands r1, #1
	ite eq
	ldreq r1, =GPIOx_BSRR_BS8
	ldrne r1, =GPIOx_BSRR_BR8
	
	ldr r0, =GPIOA_BSRR			@ Load address of GPIOA_BSRR
	str r1, [r0]

Return:
	bx lr

.align 2
BlinkTable:
	.byte	2, 2, 2, 2, 2, 2
	.byte	5, 2, 5, 2, 5, 2
	.byte	2, 2, 2, 2, 2
BlinkTableEnd:

.align 2

.type EnableClockGPIOA, %function
EnableClockGPIOA:
	ldr r1, =RCC_APB2ENR
	ldr r0, [r1]
	orr r0, r0, #RCC_APB2ENR_IOPAEN
	str r0, [r1]			@ Set IOPAEN bit in RCC_APB2ENR to 1 to enable GPIOA
	bx lr	@ Return to caller

.type ConfigurePA8, %function
ConfigurePA8:
	ldr r1, =GPIOA_CRH
	ldr r0, [r1]
	and r0, #0xfffffff0
	orr r0, #GPIOx_CRx_GP_PP_2MHz
	str r0, [r1]			@ Set CNF8:MODE8 in GPIOA_CRH to 2
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


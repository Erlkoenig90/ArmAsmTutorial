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

.text
.type Reset_Handler, %function
.global Reset_Handler
Reset_Handler:
	bl EnableClockGPIOA
	bl ConfigurePA8
	ldr r0, =TimerValue
	bl StartSysTick
	bl Blink
	b .

.type Blink, %function
Blink:
	push { r4-r8, lr }
	ldr r4, =GPIOA_BSRR				@ Load address of GPIOA_BSRR
	ldr r5, =GPIOx_BSRR_BS8			@ Register value to set pin to high
	ldr r6, =GPIOx_BSRR_BR8			@ Register value to set pin to low
	adr r7, BlinkTable				@ Move address of "BlinkTable" into r8
	adr r8, BlinkTableEnd			@ Move address of "BlinkTableEnd" into r9


	BlinkLoop:
		str r5, [r4]				@ Set BS8 in GPIOA_BSRR to 1 to set PA8 high

		ldrb r0, [r7], #1			@ Load delay iterations from table and increment address
		bl WaitSysTick

		str r6, [r4]				@ Set BR8 in GPIOA_BSRR to 1 to set PA8 low

		ldrb r0, [r7], #1			@ Load delay iterations from table and increment address
		bl WaitSysTick

		cmp r7, r8
		blo BlinkLoop
	
	pop { r4-r8, pc }

.align 2
.type BlinkTable, %object
BlinkTable:
	.byte	2, 2, 2, 2, 2, 2
	.byte	5, 2, 5, 2, 5, 2
	.byte	2, 2, 2, 2, 2, 2
BlinkTableEnd:
.align 2

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
	.ltorg

@ r0 = Count-Down value for timer
.type InitializeSysTick, %function
StartSysTick:
	ldr r1, =SCS

	str r0, [r1, #SCS_SYST_RVR]
	ldr r0, =0
	str r0, [r1, #SCS_SYST_CVR]

	ldr r0, =5
	str r0, [r1, #SCS_SYST_CSR]

	bx lr

@ r0 = Number of timer events to wait for
.type WaitSysTick, %function   
WaitSysTick:
	ldr r1,	 =SCS
	
WaitSysTickLoop:
	ldr r2, [r1, #SCS_SYST_CSR]
	tst r2, #0x10000
	beq WaitSysTickLoop

	subs r0, #1
	bne WaitSysTickLoop

	bx lr


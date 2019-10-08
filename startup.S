.syntax unified
.cpu cortex-m3
.thumb

.include "stm32f103.inc"

.text
.type Reset_Handler, %function
.global Reset_Handler
Reset_Handler:
	bl ConfigureSysClock
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

	bl main
1:	bkpt
	b 1b
	.ltorg

.type ConfigureSysClock, %function
.global ConfigureSysClock
ConfigureSysClock:
	@ Turn on HSE
	ldr r0, =RCC
	ldr r1, =((1 << RCC_CR_HSION)|(1 << RCC_CR_HSEON))
	str r1, [r0, #RCC_CR]
	
	@ Configure (but not start yet) PLL
	@ Mul = 9, Prediv = 1, APB1 Prescaler = 2, APB2 Prescaler = 1, AHB Prescaler = 1
	ldr r2, =(((9-2)<<RCC_CFGR_PLLMUL)|(1 << RCC_CFGR_USBPRE)|(1 << RCC_CFGR_PLLSRC)|(4 << RCC_CFGR_PPRE1))
	str r2, [r0, #RCC_CFGR]

	@ Pre-Calculate value for RCC_CR
	orr r1, #(1 << RCC_CR_PLLON)

	
	@ Wait for HSE ready
1:	ldr r3, [r0, #RCC_CR]
	ands r3, #(1 << RCC_CR_HSERDY)
	beq 1b
	
	@ Turn on PLL
	str r1, [r0, #RCC_CR]
	
	@ Pre-Calculate value for RCC_CFGR
	orr r2, #(2 << RCC_CFGR_SW)
	
	@ Wait for PLL ready
1:	ldr r3, [r0, #RCC_CR]
	ands r3, #(1 << RCC_CR_PLLRDY)
	beq 1b
	
	@ Set flash wait states to 2
	ldr r0, =FLASH
	ldr r3, =((1<<FLASH_ACR_PRFTBE)|(2<<FLASH_ACR_LATENCY))
	str r3, [r0, #FLASH_ACR]
	ldr r0, =RCC
	
	@ Switch system clock to PLL
	str r2, [r0, #RCC_CFGR]

	@ Pre-Calculate value for RCC_CR
	bic r1, #(1 << RCC_CR_HSION)


	@ Wait for switch to PLL
1:	ldr r3, [r0, #RCC_CFGR]
	and r3, #(3 << RCC_CFGR_SWS)
	cmp r3, #(2 << RCC_CFGR_SWS)
	bne 1b
	
	@ Turn off HSI to save power
	str r1, [r0, #RCC_CR]
	
	bx lr
	.ltorg


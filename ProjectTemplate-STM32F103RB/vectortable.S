.syntax unified
.cpu cortex-m3
.thumb

.macro defisr name
	.global \name
	.weak \name
	.thumb_set \name, Default_Handler
	.word \name
.endm

.global VectorTable
.section .VectorTable, "a"
.type VectorTable, %object
VectorTable:
.word _StackEnd
defisr Reset_Handler
defisr NMI_Handler
defisr HardFault_Handler
defisr MemManage_Handler
defisr BusFault_Handler
defisr UsageFault_Handler
.word 0
.word 0
.word 0
.word 0
defisr SVC_Handler
defisr DebugMon_Handler
.word 0
defisr PendSV_Handler
defisr SysTick_Handler
defisr WWDG_IRQHandler
defisr PVD_IRQHandler
defisr TAMPER_IRQHandler
defisr RTC_IRQHandler
defisr FLASH_IRQHandler
defisr RCC_IRQHandler
defisr EXTI0_IRQHandler
defisr EXTI1_IRQHandler
defisr EXTI2_IRQHandler
defisr EXTI3_IRQHandler
defisr EXTI4_IRQHandler
defisr DMA1_Channel1_IRQHandler
defisr DMA1_Channel2_IRQHandler
defisr DMA1_Channel3_IRQHandler
defisr DMA1_Channel4_IRQHandler
defisr DMA1_Channel5_IRQHandler
defisr DMA1_Channel6_IRQHandler
defisr DMA1_Channel7_IRQHandler
defisr ADC1_2_IRQHandler
defisr USB_HP_CAN1_TX_IRQHandler
defisr USB_LP_CAN1_RX0_IRQHandler
defisr CAN1_RX1_IRQHandler
defisr CAN1_SCE_IRQHandler
defisr EXTI9_5_IRQHandler
defisr TIM1_BRK_IRQHandler
defisr TIM1_UP_IRQHandler
defisr TIM1_TRG_COM_IRQHandler
defisr TIM1_CC_IRQHandler
defisr TIM2_IRQHandler
defisr TIM3_IRQHandler
defisr TIM4_IRQHandler
defisr I2C1_EV_IRQHandler
defisr I2C1_ER_IRQHandler
defisr I2C2_EV_IRQHandler
defisr I2C2_ER_IRQHandler
defisr SPI1_IRQHandler
defisr SPI2_IRQHandler
defisr USART1_IRQHandler
defisr USART2_IRQHandler
defisr USART3_IRQHandler
defisr EXTI15_10_IRQHandler
defisr RTCAlarm_IRQHandler
defisr USBWakeUp_IRQHandler

.text

.type Default_Handler, %function
.global Default_Handler
Default_Handler:
	bkpt
	b.n Default_Handler


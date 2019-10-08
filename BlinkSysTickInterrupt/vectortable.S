.syntax unified
.cpu cortex-m3
.thumb

.section .VectorTable, "a"
.word _StackEnd
.word Reset_Handler
.space 0x34
.word SysTick_Handler
.space 0xac


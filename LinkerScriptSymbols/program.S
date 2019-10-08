.syntax unified
.cpu cortex-m3
.thumb

.word _StackEnd
.word Reset_Handler
.space 0xe4

.type Reset_Handler, %function
Reset_Handler:

ldr r1, =0x40021018
ldr r0, [r1]
orr r0, r0, #4
str r0, [r1]			@ Set IOPAEN bit in RCC_APB2ENR to 1 to enable GPIOA

ldr r1, =0x40010804
ldr r0, [r1]
and r0, #0xfffffff0
orr r0, #2
str r0, [r1]			@ Set CNF8:MODE8 in GPIOA_CRH to 2


ldr r0, =0x40010810		@ Load address of GPIOA_BSRR
ldr r1, =0x100			@ Register value to set pin to high
ldr r2, =0x1000000		@ Register value to set pin to low
ldr r3, =1000000		@ Iterations for delay loop

BlinkLoop:
str r1, [r0]			@ Set BS8 in GPIOA_BSRR to 1 to set PA8 high

mov r4, r3
delay1:
subs r4, #1
bne delay1				@ Iterate delay loop

str r2, [r0]			@ Set BR8 in GPIOA_BSRR to 1 to set PA8 low

mov r4, r3
delay2:
subs r4, #1
bne delay2				@ Iterate delay loop

b BlinkLoop


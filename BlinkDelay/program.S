.syntax unified
.cpu cortex-m3
.thumb

.word 0x20000400
.word 0x080000ed
.space 0xe4

ldr r1, =0x40021018
ldr r0, [r1]
orr r0, r0, #4
str r0, [r1]			@ Set IOPAEN bit in RCC_APB2ENR to 1 to enable GPIOA

ldr r1, =0x40010804
ldr r0, [r1]
and r0, #0xfffffff0
orr r0, #2
str r0, [r1]			@ Set CNF8:MODE8 in GPIOA_CRH to 2

BlinkLoop:
ldr r1, =0x40010810
ldr r0, =0x100
str r0, [r1]			@ Set BS8 in GPIOA_BSRR to 1 to set PA8 high

ldr r2, =1000000
delay1:
subs r2, #1
bne delay1				@ Iterate delay loop

ldr r1, =0x40010810
ldr r0, =0x1000000
str r0, [r1]			@ Set BR8 in GPIOA_BSRR to 1 to set PA8 low

ldr r2, =1000000
delay2:
subs r2, #1
bne delay2				@ Iterate delay loop

b BlinkLoop


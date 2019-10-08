.syntax unified
.cpu cortex-m3
.thumb

.word 0x20000400
.word 0x080000ed
.space 0xe4

ldr r0, =0x00000004
ldr r1, =0x40021018
str r0, [r1]			@ Set IOPAEN bit in RCC_APB2ENR to 1 to enable GPIOA

ldr r0, =0x44444442
ldr r1, =0x40010804
str r0, [r1]			@ Set CNF8:MODE8 in GPIOA_CRH to 2

ldr r0, =0x100
ldr r1, =0x4001080C
str r0, [r1]			@ Set ODR8 in GPIOA_ODR to 1 to set PA8 high

b .


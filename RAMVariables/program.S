.syntax unified
.cpu cortex-m3
.thumb

.word 0x20000400
.word 0x080000ed
.space 0xe4

.data
var1:
	.space 4			@ Reserve 4 bytes for memory block “var1”
var2:
	.space 1			@ Reserve 1 byte for memory block “var2”

.text


ldr r0, =var1			@ Get address of var1
ldr r1, =0x12345678
str r1, [r0]			@ Store 0x12345678 into memory block “var1”


ldr r1, [r0]			@ Read memory block “var1”
and r1, #0xFF			@ Set bits 8..31 to zero
ldr r0, =var2			@ Get address of var2
strb r1, [r0]			@ Store a single byte into var2

b .


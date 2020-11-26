Keyboard_w          = 0x1d
Keyboard_s          = 0x1b
Keyboard_a          = 0x1c
Keyboard_d          = 0x23

#define GPIO_SWs      0x80001400
#define GPIO_LEDs     0x80001404
#define GPIO_INOUT    0x80001408
#define GPIO_KEY      0x80001600

.globl _start
_start:

li x28, 0xFFFF
li x29, GPIO_INOUT
sw x28, 0(x29)                  # Write the Enable Register

next:
    li  a0, GPIO_LEDs
    li x28, 0x0
    sw x28, 0(a0)
    li  a1, GPIO_KEY           # Read the KEY
    lw  t1, 0(a1)
    li  t2, 0x23
    bne t1, t2, next
    li  t3, 0xF
    sw  t3, 0(a0)               # Write the LEDs
    beq zero, zero, next
.end
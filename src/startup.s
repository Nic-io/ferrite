
.syntax unified
.cpu cortex-m4
.thumb

.section .text

.global _estack
.global reset_handler

.type vtable, %object

vtable:
.word _estack
.word reset_handler

main_loop:
    ADDS r0, r0, #1
    BL main_loop

.type reset_handler, %function
reset_handler:
    LDR r0, = _estack
    MOV sp, r0

    LDR r7, =0xDEADBEEF
    MOVS r0, #0
    BL  main_loop

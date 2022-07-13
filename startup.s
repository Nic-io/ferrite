
.syntax unified
.cpu cortex-m4
.thumb

.global vtable
.global reset_handler

.section .vector_table
.type vtable, %object
vtable:
    .word _estack
    .word reset_handler
.size vtable, .-vtable

.type reset_handler, %function
reset_handler:
    LDR r0, = _estack
    MOV sp, r0

    LDR r7, =0xDEADBEEF
    MOVS r0, #0
    B  main_loop

//.size reset_handler, .-reset_handler

//.section .text
main_loop:
    ADDS r0, r0, #1
    B main_loop


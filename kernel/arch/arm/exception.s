# Defines a table for the Interrupt Vector Table.
# The address of this table is loaded into the GIC.VBAR
# coprocessor register

/**
.global vector_table
vector_table:
    .weak reset_handler
    .weak undefined_instruction
    .weak system_call
    .weak prefetch_abort
    .weak data_abort
    .weak UNUSED
    .weak irq_handler
    .weak fiq_handler
**/
.section .text.vector_table
.global vector_table
.align 8
vector_table:
    b .
    b illegal_instruction_trampoline
    b .
    b .
    b .
    b .
    b .
    b .

.global relocate_vector_table
.section .text
relocate_vector_table:
    ldr r0, =vector_table
    mcr p15, 0, r0, c12, c0, 0
    bx lr

.extern illegal_instruction_handler
illegal_instruction_trampoline:
    # We need to reload the stack pointer. More about
    # why here: https://electronics.stackexchange.com/questions/291548/undefined-exception-in-arm-processor
    ldr sp, =__STACK_TOP // It doesn't matter that we overwrite the stack
    stmdb sp!, {r0-r12, lr, pc}
    mrs r4, spsr
    push {r4}
    mov r0, sp
    ldr pc, =illegal_instruction_handler

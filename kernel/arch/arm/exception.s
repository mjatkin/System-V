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
    ldr pc, =_start
    b illegal_instruction_trampoline
    b .
    b .
    b data_abort_trampoline
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
    
    # Let's save all the registers before we enter the cpp function handler
    stmfd sp!, {r0-r12, lr}
    mrs r0, spsr
    stmfd sp!, {r0}
    mov r0, sp

    # Jump to the actual exception handler
    bl illegal_instruction_handler
    add sp, sp, #4 // Ignore the value of SPSR we pushed onto the stack
    ldmfd sp!, {r0-r12, pc}^ // Return from exception

.extern data_abort_handler
data_abort_trampoline:
    ldr sp, =__STACK_TOP // It doesn't matter that we overwrite the stack

    # Let's save all the registers before we enter the cpp function handler
    stmfd sp!, {r0-r12, lr}
    mrs r0, spsr
    stmfd sp!, {r0}
    mov r0, sp

    # Jump to the actual exception handler
    bl data_abort_handler
    add sp, sp, #4 // Ignore the value of SPSR we pushed onto the stack
    ldmfd sp!, {r0-r12, pc}^ // Return from exception

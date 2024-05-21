# boot.S
# bootloader for risk_os
# Ethan Kelly
# 20th May, 2024

.option norv
.section .data

.section .text.init
.global _start
_start:
    # non-bootstrapping harts need to wait for an interprocessor interrupti
    # this is done by copying the hart id to register t0
    csrr t0, mhartid
    # parks the hart in a loop at the soonest label 3 after the branch
    bnez t0, 3f
    # set the supervisor address translation and protection register to OFF
    csrw satp, zero

# push current options to stack and turn of linker relaxation optimizations 
.option push
.option norelax
# load address command
    la      gp, _global_pointer
# pop the norelax from before so the linker can do its thing
.option pop

# i am become OS, setter of uninitialized vars (BSS) to 0
    la      a0, _bss_start
    la      a1, _bss_end
    # if the start address is greater than the end, do NOT start wiping memory (obviously)
    bgeu    a0, a1, 2f
1:
    # write double word zero into a0, move ahead 8 bytes, repeat until a0 is a1
    sd      zero, (a0)
    addi a0, a0, 8
    bltu a0, a1, 1b
2:

# the zone for bad non-0 harts
3:
    # wait for interrupt
    wfi
    # jump back to the nearest label 3
    j   3b

# machine mode
#li      t5, 0xffff;
# machine exception and interrupt registers
#csrw    medeleg, t5
#csrw    mideleg, t5

# stack address loaded to stack pointer
la      sp, _stack
# load 0b110001000100, enabling course interrupts and M-mode
li      t0, (0b11 << 11) | (1 << 7) | (1 << 3)
csrw    mstatus, t0
# load kmain (from Rust-land) and make it the memory address we return to
la      t1, kmain
        # machine exception program counter
csrw    mepc, t1
# call asm_trap_vector whenever there's a trap (system call, illegal instruction, etc.)
la      t2, asm_trap_vector
        # machine trap vector
csrw    mtvec, t2
# software, timer, and global interrupts enabled
li      t3, (1 << 3) | (1 << 7) | (1 << 11)
        # machine interrupt enable
csrw    mie, t3
# return address set to the parked label
la      ra, 4f
# return from trap in machine-mode (to where mepc points)
mret

4:
    wfi
    j   4b

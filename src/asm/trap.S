# trap.S
# Assembly trap handler!
.section .text
.global _asm_trap_vector
asm_trap_vector:
    # we've entered the land of the interrupted...
    #temp
    mret

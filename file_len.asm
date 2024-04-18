.include "simpleLib.asm"
.include "file_lib.asm"

.text
main:
    li t0, 1
    bne t0, a0, false_arg
    lw a0, 0(a1)
    print_str
    println
    
    li a1, F_READONLY
    call f_open
    
    mv s1, a0
    call f_length
    print_int
    println
    swap s1, a0
    
    call f_load
    swap s1, a0
    close
    mv a0, s1
    print_str
    exit 0

false_arg:
    error "Incorrect number of arguments"
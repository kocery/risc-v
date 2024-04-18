j endlib

.macro close
    syscall 57
.end_macro

.macro open
    syscall 1024
.end_macro

.macro read
    syscall 63
.end_macro

.macro lseek
    syscall 62
.end_macro


.eqv F_APPEND 9
.eqv F_READONLY 0
.eqv F_WRITEONLY 1

f_open:
    open
    li t0, -1
    beq t0, a0, cant_open
    ret

cant_open:
    error "Can open file"


f_read:
    read
    li t0, -1
    beq t0, a0, cant_read
    ret
 
cant_read:
    error "Cant read file"


f_load:
    push3 ra, s1, s2
    mv s1, a0
    call f_length
    mv s2, a0
    addi a0, a0, 1
    sbrk
    li t0, 0
    add t1, a0, s2
    sb t0, 1(t1)
    mv a1, a0
    mv a0, s1
    mv a2, s2
    mv s1, a1
    call f_read
    mv a0, s1
    pop3 ra, s1, s2
    ret


f_length:
    push1 s1
    mv s1, a0
    li a1, 0
    li a2, 2
    lseek
    li t0, -1
    beq t0, a0, f_length_error
    swap a0, s1
    li a1, 0
    li a2, 0
    lseek
    li t0, -1
    beq t0, a0, f_length_error
    mv a0, s1
    pop1 s1
    ret

f_length_error:
    error "Cant find length"


endlib:
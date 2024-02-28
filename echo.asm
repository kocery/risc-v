.text
.macro syscall %n
    li a7, %n
    ecall
.end_macro

.macro readch
    syscall 12
.end_macro

.macro printch
    syscall 11
.end_macro

.macro println
	mv a1, a0
    li a0, 10
    syscall 11
    mv a0, a1
.end_macro

.macro exit %ecode
    li, a0, %ecode
    syscall 93
.end_macro

main_loop:
	readch
	li t0, 10
	beq a0, t0, end
	
	println
    printch
    andi a0, a0, 0xff
	addi a0, a0, 1
	println
	printch
	println
	
	j main_loop
	
end:
   exit 0

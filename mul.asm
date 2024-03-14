.macro syscall %n
  li a7, %n
	ecall
.end_macro

.macro readch
  syscall 12
.end_macro

.macro error %str
.data
str: .asciz %str
.text
  la a0, str
  syscall 4
  exit 1
.end_macro

.macro printch
  syscall 11
.end_macro

.macro println # print \n | a1 - buf for swap a0
  mv a1, a0
  li a0, 10
  syscall 11
  mv a0, a1
.end_macro

.macro inside %x %y # t3 more or eq х and less у | t4, t5 - temp | t6 - result (inv)
  slti t4, t3, %y
  slti t5, t3, %x
  not t5, t5
  and t6, t4, t5
  addi t6, t6, -1
.end_macro

.macro exit %ecode
  li a0, %ecode
  syscall 93
.end_macro

main:
  call read_hex # read 1 num -> a0
  mv s0, a0
  
  call read_hex # read 2 num -> a0
  mv s1, a0
  
  mv a0, s0
  mv a1, s1
  call mulHex
  
  call print_hex # prints hex num on a0
  
  j end 

mulHex: # a0 * a1 -> a0
  li t0, 1
  li t1, 0
  li t3, 0

mulHex1:
  and t2, a1, t0
  beqz t2, mulHex2
  sll t2, a0, t1
  add t3, t3, t2

mulHex2:
  slli t0, t0, 1
  addi t1, t1, 1
  bnez t0, mulHex1
  
  mv a0, t3
  ret

read_hex:
  li a2, 7 # counter for input len
  li a3, 0 # counter for scan
  j read_hex1
        
read_hex1: # writes 7 digit nums to a0
  readch
  mv t3, a0 
  
  li t1, 10 # return when <enter>
  beq t3, t1, return_hex
  
  addi t3, t3, -48
  
  inside 0, 10 #0 - 9
  beq t6, zero, add_
  
  inside 17, 23 #a - f
  addi t3, t3, -7
  beq t6, zero, add_
  
  inside 42, 48 #A - F
  addi t3, t3, -32
  beq t6, zero, add_
  
  j return_hex
  
add_: # add hex digit to num | subfunc for read_hex
  slli a1, a1, 4
  add a1, a1, t3
  
  addi a3, a3, 1
  ble a3, a2, read_hex1
  
  println
  j return_hex

return_hex:
  mv a0, a1
  mv a1, zero
  ret

print_hex:
  mv t1, a0
  li a4, 0xf0000000 # bit mask
  li a5, 28         # counter for digits
  j print_hex1

print_hex1: #prints hex number on a0
  li t0, -4 # subtract the number of digits
  beq a5, t0, return # checking for the end of the operation

  and a0, t1, a4 # apply the mask
  srli a4, a4, 4 # shift the mask to the next discharge
  srl a0, a0, a5 # shift the num to the next discharge
  
  addi a5, a5, -4 # reducing the discharge counter
  
  mv t3, a0
  inside 0, 10
  beq t6, zero, printnum
  j printlet

printnum:
  addi a0, a0, 48
  printch
  j print_hex1

printlet:
  addi a0, a0, 87
  printch
  j print_hex1

return:
  ret

end:
  exit 0

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

.macro println # print \n | a1 - buf for swap a0
  	mv a1, a0
    li a0, 10
    syscall 11
    mv a0, a1
.end_macro

.macro exit %ecode
    li a0, %ecode
    syscall 93
.end_macro

.macro inside %x %y # а0 more or eq х and less у | t0, t1 - temp | t2 - result (inv)
  slti t0, a0, %y
  slti t1, a0, %x
  not t1, t1
  and t2, t0, t1
  addi t2, t2, -1
.end_macro

.macro load_clear_rhex %r # loads read_hex result to %r and clears after func  
  mv %r, a1 # 1 num -> s0
  mv a1, zero # clear a1
  mv s3, zero # clear counter
.end_macro
    
main:
  li s2, 7 # counter for input len
  li s3, 0 # counter for scan
  li s4, 0xf0000000 # bit mask
  li s5, 28         # counter for digits
  
  call read_hex # read 1 num
  load_clear_rhex s0
  
  call read_hex # read 2 num
  load_clear_rhex s1
  
  call readop # read and perform operation func
  
  call print_hex # prints hex num
  
  j end 
  
read_hex: # writes 7 digit nums to a1
  readch 
  
  li t1, 10 # return when <enter>
  beq a0, t1, return
  
  addi a0, a0, -48
  addi t0, t0, 48
  
  inside 0, 10 #0 - 9
  beq t2, zero, add_
  
  inside 17, 23 #a - f
  addi a0, a0, -7
  addi t0, t0, 7
  beq t2, zero, add_
  
  inside 42, 48 #A - F
  addi a0, a0, -32
  addi t0, t0, 7
  beq t2, zero, add_
  
  ret
  
add_: # add hex digit to num | subfunc for read_hex
  slli a1, a1, 4
  add a1, a1, a0
  add a0, a0, t0
  
  addi s3, s3, 1
  ble s3, s2, read_hex
  
  println
  ret

readop: # reads and performs an operation res -> a1
  li t0, 43         # +
  li t1, 45         # -
  li t2, 38         # &
  li t3, 124        # |

  readch
  println
  beq a0, t0, plus
  beq a0, t1, minus
  beq a0, t2, and_
  beq a0, t3, or_
  
  ret
  
plus:
  add a1, s1, s0
  ret

minus:
  sub a1, s0, s1
  ret

and_: 
  and a1, s1, s0
  ret

or_:
  or a1, s1, s0
  ret

print_hex: #prints hex number on a1
  li t0, -4 # subtract the number of digits
  beq s5, t0, return # checking for the end of the operation

  and a3, a1, s4 # apply the mask
  srli s4, s4, 4 # shift the mask to the next discharge
  srl a3, a3, s5 # shift the num to the next discharge
  
  addi s5, s5, -4 # reducing the discharge counter
  mv a0, a3		  # loading the value of the current digit into a0
  j print_digit # print digit

print_digit: #prints hex digit on a0
  inside 0, 10
  beq t2, zero, printnum
  j printlet

printnum:
  addi a0, a0, 48
  printch
  j print_hex

printlet:
  addi a0, a0, 87
  printch
  j print_hex

return:
  ret

end:
  exit 0

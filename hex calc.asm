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

.macro inside %x %y # а0 more or eq х and less у | t0, t1 - temp | a1 - result (inv)
  slti t0, a0, %y
  slti t1, a0, %x
  not t1, t1
  and a1, t0, t1
  addi a1, a1, -1
.end_macro
  
main:
  li t6, -2 # flag for '-' to print
  li t4, 6 # counter for input len
  li t5, 0 # counter for scan
  
  call read # read 1 num
  mv a5, s1 # 1 num -> а5
  mv s1, zero # clear s1
  mv t5, zero # clear counter
  call read # read 2 num
  mv a6, s1 # 2 num -> a6
  mv s1, zero # clear s1
  j readop
  
read: # writes 7 digit nums to s1
  readch # return when <enter>
  li a2, 10
  beq a0, a2, return
  
  addi a0, a0, -48
  addi s2, s2, 48
  
  inside 0, 10 #0 - 9
  beq a1, zero, add_
  
  inside 17, 23 #a - f
  addi a0, a0, -7
  addi s2, s2, 7
  beq a1, zero, add_
  
  inside 42, 48 #A - F
  addi a0, a0, -32
  addi s2, s2, 7
  beq a1, zero, add_
  
  j end
  
add_:
  slli s1, s1, 4
  add s1, s1, a0
  mv s0, a0
  add a0, a0, s2
  mv a0, s0
  
  addi t5, t5, 1
  ble t5, t4, read
  
  println
  ret

readop:
  li t0, 43         # +
  li t1, 45         # -
  li t2, 38         # &
  li t3, 124        # |
  li t5, 28         # counter for digits
  
  li a2, 0xf0000000 # bit mask

  readch
  println
  beq a0, t0, plus
  beq a0, t1, minus
  beq a0, t2, and_
  beq a0, t3, or_
  
  j end
  
plus:
  add a4, a6, a5
  call process
  j plus

and_: 
  and a4, a6, a5
  call process
  j and_

or_:
  or a4, a6, a5
  call process
  j or_

minus:
  sub a4, a5, a6
  blt a4, zero, negate
  j no_negate

negate:
  addi t6, t6, 1 # flag for minus
  neg a4, a4 # abs num
  blt t6, zero, print_minus
  j no_negate

print_minus:
  li a0, 45
  printch
  j no_negate

no_negate:
  call process
  j minus

process:
  li t0, -4 # subtract the number of digits
  beq t5, t0, end # checking for the end of the operation

  and a3, a4, a2 # apply the mask
  srli a2, a2, 4 # shift the mask to the next discharge
  srl a3, a3, t5 # shift the num to the next discharge
  
  addi t5, t5, -4 # reducing the discharge counter
  mv a0, a3		  # loading the value of the current digit into a0
  j print # print digit

print: 
  inside 0, 10
  beq a1, zero, printnum
  j printlet

printnum:
  addi a0, a0, 48
  printch
  ret

printlet:
  addi a0, a0, 87
  printch
  ret

return:
  ret

end:
  exit 0

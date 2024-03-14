.include "simpleLib.asm"

.macro inside %x %y # t3 more or eq х and less у | t4, t5 - temp | t6 - result (inv)
  slti t4, t3, %y
  slti t5, t3, %x
  not t5, t5
  and t6, t4, t5
  addi t6, t6, -1
.end_macro

.macro readop_f %r1 %r2
  mv a2, %r1
  mv a3, %r2
  call readop
.end_macro
  
main:
  call read_hex # read 1 num -> a0
  mv t0, a0
  
  call read_hex # read 2 num -> a0
  mv t1, a0
  
  readop_f t0, t1 # read and perform operation func %r1, %r2 -> a0
  
  call print_hex # prints hex num on a0
  
  j end 


read_hex: # writes 7 digit nums to a0
  li a2, 7 # counter for input len
  li a3, 0 # counter for scan
  j read_hex1
        
read_hex1: 
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

readop: # reads and performs an operation %r1 ? %r2 -> a0
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
  add a0, a3, a2
  ret

minus:
  sub a0, a2, a3
  ret

and_: 
  and a0, a2, a3
  ret

or_:
  or a0, a2, a3
  ret

print_hex: #prints hex number on a0
  mv t1, a0
  li a4, 0xf0000000 # bit mask
  li a5, 28         # counter for digits
  j print_hex1

print_hex1:
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

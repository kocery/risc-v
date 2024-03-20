j endlib

.include "simpleLib.asm"

.eqv scr t5

.macro inside %res %arg %x %y # %arg more or eq � and less � | t4- temp | %res - result (inv)
  slti t4, %arg, %y
  slti scr, %arg, %x
  not scr, scr
  and %res, t4, scr
  addi %res, %res, -1
.end_macro

read_hex: # writes 8 digit nums to a0
  li a1, 0 # result hex
  li a2, 7 # counter for input len
  li a3, 0 # counter for scan
        
read_hex1: 
  readch
  mv t3, a0 
  
  li t1, 10 # return when <enter>
  beq t3, t1, return_hex
  
  addi t3, t3, -48
  
  inside t6, t3, 0, 10 #0 - 9
  beq t6, zero, add_
  
  inside t6, t3, 17, 23 #a - f
  addi t3, t3, -7
  beq t6, zero, add_
  
  inside t6, t3, 42, 48 #A - F
  addi t3, t3, -32
  beq t6, zero, add_
  
  error "incorrect input"
  
add_: # add hex digit to num | subfunc for read_hex
  slli a1, a1, 4
  add a1, a1, t3
  
  addi a3, a3, 1
  ble a3, a2, read_hex1
  
  j return_hex

return_hex:
  mv a0, a1
  ret

readop: # reads and performs an operation a0, a1 - values -> a0
  li t0, 43         # +
  li t1, 45         # -
  li t2, 38         # &
  li t3, 124        # |

	mv a2, a0
	mv a3, a1
  readch
  println
  beq a0, t0, plus
  beq a0, t1, minus
  beq a0, t2, and_
  beq a0, t3, or_
  
  error "Incorrect operation"
      
plus:
  add a0, a2, a3
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
  inside t6, t3, 0, 10
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

mul_hex: # a0 * a1 -> a0
  li t0, 1
  li t1, 0
  li t3, 0

mul_hex1:
  and t2, a1, t0
  beqz t2, mul_hex2
  sll t2, a0, t1
  add t3, t3, t2

mul_hex2:
  slli t0, t0, 1
  addi t1, t1, 1
  bnez t0, mul_hex1
  
  mv a0, t3
  ret

div10_hex:
	srli, a0, a0, 4
  ret

mod10_hex:
  slli a0, a0, 28
  srli a0, a0, 28
  ret

return:
  ret

end:
  exit 0

endlib:
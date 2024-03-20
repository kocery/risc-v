.include "simpleLib.asm"

j endlib

.eqv scr t5

.macro inside %res %arg %x %y # %arg more or eq õ and less ó | t4- temp | %res - result (inv)
  slti t4, %arg, %y
  slti scr, %arg, %x
  not scr, scr
  and %res, t4, scr
  addi %res, %res, -1
.end_macro

.macro take_nth %x %r %res # take x digit BCD num in %r | t4 - mask -> %res
  sll t4, t4, %x
  and scr, %r, t4
  srl scr, scr, %x
  mv %res, scr
  srl t4, t4, %x
.end_macro  

read_bcd: # writes 8 digit nums to a0
  li a1, 0 # result bcd
  li a2, 7 # counter for input len
  li a3, 0 # counter for scan
        
read_bcd1: 
  readch
  mv t3, a0 
  
  li t1, 10 # return when <enter>
  beq t3, t1, return_bcd
  
  addi t3, t3, -48
  
  inside t6, t3, 0, 10 #0 - 9
  beq t6, zero, add_
  
  error "incorrect input"
  
add_: # add bcd digit to num | subfunc for read_bcd
  slli a1, a1, 4
  add a1, a1, t3
  
  addi a3, a3, 1
  ble a3, a2, read_bcd1
  
  j return_bcd

return_bcd:
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
  
  error "Incorrect operation"
      
plus:
  add a7, a2, a3
  bltu a7, a2, overflow

	li t1, 6 # correction num
	li t2, 28 # max for discharge
	li t3, 0 # counter for discharge
	li t4, 0x0000000f # bit mask
	li t6, 9 # forbidden number

plus_correction:
	li t0, 0
	beq t2, t3, end_correction
	
	take_nth t3, a2, a4
	take_nth t3, a3, a5
	
	add t0, a4, a5
	bgt t0, t6, plus_correction1
	j plus_correction2
	
plus_correction1:
  sll t1, t1, t3
  add a7, a7, t1
  srl t1, t1, t3
  
plus_correction2:
	addi t3, t3, 4
  j plus_correction

minus:
  sub a7, a2, a3

	li t4, 0x0000000f # bit mask
	li t2, 32 # max for discharge
	li t3, 0 # counter for discharge

minus_correction:
	li t0, 0
	beq t2, t3, end_correction
	
	take_nth t3, a2, a4
	take_nth t3, a3, a5
	
	sub t0, a4, a5
	bltz t0, minus_correction1
	j minus_correction2
	
minus_correction1:
  li t1, 6
  sll t1, t1, t3
  sub a7, a7, t1
  
minus_correction2: # update counter and loop
	addi t3, t3, 4
  j minus_correction

end_correction:
	mv a0, a7
	ret

overflow:
	error "Overflow detected"  

print_bcd: #prints bcd number on a0
  mv t1, a0
  li a4, 0xf0000000 # bit mask
  li a5, 28         # counter for digits
  j print_bcd1

print_bcd1:
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
  j print_bcd1

printlet:
  addi a0, a0, 87
  printch
  j print_bcd1

return:
  ret

end:
  exit 0
  
endlib:
j endlib

.include "simpleLib.asm"

.eqv scr t5

.macro inside %res %arg %x %y # %arg more or eq õ and less ó | t4- temp | %res - result (inv)
  slti t4, %arg, %y
  slti scr, %arg, %x
  not scr, scr
  and %res, t4, scr
  addi %res, %res, -1
.end_macro

.macro detect_sign %r %x #detects sign of %x -> %r
	li scr, 1
	slli scr, scr, 31
	and %r, %x, scr
.end_macro

.macro ifabs %x %f #abs %x if %f else not
	beqz %f, not_need
	neg %x, %x
	not_need:
.end_macro

.macro unsign %x
	slli %x, %x, 1
	srli %x, %x, 1
.end_macro

div10dec: # a0 - num | uses t0, t1, t2, t3, a1, a2, a6
	detect_sign t3, a0
	ifabs a0, t3
	mv a6, a0

	srli t1, a6, 1
	srli t2, a6, 2
	add t0, t1, t2 # q = (n >> 1) + (n >> 2)
	
	srli t1, t0, 4
	add t0, t0, t1 # q = q + (q >> 4)
	
	srli t1, t0, 8
	add t0, t0, t1 # q = q + (q >> 8)
	
	srli t1, t0, 16
	add t0, t0, t1 # q = q + (q >> 16)
	
	srli t0, t0, 3 # q = q >> 3
	
	li a2, 10
	mv a1, t0
	push1 ra
	call multdec
	pop1 ra
	sub t1, a6, a0 # r = n - q*10
	
	addi t1, t1, 6
	srli t1, t1, 4
	add a0, t0, t1 # a0 = q + ((r + 6) >> 4)
	
	beqz t3, return
	neg a0, a0
	ret

mod10dec: # a0 -> mod a0 | uses: a1, a2, a6, t0, t1, t2, t3, t6
	mv t6, a0 # old
	push1 ra
	call div10dec
	pop1 ra
	
	mv a1, a0
	li a2, 10
	push1 ra
	call multdec
	pop1 ra
	
	sub a0, t6, a0
	ret

multdec: # a1 * a2 -> a0
	li a5, 2147483647
  detect_sign a3, a1
  ifabs a1, a3
  detect_sign a4, a2
  ifabs a2, a4
  
  xor a3, a3, a4
  li a0, 0

multdec1:
  beqz a1, return_mult
  beqz a2, return_mult
  bgtu a0, a5, overflow
  add a0, a0, a2
  addi a1, a1, -1
  j multdec1

return_mult:
	bnez a3, return_neg
	ret
	return_neg:
		neg a0, a0
		ret

read_dec:
	li a5, 0 # result dec
  li a3, 9 # counter for input len
  li a4, 0 # counter for scan
  li a6, 0 # flag for -

read_dec1:
	readch
  mv t3, a0 
  
  li t1, 10 # return when <enter>
  beq t3, t1, return_dec
  
  li t1, 45 # check for -
  bne t3, t1, read_dec2
  li scr, 1
  sub  a6, a6, scr
  beqz a6, incorrect
  li a6, 1 # flag for "-"
  j read_dec1

read_dec2:
  addi t3, t3, -48
  
  inside t6, t3, 0, 10 #0 - 9
  beq t6, zero, add_
  
  j incorrect

add_:
	mv a2, a5 # old
	
	li a1, 10
	push1 ra
	call multdec
	pop1 ra
	
	add a5, t3, a0

	addi a4, a4, 1
  ble a3, a4, read_dec1
  
  j return_dec

return_dec:
	mv a0, a5
	beqz a6, return
	neg a0, a0
	ret

incorrect:
	error "incorrect input"

overflow:
	error "Overflow detected"  

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

print_dec: #prints dec number on a0
	li a6, 0 # counter for discharge

  detect_sign a3, a0
	ifabs a0, a3
	beqz a3, print_dec1
  mv t1, a0
  li a0, 45 # print "-"
  printch
  mv a0, t1

print_dec1:
	mv t1, a0
	
	push3 ra, t1, a6
  call mod10dec
  pop3 ra, t1, a6
  
  mv t3, a0
  inside t6, t3, 0, 10
  beq t6, zero, print_dec2
  error "Incorret symbol"

print_dec2:
	addi a6, a6, 1
	mv a5, a0
	push1 a5
	
	mv a0, t1
  push3 ra, t0, a6
  call div10dec
  pop3 ra, t0, a6
  
  beqz a0, print_dec3
  j print_dec1

print_dec3:
	pop1 a5
	beqz a6, return
	mv a0, a5
  addi a0, a0, 48
  printch
  addi a6, a6, -1
  
  j print_dec3

return:
	ret
	
endlib:
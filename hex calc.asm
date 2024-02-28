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
    li a0, %ecode
    syscall 93
.end_macro

.macro inside %x %y # а0 больше или равно х и меньше у
  slti t0, a0, %y
  slti t1, a0, %x
  not t1, t1
  and a1, t0, t1
.end_macro
  
main:
  li gp, 1
  li s7, 0 # для '-'
  li t4, 6 # максимум 7 символов (сумма 8)
  li t5, 0 # счётчик 1 scan
  li t6, 0 # счётчик 2 scan
  
read1:
  li a1, 0

  readch # конец ввода <enter>
  li t0, 10
  beq a0, t0, read2
  
  addi a0, a0, -48
  addi s10, s10, 48
  
  inside 0, 10 #0 - 9
  beq a1, gp, addfirst
  
  inside 17, 23 #a - f
  addi a0, a0, -7
  addi s10, s10, 7
  beq a1, gp, addfirst
  
  inside 42, 48 #A - F
  addi a0, a0, -32
  addi s10, s10, 7
  beq a1, gp, addfirst
  
  j end
  
addfirst:
  slli s1, s1, 4
  add s1, s1, a0
  mv s0, a0
  add a0, a0, s10
  mv a0, s0
  
  addi t5, t5, 1 # обновление счётчика
  ble t5, t4, read1
  
  println
  j read2

read2:
  li a1, 0
  li s10, 0
  
  readch       # конец ввода <enter>
  li t0, 10
  beq a0, t0, readop
  
  addi a0, a0, -48
  addi s10, s10, 48
  
  inside 0, 10  #0 - 9
  beq a1, gp, addsecond
  
  inside 17, 23 #a - f 
  addi a0, a0, -7
  addi s10, s10, 7
  beq a1, gp, addsecond
  
  inside 42, 48 #A - F 
  addi a0, a0, -32
  addi s10, s10, 7
  beq a1, gp, addsecond
  
  j end
  
addsecond:
  slli s2, s2, 4 #сдвигаем разряд влево
  add s2, s2, a0
  mv s0, a0
  add a0, a0, s10
  mv a0, s0
  
  addi t6, t6, 1 # обновление счётчика
  ble t6, t4, read2
  
  println
  j readop

readop:
  readch
  println
  li t0, 43         # +
  li t1, 45         # -
  li a3, 38         # &
  li a4, 124        # |
  
  li t2, 0xf0000000 # рахрядная маска
  li t3, 28         # счётчик разрядов
  
  beq a0, t0, plus
  beq a0, t1, minus
  beq a0, a3, and_
  beq a0, a4, or_
  
  j end
  
plus:
  li t0, -4       # порог счётчика разрядов
  beq t3, t0, end
  
  add s3, s2, s1  # операция, которую делаем
  and s4, s3, t2 
  srli t2, t2, 4
  srl s4, s4, t3
  
  addi t3, t3, -4 # Уменьшаем счетчик разрядов
  mv a0, s4		  # Загружаем значение текущего разряда в a0
  
  inside 0, 10    # Проверяем, является ли цифра в a0 числом от 0 до 9
  beq a1, gp, printnum_add
  
  j printlet_plus

minus:
  li t0, -4
  beq t3, t0, end
  
  sub s3, s1, s2
  blt s3, zero, negate
  j no_negate

negate:
  addi s7, s7, 1
  neg s3, s3
  beq s7, gp, print_min
  j no_negate

print_min:
  li a0, 45
  printch
  j no_negate

no_negate:
  and s4, s3, t2
  srli t2, t2, 4
  srl s4, s4, t3
  
  addi t3, t3, -4
  mv a0, s4
  
  inside 0, 10
  beq a1, gp, printnum_sub
  
  j printlet_minus

and_:
  li t0, -4
  beq t3, t0, end
  
  and s3, s2, s1
  and s4, s3, t2
  srli t2, t2, 4
  srl s4, s4, t3
  
  addi t3, t3, -4
  mv a0, s4
  
  inside 0, 10
  beq a1, gp, printnum_and
  
  j printlet_and

or_:
  li t0, -4
  beq t3, t0, end
  
  or s3, s2, s1
  and s4, s3, t2
  srli t2, t2, 4
  srl s4, s4, t3
  
  addi t3, t3, -4
  mv a0, s4
  
  inside 0, 10
  beq a1, gp, printnum_or
  
  j printlet_or

printnum_add:
  addi a0, s4, 48
  printch
  j plus

printnum_sub:
  addi a0, s4, 48
  printch
  j minus

printnum_and:
  addi a0, s4, 48
  printch
  j and_ 
  
printnum_or:
  addi a0, s4, 48
  printch
  j or_ 
  
printlet_plus:
  addi a0, s4, 87
  printch
  j plus

printlet_minus:
  addi a0, s4, 87
  printch
  j minus
  
printlet_and:
  addi a0, s4, 87
  printch
  j and_  
  
printlet_or:
  addi a0, s4, 87
  printch
  j or_  

end:
  exit 0

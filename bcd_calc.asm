.include "bcd_lib.asm"


main:
  call read_bcd
  mv s0, a0
  println
  
  call read_bcd
  mv s1, a0
  println
  
  mv a0, s0
  mv a1, s1
  call readop
  
  call print_bcd
  
  call end

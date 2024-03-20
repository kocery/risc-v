.include "hex_lib.asm"

  
main:
  call read_hex # read 1 num -> a0
  mv s0, a0
  println
  
  call read_hex # read 2 num -> a0
  mv s1, a0
  println
  
  mv a0, s0
  mv a1, s1
  call readop # a0, a1 - 2 numbers -> a0
  
  call print_hex # prints hex num on a0
  
  call end 

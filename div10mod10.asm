.include "hex_lib.asm"


main:
  call read_hex # read 1 num -> a0
  
  call div10_hex
  
  call print_hex # prints hex num on a0
  println
  call read_hex # read 1 num -> a0
  
  call mod10_hex
  
  call print_hex # prints hex num on a0
  
  call end

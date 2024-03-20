.include "hex_lib.asm"


main:
  call read_hex
  mv s0, a0
  
  call read_hex
  mv s1, a0
  
  mv a0, s0
  mv a1, s1
  call mul_hex
  
  call print_hex
  
  j end 

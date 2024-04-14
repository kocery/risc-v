.include "dec_lib.asm"

main:
	call read_dec
  mv s9, a0
  println
  
  call read_dec
  mv s10, a0
  println
  
  mv a0, s9
  mv a1, s10
  call sdivAB
	
	call print_dec
	
	j end

end:
	exit 0

.include "dec_lib.asm"

main:
	call read_dec
  println
	call isqrt
	call print_dec

end:
	exit 0

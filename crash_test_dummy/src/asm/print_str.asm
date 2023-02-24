; print_str
; Inputs:
;   - SI: contains address of the string to be printed
print_str:
    pusha        ; save all registers
	mov ah, 0x0e ; Set BIOS Service to "write text in Teletype Mode"
.get_next_char:
	lodsb        ; al <- DS:SI and increment SI by one
	or al, al    ; It will set ZF if it is zero
	jz .done     ; And if it al == 0 we reach the end of the string
	int 0x10     ; otherwise print the character and go to next one...
	jmp .get_next_char
.done:
    popa         ; restore all registers
	ret

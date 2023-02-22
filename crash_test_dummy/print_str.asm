;; Print a string using BIOS TTY service
;  si: points to the beginning of the string and ends with '0'
print_str:
	pusha
	mov ah, 0x0e ; code of the service to write Char
.get_next_char:
	mov al, [si]
	or al, al ; Set ZF if it is zero
	jz .end
	int 0x10
	inc si
	jmp .get_next_char
.end:
	popa
	ret

print_newline:
	push si
	mov si, nextLine
	call print_str
	pop si
	ret

nextLine:  db 0xa, 0xd, 0
	; 0xa is line feed (move cursor down to next line)
	; 0xd is carriage return (return to the beginning)

; Kernel will setup screen mode, print some messages
; Bootloader will load us at 0x7E00

kernel:
	org 0x7E00

	; Set up mode 80x25 color text
	mov ah, 0x0
	mov al, 0x3
	int 0x10

	; Set color Palette
	mov ah, 0xb ; BIOS Service to set color palette
	mov bh, 0x0 ; set border color
	mov bl, 0x1 ; blue
	int 0x10

	; start writing something
	mov si, helloTest ; si "points" to helloStr
	call print_str
	call print_newline

	mov dx, 0x123A     ; Set dx to the value we will print
	mov si, hexaTest   ; Set the string we want to print
	call print_str     ; print the string
	call print_hex	   ; print the value of dx
	call print_newline

	mov si, kernelEnds
	call print_str

	cli
	hlt

%include "print_str.asm"
%include "print_hex.asm"

helloTest: db "Hello, World!", 0
hexaTest:  db "test dump dx: ", 0
kernelEnds: db "Kernel ended", 0

	times 512-($-$$) db 0 ; padding with 0s

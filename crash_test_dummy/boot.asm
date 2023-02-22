; Interrupt 10H is video services
;
; https://grandidierite.github.io/bios-interrupts/
; https://en.wikipedia.org/wiki/BIOS_color_attributes
;
; Set video mode
;   AH = 0x0
;   AL = Mode
;
; Set Color Palette
;   AH = 0xb
;   BH = Palette color ID (0 or 1)
;   BL = Color or palette value to be used with color ID (0-31)
;
; Write Char in TTY (TeleTYpe mode)
;   AH = 0x0e
;   AL = Character to write
;   BL = Foreground color (graphics mode only)
;   BH = Display page number (text modes only)

	org 0x7C00 ; The code is loaded at 0x7C00 by the bootloader
		   ; We need to set it otherwise when later in the code
		   ; we will refer to memory location the address will be
		   ; wrong. For example mov al, [outputChar] will not work.

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
	call print_string

	mov dx, 0x123A    ; Set dx to the value we will print
	mov si, hexTest   ; Set the string we want to print
	call print_string ; print the string
	call print_hex	  ; print the value of dx
	mov si, nextLine
	call print_string ; go to the next line

infinite_loop:
	jmp infinite_loop

%include "print_string.asm"
%include "print_hex.asm"

nextLine:  db 0xa, 0xd, 0
	; 0xa is line feed (move cursor down to next line)
	; 0xd is carriage return (return to the beginning)
helloTest: db "Hello, World!", 0xa, 0xd, 0
hexTest:   db "test dump dx: ", 0

	times 510-($-$$) db 0 ; padding with 0s
	dw 0xaa55  ; BIOS magic number

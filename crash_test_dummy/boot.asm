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
	call print_str
	call print_newline

	mov dx, 0x123A     ; Set dx to the value we will print
	mov si, hexaTest   ; Set the string we want to print
	call print_str     ; print the string
	call print_hex	   ; print the value of dx
	call print_newline

	; This is the end...
	cli
	hlt

%include "print_str.asm"
%include "print_hex.asm"

helloTest: db "Hello, World!", 0
hexaTest:  db "test dump dx: ", 0

	times 510-($-$$) db 0 ; padding with 0s
	dw 0xaa55  ; BIOS magic number

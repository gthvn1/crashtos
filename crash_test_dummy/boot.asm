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
	mov si, helloStr ; bx "points" to helloStr
	call print_string

	mov si, worldStr
	call print_string

infinite_loop:
	jmp infinite_loop

%include "print_string.asm"

helloStr: db "Hello,", 0xa, 0 ; 0xa is line feed (move cursor down to next line)
worldStr: db "World!", 0xa, 0xd, 0 ; 0xd is carriage return (return to the beginning)
; We should see when printing:
; Hello,
;       World!

	times 510-($-$$) db 0 ; padding with 0s
	dw 0xaa55  ; BIOS magic number

; Interrupt 10H is video services
;
; https://grandidierite.github.io/bios-interrupts/
; https://en.wikipedia.org/wiki/BIOS_color_attributes
;
; Set video mode
;   AH = 0x0
;   AL = Mode
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

	; Set up mode to VGA 640x480 16 colors
	mov ah, 0x0
	mov al, 0x12
	int 0x10

	; start writing something
	mov ah, 0x0e ; code of the service to write Char
	mov bl, 0xa  ; Light Green
	mov si, helloStr ; bx "points" to helloStr
	call print_string

	mov si, worldStr
	call print_string

infinite_loop:
	jmp infinite_loop

; print_chars
;  si: points to the beginning of the string and ends with '0'
print_string:
	mov al, [si]
	or al, al ; Set ZF if it is zero
	jnz print_char
	ret
print_char:
	int 0x10
	inc si
	jmp print_string

helloStr: db "Hello,", 0xa, 0 ; 0xa is line feed (move cursor down to next line)
worldStr: db "World!", 0xa, 0xd, 0 ; 0xd is carriage return (return to the beginning)
; We should see when printing:
; Hello,
;       World!

	times 510-($-$$) db 0 ; padding with 0s
	dw 0xaa55  ; BIOS magic number

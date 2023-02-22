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

	mov ah, 0x0
	mov al, 0x12
	int 0x10 ; change mode to VGA 640x480 16 colors

	mov bl, 0xa  ; Light Green

	mov ah, 0x0e
	mov al, [outputChar]
	int 0x10

loop:
	jmp loop

outputChar: db 'Z', 0

	times 510-($-$$) db 0 ; padding with 0s
	dw 0xaa55  ; BIOS magic number

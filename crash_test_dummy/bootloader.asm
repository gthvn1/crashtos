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

	xor bx, bx     ; bx == 0x0000
	mov es, bx     ; es == 0x0000
	mov bx, 0x7E00 ; [es:bx] == 0x7E00

	call read_chs
	jmp 0x7E00

	; This is the end...
	cli
	hlt

%include "print_str.asm"
%include "print_hex.asm"
%include "read_chs.asm"

	times 510-($-$$) db 0 ; padding with 0s
	dw 0xaa55  ; BIOS magic number

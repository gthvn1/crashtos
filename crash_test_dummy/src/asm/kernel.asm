;; ============================================================================
;; kernel.asm
;;
;; Kernel will:
;;	- setup screen mode
;;	- print the hello world !!!
;;
;; Bootloader will load us at 0x7E00
;;
;; Interrupt 10H is video services
;;
;; https://grandidierite.github.io/bios-interrupts/
;; https://en.wikipedia.org/wiki/BIOS_color_attributes
;;
;; Set video mode
;;   AH = 0x0
;;   AL = Mode
;;
;; Set Color Palette
;;   AH = 0xb
;;   BH = Palette color ID (0 or 1)
;;   BL = Color or palette value to be used with color ID (0-31)
;;
;; Write Char in TTY (TeleTYpe mode)
;;   AH = 0x0e
;;   AL = Character to write
;;   BL = Foreground color (graphics mode only)
;;   BH = Display page number (text modes only)

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

	; say hello
	mov si, helloFromCTD ; si "points" to helloStr
	call print_str

	;; infinite loop
infinite_loop:
	hlt
	jmp infinite_loop

print_str:
	mov ah, 0x0e ; code of the service to write Char
.get_next_char:
	lodsb     ; al <- DS:SI and increment SI by one
	or al, al ; Set ZF if it is zero
	jz .done
	int 0x10
	jmp .get_next_char
.done:
	ret

helloFromCTD: db "Crash Test Dummy loaded!", 0xa, 0xd, 0
	; 0xa is line feed (move cursor down to next line)
	; 0xd is carriage return (return to the beginning)

	times 512-($-$$) db 0 ; padding with 0s

; boot.asm
[BITS 16] ; real mode (not really needed but seems clean)
; The program expects to be loaded at 0x7C00 in memory
; by the BIOS
[ORG 0x7C00]
	cli
	xor ax, ax ; ax == 0x0
	mov ds, ax ; BIOS interrupts expect DS to be set

	mov si, msg
	cld ; clear DF flag in EFLAGS register
	    ; => increment index register when doing string operations

print_ah:
	lodsb		; load DS:SI into AL and increment SI
	or al, al	; "or-ing" will set ZF flags if al == 0
	jz infinite_loop
	mov ah, 0xE	; Code for printing AL
	int 0x10	; Bios interrupt
	jmp print_ah

infinite_loop:
	jmp infinite_loop

; Data
msg db 'Hello, World!', 0  ; String end with 0 to detect the end when looping

; Fill the rest with 0 and at the end add the bootloader signature
times 510-($-$$) db 0
db 0x55
db 0xAA

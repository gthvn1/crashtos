;; Primary boot loader resides in 512 bytes
;; program code + partition table
;; The last two bytes contains 0xAA55

;; Compile with: nasm boot.asm -f bin -o boot.bin
;; Run with    : qemy-system-i386 -fda boot.bin

org 0x7C00 ;; this is the BIOS that loads us here

bits 16 ;; When we boot we are in real mode (16-bit mode)

start:
	cli		;; disable interrupts
	mov si, msg	;; si: source index
			;; it is used as a source for data copies
	mov ah, 0x0E    ;; a parameter for the BIOS
			;; => 0Eh: Write character in TTY mode
.loop	lodsb		;; load byte at DS:SI into AL (in legacy mode)
	or al, al	;; We put 0 at the end of msg
	jz halt		;; thus jump if al == 0
	int 0x10	;; invoke the BIOS interrupt (ie 0x10) 
	jmp .loop	;; Same player shoot again

halt: hlt		;; halt the execution

msg: db "Hello, World!", 0 ;; store the string constant

;; Magic numbers
times 510 - ($ - $$) db 0
dw 0xAA55

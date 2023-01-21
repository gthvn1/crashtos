;; Primary boot loader resides in 512 bytes
;; program code + partition table
;; The last two bytes contains 0xAA55

;; Compile with: nasm boot.asm -f bin -o boot.bin
;; Run with    : qemy-system-i386 -fda boot.bin

[org 0x7C00] ;; this is the BIOS that loads us here.
	     ;; ORG is a directive for nasm for flat bin file

[bits 16] ;; When we boot we are in real mode (16-bit mode)

start:
	cli		;; disable interrupts

	mov si, msg	;; si: source index
			;; it is used as a source for data copies
	mov ah, 0x0E    ;; a parameter for the BIOS
			;; => 0Eh: Write character in TTY mode
.loop	lodsb		;; load byte at DS:SI into AL (in legacy mode)
	or al, al	;; 0 at the end of msg => OR will set ZF
	je check_a20	;; thus jump if ZF == 1 (ZF is Zero Flag)
	int 0x10	;; invoke the BIOS interrupt (ie 0x10) 
	jmp .loop	;; Same player shoot again

check_a20:
	xor ax, ax	;; ax <- 0
	mov es, ax	;; es <- 0
	not ax		;; ax <- 0xFFFF
	mov ds, ax	;; ds <- 0xFFFF

	mov di, 0x0500
	mov si, 0x0510

	mov byte [es:di], 0x00	;; [0x500] <- 0x0
	mov byte [ds:si], 0xFF  ;; [0xFFFF0 + 0x0510 = 0x100500] <- 0xFF

	;; so here if A20 is disabled memory wraps around and we will
	;; overwrite 0x500. With qemu it is activated by default.
	mov al, byte [es:di]	;; al <- 0x0500 (can be 0x0 or 0xFF depending of A20 status)
				;; if al == 0 then A20 is enabled
				;;            else A20 is disabled

	;; You can use the debugger to test it. To have a qemu with A20 disabled
	;; you need to recompile the BIOS I think...
	jmp halt

halt:
	hlt		 ;; halt the execution

msg: db "Hello, World!", 0 ;; store the string constant

;; Magic numbers
times 510 - ($ - $$) db 0
dw 0xAA55

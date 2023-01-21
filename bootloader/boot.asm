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
	je boot	;; thus jump if ZF == 1 (ZF is Zero Flag)
	int 0x10	;; invoke the BIOS interrupt (ie 0x10)
	jmp .loop	;; Same player shoot again

boot:
;;check_a20:
;;;; Disable A20
;;mov ax, 0x2400
;;int 0x15
;;
;;;; A20 should be disabled here
;;xor ax, ax	;; ax <- 0
;;mov es, ax	;; es <- 0
;;not ax		;; ax <- 0xFFFF
;;mov ds, ax	;; ds <- 0xFFFF
;;
;;mov di, 0x0500
;;mov si, 0x0510
;;
;;mov byte [es:di], 0x00	;; [0x500] <- 0x0
;;mov byte [ds:si], 0xFF  ;; [0xFFFF0 + 0x0510 = 0x100500] <- 0xFF
;;
;;;; so here if A20 is disabled memory wraps around and we will
;;;; overwrite 0x500. With qemu it is activated by default.
;;mov al, byte [es:di]	;; al <- 0x0500 (can be 0x0 or 0xFF depending of A20 status)
;;			;; if al == 0 then A20 is enabled
;;			;;            else A20 is disabled
;;
;;;; You can use the debugger to test it. To have a qemu with A20 disabled
;;;; you need to recompile the BIOS I think...

	;; enable A20
	mov ax, 0x2401
	int 0x15

	;; We can also check with BIOS
	;;mov ax, 0x2402
	;;int 0x15

	;;enable_gdt
	lgdt [gdt_pointer]	;; load the GDT table

	;;set_protected_mode
	mov eax, cr0	;; CR is a Control Register
	or eax, 0x1	;; bit0 : PE (1 == Protected Mode)
	mov cr0, eax	;; PROTECTED MODE ENABLED !!!

	;; let's halt for now but soon we will do more intresting
	;; things
	jmp CODE_SEGMENT:halt

;; Before halt we can define the GDT here
gdt_start:		;; First 64 bits segment is null segment descriptor
	dq 0x0
gdt_code:		;; Code segment descriptor (64 bits)
	dw 0xFFFF	;; segment limit
	dw 0x0		;; base address 0-15
	db 0x0		;; base address 16-23
	db 10011010b	;; Type: 1001(9), S: 1, DPL: 1, P: 0
	db 11001111b	;; Limit: 1100(12), A:1, Res, DB: 1, G:1
	db 0x0		;; base address 24-31
gdt_data:
	dw 0xFFFF
	dw 0x0
	db 0x0
	db 10010010b	;; Type: 1001(9), S: 0, DPL: 1, P: 0
	db 11001111b
	db 0x0
gdt_end:

gdt_pointer:	;; GDT descriptor
	dw gdt_end - gdt_start	;; size on 16 bits (dw)
	dd gdt_start		;; address on 32 bits (dd)

CODE_SEGMENT equ gdt_code - gdt_start
DATA_SEGMENT equ gdt_data - gdt_start


[bits 32]

halt:
	;; Before halting let set DATA segments so it will
	;; help to find the code when debugging...
	;; CS: code segment
	;; DS: data segment
	;; SS: stack segment
	;; ES: extra segment (default segment for string operations)
	;; FS, GS: dowhatyouwant register
	mov ax, DATA_SEGMENT
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	hlt		 ;; halt the execution

msg: db "Hello, World!", 0 ;; store the string constant

;; Magic numbers
times 510 - ($ - $$) db 0
dw 0xAA55

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

	;;set vga text mode
	mov ax, 0x3
	int 0x10

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
	jmp CODE_SEGMENT:boot

[bits 32]

boot:
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

	mov word [0xb8000], 0x0E48 ; 0x0: background black, 0xE: foreground yellow, 0x48:H
	mov word [0xb8002], 0x0E65 ; e
	mov word [0xb8004], 0x0E6c ; l
	mov word [0xb8006], 0x0E6c ; l
	mov word [0xb8008], 0x0E6f ; o
	mov word [0xb800a], 0x0E2c ; ,
	mov word [0xb800c], 0x0E20 ;
	mov word [0xb800e], 0x0E77 ; w
	mov word [0xb8010], 0x0E6f ; o
	mov word [0xb8012], 0x0E72 ; r
	mov word [0xb8014], 0x0E6c ; l
	mov word [0xb8016], 0x0E64 ; d
	mov word [0xb8018], 0x0E21 ; !

halt:
	hlt		 ;; halt the execution

;; *************************************************************************
;; Let's put DATA here...

%define MAKE_GDT_ENTRY(base, limit, access, flags) \
	(((base & 0x00FFFFFF) << 16)	| \
	 ((base & 0xFF000000) << 32)	| \
	  (limit & 0x0000FFFF)		| \
	 ((limit & 0x000F0000) << 32)	| \
	 ((access & 0xFF) << 40)	| \
	 ((flags & 0x0F) << 52))

;; Before halt we can define the GDT here
gdt_start:		;; First 64 bits segment is null segment descriptor
	dq MAKE_GDT_ENTRY(0, 0, 0, 0)   ;; NULL descriptor must be the first entry
gdt_code:		;; Code segment descriptor (64 bits)
	;; access => P:1, DPL:0, S: 1 (code or data), E:1 (code), DC:0 (grows up)
	;;	     RW:1 (read allowed), A:0 (accessed bit, best left clear)
	;; flags  => G:1, DB:1 (32bit segment), L:0, AVL: 0
	dq MAKE_GDT_ENTRY(0, 0xFFFF, 10011010b, 1100b)
gdt_data:
	;; access => P:1, DPL:0, S: 1 (code or data), E:0 (data), DC:0 (grows up)
	;;	     RW:1 (read allowed), A:0 (accessed bit, best left clear)
	;; flags  => G:1, DB:1 (32bit segment), L:0, AVL: 0
	dq MAKE_GDT_ENTRY(0, 0xFFFF, 10010010b, 1100b)
gdt_end:

gdt_pointer:	;; GDT descriptor
	dw gdt_end - gdt_start	;; size on 16 bits (dw)
	dd gdt_start		;; address on 32 bits (dd)

CODE_SEGMENT equ gdt_code - gdt_start
DATA_SEGMENT equ gdt_data - gdt_start

;; Magic numbers
times 510 - ($ - $$) db 0
dw 0xAA55

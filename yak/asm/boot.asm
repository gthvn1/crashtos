global _start	;; make _start label available outside this form
extern kmain

bits 32

; Looking at https://www.gnu.org/software/grub/manual/multiboot/multiboot.html we
; see that:
;   - interrupts must be disabled until sets up its own IDT
;   - stack must be created as soon as possible
;   - even though the segment register are set up with correct offset, limit and 32-bit
;     read/execute for CS and 32-bit read/write for other segments the exact values are
;     all *UNDEFINED*
;
; We almost copy the print_XXX functions
; from https://github.com/gthvn1/yet-another-kernel/blob/master/babysteps/boot.asm
; All details about the implementation (I think about the hexa dump) can be found over there.

; As seen we must provide a stack. We allocate 16Ko.
; Remember that stack grows downards on x86 so top is the bottom ;-p
section .bss

stack_bottom:
	resb 16384; allocate 16KB (16*1024)
stack_top:

section .text
_start:
	cli ; until IDT is set ensure that interrupt are disabled

	; setup the stack
	mov esp, stack_top

	; setup new GDT 
	call setup_gdt

	; TODO:
	;   - setup IDT

	call kmain

unreachable:
	jmp unreachable

; --------
setup_gdt:
	lgdt [gdt_desc]

	; Once loaded we need to reload it
	jmp 0x8:setup_gdt.reload_cs
.reload_cs:
	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	ret

section .data

; We followed the Long Mode Setup from https://wiki.osdev.org/GDT_Tutorial
; GDT entry are 8 bytes long
;
; An entry is:
; +-------------------------------------------------------------------------------+
; | Base @(24-31) |G|DB| |A|Limit (16-19)|P|DPL(13-14)|S|Type(8-11)|Base @(16-23) |
; +-------------------------------------------------------------------------------+
; |    Base address (Bit 0-15)           |      Segment Limit                     |
; +-------------------------------------------------------------------------------+
;
; 0x00: keep it NULL
; 0x08: Kernel Code Seg (Base: 0x0, Limit: 0xFFFFF, Access Byte: 0x9A, Flags: 0xC)
; 0x10: Kernel Data Seg (Base: 0x0, Limit: 0xFFFFF, Access Byte: 0x92, Flags: 0xC)
; 0x18: User Code Seg   (Base: 0x0, Limit: 0xFFFFF, Access Byte: 0xFA, Flags: 0xC)
; 0x20: User Data Seg   (Base: 0x0, Limit: 0xFFFFF, Access Byte: 0xF2, Flags: 0xC)
; 0x28: Task State Seg  ...TO BE DONE

gdt:
.start:
	dd 0      ; null descriptor
	dd 0
.kernel_code:
	dw 0xFFFF ; Segment Limit
	dw 0x0    ; Base@ low
	db 0x0    ; Base@ mid
	db 0x9A   ; Access Byte: 1001_1010
	db 0xCF   ; Flags + Seg length(16-19)
	db 0x0    ; Base@ hi
.kernel_data:
	dw 0xFFFF ; Segment Limit
	dw 0x0    ; Base@ low
	db 0x0    ; Base@ mid
	db 0x92   ; Access Byte: 1001_0010
	db 0xCF   ; Flags + Seg length(16-19)
	db 0x0    ; Base@ hi
.user_code:
	dw 0xFFFF ; Segment Limit
	dw 0x0    ; Base@ low
	db 0x0    ; Base@ mid
	db 0xFA   ; Access Byte
	db 0xCF   ; Flags + Seg length(16-19)
	db 0x0    ; Base@ hi
.user_data:
	dw 0xFFFF ; Segment Limit
	dw 0x0    ; Base@ low
	db 0x0    ; Base@ mid
	db 0xF2   ; Access Byte
	db 0xCF   ; Flags + Seg length(16-19)
	db 0x0    ; Base@ hi
.end:

; We can now define the GDT descriptor that will be passed to lgdt
; https://wiki.osdev.org/Global_Descriptor_Table#GDTR
gdt_desc:
	dw gdt.end - gdt.start - 1 ; size of the table in bytes subtracted by 1
	dd gdt.start               ; the linear address of the GDT

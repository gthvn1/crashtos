global start	;; make start label available outside this form
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
start:
	cli ; until IDT is set ensure that interrupt are disabled

	; setup the stack
	mov esp, stack_top

	; TODO:
	;   - setup GDT
	;   - setup IDT
	call kmain

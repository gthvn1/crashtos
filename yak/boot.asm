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

	mov esi, helloMsg
	call print_string

	call kmain

;; ----- Print functions ------------------------------------------------------
print_trampoline:
	call print_char

print_string:
	mov eax, [esi]  ; put char in AL
	lea esi, [esi+1] ; load the effective address of the next caracter into esi
	cmp al, 0
	jne print_trampoline
	add byte [ypos], 1  ; string is printed, go to the next line
	mov byte [xpos], 0
	ret

print_char:
	mov ah, 0x1E ; write yellow on blue
	mov ecx, eax ; save attribute

	movzx eax, byte [ypos]
	mov edx, 160 ; attribute is 2 bytes and we have 80 cols
	mul edx	; we juste computed the offset relative to ypos
		; eax = y * 160
	movzx ebx, byte [xpos]
	shl ebx, 1 ; ebx = 2 * x (because an attribute is 2 bytes) so the offset relative
		   ; to x is xpos * 2
	mov edi, 0xB8000 ; video's memory starts here and we are in protected mode
	add edi, eax     ; Add the offset relative to ypos
	add edi, ebx     ; Add the offset relative to xpos

	mov eax, ecx ; restore attribute
	mov word [ds:edi], ax
	add byte [xpos], 1 ; update xpos

	ret

print_eax:
	mov edi, outString
	mov esi, hexaString
	mov ecx, 8 ; 8x 4bits, so we will loop 8 times
.hexloop:
	rol eax, 4
	mov ebx, eax
	and ebx, 0x0F
	mov bl, [esi+ebx]
	mov [edi], bl
	inc edi
	dec ecx
	jnz .hexloop

	mov esi, outString
	call print_string

	ret

section .data

helloMsg   db "Welcome to YaK, Yet another Kernel!", 0  ; String end with 0 to detect the end when looping
xpos       db 0
ypos       db 0

hexaString   db "0123456789ABCDEF"
outString db "00000000", 0  ; will contain the output string

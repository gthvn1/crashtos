; boot.asm
[BITS 16] ; real mode (not really needed but seems clean)
; The program expects to be loaded at 0x7C00 in memory
; by the BIOS
[ORG 0x7C00]
	cli
	xor ax, ax ; ax == 0x0
	mov ds, ax ; BIOS interrupts expect DS to be set
	mov ss, ax ; We will setup a stack to be able to use call and ret
	mov sp, 0x9C00 ; far enough from code

	cld ; clear DF flag in EFLAGS register
	    ; => increment index register when doing string operations

	mov ax, 0xB800
	mov es, ax ; In real mode segment is shifted so es:0000 <=> 0xB8000
		   ; and 0xB8000 is where video's memory is mapped.

	; Say Hello
	mov si, hello_msg
	call print_string

	; And Welcome to this fantastic world !!!
	mov si, welcome_msg
	call print_string

;; ----- This is the end...
infinite_loop:
	jmp infinite_loop

;; ----- Print functions
print_trampoline:
	call print_char
print_string:
	lodsb		; load DS:SI into AL and increment SI
	or al, al	; "or-ing" will set ZF flags to 0 if al == 0
	jnz print_trampoline ; the trick here is that we jump to the trampoline that will
	; call the print_char. So when the print_char will return the next instruction that
	; will be executed is the lodsb.
	; else al == 0 and so we reach the end of the string, so just go to the next line
	; and return (we don't check if we overflow the video's memory)...
	add byte [ypos], 1 ; we suppose that we don't reach the end of the screen
	mov byte [xpos], 0 ; go to the beginning of the line
	ret

print_char:
	mov ah, 0x1E; 0x1 is for blue background and 0xE is for yellow foreground
	mov cx, ax  ; save attribute (rememer ASCII has been loaded in AL)

	movzx ax, byte [ypos] ; move ypos into ax and extend with zeros
	mov dx, 160 ; There are 2 bytes and 80 columns
	mul dx ; ax = ax * 160 (the offset computed for y)

	movzx bx, byte [xpos]
	shl bx, 1 ; Shift left is equivalent to mult by 2. As there are 2 bytes
	          ; for attribute if x == 4 then the offset for x is +8

	; So in ax we have the shift according to ypos, in bx we have the shift
	; according to xpos if we add the two we have our position :-)
	mov di, 0
	add di, ax
	add di, bx

	mov ax, cx ; restore the attribute (BG, FG, ASCII code)
	stosw ; Store AX at ES:DI => Print the character

	add byte [xpos], 1 ; Update the position, we don't wrap
	ret

; Data
hello_msg db 'Hello, World!', 0  ; String end with 0 to detect the end when looping
welcome_msg db 'Welcome to the real mode...', 0
xpos db 0
ypos db 0

; Fill the rest with 0 and at the end add the bootloader signature
times 510-($-$$) db 0
db 0x55
db 0xAA

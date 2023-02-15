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
	mov si, helloMsg
	call print_string

	; And Welcome to this fantastic world !!!
	mov si, welcomeMsg
	call print_string

	; Next we want to print the content [0xB8000]
	mov si, contentOfMem0
	call print_string

	mov bx, 0x0000  ; the offset, here we read the first byte
	mov ax, [es:bx] ; ax == [0xB8000] (content of the memory)
	call print_ax

	; and finally we want to print the content [0xB8004]
	; that is the next caracter written...
	mov si, contentOfMem1
	call print_string

	mov bx, 0x0004  ; the offset, here we read the first byte
	mov ax, [es:bx] ; ax == [0xB8001] (content of the memory)
	call print_ax

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

print_ax:
	mov di, outputString
	mov si, hexaString
	mov cx, 4 ; Need to loop four times (see below for explanations)
.hexloop:
	; What we want is to translate the value of AX into readable hexaStringing
	; For example:
	; AX = 1E48 should print "1E48"
	; in binary it is 0001_1110_0100_1000
	; For this we will:
	;     1) use the shift rotate:
	;         => ax -> 1110_0100_1000_0001 (the first 4 bits are now at the end)
	;     2) We will extract the last four bits to get 0000_0000_0000_0001
	;       This new value is in fact the index in the hexaString
	;        => 0001 => index 1 in "012..." that is "1"
	;     3) add the caracter at the given index in outputString
	; We do this four times (this is why CX == 0x4 ;-)
	rol ax, 4         ; 1)
	mov bx, ax        ; save ax into bx
	and bx, 0x0f      ; 2) get last 4 bits (the index into hexaString)
	mov bl, [si + bx] ; BL contains the corresponding hexacar
	mov [di], bl      ; 3) copy it into outputString
	inc di		  ; next car in outsring16
	dec cx            ; do it for the next 4 bits if needed
	jnz .hexloop

	; We can now print the outputString...
	mov si, outputString
	call print_string
	ret

; Data
helloMsg   db "Hello, World!", 0  ; String end with 0 to detect the end when looping
welcomeMsg db "Welcome to the real mode...", 0
xpos	   db 0
ypos       db 0

contentOfMem0 db "[0xB8000]", 0
contentOfMem1 db "[0xB8004]", 0

hexaString     db "0123456789ABCDEF"
outputString   db "0000", 0  ; will contain the output string

; Fill the rest with 0 and at the end add the bootloader signature
times 510-($-$$) db 0
db 0x55
db 0xAA

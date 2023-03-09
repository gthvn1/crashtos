;; ----------------------------------------------------------------------------
;; clear_screen.asm
;;
;; clear screen by writing space in Video Memory

clear_screen:
    push eax
    push ecx
    push es
    push edi

    mov edi, 0xB8000

    xor eax, eax
    mov al, ' '      ; We will print space character
    mov ah, 0x0A     ; BG: black, FG: light green...
    mov ecx, 80 * 25 ; We want to clean the screen that is 80 x 25

    .loop:
    cmp ecx, 0
    je .end

    mov [edi], ax
    add edi, 2
    dec ecx
    jmp .loop

.end:
    pop edi
    pop es
    pop ecx
    pop eax
    ret

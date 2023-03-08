;; ----------------------------------------------------------------------------
;; clear_screen.asm
;;
;; clear screen by writing space in Video Memory

clear_screen:
    push ax
    push cx
    push es
    push di

    mov ax, 0xB800
    mov es, ax  ; Set ES to video memory
    xor ax, ax
    mov di, ax  ; [ES:DI] is set to the beginning of video memory

    mov al, ' '     ; We will print space character
    mov ah, 0x0A    ; BG: black, FG: light green...
    mov cx, 80 * 25 ; We want to clean the screen that is 80x25
    rep stosw       ; Repeat CX times

    pop di
    pop es
    pop cx
    pop ax
    ret

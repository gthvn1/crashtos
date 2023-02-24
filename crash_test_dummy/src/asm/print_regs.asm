;; ============================================================================
;; print_regs.asm
;;
;; It should be included with print_str and print_hex

print_regs:

    push dx                       ; save dx on the stack

    ; print ax
    mov byte [regString + 2], 'a' ; replace the 2 char that is the 'd' of regString
    mov si, regString
    call print_str
    mov dx, ax
    call print_hex

    ; print bx
    mov byte [regString + 2], 'b'
    mov si, regString
    call print_str
    mov dx, bx
    call print_hex

    ; print cx
    mov byte [regString + 2], 'c'
    mov si, regString
    call print_str
    mov dx, cx
    call print_hex

    ; print dx
    mov byte [regString + 2], 'd'
    mov si, regString
    call print_str
    pop dx
    call print_hex
    push dx             ; save it again

    ; print si
    mov word [regString + 2], 'si'
    mov si, regString
    call print_str
    mov dx, si
    call print_hex

    ; print di
    mov byte [regString + 2], 'd'
    mov si, regString
    call print_str
    mov dx, di
    call print_hex

    ; print cs
    mov word [regString + 2], 'cs'
    mov si, regString
    call print_str
    mov dx, cs
    call print_hex

    ; print ds
    mov byte [regString + 2], 'd'
    mov si, regString
    call print_str
    mov dx, ds
    call print_hex

    ; print es
    mov byte [regString + 2], 'e'
    mov si, regString
    call print_str
    mov dx, es
    call print_hex

    pop dx
    ret

regString: db 0xa, 0xd, 'dx             ', 0

;; ============================================================================
;; print_line.asm
;;
;; Print string on the screen at a given line (the row) passed as parameters.
;; We suppose that video mode is set on 80x25.
;;
;; Params:
;;   - string to print
;;   - color attribute
;;   - row
;; ============================================================================

print_line:
    push bp    ; save old base pointer
    mov bp, sp ; use the current stack pointer as new base pointer

    push ax
    push di
    push ds
    push es
    push si

    ; We need to compute the row according to the parameter.
    ; One line is 80 columns and for each character we wrote two bytes (the
    ; attribute)
    movzx ax, [bp + 4] ; It contains the row X
    mov dx, 160        ; 80 * 2
    mul dx             ; ax = ax * dx so we have the offset now where to write
    mov di, ax

    mov ax, 0xB800
    mov es, ax ; ES <- Video Memory so now [ES:DI] points to the right location

    mov ax, [bp + 6] ; The color attribute
    mov si, [bp + 8] ; string to be printed

get_next_char:
    lodsb      ; al <- DS:SI and increment SI by one
    or al, al  ; It will set ZF if it is zero
    jz .done    ; And if it al == 0 we reach the end of the string

    stosw      ; [ES:DI] <- AH:AL where AH is the color and AL the ASCII
    jmp get_next_char

.done:
    pop si
    pop es
    pop ds
    pop di
    pop ax

    mov sp, bp
    pop bp
    ret

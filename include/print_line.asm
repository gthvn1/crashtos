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
    push ebp    ; save old base pointer
    mov ebp, esp ; use the current stack pointer as new base pointer

    push eax
    push edi
    push edx
    push esi

    ; We need to compute the row according to the parameter.
    ; One line is 80 columns and for each character we wrote two bytes (the
    ; attribute)
    mov eax, [ebp + 8] ; It contains the row X
    mov edx, 160       ; 80 * 2
    mul edx            ; ax = ax * dx so we have the offset now where to write
    add eax, 0xB8000
    mov edi, eax

    ; Get the color attribute
    mov eax, [bp + 12]

    ; Get the string to be printed
    mov esi, [bp + 16]

.get_next_char:
    mov al, [ESI]
    or al, al  ; It will set ZF if it is zero
    jz .done   ; And if it al == 0 we reach the end of the string

    mov [EDI], ax
    add EDI, 2
    add ESI, 1
    jmp .get_next_char

.done:
    pop esi
    pop edx
    pop edi
    pop eax

    mov esp, ebp
    pop ebp
    ret

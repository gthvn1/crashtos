;; ============================================================================
;; print_line.asm
;;
;; Print string on the screen at a given line (the row) passed as parameters.
;; We suppose that video mode is set on 80x25.
;;
;; Params:
;;   - string to print
;;   - color attribute
;; ============================================================================
print_line:
    push ebp    ; save old base pointer
    mov ebp, esp ; use the current stack pointer as new base pointer

    ; save registers
    push eax
    push edi
    push edx
    push esi

    mov esi, [bp + 12] ; Get the string to be printed

.get_next_char:
    ; We need to compute the row according to the current position
    imul edi, [xPos], 2   ; edx = 2 * x, one print is 2 bytes
    imul eax, [yPos], 160 ; eax = y * (80 * 2), 80 columns of 2 bytes
    add edi, 0xB8000
    add edi, eax      ; edi = B8000h + y * 160 + x * 2

    mov eax, [bp + 8] ; get the color attribute
    mov al, [esi]     ; get the ASCII code to be printed

    or al, al         ; check if al is 0, oring will set ZF if it is zero
    jz .done          ; and if al is equal to 0 we reach the end of the string

    cmp al, 0xA ; check if al is line feed
    jne .check_carriage_return

    ;; move cursor down to next line
    inc dword [yPos]
    inc esi         ; Read next character
    jmp .get_next_char

.check_carriage_return:
    cmp al, 0xD ; check if al is carriage return
    jne .normal_update

    ;; return to the beginning
    mov dword [xPos], 0
    inc esi         ; Read next character
    jmp .get_next_char

.normal_update:
    mov [edi], ax  ; Print the character (attribute and ascii)

    mov eax, [xPos]
    inc eax        ; xPos++
    cmp eax, 80    ; if xPos > 80 we need to go to the next line otherwise we
                   ; only need to update x
    jle .only_update_x

    ; We need to increment yPos and set xPos to 0
    inc dword [yPos]

    xor eax, eax     ; Xpos = 0

.only_update_x:
    mov [xPos], eax

    inc esi ; Read next character
    jmp .get_next_char

.done:
    pop esi
    pop edx
    pop edi
    pop eax

    mov esp, ebp
    pop ebp
    ret

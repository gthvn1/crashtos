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
    mov eax, [yPos]
    mov edx, 160 ; One line is 80 columns and one character has 2 bytes
    mul edx      ; ax = yPos * 160 so we have the offset now where to write
    add eax, 0xB8000
    mov edx, [xPos]
    shl edx, 1   ; shift left is equivalent to multiply by 2. As already said
                 ; we print two bytes (attribute, ascii) for each "pixel".
    add eax, edx ; ax = (yPos * 160) + xPos
    mov edi, eax ; edi = (yPos * 160) + xPos

    mov eax, [bp + 8] ; get the color attribute
    mov al, [esi]     ; get the ASCII code to be printed

    or al, al         ; check if al is 0, oring will set ZF if it is zero
    jz .done          ; and if al is equal to 0 we reach the end of the string

    cmp al, 0xA ; check if al is line feed
    jne .check_carriage_return

    ;; move cursor down to next line
    mov edx, [yPos]
    inc edx
    mov [yPos], edx ; yPos = yPos + 1
    inc esi         ; Read next character
    jmp .get_next_char

.check_carriage_return:
    cmp al, 0xD ; check if al is carriage return
    jne .normal_update

    ;; return to the beginning
    xor eax, eax
    mov [xPos], eax ; Xpos = 0
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
    mov edx, [yPos]
    inc edx
    mov [yPos], edx   ; yPos = yPos + 1

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

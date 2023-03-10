;; ============================================================================
;; display.asm
;;
;; This file provides functions related to the display.
;;    - clear_screen
;;    - move_cursor
;;    - print_string
;;    - print_hexa
;;
;; Related links:
;;   - https://wiki.osdev.org/VGA_Hardware
;;   - http://www.brokenthorn.com/Resources/OSDev10.html
;; ============================================================================

;; ----------------------------------------------------------------------------
;; Clear screen by writing space in Video Memory
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
    ; Reset xPos and yPos
    mov dword [xPos], 0
    mov dword [yPos], 0

    ; Update the position of the cursor
    call move_cursor

    ; and restore values
    pop edi
    pop es
    pop ecx
    pop eax
    ret

;; ----------------------------------------------------------------------------
;; Move the cursor to (xPos, yPos) location
move_cursor:
    ; save used parameters
    push eax
    push ebx
    push ecx
    push edx

    mov eax, [yPos] ; Get Row parameter
    mov ebx, [xPos] ; Get Column parameter

    ; Position is Row * 80 + Col, so let's compute it
    mov ecx, 80
    mul ecx      ; AX <- Row * 80
    add eax, ebx ; AX <- Row * 80 + Col
    mov ebx, eax ; Save it into AX

    ; Set low byte index to VGA register
    mov al, 0x0F   ; Indice for "Cursor Location Low Byte"
    mov dx, 0x03D4 ; CRT Index Register Port
    out dx, al

    mov al, bl ; Get saved low byte from BX
    mov dx, 0x03D5 ; CRT Data Register Port
    out dx, al

    ; Now Set high byte index
    mov al, 0x0E   ; Indice for "Cursor Location High Byte"
    mov dx, 0x03D4 ; CRT Index Register Port
    out dx, al

    mov al, bh ; Get saved high byte
    mov dx, 0x03D5 ; CRT Data Register Port
    out dx, al

.done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

;; ----------------------------------------------------------------------------
;; Print a string on the screen at a given line (the row) passed as parameters.
;; We suppose that video mode is set on 80x25.
;;
;; Params:
;;   - string to print
;;   - color attribute
;; Clobber:
;;   - Update xPos
;;   - Update yPos
print_string:
    push ebp    ; save old base pointer
    mov ebp, esp ; use the current stack pointer as new base pointer

    ; save registers
    push eax
    push edi
    push edx
    push esi

    mov esi, [ebp + 12] ; Get the string to be printed

.get_next_char:
    ; We need to compute the row according to the current position
    imul edi, [xPos], 2   ; edx = 2 * x, one print is 2 bytes
    imul eax, [yPos], 160 ; eax = y * (80 * 2), 80 columns of 2 bytes
    add edi, 0xB8000
    add edi, eax      ; edi = B8000h + y * 160 + x * 2

    mov eax, [ebp + 8] ; get the color attribute
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

;; ----------------------------------------------------------------------------
;; print the hexadecimal value of parameter1
;;
;; Params:
;;   - value to print
print_hexa:
    push ebp    ; save old base pointer
    mov ebp, esp ; use the current stack pointer as new base pointer

    ; save registers
    push eax
    push ebx
    push ecx
    push edi
    push esi

    mov eax, [ebp + 8] ; Get the value to be printed

    mov ecx, 8 ; Need to loop 8 times (see below for explanations)
    mov esi, hexaString
    mov edi, hexaOutput + 2 ; Skip "0x"

.hexloop:
    ; We want to translate EAX into readable hexadecial string.
    ; For example:
    ; EAX = 0x12345678 should print "0x12345678"
    ; in binary it is 0001_0010_0011_0100_0101_0110_0111_1000
    ; For this we will:
    ;     1) use the shift rotate:
    ;         => eax -> ..._0111_1000_0001 (first 4 bits are now at the end)
    ;     2) We will extract the last four bits to get ..._0000_0000_0001
    ;       This new value is in fact the index in the hexaString
    ;        => 0001 => index 1 in "012..." that is "1"
    ;     3) add the caracter at the given index in outputString
    ; We do this 8 times (this is why CX = 8 ;-)
    rol eax, 4              ; 1)
    mov ebx, eax            ; save eax into ebx
    and ebx, 0xF            ; 2) get last 4 bits (the index into hexaString)
    mov bl, byte [esi + ebx] ; BL constains the corresponding hexa char
    mov byte [edi], bl       ; 3) copy it into hexaOutput
    inc di                  ; next car in hexaOutput
    loop .hexloop           ; do it for the next bits if needed
                            ; jmp to .hexloop if CX != 0 (loop decrements ECX)

    ; We can now print the string
    push hexaOutput
    push 0x0000_0A00
    call print_string
    add sp, 8 ; clean the stack

    pop esi
    pop edi
    pop ecx
    pop ebx
    pop eax

    mov esp, ebp
    pop ebp
    ret

hexaOutput: db "0x00000000 ", 0 ; last 8 digits will be updated in the loop
hexaString: db "0123456789ABCDEF"

;; ============================================================================
;; display.asm
;;
;; This file provides functions related to the display.
;;    - clear_screen
;;    - move_cursor
;;    - print_string
;;    - print_hexa
;;    - print_regs
;;    - print_file_table
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
;;   - message to print before printing the hexadecimal value
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

    mov eax, [ebp + 12] ; message to print
    push eax
    push 0x0000_0A00
    call print_string

    mov eax, [ebp + 8] ; Get the value to be printed

    mov ecx, 8 ; Need to loop 8 times (see below for explanations)
    mov esi, hexaString
    mov edi, hexaOutput + 2 ; Skip "0x"

.hexloop:
    ; We want to translate EAX into readable hexadecimal string.
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
    add esp, 8 ; clean the stack

    pop esi
    pop edi
    pop ecx
    pop ebx
    pop eax

    mov esp, ebp
    pop ebp
    ret

;; ----------------------------------------------------------------------------
;; print regs eax, ebx, ecx, edx, esi, edi
%macro print_regs_macro 2
    push %1
    push %2
    call print_hexa
    add esp, 8
%endmacro

print_regs:
    print_regs_macro eaxStr, eax
    print_regs_macro ebxStr, ebx
    print_regs_macro ecxStr, ecx
    print_regs_macro edxStr, edx
    print_regs_macro espStr, esp
    print_regs_macro ebpStr, ebp
    print_regs_macro ediStr, edi
    print_regs_macro esiStr, esi
    ret

;; ----------------------------------------------------------------------------
;; print the content of the file table that is loaded at 0x10:0x7E00
print_file_table:
    ; save registers
    push eax
    push ecx
    push edi
    push esi

    push fileTableHdr
    push 0x0000_0A00
    call print_string
    add esp, 8

    ; TODO: display contents
    mov esi, 0x7E00
    mov edi, ftName
    mov ecx, 10

.copy_filename:
    lodsb     ; AL <- character read from DS:ESI and ESI++
    dec ecx   ; ecx is decremented when we read one character

    or al, al ; check if AL is 0 because filename can be less than 10 bytes
    jz .filename_read

    stosb      ; ES:EDI <- AL , EDI ++
    cmp ecx, 0 ; Check if it was the last character
    jz .ecx_empty

    ; ecx is not empty so we can continue to read characters
    jmp .copy_filename

.filename_read:
    cmp ecx, 0
    je .ecx_empty

    ; we don't read 10 chars from filename so we can skip remaining '0'
    inc esi
    dec ecx
    jmp .filename_read

.ecx_empty:
    ; So we can add the '.'
    mov al, '.'
    stosb ; ES:EDI <- '.' and EDI++

    ; extension is 3 bytes and ESI should be at the right location
    lodsb ; First char of the extension
    stosb
    lodsb ; Second char of the extension
    stosb
    lodsb ; Third char of the extension
    stosb

    ; DEBUG: print full filename
    push ftName
    push 0x0000_0B00
    call print_string
    add esp, 8

    ; restore registers
    pop esi
    pop edi
    pop ecx
    pop eax
    ret

; Data used to print file table
fileTableHdr:
    db 0xA, 0xD
    db "----------  ---  ------  ------  ------", 0xA, 0xD
    db "Filename    Ext  Dir     Sector  Size  ", 0xA, 0xD
    db "----------  ---  ------  ------  ------", 0xA, 0xD, 0

; full name is at most 14 bytes: 10 (filename) + 1 (.) + 3 (extension).
ftName:   db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ; 15 cause end with '0'
ftDir:    db 0
ftSector: db 0
ftSize:   db 0

; Data Used to print regs
eaxStr: db 0xA, 0xD, "EAX: ", 0
ebxStr: db 0xA, 0xD, "EBX: ", 0
ecxStr: db 0xA, 0xD, "ECX: ", 0
edxStr: db 0xA, 0xD, "EDX: ", 0
espStr: db 0xA, 0xD, "ESP: ", 0
ebpStr: db 0xA, 0xD, "EBP: ", 0
ediStr: db 0xA, 0xD, "EDI: ", 0
esiStr: db 0xA, 0xD, "ESI: ", 0

; Data used to print hexadecimal value
hexaOutput: db "0x00000000 ", 0 ; last 8 digits will be updated in the loop
hexaString: db "0123456789ABCDEF"

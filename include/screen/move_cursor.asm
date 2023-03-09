;; ============================================================================
;; move_cursor.asm
;;
;; Move the cursor to (xPos, yPos) location
;;
;; https://wiki.osdev.org/VGA_Hardware
;; http://www.brokenthorn.com/Resources/OSDev10.html
;; ============================================================================

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

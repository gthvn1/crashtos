;; ============================================================================
;; move_cursor.asm
;;
;; Move the cursor at a given position passed as parameters.
;; We suppose that video mode is set on 80x25.
;;
;; http://www.brokenthorn.com/Resources/OSDev10.html
;;
;; Params:
;;   - col
;;   - row
;; ============================================================================

move_cursor:
    push bp    ; save old base pointer
    mov bp, sp ; use the current stack pointer as new base pointer

    ; save used parameters 
    push ax
    push bx
    push cx
    push dx

    mov ax, [bp + 4] ; Get Row parameter
    mov bx, [bp + 6] ; Get Column parameter

    ; Position is Row * 80 + Col, so let's compute it
    mov cx, 80
    mul cx     ; AX <- Row * 80
    add ax, bx ; AX <- Row * 80 + Col
    mov bx, ax ; Save it into AX

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
    pop dx
    pop cx
    pop bx
    pop ax

    mov sp, bp
    pop bp
    ret

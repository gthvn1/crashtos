;; ============================================================================
;; get_user_input.asm
;;
;; Read user input from keyboard
;;
;; http://www.brokenthorn.com/Resources/OSDev10.html
;; http://www.brokenthorn.com/Resources/OSDev7.html
;;
;; Params:
;;   - input string
;;   - input strint size
;; ============================================================================

%define LAST_ROW        160*24
%define VIDEO_MEMORY    0xB800 ; this is segment in real mode

get_user_input:
    push bp    ; save old base pointer
    mov bp, sp ; use the current stack pointer as new base pointer

    ; save used parameters 
    push ax
    push bx
    push cx
    push di
    push ds
    push dx
    push es
    push si

    ;;mov cx, [bp + 4] ; Get input string size
    ;;mov di, [bp + 6] ; Get input string

    ; For debugging purpose we will print the enter char on the last line
    mov ax, VIDEO_MEMORY
    mov es, ax
    mov di, LAST_ROW  ; Set it to last row

    mov ah, 0x1E
    mov al, "T"
    stosw 

.loop:
    in al, 0x64 ; Read the status byte to check if a scancode is available
    and al, 0000_0010b ; Check IBF (Input Buffer Full)
    jnz .loop

    in al, 0x60  ; Read the input buffer

    cmp al, [scancodeTableSize] ; If AL is too big don't do the loopkup
    jg .loop

    cmp al, [keyPressed] ; If the key is already press just skip. Currently
                         ; we have lot of garbage so until we got clean char
                         ; let's do this...
    je .loop

    mov byte [keyPressed], al ; Saved the key pressed for future comparison

    mov bx, scancodeTable ; AL contains the scancode, do the translation
    xlatb ; Use the content of AL to lookup in scancodeTable and write back the
          ; contents

    ; If Enter is pressed then we are done
    cmp al, 0x1C
    je .done

    stosw
    jmp .loop

.done:
    pop si
    pop es
    pop dx
    pop ds
    pop di
    pop cx
    pop bx
    pop ax

    mov sp, bp
    pop bp
    ret

keyPressed: db 0
; 01h:Escape  0Eh:Backspace  0Fh:Tab  1Ch:Enter  1Dh:LeftCtrl...
scancodeTable:
.begin:
    db 00h, 01h, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', ')', '=', 0Eh, 0Fh
    db 'a', 'z', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '^', '$', 1Ch, 1Dh, 'q', 's'
    db 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'ù', '*', 2Ah, 'w', 'x', 'c', 'v', 'b'
    db 'n', ',', ';', ':', '!'
.end:
scancodeTableSize: db scancodeTable.end - scancodeTable.begin

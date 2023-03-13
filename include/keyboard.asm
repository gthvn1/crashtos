;; ============================================================================
;; keyboard.asm
;;
;; This file provides functions related to keyboard.
;;    - get_user_input
;;
;; Related links:
;;   scan code:
;;   - https://www.win.tue.nl/~aeb/linux/kbd/scancodes-1.html
;;
;;   - http://www.brokenthorn.com/Resources/OSDev10.html
;;   - http://www.brokenthorn.com/Resources/OSDev7.html
;;   - https://wiki.osdev.org/%228042%22_PS/2_Controller
;; ============================================================================

;; ----------------------------------------------------------------------------
;; Read user input from keyboard
;;
;; Params:
;;   - input string
;;   - input strint size
get_user_input:
    push ebp    ; save old base pointer
    mov ebp, esp ; use the current stack pointer as new base pointer

    ; save used parameters
    push eax
    push ebx
    push ecx
    push edi
    push edx
    push esi

    mov ecx, dword [ebp + 8]  ; Get input string size
    mov edi, dword [ebp + 12] ; Get input string

.loop:
    in al, 0x64 ; Read the status byte to check if a scancode is available

    and al, 0000_0001b ; "Output Buffer Status" must be set before reading data
                       ; from IO Port 0x60
    jz .loop

    and al, 0000_0010b ; Check that "Input Buffer Full" is clear before reading
                       ; data from IO Port 0x60
    jnz .loop

    in al, 0x60  ; Read the input buffer

    ; When a pressed key is released an additional scan code is sent. This
    ; additional code is called a 'break' code. The code is obtained by setting
    ; the high order but (adding 0x80). So check this and if it is a break
    ; skip it.
    test al, 0x80
    jnz .loop

    cmp al, [scancodeTableSize] ; If AL is too big don't do the loopkup
    jg .loop

    mov bx, scancodeTable ; AL contains the scancode, do the translation
    xlatb ; Use the content of AL to lookup in scancodeTable and write back the
          ; contents

    ; If Enter is pressed then we are done
    cmp al, 0x1C
    je .done

    ; Check if it is the Backspace
    cmp al, 0x0E
    jne .not_backspace

    cmp ecx, dword [ebp + 8]  ; it is the first character pressed so just return
    je .loop

    ; if no then delete the last character
    dec edi             ; go to last char
    xor al, al
    mov byte [edi], al  ; replace it by '0'
    inc ecx             ; we have one more character available for user string

    ; Now that user input has been updated we need to erase the last char by
    ; printing a blank char instead.
    ; Note: as we cannot have string with more than 10 bytes we don't go to
    ; next line. We can safly decrement xPos.
    dec dword [xPos]
    mov byte [keyTranslated], ' ' ; add space into keytranslated
    push keyTranslated
    push 0x0000_0A00
    call print_string
    add esp, 8
    ; At this point we print a space to erase the last char. So now we just
    ; need to decrement xPos once again and we are done.
    dec dword [xPos]
    call move_cursor ; update the position of the cursor before looping
    jmp .loop

.not_backspace:
    ; if there is still some room then store the data and echo it
    mov byte [keyTranslated], al ; update it for printing

    stosb   ; store AL into user input, ES:EDI <- AL, EDI is incremented

    push keyTranslated ; print the translation of the key pressed
    push 0x0000_0A00   ; Black/LightGreen
    call print_string  ; do the call
    add esp, 8          ; clean up the stack

    call move_cursor ; update the cursor position

    dec ecx ; We store one more character. Check that we still have place for
            ; the next one.
    or ecx, ecx
    jnz .loop

.done:
    xor al, al
    stosb   ; Size is given without the 0 at the end. So we can add it now.

    pop esi
    pop edx
    pop edi
    pop ecx
    pop ebx
    pop eax

    mov esp, ebp
    pop ebp
    ret

keyTranslated: db 0, 0 ; Add an extra 0 because we will print the character

; 01h:Escape  0Eh:Backspace  0Fh:Tab  1Ch:Enter  1Dh:LeftCtrl...
scancodeTable:
.begin:
    db 00h, 01h, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', ')', '=', 0Eh, 0Fh
    db 'a', 'z', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '^', '$', 1Ch, 1Dh, 'q', 's'
    db 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'ù', '*', 2Ah, 'w', 'x', 'c', 'v', 'b'
    db 'n', ',', ';', ':', '!'
.end:
scancodeTableSize: db scancodeTable.end - scancodeTable.begin

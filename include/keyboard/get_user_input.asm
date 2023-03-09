;; ============================================================================
;; get_user_input.asm
;;
;; Read user input from keyboard
;;
;; http://www.brokenthorn.com/Resources/OSDev10.html
;; http://www.brokenthorn.com/Resources/OSDev7.html
;; https://wiki.osdev.org/%228042%22_PS/2_Controller
;;
;; Params:
;;   - input string
;;   - input strint size
;; ============================================================================

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

    ;;mov cx, [bp + 8] ; Get input string size
    ;;mov di, [bp + 12] ; Get input string

    ; For debugging purpose we will print the enter char on the last line
    mov eax, 0xB8000
    add eax, 160 * 24 ; Add (80 * 2) * 24 because for a column is 2 bytes
    mov edi, eax

    xor eax, eax
    mov ah, 0xFC ; For debugging we choose white background and red foreground

.loop:
    in al, 0x64 ; Read the status byte to check if a scancode is available

    and al, 0000_0001b ; "Output Buffer Status" must be set before reading data
                       ; from IO Port 0x60
    jz .loop

    and al, 0000_0010b ; Check that "Input Buffer Full" is clear before reading
                       ; data from IO Port 0x60
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

    mov [EDI], ax
    add edi, 2
    jmp .loop

.done:
    pop esi
    pop edx
    pop edi
    pop ecx
    pop ebx
    pop eax

    mov esp, ebp
    pop ebp
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
;; ============================================================================
;; editor.asm
;;
;; It does nothing for now. It will be used to test the usage of code and
;; data segment. Once done we will add some stuff... or not.
;; ============================================================================

[BITS 32]
[ORG 0x0]

;; ----------------------------------------------------------------------------
;; MAIN
editor:
    call clear_screen

    push editorHdr
    push 0x0000_1E00  ; BG: blue, FG: Yellow
    call print_string
    add esp, 8         ; cleanup the stack

    ; Just wait that enter is pressed before returning to kernel space
    push userInput      ; the string where we will store the input
    push userInputSize  ; the max size of the string
    call get_user_input ; call the functin
    add esp, 8           ; cleanup the stack

jmp_stage2:
    ; Setup segment, kernel data is 0x10 in GDT
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    jmp 0x8:0x8000 ; Far jump to kernel...

%include "include/display.asm"
%include "include/keyboard.asm" ; keep it after display.asm

;; ----------------------------------------------------------------------------
;; VARIABLES

editorHdr:     db "Inside ctd-editor !!!", 0
userInput:     db 0,0,0,0,0,0,0,0,0,0,0
userInputSize: db 10 ; we can store at most 10 bytes
xPos:          dd 0 ; required if we include screen files
yPos:          dd 0

    ; Sector padding to have a bin generated of 2048 bytes (4 sectors)
    times 2048-($-$$) db 0

;; ============================================================================
;; kernel.asm
;;
;; This kernel will:
;;    - setup screen mode
;;    - display a prompt
;;    - read user input
;;    - process the user input
;;
;; [BIOS Services](https://grandidierite.github.io/bios-interrupts)
;; [Video Colors](https://en.wikipedia.org/wiki/BIOS_color_attributes)

;; ----------------------------------------------------------------------------
;; MACROS

%macro PRINT_STRING 2
    push %1   ; string to print
    push %2   ; AH: Black/LightGreen, AL: ASCII char so let to 0x0
    call print_line
    add sp, 4 ; cleanup the stack
%endmacro

[BITS 32]
[ORG 0x8000]

kernel:
    call clear_screen

    ; AH: Black/LightGreen, AL: ASCII char so let to 0x0
    PRINT_STRING welcomeHdr, 0x0000_0A00

    ;;; AH: Black/Yellow
    PRINT_STRING helpHdr, 0x0000_0E00

kernel_loop:
    PRINT_STRING promptStr, 0x0000_0B00

    call move_cursor    ; move cursor to the current position
    call get_user_input

infinite_loop:
    hlt
    jmp infinite_loop

;; As it is compile at the top we need to include the asm file with its path
%include "include/screen/print_line.asm"
%include "include/screen/clear_screen.asm"
%include "include/screen/move_cursor.asm"
%include "include/keyboard/get_user_input.asm"

;; ----------------------------------------------------------------------------
;; VARIABLES

welcomeHdr: db "+---------------------+", 0xA, 0xD
            db "| Welcome to CrashTOS |", 0xA, 0xD
            db "+---------------------+", 0xA, 0xD, 0

helpHdr: db "[HELP] commands are: clear, ls, regs, reboot, halt", 0xA, 0xD, 0

promptStr: db ">", 0

xPos: dd 0 ; aligned to 32 bits regs
yPos: dd 0

    ; kernel size is 2KB so padding with 0s
    times 2048-($-$$) db 0

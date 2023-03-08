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

%macro print_string 3
    push %1   ; string to print
    push %2   ; AH: Black/LightGreen, AL: ASCII char so let to 0x0
    push %3   ; Print on the first line
    call print_line
    add sp, 6 ; cleanup the stack
%endmacro

%macro cursor_at 2
    push %1
    push %2
    call move_cursor
    add sp, 4
%endmacro

[ORG 0x8000]

kernel:
    call clear_screen

    ; 0x0A_00 => AH: Black/LightGreen, AL: ASCII char so let to 0x0
    print_string welcomeHdr2, 0x0A00, 0
    print_string welcomeHdr1, 0x0A00, 1
    print_string welcomeHdr2, 0x0A00, 2

    ; 0x0E_00    ; AH: Black/Yellow
    print_string helpHdr, 0x0E00, 4

;; The kernel loop will:
;;  - display the prompt
;;  - get user input
;;  - check if it is a command
;;  - if it is not a command check if it is a program in File Table
;;    - if it is a bin execute it
;;    - if it is a txt display it
kernel_loop:
    print_string promptStr, 0x0B00, 5
    cursor_at 2, 5

    call get_user_input

infinite_loop:
    hlt
    jmp infinite_loop

;; As it is compile at the top we need to include the asm file with its path
%include "include/clear_screen.asm"
%include "include/move_cursor.asm"
%include "include/print_line.asm"
%include "include/get_user_input.asm"

;; ----------------------------------------------------------------------------
;; VARIABLES

welcomeHdr1:   db "| Welcome to CrashTOS |", 0
welcomeHdr2:   db "+---------------------+", 0

helpHdr:       db "[HELP] commands are: clear, ls, regs, reboot, halt", 0

promptStr:     db ">", 0

    ; kernel size is 2KB so padding with 0s
    times 2048-($-$$) db 0

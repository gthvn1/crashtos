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
    push %1         ; string to print
    push %2         ; AH: Black/LightGreen, AL: ASCII char so let to 0x0
    call print_line ; call the function
    add sp, 8       ; cleanup the stack
%endmacro

%macro GET_USER_INPUT 0
    push userInput             ; the string where we will store the input
    push dword [userInputSize] ; the max size of the string
    call get_user_input        ; call the functin
    add sp, 8                  ; cleanup the stack
%endmacro

;; COMPARE_CMD is taken three parameters
;;   - the size of the command string
;;   - the command string
;;   - the label where we jump if userInput matches the command string
%macro COMPARE_CMD 3
    mov cx, [%1]      ; Set cx with the size of cmd incremented by one
    mov si, %2        ; Set SI to the start of command string
    mov di, userInput ; Set DI to the start of the user input string
    repe cmpsb        ; Repeat compare string byte while equal
    je %3             ; If equal jump to lable (3rd parameter)
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

    GET_USER_INPUT

.compare_user_input:
    ; check if command is equal to "reboot"
    COMPARE_CMD rebootCmdSize, rebootCmdStr, .exec_reboot

    ; if not, check if command is equal to "halt"
    COMPARE_CMD haltCmdSize, haltCmdStr, .exec_halt

    jmp kernel_loop

.exec_reboot:
    jmp 0xFFFF:0x0000 ; far jump to the vector reset

.exec_halt:
    ; https://wiki.osdev.org/Shutdown
    ; In new version of qemu we can: outw(0x604, 0x2000)
    ; In bochs and older version of qemu we do: outw(0xB004, 0x2000)
    mov ax, 0x2000
    ; Try new version first. It should close the application
    mov dx, 0x604
    out dx, ax ; output 0x2000 to the IO port 0x604
    ; if it doesn't work try older version
    mov dx, 0xB004
    out dx, ax
    ; if it still doesn't work just halt
    hlt

infinite_loop:
    hlt
    jmp infinite_loop

;; As it is compile at the top we need to include the asm file with its path
%include "include/screen/clear_screen.asm"
%include "include/screen/move_cursor.asm"
%include "include/screen/print_line.asm"
%include "include/keyboard/get_user_input.asm" ; keep it after screen

;; ----------------------------------------------------------------------------
;; VARIABLES

welcomeHdr: db "+---------------------+", 0xA, 0xD
            db "| Welcome to CrashTOS |", 0xA, 0xD
            db "+---------------------+", 0xA, 0xD, 0

helpHdr:    db "[HELP] commands are: clear, ls, regs, reboot, halt", 0xA, 0xD, 0

promptStr:  db 0xA, 0xD, "> ", 0

userInput:     db 0,0,0,0,0,0,0,0,0,0,0
userInputSize: dd 10 ; we can store at most 10 bytes (without counting last
                     ; '0'), aligned with 32 bits.

xPos: dd 0 ; aligned to 32 bits regs
yPos: dd 0

;; List of commands
clearCmdStr:   db "clear", 0
clearCmdSize:  dw 0x6

lsCmdStr:      db "ls", 0
lsCmdSize:     dw 0x3

regsCmdStr:    db "regs", 0
regsCmdSize:   dw 0x5

rebootCmdStr:  db "reboot", 0
rebootCmdSize: dw 0x7

haltCmdStr:    db "halt", 0
haltCmdSize:   dw 0x5

    ; kernel size is 2KB so padding with 0s
    times 2048-($-$$) db 0

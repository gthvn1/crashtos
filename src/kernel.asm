;; ============================================================================
;; kernel.asm
;;
;; This kernel will:
;;    - setup screen mode
;;    - display a prompt
;;    - read user input
;;    - process the user input
;; ============================================================================

;; ----------------------------------------------------------------------------
;; MACROS

%macro print_str_macro 2
    push %1           ; string to print
    push %2           ; AH: Black/LightGreen, AL: ASCII char so let to 0x0
    call print_string ; call the function
    add esp, 8         ; cleanup the stack
%endmacro

%macro read_cmd_macro 0
    push userInput             ; the string where we will store the input
    push dword [userInputSize] ; the max size of the string
    call get_user_input        ; call the functin
    add esp, 8                  ; cleanup the stack
%endmacro

;; compare_cmd_macro is taken three parameters
;;   - the size of the command string
;;   - the command string
;;   - the label where we jump if userInput matches the command string
%macro compare_cmd_macro 3
    mov ecx, [%1]      ; Set ECX with the size of cmd incremented by one
    mov esi, %2        ; Set ESI to the start of command string
    mov edi, userInput ; Set EDI to the start of the user input string
    repe cmpsb         ; Repeat compare string byte EXC times while equal
    je %3              ; If equal jump to label (3rd parameter)
%endmacro

[BITS 32]
[ORG 0x8000]

kernel:
    call clear_screen

    ; AH: Black/LightGreen, AL: ASCII char so let to 0x0
    print_str_macro welcomeHdr, 0x0000_0A00

    ;;; AH: Black/Yellow
    print_str_macro helpHdr, 0x0000_0E00

kernel_loop:
    print_str_macro promptStr, 0x0000_0B00

    call move_cursor    ; move cursor to the current position

    read_cmd_macro

    ; We can now compare the command given by the user with commands supported
    ; by our kernel.

    compare_cmd_macro clearCmdSize,  clearCmdStr,  .exec_clear
    compare_cmd_macro lsCmdSize,     lsCmdStr,     .exec_ls
    compare_cmd_macro regsCmdSize,   regsCmdStr,   .exec_regs
    compare_cmd_macro rebootCmdSize, rebootCmdStr, .exec_reboot
    compare_cmd_macro haltCmdSize,   haltCmdStr,   .exec_halt

    ; Unknown command so try again let's check if the command is editor.
    ; TODO: Instead of hard coded the value editor look up into file table.
    compare_cmd_macro editorCmdSize, editorCmdStr, .load_editor

    ; Ok now let's try again
    print_str_macro cmdNotFound, 0x0000_0C00
    jmp kernel_loop

.exec_clear:
    call clear_screen
    jmp kernel_loop

.exec_ls:
    ; TODO
    print_str_macro cmdNotImplemented, 0x0000_0D00
    jmp kernel_loop

.exec_regs:
    call print_regs
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

.load_editor:
    ; WIP: just call the load function for now...
    push editorCmdStr ; we push the filename
    push 0x18         ; the segment where to load the editor
    push 0x0          ; the offset
    call load_file
    add esp, 12        ; cleanup call stack

    jmp kernel_loop

infinite_loop:
    hlt
    jmp infinite_loop

;; As it is compile at the top we need to include the asm file with its path
%include "include/display.asm"
%include "include/disks.asm"
%include "include/keyboard.asm" ; keep it after display.asm

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

;; Available programs
editorCmdStr:  db "editor", 0
editorCmdSize: dd 7

;; List of commands
clearCmdStr:   db "clear", 0
clearCmdSize:  dd 6

lsCmdStr:      db "ls", 0
lsCmdSize:     dd 3

regsCmdStr:    db "regs", 0
regsCmdSize:   dd 5

rebootCmdStr:  db "reboot", 0
rebootCmdSize: dd 7

haltCmdStr:    db "halt", 0
haltCmdSize:   dd 5

;; Error messages
cmdNotImplemented: db 0xA, 0xD, "Warning: command not implemented", 0
cmdNotFound:       db 0xA, 0xD, "Error: command not found command" , 0

    ; kernel size is 2KB so padding with 0s
    times 2048-($-$$) db 0

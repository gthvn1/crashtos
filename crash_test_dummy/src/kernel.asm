;; ============================================================================
;; kernel.asm
;;
;; Kernel will:
;;    - setup screen mode
;;    - display the menu
;;
;; [BIOS Services](https://grandidierite.github.io/bios-interrupts)
;; [Video Colors](https://en.wikipedia.org/wiki/BIOS_color_attributes)

;; ----------------------------------------------------------------------------
;; MACROS

%macro PRINT_NEW_LINE 0
    mov si, newLineStr
    call print_str
%endmacro

%include "include/constants.asm"

org KERNEL_OFFSET

kernel:
    call clear_screen

    mov si, welcomeHdr
    call print_str

    mov si, helpHdr
    call print_str

;; The kernel loop will:
;;  - display the prompt
;;  - get user input
;;  - check if it is a command
;;  - if it is not a command check if it is a program in File Table
;;    - if it is a bin execute it
;;    - if it is a txt display it
kernel_loop:
    mov si, promptStr
    call print_str

    mov di, userInputStr ; Set destination index to the start of userInputStr
    xor cl, cl           ; CL is used to count the number of chars inputted

get_user_input:
    mov ah, 0x0 ; wait for keypress and read character
    int 0x16    ; BIOS interrupt for keyboard services

    ; The program is halted until key with scancode is pressed.
    ; AH will contain the keyboard scan code
    ;   -> https://www.fountainware.com/EXPL/bios_key_codes.htm
    ; AL will contain the ASCII character or zero

    ; Check if backspace is pressed
    cmp al, 0x08
    je .erase_last_char

    ; while Enter (0x0D) is not pressed we continue
    cmp al, 0x0D ; compare with "Enter"
    je .compare_user_input

    ; Check that userInputStr is not full
    cmp cl, 0x19      ; 31 chars
    je get_user_input ; Just ignore char and wait for Backspace or Enter

    ; else echo the character
    mov ah, 0x0E ; set TTY service0
    int 0x10     ; print the character

    stosb        ; Store AL at ES:DI
    inc cl       ; Update the number of char
    jmp get_user_input

.erase_last_char:
    cmp cl, 0         ; first char pressed ?
    je get_user_input ; if yes just ignore it

    ; if no then delete the last character from userInputStr
    dec di
    mov byte [di], 0
    dec cl ; need to decrement the number of char already counted

    mov ah, 0x0E ; set TTY

    mov al, 0x08 ; set backspace char
    int 0x10

    mov al, ' '  ; print a blank char to erase deleted char
    int 0x10

    mov al, 0x08 ; and set backspace again
    int 0x10

    jmp get_user_input

;; compare_cmd is taken three parameters
;;   - the size of the command string
;;   - the command string
;;   - the label where we jump if userInputStr matches the command string
%macro compare_cmd 3
    mov cx, [%1]         ; Set cx with the size of cmd incremented by one
    mov si, %2           ; Set SI to the start of command string
    mov di, userInputStr ; Set DI to the start of the user input string
    repe cmpsb           ; Repeat compare string byte while equal
    je %3                ; If equal jump to lable (3rd parameter)
%endmacro

.compare_user_input:
    mov byte [di], 0 ; add 0 at the end of userInputStr. DI has been incremented when
                     ; echoing the character. It allows to not reset the userInputStr
                     ; at each loop.

    ; Check if command is equal to "ls"
    compare_cmd lsCmdSize, lsCmdStr, .exec_ls

    ; if not, check if command is equal to "clear"
    compare_cmd clearCmdSize, clearCmdStr, .exec_clear

    ; if not, check if command is equal to "regs"
    compare_cmd regsCmdSize, regsCmdStr, .exec_regs

    ; if not, check if command is equal to "editor"
    ; TODO: Make editor an application check from file table instead of command
    compare_cmd editorCmdSize, editorCmdStr, .exec_editor

    ; if not, check if command is equal to "halt"
    compare_cmd haltCmdSize, haltCmdStr, .exec_halt

    ; if not, check if command is equal to "reboot"
    compare_cmd rebootCmdSize, rebootCmdStr, .exec_reboot

    ; No matches, so print an error message, display the help and try again.
    mov si, notFoundStr
    call print_str

    mov si, helpHdr
    call print_str

    jmp kernel_loop

.exec_ls:
    call print_file_table
    jmp kernel_loop

.exec_clear:
    call clear_screen
    jmp kernel_loop

.exec_regs:
    call print_regs
    jmp kernel_loop

.exec_editor:
    ; load editor from sector 7 at 0x2000:0x0000
    mov bx, EDITOR_SEG
    mov es, bx            ; es <- 0x1000
    xor bx, bx            ; bx <- 0x0
                          ; Set [es:bx] to 0x0002:0x0000,

    mov cx, 0x00_07       ; Cylinder: 0, Sector: 7
    mov al, 0x1           ; Read one sector (512 bytes)
    call load_disk_sector ; Read editor from disk

    ; before jumping to editor we need to setup segments
    mov ax, EDITOR_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    jmp EDITOR_SEG:EDITOR_OFFSET ; far jump to editor

.exec_halt:
    mov si, haltStr
    call print_str
    cli
    hlt

.exec_reboot:
    jmp VECTOR_RESET; far jump to the vector reset
;; End of kernel_loop

;; As it is compile at the top we need to include the asm file with its path
%include "include/load_disk_sector.asm"
%include "include/clear_screen.asm"
%include "include/print_str.asm"
%include "include/print_hex.asm"
%include "include/print_regs.asm"
%include "include/print_file_table.asm"

;; ----------------------------------------------------------------------------
;; VARIABLES

welcomeHdr:
    db "-------------------------------------", 0xA, 0xD
    db " Crash Test Dummy OS has been loaded ", 0xA, 0xD
    db "-------------------------------------", 0xA, 0xD, 0
    ; 0xA is line feed (move cursor down to next line)
    ; 0xD is carriage return (return to the beginning)

helpHdr:
    db 0xA, 0xD, "[HELP] commands are: clear, ls, regs, reboot, halt", 0xA, 0xD, 0

newLineStr:    db 0xA, 0xD, 0
promptStr:     db 0xA, 0xD, "> ", 0
haltStr:       db 0xA, 0xD, "System halted", 0
notFoundStr:   db 0xA, 0xD, "ERROR: command not found", 0xA, 0xD, 0

;; List of commands
clearCmdStr:   db "clear", 0
clearCmdSize:  dw 0x6

lsCmdStr:      db "ls", 0
lsCmdSize:     dw 0x3

regsCmdStr:    db "regs", 0
regsCmdSize:   dw 0x5

editorCmdStr:  db "editor", 0
editorCmdSize: dw 0x7

rebootCmdStr:  db "reboot", 0
rebootCmdSize: dw 0x7

haltCmdStr:    db "halt", 0
haltCmdSize:   dw 0x5

userInputStr:  times 32 db 0

    ; kernel size is 2KB so padding with 0s
    times 2048-($-$$) db 0

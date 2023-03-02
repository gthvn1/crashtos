;; ============================================================================
;; kernel.asm
;;
;; Kernel will:
;;    - setup screen mode
;;    - display the menu
;;
;; Bootloader will load us at 0x1000:0x0000
;;
;; [BIOS Services](https://grandidierite.github.io/bios-interrupts)
;; [Video Colors](https://en.wikipedia.org/wiki/BIOS_color_attributes)

;; ----------------------------------------------------------------------------
;; MACROS

%macro PRINT_NEW_LINE 0
    mov si, newLineStr
    call print_str
%endmacro

org 0x0200

kernel:
    call clear_screen

    mov si, welcomeHdr
    call print_str

    mov si, helpHdr
    call print_str

display_prompt:
    mov si, promptStr
    call print_str

    mov di, userInputStr ; Set destination index to the start of userInputStr

.get_user_input:
    mov ah, 0x0 ; wait for keypress and read character
    int 0x16    ; BIOS interrupt for keyboard services

    ; The program is halted until key with scancode is pressed.
    ; AH will contain the keyboard scan code
    ;   -> https://www.fountainware.com/EXPL/bios_key_codes.htm
    ; AL will contain the ASCII character or zero

    ; while Enter (0x0D) is not pressed we continue
    ; currently we don't check that userInputStr is not overflowed
    cmp al, 0x0D ; compare with "Enter"
    je .compare_user_input

    ; else echo the character
    mov ah, 0xE ; set TTY service
    int 0x10    ; print the character
    stosb       ; Store AL at ES:DI
    jmp .get_user_input

.compare_user_input:
    mov byte [di], 0 ; add 0 at the end of userInputStr. DI has been incremented when
                     ; echoing the character.

    mov si, userInputStr ; Set source index to point to the beginning of userInputStr

    ; Check if command is equal to "ls"
    mov cx, [lsCmdSize]  ; Set cx with the size of "ls" incremented by the end char
    mov si, lsCmdStr     ; Set source index to the start of lsCmdStr
    mov di, userInputStr ; Set destination index to the start of userInputStr
    repe cmpsb           ; Repeat compare string byte while equal.
                         ; -> Compares DS:SI and ES:DI
    je .ls_found;

    ; if not, check if command is equal to "clear"
    mov cx, [clearCmdSize]
    mov si, clearCmdStr
    mov di, userInputStr
    repe cmpsb
    je .clear_found ; Jump if there is a match

    ; if not, check if command is equal to "regs"
    mov cx, [regsCmdSize]
    mov si, regsCmdStr
    mov di, userInputStr
    repe cmpsb
    je .regs_found ; Jump if there is a match

    ; if not, check if command is equal to "halt"
    mov cx, [haltCmdSize]
    mov si, haltCmdStr
    mov di, userInputStr
    repe cmpsb
    je .halt_found

    ; if not, check if command is equal to "reboot"
    mov cx, [rebootCmdSize]
    mov si, rebootCmdStr
    mov di, userInputStr
    repe cmpsb
    je .reboot_found

    ; No matches, so command is not found, print help and retry
    mov si, notFoundStr
    call print_str
    mov si, helpHdr
    call print_str
    jmp display_prompt

.ls_found:
    call print_file_table
    jmp display_prompt

.clear_found:
    call clear_screen
    jmp display_prompt

.regs_found:
    call print_regs
    jmp display_prompt

.halt_found:
    mov si, haltStr
    call print_str
    cli
    hlt

.reboot_found:
    jmp 0xFFFF:0x0000 ; far jump to the vector reset
;; End of display_prompt

;; As it is compile at the top we need to include the asm file with its path
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

userInputStr:  times 30 db 0 ; command is less than 30 bytes
newLineStr:    db 0xA, 0xD, 0
promptStr:     db 0xA, 0xD, "> ", 0
haltStr:       db 0xA, 0xD, "System halted", 0
notFoundStr:   db 0xA, 0xD, "ERROR: command not found", 0xA, 0xD, 0

;; ----------------------------------------------------------------------------
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

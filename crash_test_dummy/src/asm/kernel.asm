;; ============================================================================
;; kernel.asm
;;
;; Kernel will:
;;    - setup screen mode
;;    - display the menu
;;
;; Bootloader will load us at 0x8000
;;
;; [BIOS Services](https://grandidierite.github.io/bios-interrupts)
;; [Video Colors](https://en.wikipedia.org/wiki/BIOS_color_attributes)

;; ----------------------------------------------------------------------------
;; MACROS

%macro PRINT_NEW_LINE 0
    mov si, newLineStr
    call print_str
%endmacro

kernel:
    org 0x8000

    call reset_screen
    mov si, welcomeHdr
    call print_str

print_prompt:
    mov si, promptStr
    call print_str

    mov ah, 0x0 ; wait for keypress and read character
    int 0x16    ; BIOS interrupt for keyboard services

    ; The program is halted until key with scancode is pressed.
    ; AH will contain the keyboard scan code
    ;   -> https://www.fountainware.com/EXPL/bios_key_codes.htm
    ; AL will contain the ASCII character or zero
    mov [cmdStr], al
    mov si, cmdStr
    call print_str
    PRINT_NEW_LINE

    ; Let's compare the key pressed by the used with our known code
    ; Let's check if it is [F]ile browser...
    cmp al, 0x66 ; Compare AL to 'F'
    jne print_prompt.check_p   ; If not equal check if it is [P]rint registers

    call browser ; If it is equal call browser
    jmp print_prompt

.check_p:
    cmp al, 0x70 ; Compare AL to 'P'
    jne print_prompt.check_q ; If not equam check if it is [Q]uit

    call print_registers
    jmp print_prompt

.check_q:
    cmp al, 0x71 ; Compare AL to 'Q'
    jne print_prompt.check_r  ; If not equal check if it is [R]eboot

    mov si, haltStr
    call print_str
    cli
    hlt

.check_r:
    cmp al, 0x72 ; Compare AL to 'R'
    jne print_prompt.not_found ; If not equal the command is not found

    jmp 0xFFFF:0x0000 ; jump to the vector reset

.not_found:
    ; no match found so print command not found and process next input.
    mov si, notFoundStr
    call print_str

    jmp print_prompt

;; End of print_prompt

;; ----------------------------------------------------------------------------
;; browser
;; Display File table
browser:
    pusha

    ; Display the print file table header
    mov si, fileTableHdr
    call print_str

    mov ah, 0x0e   ; Set BIOS Service to "write text in Teletype Mode"
    mov si, 0x7E00 ; Put the address of the File table into si
    mov cx, 0xA    ; Filename is 10 bytes max

.print_filename:
    lodsb                ; al <- DS:SI and inc SI
    or al, al            ; check if al is 0x0
    jnz .al_not_null
    mov al, ' '          ; if al is 0x0 replace it with a space
.al_not_null:
    int 0x10             ; print the character 
    loop .print_filename ; loop if CX is not null.

    ; Print 2 spaces
    mov al, ' '
    int 0x10
    int 0x10

    ; print_extension
    lodsb
    int 0x10
    lodsb
    int 0x10
    lodsb
    int 0x10

    mov dh, 0x0

    ; Print 2 spaces
    mov al, ' '
    int 0x10
    int 0x10

    ; print_directory
    lodsb
    mov dl, al
    call print_hex

    ;; Print 2 spaces
    mov al, ' '
    int 0x10
    int 0x10

    ; print_sector
    lodsb
    mov dl, al
    call print_hex

    ; Print 2 spaces
    mov al, ' '
    int 0x10
    int 0x10

    ; print_size:
    lodsb
    mov dl, al
    call print_hex

    ; check if next entry is null or not
    lodsb
    or al, al
    jz .done ; There is no more entry

    ; If there is another character display the next entry
    mov al, 0xA ; line feed (move cursor down to next line)
    int 0x10
    mov al, 0xD ; carriage return (return to the beginning)
    int 0x10
    dec si      ; Go one step back
    mov cx, 0xA ; Filename is 10 bytes max
    jmp .print_filename

.done:
    popa
    ret

;; ----------------------------------------------------------------------------
print_registers:
    ; Display the print registers header
    mov si, printRegsHdr
    call print_str

    ; print registers
    call print_regs
    ret

;; ----------------------------------------------------------------------------
reset_screen:
    push ax
    push bx

    mov ah, 0x0 ; Set BIOS service to "set video mode"
    mov al, 0x3 ; 80x25 16 color text
    int 0x10    ; BIOS interrupt for video services

    mov ah, 0xB ; Set BIOS Service to "set color palette"
    mov bh, 0x0 ; set background & border color
    mov bl, 0x5 ; magenta
    int 0x10

    pop bx
    pop ax
    ret

;; As it is compile at the top we need to include the asm file with its path
%include "src/asm/print_str.asm"
%include "src/asm/print_hex.asm"
%include "src/asm/print_regs.asm"

;; ----------------------------------------------------------------------------
;; VARIABLES

welcomeHdr:
    db "-------------------------------------", 0xA, 0xD
    db " Crash Test Dummy OS has been loaded ", 0xA, 0xD
    db "-------------------------------------", 0xA, 0xD
    db " Available commands are:             ", 0xA, 0xD 
    db "   [F]ile & Program Browser/Loader   ", 0xA, 0xD
    db "   [P]rint registers                 ", 0xA, 0xD
    db "   [R]eboot                          ", 0xA, 0xD
    db "   [Q]uit                            ", 0xA, 0xD
    db "-------------------------------------", 0xA, 0xD
    db 0
    ; 0xA is line feed (move cursor down to next line)
    ; 0xD is carriage return (return to the beginning)

fileTableHdr:
    db "----------  ---  ------  ------  ------", 0xA, 0xD
    db "Filename    Ext  Dir     Sector  Size  ", 0xA, 0xD
    db "----------  ---  ------  ------  ------", 0xA, 0xD, 0

printRegsHdr:
    db "--------     -----------", 0xA, 0xD
    db "Register     MemLocation", 0xA, 0xD
    db "--------     -----------", 0xA, 0xD, 0

cmdStr:      times 10 db 0 ; command is less than 10 bytes
newLineStr:  db 0xA, 0xD, 0
promptStr:   db 0xA, 0xD, "> ", 0
haltStr:     db "!!! enter in infinite loooooop...", 0xA, 0xD, 0
notFoundStr: db "ERROR: command not found", 0xA, 0xD, 0

    ; kernel size is 2KB so padding with 0s
    times 2048-($-$$) db 0

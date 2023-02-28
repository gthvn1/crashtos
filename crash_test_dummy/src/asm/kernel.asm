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

kernel:
    org 0x8000

display_menu:
    call reset_screen

    mov si, menuHdr ; si "points" to helloStr
    call print_str

.process_input:
    mov ah, 0x0 ; wait for keypress and read character
    int 0x16    ; BIOS interrupt for keyboard services

    ; The program is halted until key with scancode is pressed.
    ; AH will contain the keyboard scan code
    ;   -> https://www.fountainware.com/EXPL/bios_key_codes.htm
    ; AL will contain the ASCII character or zero
    mov si, cmdInput   ; set source index to cmdInput string
    mov [si + 13], al  ; Relace the 13th character by ASCII char found in AL
    call print_str     ; Print the input

    ; Let's compare the key pressed by the used with our known code
    ; Let's check if it is [F]ile browser...
    cmp al, 0x66 ; Compare AL to 'F'
    jne display_menu.check_p   ; If not equal check if it is [P]rint registers

    call browser ; If it is equal call browser
    jmp display_menu.wait_press_key

.check_p:
    cmp al, 0x70 ; Compare AL to 'P'
    jne display_menu.check_q ; If not equam check if it is [Q]uit

    call print_registers
    jmp display_menu.wait_press_key

.check_q:
    cmp al, 0x71 ; Compare AL to 'Q'
    jne display_menu.check_r  ; If not equal check if it is [R]eboot

    mov si, haltMsg
    call print_str
    cli
    hlt

.check_r:
    cmp al, 0x72 ; Compare AL to 'R'
    jne display_menu.not_found ; If not equal the command is not found

    jmp 0xFFFF:0x0000 ; jump to the vector reset

.not_found:
    ; no match found so print command not found and process next input.
    mov si, cmdNotFoundMsg
    call print_str

    jmp display_menu.process_input

.wait_press_key:
    mov si, pressKeyMsg
    call print_str

    mov ah, 0x0 ; wait for keypress and read character
    int 0x16    ; BIOS interrupt for keyboard services
    jmp display_menu
;; End of display_menu

;; ----------------------------------------------------------------------------
;; browser
;; Display File table
browser:
    pusha

    ; clear screen by setting video mode
    call reset_screen

    ; Display the print file table header
    mov si, fileTableHdr
    call print_str

    mov ah, 0x0e   ; Set BIOS Service to "write text in Teletype Mode"
    mov si, 0x7E00 ; Put the address of the File table into si
    mov cx, 0xA    ; Filename is 10 bytes max

.print_filename:
    lodsb ; al <- DS:SI and inc SI
    or al, al ; check if al is 0x0
    jnz .not_null
    mov al, ' ' ; if al is 0x0 replace it with a space
.not_null:
    int 0x10;
    dec cx
    jnz browser.print_filename ; loop if CX is not null.

    ;; Print 2 spaces
    mov al, ' '
    int 0x10
    int 0x10

.print_extension:
    lodsb
    int 0x10
    lodsb
    int 0x10
    lodsb
    int 0x10

    mov dh, 0x0

    ;; Print 2 spaces
    mov al, ' '
    int 0x10
    int 0x10

.print_directory:
    lodsb
    mov dl, al
    call print_hex

    ;; Print 2 spaces
    mov al, ' '
    int 0x10
    int 0x10

.print_sector:
    lodsb
    mov dl, al
    call print_hex

    ;; Print 2 spaces
    mov al, ' '
    int 0x10
    int 0x10

.print_size:
    lodsb
    mov dl, al
    call print_hex

    ;; check if next entry is null or not
    lodsb
    or al, al
    jz .done ; There is no more entry

    ;; If there is another character display the next entry
    mov al, 0xA ; line feed (move cursor down to next line)
    int 0x10
    mov al, 0xD ; carriage return (return to the beginning)
    int 0x10
    dec si      ; Go one step back
    mov cx, 0xA ; Filename is 10 bytes max
    jmp browser.print_filename

.done:
    popa
    ret

;; ----------------------------------------------------------------------------
print_registers:
    ; clear screen by setting video mode
    call reset_screen
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

menuHdr:
    db "Crash Test Dummy loaded!", 0xA, 0xD
    db "------------------------", 0xA, 0xD,
    db "[F]ile & Program Browser/Loader", 0xA, 0xD,
    db "[P]rint registers", 0xA, 0xD,
    db "[R]eboot", 0xA, 0xD,
    db "[Q]uit", 0xA, 0xD, 0
    ; 0xA is line feed (move cursor down to next line)
    ; 0xD is carriage return (return to the beginning)

fileTableHdr:
    db " Filename   Ext  Dir     Sector  Size", 0xA, 0xD
    db "----------  ---  ------  ------  ------", 0xA, 0xD, 0


printRegsHdr:
    db "Register     MemLocation", 0xA, 0xD
    db "--------     -----------", 0xA, 0xD, 0

pressKeyMsg:    db 0xA, 0xA, 0xD, "press any keys to return to main menu", 0
cmdNotFoundMsg: db "command not found", 0xA, 0xD, 0
haltMsg:        db "enter in infinite loop", 0xA, 0xD, 0
cmdInput:       db "you pressed: 0", 0xA, 0xD, 0

    ; kernel size can be 2KB max
    times 2048-($-$$) db 0 ; padding with 0s

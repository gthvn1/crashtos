;; ============================================================================
;; kernel.asm
;;
;; Kernel will:
;;	- setup screen mode
;;	- display the menu
;;
;; Bootloader will load us at 0x8000
;;
;; [BIOS Services](https://grandidierite.github.io/bios-interrupts)
;; [Video Colors](https://en.wikipedia.org/wiki/BIOS_color_attributes)

kernel:
	org 0x8000

	mov ah, 0x0 ; Set BIOS service to "set video mode"
	mov al, 0x3 ; 80x25 16 color text
	int 0x10    ; BIOS interrupt for video services

	mov ah, 0xb ; Set BIOS Service to "set color palette"
	mov bh, 0x0 ; set background & border color
	mov bl, 0x1 ; blue
	int 0x10

	; Display the menu
	mov si, menuString ; si "points" to helloStr
	call print_str

process_input:
    mov ah, 0x0 ; wait for keypress and read character
    int 0x16    ; BIOS interrupt for keyboard services

    ; The program is halted until key with scancode is pressed.
    ; AH will contain the keyboard scan code
    ;       https://www.stanislavs.org/helppc/scan_codes.html
    ; AL will contain the ASCII character or zero
    mov si, cmdInput   ; set source index to cmdInput string
    mov [si + 13], al  ; Relace the 13th character by ASCII char found in AL
    call print_str     ; Print the input

    ; Let's compare the key pressed by the used with our known code
    cmp al, 0x66 ; Compare AL to 'F'
    je process_input.browser   ; If equal we can now run the command

    cmp al, 0x71 ; Compare AL to 'Q'
    je process_input.quit      ; if equal "halt" the machine

    cmp al, 0x72 ; Compare AL to 'R'
    je process_input.reboot    ; if equal reboot

    mov si, cmdNotFoundMsg ; no match so print an error and get user input again
    call print_str
    jmp process_input

.browser:
    mov si, 0x7E00 ; Put the address of the File table into si
    call print_str
    jmp process_input

.quit:
    mov si, haltMsg
    call print_str
    cli
    hlt

.reboot:
    jmp 0xFFFF:0x0000 ; jump to the vector reset

;; As it is compile at the top we need to include the asm file with its path
%include "src/asm/print_str.asm"

menuString:
	db "------------------------", 0xa, 0xd
	db "Crash Test Dummy loaded!", 0xa, 0xd
	db "------------------------", 0xa, 0xd,
    db "[F]ile & Program Browser/Loader", 0xa, 0xd,
    db "[R]eboot", 0xa, 0xd,
    db "[Q]uit", 0xa, 0xd, 0
	; 0xa is line feed (move cursor down to next line)
	; 0xd is carriage return (return to the beginning)

runBrowserMsg:  db "run browser", 0xa, 0xd, 0
cmdNotFoundMsg: db "command not found", 0xa, 0xd, 0
haltMsg:        db "enter in infinite loop", 0xa, 0xd, 0
cmdInput:       db "You pressed: 0", 0xa, 0xd, 0

	times 512-($-$$) db 0 ; padding with 0s

;; ----------------------------------------------------------------------------
;; print_file_table.asm
;;
;; Display File table
;; The bootloader loaded the file table into 0x0000:0x7E00
;; As the stage2 is not on the same segment we need to modify 
;; ES to be able to get file table.
print_file_table:
    pusha

    ; Display the print file table header
    mov si, fileTableHdr
    call print_str

    mov si, 0x0 ; Put the address of the File table into ES:SI

    mov ah, 0x0e   ; Set BIOS Service to "write text in Teletype Mode"
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


fileTableHdr:
    db 0xA, 0xD
    db "----------  ---  ------  ------  ------", 0xA, 0xD
    db "Filename    Ext  Dir     Sector  Size  ", 0xA, 0xD
    db "----------  ---  ------  ------  ------", 0xA, 0xD, 0

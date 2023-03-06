;; ============================================================================
;; load_file.asm
;;
;; Load a filename into ES:BX
;; Filename will be found in the file table

;; Params:
;;   - Filename
;;   - Segment memory location
;;   - Offset memory location
;; Return values:
;;   - success AX will contain 0x0
;;   - failure AX will contain an error != 0x0

%define FILE_NOT_FOUND     0x1
%define FILE_LOAD_ERROR    0x2
%define BIN_FILE_NOT_FOUND 0x3

load_file:
    ; The last value pushed on the stack is the IP by the call.
    ; After saving the value of Base Pointer register the stack looks like:
    ;
    ; TOP STACK (0xFFFF) it is not the real value, it is just to show direction
    ;  +------------+
    ;  | parameter1 |<- BP + 8
    ;  +------------+
    ;  | parameter2 |<- BP + 6
    ;  +------------+
    ;  | parameter3 |<- BP + 4
    ;  +------------+
    ;  | @ ret      |<- BP + 2
    ;  +------------+
    ;  | old BP     |<- New BP
    ;  +------------+
    ;  |            |
    ;  ...
    ;  | stack is growing downards...
    ;  v
    ; BOTTOM STACK (0x0000)...
    push bp    ; save old base pointer
    mov bp, sp ; use the current stack pointer as new base pointer

    ; save registers and also segments that are clobbered
    ; NOTE: DON'T save ax that contains the return value
    push bx
    push cx
    push dx
    push ds
    push es
    push fs

    ; Read parameters from the stack
    mov bx, [bp + 4] ; BX = Offset memory @
    mov es, [bp + 6] ; ES = Segment memory @ where load the file
    mov di, [bp + 8] ; DI = Filename
    mov ax, ds       ; Keep the value of DS to be able to reference DI
    mov fs, ax       ; So the comparaison is done using [FS:DI]

    ;; At this point
    ;;   - [ES:BX] points to the address where file must be loaded
    ;;   - [FS:DI] points to the filename
    ;;
    ;; TODO: find the sector by reading the file table and if
    ;; found we need to load the file...
    ;; Currently we are just printing if we found a file or not and if we
    ;; found it what sector to use.

    mov ax, FTABLE_SEG
    mov ds, ax
    xor si, si  ; [DS:SI] is the address for the file table in memory
                ; SI <- 0x0 == FTABLE_OFFSET

find_filename:
    lodsb       ; AL <- [DS:SI] and SI is incremented by one

    cmp al, 0   ; We reach the end of the file table
    je file_not_found

    ;; If the first character is the same we can continue the comparaison
    ;; otherwise try the next entry. An entry of the file table is 16 bytes.
    cmp al, [fs:di]
    je check_filename
    add si, FTABLE_ENTRY_SIZE - 1 ; SI has already been incremented by one
    jmp find_filename

check_filename:
    mov cx, 0x9 ; filename is less or equal to 10 bytes. As we already
                ; compared the first char we need to compare at most 9 bytes.
    inc di      ; DI points now to the second character.

    .loop:
    lodsb           ; AL <- [DS:SI] , SI++
    cmp al, [fs:di]
    jne .compare_next_entry

    ;; otherwise continue to compare until CX == 0 or AL == 0
    cmp cx, 0
    je compare_ext ; NOTE: input "xxxxxxxxxxyz" will match "xxxxxxxxxx"
                   ;       that's ok for now because filename is 10 bits
                   ;       so just ignore bits over this limit.
    cmp al, 0
    je file_found

    ;; Otherwise we have a match but we need to compare other characters.
    dec cx
    inc di

    jmp .loop

    .compare_next_entry:
    mov di, [bp + 8] ; reset filename
    add cx, 5        ; Add the 3 extension bytes + 3 attributes - 1 because
                     ; DI has been incremented by one when loading into AL
    add si, cx       ; Update SI that should now points the next entry...
    jmp find_filename

file_not_found:
    mov ax, FILE_NOT_FOUND      ; Return the error
    jmp end

file_found:
    ; We found the file name so now we need to check if it is a bin file.
    ; To do that we need to find the beginning of extension (bits 10-12).
    ; If CX is null we are already on bit10 otherwise we need to move to it.
    dec cx     ; As SI has been incremented by 1 for the comparaison we still
    add si, cx ; need to add CX - 1 to reach the first char of the extension.

compare_ext:
    lodsb        ; AL <- [DS:SI], SI++
    cmp al, 't'  ; check if extension is equal to BIN or TXT
    je text_file_found

    ; We found binary file
    add si, 2  ; skip the end of extension
    inc si     ; skip the directory

    ; Read starting sector
    lodsb
    mov cl, al   ; CL <- Sector
    xor ch, ch   ; CH <- Cylinder

    ; Read size
    lodsb        ; AL <- Number of serctor to read

    ; We can now load the file
    ; Remember [ES:BX] has been set when reading parameters
    mov si, 0x3 ; disk reads should be retried at least three times
                ; we use SI because all AX, BX, CX and DX are already used.

    .retry:
    ; Reset the disk before reading it
    mov ah, 0x0
    int 0x13

    mov ah, 0x2  ; BIOS service: read sectors from drive
                 ; AL is set when calling load_disk_sector
                 ; CH & CL are also already set
    mov dh, 0x0  ; Head 0
    mov dl, 0x0  ; Read floppy

    int 0x13     ; 0x13 BIOS service

    ; Check the result
    ; If CF == 1 then there is an error
    jc .failed_to_load_file

    ; Otherwise it is a success
    xor ax, ax       ; AX = 0, success !!!
    jmp end

    .failed_to_load_file:
    dec si
    jnz .retry

    ; We failed to load the file too many times. Return an error
    mov ax, FILE_LOAD_ERROR
    jmp end

text_file_found:
    mov ax, BIN_FILE_NOT_FOUND

end:

    pop fs
    pop es
    pop ds
    pop dx
    pop cx
    pop bx

    mov sp, bp ; restore the stack
    pop bp     ; restore bp
    ret

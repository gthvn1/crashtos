;; ============================================================================
;; load_file.asm
;;
;; Params:
;;   - Filename
;;   - Segment memory location
;;   - Offset memory location
;; It will load a filename in ES:BX
;; Filename will be found in the file table
load_file:
    nop
    nop
    nop  ;; allow the identification of the start of the function
    ; Read parameters
    ; The last value pushed on the stack is the IP by the call.
    ; After saving the value of Base Pointer register the stack looks like:
    ;
    ; TOP STACK (0xFFFF)
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

    ;; For debugging purpose we print parametres
    mov si, param3
    call print_str
    mov dx, [bp + 4] ; Offset memory @
    call print_hex
    mov bx, si       ; So bx -> Offset

    mov si, param2
    call print_str
    mov dx, [bp + 6] ; Segment memory @
    call print_hex

    mov fs, [bp + 6] ; FS <- Segment from where we load the file

    mov si, [bp + 8] ; Filename
    call print_str
    mov di, si      ; DI points to the filename

    ;; At this point
    ;;   - [FS:BX] points to the address where file must be loaded
    ;;   - DI points to the filename
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

    mov dx, ax
    call print_hex

    cmp al, 0   ; We reach the end of the file table
    je file_not_found

    ;; If the first character is the same we can continue the comparaison
    ;; otherwise try the next entry. An entry of the file table is 16 bytes.
    cmp al, [di]
    je compare_filename
    add si, FTABLE_ENTRY_SIZE - 1 ; SI has already been incremented by one
    jmp find_filename

compare_filename:
    mov cx, 0x9 ; filename is less or equal to 10 bytes. As we already
                ; compared the first char we need to compare at most 9 bytes.
    inc di      ; DI points now to the second character.

    .loop:
    lodsb           ; AL <- [DS:SI] , SI++
    cmp al, [di]
    jne .check_next_entry

    ;; otherwise continue to compare until CX == 0 or AL == 0
    cmp cx, 0
    je file_found
    cmp al, 0
    je file_found

    ;; Otherwise we have a match but we need to compare other characters.
    dec cx
    inc di

    jmp .loop

    .check_next_entry:
    mov di, [bp + 8] ; reset filename
    add cx, 5        ; Add the 3 extension bytes + 3 attributes - 1 because
                     ; DI has been incremented by one when loading into AL
    add si, cx       ; Update SI that should now points the next entry...
    jmp find_filename

file_not_found:
    mov si, fileNotFound
    call print_str
    jmp end

file_found:
    mov si, fileFound
    call print_str

end:
    pop bp ; restore bp
    ret

markStr      db '.', 0
fileFound    db "File found", 0
fileNotFound db "File not found", 0
param1       db "Filename : ", 0
param2       db "Segment @: ", 0
param3       db "Offset   : ", 0

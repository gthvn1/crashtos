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

    ; Read parameters from the stack
    mov bx, [bp + 4] ; BX = Offset memory @
    mov fs, [bp + 6] ; FS = Segment memory @ where load the file
    mov di, [bp + 8] ; DI = Filename

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
    mov ax, 0x1      ; Return the error
    jmp end

file_found:
    xor ax, ax       ; AX = 0, success !!!

end:
    pop bp ; restore bp
    ret

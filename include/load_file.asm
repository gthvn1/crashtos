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

    ;; At this point [FS:BX] points to the address of the file and
    ;; si points to the filename
    ;; TODO: find the sector by reading the file table and if
    ;; found we need to load the file...

end:
    pop bp ; restore bp
    ret

param1 db "Filename : ", 0
param2 db "Segment @: ", 0
param3 db "Offset   : ", 0

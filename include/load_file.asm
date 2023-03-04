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

    ;; For testing just print parameter
    mov si, [bp + 8] ; parameter1
    call print_str

    mov si, [bp + 6] ; parameter2
    call print_str

    mov si, [bp + 4] ; parameter3
    call print_str

end:
    pop bp ; restore bp
    ret

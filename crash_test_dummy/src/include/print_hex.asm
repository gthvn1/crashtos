;; print_hex
;;   dx: value to print
print_hex:
    pusha
    mov ah, 0x0e ; code of the service to write Char
    mov si, hexaString
    mov di, hexaOutput + 2 ; Skip "0x"
    mov cx, 4 ; Need to loop four times (see below for explanations)

.hexloop:
    ; What we want is to translate the value of AX into readable hexaStringing
    ; For example:
    ; DX = 1E48 should print "1E48"
    ; in binary it is 0001_1110_0100_1000
    ; For this we will:
    ;     1) use the shift rotate:
    ;         => ax -> 1110_0100_1000_0001 (the first 4 bits are now at the end)
    ;     2) We will extract the last four bits to get 0000_0000_0000_0001
    ;       This new value is in fact the index in the hexaString
    ;        => 0001 => index 1 in "012..." that is "1"
    ;     3) add the caracter at the given index in outputString
    ; We do this four times (this is why CX == 0x4 ;-)
    rol dx, 4         ; 1)
    mov bx, dx        ; save dx into bx
    and bx, 0x0f      ; 2) get last 4 bits (the index into hexaString)
    mov bl, [si + bx] ; BL constains the corresponding hexa char
    mov [di], bl      ; 3) copy it into hexaOutput
    inc di            ; next car in hexaOutput
    loop .hexloop     ; do it for the next bits if needed
                      ; jmp to .hexloop if CX != 0
    mov si, hexaOutput
    call print_str

    popa
    ret

hexaOutput db "0x0000", 0 ; the last four digits will be updated in the loop
hexaString db "0123456789ABCDEF"

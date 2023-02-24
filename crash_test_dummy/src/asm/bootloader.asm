;; ============================================================================
;; bootloader.asm
;;
;; It will load the kernel by reading the second sector on the first
;; disk.

    org 0x7C00 ; The code is loaded at 0x7C00 by the bootloader
               ; We need to set it otherwise when later in the code
               ; we will refer to memory location the address will be
               ; wrong. For example mov al, [outputChar] will not work.

;; MEMORY LAYOUT
;; https://wiki.osdev.org/Memory_Map_(x86)
;;
;; 0x0000_0500 - 0x0000_7BFF   | Conventional memory
;; 0x0000_7C00 - 0x0000_7E00   | It is us, the bootloader
;; 0x0000_7E00 - 0x0007_FFFF   | Conventional Memory
;;
;; We will use the second part of conventional memory.

    ; First we will load sector 2 (the File Table) at 0x0000:0x7E00
    ; It is 512 bytes after the bootloader
    xor bx, bx
    mov es, bx     ; es <- 0x0000
    mov bx, 0x7E00 ; Set [es:bx] to 0x7E00,
    mov cx, 0x0002 ; Cylinder: 0, Sector: 2
    mov al, 0x1    ; Read one sector (512 bytes)
    call load_disk_sector ; Read the kernel from disk

    ; Now we can load the kernel from sector 3 at 0x0000:0x80000
    ; As kernel is 1Ko we need to load two segments
    xor bx, bx
    mov es, bx     ; es <- 0x0000
    mov bx, 0x8000 ; Set [es:bx] to 0x8000,
    mov cx, 0x0003 ; Cylinder: 0, Sector: 3
    mov al, 0x2    ; Read 2 sectors
    call load_disk_sector ; Read the kernel from disk

    ; once loaded jump to the kernel
    jmp 0x8000

    ; Should not be reached !!!
    cli
    hlt

; load_disk_sector:
; Inputs:
;   - AL: Number of sectors to be read
;   - CH: Cylinder
;   - CL: Sector
;   - [ES:BX] the memory where we want to load the sector
; Clobbers:
;   - SI, AH, DX

load_disk_sector:
    ;  - es:bx are set set before calling it
    mov si, 0x5 ; disk reads should be retried at least three times
                ; we use SI because all others registers are needed

    ; Reset the disk before reading it
    mov ah, 0x0
    int 0x13

    mov ah, 0x2  ; BIOS service: read sectors from drive
                 ; AL is set when calling load_disk_sector
                 ; CH & CL are also already set
    mov dh, 0x0  ; Head 0
    mov dl, 0x80 ; First hard drive

    int 0x13 ; 0x13 BIOS service

    ; Check the result
    ; If CF == 1 then there is an error
    jc .failed_to_load_kernel

    ret

.failed_to_load_kernel:
    dec si
    jnz load_disk_sector ; if it is not zero we can retry

    ; We failed more than 3 times, it is over !!!
    cli
    hlt

    times 510-($-$$) db 0    ; padding with 0s
    dw 0xaa55        ; BIOS magic number

;; ============================================================================
;; load_disk_sector.asm
;;
;; Inputs:
;;   - AL: Number of sectors to be read
;;   - CH: Cylinder
;;   - CL: Sector
;;   - [ES:BX] the memory where we want to load the sector
;; Clobbers:
;;   - SI, AH, DX

load_disk_sector:
    ;  - es:bx are set set before calling it
    mov si, 0x3 ; disk reads should be retried at least three times
                ; we use SI because all others registers are needed

    ; Reset the disk before reading it
    mov ah, 0x0
    int 0x13

    mov ah, 0x2  ; BIOS service: read sectors from drive
                 ; AL is set when calling load_disk_sector
                 ; CH & CL are also already set
    mov dh, 0x0  ; Head 0
    mov dl, 0x80 ; Read first hard drive

    int 0x13     ; 0x13 BIOS service

    ; Check the result
    ; If CF == 1 then there is an error
    jc .failed_to_load_stage2

    ret

.failed_to_load_stage2:
    dec si
    jnz load_disk_sector ; if it is not zero we can retry

    ; We failed more than 3 times, it is over !!!
    cli
    hlt

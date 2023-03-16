;; ============================================================================
;; disks.asm
;;
;; This file provides functions to read disks using ATA PIO Ports in order to
;; be able to load a file.
;;    - load_file_from_disk
;;
;; Related links:
;;  - [ATA read/write sectors](https://wiki.osdev.org/ATA_read/write_sectors)
;; ============================================================================

;; ----------------------------------------------------------------------------
;; Load a file into memory given its filename and where to load it to.
;; Information about sectors or any needed information should be read from the
;; file table.
;; The file table has been loaded at 0x10:0x7E00.
;;
;; Params:
;;   - filename
;;   - memory segment to load file to
;;   - memory offset to load file to
load_file_from_disk:
    push ebp     ; save old base pointer
    mov ebp, esp ; use the current stack pointer as new base pointer

    ; save used parameters
    push eax
    push ebx
    push ecx
    push edi
    push edx
    push esi
    push fs

    ; Get parameters from stack
    mov eax, [ebp + 8]  ; the offset
    mov ebx, [ebp + 12] ; the segment
    mov esi, [ebp + 16] ; the filename

    ; TODO: for debugging purpose just print args...
    ; As it is loaded after display.asm we can use macros
    mov edi, fileParam
.loop:
    lodsb  ; AL <- ds:esi, esi++
    stosb  ; fs:edi <- AL, edi++
    cmp al, 0
    jne .loop

    print_string_display_macro inputStr
    print_regs_display_macro twoSpaces, ebx
    print_regs_display_macro twoSpaces, eax

.done:
    pop fs
    pop esi
    pop edx
    pop edi
    pop ecx
    pop ebx
    pop eax

    mov esp, ebp
    pop ebp
    ret

inputStr: db 0xA, 0xD ; we don't add 0 so it will print \n\rfileParam
fileParam: db 0,0,0,0,0,0,0,0,0,0
twoSpaces: db "  ", 0

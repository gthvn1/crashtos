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
    mov esi, [ebp + 8]  ; the offset
    mov fs,  [ebp + 12] ; the segment
    mov ebx, [ebp + 16] ; the filename

    ; TODO: for debugging purpose just print args...
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

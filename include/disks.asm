;; ============================================================================
;; disks.asm
;;
;; This file provides functions to read disks using ATA PIO Ports in order to
;; be able to load a file from the first hard drive.
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
    ; We will use INSB instruction (Input from Port to String) to copy data and
    ; this instruction input byte from I/O port specified in EDX into memory
    ; location specified in ES:EDI. So put parameters directly in right
    ; registers.
    ;mov esi, [ebp + 8]  ; the filename (not used yet, currently we hard coded)
    mov es, [ebp + 12]  ; the segment
    mov edi, [ebp + 16] ; the address of buffer to put data obtained from disk

    ; we know the editor has 4 sectors starting at 7
    ; TODO: Get 4 and 7 from file table
    mov edx, 0x1F6   ; port to send driver & head numbers
    xor al, al       ; head index is 0
    or al, 10100000b ; default 1010b in high nibble
    out dx, al

    mov edx, 0x1F2   ; Sector count port
    mov al, 0x4      ; let's hard code it for the moment
    out dx, al

    mov edx, 0x1F3   ; Sector number port
    mov al, 0x7      ; let's hard code it for the moment
    out dx, al

    mov edx, 0x1F4   ; Cylinder low port
    xor al, al       ; al = 0
    out dx, al

    mov edx, 0x1F7   ; Command port
    mov al, 0x20     ; Read with retry
    out dx, al

.still_going:
    in al, dx
    test al, 8   ; the sector buffer requires servicing
    jz .still_going

    mov eax, 512/2 ; to read 256 words = 1 sector
    xor bx, bx     ; read CH sectors
    mov ecx, eax   ; ecx is counter for insw
    mov edx, 0x1F0 ; Data port, in and out
    rep insw       ; in to [EDI]

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

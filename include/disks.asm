;; ============================================================================
;; disks.asm
;;
;; This file provides functions to read disks using ATA PIO Ports in order to
;; be able to load a file from the first hard drive.
;;    - load_file_from_disk
;;
;; Related links:
;;  - [ATA read/write sectors](https://wiki.osdev.org/ATA_read/write_sectors)
;;  - [ATA PIO Mode](https://wiki.osdev.org/ATA_PIO_Mode)
;;  - [forum](https://forum.osdev.org/viewtopic.php?t=12268)
;;
;; Read to port 1F7h is to get status:
;;      - bit 7 = 1  controller is executing a command
;;      - bit 6 = 1  drive is ready
;;      - bit 5 = 1  write fault
;;      - bit 4 = 1  seek complete
;;      - bit 3 = 1  sector buffer requires servicing
;;      - bit 2 = 1  disk data read corrected
;;      - bit 1 = 1  index - set to 1 each revolution
;;      - bit 0 = 1  previous command ended in an error
;;
;; Write to port 1F7h is command register when:
;;      - 50h format track
;;      - 20h read sectors with retry
;;      - 21h read sectors without retry
;;      - 22h read long with retry
;;      - 23h read long without retry
;;      - 30h write sectors with retry
;;      - 31h write sectors without retry
;;      - 32h write long with retry
;;      - 33h write long without retry
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
    ;mov esi, [ebp + 16]  ; the filename (not used yet, currently we hard coded)
    ;mov es, [ebp + 12]  ; the segment
    ;mov edi, [ebp + 8] ; the address of buffer to put data obtained from disk
    mov eax, 0x18
    mov es, eax
    xor eax, eax
    mov edi, eax    ; We want to copy data in 0x18:0x00000000

    ; we know the editor has 4 sectors starting at 7
    ; TODO: Get 4 and 7 from file table
    mov edx, 0x1F6     ; port 1F6b to send driver & head numbers
    mov al, 1010_0000b ; Bit 5-7 are: 101b
                       ; Bit 4 is 0 (select drive 0)
                       ; Bits 3-0 is head, in our case it is 0
    out dx, al

    mov edx, 0x1F2   ; Port 1F2b is How many sectors to read/write?
    mov ebx, 0x4     ; let's hard code it for the moment. We use ebx to count
    mov eax, 0x1     ; we will read 1 sector by 1 sector
    out dx, al       ; number of sector read.

    mov edx, 0x1F3   ; Port 1F3b is the sector wanted
    mov al, 0x7      ; let's hard code it for the moment
    out dx, al

    mov edx, 0x1F4   ; Port 1F4b is Cylinder low port
    xor al, al       ; al = 0
    out dx, al

    mov edx, 0x1F5   ; Port 1F5b is Cylinder high port
    xor al, al       ; al = 0
    out dx, al

    mov edx, 0x1F7   ; Command port
    mov al, 0x20     ; Read with retry
    out dx, al

    ; Before sending the next command ATA specs suggest to add a 400ns delay
    ; that can be achieve by reading the status register fifteen times.
    ; Using the alternate status register (3F6h) is a good choice. We implement
    ; the 400ns delay on ERR, BSY clean and DRQ set...
    mov ecx, 4

.poll_status:
    in al, dx     ; grab status
    test al, 0x80 ; BSY flag set?
    jne .retry
    test al, 8    ; DRQ set?
    je .data_ready
.retry:
    dec ecx
    jg .poll_status

    ; need to wait some more. Loop until BSY clears or ERR sets...
.wait_more:
    in al, dx
    test al, 0x80 ; BSY flag set?
    jne .wait_more
    test al, 0x21 ; ERR or DF sets?
    jne .failed
 
.data_ready:
    mov ecx, 256   ; to read 256 words = 1 sector, ecx is counter for insw
    mov edx, 0x1F0 ; Data register, bytes are read/written here...
    rep insw       ; in to ES:EDI

    mov edx, 0x1F7 ; delay 400ns to allow drive to set new values BSY and DRQ
    in al, dx
    in al, dx
    in al, dx
    in al, dx

    cmp ebx, 0
    je .done

    ; if ebx is not null we read the next sector
    jmp .poll_status

.failed:
    ; TODO: return an error

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

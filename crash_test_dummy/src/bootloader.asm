;; ============================================================================
;; bootloader.asm
;;
;; It will load the kernel by reading the second sector on the first
;; disk.

%include "include/constants.asm"

    org BOOTLO_OFFSET ; The code is loaded at 0x7C00 by the bootloader
                      ; We need to set it otherwise when later in the code
                      ; we will refer to memory location the address will be
                      ; wrong. For example mov al, [outputChar] will not work.

;; MEMORY LAYOUT
;; https://wiki.osdev.org/Memory_Map_(x86)
;;
;; 0x0000_0000 - 0x0000_03FF | 1KB   | Real Mode IVT
;; 0x0000_0400 - 0x0000_04FF | 256B  | Bios Data Area (BDA)
;; 0x0000_0500 - 0x0000_7BFF | ~30KB | Conventional memory
;; 0x0000_7C00 - 0x0000_7DFF | 512B  | It is us, the bootloader
;; 0x0000_7E00 - 0x0007_FFFF | 480KB | Conventional Memory
;;
;; 0x0008_0000 - 0x0009_FFFF | 128KB | EBDA
;; 0x000A_0000 - 0x000B_FFFF | 128KB | Video display memory
;; 0x000C_0000 - 0x000C_7FFF | 32KB  | Video BIOS
;; 0x000C_8000 - 0x000E_FFFF | 160KB | BIOS Expansions
;; 0x000F_0000 - 0x000F_FFFF | 64KB  | Motherboard BIOS
;;
;; We will use the 64KB from 0x0001_0000 - 0x0001_FFFF:
;;   - File Table  : 0x0001_0000 - 0x0001_01FF (512B)
;;   - Kernel      : 0x0001_0200 - 0x0001_09FF (2KB)
;;   - Stack       : 0x0001_A000 - 0x0001_FFFF (24Kb)
;;   - Loaded Prog : 0x0002_0000 - 0x0002_01FF (512B)
;; NOTE: The stack is growing in direction of the kernel... so be carfull :-)
;; We keep the file table and the kernel on the same segments. Otherwise when
;; we will access file table data from kernel we need to make far jump.

    ; First we will load sector 2 (the File Table) at 0x1000:0x0000
    mov bx, FTABLE_SEG
    mov es, bx            ; es <- 0x1000
    xor bx, bx            ; bx <- 0x0
                          ; Set [es:bx] to 0x0001:0x0000,

    mov cx, 0x00_02       ; Cylinder: 0, Sector: 2
    mov al, 0x1           ; Read one sector (512 bytes)
    call load_disk_sector ; Read the file table from disk

    ; Now we can load the kernel from sector 3 at 0x1000:0x0200
    ; As kernel is 1Ko we need to load two segments
    mov bx, KERNEL_OFFSET ; Set [es:bx] to 0x0001_0200,
    mov cx, 0x00_03       ; Cylinder: 0, Sector: 3
    mov al, 0x4           ; Read 4 sectors (2KB)
    call load_disk_sector ; Read the kernel from disk

    ; before jumping to the kernel we need to setup segments
    mov ax, KERNEL_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    jmp KERNEL_SEG:KERNEL_OFFSET ; far jump to kernel

    ; Should not be reached because we never returned from kernel space...
    cli
    hlt

%include "include/load_disk_sector.asm"

    times 510-($-$$) db 0    ; padding with 0s
    dw 0xaa55        ; BIOS magic number

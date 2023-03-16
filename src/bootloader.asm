;; ============================================================================
;; bootloader.asm
;;
;; Loads file table and kernel by reading disks. It sets up the GDT and do the
;; far jump to kernel in 32 bits protected mode.
;; ============================================================================

[ORG 0x7C00] ; The code is loaded at 0x7C00 by the bootloader
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
;;   - File Table  : 0x0000_7E00 - 0x0000_07FF (512B)
;;   - Kernel      : 0x0000_8000 - 0x0001_87FF (2KB)
;;   - Loaded Prog : 0x0001_0000 - 0x0001_FFFF (64KB)
;; We keep the file table and the stage2 on the same segments. Otherwise when
;; we will access file table data from stage2 we need to make far jump.

;; ==================[ WELCOME TO THE REALM OF REAL MODE ]=====================
[BITS 16]

    ; Setup the stack under us
    mov bp, 0x7C00
    mov ax, 0x0000
    mov ss, ax
    mov sp, bp  ; So stack is growing down from 0x0000:0x7C00 -> 0x0000:0x0500
                ; We don't check if it smashes BDA but 30KB is really huge...

    ; Setup video mode
    mov ah, 0x0 ; Set BIOS service to "set video mode"
    mov al, 0x3 ; 80x25 16 color text
    int 0x10    ; BIOS interrupt for video services

    ; First we will File Table from sector 2 at 0x0000:0x7E00
    xor bx, bx
    mov es, bx            ; es <- 0x0
    mov bx, 0x7E00        ; bx <- 0x7E00
                          ; Set [es:bx] to 0x0000:0x7E00

    mov cx, 0x00_02       ; Cylinder: 0, Sector: 2
    mov al, 0x1           ; Load 1 sector (512 bytes)
    call load_disk_sector ; Read the file table from disk

    ; Now we can load the stage2 from sector 3 at 0x0000:0x8000
    xor bx, bx
    mov es, bx
    mov bx, 0x8000   ; [ES:BX] <- 0x0000:0x8000
    mov cx, 0x00_03  ; Cylinder 0, Sector 3
    mov al, 0x4      ; Load 4 sectors (2KB)
    call load_disk_sector ; Read the file table from disk

    ; Setup GDT: http://www.osdever.net/tutorials/view/the-world-of-protected-mode
    ; after the setup of the GDT we will far jump to kernel so we won't be back.
    jmp setup_gdt

unreachable:
    cli
    hlt
    jmp unreachable

;; ============================================================================
;; load_disk_sector
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
.fatal_error:
    cli
    hlt
    jmp .fatal_error

;; ============================================================================
;; GDT
; We followed the Long Mode Setup from https://wiki.osdev.org/GDT_Tutorial
; GDT entry are 8 bytes long
;
; An entry is:
; +-------------------------------------------------------------------------------+
; | Base @(24-31) |G|DB| |A|Limit (16-19)|P|DPL(13-14)|S|Type(8-11)|Base @(16-23) |
; +-------------------------------------------------------------------------------+
; |    Base address (Bit 0-15)           |      Segment Limit                     |
; +-------------------------------------------------------------------------------+
;
; 0x00: keep it NULL
; 0x08: Kernel Code Seg (Base: 0x00000, Limit: 0xFFFFF, Access Byte: 0x9A, Flags: 0xC)
; 0x10: Kernel Data Seg (Base: 0x00000, Limit: 0xFFFFF, Access Byte: 0x92, Flags: 0xC)
; 0x18: User Code Seg   (Base: 0x10000, Limit: 0xFFFFF, Access Byte: 0xFA, Flags: 0xC)
; 0x20: User Data Seg   (Base: 0x10000, Limit: 0xFFFFF, Access Byte: 0xF2, Flags: 0xC)
; 0x28: Task State Seg  ...TO BE DONE

gdt:
.start:       ; Offset 0x00
	dd 0      ; null descriptor
	dd 0

.kernel_code: ; Offset 0x08
	dw 0xFFFF ; Segment Limit
	dw 0x0    ; Base@ low
	db 0x0    ; Base@ mid
	db 0x9A   ; Access Byte: 1001_1010
	db 0xCF   ; Flags + limit(16-19): 1100_1111
	db 0x0    ; Base@ hi

.kernel_data: ; Offset 0x10
	dw 0xFFFF ; Segment Limit
	dw 0x0    ; Base@ low
	db 0x0    ; Base@ mid
	db 0x92   ; Access Byte: 1001_0010
	db 0xCF   ; Flags + limit(16-19)
	db 0x0    ; Base@ hi

.user_code:   ; Offset 0x18
	dw 0xFFFF ; Segment Limit
	dw 0x0    ; Base@ low
	db 0x1    ; Base@ mid
	db 0xFA   ; Access Byte: 1111_1010
	db 0xCF   ; Flags + limit(16-19)
	db 0x0    ; Base@ hi

.user_data:   ; Offset 0x20
	dw 0xFFFF ; Segment Limit
	dw 0x0    ; Base@ low
	db 0x1    ; Base@ mid
	db 0xF2   ; Access Byte: 1111_0010
	db 0xCF   ; Flags + limit(16-19)
	db 0x0    ; Base@ hi
.end:

; We can now define the GDT descriptor that will be passed to lgdt
; https://wiki.osdev.org/Global_Descriptor_Table#GDTR
gdt_desc:
	dw gdt.end - gdt.start - 1 ; size of the table in bytes subtracted by 1
	dd gdt.start               ; the linear address of the GDT

setup_gdt:
    cli        ; ensure that interrupts are disabled
    xor ax, ax ; AX <- 0
    mov ds, ax ; ensure that DS is set to 0x0000 where our GDT is located

    lgdt [gdt_desc]

    mov eax, cr0
    or eax, 1
    mov cr0, eax  ; At this point we are in protected mode !!!

    ; We need to clear the instruction pipeline.
    ; A far jump will do the job and send us out into protected world!
    jmp 0x8:jump_32bits

;; ==================[ ENTER THE REALM OF PROTECTED MODE ]=====================

[BITS 32]
jump_32bits:
    ; Setup segment, kernel data is 0x10 in GDT
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    jmp 0x8:0x8000 ; Far jump to kernel...

    times 510-($-$$) db 0 ; padding with 0s
    dw 0xaa55             ; BIOS magic number

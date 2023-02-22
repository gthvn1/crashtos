;; ============================================================================
;; bootloader.asm
;;
;; It will load the kernel by reading the second sector on the first
;; disk.
;;
	org 0x7C00 ; The code is loaded at 0x7C00 by the bootloader
		   ; We need to set it otherwise when later in the code
		   ; we will refer to memory location the address will be
		   ; wrong. For example mov al, [outputChar] will not work.

	xor bx, bx
	mov es, bx      ; es <- 0x0000
	mov bx, 0x7E00  ; Set [es:bx] to 0x7E00, this is where the data
			; will be put when read from the disk. So it is
			; where the kernel will be loaded.

	call load_kernel_from_disk   ; Read the kernel from disk
	jmp 0x7E00	; If it returns then jump to the kernel

	; Should not be reached !!!
	cli
	hlt

load_kernel_from_disk:
	;  - es:bx are set set before calling it
	push si
	mov si, 0x5 ; disk reads should be retried at least three times
		    ; we use SI because all others registers are needed

	; Reset the disk before reading it
	mov ah, 0x0
	int 0x13

	mov ah, 0x2  ; Read sectors from drive
	mov al, 0x1  ; Only read 1 sector
	mov ch, 0x0  ; Cylinder 0
	mov cl, 0x2  ; Sector 2 (1 is where bootloader is stored)
		     ; Remember, sector starts from 1
	mov dh, 0x0  ; Head 0
	mov dl, 0x80 ; First hard drive

	int 0x13 ; 0x13 BIOS service

	; Check the result
	; If CF == 1 then there is an error
	jc .failed_to_load_kernel

	pop si
	ret

.failed_to_load_kernel:
	dec si       
	jnz load_kernel_from_disk ; if it is not zero we can retry

	; We failed more than 3 times, it is over !!!
	cli
	halt

	times 510-($-$$) db 0	; padding with 0s
	dw 0xaa55		; BIOS magic number

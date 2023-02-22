; read the first cylinder, first head and second sector of the first disk
;  - es:bx must be set before calling it
;  - Result is stored in memory at ES:BX
;  - clobber: AX

read_chs:
	push cx
	push dx
	push si

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
	jc .error

	mov si, loadKernelSucess
	call print_str
	call print_newline

	pop si
	pop dx
	pop cx
	ret

.error:
	mov dx, ax
	call print_hex
	call print_newline

	mov si, loadKernelFailed
	call print_str
	cli
	hlt

loadKernelFailed: db "ERROR: Failed to load kernel", 0
loadKernelSucess: db "Kernel loaded", 0

;; ============================================================================
;; editor.asm
;; TODO:
;;  - First step is to be called from kernel
editor:
    pusha               ; save all general purpose registers

    call clear_screen   ; clean the screen
    mov si, editorHdr   ; display a welcome message
    call print_str

    mov ah, 0x0 ; wait for keypress before jumping back to kernel
    int 0x16    ; BIOS interrupt for keyboard services

jmp_kernel:
    ; before jumping to the kernel we need to setup segments
    mov ax, 0x1000
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    popa              ; restore registers
    jmp 0x1000:0x0200 ; far jump to kernel

%include "include/clear_screen.asm"
%include "include/print_str.asm"

editorHdr: db "Inside editor !!!", 0

	; Sector padding to have a bin generated of 512 bytes (one sector)
	times 512-($-$$) db 0

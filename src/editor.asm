;; ============================================================================
;; editor.asm
;;
;; In the editor we will remove the use of BIOS interrupt. For video we are
;; using the Video Memory.
;;
;; To remove the BIOS keyboard service we will use PIO. Qemu is emulating then
;; PS/2 keyboard controller by default.
;; http://www-ug.eecg.toronto.edu/msl/nios_devices/datasheets/PS2%20Keyboard%20Protocol.htm
;; Three registers are directly accessible via port 0x60 and 0x64.
;;   - One byte input buffer:    0x60
;;   - One byte output buffer:   0x60
;;   - One byte status register: 0x64
;; When a key is pressed, a scancode is sent to the controller, converted and
;; placed in the input buffer.

[BITS 32]
[ORG 0x0]

;; ----------------------------------------------------------------------------
;; MAIN
editor:
    call clear_screen

    push editorHdr
    push 0x0000_1E00  ; BG: blue, FG: Yellow
    call print_line
    add sp, 8         ; cleanup the stack

    ; Just wait that enter is pressed before returning to kernel space
    call get_user_input

jmp_stage2:
    ; Setup segment, kernel data is 0x10 in GDT
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    jmp 0x8:0x8000 ; Far jump to kernel...

%include "include/screen/clear_screen.asm"
%include "include/screen/print_line.asm"
%include "include/keyboard/get_user_input.asm"

;; ----------------------------------------------------------------------------
;; VARIABLES

editorHdr:  db "Inside ctd-editor !!!", 0
xPos:       dd 0 ; required if we include screen files
yPos:       dd 0

    ; Sector padding to have a bin generated of 512 bytes (1 sector)
    times 512-($-$$) db 0

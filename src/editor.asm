;; ============================================================================
;; editor.asm
;;
;; In the editor we will remove the use of BIOS interrupt. For video we are
;; using the Video Memory. We still use the keyboard BIOS service but we check
;; how to remove it...
;;
;; Currently we only display a message and wait for a user input. Once user
;; hit a key we return to stage2. Nothing fancy...

%include "include/constants.asm"

org EDITOR_OFFSET

;; ----------------------------------------------------------------------------
;; MAIN
editor:
    ; In the editor we don't use BIOS interrupts for printing
    ; message. We use the Video Memory. We are still in 80x25

    mov ax, VIDEO_MEMORY
    mov es, ax  ; In real mode segment is shifted so es:0000 => 0xB8000

    ; To clean screen we can write 80x25 () spaces on the screen
    mov al, ' '
    mov ah, 0x1E
    mov di, 0
    mov cx, 2000   ; 80x25 (! it is not in hexa :)
    rep stosw      ; store AX at ES:DI repeated 2000 times

    mov si, editorHdr   ; display a welcome message
    call print_string

    mov ah, 0x0  ; wait for keypress before jumping back to stage2
    int 0x16     ; BIOS interrupt for keyboard services

jmp_stage2:
    ; before jumping to the stage2 we need to setup segments
    mov ax, STAGE2_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    jmp STAGE2_SEG:STAGE2_OFFSET ; far jump to stage2

;; ----------------------------------------------------------------------------
;; FUNCTIONS

print_trampoline:
    call print_char
print_string:
    lodsb        ; load DS:SI into AL and increment SI
    or al, al    ; "or-ing" will set ZF flags to 0 if al == 0
    jnz print_trampoline ; the trick here is that we jump to the trampoline that
                ; will call the print_char. So when the print_char will return
                ; the next instruction that will be executed is the lodsb.
                ; else al == 0 and so we reach the end of the string, so just go
                ; to the next line and return (we don't check if we overflow the
                ; video's memory)...
    add byte [ypos], 1 ; we suppose that we don't reach the end of the screen
    mov byte [xpos], 0 ; go to the beginning of the line
    ret

print_char:
    mov ah, 0x1E; 0x1 is for blue background and 0xE is for yellow foreground
    mov cx, ax  ; save attribute (rememer ASCII has been loaded in AL) because
                ; mul is using AX for the multiplication

    ; Now we need to compute DI that is where we want to print the character
    movzx ax, byte [ypos] ; move ypos into ax and extend with zeros
    mov dx, 160           ; There are 2 bytes and 80 columns
    mul dx                ; dx = ax * 160 (the offset computed for y)

    movzx bx, byte [xpos]
    shl bx, 1 ; Shift left is equivalent to mult by 2. As there are 2 bytes
              ; for attribute if x == 4 then the offset for x is +8

    ; So in ax we have the shift according to ypos, in bx we have the shift
    ; according to xpos if we add the 2 we have our position :-)
    mov di, 0   ; di = 0
    add di, ax  ; di = ax + 0 = ax
    add di, bx  ; di = ax + bx

    mov ax, cx ; restore the attribute (BG, FG, ASCII code)
    stosw      ; Store AX at ES:DI => Print the character

    add byte [xpos], 1 ; Update the position, we don't wrap
    ret

;; ----------------------------------------------------------------------------
;; VARIABLES

editorHdr db "Inside ctd-editor !!!", 0
xpos      db 0
ypos      db 0

    ; Sector padding to have a bin generated of 512 bytes (one sector)
    times 512-($-$$) db 0

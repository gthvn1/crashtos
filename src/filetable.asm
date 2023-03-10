;; ============================================================================
;; file_table.asm
;;
;; file table to allow the selection of a program
;; Bootloader will load it at 0000h:7E00h
;; Entry is 16 bytes:
;;    Byte      Description
;;    ----      -----------
;;    0-9       Filename
;;    10-12     extension (3 chars: exe, txt, bin...)
;;    13        "Directory entry"
;;    14        Starting sector (ie: 06h -> start at sector 6)
;;    15        File sector size:
;;                  - from 00h to FFh
;; ============================================================================

[ORG 0x7E00]
[BITS 32]

;; We declare byte per byte because it helps to dectect errors.
;;  0    1    2    3    4    5    6    7   8    9    10   11   12   13   14   15


db 'b', 'o', 'o', 't', 'S', 'e', 'c', 't', 00h, 00h, 'b', 'i', 'n', 00h, 01h, 01h
db 'f', 'i', 'l', 'e', 'T', 'a', 'b', 'l', 'e', 00h, 't', 'x', 't', 00h, 02h, 01h
db 'k', 'e', 'r', 'n', 'e', 'l', 00h, 00h, 00h, 00h, 'b', 'i', 'n', 00h, 03h, 04h
db 'e', 'd', 'i', 't', 'o', 'r', 00h, 00h, 00h, 00h, 'b', 'i', 'n', 00h, 07h, 02h

	; Sector padding to have a bin generated of 512 bytes (one sector)
	times 512-($-$$) db 0

;; ============================================================================
;; file_table.asm
;;
;; file table to allow the selection of a program
;; Bootloader will load it at 0x7E00
;; Entry is 16 bytes:
;;    Byte      Description
;;    ----      -----------
;;    0-9       Filename
;;    10-12     extension (3 chars: exe, txt, bin...)
;;    13        "Directory entry"
;;    14        Starting sector (ie: 0x6 -> start at sector 6)
;;    15        File sector size:
;;                  - from 0x00 to 0xff
;;
;; We declare byte per byte because it helps to dectect errors.
;;  0    1    2    3    4    5    6    7   8    9    10   11   12   13  14  15

db 'b', 'o', 'o', 't', 'S', 'e', 'c', 't', 0x0, 0x0, 'b', 'i', 'n', 0x0, 0x1, 0x1
db 'f', 'i', 'l', 'e', 'T', 'a', 'b', 'l', 'e', 0x0, 't', 'x', 't', 0x0, 0x2, 0x1
db 'k', 'e', 'r', 'n', 'e', 'l', 0x0, 0x0, 0x0, 0x0, 'b', 'i', 'n', 0x0, 0x3, 0x4
db 'c', 'a', 'l', 'c', 'u', 'l', 'a', 't', 'o', 'r', 'b', 'i', 'n', 0x0, 0x7, 0x1

	; Sector padding to have a bin generated of 512 bytes (one sector)
	times 512-($-$$) db 0

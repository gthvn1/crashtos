;; ============================================================================
;; file_table.asm
;;
;; file table to allow the selection of a program
;; Bootloader will load it at 7E00h
;; Entry is 16 bytes:
;;    Byte      Description
;;    ----      -----------
;;    0-9       Filename
;;    10-12     extension (3 chars: exe, txt, bin...)
;;    13        "Directory entry"
;;    14        Starting sector (ie: 6h -> start at sector 6)
;;    15        File sector size:
;;                  - from 00h to ffh
;;
;; We declare byte per byte because it helps to dectect errors.
;;  0    1    2    3    4    5    6    7   8    9    10   11   12   13  14  15
db 'b', 'o', 'o', 't', 'S', 'e', 'c', 't', 0h , 0h , 'b', 'i', 'n', 0h, 1h, 1h
db 'f', 'i', 'l', 'e', 'T', 'a', 'b', 'l', 'e', 0h , 't', 'x', 't', 0h, 2h, 1h
db 'k', 'e', 'r', 'n', 'e', 'l', 0h , 0h , 0h , 0h , 'b', 'i', 'n', 0h, 3h, 4h
db 'c', 'a', 'l', 'c', 'u', 'l', 'a', 't', 'o', 'r', 'b', 'i', 'n', 0h, 7h, 1h

	; Sector padding to have a bin generated of 512 bytes (one sector)
	times 512-($-$$) db 0

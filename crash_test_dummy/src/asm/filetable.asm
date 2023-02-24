;; ============================================================================
;; file_table.asm
;;
;; file table to allow the selection of a program
;; it is a string that says which program is located on which sector
;; For example:
;;   '{fileName1-sector#, fileName2-sector#, ... }
;;
;; Bootloader will load us at 0x7E00
db '{kernel-03, calculator-05}'

	; Sector padding to have a bin generated of 512 bytes (one sector)
	times 512-($-$$) db 0

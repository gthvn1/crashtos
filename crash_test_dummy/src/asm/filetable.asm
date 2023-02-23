;; ============================================================================
;; file_table.asm
;;
;; file table to allow the selection of a program
;; it is a string that says which program is located on which sector
;; For example:
;;   '{fileName1-sector#, fileName2-sector#, ... }
;;
;; The file table will be written on sector 2 after the bootloader.
;; So kernel will be in 3 and other program after the kernel
db '{kernel-03, calculator-04}'

	; Sector padding to have a bin generated of 512 bytes (one sector)
	times 512-($-$$) db 0

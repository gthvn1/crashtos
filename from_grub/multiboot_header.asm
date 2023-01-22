;; add an annotation to the section
section .multiboot_header

header_start:
	dd 0xe85250d6  	;; the magic for multiboot header
	dd 0		;; we want to boot in protected mode (tell it to grub)
	dd header_end - header_start ;; length of the header

	;; grub also requires a fourth parameter that is the checksum
	dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))

	;; required end tags
	dw 0	;; type
	dw 0	;; flags
	dd 8	;; size
header_end:


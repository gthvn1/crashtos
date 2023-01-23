;; add an annotation to the section
section .multiboot_header

;; See https://www.gnu.org/software/grub/manual/multiboot2/multiboot.html
header:
	.start:
	dd 0xE85250D6	;; the magic for multiboot2 header
	dd 0x0		;; the field arch: 0 => 3 bit protected mode fir i386
	dd header.end - header.start ;; length of the header including magic fields
	;; grub also requires a fourth parameter that is the checksum
	;; with checksum = - (magic + arch + length)
	dd 0x100000000 - (0xE85250D6 + 0x0 + (header.end - header.start))

	;; required end tags
	dw 0	;; type
	dw 0	;; flags
	dd 8	;; size
	.end:


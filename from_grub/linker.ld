ENTRY(start)  /* entry point for the executable... remember global in boot.asm */

PHYS = 0x00100000;

SECTIONS {
	. = PHYS;

	.text : {
		/* multiboot header must be at the beginning */
		__boot_start = . ;
		*(.multiboot_header)
		__boot_end = . ;
		__text_start = . ;
		*(.text)
		. = ALIGN(4096) ;
		__text_end = . ;
	}

	.data : {
		__data_start = . ;
		*(.data)
		. = ALIGN(4096) ;
		__data_end = . ;
		__bss_start = . ;
		*(.bss)
		. = ALIGN(4096) ;
		__bss_end = . ;
	}

	__end = . ;
}

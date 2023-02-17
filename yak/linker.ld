ENTRY(_start)  /* entry point for the executable... remember global in boot.asm */

PHYS = 0x00100000;

SECTIONS {
	. = PHYS;

	__text_start = . ;
	.text : {
		/* multiboot header must be at the beginning */
		KEEP(*(.multiboot_header))
		*(.text)
		. = ALIGN(4096) ;
	}
	__text_end = . ;

	__rodata_start = . ;
	.rodata : {
		*(.rodata)
		. = ALIGN(4096) ;
	}
	__rodata_end = . ;

	__data_start = . ;
	.data : {
		*(.data)
		. = ALIGN(4096) ;
	}
	__data_end = . ;

	__bss_start = . ;
	.bss : {
		*(.bss)
		. = ALIGN(16384) ;
	}
	__bss_end = . ;

	__end = . ;
}

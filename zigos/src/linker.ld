ENTRY(kmain)  /* kernel main entry point */

PHYS = 0x00100000;

SECTIONS {
	. = PHYS;

	.text : {
		/* multiboot header must be at the beginning */
		KEEP(*(.multiboot))
		*(.text)
		. = ALIGN(4096) ;
	}

	.data : {
		*(.data)
		. = ALIGN(4096) ;
		*(.bss)
		. = ALIGN(4096) ;
	}

	__end = . ;
}

ENTRY(start)  /* entry point for the executable... remember global in boot.asm */

phys = 0x00100000;

SECTIONS {
	/* create a section boot */
	.boot phys : AT(phys) {
		/* multiboot header must be at the beginning of the boot section */
		boot = . ;  /* keep a reference where we put boot */
		*(.multiboot_header)
	}

	/* Right above the boot we put the text */
	.text : AT(phys + (text - boot)) {
		text = . ;
		*(.text)
	}
}

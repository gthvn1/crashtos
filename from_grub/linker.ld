ENTRY(start)  /* entry point for the executable... remember global in boot.asm */

SECTIONS {
	. = 1M; /* Start putting things at 1M. It is a convention */

	.boot :  /* create a secion boot */
	{
		/* multiboot header must be at the beginning of the boot section */
		/* grub will see it */
		*(.multiboot_header)
	}

	.text : /* create a section text */
	{
		*(.text)
	}
}

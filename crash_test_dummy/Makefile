.PHONY: run clean

FLOPPY=floppy.bin

run: $(FLOPPY) disk.raw
	bochs -q

disk.raw:
	qemu-img create disk.raw 510K

# BIN format puts NASM by default in 16-bit mode
$(FLOPPY): boot.asm
	nasm -f bin -o $@ $<

clean:
	rm -f $(FLOPPY)

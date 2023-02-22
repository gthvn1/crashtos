.PHONY: run clean

FLOPPY=floppy.bin

run: $(FLOPPY)
	bochs -q

$(FLOPPY): boot.asm
	nasm -f bin -o $@ $<

clean:
	rm -f $(FLOPPY)

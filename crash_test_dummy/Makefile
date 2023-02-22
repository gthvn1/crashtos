.PHONY: run clean

run: disk.raw
	bochs -q

disk.raw: bootloader.bin kernel.bin
	cat bootloader.bin kernel.bin > $@

# BIN format puts NASM by default in 16-bit mode
kernel.bin: kernel.asm
	nasm -f bin -o $@ $<

bootloader.bin: bootloader.asm
	nasm -f bin -o $@ $<

clean:
	rm -f *.bin disk.raw

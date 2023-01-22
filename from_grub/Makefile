.PHONY: default run build clean

default: build

run: build
	qemu-system-x86_64 -cdrom yak.iso

build: kernel.bin grub.cfg
	mkdir -p isofiles/boot/grub
	mv kernel.bin isofiles/boot/
	cp grub.cfg isofiles/boot/grub/
	grub2-mkrescue -o yak.iso isofiles

kernel.bin: multiboot_header.o boot.o
	ld -nmagic --output=kernel.bin --script=linker.ld multiboot_header.o boot.o

multiboot_header.o: multiboot_header.asm
	nasm -f elf64 multiboot_header.asm

boot.o: boot.asm
	nasm -f elf64 boot.asm

clean:
	rm -rf multiboot_header.o boot.o yak.iso isofiles/

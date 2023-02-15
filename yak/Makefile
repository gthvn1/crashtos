.PHONY: default run build clean

default: build

run: build
	qemu-system-x86_64 -cdrom yak.iso

build: kernel.bin grub.cfg
	mkdir -p iso/boot/grub
	mv kernel.bin iso/boot/
	cp grub.cfg iso/boot/grub/
	grub2-mkrescue -o yak.iso iso

kernel.bin: multiboot_header.o boot.o
	ld -nmagic --output=kernel.bin --script=linker.ld multiboot_header.o boot.o

multiboot_header.o: multiboot_header.asm
	nasm -f elf64 multiboot_header.asm

boot.o: boot.asm
	nasm -f elf64 boot.asm

clean:
	rm -rf multiboot_header.o boot.o yak.iso iso/

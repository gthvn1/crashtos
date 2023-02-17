.PHONY: default run build clean

override CFLAGS = -m32

default: build

run: build
	qemu-system-x86_64 -cdrom yak.iso

build: kernel.bin grub.cfg
	mkdir -p iso/boot/grub
	mv kernel.bin iso/boot/
	cp grub.cfg iso/boot/grub/
	grub2-mkrescue -o yak.iso iso

kernel.bin: multiboot_header.o boot.o kernel.o
	ld -m elf_i386 -nostdlib -o $@ -T linker.ld $^

kernel.o: src/kernel.zig
	zig build-obj -target i386-freestanding $<

multiboot_header.o: multiboot_header.asm
	nasm -f elf32 multiboot_header.asm

boot.o: boot.asm
	nasm -f elf32 boot.asm

clean:
	rm -rf multiboot_header.o boot.o yak.iso iso/ kernel.o kernel.d src/zig-cache

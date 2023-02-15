.PHONY: default run build clean

override CFLAGS +=       \
    -std=c11             \
    -ffreestanding       \
    -fno-stack-protector \
    -fno-stack-check     \
    -fno-lto             \
    -fno-pie             \
    -fno-pic             \
    -m64                 \
    -march=x86-64        \
    -mabi=sysv           \
    -mno-80387           \
    -mno-mmx             \
    -mno-sse             \
    -mno-sse2            \
    -mno-red-zone        \
    -mcmodel=kernel      \
    -MMD                 \
    -I.

default: build

run: build
	qemu-system-x86_64 -cdrom yak.iso

build: kernel.bin grub.cfg
	mkdir -p iso/boot/grub
	mv kernel.bin iso/boot/
	cp grub.cfg iso/boot/grub/
	grub2-mkrescue -o yak.iso iso

kernel.bin: multiboot_header.o boot.o kernel.o
	ld -nostdlib -nmagic --output=kernel.bin --script=linker.ld multiboot_header.o boot.o kernel.o

kernel.o: kernel.c
	$(CC) $(CFLAGS) -c $< -o $@

multiboot_header.o: multiboot_header.asm
	nasm -f elf64 multiboot_header.asm

boot.o: boot.asm
	nasm -f elf64 boot.asm

clean:
	rm -rf multiboot_header.o boot.o yak.iso iso/ kernel.o kernel.d

.PHONY: iso clean

CFLAGS = -m32
BUILD_DIR = build
ASM_DIR = asm
DEPS = $(BUILD_DIR)/multiboot_header.o $(BUILD_DIR)/boot.o $(BUILD_DIR)/kmain.o

iso: $(BUILD_DIR)/iso/boot/kernel.bin
	mkdir -p $(BUILD_DIR)/iso/boot/grub
	cp grub/grub.cfg build/iso/boot/grub/
	grub2-mkrescue -o build/yak.iso build/iso

$(BUILD_DIR)/iso/boot/kernel.bin: $(DEPS)
	mkdir -p $(BUILD_DIR)/iso/boot
	ld -m elf_i386 -nostdlib -o $@ -T linker.ld $^

$(BUILD_DIR)/kmain.o: kernel/kmain.zig
	mkdir -p $(BUILD_DIR)
	zig build-obj -target i386-freestanding $<
	mv kmain.o build/

$(BUILD_DIR)/%.o: $(ASM_DIR)/%.asm
	mkdir -p $(BUILD_DIR)
	nasm -f elf32 -o $@ $<

clean:
	rm -rf $(BUILD_DIR) kernel/zig-cache

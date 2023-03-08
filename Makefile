.PHONY: rebuild bochs qemu clean

SRC_ASM := src
BIN_DIR := bin

$(shell mkdir -p $(BIN_DIR))

BOOTLOADER := $(BIN_DIR)/bootloader.bin # 1 * 512B
FILETABLE  := $(BIN_DIR)/filetable.bin  # 1 * 512B
KERNEL     := $(BIN_DIR)/kernel.bin     # 4 * 512B
EDITOR     := $(BIN_DIR)/editor.bin     # 1 * 512B

MINIOS := $(BIN_DIR)/mini-os.bin

rebuild:
	make clean
	make $(MINIOS)

$(MINIOS): $(BOOTLOADER) $(FILETABLE) $(KERNEL) $(EDITOR)
	dd if=/dev/zero     of=$(MINIOS) bs=512 count=2880
	dd if=$(BOOTLOADER) of=$(MINIOS) bs=512 seek=0 conv=notrunc
	dd if=$(FILETABLE)  of=$(MINIOS) bs=512 seek=1 conv=notrunc
	dd if=$(KERNEL)     of=$(MINIOS) bs=512 seek=2 conv=notrunc
	dd if=$(EDITOR)     of=$(MINIOS) bs=512 seek=6 conv=notrunc

# BIN format puts NASM by default in 16-bit mode
$(BIN_DIR)/%.bin: $(SRC_ASM)/%.asm
	nasm -f bin -o $@ $<

bochs: rebuild $(MINIOS)
	bochs -q

qemu: rebuild $(MINIOS)
	qemu-system-i386 -drive format=raw,if=ide,index=0,media=disk,file=$(MINIOS)

clean:
	rm -rf $(BIN_DIR)

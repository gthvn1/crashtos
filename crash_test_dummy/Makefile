.PHONY: run

SRC_ASM := src/asm
BIN_DIR := bin

$(shell mkdir -p $(BIN_DIR))

BOOTLOADER    := $(BIN_DIR)/bootloader.bin
FILETABLE     := $(BIN_DIR)/filetable.bin
KERNEL        := $(BIN_DIR)/kernel.bin
MINIOS        := $(BIN_DIR)/mini-os
MINIOS_FLOPPY := $(BIN_DIR)/mini-os.floppy

$(MINIOS): $(BOOTLOADER) $(FILETABLE) $(KERNEL)
	cat $^ > $(MINIOS)
	dd if=/dev/zero of=$(MINIOS_FLOPPY) bs=512 count=2880
	dd if=$(MINIOS) of=$(MINIOS_FLOPPY) conv=notrunc

# Explicitly call `make run` to start bochs
run: $(MINIOS)
	bochs -q

# BIN format puts NASM by default in 16-bit mode
$(BOOTLOADER): $(SRC_ASM)/bootloader.asm
	nasm -f bin -o $@ $<

$(FILETABLE): $(SRC_ASM)/filetable.asm
	nasm -f bin -o $@ $<

$(KERNEL): $(SRC_ASM)/kernel.asm
	nasm -f bin -o $@ $<

clean:
	rm -rf $(BIN_DIR)

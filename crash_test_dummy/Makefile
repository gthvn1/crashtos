.PHONY: run

SRC_ASM := src/asm
BIN_DIR := bin

$(shell mkdir -p $(BIN_DIR))

BOOTLOADER := $(BIN_DIR)/bootloader.bin
KERNEL     := $(BIN_DIR)/kernel.bin
MINIOS	   := $(BIN_DIR)/mini-os

run: $(MINIOS)
	bochs -q

$(MINIOS): $(BOOTLOADER) $(KERNEL)
	cat $^ > $(MINIOS)

# BIN format puts NASM by default in 16-bit mode
$(BOOTLOADER): $(SRC_ASM)/bootloader.asm
	nasm -f bin -o $@ $<

$(KERNEL): $(SRC_ASM)/kernel.asm
	nasm -f bin -o $@ $<

clean:
	rm -rf $(BIN_DIR)

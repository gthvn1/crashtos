.PHONY: run

SRC_ASM := src/asm
BIN_DIR := bin

$(shell mkdir -p $(BIN_DIR))

BOOTLOADER    := $(BIN_DIR)/bootloader.bin # 1 * 512B
FILETABLE     := $(BIN_DIR)/filetable.bin  # 1 * 512B
KERNEL        := $(BIN_DIR)/kernel.bin     # 4 * 512B
CALCULATOR    := $(BIN_DIR)/calculator.bin # 1 * 512B
MINIOS_FLOPPY := $(BIN_DIR)/mini-os.floppy

$(MINIOS_FLOPPY): $(BOOTLOADER) $(FILETABLE) $(KERNEL) $(CALCULATOR)
	dd if=/dev/zero     of=$(MINIOS_FLOPPY) bs=512 count=2880
	dd if=$(BOOTLOADER) of=$(MINIOS_FLOPPY) bs=512 seek=0 conv=notrunc
	dd if=$(FILETABLE)  of=$(MINIOS_FLOPPY) bs=512 seek=1 conv=notrunc
	dd if=$(KERNEL)     of=$(MINIOS_FLOPPY) bs=512 seek=2 conv=notrunc
	dd if=$(CALCULATOR) of=$(MINIOS_FLOPPY) bs=512 seek=6 conv=notrunc

# Explicitly call `make run` to start bochs
run: $(MINIOS_FLOPPY)
	bochs -q

# BIN format puts NASM by default in 16-bit mode
$(BOOTLOADER): $(SRC_ASM)/bootloader.asm
	nasm -f bin -o $@ $<

$(FILETABLE): $(SRC_ASM)/filetable.asm
	nasm -f bin -o $@ $<

$(KERNEL): $(SRC_ASM)/kernel.asm
	nasm -f bin -o $@ $<

$(CALCULATOR): $(SRC_ASM)/calculator.asm
	nasm -f bin -o $@ $<

clean:
	rm -rf $(BIN_DIR)

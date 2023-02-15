#include <stdint.h>

enum VGAColor {
	VGAColor_BLACK = 0,
	VGAColor_BLUE = 1,
	VGAColor_GREEN = 2,
	VGAColor_CYAN = 3,
	VGAColor_RED = 4,
	VGAColor_MAGENTA = 5,
	VGAColor_BROWN = 6,
	VGAColor_LIGHT_GREY = 7,
	VGAColor_DARK_GREY = 8,
	VGAColor_LIGHT_BLUE = 9,
	VGAColor_LIGHT_GREEN = 10,
	VGAColor_LIGHT_CYAN = 11,
	VGAColor_LIGHT_RED = 12,
	VGAColor_LIGHT_MAGENTA = 13,
	VGAColor_LIGHT_BROWN = 14,
	VGAColor_WHITE = 15,
};

const uint16_t VGA_WIDTH = 80;
const uint16_t VGA_HEIGHT = 25;

uint16_t *ttyBuffer = (uint16_t*) 0xB8000;

static inline uint8_t vga_entry_color(enum VGAColor fg, enum VGAColor bg)
{
	return fg | bg << 4;
}

static inline uint16_t vga_entry(unsigned char uc, uint8_t color)
{
	return (uint16_t) uc | (uint16_t) color << 8;
}

void tty_put_char_at(char c, uint8_t color, uint16_t x, uint16_t y)
{
	const uint16_t index = y * VGA_WIDTH + x;
	ttyBuffer[index] = vga_entry(c, color);
}

void kernel_main(void)
{
	uint8_t ttyColor = vga_entry_color(VGAColor_LIGHT_GREY, VGAColor_BLACK);

	tty_put_char_at('O', ttyColor, 2, 2);
	tty_put_char_at('K', ttyColor, 4, 2);

	for(;;) {}
}

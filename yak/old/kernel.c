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

typedef unsigned char uint8_t;
typedef unsigned short uint16_t;

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

static unsigned int string_len(const char *str)
{
	unsigned int len = 0;
	while (str[len])
		len++;

	return len;
}

static void tty_put_char_at(char c, uint8_t color, uint16_t x, uint16_t y)
{
	const uint16_t index = y * VGA_WIDTH + x;
	ttyBuffer[index] = vga_entry(c, color);
}

static void tty_write(const char* data, uint8_t color, uint16_t x, uint16_t y)
{
	unsigned int len = string_len(data);

	for (unsigned int i = 0; i < len; i++) {
		tty_put_char_at(data[i], color, x, y);
		// update x and y
		x++;
		if (x == VGA_WIDTH) {
			x = 0;
			y++;
			if (y == VGA_HEIGHT) {
				y = 0;
			}
		}
	}
}

void kmain(void)
{
	uint8_t ttyColor;

	ttyColor = vga_entry_color(VGAColor_LIGHT_GREY, VGAColor_BLACK);
	tty_write("In the kernel !!!", ttyColor, 0, 1);

	ttyColor = vga_entry_color(VGAColor_LIGHT_GREEN, VGAColor_BLACK);
	tty_write("Isn't that cool :-)", ttyColor, 0, 2);

	for(;;) {}
}

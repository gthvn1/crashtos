const mem = @import("std").mem;

// screen properties
const VGA_WIDTH = 80;
const VGA_HEIGHT = 25;
const VGA_SIZE = VGA_WIDTH * VGA_HEIGHT;

// colors definitions
const VGA_COLOR_BLACK: u8 = 0;
const VGA_COLOR_BLUE: u8 = 1;
const VGA_COLOR_GREEN: u8 = 2;
const VGA_COLOR_CYAN: u8 = 3;
const VGA_COLOR_RED: u8 = 4;
const VGA_COLOR_MAGENTA: u8 = 5;
const VGA_COLOR_BROWN: u8 = 6;
const VGA_COLOR_LIGHT_GREY: u8 = 7;
const VGA_COLOR_DARK_GREY: u8 = 8;
const VGA_COLOR_LIGHT_BLUE: u8 = 9;
const VGA_COLOR_LIGHT_GREEN: u8 = 10;
const VGA_COLOR_LIGHT_CYAN: u8 = 11;
const VGA_COLOR_LIGHT_RED: u8 = 12;
const VGA_COLOR_LIGHT_MAGENTA: u8 = 13;
const VGA_COLOR_LIGHT_BROWN: u8 = 14;
const VGA_COLOR_WHITE: u8 = 15;

// 0x0E => 0x0: background black & 0xE: foreground yellow
fn vgaEntryColor(fg: u8, bg: u8) u8 {
    return bg << 4 | fg;
}

// 0x0E48 => 0x0: background black & 0xE: foreground yellow & 0x48: char
fn vgaEntry(car: u8, color: u8) u16 {
    var color_u16: u16 = color;
    return color_u16 << 8 | car;
}

// Terminal state
var term_row: u8 = undefined;
var term_column: u8 = undefined;
var term_color: u8 = undefined;
var term_buff = @intToPtr([*]volatile u16, 0xB8000);

fn setColor(fg: u8, bg: u8) void {
    term_color = vgaEntryColor(fg, bg);
}

fn putEntryAt(c: u8, color: u8, x: u8, y: u8) void {
    const index: u8 = y * VGA_WIDTH + x;
    term_buff[index] = vgaEntry(c, color);
}

fn putChar(c: u8) void {
    putEntryAt(c, term_color, term_column, term_row);
    // Update row and columns
    term_column += 1;
    if (term_column == VGA_WIDTH) {
        nextLine();
    }
}

pub fn initialize() void {
    term_row = 0;
    term_column = 0;
    term_color = vgaEntryColor(VGA_COLOR_GREEN, VGA_COLOR_BLACK);
    mem.set(u16, term_buff[0..VGA_SIZE], vgaEntry(' ', term_color));
}

pub fn nextLine() void {
    term_column = 0;
    term_row += 1;
    if (term_row == VGA_HEIGHT) {
        term_row = 0;
    }
}

pub fn write(s: []const u8) void {
    for (s) |c| {
        putChar(c);
    }
}

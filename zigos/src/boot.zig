const mem = @import("std").mem;

const ALIGN = 1 << 0; // align loaded modules on page boundaries
const MEMINFO = 1 << 1; // provide memory map
const FLAGS = ALIGN | MEMINFO; // this is the Multiboot 'flag' field
const MAGIC = 0x1BADB002; // 'magic' lets bootloader find the header
const CHECKSUM = -(MAGIC + FLAGS); // checksum to prove we are multiboot

const MultibootHeader = packed struct {
    magic: i32 = MAGIC,
    flags: i32 = FLAGS,
    checksum: i32 = CHECKSUM,
};

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
fn vga_entry_color(fg: u8, bg: u8) u8 {
    return bg << 4 | fg;
}

// 0x0E48 => 0x0: background black & 0xE: foreground yellow & 0x48: char
fn vga_entry(car: u8, color: u8) u16 {
    var color_u16: u16 = color;
    return color_u16 << 8 | car;
}

// Terminal state
var terminalRow: u8 = 0;
var terminalColumn: u8 = 0;
var terminalColor = vga_entry_color(VGA_COLOR_LIGHT_BROWN, VGA_COLOR_BLUE);
var terminalBuffer = @intToPtr([*]volatile u16, 0xB8000);

fn terminal_initialize() void {
    mem.set(u16, terminalBuffer[0..VGA_SIZE], vga_entry(' ', terminalColor));
}

export var multiboot align(4) linksection(".multiboot") = MultibootHeader{};

export fn kmain() callconv(.Naked) noreturn {
    terminal_initialize();
    while (true) {}
}

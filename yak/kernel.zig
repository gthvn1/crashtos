const tty = @import("tty.zig");

export fn kmain() callconv(.Naked) noreturn {
    tty.initialize();
    tty.write("Welcome from zig", tty.VGAColor.Green, tty.VGAColor.Black);

    while (true) {
        asm volatile ("hlt");
    }
}

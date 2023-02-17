const tty = @import("tty.zig");

export fn kmain() callconv(.Naked) noreturn {
    tty.initialize();
    tty.write("-= YaK version 0.1 =-", tty.VGAColor.LightBrown, tty.VGAColor.Blue);
    tty.nextLine();
    tty.nextLine();
    tty.write(" Welcome from zig", tty.VGAColor.Green, tty.VGAColor.Black);

    while (true) {
        asm volatile ("hlt");
    }
}

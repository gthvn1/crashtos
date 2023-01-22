# Yet Another Kernel

  The goal is to try to understand the differents steps from switching your computer
on until executing kernel.

## Blog posts

In the first post we see how BIOS is loading our first stage0 boot that just print
*Hello, World!* from real mode (16 bits).
- [Hello from bootloader](https://gthvn1.github.io/blog/blog/bootloader-hello-world/)

In the second post we see how to reach the protected mode and we print the same
*Hello, World!* but in protected mode.
- [Good bye real mode](https://gthvn1.github.io/blog/posts/bootloader-good-bye-real-mode/)

The role of the bootloader is to setup things for switching to protected mode, read
the code of an operating system from a boot device, load this piece of code somewhere
and finally jump to the entry code of this new software. In the next post we will see
how a bootloader (we will use grub) is able to load another *Hello, World!* but this
time from our operating system...

## Some interesting links

- [Redox bootloader](https://gitlab.redox-os.org/redox-os/bootloader)
- [BIOS interrupt call](https://en.wikipedia.org/wiki/BIOS_interrupt_call)
- [OSDev bootloder wiki](https://wiki.osdev.org/Bootloader)
- [Multiboot headers](https://intermezzos.github.io/book/first-edition/multiboot-headers.html)

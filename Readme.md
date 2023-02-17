# Yet Another Kernel

  The goal is to try to understand the differents steps from switching your computer
on until executing kernel. For this we will follow [OSDev tutorials](https://wiki.osdev.org/Tutorials).

## Babysteps

Steps to create a basic kernel in assembly are in [Babysteps](https://wiki.osdev.org/Tutorials#Babysteps).

How to create a basic kernel in assembly:
- [X] [Babystep1](https://wiki.osdev.org/Babystep1) - Your first boot sector.
- [X] [Babystep2](https://wiki.osdev.org/Babystep2) - Writing a message using the BIOS.
- [X] [Babystep3](https://wiki.osdev.org/Babystep3) - A look at machine code
- [X] [Babystep4](https://wiki.osdev.org/Babystep4) - Printing to the screen without the BIOS
- [X] [Babystep5](https://wiki.osdev.org/Babystep5) - Interrupts
- [ ] [Babystep6](https://wiki.osdev.org/Babystep6) - Entering protected mode
- [ ] [Babystep7](https://wiki.osdev.org/Babystep7) - Unreal Mode
- [ ] [Babystep8](https://wiki.osdev.org/Babystep0) - 32-bit printing
- Appendix A - [Additional information](https://wiki.osdev.org/Real_mode_assembly_appendix_A)

### Babystep1

- To debug and check that everything is working as expected you can start qemu as follow:
  - `qemu-system-i386 -s -S -fda boot.bin`
- And in another terminal attach gdb:
```sh
gdb -ex 'target remote localhost:1234' -ex 'set disassembly-flavor intel'
(gdb) b *0x7c00
(gdb) c
Breakpoint 1, 0x00007c00 in ?? ()
(gdb) x/2i $pc
=> 0x7c00:	cli
   0x7c01:	jmp    0x7c01
```
- As you see it is our code that it is running...

### Babystep2

- Just run `qemu-system-i386 -hda boot.bin` and you should see the famous **Hello, World!**.
  - `-fda` is working as well.

### Babystep3

- We use `hexdump` to see binary file:
```sh
# hexdump -C boot.bin
00000000  fa 31 c0 8e d8 be 16 7c  fc ac 08 c0 74 06 b4 0e  |.1.....|....t...|
00000010  cd 10 eb f5 eb fe 48 65  6c 6c 6f 2c 20 57 6f 72  |......Hello, Wor|
00000020  6c 64 21 00 00 00 00 00  00 00 00 00 00 00 00 00  |ld!.............|
00000030  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
000001f0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 55 aa  |..............U.|
00000200
```
- We see for example *fa* that is the opcode for **cli**.
- Then *31* that is the opcode for **xor register**. To decode the instruction completely we need
  to check the [instruction format](http://www.baldwin.cx/386htm/s17_02.htm).

### Babystep4

Nothing really special.

### Babystep5

Now you can press a key and you will see the value read from the keyboard... Cool no?

### Babysteps 6 to 8

They are not really interesting. It is said that we need to setup the GDT to be able
to jump to protected mode. We already wrote a blog about this and it is almost done
in [ZigOS](https://github.com/gthvn1/zigos).

## YaK (Yet another Kernel)

It is the main project, it has its own [Readme.md](https://github.com/gthvn1/yet-another-kernel/blob/master/yak/Readme.md) file...

## Blog posts related to previous paragraphs

### Hello from bootloader

  In the first post we see how BIOS is loading our first stage0 boot that just print
*Hello, World!* from real mode (16 bits).
- [Hello from bootloader](https://gthvn1.github.io/blog/blog/bootloader-hello-world/)

### Good bye real mode

  In the second post we see how to reach the protected mode and we print the same
*Hello, World!* but in protected mode.
- [Good bye real mode](https://gthvn1.github.io/blog/posts/bootloader-good-bye-real-mode/)

### Your door to operating system

  The role of the bootloader is to setup things for switching to protected mode, read
the code of an operating system from a boot device, load this piece of code somewhere
and finally jump to the entry code of this new software. In the next post we will see
how a bootloader (we will use grub) is able to load another *Hello, World!* but this
time from our operating system...
- [Your door to operating system](https://gthvn1.github.io/blog/posts/your-door-to-os/)

### Enter long mode

  A first try using [Zig](https://ziglang.org/) but unfortunatly we had some issues for
building it.
  - [Enter long mode](https://www.thouvenin.eu/blog/posts/enter-long-mode/)

## Some interesting links

- [The little book about OS development](https://ordoflammae.github.io/littleosbook/)
- [OSDev long mode](https://wiki.osdev.org/Setting_Up_Long_Mode)
- [Redox bootloader](https://gitlab.redox-os.org/redox-os/bootloader)
- [BIOS interrupt call](https://en.wikipedia.org/wiki/BIOS_interrupt_call)
- [OSDev bootloder wiki](https://wiki.osdev.org/Bootloader)
- [Multiboot headers](https://intermezzos.github.io/book/first-edition/multiboot-headers.html)

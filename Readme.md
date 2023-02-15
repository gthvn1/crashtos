# Yet Another Kernel

  The goal is to try to understand the differents steps from switching your computer
on until executing kernel. For this we will follow [OSDev tutorials](https://wiki.osdev.org/Tutorials).

## Babystep

Steps to create a basic kernel in assembly are in [Babysteps](https://wiki.osdev.org/Tutorials#Babysteps).

How to create a basic kernel in assembly:
- [X] [Babystep1](https://wiki.osdev.org/Babystep1) - Your first boot sector.
- [ ] [Babystep2](https://wiki.osdev.org/Babystep2) - Writing a message using the BIOS.
- [ ] [Babystep3](https://wiki.osdev.org/Babystep3) - A look at machine code
- [ ] [Babystep4](https://wiki.osdev.org/Babystep4) - Printing to the screen without the BIOS
- [ ] [Babystep5](https://wiki.osdev.org/Babystep5) - Interrupts
- [ ] [Babystep6](https://wiki.osdev.org/Babystep6) - Entering protected mode
- [ ] [Babystep7](https://wiki.osdev.org/Babystep7) - Unreal Mode
- [ ] [Babystep8](https://wiki.osdev.org/Babystep0) - 32-bit printing
- [ ] Appendix A - Additional information

### Babystep1

- To debug and check that everything is working as expected you can start qemu as follow:
  - `qemu-system-i386 -s -S -fda boot.bin`
- And in another terminal attach gdb:
```sh
gdb -ex 'target remote localhost:1234' -ex 'set disassembly-flavor intel
(gdb) b *0x7c00
(gdb) c
Breakpoint 1, 0x00007c00 in ?? ()
(gdb) x/2i $pc
=> 0x7c00:	cli
   0x7c01:	jmp    0x7c01
```
- As you see it is our code that it is running...
## Blog posts

During babysteps we will sometimes wrote some blogs for a better understanding.
We will list them here:

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

### long mode

Next will discover the 64 bits world.... but this is [ZigOS](https://github.com/gthvn1/zigos).

## Some interesting links

- [OSDev long mode](https://wiki.osdev.org/Setting_Up_Long_Mode)
- [Redox bootloader](https://gitlab.redox-os.org/redox-os/bootloader)
- [BIOS interrupt call](https://en.wikipedia.org/wiki/BIOS_interrupt_call)
- [OSDev bootloder wiki](https://wiki.osdev.org/Bootloader)
- [Multiboot headers](https://intermezzos.github.io/book/first-edition/multiboot-headers.html)

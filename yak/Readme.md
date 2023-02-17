# Yet Another Kernel

  The goal is to try to understand the differents steps from switching your computer
on until executing kernel. For this we will follow [OSDev tutorials](https://wiki.osdev.org/Tutorials).

## YaK (Yet another Kernel)

After doing Babysteps we will try to go further... So now we are able to create an ISO that
can be booted using grub and we are able to write the hello world but this time in
protected mode...

### Directories

- *asm*: contains ASM files used to start the kernel
- *bochs_config*: default configuration if you want to test it using [bochs](https://bochs.sourceforge.io/)
- *grub*: grub configuration used when generating the iso with **grub2-mkrescue**
- *kernel*: kernel source files
- *old*: Before trying Zig we try C. We keep the file in this repo.

You will also find a linker script *linker.ld*, the *Makefile* and this *Readme.md*.

### Build and test

- to build just run `make`. It will create an bootable iso in **build/**.
- to test it: `qemu-system-x86_64  -drive format=raw,file=build/yak.iso`
  - Note the currently i386 is working as well...
- to debug:
```sh
gdb -ex 'target remote localhost:1234' -ex 'set disassembly-flavor intel'
(gdb) b *0x100020
(gdb) c
```

### Next steps

- [X] setup the stack
- [ ] setup the GDT
- [ ] setup the IDT
- [ ] jump into the kernel (don't know yet if it will be in C, in Rust, in Zig...)

**NOTE**: we already added a file *kernel.c* (renamed *kernel.c.not_used* and we try to call the C function from
the *boot.asm*. We also tried to do it in Zig... So it is working in Zig and also in C. Before going further we
need to setup GDT, IDT and then jump into **kmain()** that is the kernel entry point. 

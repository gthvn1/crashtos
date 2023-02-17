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
- *kernel_C*: kernel source files in *C*.
- *kernel_zig*: kernel source files in *Zig*.

You will also find a linker script *linker.ld*, the *Makefile* and this *Readme.md*.

### Build and test

### default
- to build just run `make`. It will create an bootable iso in **build/**.
- to test it: `qemu-system-x86_64  -drive format=raw,file=build/yak.iso`
  - Note the currently i386 is working as well...
- to debug:
```sh
gdb -ex 'target remote localhost:1234' -ex 'set disassembly-flavor intel'
(gdb) b *0x100020
(gdb) c
```

### C or Zig or ...

We don't know yet which langage we will use. We tried *C* and *Zig* for now. By default
`make` will compile the *C* kernel. If you want to compile the *Zig* one you can run
`make zig=1`.

### Next steps

- [X] setup the stack
- [ ] setup the GDT
- [ ] setup the IDT
- [ ] jump into the kernel (don't know yet if it will be in C, in Rust, in Zig...)

## Links

- [Issue with GDT in asm](https://stackoverflow.com/questions/58192042/solution-needed-for-building-a-static-idt-and-gdt-at-assemble-compile-link-time)

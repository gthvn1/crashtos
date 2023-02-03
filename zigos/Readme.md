# ZigOS

## Bare Bones tutorial

Try the tutorial [Bare Bones](https://wiki.osdev.org/Bare_Bones) from OS dev.
We try to use [zig](https://ziglang.org/) because there are some facilites to
build low level stuff and use some cool keyword like `linksection`...

The goal is to
 - [X] boot
 - [ ] print message

## Build

- `zig build`

## Run & debug

- `qemu-system-i386 -cdrom zig-out/bin/zigos.iso`
- if you want to attach a debugger add `-s -S`
- check with `nm -s` the address of **kmain**
    - In my case it is 0x001000c0
```
gdb -ex 'target remote localhost:1234' \
    -ex 'set disassembly-flavor intel' \
    -ex 'break *0x001000c0' \
    -ex 'continue'

```

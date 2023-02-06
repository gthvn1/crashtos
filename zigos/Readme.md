# ZigOS

## Overview

The only purpose of this "operating system" is the exploration of this universe.
There is many really good tutorials and blogs that explain how to setup your own
operating system. So this one and the related blog posts are more some milestones
for me but maybe it can be usefull for someone else so I will try to keep things
simple and working.

## Links

### Bare Bones tutorial

Try the tutorial [Bare Bones](https://wiki.osdev.org/Bare_Bones) from OS dev.
We try to use [zig](https://ziglang.org/) because there are some facilites to
build low level stuff and use some cool keyword like `linksection`...

The goal is to
 - [X] boot
 - [X] print message
 - [ ] switch to long mode

### Related blogs

TODO

### Existing Zig Operating System

- [Pluto](https://github.com/ZystemOS/pluto)
- [Zen](https://github.com/AndreaOrru/zen)
- [Zig Bare Bones](https://wiki.osdev.org/Zig_Bare_Bones)

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

## It is cool but...

- At this point we can boot and print messages on the screen but
  - we are still in 32 bits mode
  - we don't know how grub sets GDT
  - we don't know what is the stack used

- So I think that we need to figure out how to set up this things.

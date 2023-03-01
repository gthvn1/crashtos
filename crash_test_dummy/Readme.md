# Crash Test Dummy Mini OS

We will follow [Amateur Makes an OS](https://www.youtube.com/playlist?list=PLT7NbkyNWaqajsw8Xh7SP9KJwjfpP8TNX). It is really interesting so let's do it.

## Build

It is easy, just run `make`. It requires [bochs](https://bochs.sourceforge.io/)
emulator. To just build the mini os without running it on bochs just run
`make bin/mini-os`

Currently we only have assembly files that are in **src/asm**.

Build will create a **bin/** directory with the mini-os that is the concatenation
of the bootloader in the boot sector (the first 512 bytes of the disk) and the kernel
on the second sector.

## Some notes

Currently it is not working on real hardware. Maybe we just need to add A20. It can
be cool to try to have it working on real HW...

### Floppy geometry

- We are using 1 cylinder, 1 head and 4 sectors
  - cylinders'size is 512 bytes
  - sector numbers start from 1 (cylinder and head start from 0)
  - sector 1   -> bootloader (512 bytes ended with magic)
  - sector 2   -> File table (512 bytes padded with 0s)
  - sector 3-4 -> kernel (1024 bytes padded with 0s)
  - sector 5   -> future program... (not yet done)

### Next steps

- [x] In the step3 it is really cool to load the *"kernel"* using a *"bootloader"*.
  So create an raw image that has the *"bootloader*" in its first sector and the kernel
  after. A sector is 512 bytes that is the size of the bootloader...
- [x] To prepare this step we just create an empty kernel that will fill the second sector
  so the size of the disk will be related to its geometry.
- [x] Move the kernel into sector 3 and add something else on the second sector. Use kind
  of filesystem to know where things are stored. The "filesystem" will just be a string with
  the filename of things stored on sectors. For the moment we store segment by segment.
- [x] Read input from user
- [x] Instead of reading the key pressed we can store keys pressed in memory and when
  user press "Enter" then we check if the command starts from "F" and do appropriate
  thing, if it starts by "Q" we quit, and otherwise we get another input from the user.
  The cool thing with that is that later we will be able to have a shell :)
  - *NOTE*: we just store the key press in memory (in fact we save the caracter in then
    expected index of the input string to have a nice print message).
- [x] Add warm reboot (it is a far jump to 0xFFFF:0x0000)
- [x] Load file table from sector 2
- [x] Add an entry for printing registers
- [x] After running a command add a "return to menu" message, wait for key input
  , cleanup the screen and go back to menu.
- [x] Display registers
- [x] Display file table
- [x] Implement a prompt instead of menu
  - `> ls`: Print file table
  - `> regs`: Print registers
  - `> halt`: Halt the computer
  - `> reboot`: Reboot
- [ ] Add a command to play with graphics
- [ ] Once file table displayed allow to enter a filename and load it if possible.
- [x] Load file table at 0x1000:0x0000
- [x] Load kernel at 0x1000:0x0200

## Bugs

- [ ] Check that cmdStr doesn't overflow (max 30 bytes)

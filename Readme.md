# CrashTOS: A Crash Test Operating System

We will follow [Amateur Makes an OS](https://www.youtube.com/playlist?list=PLT7NbkyNWaqajsw8Xh7SP9KJwjfpP8TNX).
It is really awesome so let us be inspired.

## Code, Build & Test

### Code
Currently main assembly files are in **src/** and others assembly files that are
not build but just included are in **include/**.

Build will create a **bin/** directory with the mini-os that is the concatenation
of the bootloader in the boot sector (the first 512 bytes of the disk) and
kernel and other programs on others sectors. See the description of the Floppy
for more details.

### Build
To build the mini os just run `make`.

### Test
To test it with [bochs](https://bochs.sourceforge.io/) emulator just run
`make bochs`. Check [bochsrc.txt](https://github.com/gthvn1/yet-another-kernel/blob/master/crash_test_dummy/bochsrc.txt) if you need a custom setup.

You can also test it on [qemu](https://www.qemu.org/) if you run `make qemu`.

## Some notes

Currently it is not working on real hardware. Maybe we just need to add A20.
It can be cool to try to have it working on real HW...

### Memory Layout

- Check [src/bootloader.asm](https://github.com/gthvn1/yet-another-kernel/blob/master/crash_test_dummy/src/bootloader.asm)
for an up to date layout. Should be sync but who knows...
```sh
;; MEMORY LAYOUT
;; https://wiki.osdev.org/Memory_Map_(x86)
;;
;; 0x0000_0000 - 0x0000_03FF | 1KB   | Real Mode IVT
;; 0x0000_0400 - 0x0000_04FF | 256B  | Bios Data Area (BDA)
;; 0x0000_0500 - 0x0000_7BFF | ~30KB | Conventional memory
;; 0x0000_7C00 - 0x0000_7DFF | 512B  | It is us, the bootloader
;; 0x0000_7E00 - 0x0007_FFFF | 480KB | Conventional Memory
;;
;; 0x0008_0000 - 0x0009_FFFF | 128KB | EBDA
;; 0x000A_0000 - 0x000B_FFFF | 128KB | Video display memory
;; 0x000C_0000 - 0x000C_7FFF | 32KB  | Video BIOS
;; 0x000C_8000 - 0x000E_FFFF | 160KB | BIOS Expansions
;; 0x000F_0000 - 0x000F_FFFF | 64KB  | Motherboard BIOS
;;
;; We will use the 64KB from 0x0001_0000 - 0x0001_FFFF:
;;   - File Table : 0x0001_0000 - 0x0001_01FF (512B)
;;   - Kernel     : 0x0001_0200 - 0x0001_09FF (2KB)
;;   - Stack      : 0x0001_A000 - 0x0001_FFFF (24Kb)
;; NOTE: The stack is growing in direction of the kernel... so be carfull :-)
;; We keep the file table and the kernel on the same segments. Otherwise when
;; we will access file table data from kernel we need to make far jump.
```
### Floppy geometry

- cylinders'size is 512 bytes
- sector numbers start from 1 (cylinder and head start from 0)
  - sector 1   -> bootloader (512 bytes ended with magic)
  - sector 2   -> File table (512 bytes padded with 0s)
  - sector 3-6 -> kernel (2048 bytes padded with 0s)
  - sector 7   -> future program... (not yet done)

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
- [x] Load file table at 0x1000:0x0000
- [x] Load kernel at 0x1000:0x0200
- [x] Manage backspace
- [x] Check that user input doesn't overflow the buffer
- [ ] Add a command to play with graphics
- [ ] If we don't find any command look into file table if we find a "txt" file
      or a "bin" file. If we found a "bin" file execute it, if it is a "txt" file
      display its contents. If it is another extension do nothing.
      Example: *editor* should start the editor
- [ ] Use graphics instead of BIOS interrupt

# CrashTOS: A Crash Test Operating System

We will follow [Amateur Makes an OS](https://www.youtube.com/playlist?list=PLT7NbkyNWaqajsw8Xh7SP9KJwjfpP8TNX). It is really interesting so let's do it.

## Code, Build & Test

### Code
Currently main assembly files are in **src/** and others assembly files that are
not build but just included are in **include/**.

Build will create a **bin/** directory with the mini-os that is the concatenation
of the bootloader in the boot sector (the first 512 bytes of the disk) and
stage2 and other programs on others sectors. See the description of the Floppy
for more details.

### Build
To build the mini os just run `make`.

### Test
To test it with [bochs](https://bochs.sourceforge.io/) emulator just run
`make bochs`. Check [bochsrc.txt](https://github.com/gthvn1/crashtos/blob/master/bochsrc.txt)
if you need a custom setup.

You can also test it on [qemu](https://www.qemu.org/) if you run `make qemu`.

## Some notes

Currently it is not working on real hardware probably because we are reading
from floppy. We tried to read from drive but it is not working either. There
is probably something more to do if we want to generate an USB image and load
programs like stage2 from USB. But it will be cool to see it working on real
HW...


### Steps

- [x] In the step3 it is really cool to load the *"stage2"* using a *"bootloader"*.
  So create an raw image that has the *"bootloader*" in its first sector and the stage2
  after. A sector is 512 bytes that is the size of the bootloader...
- [x] To prepare this step we just create an empty stage2 that will fill the second sector
  so the size of the disk will be related to its geometry.
- [x] Move the stage2 into sector 3 and add something else on the second sector. Use kind
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
- [x] Load stage2 at 0x1000:0x0200
- [x] Manage backspace
- [x] Check that user input doesn't overflow the buffer
- [x] If we don't find any command look into file table if we find a "txt" file
      or a "bin" file. If we found a "bin" file execute it, if it is a "txt" file
      display its contents. If it is another extension do nothing.
      Example: *editor* should start the editor
  - NOTE: Still need to display content of txt file.
  - Maybe we should load both text file and binary file in memory. Just have
    different return value in AX to let the stage2 if we can execute it, display
    it or of an error occured.
- [x] Use graphics instead of BIOS Video services (interrupt 10h). We can keep
      it for bootloader. But for other part remove it because when we will switch
      to protected mode we won't be able to use it.
  - [x] clear screen
  - [x] print char
- [x] Setup GDT
  - NOTE: BIOS interrupt are not available after switching to protected mode.
  there is some workaround but a good solution will probably to remove the usage
  of BIOS interrupt.

#### Breaking news... Protected mode is here...

To prepare the transition to protected mode we started to remove the usage of
BIOS services in the kernel. It is not so easy to do it properly. So we start
the modification in the bootloader to load the kernel. The goal is to put in
kernel.asm the same thing that we have in stage2.asm (that is not used any more)
but without any BIOS interrupt.

- [x] In the first step have clean screen, the print of a line and we are
trying to get input from user. But this part is not working well.
- [x] Before going further we did the jump, so we did the setup of the GDT...
- [x] Now we need to fix the get user input... It is fixed.
- [ ] Add the print of file table
- [ ] Use PIO to access disk instead of BIOS Disk services (interrupt 13h)
- [ ] load editor
- [ ] play a little bit with editor
- [ ] set ITV to get interrupt from keyboard
- [ ] jump to C, Rust, Zig ???

### Kernel is protected

We fixed the issue to get user input. So now the bootloader is running in real
mode. It sets:
  - the video mode
  - load the file table
  - load the kernel
  - setup GDT
  - jump in kernel in protected mode

Once inside the kernel all is in protected mode. Currently we are using PIO to
get input from keyboard and the screen is managed using the video memory. We
still need to manage disk and once done we will propably use a higer level language
than C.

### Memory Layout

- Check [src/bootloader.asm](https://github.com/gthvn1/crashtos/blob/master/src/bootloader.asm)
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
;;   - Stage2     : 0x0001_0200 - 0x0001_09FF (2KB)
;;   - Stack      : 0x0001_A000 - 0x0001_FFFF (24Kb)
;; NOTE: The stack is growing in direction of the stage2... so be carfull :-)
;; We keep the file table and the stage2 on the same segments. Otherwise when
;; we will access file table data from stage2 we need to make far jump.
```
### Disk geometry

- cylinders'size is 512 bytes
- sector numbers start from 1 (cylinder and head start from 0)
  - sector 1   -> bootloader (512 bytes ended with magic)
  - sector 2   -> File table (512 bytes padded with 0s)
  - sector 3-6 -> stage2 (2048 bytes padded with 0s)
  - sector 7   -> user input program

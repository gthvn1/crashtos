# Yet Another Kernel

The goal is to try to understand the differents steps from switching your computer on until the prompt of a simple kernel...

The code will be in this repo and we will write [some posts](https://gthvn1.github.io/blog/) to help to understand things.

## The bootloader

When your computer starts the first step is to load the BIOS from the ROM. It will do the initialization of
hardware and it will try to find a place like a disk where a piece of code called the bootloader is
stored. It only looks the first 512 bytes of the device. If the BIOS finds a bootloader that is recognized
with its magic number stored on the last two bytes of the 512 bytes it loads it at a know address (0x7C00)
and the bootloader is executed. This piece of software is called the fist stage bootloader.

%define VIDEO_MEMORY 0xB800 ; this is used in ES so it is 0xB8000

%define VECTOR_RESET  0xFFFF:0x0000

%define BOOTLO_SEG    0x0000
%define BOOTLO_OFFSET 0x7C00

%define FTABLE_SEG    0x1000 ; this is where bootloarder loads file table
%define FTABLE_OFFSET 0x0000

%define KERNEL_SEG    0x1000 ; this is where the bootloader loaded the kernel
%define KERNEL_OFFSET 0x0200

%define EDITOR_SEG    0x2000
%define EDITOR_OFFSET 0x0000

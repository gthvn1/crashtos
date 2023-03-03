%define VIDEO_MEMORY 0xB800 ; this is used in ES so it is 0xB8000

%define FTABLE_SEG   0x1000 ; this is where bootloarder loads file table
%define FTABLE_CODE  0x0000

%define KERNEL_SEG   0x1000 ; this is where the bootloader loaded the kernel
%define KERNEL_CODE  0x0200

%define EDITOR_SEG   0x2000
%define EDITOR_CODE  0x0000

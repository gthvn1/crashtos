%define VIDEO_MEMORY        0xB800 ; this is used in ES so it is 0xB8000

%define VECTOR_RESET        0xFFFF:0x0000

%define BOOTLO_SEG          0x0000
%define BOOTLO_OFFSET       0x7C00

%define FTABLE_SEG          0x1000 ; this is where bootloarder loads file table
%define FTABLE_OFFSET       0x0000

%define STAGE2_SEG          0x1000 ; this is where the bootloader loads stage2
%define STAGE2_OFFSET       0x0200

%define PROGRAM_SEG          0x2000
%define PROGRAM_OFFSET       0x0000

%define FTABLE_ENTRY_SIZE   0x10   ; An entry is 16 bytes

We will follow [Amateur Makes an OS](https://www.youtube.com/playlist?list=PLT7NbkyNWaqajsw8Xh7SP9KJwjfpP8TNX). It is really interesting so let's do it.

# Some notes

- Disk has 1 cylinder, 1 head and 2 sectors
  - cylinders'size is 512 bytes
  - sector numbers start from 1 (cylinder and head start from 0)
  - sector 1 -> bootloader (512 bytes ended with magic)
  - sector 2 -> kernel (512 bytes)

# Next steps

- [x] In the step3 it is really cool to load the *"kernel"* using a *"bootloader"*.
So create an raw image that has the *"bootloader*" in its first sector and the kernel
after. A sector is 512 bytes that is the size of the bootloader...
- [x] To prepare this step we just create an empty kernel that will fill the second sector
so the size of the disk will be related to its geometry.
- [ ] Currently it is not working on real hardware. Maybe we just need to add A20. It can
be cool to try to have it working on real HW...
- [ ] ...

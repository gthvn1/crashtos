We will follow [Amateur Makes an OS](https://www.youtube.com/playlist?list=PLT7NbkyNWaqajsw8Xh7SP9KJwjfpP8TNX). It is really interesting so let's do it.

# Some notes

- Disk has 10 cylinder, 6 heads and 17 sectors
  - size is `10 * 6 * 17 * 512 bytes` (510KB)
- It is created by the Makefile if it doesn't exist.

# Next steps

In the step3 it is really cool to load the *"kernel"* using a *"bootloader"*.
So create an raw image that has the *"bootloader*" in its first sector and the kernel
after. A sector is 512 bytes that is the size of the bootloader...

To prepare this step we just create an empty kernel that will fill the second sector
so the size of the disk will be related to its geometry.

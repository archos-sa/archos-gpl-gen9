You can build a mini SDE demo image using the gen9 GPL release
Note, this is just a proof of concent and not a full Linux OS.

1) Follow the steps of the standard Readme.txt

2) In the buildroot folder, type "make sde". This will compile
a kernel and a small initramfs that just outputs a banner on the 
framebuffer and then reboots after 10 seconds.

3) Copy both files, zImage and initramfs.cpio.gz from the 
"buildroot/sde" folder to the unit when using the 
"Flash Kernel and Initramfs" option from the developer menu on the
unit.


Notes on tweaking the SDE demo image:

1) the root filesystem is build in "buildroot/sde/root" using
the buildroot and busybox configuration in "buildroot/local/init"

2) the actual init script executed and the device table
are in "buildroot/sde/init" and "buildroot/sde/device_table.txt"

3) see "buildroot/sde/sde.mk" on how the cpio initramfs image is
assembled



(18-june-2016)

Buildscripts used for ongoing development of Socfpga Debian bootable image(s).
And cross compiling Fully working Machinekit rip install, for rapid development.

Rel_3 beta update.

Current buildscript is:

main-top-script.sh

Featuring:

	u-boot 2016:07
	Cross compiled debian packed 4.1.22-ltsi-rt23 kernel  (providing devicetree dtb , dts , zImage)
	added max-mtu 9000 (jumbo frames)
	added kernel .deb package gen, including full range of socfpga .dtb(s) in /boot/dtb folder
	added ramdisk boot with uInitrd auto update
	added /boot/kver.txt containing current kernelversion (for u-boot probing)
	Current rootfs = qemu-debootstrap generated rootfs (Debian jessie 8.4)

#(Compilable MK-Dev image)


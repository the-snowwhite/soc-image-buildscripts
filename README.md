(12-may-2019)

Buildscripts used for ongoing development of Socfpga Debian bootable image(s).

Updated for Rel_2-1 release.

Current buildscript is:

SD-Image-Gen/build-all.sh

Featuring:

u-boot 2018:01

Cross compiled debian packed 4.9.76-rt61-ltsi kernel  (providing devicetree dtb , dts , zImage, extlinux)

added kernel .deb package gen, including full range of socfpga .dtb(s) in /boot/dtb folder

ramdisk boot with uInitrd auto update (not tested)

including /boot/extlinux (to autoselect kerned on apt update)

Current rootfs = qemu-debootstrap generated rootfs (Debian stretch 9.x)

---

- (Detailed setup steps for machinekit use)[http://preview.machinekit.io/docs/getting-started/machinekit-de10-images/]

---

Howto build process:

For the full functionality setup a local debian repository (reprepro) and point the variable:
HOME_DEB_MIRR_REPO_URL to its url (https://github.com/the-snowwhite/soc-image-buildscripts/blob/master/SD-Image-Gen/build-all.sh#L37)


clone the repo somewhere (in this example: /home/mib/Developer/the-snowwhite_git):
    
    git clone https://github.com/the-snowwhite/soc-image-buildscripts.git

Create a new folder and cd into it:

    mkdir Machinekit_image_build
    cd Machinekit_image_build

see build script options:

    /home/mib/Developer/the-snowwhite_git/soc-image-buildscripts/SD-Image-Gen/build-all.sh 
    
 Bufore running the first builds install build dependencies:
 
    /home/mib/Developer/the-snowwhite_git/soc-image-buildscripts/SD-Image-Gen/build-all.sh --deps

    
latest 2 sd-images are built with following commands:

uboot:

    /home/mib/Developer/the-snowwhite_git/soc-image-buildscripts/SD-Image-Gen/build-all.sh --uboot=de0_nano_soc
    
kernel:

    /home/mib/Developer/the-snowwhite_git/soc-image-buildscripts/SD-Image-Gen/build-all.sh --build_git-kernel=stretch=de10_nano

for the next command to work you need to have setup a local debian repo (reprepro):
    
    /home/mib/Developer/the-snowwhite_git/soc-image-buildscripts/SD-Image-Gen/build-all.sh --gitkernel2repo=stretch=armhf

rootfs:

    /home/mib/Developer/the-snowwhite_git/soc-image-buildscripts/SD-Image-Gen/build-all.sh --gen-base-qemu-rootfs=stretch=armhf
    
    /home/mib/Developer/the-snowwhite_git/soc-image-buildscripts/SD-Image-Gen/build-all.sh --gen-base-qemu-rootfs-desktop=stretch=armhf
    
final rootfs setup:

    /home/mib/Developer/the-snowwhite_git/soc-image-buildscripts/SD-Image-Gen/build-all.sh --finalize-rootfs=stretch=machinekit=armhf

    /home/mib/Developer/the-snowwhite_git/soc-image-buildscripts/SD-Image-Gen/build-all.sh --inst_repo_kernel=stretch=armhf=machinekit

install kernel from local debian repo (reprepro):
 
    /home/mib/Developer/the-snowwhite_git/soc-image-buildscripts/SD-Image-Gen/build-all.sh --inst_repo_kernel-desktop=stretch=armhf=machinekit

    /home/mib/Developer/the-snowwhite_git/soc-image-buildscripts/SD-Image-Gen/build-all.sh --inst_repo_kernel-desktop=stretch=armhf=machinekit

Generate final compressed sd-card images with .bmap file and md5sum

    /home/mib/Developer/the-snowwhite_git/soc-image-buildscripts/SD-Image-Gen/build-all.sh --assemble_sd_img=de10_nano=stretch=machinekit
    
    /home/mib/Developer/the-snowwhite_git/soc-image-buildscripts/SD-Image-Gen/build-all.sh --assemble_desktop_sd_img=de10_nano=stretch=machinekit


#!/bin/sh

uboot_deps() {
# install deps for u-boot build
	sudo ${apt_cmd} -y install lib32z1 device-tree-compiler bc u-boot-tools
}

kernel_deps() {
# install deps for kernel build
	sudo ${apt_cmd} -y install build-essential fakeroot bc u-boot-tools
	sudo apt-get -y build-dep linux
}

rootfs_deps() {
    sudo apt-get -y install qemu binfmt-support qemu-user-static schroot debootstrap libc6 debian-archive-keyring
#    sudo dpkg --add-architecture armhf
    sudo apt update
#    sudo apt -y --force-yes upgrade
    sudo update-binfmts --display | grep interpreter
}


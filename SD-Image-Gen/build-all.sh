#!/bin/sh

# Main-top-script Invokes selected scripts in sub folder that generates a working armhf Debian Jessie or Stretch/sid sd-card-image().img
# base kernel is the x.xx.xx-rt-ltsi kernel from the alterasoc repo (currently 4.1.22-rt23)
# ongoing work is done to get pluged into the 4.4.4-rt mainline kernel.
#
# !!! warning while using the script to generate u-boot, kernels and sd-image, is quite safe
# the (qemu)rootfs generation can be more tricky. and might potentially overwrite files in your host root file system.
# if something goes wrong underway you need to know how to use lsblk, sudo losetup -D and sudo umount -R
# the machinekit Rip cross build script is in an even higher risc zone, and it is highly recomended to install the .deb packages,
# unless you really need a local rip build for development purposes on you soc.
# as installing machinekit packages works just fine for runtime purposes ....
#
# Initially developed for the Terasic De0 Nano / Altera Atlas Soc-Fpga dev board

# v.03 New rev.

# 1.initial source: make minimal rootfs on amd64 Debian Jessie, according to "How to create bare minimum Debian Wheezy rootfs from scratch"
# http://olimex.wordpress.com/2014/07/21/how-to-create-bare-minimum-debian-wheezy-rootfs-from-scratch/
#
#------------------------------------------------------------------------------------------------------
# Variables Custom settings
#------------------------------------------------------------------------------------------------------

## Select distro:
#distro=sid
#distro=jessie
distro=stretch

## 3 part Expandable image with swap in p2
IMG_ROOT_PART=p3

## Select board
BOARD=de10-nano
#BOARD=de0-nano-soc
#BOARD=de1-soc
#BOARD=sockit

## Select u-boot version:
UBOOT_VERSION="v2016.09"
UBOOT_MAKE_CONFIG='u-boot-with-spl.sfp'

## Select user name / function
#USER_NAME=machinekit;
USER_NAME=holosynth;

KERNEL_VERSION="4.9.30"
RT_PATCH_REV="rt20"


#------------------------------------------------------------------------------------------------------
# Variables Prerequsites
#apt_cmd=apt
apt_cmd="apt-get"
#------------------------------------------------------------------------------------------------------
WORK_DIR=${1}

REPO_DIR="/var/www/repos/apt/debian"

#MAIN_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MAIN_SCRIPT_DIR="$(cd $(dirname $0) && pwd)"
SUB_SCRIPT_DIR=${MAIN_SCRIPT_DIR}/subscripts
FUNC_SCRIPT_DIR=${MAIN_SCRIPT_DIR}/functions
PATCH_SCRIPT_DIR=${MAIN_SCRIPT_DIR}/patches
DTS_DIR=${MAIN_SCRIPT_DIR}/../dts

CURRENT_DIR=$(pwd)
ROOTFS_MNT=/tmp/myimage

ROOTFS_IMG=${CURRENT_DIR}/rootfs.img

CURRENT_DATE=`date -I`
REL_DATE=${CURRENT_DATE}
#REL_DATE=2016-03-07

## ----------------------------  Toolchain   -----------------------------##

PCH52_CC_FOLDER_NAME="gcc-linaro-5.2-2015.11-1-x86_64_arm-linux-gnueabihf"
PCH52_CC_FILE="${PCH52_CC_FOLDER_NAME}.tar.xz"
PCH52_CC_URL="http://releases.linaro.org/components/toolchain/binaries/5.2-2015.11-1/arm-linux-gnueabihf/${PCH52_CC_FILE}"

TOOLCHAIN_DIR=${HOME}/bin

## ------------------------------  Kernel  -------------------------------##
KERNEL_LOCALVERSION="socfpga-${KERNEL_VERSION}-${RT_PATCH_REV}"
KERNEL_REV="0.1"

KERNEL_URL="https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-${KERNEL_VERSION}.tar.xz"
RT_PATCH_URL="https://cdn.kernel.org/pub/linux/kernel/projects/rt/4.9/patch-${KERNEL_VERSION}-${RT_PATCH_REV}.patch.xz"

## ------------------------------  Uboot  --------------------------------##
UBOOT_GIT_URL="git://git.denx.de/u-boot.git"
UBOOT_DIR=uboot
UBOOT_CHKOUT_OPTIONS='-b tmp'

if [ "${BOARD}" = "de10-nano" ]; then
   UBOOT_CONFIG='de0_nano_soc'
   BOOT_FILES_DIR=${MAIN_SCRIPT_DIR}/../boot_files/${nanofolder}
elif [ "${BOARD}" = "de0-nano-soc" ]; then
   UBOOT_CONFIG='de0-nano-soc'
   BOOT_FILES_DIR=${MAIN_SCRIPT_DIR}/../boot_files/${de1folder}
elif [ "${BOARD}" = "de1-soc" ]; then
   UBOOT_CONFIG='de0_nano_soc'
   BOOT_FILES_DIR=${MAIN_SCRIPT_DIR}/../boot_files/${de1folder}
elif [ "${BOARD}" = "sockit" ]; then
   UBOOT_CONFIG='sockit'
   BOOT_FILES_DIR=${MAIN_SCRIPT_DIR}/../boot_files/${sockitfolder}
fi

# 2016.0X patches:
UBOOT_PATCH_FILE="u-boot-${UBOOT_VERSION}-${UBOOT_CONFIG}-changeset.patch"

UBOOT_BOARD_CONFIG="socfpga_${UBOOT_CONFIG}_defconfig"

#-----  select global toolchain  ------#

CC_FOLDER_NAME=$PCH52_CC_FOLDER_NAME
CC_URL=$PCH52_CC_URL

#------------------------------------------------------------------------------------------------------
# Variables Postrequsites
#------------------------------------------------------------------------------------------------------

#------------  Toolchain  -------------#
CC_DIR="${TOOLCHAIN_DIR}/${CC_FOLDER_NAME}"
CC_FILE="${CC_FOLDER_NAME}.tar.xz"
CC="${CC_DIR}/bin/arm-linux-gnueabihf-"

COMP_REL=debian-${distro}_socfpga
NCORES=`nproc`

#--------------  u-boot  --------------#


#-----------------------------------------------------------------------------------
# local functions
#-----------------------------------------------------------------------------------
usage()
{
    echo "if this was a real script you would see something useful here"
    echo ""
    echo "./simple_args_parsing.sh"
    echo "\t-h --help"
    echo "\t--deps    Will install build deps"
    echo "\t--uboot   Will clone and build uboot"
    echo ""
}

install_deps() {
## toolchain:
	if [ ! -d ${CC_DIR} ]; then
		echo ""
		echo "Script_MSG: Toolchain not preinstalled .!"
		echo "Script_MSG: ${CC_DIR}"
		echo ""
		. ${FUNC_SCRIPT_DIR}/file_build-func.sh
		get_and_extract ${CC_DIR} ${CC_URL} ${CC_FILE}
	else
		echo ""
		echo "Script_MSG: Toolchain allready installed in -->"
		echo "Script_MSG: ${CC_DIR}"
		echo ""
	fi
#	install_uboot_dep
#	install_kernel_dep
#	#sudo ${apt_cmd} install kpartx
#	install_rootfs_dep
#	sudo ${apt_cmd} install -y bmap-tools pbzip2 pigz
	echo "MSG: deps installed"
}

build_uboot() {
	. ${FUNC_SCRIPT_DIR}/file_build-func.sh
	git_fetch ${UBOOT_DIR} ${UBOOT_GIT_URL} ${UBOOT_VERSION} "${UBOOT_CHKOUT_OPTIONS}" ${UBOOT_PATCH_FILE}
	armhf_build ${UBOOT_DIR} "${UBOOT_BOARD_CONFIG}" "${UBOOT_MAKE_CONFIG}"
}
#------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------- #
#-----------+++     Full Flow Control                       +++-------------------- #
#---------------------------------------------------------------------------------- #


while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --deps)
            . ${FUNC_SCRIPT_DIR}/deps-func.sh
            echo "--deps  --> Not fully implemented yet"
            install_deps
            ;;
        --uboot)
            build_uboot
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

echo "Script was run from ${CURRENT_DIR}"
echo "Toolchain_dir =  ${TOOLCHAIN_DIR}"

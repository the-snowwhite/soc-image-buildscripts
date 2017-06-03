#!/bin/bash
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
#set -v -e
# 1.initial source: make minimal rootfs on amd64 Debian Jessie, according to "How to create bare minimum Debian Wheezy rootfs from scratch"
# http://olimex.wordpress.com/2014/07/21/how-to-create-bare-minimum-debian-wheezy-rootfs-from-scratch/
#
#------------------------------------------------------------------------------------------------------
# Variables Custom settings
#------------------------------------------------------------------------------------------------------

## Select distro:
### Debian based:
#distro=sid
#distro=jessie
distro="stretch"
### Ubuntu based:
#distro=zesty
#distro=xenial

HOME_MIRR_REPO_URL=http://kubuntu16-srv.holotronic.lan/debian
ROOT_REPO_URL=${HOME_MIRR_REPO_URL}
#ROOT_REPO_URL=http://ports.ubuntu.com
#ROOT_REPO_URL=http://ports.ubuntu.com/ubuntu-ports

## 3 part Expandable image with swap in p2
ROOTFS_TYPE=ext4
ROOTFS_LABEL="rootfs"
mkfs="mkfs.${ROOTFS_TYPE}"
media_swap_partition=p2
media_rootfs_partition=p3

#ext4_options="-O ^metadata_csum,^64bit"
#mkfs_options="${ext4_options}"
mkfs_options=""


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
KERNEL_CONF="socfpga_defconfig"

#------------------------------------------------------------------------------------------------------
# Variables Prerequsites
#apt_cmd=apt
apt_cmd="apt-get"
#------------------------------------------------------------------------------------------------------
WORK_DIR=${1}

HOME_REPO_DIR="/var/www/repos/apt/debian"

#MAIN_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MAIN_SCRIPT_DIR="$(cd $(dirname $0) && pwd)"
SUB_SCRIPT_DIR=${MAIN_SCRIPT_DIR}/subscripts
FUNC_SCRIPT_DIR=${MAIN_SCRIPT_DIR}/functions
PATCH_SCRIPT_DIR=${MAIN_SCRIPT_DIR}/patches
DTS_DIR=${MAIN_SCRIPT_DIR}/../dts

CURRENT_DIR=$(pwd)
ROOTFS_MNT="/tmp/myimage"

ROOTFS_IMG="${CURRENT_DIR}/${ROOTFS_LABEL}.img"

CURRENT_DATE=`date -I`
REL_DATE=${CURRENT_DATE}
#REL_DATE=2016-03-07

final_repo="http://ftp.dk.debian.org/debian/"
local_repo="http://kubuntu16-srv.holotronic.lan/debian/"
local_kernel_repo="http://kubuntu16-ws.holotronic.lan/debian/"

DEFGROUPS="sudo,kmem,adm,dialout,holosynth,video,plugdev"

## ----------------------------  Toolchain   -----------------------------##

PCH52_CC_FOLDER_NAME="gcc-linaro-5.2-2015.11-1-x86_64_arm-linux-gnueabihf"
PCH52_CC_FILE="${PCH52_CC_FOLDER_NAME}.tar.xz"
PCH52_CC_URL="http://releases.linaro.org/components/toolchain/binaries/5.2-2015.11-1/arm-linux-gnueabihf/${PCH52_CC_FILE}"

TOOLCHAIN_DIR=${HOME}/bin

## ------------------------------  Kernel  -------------------------------##
KERNEL_TAG="${KERNEL_VERSION}-${RT_PATCH_REV}"
KERNEL_LOCALVERSION="socfpga-${KERNEL_TAG}"
KERNEL_REV="0.1"

KERNEL_FOLDER="linux-${KERNEL_VERSION}"
KERNEL_FILE_NAME="${KERNEL_FOLDER}.tar.xz"
KERNEL_URL="https://cdn.kernel.org/pub/linux/kernel/v4.x/${KERNEL_FILE_NAME}"
RT_PATCH_FILE="patch-${KERNEL_TAG}.patch.xz"
RT_PATCH_URL="https://cdn.kernel.org/pub/linux/kernel/projects/rt/4.9/${RT_PATCH_FILE}"


KERNEL_PARENT_DIR="${CURRENT_DIR}/arm-linux-${KERNEL_VERSION}-gnueabifh-kernel"
KERNEL_BUILD_DIR="${KERNEL_PARENT_DIR}/${KERNEL_FOLDER}"

# ------------------------------  Uboot  --------------------------------##

UBOOT_GIT_URL="git://git.denx.de/u-boot.git"
UBOOT_DIR=uboot
#UBOOT_CHKOUT_OPTIONS='-b tmp'
UBOOT_CHKOUT_OPTIONS=""

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
UBOOT_PATCH_FILE="u-boot-${UBOOT_VERSION}-${BOARD}-changeset.patch"

UBOOT_BOARD_CONFIG="socfpga_${UBOOT_CONFIG}_defconfig"

HOLOSYNTH_QUAR_PROJ_FOLDER="/home/mib/Developer/the-snowwhite_git/HolosynthV/QuartusProjects/DE10Nano"

#-----  select global toolchain  ------#

CC_FOLDER_NAME=$PCH52_CC_FOLDER_NAME
CC_URL=$PCH52_CC_URL

#------------------------------------------------------------------------------------------------------
# Variables Postrequsites
#------------------------------------------------------------------------------------------------------
if [ "${USER_NAME}" == "machinekit" ]; then
	HOST_NAME="mksocfpga-nano-soc"
elif [ "${USER_NAME}" == "holosynth" ]; then
	HOST_NAME="holosynthv"
fi

SD_FILE_PRELUDE=mksocfpga_${distro}_${USER_NAME}_${KERNEL_VERSION}-${REL_DATE}
SD_IMG_NAME="${SD_FILE_PRELUDE}-${BOARD}_sd.img"
SD_IMG_FILE="${CURRENT_DIR}/${SD_IMG_NAME}"

#------------  Toolchain  -------------#
CC_DIR="${TOOLCHAIN_DIR}/${CC_FOLDER_NAME}"
CC_FILE="${CC_FOLDER_NAME}.tar.xz"
CC="${CC_DIR}/bin/arm-linux-gnueabihf-"

COMP_REL=debian-${distro}_socfpga
NCORES=`nproc`

#--------------  Kernel  --------------#

KERNEL_CONFIGSTRING="${KERNEL_CONF}"
FULL_KERNEL_CONFIGSTRING='NAME="Michael Brown" EMAIL="producer@holotronic.dk" KBUILD_DEBARCH=armhf LOCALVERSION=-'${KERNEL_LOCALVERSION}' KDEB_PKGVERSION='${KERNEL_VERSION}'-'${KERNEL_REV}''

POLICY_FILE=${ROOTFS_MNT}/usr/sbin/policy-rc.d


#-----------------------------------------------------------------------------------
# local functions
#-----------------------------------------------------------------------------------
usage()
{
    echo "if this was a real script you would see something useful here"
    echo ""
    echo "    simple_args_parsing.sh"
    echo "    -h --help"
    echo "    --deps    Will install build deps"
    echo "    --uboot   Will clone and build uboot"
    echo "    --build_git-kernel   Will clone and build kernel from git"
    echo "    --build_rt-ltsi-kernel   Will download rt-ltsi patch and build kernel"
    echo "    --kernel2repo   Will add kernel .debs to local repo"
    echo "    --gen-rootfs   Will create root image and generate qemu rootfs"
    echo "    --finalize-rootfs   Will create user and configure  rootfs for fully working out of the box experience"
    echo "    --bindmount_rootfsimg    Will mount rootfs image"
    echo "    --bindunmount_rootfsimg    Will unmount rootfs image"
    echo "    --inst_repo_kernel   Will install kernel from local repo"
    echo "    --assemble_full_sd_img   Will generate full populated sd imagefile and bmap"
    echo ""
}

install_deps() {
## toolchain:
	if [ ! -d ${CC_DIR} ]; then
		echo ""
		echo "Script_MSG: Toolchain not preinstalled .!"
		echo "Script_MSG: ${CC_DIR}"
		echo ""
		cd ${TOOLCHAIN_DIR}
		get_and_extract ${CC_DIR} ${CC_URL} ${CC_FILE}
		# install linaro gcc crosstoolchain dependency:
		sudo ${apt_cmd} -y install lib32stdc++6
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
	git_fetch ${UBOOT_DIR} ${UBOOT_GIT_URL} ${UBOOT_VERSION} "${UBOOT_CHKOUT_OPTIONS}" ${UBOOT_PATCH_FILE}
	armhf_build ${UBOOT_DIR} "${UBOOT_BOARD_CONFIG}" "${UBOOT_MAKE_CONFIG}"
}

build_git_kernel() {
	echo "--  --> Not implemented yet"
# 	. ${FUNC_SCRIPT_DIR}/file_build-func.sh
# 	git_fetch t ${KERNEL_PARENT_DIR} ${KERNEL_URL} ${KERNEL_FILE_NAME}
#	armhf_build ${UBOOT_DIR} "${UBOOT_BOARD_CONFIG}" "${UBOOT_MAKE_CONFIG}"
}

build_rt_ltsi_kernel() {
	if [ -d ${KERNEL_BUILD_DIR} ]; then
		echo the kernel target directory ${KERNEL_BUILD_DIR} already exists cleaning ...
		rm -R ${KERNEL_BUILD_DIR}
		cd ${KERNEL_PARENT_DIR}
		extract_xz ${KERNEL_FILE_NAME}
    else
		mkdir -p ${KERNEL_PARENT_DIR}
		cd ${KERNEL_PARENT_DIR}
		get_and_extract ${KERNEL_PARENT_DIR} ${KERNEL_URL} ${KERNEL_FILE_NAME}
	fi
	rt_patch_kernel
	armhf_build ${KERNEL_BUILD_DIR} "${KERNEL_CONFIGSTRING}" deb-pkg 2>&1 | tee ../deb_rt-log.txt
}

## parameters: 1: mount dev name, 2: image name, 3: distro name
gen_rootfs_image() {
	create_img 1 ${2} ""
	mount_imagefile ${2} ${1}
	. ${FUNC_SCRIPT_DIR}/rootfs-func.sh
	if [ "${USER_NAME}" = "holosynth" ]; then
		run_qt_qemu_debootstrap ${1} ${3} ${ROOT_REPO_URL}
	fi
	echo ""
	echo "Scr_MSG: run_qt_qemu_debootstrap function return value was --> ${output}"
	echo ""
	if [ ${output} -gt 0 ]; then
		echo "Scr_MSG: run_qt_qemu_debootstrap failed"
		unmount_binded ${1}
		exit 1
	else
		compress_rootfs ${CURRENT_DIR} ${ROOTFS_MNT} "qemu_debootstrap-only"
		echo "Script_MSG: will now setup_configfiles"
# 		setup_configfiles
# 		compress_rootfs ${CURRENT_DIR} ${ROOTFS_MNT} "fully_configured_rootfs"
		unmount_binded ${1}
	fi
}

## parameters: 1: mount dev name, 2: image name, 3: distro name
finalize_rootfs_image() {
	create_img 1 ${2} ""
	mount_imagefile ${2} ${1}
	. ${FUNC_SCRIPT_DIR}/rootfs-func.sh
# 	if [ ${output} -gt 0 ]; then
# 		echo "Scr_MSG: run_qt_qemu_debootstrap failed"
# 		unmount_binded ${1}
# 		exit 1
# 	else
	extract_rootfs ${CURRENT_DIR} ${ROOTFS_MNT} "qemu_debootstrap-only"
	echo "Script_MSG: will now setup_configfiles"
	setup_configfiles
	initial_rootfs_user_setup_sh
	finalize
	compress_rootfs ${CURRENT_DIR} ${ROOTFS_MNT} "finalized_fully_configured_rootfs"
	unmount_binded ${1}
#	fi
}

inst_repo_kernel() {
	mount_imagefile ${ROOTFS_IMG} ${ROOTFS_MNT}
	inst_kernel_from_local_repo ${ROOTFS_MNT} ${KERNEL_TAG}
	compress_rootfs ${CURRENT_DIR} ${ROOTFS_MNT} "finalized_fully_configured_rootfs-with_kernel"
	unmount_binded ${ROOTFS_MNT}
}

#------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------- #
#-----------+++     Full Flow Control                       +++-------------------- #
#---------------------------------------------------------------------------------- #
. ${FUNC_SCRIPT_DIR}/file_build-func.sh

mkdir -p Logs

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
        --build_git-kernel)
            build_git_kernel
            ;;
        --build_rt-ltsi-kernel)
            build_rt_ltsi_kernel
            ;;
        --kernel2repo)
            . ${FUNC_SCRIPT_DIR}/file_build-func.sh
            add_kernel2repo ${distro}
            ;;
        --inst_repo_kernel)
        inst_repo_kernel
            ;;
        --gen-rootfs)
            gen_rootfs_image ${ROOTFS_MNT} ${ROOTFS_IMG} ${distro} | tee ${CURRENT_DIR}/Logs/gen-ubuntu_rootfs-log.txt
            ;;
        --finalize-rootfs)
            finalize_rootfs_image ${ROOTFS_MNT} ${ROOTFS_IMG} ${distro} | tee ${CURRENT_DIR}/Logs/gen-ubuntu_rootfs-log.txt
            ;;
        --bindmount_rootfsimg)
			. ${FUNC_SCRIPT_DIR}/file_build-func.sh
            mount_imagefile ${ROOTFS_IMG} ${ROOTFS_MNT}
            bind_mounted ${ROOTFS_MNT}
            ;;
        --bindunmount_rootfsimg)
			. ${FUNC_SCRIPT_DIR}/file_build-func.sh
            unmount_binded ${ROOTFS_MNT}
            ;;
        --assemble_full_sd_img)
			echo "step 1 create image:"
			create_img "3" "${SD_IMG_FILE}" "${ROOTFS_MNT}" "${media_rootfs_partition}"
			echo "step 2 mount:"
			mount_sd_imagefile ${SD_IMG_FILE} ${ROOTFS_MNT} ${media_rootfs_partition}
			extract_rootfs ${CURRENT_DIR} ${ROOTFS_MNT} "finalized_fully_configured_rootfs-with_kernel"
            unmount_binded ${ROOTFS_MNT}
            unmount_loopdev
			install_uboot ${CURRENT_DIR} ${UBOOT_DIR} ${UBOOT_MAKE_CONFIG} ${SD_IMG_FILE}
			make_bmap_image ${CURRENT_DIR} ${SD_IMG_NAME}
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

# echo "Script was run from ${CURRENT_DIR}"
# echo "Toolchain_dir =  ${TOOLCHAIN_DIR}"
# echo ""

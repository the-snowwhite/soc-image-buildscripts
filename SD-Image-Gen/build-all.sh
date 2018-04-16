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
# set -v -e
# 1.initial source: make minimal rootfs on amd64 Debian Jessie, according to "How to create bare minimum Debian Wheezy rootfs from scratch"
# http://olimex.wordpress.com/2014/07/21/how-to-create-bare-minimum-debian-wheezy-rootfs-from-scratch/
#
#------------------------------------------------------------------------------------------------------
# Variables Custom settings
#------------------------------------------------------------------------------------------------------

## Select distro:
### Debian based:
distro="stretch"
#distro="buster"
### Ubuntu based:
#distro=bionic
#distro=xenial
#HOME_MIRR_REPO_URL=http://kubuntu16-srv.holotronic.lan/debian
HOME_MIRR_REPO_URL=http://debian9-ws2.holotronic.lan/debian

shell_cmd="/bin/bash"
#shell_cmd="/bin/sh"

#ROOT_REPO_URL=http://ports.ubuntu.com/ubuntu-ports
ROOT_REPO_URL=${HOME_MIRR_REPO_URL}
#final_repo="http://ftp.dk.debian.org/debian/"
final_repo="http://deb.debian.org//debian/"
local_repo=${HOME_MIRR_REPO_URL}
local_ws=kdeneon-ws
local_kernel_repo="http://${local_ws}.holotronic.lan/debian/"


## 3 part Expandable image with swap in p2
ROOTFS_TYPE=ext4
ROOTFS_LABEL="rootfs"
mkfs="mkfs.${ROOTFS_TYPE}"
media_swap_partition=p2
media_rootfs_partition=p3

ext4_options="-O ^metadata_csum,^64bit"
#mkfs_options="${ext4_options}"
mkfs_options=""


## Select board
BOARDS=("de0_nano_soc" "de10_nano" "de1_soc" "sockit")
#BOARD=de10_nano
#BOARD=de0_nano_soc
#BOARD=de1_soc
#BOARD=sockit

## Select u-boot version:
#UBOOT_VERSION="v2016.09"
UBOOT_VERSION="v2018.01"
#UBOOT_MAKE_CONFIG="u-boot-with-spl.sfp"
UBOOT_MAKE_CONFIG="all"
UBOOT_IMG_FILENAME="u-boot-with-spl.sfp"

## Select user name / function
#USER_NAME=ubuntu;
#USER_NAME=machinekit;
USER_NAME=holosynth;

RT_KERNEL_VERSION="4.9.68"
RT_PATCH_REV="rt60"

GIT_KERNEL_VERSION="4.9.76"
GIT_KERNEL_REV="-ltsi-rt"
#GIT_KERNEL_VERSION="4.15"
#GIT_KERNEL_REV=""

SD_KERNEL_VERSION=${GIT_KERNEL_VERSION}
#SD_KERNEL_VERSION=${RT_KERNEL_VERSION}

#RT_PATCH_REV="ltsi-rt23-socfpga-initrd"
#RT_PATCH_REV="ltsi-rt23"
KERNEL_CONF="socfpga_defconfig"
ALT_GIT_KERNEL_VERSION="${GIT_KERNEL_VERSION}${GIT_KERNEL_REV}"

#QT_VER=5.7.1
QT_VER=5.10.1
QT_ROOTFS_MNT="/tmp/qt_${QT_VER}-img"

#QTDIR="/home/mib/qt-src/qt-everywhere-opensource-src-${QT_VER}"
QTDIR="/home/mib/qt-src/qt-everywhere-src-${QT_VER}"

QWTDIR="/home/mib/Developer/ext-repos/qwt/qwt"

#------------------------------------------------------------------------------------------------------
# Variables Prerequsites
#apt_cmd=apt
apt_cmd="apt-get"
#------------------------------------------------------------------------------------------------------
WORK_DIR=${1}

#HOME_REPO_DIR="/var/www/repos/apt/debian"
HOME_REPO_DIR="/var/www/debian"

MAIN_SCRIPT_DIR="$(cd $(dirname $0) && pwd)"
SUB_SCRIPT_DIR=${MAIN_SCRIPT_DIR}/subscripts
FUNC_SCRIPT_DIR=${MAIN_SCRIPT_DIR}/functions
PATCH_SCRIPT_DIR=${MAIN_SCRIPT_DIR}/patches
DTS_DIR=${MAIN_SCRIPT_DIR}/../dts

CURRENT_DIR=`pwd`
ROOTFS_MNT="/tmp/myimage"

ROOTFS_IMG="${ROOTFS_LABEL}.img"
QT_ROOTFS_IMG="qt_${ROOTFS_LABEL}.img"

CURRENT_DATE=`date -I`
REL_DATE=${CURRENT_DATE}
#REL_DATE=2016-03-07

DEFGROUPS="sudo,kmem,adm,dialout,holosynth,video,plugdev,netdev"

## ----------------------------  Toolchain   -----------------------------##
CROSS_GNU_ARCH="arm-linux-gnueabihf"

#GCC v6
#http://releases.linaro.org/components/toolchain/binaries/6.3-2017.05/arm-linux-gnueabihf/gcc-linaro-6.3.1-2017.05-x86_64_arm-linux-gnueabihf.tar.xz
GCC_REL="6.3"
GCC_VER="1"
GCC_REV="2017.05"
PCH63_CC_FOLDER_NAME="gcc-linaro-${GCC_REL}.${GCC_VER}-${GCC_REV}-x86_64_${CROSS_GNU_ARCH}"
PCH63_CC_FILE="${PCH63_CC_FOLDER_NAME}.tar.xz"
PCH63_CC_URL="http://releases.linaro.org/components/toolchain/binaries/${GCC_REL}-${GCC_REV}/${CROSS_GNU_ARCH}/${PCH63_CC_FILE}"


#GCC v5
PCH52_CC_FOLDER_NAME="gcc-linaro-5.2-2015.11-1-x86_64_${CROSS_GNU_ARCH}"
PCH52_CC_FILE="${PCH52_CC_FOLDER_NAME}.tar.xz"
PCH52_CC_URL="http://releases.linaro.org/components/toolchain/binaries/5.2-2015.11-1/${CROSS_GNU_ARCH}/${PCH52_CC_FILE}"

TOOLCHAIN_DIR=${HOME}/bin

QT_CFLAGS="-march=armv7-a -mtune=cortex-a8 -mfpu=neon -mfloat-abi=hard"

#QT_CC_FOLDER_NAME="gcc-linaro-${CROSS_GNU_ARCH}-4.9-2014.09_linux"
QT_CC_FOLDER_NAME=PCH63_CC_FOLDER_NAME
#QT_CC_FOLDER_NAME=PCH52_CC_FOLDER_NAME

QT_CC_DIR="${TOOLCHAIN_DIR}/${QT_CC_FOLDER_NAME}"
#QT_CC_FILE="${QT_CC_FOLDER_NAME}.tar.xz"
#QT_CC="${QT_CC_DIR}/bin/${CROSS_GNU_ARCH}-"
QT_CC="/usr/bin/${CROSS_GNU_ARCH}-"

## ------------------------------  Kernel  -------------------------------##
if [ "${USER_NAME}" == "machinekit" ]; then
    KERNEL_PKG_VERSION="0.1"
elif [ "${USER_NAME}" == "holosynth" ]; then
    KERNEL_PKG_VERSION="1.1"
fi

RT_KERNEL_TAG="${RT_KERNEL_VERSION}-${RT_PATCH_REV}"
RT_KERNEL_LOCALVERSION="socfpga-${RT_KERNEL_TAG}"
GIT_KERNEL_TAG="${ALT_GIT_KERNEL_VERSION}"
GIT_KERNEL_LOCALVERSION="socfpga-${GIT_KERNEL_TAG}"
#SD_KERNEL_TAG="socfpga${GIT_KERNEL_REV}"
SD_KERNEL_TAG="socfpga-rt-ltsi"

RT_KERNEL_FOLDER="linux-${RT_KERNEL_VERSION}"
RT_KERNEL_FILE_NAME="${RT_KERNEL_FOLDER}.tar.xz"
KERNEL_URL="https://cdn.kernel.org/pub/linux/kernel/v4.x/${RT_KERNEL_FILE_NAME}"
RT_PATCH_FILE="patch-${RT_KERNEL_TAG}.patch.xz"
RT_PATCH_URL="https://cdn.kernel.org/pub/linux/kernel/projects/rt/4.9/${RT_PATCH_FILE}"


GIT_KERNEL_PARENT_DIR="${CURRENT_DIR}/arm-linux-${ALT_GIT_KERNEL_VERSION}-gnueabifh-kernel"
RT_KERNEL_PARENT_DIR="${CURRENT_DIR}/arm-linux-${RT_KERNEL_VERSION}-gnueabifh-kernel"
RT_KERNEL_BUILD_DIR="${RT_KERNEL_PARENT_DIR}/${RT_KERNEL_FOLDER}"
GIT_KERNEL_BUILD_DIR="${GIT_KERNEL_PARENT_DIR}/linux"
SD_KERNEL_PARANT_DIR="${CURRENT_DIR}/arm-linux-${SD_KERNEL_VERSION}-gnueabifh-kernel"

#ALT_GIT_KERNEL_URL="https://github.com/altera-opensource/linux-socfpga.git"
ALT_GIT_KERNEL_URL="https://github.com/the-snowwhite/linux-socfpga.git"
ALT_GIT_KERNEL_BRANCH="socfpga-${GIT_KERNEL_TAG}"
ALT_GIT_KERNEL_PATCH_FILE="${ALT_GIT_KERNEL_BRANCH}-changeset.patch"
GIT_KERNEL_DIR=linux

# ------------------------------  Uboot  --------------------------------##

UBOOT_GIT_URL="git://git.denx.de/u-boot.git"
UBOOT_DIR=uboot
UBOOT_PARENT_DIR="${CURRENT_DIR}/${UBOOT_DIR}"
UBOOT_BUILD_DIR="$UBOOT_PARENT_DIR/${UBOOT_VERSION}"
UBOOT_CHKOUT_OPTIONS='-b tmp'
#UBOOT_CHKOUT_OPTIONS=""

HOLOSYNTH_QUAR_PROJ_FOLDER='/home/mib/Developer/the-snowwhite_git/HolosynthV/QuartusProjects/HolosynthIV_DE1SoC-Q15.0_15-inch-lcd'

#-----  select global toolchain  ------#

CC_FOLDER_NAME=${PCH63_CC_FOLDER_NAME}
CC_URL=${PCH63_CC_URL}

#------------------------------------------------------------------------------------------------------
# Variables Postrequsites
#------------------------------------------------------------------------------------------------------
if [ "${USER_NAME}" == "machinekit" ]; then
    HOST_NAME="mksocfpga-nano-soc"
elif [ "${USER_NAME}" == "holosynth" ]; then
    HOST_NAME="holosynthv"
fi

SD_FILE_PRELUDE=mksocfpga_${distro}_${USER_NAME}_${SD_KERNEL_VERSION}-${REL_DATE}

#------------  Toolchain  -------------#
CC_DIR="${TOOLCHAIN_DIR}/${CC_FOLDER_NAME}"
CC_FILE="${CC_FOLDER_NAME}.tar.xz"
CC="${CC_DIR}/bin/${CROSS_GNU_ARCH}-"

COMP_REL=debian-${distro}_socfpga
NCORES=`nproc`

#--------------  Kernel  --------------#

KERNEL_PRE_CONFIGSTRING="${KERNEL_CONF}"
GIT_KERNEL_PRE_CONFIGSTRING=" NAME=\"Michael Brown\" EMAIL=\"producer@holotronic.dk\" KBUILD_DEBARCH=armhf LOCALVERSION=-${GIT_KERNEL_LOCALVERSION} KDEB_PKGVERSION=${ALT_GIT_KERNEL_VERSION}-${KERNEL_PKG_VERSION}"

POLICY_FILE=${ROOTFS_MNT}/usr/sbin/policy-rc.d

EnableSystemdNetworkedLink='/etc/systemd/system/multi-user.target.wants/systemd-networkd.service'
EnableSystemdResolvedLink='/etc/systemd/system/multi-user.target.wants/systemd-resolved.service'


#-----------------------------------------------------------------------------------
# local functions
#-----------------------------------------------------------------------------------
usage()
{
    echo ""
    echo "    -h --help (this printout)"
    echo "    --deps    Will install build deps"
    echo "    --uboot   Will clone, patch and build uboot (add =c to skip build)"
    echo "    --build_git-kernel   Will clone, patch and build kernel from git (add =c to skip build)"
    echo "    --build_rt-ltsi-kernel   Will download rt-ltsi kernel, patch and build kernel (add =c to skip build)"
    echo "    --gitkernel2repo   Will add kernel .debs to local repo"
    echo "    --rtkernel2repo   Will add kernel .debs to local repo"
    echo "    --mk2repo   Will add machinekit .debs to local repo"
    echo "    --gen-base-qemu-rootfs   Will create single root partition image and generate base qemu rootfs"
    echo "    --gen-base-qemu-rootfs-desktop   Will create single root partition image and generate base qemu rootfs"
    echo "    --finalize-rootfs   Will create user and configure  rootfs for fully working out of the box experience"
    echo "    --finalize-desktop-rootfs   Will create user and configure  rootfs with desktop for fully working out of the box experience"
    echo "    --inst_repo_kernel   Will install kernel from local repo"
    echo "    --inst_repo_kernel-desktop   Will install kernel from local repo in desktop version"
    echo "    --bindmount_rootfsimg    Will mount rootfs image"
    echo "    --bindunmount_rootfsimg    Will unmount rootfs image"
    echo "    --assemble_sd_img   Will generate full populated sd imagefile and bmap file"
    echo "    --assemble_desktop_sd_img   Will generate full populated fb sd imagefile and bmap file"
    echo "    --inst_qt_img_deps  Will install qt build depedencies in rootfs image"
    echo "    --build_qt_cross  Will build and install qt in rootfs image"
    echo "    --crossbuild_qt_plugins  Will build and install qt plugins in qt_rootfs image"
    echo "    --assemble_qt_dev_sd_img   Will generate full populated sd imagefile with QT-dev and bmap file"
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
    install_uboot_dep
    install_kernel_dep
    sudo ${apt_cmd} install kpartx
    install_rootfs_dep
    sudo ${apt_cmd} install -y bmap-tools pbzip2 pigz
    echo "MSG: deps installed"
}

build_uboot() {
    contains ${BOARDS[@]} ${1}
    if [ "$?" -eq 0 ]; then
        echo "Valid boardname = ${1} given"
        # patches:
#        UBOOT_PATCH_FILE="u-boot-${UBOOT_VERSION}-${1}-changeset.patch"
        UBOOT_PATCH_FILE="u-boot-${UBOOT_VERSION}-de0-de10_nano-de1_soc-changeset.patch"
        git_fetch ${UBOOT_PARENT_DIR} ${UBOOT_GIT_URL} ${UBOOT_VERSION} ${UBOOT_VERSION} ${UBOOT_VERSION} ${UBOOT_PATCH_FILE}
        UBOOT_BOARD_CONFIG="socfpga_${1}_defconfig"
        armhf_build ${UBOOT_BUILD_DIR} "${UBOOT_BOARD_CONFIG}" "${UBOOT_MAKE_CONFIG}" "envtools"
    elif [ "${1}" == "c" ]; then
        git_fetch ${UBOOT_PARENT_DIR} ${UBOOT_GIT_URL} ${UBOOT_VERSION} ${UBOOT_VERSION} ${UBOOT_VERSION} ${UBOOT_PATCH_FILE}
    else
        echo "--build_uboot= bad argument --> ${1}"
        echo "Use either =c to fetch and patch only or =boardname"
        echo "Valid boardnames are:"
        echo " ${BOARDS[@]}"
    fi
}

build_git_kernel() {
#    distro="jessie"
    git_fetch ${GIT_KERNEL_PARENT_DIR} ${ALT_GIT_KERNEL_URL} ${GIT_KERNEL_TAG} "origin/${ALT_GIT_KERNEL_BRANCH}" ${GIT_KERNEL_DIR} ${ALT_GIT_KERNEL_PATCH_FILE}
    if [ "${1}" != "c" ]; then
    armhf_build "${GIT_KERNEL_BUILD_DIR}" ${KERNEL_CONF} "deb-pkg" |& tee ${CURRENT_DIR}/Logs/git_kernel_deb_rt-log.txt
    fi
}

build_rt_ltsi_kernel() {
    distro="stretch"
    if [ -d ${RT_KERNEL_BUILD_DIR} ]; then
        echo the kernel target directory ${RT_KERNEL_BUILD_DIR} already exists cleaning ...
        rm -R ${RT_KERNEL_BUILD_DIR}
        cd ${RT_KERNEL_PARENT_DIR}
        extract_xz ${RT_KERNEL_FILE_NAME}
    else
        mkdir -p ${RT_KERNEL_PARENT_DIR}
        cd ${RT_KERNEL_PARENT_DIR}
        get_and_extract ${RT_KERNEL_PARENT_DIR} ${KERNEL_URL} ${RT_KERNEL_FILE_NAME}
    fi
    rt_patch_kernel
    if [ "${1}" != "c" ]; then
    armhf_build "${RT_KERNEL_BUILD_DIR}" "${KERNEL_PRE_CONFIGSTRING}"
    fi
}

## parameters: 1: mount dev name, 2: image name, 3: distro name
gen_rootfs_image() {
    zero=0;
    create_img 1 ${2} ""
    mount_imagefile ${2} ${1}
    . ${FUNC_SCRIPT_DIR}/rootfs-func.sh
    echo ""
#     if [ "${USER_NAME}" == "holosynth" ]; then
#         run_qt_qemu_debootstrap ${1} ${3} ${ROOT_REPO_URL}
#     echo "Script_MSG: run_qt_qemu_debootstrap (${3}) function return value was --> ${output}"
#    else
        if [ "${DESKTOP}" == "yes" ]; then
            if [ "${3}" == "buster" ]; then
                run_qemu_debootstrap_buster ${1} ${3} ${ROOT_REPO_URL}
                echo "Script_MSG: run_qemu_debootstrap_buster function return value was --> ${output}"
            else
                run_desktop_qemu_debootstrap ${1} ${3} ${ROOT_REPO_URL}
                echo "Script_MSG: run_desktop_qemu_debootstrap (${3}) function return value was --> ${output}"
            fi
        else
            run_qemu_debootstrap ${1} ${3} ${ROOT_REPO_URL}
            echo "Script_MSG: run_qemu_debootstrap (${3}) function return value was --> ${output}"
        fi
#    fi
    echo ""
    if [[ $output -gt $zero ]]; then
        echo "Script_MSG: debootstrap failed"
        unmount_binded ${1}
        exit 1
    else
        if [ "${DESKTOP}" == "yes" ]; then
            compress_rootfs ${CURRENT_DIR} ${ROOTFS_MNT} "qemu_debootstrap-only-desktop"
        else
            compress_rootfs ${CURRENT_DIR} ${ROOTFS_MNT} "qemu_debootstrap-only"
        fi
        echo "Script_MSG: finished qemu_debootstrap-only with success ... !"
        unmount_binded ${1}
        cp ${2} "${2}-base-qemu"
        echo "Script_MSG: copied ${2} to --> ${2}-base-qemu as a backup"
    fi
}

## parameters: 1: mount dev name, 2: image name, 3: distro name
finalize_rootfs_image() {
    if [ "$(ls -A ${1})" ]; then
        echo "Script_MSG: !! Found ${1} mounted .. will unmount now"
        unmount_binded ${1}
    fi
    create_img 1 "${2}" ""
    mount_imagefile "${2}" ${1}
    bind_mounted ${ROOTFS_MNT}
    . ${FUNC_SCRIPT_DIR}/rootfs-func.sh
    if [ "${DESKTOP}" == "yes" ]; then
        extract_rootfs ${CURRENT_DIR} ${ROOTFS_MNT} "qemu_debootstrap-only-desktop"
    else
        extract_rootfs ${CURRENT_DIR} ${ROOTFS_MNT} "qemu_debootstrap-only"
    fi
    echo "Script_MSG: will now run final setup_configfiles"
    setup_configfiles
    echo "Script_MSG: configfiles setup finished"
    initial_rootfs_user_setup_sh
    finalize
    if [ "${DESKTOP}" == "yes" ]; then
        compress_rootfs ${CURRENT_DIR} ${ROOTFS_MNT} "${USER_NAME}_finalized-fully-configured-desktop"
    else
        compress_rootfs ${CURRENT_DIR} ${ROOTFS_MNT} "${USER_NAME}_finalized-fully-configured"
    fi
    set +e
    unmount_binded ${1}
    cp ${2} "${2}-fin-conf"
#	fi
}

## parameters: 1: kernel image tag, 2: rootfs image name
inst_repo_kernel() {
    if [ "$(ls -A ${ROOTFS_MNT})" ]; then
        echo "Script_MSG: !! Found ${ROOTFS_MNT} mounted .. will unmount now"
        unmount_binded ${ROOTFS_MNT}
    fi
    create_img 1 "${2}" ""
    mount_imagefile "${2}" ${ROOTFS_MNT}
    bind_mounted ${ROOTFS_MNT}
    if [ "${DESKTOP}" == "yes" ]; then
        extract_rootfs ${CURRENT_DIR} ${ROOTFS_MNT} "${USER_NAME}_finalized-fully-configured-desktop"
    else
        extract_rootfs ${CURRENT_DIR} ${ROOTFS_MNT} "${USER_NAME}_finalized-fully-configured"
    fi
    echo "Script_MSG: will now install kernel"
    inst_kernel_from_local_repo ${ROOTFS_MNT} ${SD_KERNEL_TAG}
    compress_rootfs ${CURRENT_DIR} ${ROOTFS_MNT} ${1}
    unmount_binded ${ROOTFS_MNT}
}

## parameters: 1: kernel image tag, 2: board name
assemble_full_sd_img() {
    contains ${BOARDS[@]} ${2}
    if [ "$?" -eq 0 ]; then
        if [ "${DESKTOP}" == "yes" ]; then
            SD_IMG_NAME="${SD_FILE_PRELUDE}-${2}_desktop_sd.img"
        else
            SD_IMG_NAME="${SD_FILE_PRELUDE}-${2}_sd.img"
        fi
        SD_IMG_FILE="${CURRENT_DIR}/${SD_IMG_NAME}"

        echo "step 1 create ${SD_IMG_FILE}"
        create_img "3" "${SD_IMG_FILE}" "${ROOTFS_MNT}" "${media_rootfs_partition}"
        echo "step 2 mount:"
        mount_sd_imagefile ${SD_IMG_FILE} ${ROOTFS_MNT} ${media_rootfs_partition}
        extract_rootfs ${CURRENT_DIR} ${ROOTFS_MNT} ${1}
        set_fw_uboot_env ${LOOP_DEV} ${ROOTFS_MNT} ${2}
        unmount_binded ${ROOTFS_MNT}
        unmount_loopdev
        install_uboot ${UBOOT_BUILD_DIR} ${UBOOT_IMG_FILENAME} ${SD_IMG_FILE}
        make_bmap_image ${CURRENT_DIR} ${SD_IMG_NAME}
    else
        echo "--build_uboot= bad argument --> ${2}"
        echo "Use  =boardname"
        echo "Valid boardnames are:"
        echo " ${BOARDS[@]}"
    fi
}

#------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------- #
#-----------+++     Full Flow Control                       +++-------------------- #
#---------------------------------------------------------------------------------- #
. ${FUNC_SCRIPT_DIR}/file_build-func.sh

mkdir -p Logs
if [ "$1" == "" ]; then
    echo ""
    echo "!! You ran the script without any parameters:"
    usage
fi

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
            build_uboot ${VALUE}
            ;;
        --build_git-kernel)
            build_git_kernel ${VALUE}
            ;;
        --build_rt-ltsi-kernel)
            build_rt_ltsi_kernel ${VALUE}
            ;;
        --gitkernel2repo)
            add2repo ${distro} ${GIT_KERNEL_PARENT_DIR} "linux-"
#            add2repo ${distro} ${GIT_KERNEL_PARENT_DIR} ${GIT_KERNEL_TAG}
            ;;
        --rtkernel2repo)
#            add2repo ${distro} ${RT_KERNEL_PARENT_DIR} ${RT_KERNEL_TAG}
            add2repo "stretch" ${RT_KERNEL_PARENT_DIR} "${RT_KERNEL_TAG}-socfpga-${KERNEL_PKG_VERSION}"
            ;;
        --mk2repo)
            add2repo ${distro} "/home/mib/Development/Docker" "machinekit"
            ;;
        --gen-base-qemu-rootfs)
            gen_rootfs_image ${ROOTFS_MNT} "${CURRENT_DIR}/${ROOTFS_IMG}" ${distro} | tee ${CURRENT_DIR}/Logs/gen-qemu-base_rootfs-log.txt
            ;;
        --gen-base-qemu-rootfs-desktop)
            DESKTOP="yes"
            gen_rootfs_image ${ROOTFS_MNT} "${CURRENT_DIR}/desktop-${ROOTFS_IMG}" ${distro} | tee ${CURRENT_DIR}/Logs/gen-qemu-base_rootfs-log.txt
            ;;
        --finalize-rootfs)
            finalize_rootfs_image ${ROOTFS_MNT} "${CURRENT_DIR}/${ROOTFS_IMG}" ${distro} | tee ${CURRENT_DIR}/Logs/finalize_rootfs-log.txt
            ;;
        --finalize-desktop-rootfs)
            DESKTOP="yes"
            finalize_rootfs_image ${ROOTFS_MNT} "${CURRENT_DIR}/desktop-${ROOTFS_IMG}" ${distro} | tee ${CURRENT_DIR}/Logs/finalize_rootfs-log.txt
            ;;
        --inst_repo_kernel)
            inst_repo_kernel "${USER_NAME}_finalized-fully-configured-with-kernel" "${CURRENT_DIR}/${ROOTFS_IMG}"
            ;;
        --inst_repo_kernel-desktop)
            DESKTOP="yes"
            inst_repo_kernel "${USER_NAME}_finalized-fully-configured-with-kernel-and-desktop" "${CURRENT_DIR}/desktop-kernel-${ROOTFS_IMG}"
            ;;
        --bindmount_rootfsimg)
            mount_imagefile "${CURRENT_DIR}/${ROOTFS_IMG}" ${ROOTFS_MNT}
            bind_mounted ${ROOTFS_MNT}
            ;;
        --bindunmount_rootfsimg)
            unmount_binded ${ROOTFS_MNT}
            ;;
        --assemble_sd_img)
            assemble_full_sd_img "${USER_NAME}_finalized-fully-configured-with-kernel" ${VALUE}
            ;;
        --assemble_desktop_sd_img)
            DESKTOP="yes"
            assemble_full_sd_img "${USER_NAME}_finalized-fully-configured-with-kernel-and-desktop" ${VALUE}
            ;;
        --inst_qt_img_deps)
            if [ "$(ls -A ${ROOTFS_MNT})" ]; then
                echo "Script_MSG: !! Found ${ROOTFS_MNT} mounted .. will unmount now"
                unmount_binded ${ROOTFS_MNT}
            fi
            create_img 1 "${CURRENT_DIR}/${ROOTFS_IMG}" ""
            mount_imagefile "${CURRENT_DIR}/${ROOTFS_IMG}" ${ROOTFS_MNT}
            bind_mounted ${ROOTFS_MNT}
            extract_rootfs ${CURRENT_DIR} ${ROOTFS_MNT} "${USER_NAME}_finalized-fully-configured-with-kernel-and-desktop"
#           cp "${CURRENT_DIR}/desktop-${ROOTFS_IMG}" "${CURRENT_DIR}/fin-qt-dep-${ROOTFS_IMG}"
#            mount_imagefile "${CURRENT_DIR}/fin-qt-dep-${ROOTFS_IMG}" ${ROOTFS_MNT}
#            bind_mounted ${ROOTFS_MNT}
            mkdir -p ${CURRENT_DIR}/Qt_logs
            inst_qt_build_deps 2>&1| tee ${CURRENT_DIR}/Qt_logs/install_qt_deps-log.txt
            compress_rootfs ${CURRENT_DIR} ${ROOTFS_MNT} "${USER_NAME}_finalized-fully-configured-with-kernel-and-desktop-and-qt-deps"
            unmount_binded ${ROOTFS_MNT}
            ;;
        --build_qt_cross)
            if [ "$(ls -A ${QT_ROOTFS_MNT})" ]; then
                echo "Script_MSG: !! Found ${QT_ROOTFS_MNT} mounted .. will unmount now"
                unmount_binded ${QT_ROOTFS_MNT}
            fi
            create_img 1 "${CURRENT_DIR}/${ROOTFS_IMG}" ""
            mount_imagefile "${CURRENT_DIR}/${ROOTFS_IMG}" ${QT_ROOTFS_MNT}
            bind_mounted ${QT_ROOTFS_MNT}
            extract_rootfs ${CURRENT_DIR} ${QT_ROOTFS_MNT} "${USER_NAME}_finalized-fully-configured-with-kernel-and-desktop-and-qt-deps"
#            cp "${CURRENT_DIR}/fin-qt-dep-${ROOTFS_IMG}" "${CURRENT_DIR}/fin-qt-built-${ROOTFS_IMG}"
#            mount_imagefile "${CURRENT_DIR}/fin-qt-built-${ROOTFS_IMG}" ${QT_ROOTFS_MNT}
            qt_build
            compress_rootfs ${CURRENT_DIR} ${QT_ROOTFS_MNT} "${USER_NAME}_finalized-fully-configured-with-kernel-and-desktop-and-qtbuilt"
            unmount_binded ${QT_ROOTFS_MNT}
            ;;
        --crossbuild_qt_plugins)
            if [ "$(ls -A ${QT_ROOTFS_MNT})" ]; then
                echo "Script_MSG: !! Found ${QT_ROOTFS_MNT} mounted .. will unmount now"
                unmount_binded ${QT_ROOTFS_MNT}
            fi
            create_img 1 "${CURRENT_DIR}/${QT_ROOTFS_IMG}" ""
            mount_imagefile "${CURRENT_DIR}/${QT_ROOTFS_IMG}" ${QT_ROOTFS_MNT}
            bind_mounted ${QT_ROOTFS_MNT}
            extract_rootfs ${CURRENT_DIR} ${QT_ROOTFS_MNT} "${USER_NAME}_finalized-fully-configured-with-kernel-and-desktop-and-qtbuilt"
#            cp "${CURRENT_DIR}/fin-qt-dep-${ROOTFS_IMG}" "${CURRENT_DIR}/fin-qt-built-${ROOTFS_IMG}"
#            mount_imagefile "${CURRENT_DIR}/fin-qt-built-${ROOTFS_IMG}" ${QT_ROOTFS_MNT}
            build_qt_plugins qwt
            compress_rootfs ${CURRENT_DIR} ${QT_ROOTFS_MNT} "${USER_NAME}_finalized-fully-configured-with-kernel-and-desktop-and-qtbuilt-and-qt-plugins"
            unmount_binded ${QT_ROOTFS_MNT}
            ;;
        --assemble_qt_dev_sd_img)
            DESKTOP="yes"
#            assemble_full_sd_img "finalized-fully-configured-with-kernel-and-qt-installed"
            assemble_full_sd_img "${USER_NAME}_finalized-fully-configured-with-kernel-and-desktop-and-qtbuilt-and-qt-plugins" ${VALUE}
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

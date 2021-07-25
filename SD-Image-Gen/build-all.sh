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
export DEBIAN_FRONTEND=noninteractive

## Valid boards:
BOARDS=("de0_nano_soc" "de10_nano" "de1_soc" "ultra96v1" "fz3" "ultramyir" "k26-stkit")

BOARD_CLASS=("cvsoc" "mpsoc")

## Valid distros:
DISTROS=("stretch" "buster" "bullseye" "bionic" "petalinux")

## Valid archs:
DISTARCHS=("armhf" "arm64")

## Valid user names
USERS=("machinekit" "holosynth" "ubuntu" "vivado")

#HOME_DEB_MIRR_REPO_URL=http://kubuntu16-srv.holotronic.lan/debian
#HOME_DEB_MIRR_REPO_URL=http://kdeneon-ws/debian
HOME_DEB_MIRR_REPO_URL=http://bullseye-ws2/debian

shell_cmd="/bin/bash"

#DEB_EXT_REPO_URL="http://deb.debian.org//debian/"
DEB_EXT_REPO_URL="http://ftp.dk.debian.org/debian/"
#UB_EXT_REPO_URL=http://ftp.tu-chemnitz.de/pub/linux/ubuntu-ports
UB_EXT_REPO_URL="http://ports.ubuntu.com/ubuntu-ports/"
#final_repo="http://ftp.dk.debian.org/debian/"
final_deb_repo=${DEB_EXT_REPO_URL}
final_ub_repo=${UB_EXT_REPO_URL}
#local_deb_repo=${HOME_DEB_MIRR_REPO_URL}
local_deb_repo=${DEB_EXT_REPO_URL}
local_ub_repo=${UB_EXT_REPO_URL}
#local_ws=kdeneon-ws
local_ws=bullseye-ws2
#local_kernel_repo="http://${local_ws}.holotronic.lan/debian/"
#local_ub_kernel_repo="http://${local_ws}.holotronic.lan/ubuntu/"
local_kernel_repo="http://${local_ws}/debian/"
local_ub_kernel_repo="http://${local_ws}/ubuntu/"
HolosynthV_URL="https://github.com/the-snowwhite/HolosynthV/raw/2020.2.2"

## 3 part Expandable image with swap in p2
ROOTFS_TYPE=ext4
mkfs="mkfs.${ROOTFS_TYPE}"
media_swap_partition=p2
media_rootfs_partition=p3
ROOTFS_MNT="/tmp/myimage"

ROOTFS_LABEL="rootfs"
ROOTFS_IMG_END_TAG="${ROOTFS_LABEL}.img"
QT_ROOTFS_IMG_END_TAG="qt_${ROOTFS_LABEL}.img"

ext4_options="-O ^metadata_csum,^64bit"
#mkfs_options="${ext4_options}"
mkfs_options=""


## Select u-boot version:
UBOOT_VERSION="v2018.01"
#UBOOT_VERSION="v2021.01"

#XIL_UBOOT_VERSION="v2018.07"
#XIL_UBOOT_VERSION="v2018.07-rc3"
XIL_UBOOT_VERSION="xilinx-v2018.2"
#UBOOT_MAKE_CONFIG="u-boot-with-spl.sfp"
UBOOT_MAKE_CONFIG="all"
UBOOT_IMG_FILENAME="u-boot-with-spl.sfp"
XIL_UBOOT_IMG_FILENAME="u-boot"
#XIL_BOOT_FILES_LOC="/home/mib/Development/Docker/petalinux-docker"
XIL_BOOT_FILES_LOC='/home/mib/Projects/sd-boot-files'
RT_KERNEL_VERSION="4.9.68"
RT_PATCH_REV="rt60"

#ALT_GIT_KERNEL_VERSION="4.14.126"
#ALT_GIT_KERNEL_REV="-ltsi-rt"
#ALT_GIT_KERNEL_NUM="5.4"
ALT_GIT_KERNEL_VERSION="5.4.114"
ALT_GIT_KERNEL_REV="-lts"
#XIL_GIT_KERNEL_VERSION="xilinx"
XIL_GIT_KERNEL_VERSION="zynqmp"
#XIL_GIT_KERNEL_REV="-v2019.1"
XIL_GIT_KERNEL_REV="-5.4"

#RT_PATCH_REV="ltsi-rt23-socfpga-initrd"
#RT_PATCH_REV="ltsi-rt23"
ALT_KERNEL_CONF="socfpga_defconfig"
XIL_KERNEL_CONF="xilinx_zynqmp_defconfig"
ALT_GIT_KERNEL_TAG="${ALT_GIT_KERNEL_VERSION}${ALT_GIT_KERNEL_REV}"
XIL_GIT_KERNEL_TAG="${XIL_GIT_KERNEL_VERSION}${XIL_GIT_KERNEL_REV}"

QT_VER=5.7.1
QTDIR="/home/mib/qt-src/qt-everywhere-opensource-src-${QT_VER}"
#QT_VER=5.10.1
#QTDIR="/home/mib/qt-src/qt-everywhere-src-${QT_VER}"

QT_1="/tmp/qt_${QT_VER}-img"
QT_PREFIX="/usr/local/lib/qt-${QT_VER}-altera-soc"

QWTDIR="/home/mib/Developer/ext-repos/qwt/qwt"

#------------------------------------------------------------------------------------------------------
# Variables Prerequsites
#apt_cmd=apt
apt_cmd="apt-get"
#------------------------------------------------------------------------------------------------------
WORK_DIR=$(pwd)

#HOME_REPO_DIR="/var/www/repos/apt/debian"
#HOME_REPO_DIR="/var/www/debian"
#HOME_REPO_DIR="/var/www/repos/apt"
#HOME_REPO_DIR="/opt/lampp/htdocs/repos/apt"
HOME_REPO_DIR="/var/www/html/repos/apt"

MAIN_SCRIPT_DIR="$(cd $(dirname $0) && pwd)"
SUB_SCRIPT_DIR=${MAIN_SCRIPT_DIR}/subscripts
FUNC_SCRIPT_DIR=${MAIN_SCRIPT_DIR}/functions
PATCH_SCRIPT_DIR=${MAIN_SCRIPT_DIR}/patches
DTS_DIR=${MAIN_SCRIPT_DIR}/../dts

CURRENT_DIR=`pwd`

CURRENT_DATE=`date -I`
REL_DATE=${CURRENT_DATE}
#REL_DATE=2016-03-07

#DEFGROUPS="sudo,kmem,adm,dialout,holosynth,video,plugdev,netdev,tty"

## ----------------------------  Toolchain   -----------------------------##
CROSS_GNU_ARCH="arm-linux-gnueabihf"
CROSS_GNU_ARCH_64="aarch64-linux-gnu"

QT_CFLAGS="-march=armv7-a -mtune=cortex-a8 -mfpu=neon -mfloat-abi=hard"

#QT_CC_FOLDER_NAME="gcc-linaro-${CROSS_GNU_ARCH}-4.9-2014.09_linux"
#QT_CC_FOLDER_NAME=PCH63_CC_FOLDER_NAME
#QT_CC_FOLDER_NAME=PCH52_CC_FOLDER_NAME

#QT_CC_DIR="${TOOLCHAIN_DIR}/${QT_CC_FOLDER_NAME}"
#QT_CC_FILE="${QT_CC_FOLDER_NAME}.tar.xz"
#QT_CC="${QT_CC_DIR}/bin/${CROSS_GNU_ARCH}-"
QT_CC="/usr/bin/${CROSS_GNU_ARCH}-"

## ------------------------------  Kernel  -------------------------------##

RT_KERNEL_TAG="${RT_KERNEL_VERSION}-${RT_PATCH_REV}"
RT_KERNEL_LOCALVERSION="socfpga-${RT_KERNEL_TAG}"
#GIT_KERNEL_LOCALVERSION="socfpga-${ALT_GIT_KERNEL_TAG}"

RT_KERNEL_FOLDER="linux-${RT_KERNEL_VERSION}"
RT_KERNEL_FILE_NAME="${RT_KERNEL_FOLDER}.tar.xz"
KERNEL_URL="https://cdn.kernel.org/pub/linux/kernel/v4.x/${RT_KERNEL_FILE_NAME}"
RT_PATCH_FILE="patch-${RT_KERNEL_TAG}.patch.xz"
RT_PATCH_URL="https://cdn.kernel.org/pub/linux/kernel/projects/rt/4.9/${RT_PATCH_FILE}"


ALT_GIT_KERNEL_PARENT_DIR="${CURRENT_DIR}/arm-linux-${ALT_GIT_KERNEL_TAG}-gnueabihf-kernel"
XIL_GIT_KERNEL_PARENT_DIR="${CURRENT_DIR}/arm-linux-${XIL_GIT_KERNEL_TAG}-aarch64-kernel"

RT_KERNEL_PARENT_DIR="${CURRENT_DIR}/arm-linux-${RT_KERNEL_VERSION}-gnueabihf-kernel"
RT_KERNEL_BUILD_DIR="${RT_KERNEL_PARENT_DIR}/${RT_KERNEL_FOLDER}"
ALT_GIT_KERNEL_BUILD_DIR="${ALT_GIT_KERNEL_PARENT_DIR}/linux"
XIL_GIT_KERNEL_BUILD_DIR="${XIL_GIT_KERNEL_PARENT_DIR}/linux"

#ALT_GIT_KERNEL_URL="https://github.com/altera-opensource/linux-socfpga.git"
ALT_GIT_KERNEL_URL="https://github.com/the-snowwhite/linux-socfpga.git"
XIL_GIT_KERNEL_URL="https://github.com/the-snowwhite/linux-xlnx.git"
ALT_GIT_KERNEL_BRANCH="socfpga-${ALT_GIT_KERNEL_TAG}"
XIL_GIT_KERNEL_BRANCH="socfpga64-${XIL_GIT_KERNEL_TAG}"
ALT_GIT_KERNEL_PATCH_FILE="${ALT_GIT_KERNEL_BRANCH}-changeset.patch"
XIL_GIT_KERNEL_PATCH_FILE="${XIL_GIT_KERNEL_BRANCH}-changeset.patch"
GIT_KERNEL_DIR=linux

# ------------------------------  Uboot  --------------------------------##

UBOOT_GIT_URL="git://git.denx.de/u-boot.git"
XIL_UBOOT_GIT_URL="https://github.com/Xilinx/u-boot-xlnx.git"
UBOOT_DIR=uboot
UBOOT_PARENT_DIR="${CURRENT_DIR}/${UBOOT_DIR}"
UBOOT_BUILD_DIR="$UBOOT_PARENT_DIR/${UBOOT_VERSION}"
XIL_UBOOT_BUILD_DIR="$UBOOT_PARENT_DIR/${XIL_UBOOT_VERSION}"
UBOOT_CHKOUT_OPTIONS='-b tmp'
#UBOOT_CHKOUT_OPTIONS=""

HOLOSYNTH_QUAR_PROJ_FOLDER='/home/mib/Developer/the-snowwhite_git/HolosynthV/QuartusProjects/HolosynthIV_DE1SoC-Q15.0_15-inch-lcd'

#-----  select global toolchain  ------#

#CC_FOLDER_NAME=${PCH63_CC_FOLDER_NAME}
#CC_URL=${PCH63_CC_URL}

#------------------------------------------------------------------------------------------------------
# Variables Postrequsites
#------------------------------------------------------------------------------------------------------

#------------  Toolchain  -------------#
#CC_DIR="${TOOLCHAIN_DIR}/${CC_FOLDER_NAME}"
#CC_FILE="${CC_FOLDER_NAME}.tar.xz"
#CC="${CC_DIR}/bin/${CROSS_GNU_ARCH}-"
CC="${CROSS_GNU_ARCH}-"
CC_64="${CROSS_GNU_ARCH_64}-"

NCORES=`nproc`

#--------------  Kernel  --------------#

KERNEL_PRE_CONFIGSTRING="${ALT_KERNEL_CONF}"

POLICY_FILE=${1}/usr/sbin/policy-rc.d

EnableSystemdNetworkedLink='/etc/systemd/system/multi-user.target.wants/systemd-networkd.service'
EnableSystemdResolvedLink='/etc/systemd/system/multi-user.target.wants/systemd-resolved.service'
EnableResize2fsLink='/etc/systemd/system/multi-user.target.wants/resize2fs.service'


#-----------------------------------------------------------------------------------
# local functions
#-----------------------------------------------------------------------------------
usage()
{
    echo ""
    echo "    -h --help (this printout)"
    echo "    --deps    Will install build deps"
    echo "    --uboot   Will clone, patch and build uboot Use  =boardname (add =c to skip build)"
    echo "    --build_git-kernel   Will clone, patch and build kernel from git Use =distroname=boardname (add =c to skip build)"
    echo "    --gitkernel2repo   Will add kernel .debs to local repo Use =distroname=distarch"
    echo "    --mk2repo   Will add machinekit .debs to local repo Use =distroname=distarch"
    echo "    --cadence2repo   Will add cadence .debs to local repo Use =distroname=distarch"
    echo "    --carla2repo   Will add carla .debs to local repo Use =distroname=distarch"
    echo "    --lv22repo   Will add lv2plugin .debs to local repo Use =distroname=distarch"
    echo "    --jackd22repo   Will add Jackd2 .debs to local repo Use =distroname=distarch"
    echo "    --hikey2repo   Will add Hikey kernel .debs to local repo Use =distroname=distarch"
    echo "    --dexed2repo   Will add Dexed and plugin .debs to local repo Use =distroname=distarch"
    echo "    --xf86-video-armsoc2repo   Will add xf86-video-armsoc .debs to local repo Use =distroname=distarch"
    echo "    --gen-base-rootfs   Will create single root partition image and generate base rootfs Use =distroname=distarch"
    echo "    --gen-base-rootfs-desktop   Will create single root partition image and generate base rootfs Use =distroname=distarch"
    echo "    --finalize-rootfs   Will create user and configure  rootfs for fully working out of the box experience Use =distroname=distarch=username"
    echo "    --finalize-desktop-rootfs   Will create user and configure  rootfs with desktop for fully working out of the box experience Use =distroname=distarch=username"
    echo "    --inst_repo_kernel   Will install kernel from local repo Use =distroname=distarch=username"
    echo "    --inst_repo_kernel-desktop   Will install kernel from local repo in desktop version Use =distroname=distarch=username"
    echo "    --inst_hs_aud_stuff  Will install holosynth audio stuff in rootfs image"
    echo "    --bindmount_rootfsimg    Will mount rootfs image"
    echo "    --bindunmount_rootfsimg    Will unmount rootfs image"
    echo "    --assemble_sd_img   Will generate full populated sd imagefile and bmap file Use =boardname=distroname=username"
    echo "    --assemble_desktop_sd_img   Will generate full populated fb sd imagefile and bmap file Use =boardname=distroname=username"
    echo ""
}

install_deps() {
## toolchain:
#     if [ ! -d ${CC_DIR} ]; then
#         echo ""
#         echo "Script_MSG: Toolchain not preinstalled .!"
#         echo "Script_MSG: ${CC_DIR}"
#         echo ""
#         cd ${TOOLCHAIN_DIR}
#         get_and_extract ${CC_DIR} ${CC_URL} ${CC_FILE}
#         # install linaro gcc crosstoolchain dependency:
#         sudo ${apt_cmd} -y install lib32stdc++6
#     else
#         echo ""
#         echo "Script_MSG: Toolchain allready installed in -->"
#         echo "Script_MSG: ${CC_DIR}"
#         echo ""
#     fi
    
    install_crossbuild_arm64
    install_uboot_dep
    install_kernel_dep
    sudo ${apt_cmd} install kpartx
    install_rootfs_dep
    sudo ${apt_cmd} install -y bmap-tools pbzip2 pigz
    echo "MSG: deps installed"
}

## parameters: 1: board name
uild_uboot() {
    contains ${BOARDS[@]} ${1}
    if [ "$?" -eq 0 ]; then
        echo "Valid boardname = ${1} given"
        if [ "${1}" == "ultra96v1" ] || [ "${1}" == "fz3" ] || [ "${1}" == "ultramyir" ] || [ "${1}" == "k26-stkit" ]; then
            echo ""
            echo "! Please use holosynth petalinux bsp to generate boot files"
            echo ""
            exit
        else
            # patches:
            UBOOT_PATCH_FILE="u-boot-${UBOOT_VERSION}-de0-de10_nano-de1_soc-changeset.patch"
            git_fetch ${UBOOT_PARENT_DIR} ${UBOOT_GIT_URL} ${UBOOT_VERSION} ${UBOOT_VERSION} ${UBOOT_VERSION} ${UBOOT_PATCH_FILE}
            UBOOT_BOARD_CONFIG="socfpga_${1}_defconfig"
            armhf_build "$UBOOT_PARENT_DIR/${UBOOT_VERSION}" "${UBOOT_BOARD_CONFIG}" "${UBOOT_MAKE_CONFIG}" "envtools"
        fi
    elif [ "${1}" == "c" ]; then
        git_fetch ${UBOOT_PARENT_DIR} ${UBOOT_GIT_URL} ${UBOOT_VERSION} ${UBOOT_VERSION} ${UBOOT_VERSION} ${UBOOT_PATCH_FILE}
    else
        echo "--build_uboot= bad argument --> ${1}"
        echo "Use (=c to skip build) =boardname"
        echo "Valid boardnames are:"
        echo " ${BOARDS[@]}"
    fi
}

## parameters: 1: board name, 2: distro name
build_git_kernel() {
contains ${BOARDS[@]} ${1}
    if [ "$?" -eq 0 ]; then
        echo "Valid boardname = ${1} given"
        if [ "${1}" == "ultra96v1" ] || [ "${1}" == "fz3" ] || [ "${1}" == "ultramyir" ] || [ "${1}" == "k26-stkit" ]; then
            echo ""
            echo "! Please use holosynth petalinux bsp to generate boot files"
            echo ""
            exit
        else
            KERNEL_PKG_VERSION="1.0"
            git_fetch ${ALT_GIT_KERNEL_PARENT_DIR} ${ALT_GIT_KERNEL_URL} ${ALT_GIT_KERNEL_TAG} "origin/${ALT_GIT_KERNEL_BRANCH}" ${GIT_KERNEL_DIR} ${ALT_GIT_KERNEL_PATCH_FILE}
            armhf_build "${ALT_GIT_KERNEL_BUILD_DIR}" ${ALT_KERNEL_CONF} "deb-pkg" |& tee ${CURRENT_DIR}/Logs/alt_git_kernel_deb_rt-log.txt
        fi

    else
        if [ "${1}" != "c" ]; then
            echo "--build_git_kernel bad argument --> ${1}"
            echo "Use =boardname or =c --> configure and patch only"
            echo "Valid boardnames are:"
            echo " ${BOARDS[@]}"
        else
            echo ""
            echo "MSG: kernel configure and patching only"
            echo ""
            git_fetch ${ALT_GIT_KERNEL_PARENT_DIR} ${ALT_GIT_KERNEL_URL} ${ALT_GIT_KERNEL_TAG} "origin/${ALT_GIT_KERNEL_BRANCH}" ${GIT_KERNEL_DIR} ${ALT_GIT_KERNEL_PATCH_FILE}
            echo "MSG: kernel configure and patch finish"
            echo ""
        fi
    fi
}

## parameters: 1: mount dev name, 2: distro name, 3: distro arch
gen_rootfs_image() {
    zero=0;
    contains ${DISTROS[@]} ${2}
    if [ "$?" -eq 0 ]; then
        echo "Script_MSG: Valid distroname = ${2} given"
        contains ${DISTARCHS[@]} ${3}
        if [ "$?" -eq 0 ]; then
            echo "Script_MSG: Valid distarch = ${3} given"
            create_img "1" rootfs.img
            mount_imagefile rootfs.img ${1}
            . ${FUNC_SCRIPT_DIR}/rootfs-func.sh
            echo ""
            if [ "${DESKTOP}" == "yes" ]; then
                if [ "${2}" == "bionic" ]; then
                    run_desktop_debootstrap_bionic ${1} ${2} ${UB_EXT_REPO_URL} ${3}
                    echo "Script_MSG: run_desktop_debootstrap_bionic (${2}) (${3}) function return value was --> ${output}"
                else
                    if [ "${2}" == "bullseye" ]; then
                        echo "Script_MSG: will run run_desktop_debootstrap_bullseye"
                        run_desktop_debootstrap_bullseye ${1} ${2} ${DEB_EXT_REPO_URL} ${3}
                        echo "Script_MSG: run_desktop_debootstrap_bullseye (${2}) (${3}) function return value was --> ${output}"
                    else
                        if [ "${2}" == "buster" ]; then
                            run_desktop_debootstrap_buster ${1} ${2} ${DEB_EXT_REPO_URL} ${3}
                            echo "Script_MSG: run_desktop_debootstrap_buster (${2}) (${3}) function return value was --> ${output}"
                        else
                            if [ "${2}" == "stretch" ]; then
                                run_desktop_debootstrap_stretch ${1} ${2} ${DEB_EXT_REPO_URL} ${3}
                                echo "Script_MSG: run_desktop_debootstrap_buster (${2}) (${3}) function return value was --> ${output}"
                            else
                                run_desktop_debootstrap ${1} ${2} ${DEB_EXT_REPO_URL} ${3}
                                echo "Script_MSG: run_desktop_debootstrap (${2}) (${3}) function return value was --> ${output}"
                            fi
                        fi
                    fi
                fi
            else
                run_debootstrap ${1} ${2} ${DEB_EXT_REPO_URL} ${3}
                echo "Script_MSG: run_debootstrap (${2}) (${3}) function return value was --> ${output}"
            fi
            echo ""
            if [[ $output -gt $zero ]]; then
                echo "Script_MSG: debootstrap failed"
                unmount_binded ${1}
                exit 1
            else
                if [ "${DESKTOP}" == "yes" ]; then
                    compress_rootfs ${CURRENT_DIR} ${1} "${3}_base-desktop" ${2}
                    # parameters: 1: work dir, 2: mount dev name, 3: comp prefix, 4 distro name
                    unmount_binded ${1}
                    sudo mv rootfs.img "${2}-${3}_base-desktop.img"
                    echo "Script_MSG: renamed rootfs.img to --> ${2}-${3}_base-desktop.img"
                else
                    compress_rootfs ${CURRENT_DIR} ${1} "${3}_base" ${2}
                    # parameters: 1: work dir, 2: mount dev name, 3: comp prefix, 4 distro name
                    unmount_binded ${1}
                    sudo mv rootfs.img "${CURRENT_DIR}/${2}_${3}-base.img"
                    echo "Script_MSG: renamed rootfs.img to --> ${CURRENT_DIR}/${2}_${3}-base.img"
                fi
                echo "Script_MSG: finished debootstrap-only_${2}-${3} with success ... !"
            fi
        else
            echo "--gen_rootfs_image= bad argument --> ${3}"
            echo "Use =distroname=distarch"
            echo "Valid distarchs are:"
            echo " ${DISTARCHS[@]}"
        fi
    else
        echo "--gen_rootfs_image= bad argument --> ${2}"
        echo "Use =distroname=distarch"
        echo "Valid distrosnames are:"
        echo " ${DISTROS[@]}"
        echo "Valid distarchs are:"
        echo " ${DISTARCHS[@]}"
    fi
}

## parameters: 1: mount dev name, 2: distro name, 3: distro arch, 4: user name
finalize_rootfs_image() {
#    set -x
    contains ${DISTROS[@]} ${2}
    if [ "$?" -eq 0 ]; then
        echo "Valid distroname = ${2} given"
        contains ${USERS[@]} ${4}
        if [ "$?" -eq 0 ]; then
            echo "Valid user name = ${4} given"
            contains ${DISTARCHS[@]} ${3}
            if [ "$?" -eq 0 ]; then
                echo "Valid distarch = ${3} given"
                if [ "$(ls -A ${1})" ]; then
                    echo "Script_MSG: !! Found ${1} mounted .. will unmount now"
                    unmount_binded ${1}
                fi
                create_img "1" rootfs.img
                mount_imagefile rootfs.img ${1}
                bind_mounted ${1}
                . ${FUNC_SCRIPT_DIR}/rootfs-func.sh
                if [ "${DESKTOP}" == "yes" ]; then
                    extract_rootfs ${CURRENT_DIR} ${1} "${3}_base-desktop" ${2}
                else
                    extract_rootfs ${CURRENT_DIR} ${1} "${3}_base" ${2}
                fi
                echo "Script_MSG: will now run final setup_configfiles with user name: ${4}"
                setup_configfiles ${1} ${4} ${2} ${3}
                echo "Script_MSG: configfiles setup finished"
                initial_rootfs_user_setup_sh ${1} ${4} ${2} ${3}
                finalize ${1} ${4} ${2} ${3}
                sudo sync
                if [ "${DESKTOP}" == "yes" ]; then
                    compress_rootfs ${CURRENT_DIR} ${1} "${3}_${4}_finalized-desktop" ${2}
                    sudo sync
                    unmount_binded ${1}
                    sudo mv rootfs.img "${CURRENT_DIR}/${2}_${3}_${4}_finalized-desktop.img"
                    echo "Script_MSG: renamed rootfs.img to --> ${CURRENT_DIR}/${2}_${3}_${4}_finalized.img"
                else
                    compress_rootfs ${CURRENT_DIR} ${1} "${3}_${4}_finalized" ${2}
                    sudo sync
                    unmount_binded ${1}
                    sudo mv rootfs.img "${CURRENT_DIR}/${2}_${3}_${4}_finalized.img"
                    echo "Script_MSG: renamed rootfs.img to --> ${CURRENT_DIR}/${2}_${3}_${4}_finalized.img"
                fi
                sudo sync
                echo ""
                echo "Script_MSG: finished finalize_rootfs_image_${2}-${3}-${4} with success ... !"
            else
                echo "--finalize_rootfs_image= bad argument --> ${3}"
                echo "Use =distroname=username=distarch"
                echo "Valid distarchs are:"
                echo " ${DISTARCHS[@]}"
            fi
        else
            echo "--finalize_rootfs_image= bad argument --> ${4}"
            echo "missing username"
            echo "Use =distroname=username=distarch"
            echo "Valid distrosnames are:"
            echo " ${DISTROS[@]}"
            echo "Valid usernames are:"
            echo " ${USERS[@]}"
            echo "Valid distarchs are:"
            echo " ${DISTARCHS[@]}"
        fi
    else
        echo "--finalize_rootfs_image= bad argument --> ${2}"
        echo "Use =distroname=username=distarch"
        echo "Valid distrosnames are:"
        echo " ${DISTROS[@]}"
        echo "Valid usernames are:"
        echo " ${USERS[@]}"
        echo "Valid distarchs are:"
        echo " ${DISTARCHS[@]}"
    fi
}

## parameters: 1: mount dev name, 2: distroname, 3: distro arch, 4: user name
inst_repo_kernel() {
    contains ${DISTROS[@]} ${2}
    if [ "$?" -eq 0 ]; then
        echo "Valid distroname = ${2} given"
        contains ${DISTARCHS[@]} ${3}
        if [ "$?" -eq 0 ]; then
            echo "Valid distarch = ${3} given"
            contains ${USERS[@]} ${4}
            if [ "$?" -eq 0 ]; then
                echo "Valid user name = ${4} given"
                if [ "$(ls -A ${1})" ]; then
                    echo "Script_MSG: !! Found ${1} mounted .. will unmount now"
                    unmount_binded ${1}
                fi
                create_img "1" rootfs.img
                mount_imagefile rootfs.img ${1}
                bind_mounted ${1}
                if [ "${DESKTOP}" == "yes" ]; then
                    extract_rootfs ${CURRENT_DIR} ${1} "${3}_${4}_finalized-desktop" ${2}
                else
                    extract_rootfs ${CURRENT_DIR} ${1} "${3}_${4}_finalized" ${2}
                fi
                echo "Script_MSG: will now install kernel"
                if [ "${3}" == "arm64" ]; then
                    if [ "${2}" == "bionic" ] || [ "${2}" == "buster" ]; then
                        SD_KERNEL_TAG="*socfpga64-4.14"
                    else
                        SD_KERNEL_TAG="*socfpga64-5.5"
                    fi
                    if [ "${2}" == "bullseye" ]; then
                        sudo cp -r '/home/mib/Projects/2020v1/kernel_modules/lib/modules' ${1}/lib
                    else
                        sudo cp -r '/home/mib/Projects/2019v1/kernel_modules/lib/modules' ${1}/lib
                    fi
                else
                    SD_KERNEL_TAG="${ALT_GIT_KERNEL_VERSION}-socfpga"
                    inst_kernel_from_local_repo ${1} ${SD_KERNEL_TAG}
                fi
                if [ "${DESKTOP}" == "yes" ]; then
                    compress_rootfs ${CURRENT_DIR} ${1} "${3}_${4}_finalized-desktop_with-kernel" ${2}
                    unmount_binded ${1}
                    sudo mv rootfs.img "${2}_${3}_${4}_finalized-desktop_with-kernel.img"
                else
                    compress_rootfs ${CURRENT_DIR} ${1} "${3}_${4}_finalized_with-kernel" ${2}
                    unmount_binded ${1}
                    sudo mv rootfs.img "${2}_${3}_${4}_finalized_with-kernel.img"
                fi
                sudo sync
                echo "Script_MSG: finished inst_repo_kernel_${2}-${3}-${4} with success ... !"
            else
                echo "--inst_repo_kernel= bad argument --> ${4}"
                echo "wrong user name"
                echo "Use =distroname=distarch=username"
                echo "Valid user names are:"
                echo " ${USERS[@]}"
                echo " ${DISTARCHS[@]}"
                echo "Valid distrosnames are:"
                echo " ${DISTROS[@]}"
            fi
        else
            echo "--inst_repo_kernel= bad argument --> ${3}"
            echo "Use =distroname=distarch=username"
            echo "Valid user names are:"
            echo " ${USERS[@]}"
            echo "Valid distarchs are:"
            echo " ${DISTARCHS[@]}"
            echo "Valid distrosnames are:"
            echo " ${DISTROS[@]}"
        fi
    else
        echo "--inst_repo_kernel= bad argument --> ${2}"
        echo "Use =distroname=distarch=username"
        echo "Valid user names are:"
        echo " ${USERS[@]}"
        echo "Valid distarchs are:"
        echo " ${DISTARCHS[@]}"
        echo "Valid distrosnames are:"
        echo " ${DISTROS[@]}"
    fi
}

## parameters: 1: mount dev name, 2: rootfs file tag, 3: board name, 4: distroname, 5: user name
assemble_full_sd_img() {
    contains ${BOARDS[@]} ${3}
    if [ "$?" -eq 0 ]; then
        echo "Valid boardname = ${3} given"
        contains ${DISTROS[@]} ${4}
        if [ "$?" -eq 0 ]; then
            echo "Valid distroname = ${4} given"
            contains ${USERS[@]} ${5}
            if [ "$?" -eq 0 ]; then
                echo "Valid user name = ${5} given"
                if [ "${3}" == "ultra96v1" ] || [ "${3}" == "fz3" ] || [ "${3}" == "ultramyir" ] || [ "${3}" == "k26-stkit" ]; then
                    SD_KERNEL_VERSION=${XIL_GIT_KERNEL_TAG}
                else
                    SD_KERNEL_VERSION=${ALT_GIT_KERNEL_TAG}
                fi
                SD_FILE_PRELUDE="${4}_${5}_${SD_KERNEL_VERSION}-${3}"
                if [ "${DESKTOP}" == "yes" ]; then
                    SD_IMG_NAME="${SD_FILE_PRELUDE}_desktop_sd_${REL_DATE}"
                else
                    SD_IMG_NAME="${SD_FILE_PRELUDE}_console_sd_${REL_DATE}"
                fi
                SD_IMG_FILE="${CURRENT_DIR}/socfpga_${SD_IMG_NAME}.img"

                echo "MSG: step 1 create ${SD_IMG_FILE}"
                if [ "${3}" == "ultra96v1" ] || [ "${3}" == "fz3" ] || [ "${3}" == "ultramyir" ] || [ "${3}" == "k26-stkit" ]; then
                    echo "Script_MSG: Arm64 mpsoc detected"
                    echo ""
                    create_img "2" "${SD_IMG_FILE}" "${1}" "p2" "1"
                    mount_sd_imagefile ${SD_IMG_FILE} ${1} p1
                    echo "Copying files to boot partition"
                    if [ "${4}" == "petalinux" ]; then
                        sudo cp ${XIL_BOOT_FILES_LOC}/peta_built/images/linux/BOOT.BIN ${1}
                        sudo cp ${XIL_BOOT_FILES_LOC}/peta_built/images/linux/image.ub ${1}
                    else
                        if [ "${3}" == "ultra96v1" ]; then
                            wget ${HolosynthV_URL}/VivadoProjects/Avnet/ultra96v1-holosynthv-2020.2.2.tar.bz2 -O board.tar.bz2                            
                        elif [ "${3}" == "fz3" ]; then
                            wget ${HolosynthV_URL}/VivadoProjects/Myirtech/fz3/fz3-holosynthv-2020.2.tar.bz2 -O board.tar.bz2
                        elif [ "${3}" == "ultramyir" ]; then
                            wget ${HolosynthV_URL}/VivadoProjects/Myirtech/ultramyir/ultramyir-holosynthv-2020.2.2.tar.bz2 -O board.tar.bz2
                        elif [ "${3}" == "k26-stkit" ]; then
                            wget ${HolosynthV_URL}/VivadoProjects/Xilinx/k26-stkit/k26-stkit-holosynthv-2020.2.2.tar.bz2 -O board.tar.bz2
                        fi
                        tar xfS board.tar.bz2 "${3}-holosynthv-2020.2.2"/pre-built/linux/images --use-compress-program lbzip2 --strip-components 3
                        sudo cp images/* ${1}
#                        sudo cp ${XIL_BOOT_FILES_LOC}/image.ub ${1}
                    fi
                    echo "MSG: Unmounting boot partition"
                    unmount_binded ${1}
                    unmount_loopdev
                    echo "MSG: mounting rootfs partition"
                    mount_sd_imagefile ${SD_IMG_FILE} ${1} p2
                    echo "MSG: Extracting to rootfs partition"
                    if [ "${4}" == "petalinux" ]; then
                        sudo tar xfS ${XIL_BOOT_FILES_LOC}/peta_built/images/linux/rootfs.tar.bz2 -C ${1} --use-compress-program lbzip2
                    else
                        if [ "${DESKTOP}" == "yes" ]; then
#                            extract_rootfs ${CURRENT_DIR} ${1} "arm64_${5}_finalized-desktop_with-kernel" ${4}
                            extract_rootfs ${CURRENT_DIR} ${1} "arm64_${5}_finalized-desktop" ${4}
                        else
#                            extract_rootfs ${CURRENT_DIR} ${1} "arm64_${5}_finalized_with-kernel" ${4}
                            extract_rootfs ${CURRENT_DIR} ${1} "arm64_${5}_finalized" ${4}
                        fi
                    fi
                    bind_mounted ${1}
                    sudo sync
                    sudo rm -f ${1}/etc/resolv.conf
                    sudo cp /etc/resolv.conf ${1}/etc/resolv.conf
                    sudo cp -f ${1}/etc/apt/sources.list-local ${1}/etc/apt/sources.list
                    sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y update'
                    sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y autoremove'
                    sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y upgrade'
                    sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install dialog'
                    sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install --reinstall libc6-dev'
                    sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /bin/rm -f /etc/resolv.conf'
                    sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /bin/ln -s /run/systemd/resolve/resolv.conf  /etc/resolv.conf'
                    sudo cp -f ${1}/etc/apt/sources.list-final ${1}/etc/apt/sources.list
                    sudo cp -R ${MAIN_SCRIPT_DIR}/Auto-expand-on-boot/* ${1}
                    sudo ln -s ${1}/lib/systemd/system/resize2fs.service ${1}/${EnableResize2fsLink}
                    echo ""
                    echo "# --------->       Removing qemu policy file          <--------------- ---------"
                    echo ""

                    if [ -f ${POLICY_FILE} ]; then
                        echo "removing ${POLICY_FILE}"
                        sudo rm -f ${POLICY_FILE}
                    fi
                    unmount_binded ${1}
                    unmount_loopdev
                else
                    create_img "3" "${SD_IMG_FILE}" "${1}" "${media_rootfs_partition}"
                    echo "MSG: step 2 mount:"
                    mount_sd_imagefile ${SD_IMG_FILE} ${1} ${media_rootfs_partition}
                    if [ "${DESKTOP}" == "yes" ]; then
                        extract_rootfs ${CURRENT_DIR} ${1} "armhf_${5}_finalized-desktop_with-kernel" ${4}
                    else
                        extract_rootfs ${CURRENT_DIR} ${1} "armhf_${5}_finalized_with-kernel" ${4}
                    fi
                    bind_mounted ${1}
                    sudo sync
                    sudo rm -f ${1}/etc/resolv.conf
                    sudo cp /etc/resolv.conf ${1}/etc/resolv.conf
                    sudo cp -f ${1}/etc/apt/sources.list-local ${1}/etc/apt/sources.list
                    sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y update'
                    sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y autoremove'
                    sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y upgrade'
                    sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install dialog'
                    sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install --reinstall libc6-dev'
                    sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /bin/rm -f /etc/resolv.conf'
                    sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /bin/ln -s /run/systemd/resolve/resolv.conf  /etc/resolv.conf'
                    sudo cp -f ${1}/etc/apt/sources.list-final ${1}/etc/apt/sources.list
                    sudo cp -R ${MAIN_SCRIPT_DIR}/Auto-expand-on-boot/* ${1}
                    sudo ln -s ${1}/lib/systemd/system/resize2fs.service ${1}/${EnableResize2fsLink}
                    set_fw_uboot_env_mnt ${LOOP_DEV} ${1}
                    if [ -f ${POLICY_FILE} ]; then
                        echo ""
                        echo "# --------->       Removing qemu policy file          <--------------- ---------"
                        echo ""
                        echo "removing ${POLICY_FILE}"
                        sudo rm -f ${POLICY_FILE}
                    fi
                    unmount_binded ${1}
                    unmount_loopdev
                    install_uboot "${UBOOT_BUILD_DIR}" "${UBOOT_IMG_FILENAME}" "${SD_IMG_FILE}"
                fi
                echo ""
                echo "# --------->       Running final steps:               <--------------- ---------"
                echo ""
                make_bmap_image ${CURRENT_DIR} "socfpga_${SD_IMG_NAME}.img"
                echo "Script_MSG: finished assemble_full_sd_img_${3}-${4}-${5} with success ... !"
                echo ""
                echo "# --------->         SD Imaging Completed             <--------------- ---------"
                echo ""
                echo "Script_MSG: Image is now completely built and ready for distribution ... !"
            else
                echo "--assemble_full_sd_img= bad argument --> ${5}"
                echo "Use =boardname=distroname=username"
                echo "wrong user name"
                echo "Valid user names are:"
                echo " ${USERS[@]}"
            fi
        else
            echo "--assemble_full_sd_img= bad argument --> ${4}"
            echo "Use =boardname=distroname=username"
            echo "wrong distro name"
            echo "Valid distrosnames are:"
            echo " ${DISTROS[@]}"
        fi
    else
        echo "--assemble_full_sd_img= bad argument --> ${3}"
        echo "Use =boardname=distroname=username"
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
    VALUE1=`echo $1 | awk -F= '{print $2}'`
    VALUE2=`echo $1 | awk -F= '{print $3}'`
    VALUE3=`echo $1 | awk -F= '{print $4}'`
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
            build_uboot "${VALUE1}"
            ;;
        --build_git-kernel)
            contains ${DISTROS[@]} ${VALUE1}
            if [ "$?" -eq 0 ]; then
                echo "Valid distarch = ${VALUE1} given"
                build_git_kernel "${VALUE2}" "${VALUE1}"
            else
                echo "--gitkernel2repo bad argument --> ${VALUE1}"
                echo "Use =distroname=boardname"
                echo "Valid distonames are:"
                echo " ${DISTROS[@]}"
            fi
            ;;
        --gitkernel2repo)
#            set -x
            contains ${DISTARCHS[@]} ${VALUE2}
            if [ "$?" -eq 0 ]; then
                echo "Valid distarch = ${VALUE2} given"
                if [ ""${VALUE2}"" = "arm64" ]; then
                    ## parameters: 1: distro name, 2: dir, 3: dist arch, 4: file filter
                    add2repo "${VALUE1}" ${XIL_GIT_KERNEL_PARENT_DIR} "${VALUE2}" "linux-"
                else
                    ## parameters: 1: distro name, 2: dir, 3: dist arch, 4: file filter
                    add2repo "${VALUE1}" ${ALT_GIT_KERNEL_PARENT_DIR} "${VALUE2}" "linux-"
                fi
            else
                echo "--gitkernel2repo bad argument --> ${VALUE2}"
                echo "Use =distroname=distarch"
                echo "Valid distarchs are:"
                echo " ${DISTARCHS[@]}"
            fi
            ;;
        --mk2repo)
            ## parameters: 1: distro name, 2: dir, 3: dist arch, 4: file filter
            add2repo "${VALUE1}" "/home/mib/Development/Docker" "${VALUE2}" "machinekit"
            ;;
        --cadence2repo)
            ## parameters: 1: distro name, 2: dir, 3: dist arch, 4: file filter
            if [ "${VALUE1}" == "bionic" ]; then
                add2repo "${VALUE1}" "/home/mib/Development/Deb-Pkg/Bionic/Cadence" "${VALUE2}" "cadence|claudia|catia|catarina"
            else
                add2repo "${VALUE1}" "/home/mib/Development/Deb-Pkg/Cadence" "${VALUE2}" "cadence|claudia|catia|catarina"
            fi
            ;;
        --carla2repo)
            ## parameters: 1: distro name, 2: dir, 3: dist arch, 4: file filter
            if [ "${VALUE1}" == "bionic" ]; then
                add2repo "${VALUE1}" "/home/mib/Development/Deb-Pkg/Bionic/Carla" "${VALUE2}" "fttw3|libjpeg|liblo|libpng|mxml|zlib|pixman|ntk|libogg|libvorbis|flac|sndfile|fluidsynth|gig|linuxsampler-static|carla"
            else
                add2repo "${VALUE1}" "/home/mib/Development/Deb-Pkg/Buster/Carla" "${VALUE2}" "fttw3|libjpeg|liblo|libpng|mxml|zlib|pixman|ntk|libogg|libvorbis|flac|sndfile|fluidsynth|gig|linuxsampler-static|carla"
            fi
             ;;
        --lv22repo)
            ## parameters: 1: distro name, 2: dir, 3: dist arch, 4: file filter
            if [ "${VALUE1}" == "bionic" ]; then
                add2repo "${VALUE1}" "/home/mib/Development/Deb-Pkg/Bionic/Lv2-plugins" "${VALUE2}" "vs2sdk|sqlite3-static|linuxsampler-lv2|linuxsampler-dssi|linuxsampler-vst|hexter|premake"
            else
                add2repo "${VALUE1}" "/home/mib/Development/Deb-Pkg/Buster/Lv2-plugins" "${VALUE2}" "vs2sdk|sqlite3-static|linuxsampler-lv2|linuxsampler-dssi|linuxsampler-vst"
            fi
             ;;
        --jackd22repo)
            ## parameters: 1: distro name, 2: dir, 3: dist arch, 4: file filter
            if [ "${VALUE1}" == "bionic" ]; then
                add2repo "${VALUE1}" "/home/mib/Development/Deb-Pkg/Bionic/Jackd2" "${VALUE2}" "libopus-custom-static|jackd2|ardour"
            else
                add2repo "${VALUE1}" "/home/mib/Development/Deb-Pkg/Buster/Jackd2" "${VALUE2}" ""
            fi
             ;;
        --hikey2repo)
            ## parameters: 1: distro name, 2: dir, 3: dist arch, 4: file filter
            if [ "${VALUE1}" == "stretch" ]; then
                add2repo "${VALUE1}" "/home/mib/Development/Deb-Pkg/Stretch/Hikey" "${VALUE2}" "hikey"
            else
                add2repo "${VALUE1}" "/home/mib/Development/Deb-Pkg/Buster/Jackd2" "${VALUE2}" ""
            fi
             ;;
        --dexed2repo)
            ## parameters: 1: distro name, 2: dir, 3: dist arch, 4: file filter
            if [ "${VALUE1}" == "bionic" ]; then
                add2repo "${VALUE1}" "/home/mib/Development/Deb-Pkg/Bionic/Dexed" "${VALUE2}" "kxstudio3"
            else
                add2repo "${VALUE1}" "/home/mib/Development/Deb-Pkg/Buster/Dexed" "${VALUE2}" ""
            fi
             ;;
       --xf86-video-armsoc2repo)
            ## parameters: 1: distro name, 2: dir, 3: dist arch, 4: file filter
            add2repo "${VALUE1}" "/home/mib/Development/Deb-Pkg/armsoc_debs" "${VALUE2}" "xserver-xorg-video-armsoc"
            ;;
        --gen-base-rootfs)
            ## parameters: 1: mount dev name, 2: image name, 3: distro name, 4: distro arch
            gen_rootfs_image ${ROOTFS_MNT} "${VALUE1}" "${VALUE2}" | tee ${CURRENT_DIR}/Logs/gen-base_rootfs-log.txt
            ;;
        --gen-base-rootfs-desktop)
            DESKTOP="yes"
            ## parameters: 1: mount dev name, 2: image name, 3: distro name, 4: distro arch
            gen_rootfs_image ${ROOTFS_MNT} "${VALUE1}" "${VALUE2}" | tee ${CURRENT_DIR}/Logs/gen-base_rootfs-log.txt
            ;;
       --finalize-rootfs)
            finalize_rootfs_image ${ROOTFS_MNT} "${VALUE1}" "${VALUE2}" "${VALUE3}" | tee ${CURRENT_DIR}/Logs/finalize_rootfs-log.txt
            ## parameters: 1: mount dev name, 2: image name, 3: distro name, 4: distro arch, 5: user name
            ;;
        --finalize-desktop-rootfs)
            DESKTOP="yes"
            finalize_rootfs_image ${ROOTFS_MNT} "${VALUE1}" "${VALUE2}" "${VALUE3}" | tee ${CURRENT_DIR}/Logs/finalize_rootfs-log.txt
            ## parameters: 1: mount dev name, 2: image name, 3: distro name, 4: distro arch, 5: user name
            ;;
        --inst_repo_kernel)sudo losetup -d
            inst_repo_kernel ${ROOTFS_MNT} "${VALUE1}" "${VALUE2}" "${VALUE3}"
            ## parameters: 1: mount dev name, 2: bzipname end, 3: rootfs image path, 4: distroname, 5: distro arch, 6: user name
            ;;
        --inst_repo_kernel-desktop)
            DESKTOP="yes"
            inst_repo_kernel ${ROOTFS_MNT} "${VALUE1}" "${VALUE2}" "${VALUE3}"
            ## parameters: 1: mount dev name, 2: bzipname end, 3: rootfs image path, 4: distroname, 5: distro arch, 6: user name
           ;;
        --inst_hs_aud_stuff)
            if [ "$(ls -A ${ROOTFS_MNT})" ]; then
                echo "Script_MSG: !! Found ${ROOTFS_MNT} mounted .. will unmount now"
                unmount_binded ${ROOTFS_MNT}
            fi
            create_img "1" rootfs.img
            mount_imagefile rootfs.img ${ROOTFS_MNT}
            bind_mounted ${ROOTFS_MNT}
            extract_rootfs ${CURRENT_DIR} ${ROOTFS_MNT} "${USER_NAME}_finalized-with-kernel-and-desktop"
            mkdir -p ${CURRENT_DIR}/Qt_logs
            inst_cadence ${ROOTFS_MNT} 2>&1| tee ${CURRENT_DIR}/Qt_logs/install_cadence-log.txt
            compress_rootfs ${CURRENT_DIR} ${ROOTFS_MNT} "${USER_NAME}_finalized-with-kernel-and-desktop-and-qt-deps"
            unmount_binded ${ROOTFS_MNT}
            ;;
        --bindmount_rootfsimg)
            mount_imagefile rootfs.img ${ROOTFS_MNT}
            bind_mounted ${ROOTFS_MNT}
            ;;
        --bindunmount_rootfsimg)
            unmount_binded ${ROOTFS_MNT}
            ;;
        --assemble_sd_img)
            assemble_full_sd_img ${ROOTFS_MNT} "finalized-with-kernel" "${VALUE1}" "${VALUE2}" "${VALUE3}"
            ;;
        --assemble_desktop_sd_img)
            DESKTOP="yes"
            assemble_full_sd_img ${ROOTFS_MNT} "finalized-with-kernel-and-desktop" "${VALUE1}" "${VALUE2}" "${VALUE3}"
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

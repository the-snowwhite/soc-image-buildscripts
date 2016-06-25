#!/bin/bash

# Script to build u-boot + preloader for Altera Soc Platform (Only Nano / Atlas board initially)
# usage: build_uboot.sh <builddir path>
#------------------------------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------------------------------
CURRENT_DIR=`pwd`
WORK_DIR=${1}

SCRIPT_ROOT_DIR=${2}
UBOOT_VERSION=${3}
BOARD=${4}
UBOOT_BOARD=${5}
MAKE_CONFIG=${6}

CC_FOLDER_NAME=${7}
PATCH=${8}

#UBOOT_VERSION='v2015.10'
#UBOOT_VERSION='v2016.01'
CHKOUT_OPTIONS=''
#CHKOUT_OPTIONS='-b tmp'

BOARD_CONFIG="socfpga_${UBOOT_BOARD}_defconfig"


# 2016.0X patches:
PATCH_FILE=patches/"u-boot-${UBOOT_VERSION}-${BOARD}-changeset.patch"

UBOOT_DIR=${WORK_DIR}/uboot

#-------------------------------------------
# u-boot, toolchain, imagegen vars
#-------------------------------------------
#--------- altera socfpga kernel --------------------------------------#

#--------- Toolchain  -------------------------------------------------#

CC_DIR="${WORK_DIR}/${CC_FOLDER_NAME}"

CC="${CC_DIR}/bin/arm-linux-gnueabihf-"

#----------------------------------------------------------------------#


NCORES=`nproc`

patch_uboot() {
if [ ! -z "$PATCH" ]; then
	echo "MGG: Applying u-boot patch ${PATCH_FILE}"
	cd $UBOOT_DIR
	git am --signoff <  $SCRIPT_ROOT_DIR/$PATCH_FILE
else
	echo "MSG: No u-boot patch applied"
fi
}

fetch_uboot() {
if [ ! -d ${UBOOT_DIR} ]; then
    echo "MSG: cloning u-boot"
    git clone git://git.denx.de/u-boot.git uboot
fi

cd $UBOOT_DIR
if [ ! -z "$UBOOT_VERSION" ]
then
    git fetch origin
    git reset --hard origin/master
    echo "MSG: Will now check out " $UBOOT_VERSION
    git checkout $UBOOT_VERSION $CHKOUT_OPTIONS
    echo "MSG: Will now apply patch: " $SCRIPT_ROOT_DIR/$PATCH_FILE
    patch_uboot
fi
cd ..
}

install_sid_armhf_crosstoolchain() {
sudo dpkg --add-architecture armhf
sudo apt-get update

#sudo apt-get install crossbuild-essential-armhf
#sudo apt-get install gcc-arm-linux-gnueabihf

sudo apt-get install gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf libc6-dev debconf dpkg-dev libconfig-auto-perl file libfile-homedir-perl libfile-temp-perl liblocale-gettext-perl perl binutils-multiarch fakeroot

}

build_uboot() {
cd $UBOOT_DIR
# compile u-boot + spl
export ARCH=arm
export PATH=$CC_DIR/bin/:$PATH
export CROSS_COMPILE=$CC

echo "MSG: configuring u-boot"
make mrproper
make $BOARD_CONFIG
echo "MSG: compiling u-boot"
make $MAKE_CONFIG -j$NCORES
}

# run functions
echo "#---------------------------------------------------------------------------------- "
echo "#-------------+++      build_uboot.sh Start      +++------------------------------- "
echo "#---------------------------------------------------------------------------------- "

set -e

if [ ! -z "$WORK_DIR" ]; then
    cd $WORK_DIR
    fetch_uboot

    build_uboot
else
    echo "no workdir parameter given"
    echo "usage: build_uboot.sh <builddir path>"
fi
echo "#---------------------------------------------------------------------------------- "
echo "#-------------+++      build_uboot.sh End      +++--------------------------------- "
echo "#---------------------------------------------------------------------------------- "



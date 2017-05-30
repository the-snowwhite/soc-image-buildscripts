#!/bin/bash

# Script to build u-boot + preloader for Altera Soc Platform (Only Nano / Atlas board initially)
# usage: build_uboot.sh <builddir path>
#------------------------------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------------------------------

#UBOOT_CHKOUT_OPTIONS=''
UBOOT_CHKOUT_OPTIONS='-b tmp'
UBOOT_BOARD_CONFIG="socfpga_${UBOOT_BOARD}_defconfig"

# 2016.0X patches:
UBOOT_PATCH_FILE=${PATCH_DIR}/"u-boot-${UBOOT_VERSION}-${BOARD}-changeset.patch"

UBOOT_DIR=${CURRENT_DIR}/uboot

#----------------------------------------------------------------------#

patch_uboot() {
if [[ ${APPLY_UBOOT_PATCH} == 'yes' ]]; then
	echo "MGG: Applying u-boot patch ${UBOOT_PATCH_FILE}"
	cd $UBOOT_DIR
	git am --signoff <  ${MAIN_SCRIPT_ROOT_DIR}/${UBOOT_PATCH_FILE}
else
	echo "MSG: No u-boot patch applied"
fi
}

build_uboot() {
cd $UBOOT_DIR
# compile u-boot + spl
export ARCH=arm
export PATH=$CC_DIR/bin/:$PATH
export CROSS_COMPILE=$CC

echo "MSG: configuring u-boot"
make mrproper
make $UBOOT_BOARD_CONFIG
echo "MSG: compiling u-boot"
make $UBOOT_MAKE_CONFIG -j$NCORES
}

# run functions
echo "#---------------------------------------------------------------------------------- "
echo "#-------------+++      build_uboot.sh Start      +++------------------------------- "
echo "#---------------------------------------------------------------------------------- "

set -e

if [ ! -z "$CURRENT_DIR" ]; then
    cd $CURRENT_DIR
    fetch_uboot

    build_uboot
else
    echo "no workdir parameter given"
    echo "usage: build_uboot.sh <builddir path>"
fi
echo "#---------------------------------------------------------------------------------- "
echo "#-------------+++      build_uboot.sh End      +++--------------------------------- "
echo "#---------------------------------------------------------------------------------- "



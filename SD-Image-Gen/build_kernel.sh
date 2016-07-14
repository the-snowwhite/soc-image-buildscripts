#!/bin/bash

#------------------------------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------------------------------
CURRENT_DIR=`pwd`
WORK_DIR=${1}
SCRIPT_ROOT_DIR=${2}
CC_FOLDER_NAME=${3}
CC_URL=${4}
KERNEL_FOLDER_NAME=${5}
KERNEL_URL=${6}
KERNEL_BRANCH=${7}
KERNEL_VERSION=${8}
PATCH_URL=${9}

echo "NOTE: in build_kernel.sh param KERNEL_FOLDER_NAME = ${5}"
echo "NOTE: KERNEL_URL = ${6}"
echo "NOTE: KERNEL_BRANCH = ${7}"
echo "NOTE: KERNEL_VERSION = ${8}"
echo "NOTE: PATCH_URL = ${9}"

KERNEL_EX_FOLDER=linux-${KERNEL_VERSION}

KERNEL_FILE=${KERNEL_EX_FOLDER}.tar.xz

PATCH_FILE=patches/"patch-${KERNEL_FOLDER_NAME}.patch.xz"

ALT_SOC_KERNEL_PATCH_FILE=patches//${KERNEL_FOLDER_NAME}-changeset.patch

#-------------- all kernel ----------------------------------------------------------------#

# mksoc uio kernel driver module filder:
MK_KERNEL_DRIVER_FOLDER=${SCRIPT_ROOT_DIR}/../../SW/MK/kernel-drivers
UIO_DIR=${MK_KERNEL_DRIVER_FOLDER}/hm2reg_uio-module
#ADC_DIR=${MK_KERNEL_DRIVER_FOLDER}/hm2adc_uio-module
ADC_DIR=${MK_KERNEL_DRIVER_FOLDER}/adcreg



# --- config end ------------------------------#


CC_DIR="${WORK_DIR}/${CC_FOLDER_NAME}"
CC_FILE="${CC_FOLDER_NAME}.tar.xz"
CC="${CC_DIR}/bin/arm-linux-gnueabihf-"

KERNEL_CONF='socfpga_defconfig'

#----------------------------------------------------------------------#
#----------------------------------------------------------------------#
#----------------------------------------------------------------------#


IMG_FILE=${WORK_DIR}/mksoc_sdcard.img
DRIVE=/dev/loop0

KERNEL_PARENT_DIR=${WORK_DIR}/arm-linux-${KERNEL_FOLDER_NAME}-gnueabifh-kernel
KERNEL_BUILD_DIR=${KERNEL_PARENT_DIR}/linux

NCORES=`nproc`

extract_toolchain() {
#    if hash lbzip2 2>/dev/null; then
#        echo "lbzip2 found"
#        tar --use=lbzip2 -xf ${CC_FILE}
#    else
#        echo "lbzip2 not found using tar simglecore extract"
        echo "using tar for xz extract"
        tar xf ${CC_FILE}
#    fi
}

get_toolchain() {
# download linaro cross compiler toolchain

if [ ! -d ${CC_DIR} ]; then
    if [ ! -f ${CC_FILE} ]; then
        echo "downloading toolchain"
    	wget -c ${CC_URL}
    fi
# extract linaro cross compiler toolchain
# uses multicore extract (lbzip2) if available
    echo "extracting toolchain"
    extract_toolchain
fi
}

uiomod_kernel() {
#cd ${KERNEL_BUILD_DIR}
#Uio Config additions:
cat <<EOT >> ${KERNEL_BUILD_DIR}/arch/arm/configs/${KERNEL_CONF}
CONFIG_UIO=y
CONFIG_UIO_PDRV=y
CONFIG_UIO_PDRV_GENIRQ=y
CONFIG_IP_ADVANCED_ROUTER=y
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_HOTPLUG=y
CONFIG_INOTIFY_USER=y
CONFIG_PROC_FS=y
CONFIG_SIGNALFD=y
CONFIG_SYSFS=y
CONFIG_SYSFS_DEPRECATED=n
CONFIG_AUTOFS4_FS=m
CONFIG_AUDIT=n
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_FW_LOADER_USER_HELPER=n
CONFIG_TIMERFD=y
CONFIG_EPOLL=y
CONFIG_NET_NS=y
CONFIG_PREEMPT_RT=y
CONFIG_PREEMPT_RT_FULL=y
CONFIG_MARVELL_PHY=y
CONFIG_FHANDLE=y
CONFIG_LBDAF=y
CONFIG_EXT4_FS_XATTR=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
CONFIG_OF_OVERLAY=y
CONFIG_GPIO_ALTERA=m
#CONFIG_GPIO_A10SYCON=y
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
CONFIG_LEDS_GPIO=y
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=y
CONFIG_LEDS_TRIGGER_CPU=y
CONFIG_CFS_BANDWIDTH=y
CONFIG_CGROUPS=y
CONFIG_DEVPTS_MULTIPLE_INSTANCES=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_RT_GROUP_SCHED=y
EOT
echo "Kernel UIO Patch added"
echo "config file mods applied"

cp ${SCRIPT_ROOT_DIR}/socfpga.dtsi ${KERNEL_BUILD_DIR}/arch/arm/boot/dts

}

patch_git_kernel() {
cd ${KERNEL_BUILD_DIR}
git am --signoff <  ${SCRIPT_ROOT_DIR}/${ALT_SOC_KERNEL_PATCH_FILE}
}

clone_kernel() {
    if [ -d ${KERNEL_PARENT_DIR} ]; then
        echo the kernel target directory ${KERNEL_PARENT_DIR} already exists.
        echo cleaning repo
        cd ${KERNEL_PARENT_DIR}/linux
        git clean -d -f -x
        git fetch origin
        git reset --hard origin/${KERNEL_BRANCH}
    else
        mkdir -p ${KERNEL_PARENT_DIR}
        cd ${KERNEL_PARENT_DIR}
        git clone ${KERNEL_URL} linux
        cd linux
        git remote add linux ${KERNEL_URL}
        git fetch linux
        git checkout -b linux-rt linux/${KERNEL_BRANCH}
    fi
cd ..
}

fetch_kernel() {
    if [ -d ${KERNEL_PARENT_DIR} ]; then
        echo the kernel target directory $KERNEL_PARENT_DIR already exists.
        echo reinstalling file
        cd ${KERNEL_PARENT_DIR}
        echo "deleting kernel folder"
        sudo rm -Rf linux
    else
        echo "creating ${KERNEL_PARENT_DIR}"
        mkdir -p ${KERNEL_PARENT_DIR}
        cd ${KERNEL_PARENT_DIR}
    fi
    if [ ! -f ${KERNEL_FILE} ]; then
        echo "fetching kernel"
        wget ${KERNEL_URL}
    fi
    echo "extracting kernel"
    tar xf ${KERNEL_FILE}
    mv ${KERNEL_EX_FOLDER} linux
}


patch_kernel() {
cd ${KERNEL_PARENT_DIR}
if [ ! -f ${PATCH_FILE} ]; then #if file with that name not exists
        echo "fetching patch"
        wget ${PATCH_URL}
fi
cd ${KERNEL_BUILD_DIR}
xzcat ../${PATCH_FILE} | patch -p1
echo "rt-Patch applied"
#Uio Patch:
uiomod_kernel
}

gen_makefile() {
rm -f Makefile
sh -c 'cat <<EOT >Makefile
#!/bin/bash

KERNEL_SRC_DIR='${KERNEL_BUILD_DIR}'
CURDIR=\$(shell pwd)
CROSS_C  ?= '${CC}'
ARCH=arm

OUT_DIR =\$(KERNEL_SRC_DIR)

//NCORES=`nproc`
NCORES=1


#LINUX_VARIABLES = PATH=\$(PATH)
LINUX_VARIABLES = ARCH=\$(ARCH)
ifneq ("\$(KBUILD_BUILD_VERSION)","")
        LINUX_VARIABLES += KBUILD_BUILD_VERSION="\$(KBUILD_BUILD_VERSION)"
endif
LINUX_VARIABLES += CROSS_COMPILE=\$(CROSS_C)

#ifneq ("\$(DEVICETREE_SRC)","")
#       LINUX_VARIABLES += CONFIG_DTB_SOURCE=\$(DEVICETREE_SRC)
#endif
#LINUX_VARIABLES += INSTALL_MOD_PATH=\$(INSTALL_MOD_PATH)


ifndef OUT_DIR
    \$(error OUT_DIR is undefined, bad environment, you point OUT_DIR to the linux kernel build output directory)
endif

KDIR ?= \$(OUT_DIR)

default:
	\$(MAKE) -j\$(NCORES) \$(LINUX_VARIABLES) -C \$(KDIR) M=\$(CURDIR)

clean:
	\$(MAKE) -C \$(KDIR) \$(LINUX_VARIABLES) M=\$(CURDIR) clean

help:
	\$(MAKE) -C \$(KDIR) \$(LINUX_VARIABLES) M=\$(CURDIR) help

modules:
	\$(MAKE) -j\$(NCORES) \$(LINUX_VARIABLES) -C \$(KDIR) M=\$(CURDIR) modules

modules_install:
	\$(MAKE) -C \$(KDIR) \$(LINUX_VARIABLES) M=\$(CURDIR) modules_install

EOT'
cat <<EOT > Kbuild
obj-m := ${CFG_BUILD}.o
EOT
}

build_cfg() {

cd ${WORK_DIR}
if [ -d ${WORK_DIR}/${CFG_BUILD} ]; then
    echo the kernel target directory ${WORK_DIR}/${CFG_BUILD} already exists.
    echo making clean
    cd ${WORK_DIR}/${CFG_BUILD}
    gen_makefile
    make clean
else
    echo "cloning ${CFG_BUILD}"
    git clone https://github.com/ikwzm/${CFG_BUILD}.git
   cd ${WORK_DIR}/${CFG_BUILD}
   gen_makefile
fi

make -j${NCORES} ARCH=arm CROSS_COMPILE=${CC} -C ${KERNEL_BUILD_DIR} M=${WORK_DIR}/${CFG_BUILD}  modules 2>&1 | tee ../${CFG_BUILD}-module_rt-log.txt
}

build_kernel() {

set -v

export CROSS_COMPILE=${CC}
export KBUILD_DEBARCH=armhf

cd ${KERNEL_BUILD_DIR}

#clean
make -j${NCORES} mrproper
#make distclean

#chmod a+x scripts/*
#chmod a+x debian/scripts/misc/*
#fakeroot rules clean
#fakeroot debian/rules editconfigs

# configure
#make ARCH=arm CROSS_COMPILE=${CC} ${KERNEL_CONF} 2>&1 | tee ../linux-config_rt-log.txt
#make ${KERNEL_CONF} 2>&1 | tee ../linux-config_rt-log.txt

# # zImage:
# make -j${NCORES} ARCH=arm CROSS_COMPILE=${CC} 2>&1 | tee ../linux-make_rt-log_.txt
# #make -j${NCORES} 2>&1 | tee ../linux-make_rt-log_.txt
# 
# # modules:
# make -j${NCORES} ARCH=arm CROSS_COMPILE=${CC} modules 2>&1 | tee ../linux-modules_rt-log.txt
# #make -j${NCORES} modules 2>&1 | tee ../linux-modules_rt-log.txt
# 
# # uio hm2_soc module:
# #make -j${NCORES} ARCH=arm CROSS_COMPILE=${CC} -C ${KERNEL_BUILD_DIR} M=${UIO_DIR}  modules 2>&1 | tee ../linux-uio-hm2_soc-module_rt-log.txt
# 
# # adc module:
# #make -j${NCORES} ARCH=arm -C ${KERNEL_BUILD_DIR} M=${ADC_DIR}  modules 2>&1 | tee ../linux-adcreg-module_rt-log.txt
# 
# # headers:
# make -j${NCORES} ARCH=arm  headers_check 2>&1 | tee ../linux-headers_rt-log.txt
# 
# # deb:
# #make -j${NCORES} NAME="Michael Brown" EMAIL="producer@holotronic.dk" ARCH=arm LOCALVERSION=-socfpga KDEB_PKGVERSION=$(make kernelversion)-3 KBUILD_IMAGE=uImage deb-pkg 2>&1 | tee ../deb_rt-log.txt

make -j${NCORES} CROSS_COMPILE=${CC} ${KERNEL_CONF} NAME="Michael Brown" EMAIL="producer@holotronic.dk" ARCH=arm LOCALVERSION=-socfpga KDEB_PKGVERSION=$(make kernelversion)-0.1 deb-pkg 2>&1 | tee ../deb_rt-log.txt

#make NAME="Michael Brown" EMAIL="producer@holotronic.dk" ARCH=arm LOCALVERSION=-socfpga-iscsi KDEB_PKGVERSION=$(make kernelversion)-0.4 deb-pkg 2>&1 | tee ../deb_rt-log.txt
#
#	The following packages will be REMOVED:
#	  linux-headers-4.1.17-ltsi-rt17-socfpga-iscsi-02568-g1faf95c* linux-image-4.1.17-ltsi-rt17-socfpga-iscsi-02568-g1faf95c*
#	Removing linux-headers-4.1.17-ltsi-rt17-socfpga-iscsi-02568-g1faf95c (4.1.17-ltsi-2) ...
# 	Removing linux-image-4.1.17-ltsi-rt17-socfpga-iscsi-02568-g1faf95c (4.1.17-ltsi-2) ...
# 	update-initramfs: Deleting /boot/initrd.img-4.1.17-ltsi-rt17-socfpga-iscsi-02568-g1faf95c
# 	Purging configuration files for linux-image-4.1.17-ltsi-rt17-socfpga-iscsi-02568-g1faf95c (4.1.17-ltsi-2) ...
#

#dtboconfig:

# CFG_BUILD=dtbocfg
# build_cfg

#fpgaconfig:

# CFG_BUILD=fpgacfg
# build_cfg

}

echo "#---------------------------------------------------------------------------------- "
echo "#-------------------+++        build_kernel.sh Start        +++-------------------- "
echo "#---------------------------------------------------------------------------------- "

set -e

if [ ! -z "${WORK_DIR}" ]; then
   if [ ! -d ${CC_DIR} ]; then
      echo "fetching / extracting toolchain"
      get_toolchain
   fi

   if [ ! -z "${PATCH_URL}" ]; then
      echo "MSG: building rt-Patched kernel"
      fetch_kernel
      echo "Applying patch"
      patch_kernel
   else
      echo "MSG: building git cloned kernel"
      echo "cloning kernel"
      clone_kernel
      patch_git_kernel
   fi
   echo "building kernel"
   build_kernel
   echo "#---------------------------------------------------------------------------------- "
   echo "#--------+++       build_kernel.sh Finished Successfull      +++------------------- "
   echo "#---------------------------------------------------------------------------------- "

else
   echo "#---------------------------------------------------------------------------------- "
   echo "#-------------    build_kernel.sh  Unsuccessfull     ------------------------------ "
   echo "#-------------    workdir parameter missing    ------------------------------------ "
   echo "#---------------------------------------------------------------------------------- "
fi


#!/bin/bash

# Working Invokes selected scripts in same folder that generates a working armhf Debian Jessie or Stretch/sid sd-card-image().img
# base kernel is the 3.13-rt-ltsi kernel from the alterasoc repo
# ongoing work is done to get the 4.4.4-rt mainline kernel to function properly.
#
# !!! warning while using the script to generate u-boot, kernels and sd-image
# the (qemu)rootfs generation can be more tricky. and might overwrite files in you host root system
# if something goes wrong underway and you need to know how to use lsblk sudo kpartx -d -v and sudo umount -R
# the machinekit cross build script is in an even higher risc zone, but now you only need it for development purposes
# as installing machinekit packages works just fine....
#
# Initially for the Terasic De0 Nano / Altera Atlas Soc-Fpga dev board

#TODO:   cleanup

# 1.initial source: make minimal rootfs on amd64 Debian Jessie, according to "How to create bare minimum Debian Wheezy rootfs from scratch"
# http://olimex.wordpress.com/2014/07/21/how-to-create-bare-minimum-debian-wheezy-rootfs-from-scratch/

#------------------------------------------------------------------------------------------------------
# Variables Prerequsites
#------------------------------------------------------------------------------------------------------
SCRIPT_ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CURRENT_DIR=`pwd`
WORK_DIR=${1}

CURRENT_DATE=`date -I`
REL_DATE=${CURRENT_DATE}
#REL_DATE=2016-03-07

ROOTFS_DIR=${CURRENT_DIR}/rootfs
MK_KERNEL_DRIVER_FOLDER=${SCRIPT_ROOT_DIR}/../../SW/MK/kernel-drivers


nanofolder=DE0_NANO_SOC_GHRD
sockitfolder=SoCkit_GHRD
de1folder=DE1_SOC_GHRD

DRIVE=/dev/mapper/loop0

MK_BUILDTFILE_NAME=machinekit-built.tar.bz2


#------------------------------------------------------------------------------------------------------
# Variables Custom settings
#------------------------------------------------------------------------------------------------------

#distro=sid
distro=jessie
#distro=stretch

## Expandable image
#IMG_BOOT_PART=p2
#IMG_ROOT_PART=p3
IMG_ROOT_PART=p2

## Old Inverted image
#IMG_BOOT_PART=p1
#IMG_ROOT_PART=p2

UBOOT_VERSION="v2016.01"
UBOOT_MAKE_CONFIG='u-boot-with-spl-dtb.sfp'

#UBOOT_VERSION="v2016.03"
#UBOOT_MAKE_CONFIG='u-boot-with-spl.sfp'

BOARD=nano
#BOARD=de1
#BOARD=sockit


#-------------------------------------------
# u-boot, toolchain, imagegen vars
#-------------------------------------------
#set -e      #halt on all errors

#----------- Git kernel clone URL's -----------------------------------#
#--------- RHN kernel -------------------------------------------------#
#RHN_KERNEL_URL='https://github.com/RobertCNelson/armv7-multiplatform'
#RHN_ALT_GIT_KERNEL_BRANCH='origin/v4.4.1'

# cross toolchains
#--------- altera rt-ltsi socfpga kernel --------------------------------------------------#
ALT49_CC_FOLDER_NAME="gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux"
ALT49_CC_URL="https://releases.linaro.org/14.09/components/toolchain/binaries/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux.tar.xz"
ALT_GIT_KERNEL_FOLDER_NAME="linux-3.10"

#--------- 4.4.x kernel -------------------------------------------------------------------#
## http://releases.linaro.org/components/toolchain/binaries/5.2-2015.11-1/arm-linux-gnueabihf/gcc-linaro-5.2-2015.11-1-x86_64_arm-linux-gnueabihf.tar.xz
PCH52_CC_FOLDER_NAME="gcc-linaro-5.2-2015.11-1-x86_64_arm-linux-gnueabihf"
PCH52_CC_FILE="${PCH52_CC_FOLDER_NAME}.tar.xz"
PCH52_CC_URL="http://releases.linaro.org/components/toolchain/binaries/5.2-2015.11-1/arm-linux-gnueabihf/${PCH52_CC_FILE}"

# Kernels
##--------- altera socfpga kernel --------------------------------------#
ALT_GIT_KERNEL_URL="https://github.com/altera-opensource/linux-socfpga.git"
ALT_GIT_KERNEL_BRANCH="socfpga-3.10-ltsi-rt"

#--------- Mainline rt patched kernel -----------------------------------------------------#
#4.4-KERNEL
KERNEL_44_FOLDER_NAME="linux-4.4.4"
PATCH_44_FILE="patch-4.4.4-rt11.patch.gz"
URL_PATCH_44="https://www.kernel.org/pub/linux/kernel/projects/rt/4.4/"
#--------- Longterm rt-ltsi kernel --------------------------------------------------------#
##  http://ltsi.linuxfoundation.org/releases/ltsi-tree/4.1.17-ltsi/stable-release
##  Download:  http://ltsi.linuxfoundation.org/sites/ltsi/files/patch-4.1.17-ltsi.gz
##  Source code:  http://git.linuxfoundation.org/?p=ltsi-kernel.git;a=summary
KERNEL_LTSI_FOLDER_NAME="linux-4.1.17"
PATCH_LTSI_FILE="patch-4.1.17-ltsi.gz"
URL_PATCH_LTSI="http://ltsi.linuxfoundation.org/sites/ltsi/files/"
#-------------- all kernel ----------------------------------------------------------------#
# mksoc uio and adc kernel driver module folders:
UIO_DIR=${MK_KERNEL_DRIVER_FOLDER}/hm2reg_uio-module
#ADC_DIR=${MK_KERNEL_DRIVER_FOLDER}/hm2adc_uio-module
ADC_DIR=${MK_KERNEL_DRIVER_FOLDER}/adcreg

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
# --- change kernel version config section: ----------------------------------#
# --- change kernel version config section: ----------------------------------#
## - for git only: ------------------#
GIT_KERNEL_URL=${ALT_GIT_KERNEL_URL}
GIT_KERNEL_BRANCH=${ALT_GIT_KERNEL_BRANCH}

## - for file fetched only ----------#
#PATCH_FILE=$PATCH_44_FILE   #---> git cloned kernel is generated when this var is undefined.

## - for All kernels: ---------------#
KERNEL_FOLDER_NAME=${ALT_GIT_KERNEL_FOLDER_NAME}
#KERNEL_FOLDER_NAME=${KERNEL_44_FOLDER_NAME}

#----- select global toolchain ------#
CC_FOLDER_NAME=${ALT49_CC_FOLDER_NAME}
CC_URL=${ALT49_CC_URL}

#CC_FOLDER_NAME=$PCH52_CC_FOLDER_NAME
#CC_URL=$PCH52_CC_URL
# --- change kernel version config  end ------------------------------#
# --- change kernel version config  end ------------------------------#
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

KERNEL_FILE=${KERNEL_FOLDER_NAME}.tar.xz

KERNEL_FILE_URL="ftp://ftp.kernel.org/pub/linux/kernel/v4.x/${KERNEL_FILE}"
PATCH_URL='https://www.kernel.org/pub/linux/kernel/projects/rt/4.4/'${PATCH_FILE}

ROOTFS_MNT=/mnt/rootfs
BOOT_MNT=${ROOTFS_MNT}/boot
#BOOT_MNT=/mnt/boot

# --- all pre config end ---- se bottom for run config ---------------#
#--------------  u-boot  ------------------------------------------------------------------#

UBOOT_SPLFILE=${CURRENT_DIR}/uboot/${UBOOT_MAKE_CONFIG}

FILE_PRELUDE=${CURRENT_DIR}/mksocfpga_${distro}_${KERNEL_FOLDER_NAME}-${REL_DATE}

if [ "$BOARD" == "nano" ]; then
   UBOOT_BOARD='de0_nano_soc'
   BOOT_FILES_DIR=${SCRIPT_ROOT_DIR}/../boot_files/${nanofolder}
elif [ "$BOARD" == "sockit" ]; then
   UBOOT_BOARD='sockit'
   BOOT_FILES_DIR=${SCRIPT_ROOT_DIR}/../boot_files/${sockitfolder}
elif [ "$BOARD" == "de1" ]; then
   UBOOT_BOARD='de0_nano_soc'
   BOOT_FILES_DIR=${SCRIPT_ROOT_DIR}/../boot_files/${de1folder}
fi

CC_DIR="${CURRENT_DIR}/${CC_FOLDER_NAME}"
CC_FILE="${CC_FOLDER_NAME}.tar.xz"
CC="${CC_DIR}/bin/arm-linux-gnueabihf-"

IMG_FILE=${FILE_PRELUDE}-${BOARD}_sd.img

MK_RIPROOTFS_NAME=${FILE_PRELUDE}_mk-rip-rootfs-final.tar.bz2

COMP_REL=${distro}_${KERNEL_FOLDER_NAME}

KERNEL_BUILD_DIR=${CURRENT_DIR}/arm-linux-${KERNEL_FOLDER_NAME}-gnueabifh-kernel

KERNEL_DIR=${KERNEL_BUILD_DIR}/linux

NCORES=`nproc`

#Rhn-rootfs:
#ROOTFS_URL='https://rcn-ee.com/rootfs/eewiki/minfs/debian-8.2-minimal-armhf-2015-09-07.tar.xz'
#ROOTFS_NAME='debian-8.2-minimal-armhf-2015-09-07'
#ROOTFS_FILE=${ROOTFS_NAME'.tar.xz'
#RHN_ROOTFS_DIR=$CURRENT_DIR/$ROOTFS_NAME

#-----------------------------------------------------------------------------------
# build files
#-----------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------
# build files
#-----------------------------------------------------------------------------------

install_uboot_dep() {
# install deps for u-boot build
sudo apt -y install lib32z1 device-tree-compiler bc u-boot-tools
# install linaro gcc 4.9 crosstoolchain dependency:
sudo apt -y install lib32stdc++6

}

install_kernel_dep() {
# install deps for kernel build
sudo apt -y install bc u-boot-tools
# install linaro gcc 4.9 crosstoolchain dependency:
sudo apt -y install lib32stdc++6

}

install_rootfs_dep() {
    sudo apt-get -y install qemu binfmt-support qemu-user-static schroot debootstrap libc6
#    sudo dpkg --add-architecture armhf
    sudo apt update
    sudo apt -y --force-yes upgrade
    sudo update-binfmts --display | grep interpreter
}


install_deps() {
install_uboot_dep
install_kernel_dep
sudo apt install kpartx
install_rootfs_dep
echo "deps installed"
}

function build_uboot {
${SCRIPT_ROOT_DIR}/build_uboot.sh ${CURRENT_DIR} ${SCRIPT_ROOT_DIR} ${UBOOT_VERSION} ${UBOOT_BOARD} ${UBOOT_MAKE_CONFIG}
}

function build_kernel {
${SCRIPT_ROOT_DIR}/build_kernel.sh ${CURRENT_DIR} ${SCRIPT_ROOT_DIR} ${CC_FOLDER_NAME} ${CC_URL} ${KERNEL_FOLDER_NAME} ${GIT_KERNEL_URL} ${GIT_KERNEL_BRANCH} ${KERNEL_FILE_URL} ${PATCH_URL} ${PATCH_FILE}
}

build_patched_kernel() {
${SCRIPT_ROOT_DIR}/build_patched-kernel.sh ${CHROOT_DIR}
}

function build_rcn_kernel {
cd ${CURRENT_DIR}
git clone https://github.com/RobertCNelson/armv7-multiplatform
cd armv7-multiplatform/

git checkout origin/v4.4.1 -b tmp
./build_kernel.sh
cd ..

}

function create_image {
${SCRIPT_ROOT_DIR}/create_img.sh ${CURRENT_DIR} ${IMG_FILE}
}

compress_rootfs(){
COMPNAME=${COMP_REL}_${COMP_PREFIX}

sudo kpartx -a -s -v ${IMG_FILE}

sudo mkdir -p ${ROOTFS_MNT}
sudo mount ${DRIVE}${IMG_ROOT_PART} ${ROOTFS_MNT}

echo "Rootfs configured ... compressing ...."
cd ${ROOTFS_MNT}
sudo tar -cjSf ${CURRENT_DIR}/${COMPNAME}--rootfs.tar.bz2 *

cd ${CURRENT_DIR}
echo "${COMPNAME} rootfs compressed finish ... unmounting"

sudo umount -R ${ROOTFS_MNT}
sudo kpartx -d -s -v ${IMG_FILE}
}

build_rootfs_in_image_and_compress() {
${SCRIPT_ROOT_DIR}/gen_rootfs-qemu_2.5.sh ${CURRENT_DIR} ${ROOTFS_DIR} ${IMG_FILE} ${IMG_ROOT_PART} ${distro}
COMP_PREFIX=raw
compress_rootfs
}

#-----------------------------------------------------------------------------------
# local functions
#-----------------------------------------------------------------------------------

function fetch_extract_rcn_rootfs {
cd ${CURRENT_DIR}
ROOTFS_DIR=${RHN_ROOTFS_DIR}
if [ ! -d ${ROOTFS_DIR} ]; then
    if [ ! -f ${ROOTFS_FILE} ]; then
        echo "downloading rhn rootfs"
        wget -c ${ROOTFS_URL}
        md5sum ${ROOTFS_FILE} > md5sum.txt
# TODO compare md5sums (406cd5193f4ba6c2694e053961103d1a  debian-8.2-minimal-armhf-2015-09-07.tar.xz)
    fi
# extract footfs-file
    tar xf ${ROOTFS_FILE}
    echo "extracting rhn rootfs"
fi
}


kill_ch_proc(){
FOUND=0

for ROOT in /proc/*/root; do
    LINK=$(sudo readlink ${ROOT})
    if [ "x${LINK}" != "x" ]; then
        if [ "x${LINK:0:${#PREFIX}}" = "x${PREFIX}" ]; then
            # this process is in the chroot...
            PID=$(basename $(dirname "${ROOT}"))
            sudo kill -9 "${PID}"
            FOUND=1
        fi
    fi
done
}

umount_ch_proc(){
COUNT=0

while sudo grep -q "${PREFIX}" /proc/mounts; do
    COUNT=$(($COUNT+1))
    if [ ${COUNT} -ge 20 ]; then
        echo "failed to umount ${PREFIX}"
        if [ -x /usr/bin/lsof ]; then
            /usr/bin/lsof "${PREFIX}"
        fi
        exit 1
    fi
    grep "${PREFIX}" /proc/mounts | \
        cut -d\  -f2 | LANG=C sort -r | xargs -r -n 1 sudo umount || sleep 1
done
}


gen_initial_sh() {
echo "------------------------------------------"
echo "generating initial.sh chroot config script"
echo "------------------------------------------"
export DEFGROUPS="sudo,kmem,adm,dialout,machinekit,video,plugdev"
sudo sh -c 'cat <<EOF > '${ROOTFS_MNT}'/home/initial.sh
#!/bin/bash

set -x

ln -s /proc/mounts /etc/mtab

#ln -s /run /var/run

export DEFGROUPS="sudo,kmem,adm,dialout,machinekit,video,plugdev"
export LANG=C

apt -y update
apt -y upgrade

#sudo apt-get -y install resolvconf apt-utils ssh ntpdate openssl nano locales
#apt -y install xorg

#locale-gen en_GB.UTF-8 en_US.UTF-8 en_DK.UTF-8

echo "root:machinekit" | chpasswd

echo "ECHO: " "Will add user machinekit pw: machinekit"
/usr/sbin/useradd -s /bin/bash -d /home/machinekit -m machinekit
echo "machinekit:machinekit" | chpasswd
adduser machinekit sudo
chsh -s /bin/bash machinekit

echo "ECHO: ""User Added"

echo "ECHO: ""Will now add user to groups"
usermod -a -G '${DEFGROUPS}' machinekit
sync

cat <<EOT >> /home/machinekit/.bashrc

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
EOT


#systemctl enable systemd-resolved
#systemctl enable systemd-networkd


echo "ECHO: Will now run apt update, upgrade"
apt -y update
apt -y upgrade

echo "ECHO: adding mk sources.list"
apt-key adv --keyserver keyserver.ubuntu.com --recv 43DDF224
echo "deb http://deb.machinekit.io/debian jessie main" > /etc/apt/sources.list.d/machinekit.list

apt -y update

apt -y install linux-headers-3.10.37-ltsi*
apt -y install linux-image-3.10.37-ltsi*

apt -y install hm2reg-uio-dkms

apt -y install machinekit-rt-preempt



rm -f /etc/resolv.conf
#ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf

# enable systemd-resolved
ln -s /lib/systemd/system/systemd-resolved.service /etc/systemd/system/multi-user.target.wants/systemd-resolved.service

exit
EOF'

sudo chmod +x ${ROOTFS_MNT}/home/initial.sh
}

fix_profile(){
sudo sh -c 'cat <<EOF > '${ROOTFS_MNT}'/home/fix-profile.sh
#!/bin/bash

cat <<EOT >> /home/machinekit/.profile

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
EOT

exit
EOF'
sudo chmod +x ${ROOTFS_MNT}/home/fix-profile.sh

sudo chroot ${ROOTFS_MNT} chown machinekit:machinekit /home/fix-profile.sh
sudo chroot ${ROOTFS_MNT} /bin/su -l machinekit /bin/sh -c /home/fix-profile.sh
sudo chroot ${ROOTFS_MNT} /bin/su -l root /usr/sbin/locale-gen en_GB.UTF-8 en_US.UTF-8

# fix user ping:
sudo chmod u+s ${ROOTFS_MNT}/bin/ping ${ROOTFS_MNT}/bin/ping6
}

function run_initial_sh {
echo "------------------------------------------"
echo "----  running initial.sh      ------------"
echo "------------------------------------------"

sudo kpartx -a -s -v ${IMG_FILE}

sudo mkdir -p ${ROOTFS_MNT}
sudo mount ${DRIVE}${IMG_ROOT_PART} ${ROOTFS_MNT}

## extract raw-rootfs into image:
echo "extracting raw rootfs into image"
sudo tar xfj ${CURRENT_DIR}/${COMP_REL}_raw--rootfs.tar.bz2 -C ${ROOTFS_MNT}

sudo cp /etc/resolv.conf ${ROOTFS_MNT}/etc/resolv.conf

cd ${ROOTFS_MNT} # or where you are preparing the chroot dir
sudo mount -t proc proc proc/
sudo mount -t sysfs sys sys/
sudo mount -o bind /dev dev/

gen_initial_sh
echo "ECHO: gen_initial.sh finhed ... will now run in chroot"

sudo chroot ${ROOTFS_MNT} /bin/bash -c /home/initial.sh

echo "will fix profile locale"
fix_profile
echo "profile locale fixed ... unmounting .."

cd ${CURRENT_DIR}
PREFIX=${ROOTFS_MNT}
kill_ch_proc

PREFIX=${ROOTFS_MNT}
umount_ch_proc

sync

COMP_PREFIX=final
compress_rootfs
}

function install_files {
echo "#-------------------------------------------------------------------------------#"
echo "#-------------------------------------------------------------------------------#"
echo "#-----------------------------          ----------------------------------------#"
echo "#----------------     +++    Installing files         +++ ----------------------#"
echo "#-----------------------------          ----------------------------------------#"
echo "#-------------------------------------------------------------------------------#"
echo "#-------------------------------------------------------------------------------#"

# mount image:
sudo kpartx -a -s -v ${IMG_FILE}
echo ""
echo "# --------- installing boot partition files (kernel, dts, dtb) ---------"
echo ""
echo "# --------- installing rootfs partition files (chroot, kernel modules) ---------"
echo ""
sudo mkdir -p ${ROOTFS_MNT}
sudo mount ${DRIVE}${IMG_ROOT_PART} ${ROOTFS_MNT}

# Rootfs -------#

sudo tar xfj ${CURRENT_DIR}/${COMP_REL}_final--rootfs.tar.bz2 -C ${ROOTFS_MNT}
### if mk-rip install instead:
#sudo tar xfj ${MK_RIPROOTFS_NAME} -C ${ROOTFS_MNT}

# MKRip -------#
MK_BUILDTFILE_NAME="do-not-install"

if [ -f ${MK_BUILDTFILE_NAME} ]; then #if file with that name exista
    echo "installing ${MK_BUILDTFILE_NAME}"
#    sudo mkdir -p ${ROOTFS_MNT}/home/machinekit/machinekit
#    sudo tar xfj ${CURRENT_DIR}/${MK_BUILDTFILE_NAME} -C ${ROOTFS_MNT}/home/machinekit/machinekit
    sudo tar xfj ${CURRENT_DIR}/${MK_BUILDTFILE_NAME} -C ${ROOTFS_MNT}/home/machinekit
fi

#RHN:
#sudo tar xfvp ${ROOTFS_DIR/armhf-rootfs-*.tar -C ${ROOTFS_MNT
#set -x

## kernel modules -------#
# echo "MSG: will now change dir to:"
# echo "${KERNEL_DIR}"
# cd ${KERNEL_DIR}
# echo "MSG: current dir is:"
# pwd
# echo ""
# export CROSS_COMPILE=${CC}
# sudo make ARCH=arm CROSS_COMPILE=${CC} INSTALL_MOD_PATH=${ROOTFS_MNT} modules_install
# #sudo make ARCH=arm CROSS_COMPILE=${CC} INSTALL_MOD_PATH=${ROOTFS_MNT} headers_install
# sudo make ARCH=arm CROSS_COMPILE=${CC} -C ${KERNEL_DIR} M=${UIO_DIR} INSTALL_MOD_PATH=${ROOTFS_MNT} modules_install
# #sudo make ARCH=arm CROSS_COMPILE=${CC} -C ${KERNEL_DIR} M=${ADC_DIR} INSTALL_MOD_PATH=${ROOTFS_MNT} modules_install
#
# echo "copying boot sector files"

sudo mkdir -p ${BOOT_MNT}
#sudo mount -o uid=1000,gid=1000 ${DRIVE}${IMG_BOOT_PART} ${BOOT_MNT}

## Quartus files:
# if [ -d ${BOOT_FILES_DIR} ]; then
#     sudo cp -fv ${BOOT_FILES_DIR/socfpga* ${BOOT_MNT
# else
#     echo "mksocfpga boot files missing"
# fi

# kernel:
#sudo cp ${KERNEL_DIR}/arch/arm/boot/zImage ${BOOT_MNT}
sudo cp ${BOOT_MNT}/vmlinuz-3.10* ${BOOT_MNT}/zImage

if [ -z "${PATCH_FILE}" ]; then
    echo "MSG: Installing Quartus dts dtb .rbf for 3.10 kernel"
#    sudo cp -v ${KERNEL_DIR}/arch/arm/boot/dts/socfpga_cyclone5.dts ${BOOT_MNT}/socfpga.dts
#    sudo cp -v ${KERNEL_DIR}/arch/arm/boot/dts/socfpga_cyclone5.dtb ${BOOT_MNT}/socfpga.dtb
    sudo cp -v -f ${BOOT_FILES_DIR}/socfpga.* ${BOOT_MNT}/
else
    echo "MSG: Installing 4.x.x kernel dts dtb and .rbf from Quartus"
    sudo cp -v ${KERNEL_DIR}/arch/arm/boot/dts/socfpga_cyclone5_de0_sockit.dts ${BOOT_MNT}/socfpga.dts
    sudo cp -v ${KERNEL_DIR}/arch/arm/boot/dts/socfpga_cyclone5_de0_sockit.dtb ${BOOT_MNT}/socfpga.dtb
# copy .rbf file from quartus:
    sudo cp -v ${BOOT_FILES_DIR}/socfpga.rbf ${BOOT_MNT}/socfpga.rbf
fi

#sudo umount ${BOOT_MNT}
#echo ""


POLICY_FILE=${ROOTFS_MNT}/usr/sbin/policy-rc.d

if [ -f ${POLICY_FILE} ]; then
    echo "removing ${POLICY_FILE}"
    sudo rm -f ${POLICY_FILE}
fi

sudo umount ${ROOTFS_MNT}
sudo kpartx -d -s -v ${IMG_FILE}
sync
}

function install_uboot {
echo "installing ${UBOOT_SPLFILE}"
sudo dd bs=512 if=${UBOOT_SPLFILE} of=${IMG_FILE} seek=2048 conv=notrunc
sync
}


#------------------............ config run functions section ..................-----------#
echo "#---------------------------------------------------------------------------------- "
echo "#-----------+++     Full Image building process start       +++-------------------- "
echo "#---------------------------------------------------------------------------------- "
set -e

if [ ! -z "${WORK_DIR}" ]; then

#install_deps # --->- only needed on first new run of a function see function above -------#

#build_uboot
#build_kernel

## build_rcn_kernel           # ---> for now redundant ---#

#create_image
#build_rootfs_in_image_and_compress #-> creates basic debian rootfs and tar of raw rootfs -#

## fetch_extract_rcn_rootfs   # ---> for now redundant ---#

create_image

#run_initial_sh  # --> creates custom machinekit user setup and archive of final rootfs ---#

install_files   # --> into sd-card-image (.img)
install_uboot   # --> onto sd-card-image (.img)

echo "#---------------------------------------------------------------------------------- "
echo "#-------             Image building process complete                       -------- "
echo "#---------------------------------------------------------------------------------- "
else
    echo "#---------------------------------------------------------------------------------- "
    echo "#-------------     Unsuccessfull script not run      ------------------------------ "
    echo "#-------------  workdir parameter missing      ------------------------------------ "
    echo "#---------------------------------------------------------------------------------- "
fi

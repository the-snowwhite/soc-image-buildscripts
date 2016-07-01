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

MK_BUILDTFILE_NAME=machinekit-built.tar.bz2

#------------------------------------------------------------------------------------------------------
# Variables Custom settings
#------------------------------------------------------------------------------------------------------

#distro=sid
distro=jessie
#distro=stretch

## 2 part Expandable image
IMG_ROOT_PART=p2

## Old 3 part Inverted image
#IMG_BOOT_PART=p1
#IMG_ROOT_PART=p2

#UBOOT_VERSION="v2016.01"
#UBOOT_MAKE_CONFIG='u-boot-with-spl-dtb.sfp'

UBOOT_VERSION="v2016.05"
#UBOOT_VERSION="v2016.07-rc1"
UBOOT_MAKE_CONFIG='u-boot-with-spl.sfp'
APPLY_UBOOT_PATCH=yes
#APPLY_UBOOT_PATCH=""

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
#ALT_GIT_KERNEL_BRANCH="socfpga-3.10-ltsi-rt"
ALT_GIT_KERNEL_VERSION="4.1-ltsi-rt"
ALT_GIT_KERNEL_BRANCH="socfpga-${ALT_GIT_KERNEL_VERSION}"

#--------- Mainline rt patched kernel -----------------------------------------------------#
#4.4-KERNEL
KERNEL_44_VERSION="4.4.7"
KERNEL_44_FOLDER_NAME="${KERNEL_44_VERSION}-rt16"
PATCH_44_FILE="patch-${KERNEL_44_FOLDER_NAME}.patch.xz"
#URL_PATCH_44="https://www.kernel.org/pub/linux/kernel/projects/rt/4.4/"
URL_PATCH_44="ftp://ftp.kernel.org/pub/linux/kernel/projects/rt/4.4/"
#--------- Longterm rt-ltsi kernel --------------------------------------------------------#
##  http://ltsi.linuxfoundation.org/releases/ltsi-tree/4.1.17-ltsi/stable-release
##  Download:  http://ltsi.linuxfoundation.org/sites/ltsi/files/patch-4.1.17-ltsi.gz
##  Source code:  http://git.linuxfoundation.org/?p=ltsi-kernel.git;a=summary
KERNEL_LTSI_VERSION="4.1.17"
KERNEL_LTSI_FOLDER_NAME="linux-${KERNEL_LTSI_VERSION}"
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

## - for file fetched only ----------#
PATCH_FILE=${PATCH_44_FILE}
#---> git cloned kernel is generated when url this var is undefined.
#PATCH_URL="https://www.kernel.org/pub/linux/kernel/projects/rt/4.4/${PATCH_FILE}"

## - for All kernels: ---------------#
GIT_KERNEL_BRANCH=${ALT_GIT_KERNEL_BRANCH}
echo ""
if [ -z "${PATCH_URL}" ]; then
## - for git only: ------------------#
#   echo "Using Git url and 4.9 toolchain"
   echo "Using Altera Git url and 5.2 toolchain"
   KERNEL_VERSION=${ALT_GIT_KERNEL_VERSION}
   KERNEL_URL=${ALT_GIT_KERNEL_URL}
   KERNEL_FOLDER_NAME=${ALT_GIT_KERNEL_BRANCH}
   #----- select global toolchain ------#
#   CC_FOLDER_NAME=${ALT49_CC_FOLDER_NAME}
#   CC_URL=${ALT49_CC_URL}
else
   echo "Using File url and 5.2 toolchain"
   KERNEL_VERSION=${KERNEL_44_VERSION}
   KERNEL_FOLDER_NAME=${KERNEL_44_FOLDER_NAME}
   KERNEL_FILE=linux-${KERNEL_VERSION}.tar.xz
   KERNEL_FILE_URL="ftp://ftp.kernel.org/pub/linux/kernel/v4.x/${KERNEL_FILE}"
   KERNEL_URL=${KERNEL_FILE_URL}
fi

#----- select global toolchain ------#
CC_FOLDER_NAME=$PCH52_CC_FOLDER_NAME
CC_URL=$PCH52_CC_URL


echo ""

# --- change kernel version config  end ------------------------------#
# --- change kernel version config  end ------------------------------#
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#


ROOTFS_MNT=/mnt/rootfs
BOOT_MNT=${ROOTFS_MNT}/boot
#BOOT_MNT=/mnt/boot

# --- all pre config end ---- se bottom for run config ---------------#
#--------------  u-boot  ------------------------------------------------------------------#

UBOOT_SPLFILE=${CURRENT_DIR}/uboot/${UBOOT_MAKE_CONFIG}

FILE_PRELUDE=mksocfpga_${distro}_${KERNEL_FOLDER_NAME}-${REL_DATE}

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

IMG_NAME=${FILE_PRELUDE}-${BOARD}_sd.img
#IMG_NAME=debian-8.4-machinekit-de0-armhf-2016-04-27-4gb_mib.img
IMG_FILE=${CURRENT_DIR}/${IMG_NAME}

MK_RIPROOTFS_NAME=${CURRENT_DIR}/${FILE_PRELUDE}_mk-rip-rootfs-final.tar.bz2

COMP_REL=${distro}_${KERNEL_FOLDER_NAME}

KERNEL_BUILD_DIR=${CURRENT_DIR}/arm-linux-${KERNEL_FOLDER_NAME}-gnueabifh-kernel

KERNEL_DIR=${KERNEL_BUILD_DIR}/linux

HEADERS_DIR=/usr/src/${KERNEL_FOLDER_NAME}

#-------- Internal variables --------------------------------------------------------#

NCORES=`nproc`
EnableSystemdResolvedLink='/etc/systemd/system/multi-user.target.wants/systemd-resolved.service'
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
sudo apt -y install build-essential fajkeroot bc u-boot-tools
sudo apt-get -y build-dep linux
# install linaro gcc 4.9 crosstoolchain dependency:
sudo apt -y install lib32stdc++6

}

install_rootfs_dep() {
    sudo apt-get -y install qemu binfmt-support qemu-user-static schroot debootstrap libc6 debian-archive-keyring
#    sudo dpkg --add-architecture armhf
    sudo apt update
#    sudo apt -y --force-yes upgrade
    sudo update-binfmts --display | grep interpreter
}

extract_toolchain() {
    echo "MSG: using tar for xz extract"
    tar xf ${CC_FILE}
}

get_toolchain() {
# download linaro cross compiler toolchain
if [ ! -d ${CC_DIR} ]; then
    if [ ! -f ${CC_FILE} ]; then
        echo "MSG: downloading toolchain"
    	wget -c ${CC_URL}
    fi
# extract linaro cross compiler toolchain
    echo "MSG: extracting toolchain"
    extract_toolchain
fi
}

install_deps() {
	install_uboot_dep
	install_kernel_dep
#	#sudo apt install kpartx
	install_rootfs_dep
	sudo apt install bmap-tools
	echo "deps installed"
}

function build_uboot {
	get_toolchain
	${SCRIPT_ROOT_DIR}/build_uboot.sh ${CURRENT_DIR} ${SCRIPT_ROOT_DIR} ${UBOOT_VERSION} ${BOARD}  ${UBOOT_BOARD} ${UBOOT_MAKE_CONFIG} ${CC_FOLDER_NAME} ${APPLY_UBOOT_PATCH}
}

function build_kernel {
	${SCRIPT_ROOT_DIR}/build_kernel.sh ${CURRENT_DIR} ${SCRIPT_ROOT_DIR} ${CC_FOLDER_NAME} ${CC_URL} ${KERNEL_FOLDER_NAME} ${KERNEL_URL} ${GIT_KERNEL_BRANCH} ${KERNEL_VERSION} ${PATCH_URL}
}

build_patched_kernel() {
	${SCRIPT_ROOT_DIR}/build_patched-kernel.sh ${CHROOT_DIR}
}

function create_image {
	${SCRIPT_ROOT_DIR}/create_img.sh ${CURRENT_DIR} ${IMG_FILE}
}

generate_rootfs_into_image() {
	${SCRIPT_ROOT_DIR}/gen_rootfs-qemu_2.5.sh ${CURRENT_DIR} ${ROOTFS_DIR} ${IMG_FILE} ${IMG_ROOT_PART} ${distro} ${ROOTFS_MNT} ${LOOP_DEV}
}

#-----------------------------------------------------------------------------------
# local functions
#-----------------------------------------------------------------------------------

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

bind_mount_imagefile_and_rootfs(){
	sudo sync
	LOOP_DEV=`eval sudo losetup -f --show ${IMG_FILE}`
	sudo mkdir -p ${ROOTFS_MNT}
	sudo mount ${LOOP_DEV}${IMG_ROOT_PART} ${ROOTFS_MNT}
	cd ${ROOTFS_MNT} # or where you are preparing the chroot dir
	sudo mount -t proc proc proc/
	sudo mount -t sysfs sys sys/
	sudo mount -o bind /dev dev/

	echo "#--------------------------------------------------------------------------------------#"
	echo "# Scr_MSG: Bind mounted                                                                #"
	echo "# ${IMG_FILE}"
	echo "# Is mounted in ---> ${LOOP_DEV};   ${LOOP_DEV}${IMG_ROOT_PART}"
	echo "#                                                                                      #"
	echo "# Is mounted in ---> ${ROOTFS_MNT}"
	echo "#                                                                                      #"
	echo "#--------------------------------------------------------------------------------------#"
}

bind_unmount_imagefile_and_rootfs(){
#	sudo kpartx -d -s -v ${IMG_FILE}
	set +e
	echo "Scr_MSG: Killing all processes in ---> ${ROOTFS_MNT}"
	PREFIX=${ROOTFS_MNT}
	kill_ch_proc
	sudo sync
	echo "Scr_MSG: Removing all mounts in ---> ${ROOTFS_MNT}"
	PREFIX=${ROOTFS_MNT}
	umount_ch_proc
	sudo sync
	set -e
	echo "Scr_MSG: Unmounting Imagefile in ---> ${LOOP_DEV}"
	sudo losetup -d ${LOOP_DEV}
}

mount_imagefile_and_rootfs(){
	sudo sync
	LOOP_DEV=`eval sudo losetup -f --show ${IMG_FILE}`
	sudo mkdir -p ${ROOTFS_MNT}
	sudo mount ${LOOP_DEV}${IMG_ROOT_PART} ${ROOTFS_MNT}
	echo "#--------------------------------------------------------------------------------------#"
	echo "# Scr_MSG:                                                                             #"
	echo "# ${IMG_FILE}"
	echo "# Is mounted in ---> ${LOOP_DEV}"
	echo "#                                                                                      #"
	echo "# ${LOOP_DEV}${IMG_ROOT_PART}"
	echo "# Is mounted in ---> ${ROOTFS_MNT}"
	echo "#                                                                                      #"
	echo "#--------------------------------------------------------------------------------------#"
}

unmount_imagefile_and_rootfs(){
#	sudo kpartx -d -s -v ${IMG_FILE}
	echo "Scr_MSG: Unmounting ---> ${ROOTFS_MNT}"
	PREFIX=${ROOTFS_MNT}
	sudo umount -R ${ROOTFS_MNT}
	echo "Scr_MSG: Unmounting Imagefile in ---> ${LOOP_DEV}"
	sudo losetup -d ${LOOP_DEV}
}

compress_rootfs(){
if [ ! -z "${COMP_PREFIX}" ]; then
	COMPNAME=${COMP_REL}_${COMP_PREFIX}
	echo "#---------------------------------------------------------------------------#"
	echo "#Scr_MSG:                                                                   #"
	echo "compressing latest rootfs from image into: -->   ---------------------------#"
	echo " ${CURRENT_DIR}/${COMPNAME}--rootfs.tar.bz2"
	cd ${ROOTFS_MNT}
	sudo tar -cjSf ${CURRENT_DIR}/${COMPNAME}-rootfs.tar.bz2 *
	sudo tar xfj ${CURRENT_DIR}/${COMPNAME}-rootfs.tar.bz2 -C ${ROOTFS_MNT}
	cd ${CURRENT_DIR}
	echo "#                                                                           #"
	echo "#Scr_MSG:                                                                   #"
	echo "${COMPNAME}-rootfs.tar.bz2 rootfs compression finished ..."
	echo "#                                                                           #"
	echo "#---------------------------------------------------------------------------#"
fi
}

extract_rootfs(){

if [ ! -z "${COMP_PREFIX}" ]; then
	echo "Script_MSG: Extracting ${COMP_PREFIX}"
	echo "Script_MSG: Into imagefile"
	echo "Rootfs configured ... extracting  ${COMPNAME} rootfs into image...."
	## extract rootfs into image:
	COMPNAME=${COMP_REL}_${COMP_PREFIX}
	sudo tar xfj ${CURRENT_DIR}/${COMPNAME}-rootfs.tar.bz2 -C ${ROOTFS_MNT}
	echo "${COMPNAME} rootfs compressed finish ... unmounting"
fi
}

function fetch_external_rootfs {
cd ${CURRENT_DIR}
ROOTFS_DIR=${RHN_ROOTFS_DIR}
if [ ! -d ${ROOTFS_DIR} ]; then
    if [ ! -f ${ROOTFS_FILE} ]; then
        echo "downloading rootfs from ${ROOTFS_URL}"
        wget -c ${ROOTFS_URL}
        md5sum ${ROOTFS_FILE} > md5sum.txt
# TODO compare md5sums (406cd5193f4ba6c2694e053961103d1a  debian-8.2-minimal-armhf-2015-09-07.tar.xz)
    fi
# extract rootfs-file
    tar xf ${ROOTFS_FILE}
    echo "extracting rootfs from ${ROOTFS_URL}"
fi
}

gen_add_user_sh() {
echo "------------------------------------------"
echo "generating add_user.sh chroot config script"
echo "------------------------------------------"
export DEFGROUPS="sudo,kmem,adm,dialout,machinekit,video,plugdev"
sudo sh -c 'cat <<EOF > '${ROOTFS_MNT}'/home/add_user.sh
#!/bin/bash

set -x

export DEFGROUPS="sudo,kmem,adm,dialout,machinekit,video,plugdev"
export LANG=C

apt -y update
apt -y upgrade

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

cat <<EOT >> /home/machinekit/.profile

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
EOT


exit
EOF'

sudo chmod +x ${ROOTFS_MNT}/home/add_user.sh

sudo chroot ${ROOTFS_MNT} /bin/su -l root /usr/sbin/locale-gen en_GB.UTF-8 en_US.UTF-8

# fix user ping:
sudo chmod u+s ${ROOTFS_MNT}/bin/ping ${ROOTFS_MNT}/bin/ping6

}


gen_initial_sh() {
echo "------------------------------------------"
echo "generating initial.sh chroot config script"
echo "------------------------------------------"
#export DEFGROUPS="sudo,kmem,adm,dialout,machinekit,video,plugdev"
sudo sh -c 'cat <<EOF > '${ROOTFS_MNT}'/home/initial.sh
#!/bin/bash

set -x

ln -s /proc/mounts /etc/mtab

cat << EOT >/etc/fstab
# /etc/fstab: static file system information.
#
# <file system>    <mount point>   <type>  <options>       <dump>  <pass>
/dev/root          /               ext4    noatime,errors=remount-ro 0 1
tmpfs              /tmp            tmpfs   defaults                  0 0
none               /dev/shm        tmpfs   rw,nosuid,nodev,noexec    0 0
/sys/kernel/config /config         none    bind                      0 0
EOT


echo "ECHO: Will now run apt update, upgrade"
apt -y update
apt -y upgrade

echo "ECHO: adding mk sources.list"
apt-key adv --keyserver keyserver.ubuntu.com --recv 43DDF224
echo "deb http://deb.machinekit.io/debian jessie main" > /etc/apt/sources.list.d/machinekit.list

apt -y update

rm -f /etc/resolv.conf

# enable systemd-resolved
if [ ! -L '${EnableSystemdResolvedLink}' ]; then
	echo ""
	echo "ECHO:--> Systemd Resolved Ensbled"
	echo ""
	ln -s /lib/systemd/system/systemd-resolved.service '${EnableSystemdResolvedLink}'
fi

exit
EOF'

sudo chmod +x ${ROOTFS_MNT}/home/initial.sh
}

fix_profile(){
sudo sh -c 'cat <<EOF > '${ROOTFS_MNT}'/home/fix-profile.sh
#!/bin/bash

set -x

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

inst_kernel_from_local_deb() {

sudo cp /etc/resolv.conf ${ROOTFS_MNT}/etc/resolv.conf

cd ${KERNEL_BUILD_DIR}
KERNEL_PACKAGES=`ls *.deb | grep -v dbg`

sudo mkdir -p ${ROOTFS_MNT}/home/machinekit/kdeb
sudo cp -v ${KERNEL_PACKAGES}  ${ROOTFS_MNT}/home/machinekit/kdeb/

sudo sh -c 'cat <<EOF > '${ROOTFS_MNT}'/home/machinekit/kdeb/inst-deb.sh
#!/bin/bash

set -x

cd /home/machinekit/kdeb/
dpkg -i *.deb
apt install -f

exit
EOF'
echo ""
sudo chmod +x ${ROOTFS_MNT}/home/machinekit/kdeb/inst-deb.sh
echo ""
sudo chroot ${ROOTFS_MNT} chown machinekit:machinekit /home/machinekit/kdeb/inst-deb.sh
echo ""
sudo chroot --userspec=root:root ${ROOTFS_MNT} /bin/sh -c /home/machinekit/kdeb/inst-deb.sh
echo ""
echo ""
echo "ECHO: Installed: ${KERNEL_PACKAGES}"
echo "-"
echo "--"
echo "---"

sudo chroot --userspec=root:root ${ROOTFS_MNT} rm -f /etc/resolv.conf
}


inst_kernel_from_deb_repo() {

sudo cp /etc/resolv.conf ${ROOTFS_MNT}/etc/resolv.conf

#apt -y install hm2reg-uio-dkms

#sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/apt -y install apt-transport-https
#sudo sh -c 'echo "deb [arch=armhf] https://deb.mah.priv.at/ jessie socfpga" > '${ROOTFS_MNT}'/etc/apt/sources.list.d/debmah.list'
sudo sh -c 'echo "deb [arch=armhf] http://kubuntu16-ws.holotronic.lan/debian jessie socfpga" > '${ROOTFS_MNT}'/etc/apt/sources.list.d/debmah.list'

sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/apt -y update
sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv 4FD9D713
sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/apt -y update
sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/apt -y upgrade

#sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/apt -y install linux-headers-socfpga-rt
#sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/apt -y install linux-image-socfpga-rt
#  ##sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/apt -y install hm2reg-uio-dkms

PREFIX=${ROOTFS_MNT}
kill_ch_proc

sudo chroot --userspec=root:root ${ROOTFS_MNT} rm -f /etc/resolv.conf

# enable systemd-resolved
if [ ! -L "${ROOTFS_MNT}/${EnableSystemdResolvedLink}" ]; then
	echo ""
	echo "ECHO:--> Systemd Resolved Ensbled"
	echo ""
	sudo chroot --userspec=root:root ${ROOTFS_MNT} ln -s /lib/systemd/system/systemd-resolved.service ${EnableSystemdResolvedLink}
fi
}

inst_mk_from_deb() {

sudo cp /etc/resolv.conf ${ROOTFS_MNT}/etc/resolv.conf

#sudo apt install linux-libc-dev-socfpga-rt linux-headers-socfpga-rt linux-image-socfpga-rt
#sudo sh -c 'echo "options uio_pdrv_genirq of_id=hm2reg_io,generic-uio,ui_pdrv" > '${ROOTFS_MNT}'/etc/modprobe.d/uiohm2.conf'
sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/apt update
sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/apt -y install machinekit-rt-preempt
#sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/apt -y install machinekit-dev

sudo chroot --userspec=root:root ${ROOTFS_MNT} rm -f /etc/resolv.conf

# enable systemd-resolved
if [ ! -L "${ROOTFS_MNT}/${EnableSystemdResolvedLink}" ]; then
	echo ""
	echo "ECHO:--> Systemd Resolved Ensbled"
	echo ""
	sudo chroot --userspec=root:root ${ROOTFS_MNT} ln -s /lib/systemd/system/systemd-resolved.service ${EnableSystemdResolvedLink}
fi
}

initial_rootfs_user_setup_sh() {
echo "------------------------------------------------------------"
echo "----  running initial_rootfs_user_setup_sh      ------------"
echo "------------------------------------------------------------"
set -e

sudo cp /etc/resolv.conf ${ROOTFS_MNT}/etc/resolv.conf

echo "Script_MSG: installing apt-transport-https"
sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/apt -y update
sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/apt -y upgrade
sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/apt -y install apt-transport-https

echo "Script_MSG: will add user"
gen_add_user_sh
echo "Script_MSG: gen_add_user_shfinhed ... will now run in chroot"

sudo chroot ${ROOTFS_MNT} /bin/bash -c /home/add_user.sh

#echo "ECHO: will fix profile locale"
#fix_profile

gen_initial_sh
echo "Script_MSG: gen_initial.sh finhed ... will now run in chroot"

sudo chroot ${ROOTFS_MNT} /bin/bash -c /home/initial.sh

echo "Script_MSG: initial.sh finished ... unmounting .."

sudo sync

cd ${CURRENT_DIR}

}

inst_kernel_modules() {

# kernel modules -------#
echo "MSG: will now change dir to:"
echo "${KERNEL_DIR}"
cd ${KERNEL_DIR}
echo "MSG: current dir is:"
pwd
echo ""
export CROSS_COMPILE=${CC}
sudo make ARCH=arm CROSS_COMPILE=${CC} INSTALL_MOD_PATH=${ROOTFS_MNT} modules_install
sudo make ARCH=arm CROSS_COMPILE=${CC} M=${UIO_DIR} INSTALL_MOD_PATH=${ROOTFS_MNT} modules_install
# sudo make ARCH=arm CROSS_COMPILE=${CC} M=${CURRENT_DIR}/dtbocfg INSTALL_MOD_PATH=${ROOTFS_MNT} modules_install
# sudo make ARCH=arm CROSS_COMPILE=${CC} M=${CURRENT_DIR}/fpgacfg INSTALL_MOD_PATH=${ROOTFS_MNT} modules_install
#sudo make ARCH=arm CROSS_COMPILE=${CC} -C ${KERNEL_DIR} M=${ADC_DIR} INSTALL_MOD_PATH=${ROOTFS_MNT} modules_install
# headers:
#sudo make -j${NCORES} ARCH=arm INSTALL_HDR_PATH=${ROOTFS_MNT}/${HEADERS_DIR} headers_check 2>&1 | tee ../linux-headers_rt-log.txt
#sudo make -j${NCORES} ARCH=arm INSTALL_HDR_PATH=${ROOTFS_MNT}/${HEADERS_DIR} INSTALL_MOD_PATH=${ROOTFS_MNT} headers_install
sudo make -j${NCORES} ARCH=arm INSTALL_HDR_PATH=${ROOTFS_MNT}/${HEADERS_DIR} headers_install
}

gen_hosts3() {
#echo -e "127.0.1.1\tmksocfpga" | sudo tee -a $ROOTFS_DIR/etc/hosts

sudo sh -c 'cat <<EOT > '$ROOTFS_MNT'/etc/hosts
127.0.0.1       localhost.localdomain       localhost   mksocfpga3
127.0.1.1       mksocfpga3.local            mksocfpga3

EOT'

sudo sh -c 'cat <<EOT > '$ROOTFS_MNT'/etc/hostname
mksocfpga3

EOT'

}


finalize() {
echo "#-------------------------------------------------------------------------------#"
echo "#-------------------------------------------------------------------------------#"
echo "#-----------------------------          ----------------------------------------#"
echo "#----------------     +++    Installing files         +++ ----------------------#"
echo "#-----------------------------          ----------------------------------------#"
echo "#-------------------------------------------------------------------------------#"
echo "#-------------------------------------------------------------------------------#"

echo ""
echo "# --------- ------------ Customizing  -------- --------------- ---------"
echo ""

gen_hosts3
echo ""
echo "# --------- installing boot partition files (kernel, dts, dtb) ---------"
echo ""
echo "# --------- installing rootfs partition files (chroot, kernel modules) ---------"
echo ""

echo ""
echo "# --------- ------------ Finalizing  --------- --------------- ---------"
echo ""

POLICY_FILE=${ROOTFS_MNT}/usr/sbin/policy-rc.d

if [ -f ${POLICY_FILE} ]; then
    echo "removing ${POLICY_FILE}"
    sudo rm -f ${POLICY_FILE}
fi

# Rootfs -------#
# COMPNAME=${COMP_REL}_${COMP_PREFIX}
#
# echo ""
# echo "NOTE: extracting ${CURRENT_DIR}/${COMP_REL}_final--rootfs.tar.bz2 --> into sd-image"
# echo ""
# #sudo tar xfj ${CURRENT_DIR}/${COMP_REL}_final--rootfs.tar.bz2 -C ${ROOTFS_MNT}
# sudo tar xfj ${CURRENT_DIR}/jessie_socfpga-4.1-ltsi-rt_mib-hm3-mk-rip-inst_rootfs--rootfs.tar.bz2 -C ${ROOTFS_MNT}
#
#
# ### if mk-rip install instead:
# #sudo tar xfj ${CURRENT_DIR}/mksocfpga_jessie_socfpga-4.1-ltsi-rt-2016-04-28_mk-rip-rootfs-final.tar.bz2 -C ${ROOTFS_MNT}
#
# #echo "NOTE: extracting ${CURRENT_DIR}/jessie_socfpga-4.1-ltsi-rt_mharber-dev-deb--rootfs.tar.bz2 --> into sd-image"
# #sudo tar xfj ${CURRENT_DIR}/jessie_socfpga-4.1-ltsi-rt_mharber-dev-deb--rootfs.tar.bz2 -C ${ROOTFS_MNT}
#
# #sudo tar xfj ${MK_RIPROOTFS_NAME} -C ${ROOTFS_MNT}
#
# # MKRip -------#
# MK_BUILDTFILE_NAME="do-not-install"
#
# if [ -f ${MK_BUILDTFILE_NAME} ]; then #if file with that name exista
#     echo "installing ${MK_BUILDTFILE_NAME}"
# #    sudo mkdir -p ${ROOTFS_MNT}/home/machinekit/machinekit
# #    sudo tar xfj ${CURRENT_DIR}/${MK_BUILDTFILE_NAME} -C ${ROOTFS_MNT}/home/machinekit/machinekit
#     sudo tar xfj ${CURRENT_DIR}/${MK_BUILDTFILE_NAME} -C ${ROOTFS_MNT}/home/machinekit
# fi

#RHN:
#sudo tar xfvp ${ROOTFS_DIR/armhf-rootfs-*.tar -C ${ROOTFS_MNT
#set -x
#
# echo "copying boot sector files"

# sudo mkdir -p ${BOOT_MNT}
#sudo mount -o uid=1000,gid=1000 ${LOOP_DEV}${IMG_BOOT_PART} ${BOOT_MNT}

## Quartus files:
# if [ -d ${BOOT_FILES_DIR} ]; then
#     sudo cp -fv ${BOOT_FILES_DIR/socfpga* ${BOOT_MNT
# else
#     echo "mksocfpga boot files missing"
# fi

# kernel:
# sudo cp ${KERNEL_DIR}/arch/arm/boot/zImage ${BOOT_MNT}
#sudo cp ${BOOT_MNT}/vmlinuz-4.1* ${BOOT_MNT}/zImage

#inst_kernel_modules
#
# if [ -z "${PATCH_FILE}" ]; then
#     echo "MSG: Installing Quartus dts dtb .rbf for ${KERNEL_FOLDER_NAME} kernel"
# #    sudo cp -v ${KERNEL_DIR}/arch/arm/boot/dts/socfpga_cyclone5.dts ${BOOT_MNT}/socfpga.dts
#     sudo sh -c "/usr/local/bin/fdtdump ${KERNEL_DIR}/arch/arm/boot/dts/socfpga_cyclone5_de0_sockit.dtb > ${BOOT_MNT}/socfpga.dts"
#     sudo cp -v ${KERNEL_DIR}/arch/arm/boot/dts/socfpga_cyclone5_de0_sockit.dtb ${BOOT_MNT}/socfpga.dtb
# #    sudo cp -v -f ${BOOT_FILES_DIR}/socfpga.* ${BOOT_MNT}/
#     sudo cp -v -f ${BOOT_FILES_DIR}/socfpga.rbf ${BOOT_MNT}/
# else
#     echo "MSG: Installing 4.x.x kernel dts dtb and .rbf from Quartus"
# #q    sudo cp -v ${KERNEL_DIR}/arch/arm/boot/dts/socfpga_cyclone5_de0_sockit.dts ${BOOT_MNT}/socfpga.dts
#     sudo sh -c "/usr/local/bin/fdtdump ${KERNEL_DIR}/arch/arm/boot/dts/socfpga_cyclone5_de0_sockit.dtb > ${BOOT_MNT}/socfpga.dts"
#     sudo cp -v ${KERNEL_DIR}/arch/arm/boot/dts/socfpga_cyclone5_de0_sockit.dtb ${BOOT_MNT}/socfpga.dtb
# # copy .rbf file from quartus:
#     sudo cp -v ${BOOT_FILES_DIR}/socfpga.rbf ${BOOT_MNT}/socfpga.rbf
# fi

# # overlay firmware search path
# sudo mkdir -p ${ROOTFS_MNT}/lib/firmware/socfpga/dtbo
# sudo cp -v ${BOOT_FILES_DIR}/socfpga.rbf ${ROOTFS_MNT}/lib/firmware/socfpga
# sudo cp -v ${CURRENT_DIR}/test/hm2reg_uio.dtbo ${ROOTFS_MNT}/lib/firmware/socfpga/dtbo
#
#sudo umount ${BOOT_MNT}
#echo ""

}

install_uboot() {
echo ""
echo "installing ${UBOOT_SPLFILE}"
echo ""
sudo dd bs=512 if=${UBOOT_SPLFILE} of=${IMG_FILE} seek=2048 conv=notrunc
sudo sync
}

make_bmap_image() {
	echo ""
	echo "NOTE:  Will now make bmap image"
	echo ""
	cd ${CURRENT_DIR}
	bmaptool create -o ${IMG_NAME}.bmap ${IMG_NAME}
	tar -cjSf ${IMG_NAME}.tar.bz2 ${IMG_NAME}
	tar -cjSf ${IMG_NAME}-bmap.tar.bz2 ${IMG_NAME}.tar.bz2 ${IMG_NAME}.bmap
	echo ""
	echo "NOTE:  Bmap image created"
	echo ""
}

#------------------............ config run functions section ..................-----------#
echo "#---------------------------------------------------------------------------------- "
echo "#-----------+++     Full Image building process start       +++-------------------- "
echo "#---------------------------------------------------------------------------------- "
set -x

if [ ! -z "${WORK_DIR}" ]; then

#	GEN_IMAGE="yes"; GEN_ROOTFS="yes"; ADD_MK_USER="yes"; INST_LOCALKERNEL_DEBS="yes"; INST_UBOOT="yes"; CREATE_BMAP="yes"

#	GEN_IMAGE="yes"; ADD_MK_USER="yes"; INST_LOCALKERNEL_DEBS="yes"; INST_UBOOT="yes"; CREATE_BMAP="yes"

#	ADD_MK_USER="yes"; INST_LOCALKERNEL_DEBS="yes"; INST_UBOOT="yes"; CREATE_BMAP="yes"

#	GEN_IMAGE="yes"; INST_LOCALKERNEL_DEBS="yes"; INST_UBOOT="yes"; CREATE_BMAP="yes"

	CREATE_BMAP="yes"

	#install_deps # --->- only needed on first new run of a function see function above -------#
	#build_uboot
#	build_kernel

	if [[ ${GEN_IMAGE} == 'yes' ]]; then ## Create a fresh image and replace old if existing:
		create_image
	VIRGIN_IMAGE="yes"
	fi

	COMP_PREFIX=raw

	if [[ ${VIRGIN_IMAGE} == 'yes' ]]; then
		if [[ ${GEN_ROOTFS} == 'yes' ]]; then
			bind_mount_imagefile_and_rootfs
			generate_rootfs_into_image #-> creates custom qumu debian rootfs -#
#			unmount_imagefile_and_rootfs
			bind_unmount_imagefile_and_rootfs

			mount_imagefile_and_rootfs
			compress_rootfs
			unmount_imagefile_and_rootfs
			VIRGIN_IMAGE=""
		fi
	fi
	if [[ ${ADD_MK_USER} == 'yes' ]]; then
		bind_mount_imagefile_and_rootfs
		if [[ ${VIRGIN_IMAGE} == 'yes' ]]; then
			extract_rootfs
			VIRGIN_IMAGE=""
		fi
		initial_rootfs_user_setup_sh  # --> creates custom machinekit user setup and archive of final rootfs ---#
		bind_unmount_imagefile_and_rootfs

		COMP_PREFIX=final
		mount_imagefile_and_rootfs
		compress_rootfs
		unmount_imagefile_and_rootfs
	else
		COMP_PREFIX=final
	fi
	if [[ ${INST_LOCALKERNEL_DEBS} == 'yes' ]]; then
		bind_mount_imagefile_and_rootfs
		if [[ ${VIRGIN_IMAGE} == 'yes' ]]; then
			extract_rootfs
			VIRGIN_IMAGE=""
		fi
		inst_kernel_from_local_deb
		bind_unmount_imagefile_and_rootfs

		COMP_PREFIX=final-with-kernel-from-local-deb
		mount_imagefile_and_rootfs
		compress_rootfs
		unmount_imagefile_and_rootfs
	else
		COMP_PREFIX=final-with-kernel-from-local-deb
	fi
	if [[ ${INST_REPOKERNEL_DEBS} == 'yes' ]]; then
		bind_mount_imagefile_and_rootfs
		if [[ ${VIRGIN_IMAGE} == 'yes' ]]; then
			extract_rootfs
			VIRGIN_IMAGE=""
		fi
		inst_kernel_from_deb_repo
		bind_unmount_imagefile_and_rootfs

		COMP_PREFIX=final-kernel-from-deb
		mount_imagefile_and_rootfs
		compress_rootfs
		unmount_imagefile_and_rootfs
	else
		COMP_PREFIX=final-kernel-from-deb
	fi
	if [[ ${INST_MACHINEKIT_DEBS} == 'yes' ]]; then
		bind_mount_imagefile_and_rootfs
		if [[ ${VIRGIN_IMAGE} == 'yes' ]]; then
			extract_rootfs
			VIRGIN_IMAGE=""
		fi
		inst_mk_from_deb
		bind_unmount_imagefile_and_rootfs

		COMP_PREFIX=final-mk_from_deb
		mount_imagefile_and_rootfs
		compress_rootfs
		unmount_imagefile_and_rootfs
	else
		COMP_PREFIX=final-mk_from_deb
	fi
	if [[ ${INST_UBOOT} == 'yes' ]]; then
		if [[ ${VIRGIN_IMAGE} == 'yes' ]]; then
			mount_imagefile_and_rootfs
			extract_rootfs
			unmount_imagefile_and_rootfs
			VIRGIN_IMAGE=""
		fi
		echo "NOTE:  Will now install u-boot --> onto sd-card-image:"
		echo "--> ${IMG_FILE}"
		echo ""
		install_uboot   # --> onto sd-card-image (.img)
	fi
	if [[ ${CREATE_BMAP} == 'yes' ]]; then ## replace old image with a fresh:
		mount_imagefile_and_rootfs
		finalize
		unmount_imagefile_and_rootfs
		make_bmap_image
	fi

	# ## fetch_external_rootfs   # ---> for now redundant ---#
	#    sudo sh -c "apt -y install `apt-cache depends machinekit-rt-preempt | awk '/Depends:/{print$2}'`"
	#
	#
	echo "#---------------------------------------------------------------------------------- "
	echo "#-------             Image building process complete                       -------- "
	echo "#---------------------------------------------------------------------------------- "
else
	echo "#---------------------------------------------------------------------------------- "
	echo "#-------------     Unsuccessfull script not run      ------------------------------ "
	echo "#-------------  workdir parameter missing      ------------------------------------ "
	echo "#---------------------------------------------------------------------------------- "
fi

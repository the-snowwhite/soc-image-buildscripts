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

# v.02 TODO:   more cleanup

# 1.initial source: make minimal rootfs on amd64 Debian Jessie, according to "How to create bare minimum Debian Wheezy rootfs from scratch"
# http://olimex.wordpress.com/2014/07/21/how-to-create-bare-minimum-debian-wheezy-rootfs-from-scratch/
#------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------
# Variables Prerequsites
#apt_cmd=apt
apt_cmd="apt-get"
#------------------------------------------------------------------------------------------------------
WORK_DIR=${1}

MAIN_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SUB_SCRIPT_DIR=${MAIN_SCRIPT_DIR}/subscripts
CURRENT_DIR=`pwd`
#ROOTFS_MNT=/mnt/rootfs
ROOTFS_MNT=/tmp/myimage

ROOTFS_IMG=${CURRENT_DIR}/rootfs.img

CURRENT_DATE=`date -I`
REL_DATE=${CURRENT_DATE}
#REL_DATE=2016-03-07

ALT_GIT_KERNEL_URL="https://github.com/altera-opensource/linux-socfpga.git"

## http://releases.linaro.org/components/toolchain/binaries/5.2-2015.11-1/arm-linux-gnueabihf/gcc-linaro-5.2-2015.11-1-x86_64_arm-linux-gnueabihf.tar.xz
PCH52_CC_FOLDER_NAME="gcc-linaro-5.2-2015.11-1-x86_64_arm-linux-gnueabihf"
PCH52_CC_FILE="${PCH52_CC_FOLDER_NAME}.tar.xz"
PCH52_CC_URL="http://releases.linaro.org/components/toolchain/binaries/5.2-2015.11-1/arm-linux-gnueabihf/${PCH52_CC_FILE}"

#ALT_GIT_KERNEL_VERSION="4.1-ltsi-rt"
ALT_GIT_KERNEL_VERSION="4.1.22-ltsi-rt"
ALT_GIT_KERNEL_BRANCH="socfpga-${ALT_GIT_KERNEL_VERSION}"

#------------------------------------------------------------------------------------------------------
# Variables Custom settings
#------------------------------------------------------------------------------------------------------

#distro=sid
distro=jessie
#distro=stretch

## 2 part Expandable image
IMG_ROOT_PART=p2

BOARD=de0-nano-soc
#BOARD=de1-soc
#BOARD=sockit

UBOOT_VERSION="v2016.07"
#UBOOT_VERSION="v2016.05"
UBOOT_MAKE_CONFIG='u-boot-with-spl.sfp'
#APPLY_UBOOT_PATCH=yes
APPLY_UBOOT_PATCH=""

TOOLCHAIN_DIR=${CURRENT_DIR}

GIT_KERNEL_BRANCH=${ALT_GIT_KERNEL_BRANCH}

#KERNEL_LOCALVERSION="socfpga"
KERNEL_LOCALVERSION="socfpga-initrd"
KERNEL_REV="0.1"
# cross toolchains
#--------- 4.1 + kernels -------------------------------------------------------------------#
KERNEL_VERSION=${ALT_GIT_KERNEL_VERSION}
KERNEL_URL=${ALT_GIT_KERNEL_URL}

#-----  select global toolchain  ------#

CC_FOLDER_NAME=$PCH52_CC_FOLDER_NAME
CC_URL=$PCH52_CC_URL

EnableSystemdNetworkedLink='/etc/systemd/system/multi-user.target.wants/systemd-networkd.service'
EnableSystemdResolvedLink='/etc/systemd/system/multi-user.target.wants/systemd-resolved.service'


#------------------------------------------------------------------------------------------------------
# Variables Postrequsites
#------------------------------------------------------------------------------------------------------
KERNEL_MIDDLE_NAME=${GIT_KERNEL_BRANCH}

SD_FILE_PRELUDE=mksocfpga_${distro}_${KERNEL_VERSION}-${REL_DATE}
SD_IMG_NAME=${SD_FILE_PRELUDE}-${BOARD}_sd.img
SD_IMG_FILE=${CURRENT_DIR}/${SD_IMG_NAME}

#--------------  u-boot  --------------#

if [ "$BOARD" == "de0-nano-soc" ]; then
   UBOOT_BOARD='de0_nano_soc'
   BOOT_FILES_DIR=${MAIN_SCRIPT_DIR}/../boot_files/${nanofolder}
elif [ "$BOARD" == "de1-soc" ]; then
   UBOOT_BOARD='de0_nano_soc'
   BOOT_FILES_DIR=${MAIN_SCRIPT_DIR}/../boot_files/${de1folder}
elif [ "$BOARD" == "sockit" ]; then
   UBOOT_BOARD='sockit'
   BOOT_FILES_DIR=${MAIN_SCRIPT_DIR}/../boot_files/${sockitfolder}
fi

CC_DIR="${CURRENT_DIR}/${CC_FOLDER_NAME}"
CC_FILE="${CC_FOLDER_NAME}.tar.xz"
CC="${CC_DIR}/bin/arm-linux-gnueabihf-"

COMP_REL=debian-${distro}_socfpga

KERNEL_PARENT_DIR=${CURRENT_DIR}/arm-linux-${KERNEL_MIDDLE_NAME}-gnueabifh-kernel

UBOOT_SPLFILE=${CURRENT_DIR}/uboot/${UBOOT_MAKE_CONFIG}
KERNEL_TAG=${KERNEL_VERSION}23-${KERNEL_LOCALVERSION}

#-----------------------------------------------------------------------------------
# local functions for external scripts
#-----------------------------------------------------------------------------------

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
# install linaro gcc crosstoolchain dependency:
	sudo ${apt_cmd} -y install lib32stdc++6
else
	echo ""
	echo "Script_MSG: Toolchain allready installed in -->"
	echo "Script_MSG: ${CC_DIR}"
	echo ""
fi
}

install_uboot_dep() {
# install deps for u-boot build
	sudo ${apt_cmd} -y install lib32z1 device-tree-compiler bc u-boot-tools
}

install_kernel_dep() {
# install deps for kernel build
	sudo ${apt_cmd} -y install build-essential fakeroot bc u-boot-tools
	sudo apt-get -y build-dep linux
}

install_deps() {
	get_toolchain
	install_uboot_dep
#	install_kernel_dep
#	#sudo ${apt_cmd} install kpartx
#	install_rootfs_dep
#	sudo ${apt_cmd} install bmap-tools
	echo "MSG: deps installed"
}

#-----------------------------------------------------------------------------------
# external scripted functions
#-----------------------------------------------------------------------------------

function build_uboot {
	${SUB_SCRIPT_DIR}/build_uboot.sh ${CURRENT_DIR} ${MAIN_SCRIPT_DIR} ${UBOOT_VERSION} ${BOARD}  ${UBOOT_BOARD} ${UBOOT_MAKE_CONFIG} ${CC_FOLDER_NAME} ${APPLY_UBOOT_PATCH} | tee ${CURRENT_DIR}/build-uboot-log.txt
}

function build_kernel {
	${SUB_SCRIPT_DIR}/build_kernel.sh ${CURRENT_DIR} ${TOOLCHAIN_DIR} ${MAIN_SCRIPT_DIR} ${CC_FOLDER_NAME} ${KERNEL_MIDDLE_NAME} ${GIT_KERNEL_BRANCH} ${KERNEL_VERSION} ${KERNEL_URL} ${KERNEL_LOCALVERSION} ${KERNEL_REV}  ${PATCH_URL} | tee ${CURRENT_DIR}/build_kernel-log.txt
}

create_image() {
	${SUB_SCRIPT_DIR}/create_img.sh ${CURRENT_DIR} ${IMG_PARTS} ${SD_IMG_FILE} | tee ${CURRENT_DIR}/create_img-log.txt
}

generate_rootfs_into_image() {
	sh -c "${SUB_SCRIPT_DIR}/gen_rootfs-qemu_2.5.sh ${CURRENT_DIR} ${ROOTFS_IMG} ${distro} ${ROOTFS_MNT}" | tee ${CURRENT_DIR}/gen_rootfs-qemu_2.5-log.txt
}

#-----------------------------------------------------------------------------------
# local functions
#-----------------------------------------------------------------------------------

kill_ch_proc(){
FOUND=0

for ROOT in /proc/*/root; do
	LINK=$(sudo readlink ${ROOT})
	if [ "x${LINK}" != "x" ]; then
		if [ "x${LINK:0:${#KILL_PREFIX}}" = "x${KILL_PREFIX}" ]; then
			# this process is in the chroot...
			PID=$(basename $(dirname "${ROOT}"))
			sudo kill -9 "${PID}"
			FOUND=1
		fi
	fi
done
}

mount_sdimagefile(){
	sudo sync
	LOOP_DEV=`eval sudo losetup -f --show ${SD_IMG_FILE}`
	sudo mkdir -p ${ROOTFS_MNT}
	sudo mount ${LOOP_DEV}${IMG_ROOT_PART} ${ROOTFS_MNT}
	echo "#--------------------------------------------------------------------------------------#"
	echo "# Scr_MSG:                                                                             #"
	echo "# ${SD_IMG_FILE}"
	echo "# Is mounted in ---> ${LOOP_DEV}"
	echo "#                                                                                      #"
	echo "# ${LOOP_DEV}${IMG_ROOT_PART}"
	echo "# Is mounted in ---> ${ROOTFS_MNT}"
	echo "#                                                                                      #"
	echo "#--------------------------------------------------------------------------------------#"
}

mount_rootfs_imagefile(){
	sudo sync
	mkdir -p ${ROOTFS_MNT}
	sudo mount ${ROOTFS_IMG} ${ROOTFS_MNT}
	echo "#--------------------------------------------------------------------------------------#"
	echo "# Scr_MSG:                                                                             #"
	echo "# ${ROOTFS_IMG}"
	echo "# Is mounted in ---> ${ROOTFS_MNT}"
	echo "#                                                                                      #"
	echo "#--------------------------------------------------------------------------------------#"
}

unmount_sdimagefile(){
	echo ""
	echo "Scr_MSG: Unmounting ---> ${ROOTFS_MNT}"
	sudo umount -R ${ROOTFS_MNT}
	echo ""
	echo "Scr_MSG: Unmounting Imagefile in ---> ${LOOP_DEV}"
	sudo losetup -d ${LOOP_DEV}
	echo ""
}

unmount_rootfs_imagefile(){
	echo "Scr_MSG: Unmounting Imagefile in ---> ${ROOTFS_MNT}"
	sudo umount -R ${ROOTFS_MNT}
}

bind_rootfs(){
	sudo sync
	sudo mkdir -p ${ROOTFS_MNT}
	sudo mount -o bind /proc ${ROOTFS_MNT}/proc
	sudo mount -o bind /sys ${ROOTFS_MNT}/sys
	sudo mount -o bind /dev ${ROOTFS_MNT}/dev

	echo "#--------------------------------------------------------------------------------------#"
	echo "# Scr_MSG: ${ROOTFS_MNT} Bind mounted                                                  #"
	echo "#                                                                                      #"
	echo "#--------------------------------------------------------------------------------------#"
}
 
bind_unmount_rootfs_imagefile(){
	cd ${CURRENT_DIR}
	CDR=`eval pwd`
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo ""
	echo "Scr_MSG: current dir is now: ${CDR}"
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo ""
	sudo sync
	if [ -d "${ROOTFS_MNT}/home" ]; then
		echo ""
		echo "Scr_MSG: Will now (unbind) ummount ${ROOTFS_MNT}"
		RES=`eval sudo umount -R ${ROOTFS_MNT}`
		echo ""
		echo "Scr_MSG: Unmont result = ${RES}"
		echo "Scr_MSG: Unmont return value = ${?}"
		echo ""
	else
		echo ""
		echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		echo ""
		echo "Scr_MSG: Rootfs was unmounted correctly"
		echo ""
		echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		echo ""
	fi

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
	echo "${COMPNAME} rootfs extraction finished .."
fi
}

gen_local_sources_list() {
sudo cp -f ${ROOTFS_MNT}/etc/apt/sources.list ${CURRENT_DIR}

distro=jessie
sudo sh -c 'cat <<EOT > '$ROOTFS_MNT'/etc/apt/sources.list
#------------------------------------------------------------------------------#
#                   OFFICIAL DEBIAN REPOS                    
#------------------------------------------------------------------------------#

###### Debian Main Repos
#deb http://ftp.se.debian.org/debian/ '$distro' main contrib non-free 
#deb-src http://ftp.se.debian.org/debian/ '$distro' main 


##### Local Debian mirror 
deb http://kubuntu16-srv.holotronic.lan/debian/ '$distro' main contrib non-free 
deb-src http://kubuntu16-srv.holotronic.lan/debian/ '$distro' main 

###### Debian Update Repos
deb http://security.debian.org/ '$distro'/updates main contrib non-free 

EOT'
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

'${apt_cmd}' -y update
'${apt_cmd}' -y --force-yes upgrade

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


echo "ECHO: Will now run '${apt_cmd}' update, upgrade"
'${apt_cmd}' -y update
'${apt_cmd}' -y --force-yes upgrade

echo "ECHO: adding mk sources.list"
apt-key adv --keyserver keyserver.ubuntu.com --recv 43DDF224
echo "deb http://deb.machinekit.io/debian jessie main" > /etc/apt/sources.list.d/machinekit.list

'${apt_cmd}' -y update

rm -f /etc/resolv.conf

# enable systemd-networkd
if [ ! -L '${EnableSystemdNetworkedLink}' ]; then
	echo ""
	echo "ECHO:--> Enabling Systemd Networkd"
	echo ""
	ln -s /lib/systemd/system/systemd-networkd.service ${EnableSystemdNetworkedLink}
fi

enable systemd-resolved
if [ ! -L '${EnableSystemdResolvedLink}' ]; then
	echo ""
	echo "ECHO:--> Enabling Systemd Resolved"
	echo ""
	ln -s /lib/systemd/system/systemd-resolved.service ${EnableSystemdResolvedLink}
	rm -f /etc/resolv.conf
	ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
fi

exit
EOF'

sudo chmod +x ${ROOTFS_MNT}/home/initial.sh
}

initial_rootfs_user_setup_sh() {
echo "------------------------------------------------------------"
echo "----  running initial_rootfs_user_setup_sh      ------------"
echo "------------------------------------------------------------"
set -e

gen_local_sources_list

sudo cp /etc/resolv.conf ${ROOTFS_MNT}/etc/resolv.conf

echo "Script_MSG: installing apt-transport-https"
sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/${apt_cmd} -y update
sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/${apt_cmd} -y --force-yes upgrade
sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/${apt_cmd} -y install apt-transport-https

echo "Script_MSG: will add user"
gen_add_user_sh
echo "Script_MSG: gen_add_user_shfinhed ... will now run in chroot"

sudo chroot ${ROOTFS_MNT} /bin/bash -c /home/add_user.sh

gen_initial_sh
echo "Script_MSG: gen_initial.sh finhed ... will now run in chroot"

sudo chroot ${ROOTFS_MNT} /bin/bash -c /home/initial.sh

sudo sync

cd ${CURRENT_DIR}
sudo cp -f ${CURRENT_DIR}/sources.list ${ROOTFS_MNT}/etc/apt/sources.list

echo "Script_MSG: initial_rootfs_user_setup_sh finished .. ok .."

}

inst_kernel_from_deb_repo(){

gen_local_sources_list

sudo rm -f ${ROOTFS_MNT}/etc/resolv.conf
sudo cp -f /etc/resolv.conf ${ROOTFS_MNT}/etc/resolv.conf

sudo sh -c 'cat <<"EOF" > "'${ROOTFS_MNT}'/etc/kernel/postinst.d/zzz-socfpga-mkimage"
#!/bin/sh -e

version="$1"

echo "Installing new uInitrd to SD"

mkimage -A arm -O linux -T ramdisk -a 0x0 -e 0x0 -n /boot/initrd.img-"${version}" -d /boot/initrd.img-"${version}" /boot/uInitrd-$"${version}" 

EOF'
sudo chmod 755 "${ROOTFS_MNT}/etc/kernel/postinst.d/zzz-socfpga-mkimage"

#${apt_cmd} -y install hm2reg-uio-dkms

#sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/${apt_cmd} -y install apt-transport-https

#sudo sh -c 'echo "deb [arch=armhf] https://deb.mah.priv.at/ jessie socfpga" > '${ROOTFS_MNT}'/etc/apt/sources.list.d/debmah.list'
sudo sh -c 'echo "deb [arch=armhf] http://kubuntu16-ws.holotronic.lan/debian jessie main" > '${ROOTFS_MNT}'/etc/apt/sources.list.d/mibsocdeb.list'

sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/${apt_cmd} -y update
#sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv 4FD9D713
#sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/${apt_cmd} -y update
sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/${apt_cmd} -y --force-yes upgrade
set +e
sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/${apt_cmd} -y --force-yes install linux-headers-${KERNEL_TAG} linux-image-${KERNEL_TAG}
set -e
#  ##sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/${apt_cmd} -y install hm2reg-uio-dkms

cd ${CURRENT_DIR}
sudo cp -f ${CURRENT_DIR}/sources.list ${ROOTFS_MNT}/etc/apt/sources.list
sudo chroot --userspec=root:root ${ROOTFS_MNT} /bin/rm -f /etc/resolv.conf
sudo chroot --userspec=root:root ${ROOTFS_MNT} /bin/ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf

PREFIX=${ROOTFS_MNT}
kill_ch_proc

}


make_uInitrd(){

kver_prepend="${ROOTFS_MNT}/boot/initrd.img-"
size=${#kver_prepend} 
u_name=`ls ${kver_prepend}${KERNEL_VERSION:0:3}.*`
kver=${u_name:${size}}
echo ""
echo "kver = ${kver}"
echo ""
set -x
sudo mkimage -A arm -O linux -T ramdisk -a 0x0 -e 0x0 -n ${ROOTFS_MNT}/boot/initrd.img-${kver} -d ${ROOTFS_MNT}/boot/initrd.img-${kver} ${ROOTFS_MNT}/boot/uInitrd-${kver}

set +x

}

gen_hosts3() {

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
echo "#----------------   +++      Customizing          +++  -------------------------#"
echo "#-----------------------------          ----------------------------------------#"
echo "#-------------------------------------------------------------------------------#"
echo "#-------------------------------------------------------------------------------#"

echo ""
echo "# --------- ------------ Customizing  -------- --------------- ---------"
echo ""
echo "# -----------------    Changing hostname to mksocfpga3     -------------"
echo ""
gen_hosts3
echo ""
echo "# --------->       Removing qemu policy file          <--------------- ---------"
echo ""

POLICY_FILE=${ROOTFS_MNT}/usr/sbin/policy-rc.d

if [ -f ${POLICY_FILE} ]; then
    echo "removing ${POLICY_FILE}"
    sudo rm -f ${POLICY_FILE}
fi
echo ""
echo "# --------->       Restoring resolv.conf link         <--------------- ---------"
echo ""
sudo chroot --userspec=root:root ${ROOTFS_MNT} /bin/rm -f /etc/resolv.conf
sudo chroot --userspec=root:root ${ROOTFS_MNT} /bin/ln -s /lib/systemd/system/systemd-resolved.service /etc/resolv.conf

echo ""
echo "# --------- ------------>   Finalized    --- --------- --------------- ---------"
echo ""

}


#------------------............ config run functions section ..................-----------#

install_uboot() {
echo ""
echo "installing ${UBOOT_SPLFILE}"
echo ""
sudo dd bs=512 if=${UBOOT_SPLFILE} of=${SD_IMG_FILE} seek=2048 conv=notrunc
sudo sync
}

make_bmap_image() {
	echo ""
	echo "NOTE:  Will now make bmap image"
	echo ""
	cd ${CURRENT_DIR}
	bmaptool create -o ${SD_IMG_FILE}.bmap ${SD_IMG_FILE}
	tar -cjSf ${SD_IMG_FILE}.tar.bz2 ${SD_IMG_FILE}
	tar -cjSf ${SD_IMG_FILE}-bmap.tar.bz2 ${SD_IMG_FILE}.tar.bz2 ${SD_IMG_FILE}.bmap
	echo ""
	echo "NOTE:  Bmap image created"
	echo ""
}

format_rootfs(){
	ROOTFS_TYPE=ext4
	ROOTFS_LABEL=rootfs
	ext4_options="-O ^metadata_csum,^64bit"
	#mkfs_options="${ext4_options}"
	mkfs_options=""

	mkfs="mkfs.${ROOTFS_TYPE}"
	media_prefix=${LOOP_DEV}
	media_rootfs_partition=p2

	mkfs_partition="${media_prefix}${media_rootfs_partition}"
	mkfs_label="-L ${ROOTFS_LABEL}"
	
	sudo sh -c "LC_ALL=C ${mkfs} ${mkfs_options} ${ROOTFS_IMG} ${mkfs_label}"

#	sudo sh -c "LC_ALL=C ${mkfs} ${mkfs_partition} ${mkfs_label}"
}

inst_comp_prefis_rootfs(){
	mount_rootfs_imagefile
	extract_rootfs
	VIRGIN_IMAGE=""
	unmount_rootfs_imagefile
}

compress_prefix_rootfs(){
	mount_rootfs_imagefile
	compress_rootfs
	unmount_rootfs_imagefile
}

if [ ! -z "${WORK_DIR}" ]; then


#---------------------------------------------------------------------------------- #
#-----------+++     Full Flow Control                       +++-------------------- #
#---------------------------------------------------------------------------------- #

#install_deps # --->- only needed on first new run of a function see function above -------#


#BUILD_UBOOT="yes";
# 
#BUILD_KERNEL="yes";
# 
#GREATE_ROOTFS_IMAGE="yes";
#
#GEN_ROOTFS="yes";
#
#ADD_MK_USER="yes";
# #  INST_LOCALKERNEL_DEBS="yes";
#
#INST_REPOKERNEL_DEBS="yes";
# #	ISCSI_CONV="yes";
# # # #	MAKE_UINITRD="yes";
#
CREATE_BMAP="yes"; INST_UBOOT="yes";
# 

echo "#---------------------------------------------------------------------------------- "
echo "#-----------+++     Full Image building process start       +++-------------------- "
echo "#---------------------------------------------------------------------------------- "
set -e


	if [[ ${BUILD_UBOOT} == 'yes' ]]; then ## Create a fresh image and replace old if existing:
		build_uboot
	fi

	if [[ ${BUILD_KERNEL} == 'yes' ]]; then ## Create a fresh image and replace old if existing:
		rm -f ${KERNEL_PARENT_DIR}/*.deb
		build_kernel
	fi

	if [[ ${GREATE_ROOTFS_IMAGE} == 'yes' ]]; then ## Create a fresh image and replace old if existing:
		IMG_PARTS=0
		create_image
		VIRGIN_IMAGE="yes"
	fi

	COMP_PREFIX=raw
	
	if [[ ${GEN_ROOTFS} == 'yes' ]]; then
		if [[ ${VIRGIN_IMAGE} != 'yes' ]]; then
			echo ""
			echo "Script_MSG: No new image generated formatting old image root partition"
			echo ""
			format_rootfs
		fi
		mount_rootfs_imagefile
		bind_rootfs
		generate_rootfs_into_image #-> creates custom qumu debian rootfs -#
		bind_unmount_rootfs_imagefile

		compress_prefix_rootfs
		VIRGIN_IMAGE=""
	fi

	COMP_PREFIX=final	
	
	if [[ ${ADD_MK_USER} == 'yes' ]]; then
		if [[ ${VIRGIN_IMAGE} == 'yes' ]]; then
			inst_comp_prefis_rootfs
		fi
		mount_rootfs_imagefile
		bind_rootfs
		initial_rootfs_user_setup_sh | tee ${CURRENT_DIR}/usr_setup-log.txt # --> creates custom machinekit user setup and archive of final rootfs ---#
		bind_unmount_rootfs_imagefile

		compress_prefix_rootfs
	fi
		
	if [[ ${INST_LOCALKERNEL_DEBS} == 'yes' ]]; then
		if [[ ${VIRGIN_IMAGE} == 'yes' ]]; then
			inst_comp_prefis_rootfs
		fi
		mount_rootfs_imagefile
		bind_rootfs
		inst_kernel_from_local_deb | tee ${CURRENT_DIR}/local_kernel_install-log.txt
		bind_unmount_rootfs_imagefile

		COMP_PREFIX=final-with-kernel-from-local-deb
		compress_prefix_rootfs
	else
		if [[ ${INST_REPOKERNEL_DEBS} == 'yes' ]]; then
			if [[ ${VIRGIN_IMAGE} == 'yes' ]]; then
				inst_comp_prefis_rootfs
			fi
			mount_rootfs_imagefile
			bind_rootfs
			inst_kernel_from_deb_repo | tee ${CURRENT_DIR}/deb_kernel_install-log.txt
			bind_unmount_rootfs_imagefile
			COMP_PREFIX=final-kernel-from-repo-deb

			compress_prefix_rootfs
		fi
	fi
	
	if [[ ${MAKE_UINITRD} == 'yes' ]]; then
		if [[ ${VIRGIN_IMAGE} == 'yes' ]]; then
			inst_comp_prefis_rootfs
		fi
		mount_rootfs_imagefile
		bind_rootfs
		make_uInitrd
		echo "Files in boot folder -->"
		boot_content=`ls -lat ${ROOTFS_MNT}/boot`
		echo "${boot_content}"
		bind_unmount_rootfs_imagefile

		COMP_PREFIX=final-kernel-from-deb_uinitrd
		compress_prefix_rootfs
	fi
	

	if [[ ${CREATE_BMAP} == 'yes' ]]; then ## replace old image with a fresh:
		if [[ ${INST_UBOOT} == 'yes' ]]; then
			IMG_PARTS=2
			create_image
			COMP_PREFIX=final-kernel-from-repo-deb

			mount_sdimagefile
			extract_rootfs
			
			finalize
			unmount_sdimagefile
			echo "NOTE:  Will now install u-boot --> onto sd-card-image:"
			echo "--> ${SD_IMG_FILE}"
			echo ""
			install_uboot | tee ${CURRENT_DIR}/u-boot_install-log.txt   # --> onto sd-card-image (.img)
			make_bmap_image
		fi
# 		mount_imagefile_and_rootfs
# 		finalize
# 		unmount_imagefile_and_rootfs
# 		make_bmap_image
	fi

	echo "#---------------------------------------------------------------------------------- "
	echo "#-------             Image building process complete                       -------- "
	echo "#---------------------------------------------------------------------------------- "
else
	echo "#---------------------------------------------------------------------------------- "
	echo "#-------------     Unsuccessfull script not run      ------------------------------ "
	echo "#-------------  workdir parameter missing      ------------------------------------ "
	echo "#---------------------------------------------------------------------------------- "
fi

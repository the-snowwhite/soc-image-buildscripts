#!/bin/bash
#------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------
# Variables Prerequsites
#apt_cmd=apt
apt_cmd="apt-get"
#------------------------------------------------------------------------------------------------------
WORK_DIR=${1}

distro=jessie
ALT_GIT_KERNEL_VERSION="4.1.22-ltsi-rt"

MAIN_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SUB_SCRIPT_DIR=${MAIN_SCRIPT_DIR}/subscripts
CURRENT_DIR=`pwd`
ROOTFS_MNT=/tmp/myimage
## 2 part Expandable image
IMG_ROOT_PART=p2

ROOTFS_IMG=${CURRENT_DIR}/rootfs.img
SD_IMG=${CURRENT_DIR}/mksocfpga_jessie_4.1.22-ltsi-rt-2016-07-17-de0-nano-soc_sd.img


COMP_REL=debian-${distro}-socfpga

KERNEL_LOCALVERSION="socfpga-initrd"
KERNEL_VERSION=${ALT_GIT_KERNEL_VERSION}


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

bind_mount_imagefile_and_rootfs(){
	mkdir -p /tmp/myimage
	sudo sync
	LOOP_DEV=`eval sudo losetup -f --show ${SD_IMG}`
	sudo mkdir -p ${ROOTFS_MNT}
	sudo mount ${LOOP_DEV}${IMG_ROOT_PART} ${ROOTFS_MNT}
	cd ${ROOTFS_MNT} # or where you are preparing the chroot dir
	sudo mount -t proc proc proc/
	sudo mount -t sysfs sys sys/
	sudo mount -o bind /dev dev/

	echo "#--------------------------------------------------------------------------------------#"
	echo "# Scr_MSG: Bind mounted                                                                #"
	echo "# ${SD_IMG}"
	echo "# Is mounted in ---> ${LOOP_DEV}"
	echo "#                                                                                      #"
	echo "# ${LOOP_DEV}${IMG_ROOT_PART}"
	echo "# Is mounted in ---> ${ROOTFS_MNT}"
	echo "#                                                                                      #"
	echo "#--------------------------------------------------------------------------------------#"
}

 
bind_unmount_imagefile_and_rootfs(){
	CDR=`eval pwd`
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo ""
	echo "Scr_MSG: current dir was: ${CDR}"
	cd ${CURRENT_DIR}
	CDR=`eval pwd`
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo ""
	echo "Scr_MSG: current dir is now: ${CDR}"
	echo ""
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo ""
	set +e
	echo "Scr_MSG: Killing all processes in ---> ${ROOTFS_MNT}"
	KILL_PREFIX=${ROOTFS_MNT}
	kill_ch_proc
	sudo sync
# 	echo "Scr_MSG: Removing all mounts in ---> ${ROOTFS_MNT}"
# 	KILL_PREFIX=${ROOTFS_MNT}
# 	umount_ch_proc
	sudo sync
	if [ -d "${ROOTFS_MNT}/home" ]; then
		echo ""
		echo "Scr_MSG: Will now (unbind) ummount ${ROOTFS_MNT}"
		RES=sudo umount -R ${ROOTFS_MNT}
		echo ""
		echo "Scr_MSG: Unmont result = ${RES}"
		echo "Scr_MSG: Unmont return value = ${?}"
		echo ""
	else
		echo ""
		echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		echo ""
		echo "Scr_MSG: Rootfs unmounted correctly"
		echo ""
		echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		echo ""
	fi
	echo "Scr_MSG: Now unmounting Imagefile in ---> ${LOOP_DEV}"
	set -e
	sudo losetup -d ${LOOP_DEV}
}

mount_sdimagefile(){
	sudo sync
	LOOP_DEV=`eval sudo losetup -f --show ${SD_IMG}`
	echo "#--------------------------------------------------------------------------------------#"
	echo "# Scr_MSG:                                                                             #"
	echo "# ${SD_IMG}"
	echo "# Is mounted in ---> ${LOOP_DEV}"
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

mount_imagefile_and_rootfs(){
	sudo sync
	LOOP_DEV=`eval sudo losetup -f --show ${SD_IMG}`
	sudo mkdir -p ${ROOTFS_MNT}
	sudo mount ${LOOP_DEV}${IMG_ROOT_PART} ${ROOTFS_MNT}
	echo "#--------------------------------------------------------------------------------------#"
	echo "# Scr_MSG:                                                                             #"
	echo "# ${SD_IMG}"
	echo "# Is mounted in ---> ${LOOP_DEV}"
	echo "#                                                                                      #"
	echo "# ${LOOP_DEV}${IMG_ROOT_PART}"
	echo "# Is mounted in ---> ${ROOTFS_MNT}"
	echo "#                                                                                      #"
	echo "#--------------------------------------------------------------------------------------#"
}

unmount_sdimagefile(){
	echo "Scr_MSG: Unmounting Imagefile in ---> ${LOOP_DEV}"
	sudo losetup -d ${LOOP_DEV}
}

unmount_rootfs_imagefile(){
	echo "Scr_MSG: Unmounting Imagefile in ---> ${ROOTFS_MNT}"
	sudo umount -R ${ROOTFS_MNT}
}

unmount_imagefile_and_rootfs(){
#	sudo kpartx -d -s -v ${SD_IMG}
	echo "Scr_MSG: Unmounting ---> ${ROOTFS_MNT}"
#	KILL_PREFIX=${ROOTFS_MNT}
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
	sudo tar -cjSf ${CURRENT_DIR}/${COMPNAME}_rootfs.tar.bz2 *
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
	sudo tar xfj ${CURRENT_DIR}/${COMPNAME}_rootfs.tar.bz2 -C ${ROOTFS_MNT}
	echo "${COMPNAME} rootfs compressed finish ... unmounting"
fi
}


inst_comp_prefis_rootfs(){
	mount_rootfs_imagefile
	extract_rootfs
#	VIRGIN_IMAGE=""
	unmount_rootfs_imagefile
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

inst_kernel_from_deb_repo() {
gen_local_sources_list

sudo cp -f /etc/resolv.conf ${ROOTFS_MNT}/etc/resolv.conf

sudo sh -c 'echo "deb [arch=armhf] http://kubuntu16-ws.holotronic.lan/debian jessie main" > '${ROOTFS_MNT}'/etc/apt/sources.list.d/mibsocdeb.list'

sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/${apt_cmd} -y update
#sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv 4FD9D713
#sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/${apt_cmd} -y update
sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/${apt_cmd} -y --force-yes upgrade
set +e
sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/${apt_cmd} -y --force-yes install linux-headers-${KERNEL_VERSION}23-${KERNEL_LOCALVERSION} linux-image-${KERNEL_VERSION}23-${KERNEL_LOCALVERSION}
set -e
sleep 2
cd ${CURRENT_DIR}
sudo cp -f ${CURRENT_DIR}/sources.list ${ROOTFS_MNT}/etc/apt/sources.list
sudo chroot --userspec=root:root ${ROOTFS_MNT} /bin/rm -f /etc/resolv.conf
sudo chroot --userspec=root:root ${ROOTFS_MNT} /bin/ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
sleep 2
#PREFIX=${ROOTFS_MNT}
#kill_ch_proc

}


echo "#---------------------------------------------------------------------------------- "
echo "#-----------+++     Script process              start       +++-------------------- "
echo "#---------------------------------------------------------------------------------- "
set -e -x

# 
# mount_sdimagefile
# sudo dd bs=4K if=${LOOP_DEV}${IMG_ROOT_PART} of=${ROOTFS_IMG}
# unmount_sdimagefile
# 

# # #IMG_NAME=${FILE_PRELUDE}-${BOARD}_sd.img
# # IMG_NAME=rootfs.img
# # #IMG_NAME=debian-8.4-machinekit-de0-armhf-2016-04-27-4gb_mib.img
# # IMG_FILE=${CURRENT_DIR}/${IMG_NAME}
# # 
# # tar -cjSf ${IMG_FILE}.tar.bz2 ${IMG_FILE}
# # 
#

# IMG_NAME=rootfs.img
# IMG_FILE=${CURRENT_DIR}/${IMG_NAME}
# tar -xjSf ${IMG_FILE}.tar.bz2
# 

# 
# COMP_PREFIX=final	
# inst_comp_prefis_rootfs
# IMG_NAME=rootfs.img
# IMG_FILE=${CURRENT_DIR}/${IMG_NAME}
# tar -cjSf ./${IMG_NAME}_final.tar.bz2 ${IMG_FILE}
# 

mount_rootfs_imagefile

mkdir -p ${ROOTFS_MNT}/boot

sudo mount -o bind /proc ${ROOTFS_MNT}/proc
sudo mount -o bind /sys ${ROOTFS_MNT}/sys
sudo mount -o bind /dev ${ROOTFS_MNT}/dev
sudo chroot ${ROOTFS_MNT}

#inst_kernel_from_deb_repo

#exit

sudo umount -R ${ROOTFS_MNT}
#update-initramfs -c -t -k "3.10.43"
#mkimage -A arm -O linux -T ramdisk -C none -a 0 -e 0 -n uInitrd -d /boot/initrd.img-3.10.42 /boot/uInitrd-3.10.43
#cp /boot/uInitrd-3.10.43 /boot/uInitrd


echo "#---------------------------------------------------------------------------------- "
echo "#-------             Script         process complete                       -------- "
echo "#---------------------------------------------------------------------------------- "

#!/bin/bash

# Create, partition and mount SD-Card image:
#------------------------------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------------------------------
CURRENT_DIR=`pwd`
WORK_DIR=${1}
IMG_PARTS=${2}
IMG_FILE=${3}

ROOTFS_IMG=${WORK_DIR}/rootfs.img
ROOTFS_TYPE=ext4
ROOTFS_LABEL=rootfs


ext4_options="-O ^metadata_csum,^64bit"
#mkfs_options="${ext4_options}"
mkfs_options=""

mkfs="mkfs.${ROOTFS_TYPE}"
media_rootfs_partition=p2

mkfs_label="-L ${ROOTFS_LABEL}"


mount_sd_image_file(){
	LOOP_DEV=`eval sudo losetup -f --show ${IMG_FILE}`
	echo "#-----------------------------------------------------------------------------------	#"
	echo "#                                                                                   	#"
	echo "# Scr_MSG: Image file mounted in LOOP_DEV--> ${LOOP_DEV}                            	#"
	echo "#                                                                                   	#"
	echo "# Scr_MSG: sudo losetup -f --show ${IMG_FILE}                                       	#"
	echo "# Output = ${LOOP_DEV}                                                              	#"
	echo "#                                                                                   	#"
	echo "#-----------------------------------------------------------------------------------	#"
}

unmount_sd_image_file(){
	sudo losetup -d ${LOOP_DEV}
}

fdisk_2part() {
sudo fdisk ${LOOP_DEV} << EOF
n
p
1

+1M
t
a2
n
p
2


w
EOF
}

fdisk_3part_swap() {
sudo fdisk ${LOOP_DEV} << EOF
n
p
1

+1M
t
a2
n
p
2

+5600M
n
p
3


t
3
82
w
EOF
}

create_sdcard_img() {
#--------------- Initial sd-card image - partitioned --------------
echo "#-------------------------------------------------------------------------------#"
echo "#-----------------------------          ----------------------------------------#"
echo "#---------------     +++ generating sd-card image  zzz  +++ ........  ----------#"
echo "#---------------------------  Please  wait   -----------------------------------#"
echo "#-------------------------------------------------------------------------------#"

sudo dd if=/dev/zero of=${IMG_FILE} bs=4K count=1675K
mount_sd_image_file

if [ "${IMG_PARTS}" == "2" ]; then
	fdisk_2part
elif [ "${IMG_PARTS}" == "3" ]; then
	fdisk_3part_swap
else
	echo ""
	echo "SubScr_MSG: No Valid number of partitions given ie: 2 or 3(with swap)"
	echo ""
fi
sudo sync
sudo partprobe -s ${LOOP_DEV}
sudo sync

echo "SubScr_MSG: creating file systems"
media_prefix=${LOOP_DEV}
mkfs_partition="${media_prefix}${media_rootfs_partition}"

sudo sh -c "LC_ALL=C ${mkfs} ${mkfs_options} ${mkfs_partition} ${mkfs_label}"

sudo sync
unmount_sd_image_file

}

create_rootfs_img() {
echo "#-------------------------------------------------------------------------------#"
echo "#-----------------------------          ----------------------------------------#"
echo "#----------------     +++ generating rootfs image  zzz  +++ ........  ----------#"
echo "#-----------------------------   wait   ----------------------------------------#"
echo "#-------------------------------------------------------------------------------#"
set -v
sudo dd if=/dev/zero of=${ROOTFS_IMG}  bs=4K count=1400K
sudo sh -c "LC_ALL=C ${mkfs} ${mkfs_options} ${ROOTFS_IMG} ${mkfs_label}"
#sudo mke2fs -j -L "rootfs" ${ROOTFS_IMG}
}

if [ ! -z "${WORK_DIR}" ]; then
	if [ "${IMG_PARTS}" == "0" ]; then
		echo "SubScr_MSG: creating Rootfs Image file (${ROOTFS_IMG})"
		if [ -f ${ROOTFS_IMG} ]; then
			echo "Deleting old single partition imagefile"
			rm -f ${ROOTFS_IMG}
		fi
		create_rootfs_img
	else
		if [ -a ${SD_IMG} ]; then
			echo "Deleting old sd-imagefile"
			rm -f ${SD_IMG}
		fi
		create_sdcard_img
	fi
	echo "#----------------------------------------------------------------------------------#"
	echo "#-------------  create_img.sh Finished with Success  ------------------------------#"
	echo "#----------------------------------------------------------------------------------#"

else
    echo "#----------------------------------------------------------------------------------#"
    echo "#----------------  create_img.sh Ended Unsuccessfully    --------------------------#"
    echo "#--------------->  maybe parameters given    --- ----------------------------------#"
    echo "#----------------------------------------------------------------------------------#"
fi



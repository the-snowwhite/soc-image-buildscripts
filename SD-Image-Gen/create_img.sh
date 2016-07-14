#!/bin/bash

# Create, partition and mount SD-Card image:
#------------------------------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------------------------------
CURRENT_DIR=`pwd`
WORK_DIR=${1}
IMG_FILE=${2}

ROOTFS_IMG=${WORK_DIR}/rootfs.img
ROOTFS_TYPE=ext4
ROOTFS_LABEL=rootfs

mount_image_file(){
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

unmount_image_file(){
#	sudo kpartx -d -s -v ${IMG_FILE}
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

+5599M
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
#sudo dd if=/dev/zero of=${IMG_FILE}  bs=1024 count=3700K
#sudo dd if=/dev/zero of=${IMG_FILE}  bs=4K count=925K
#sudo dd if=/dev/zero of=${IMG_FILE}  bs=1024 count=6700K

sudo dd if=/dev/zero of=${IMG_FILE} bs=4K count=1675K
mount_image_file

fdisk_2part

#fdisk_3part_swap
sudo sync
sudo partprobe -s ${LOOP_DEV}
sudo sync

#sudo kpartx -u -f -s ${IMG_FILE}

echo "creating file systems"

ext4_options="-O ^metadata_csum,^64bit"
mkfs_options="${ext4_options}"

mkfs="mkfs.${ROOTFS_TYPE}"
media_prefix=${LOOP_DEV}
media_rootfs_partition=p2

mkfs_partition="${media_prefix}${media_rootfs_partition}"
mkfs_label="-L ${ROOTFS_LABEL}"

sudo sh -c "LC_ALL=C ${mkfs} ${mkfs_partition} ${mkfs_label}"
#sudo sh -c "LC_ALL=C ${mkfs} ${mkfs_options} ${mkfs_partition} ${mkfs_label}"

sudo sync
unmount_image_file

}

create_rootfs_img() {
echo "#-------------------------------------------------------------------------------#"
echo "#-----------------------------          ----------------------------------------#"
echo "#----------------     +++ generating rootfs image  zzz  +++ ........  ----------#"
echo "#-----------------------------   wait   ----------------------------------------#"
echo "#-------------------------------------------------------------------------------#"
set -v
sudo dd if=/dev/zero of=${ROOTFS_IMG}  bs=1024 count=3600K
sudo mke2fs -j -L "rootfs" ${ROOTFS_IMG}
}

if [ ! -z "${WORK_DIR}" ]; then
    if [ -a ${SD_IMG} ]; then
        echo "Deleting old sd-imagefile"
        rm -f ${SD_IMG}
    fi
    if [ -f ${ROOTFS_IMG} ]; then
        echo "Deleting old single partition imagefile"
        rm -f ${ROOTFS_IMG}
    fi

	create_sdcard_img
	#create_rootfs_img

	echo "#----------------------------------------------------------------------------------#"
	echo "#-------------  create_img.sh Finished with Success  ------------------------------#"
	echo "#----------------------------------------------------------------------------------#"

else
    echo "#----------------------------------------------------------------------------------#"
    echo "#----------------  create_img.sh Ended Unsuccessfully    --------------------------#"
    echo "#--------------->  no parameters given    --- -------------------------------------#"
    echo "#----------------------------------------------------------------------------------#"
fi



#!/bin/bash
extract_xz() {
    echo "MSG: using tar for xz extract"
    tar xf ${1}
}

## parameters: 1: folder name, 2: url, 3: file name
get_and_extract() {
# download linaro cross compiler toolchain
    if [ ! -f ${1} ]; then
        echo "MSG: downloading ${2}"
    	wget -c ${2}
    fi
# extract linaro cross compiler toolchain
    echo "MSG: extracting ${3}"
    extract_xz ${3}
}

uiomod_kernel() {
#cd ${KERNEL_BUILD_DIR}
#Uio Config additions:
cat <<EOT >> ${KERNEL_BUILD_DIR}/arch/arm/configs/${KERNEL_CONF}
CONFIG_UIO=m
CONFIG_UIO_PDRV=m
CONFIG_UIO_PDRV_GENIRQ=m
CONFIG_CONFIGFS_FS=y
CONFIG_OF_OVERLAY=y
CONFIG_LBDAF=y
CONFIG_EXT4_FS_XATTR=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
CONFIG_AUTOFS4_FS=m
CONFIG_DEBUG_INFO=n
CONFIG_USB_HIDDEV=y
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_UHCI_HCD=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_ARM_HEAVY_MB=y
CONFIG_ARCH_SUPPORTS_BIG_ENDIAN=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_FORCE_MAX_ZONEORDER=13
CONFIG_DMA_CMA=y
CONFIG_MEMORY_ISOLATION=y
CONFIG_CMA_DEBUG=y
CONFIG_CMA_DEBUGFS=y
CONFIG_CMA_AREAS=7
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_FRAME_VECTOR=y
CONFIG_CMA_SIZE_MBYTES=512
CONFIG_CMA_SIZE_SEL_MBYTES=y
CONFIG_CMA_ALIGNMENT=8
CONFIG_CMA_AREAS=7
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_MEDIA_SUPPORT=y
CONFIG_MEDIA_SUPPORT=y
CONFIG_MEDIA_CAMERA_SUPPORT=y
CONFIG_MEDIA_CONTROLLER=y
CONFIG_MEDIA_CONTROLLER_DVB=y
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2_SUBDEV_API=y
CONFIG_VIDEO_V4L2=y
CONFIG_VIDEOBUF_GEN=y
CONFIG_VIDEOBUF2_CORE=y
CONFIG_VIDEOBUF2_MEMOPS=y
CONFIG_VIDEOBUF2_VMALLOC=y
CONFIG_MEDIA_USB_SUPPORT=y
CONFIG_MEDIA_USB_SUPPORT=y
CONFIG_USB_VIDEO_CLASS=y
CONFIG_USB_VIDEO_CLASS_INPUT_EVDEV=y
CONFIG_USB_GSPCA=y
CONFIG_USB_M5602=y
CONFIG_USB_STV06XX=y
CONFIG_USB_GL860=y
CONFIG_USB_GSPCA_BENQ=y
CONFIG_USB_GSPCA_CONEX=y
CONFIG_USB_GSPCA_CPIA1=y
CONFIG_USB_GSPCA_DTCS033=y
CONFIG_USB_GSPCA_ETOMS=y
CONFIG_USB_GSPCA_FINEPIX=y
CONFIG_USB_GSPCA_JEILINJ=y
CONFIG_USB_GSPCA_JL2005BCD=y
CONFIG_USB_GSPCA_KINECT=y
CONFIG_USB_GSPCA_KONICA=y
CONFIG_USB_GSPCA_MARS=y
CONFIG_USB_GSPCA_MR97310A=y
CONFIG_USB_GSPCA_NW80X=y
CONFIG_USB_GSPCA_OV519=y
CONFIG_USB_GSPCA_OV534=y
CONFIG_USB_GSPCA_OV534_9=y
CONFIG_USB_GSPCA_PAC207=y
CONFIG_USB_GSPCA_PAC7302=y
CONFIG_USB_GSPCA_PAC7311=y
CONFIG_USB_GSPCA_SE401=y
CONFIG_USB_GSPCA_SN9C2028=y
CONFIG_USB_GSPCA_SN9C20X=y
CONFIG_USB_GSPCA_SONIXB=y
CONFIG_USB_GSPCA_SONIXJ=y
CONFIG_USB_GSPCA_SPCA500=y
CONFIG_USB_GSPCA_SPCA501=y
CONFIG_USB_GSPCA_SPCA505=y
CONFIG_USB_GSPCA_SPCA506=y
CONFIG_USB_GSPCA_SPCA508=y
CONFIG_USB_GSPCA_SPCA561=y
CONFIG_USB_GSPCA_SPCA1528=y
CONFIG_USB_GSPCA_SQ905=y
CONFIG_USB_GSPCA_SQ905C=y
CONFIG_USB_GSPCA_SQ930X=y
CONFIG_USB_GSPCA_STK014=y
CONFIG_USB_GSPCA_STK1135=y
CONFIG_USB_GSPCA_STV0680=y
CONFIG_USB_GSPCA_SUNPLUS=y
CONFIG_USB_GSPCA_T613=y
CONFIG_USB_GSPCA_TOPRO=y
CONFIG_USB_GSPCA_TOUPTEK=y
CONFIG_USB_GSPCA_TV8532=y
CONFIG_USB_GSPCA_VC032X=y
CONFIG_USB_GSPCA_VICAM=y
CONFIG_USB_GSPCA_XIRLINK_CIT=y
CONFIG_USB_GSPCA_ZC3XX=y
CONFIG_V4L_PLATFORM_DRIVERS=y
CONFIG_SOC_CAMERA=y
CONFIG_SOC_CAMERA_PLATFORM=y
CONFIG_FB=y
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
CONFIG_FB_ALTERA_VIP=y
CONFIG_DUMMY_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=y
CONFIG_LOGO=y
CONFIG_LOGO_LINUX_MONO=y
CONFIG_LOGO_LINUX_VGA16=y
CONFIG_LOGO_LINUX_CLUT224=y
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y
CONFIG_LIBCRC32C=y
CONFIG_INPUT_EVDEV=y
CONFIG_INPUT_UINPUT=y
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_USB_COMPOSITE=y
CONFIG_HID=y
CONFIG_USB_HID=y
CONFIG_HID_MULTITOUCH=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_SOUND=y
CONFIG_SOUND_OSS_CORE=y
CONFIG_SOUND_OSS_CORE_PRECLAIM=y
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_HWDEP=y
CONFIG_SND_RAWMIDI=y
CONFIG_SND_COMPRESS_OFFLOAD=y
CONFIG_SND_JACK=y
CONFIG_SND_SEQUENCER=y
CONFIG_SND_SEQ_DUMMY=y
CONFIG_SND_OSSEMUL=y
CONFIG_SND_SEQUENCER_OSS=y
CONFIG_SND_SUPPORT_OLD_API=y
CONFIG_SND_VERBOSE_PROCFS=y
CONFIG_SND_VERBOSE_PRINTK=y
CONFIG_SND_DEBUG=y
CONFIG_SND_DEBUG_VERBOSE=y
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_DRIVERS=y
CONFIG_SND_DUMMY=m
CONFIG_SND_SERIAL_U16550=m
CONFIG_SND_SPI=y
CONFIG_SND_USB=y
CONFIG_SND_USB_AUDIO=y
CONFIG_SND_SOC=y
CONFIG_SND_SOC_I2C_AND_SPI=y
CONFIG_SND_SOC_SIGMADSP=m
CONFIG_SND_SOC_SIGMADSP_I2C=m
CONFIG_SND_SOC_SSM2602=m
CONFIG_SND_SOC_SSM2602_I2C=m
CONFIG_SND_SOC_WM8731=m
#
# CONFIG_IP_ADVANCED_ROUTER=y
# CONFIG_IP_MULTIPLE_TABLES=y
# CONFIG_SYSFS_DEPRECATED=n
# CONFIG_AUDIT=n
# #CONFIG_FW_LOADER_USER_HELPER=n
# CONFIG_PREEMPT_RT=y
# CONFIG_PREEMPT_RT_FULL=y
# CONFIG_PREEMPT=y
# CONFIG_MARVELL_PHY=y
# CONFIG_GPIO_ALTERA=m
# #CONFIG_GPIO_A10SYCON=y
# CONFIG_NEW_LEDS=y
# CONFIG_LEDS_CLASS=y
# CONFIG_LEDS_GPIO=y
# CONFIG_LEDS_TRIGGERS=y
# CONFIG_LEDS_TRIGGER_TIMER=y
# CONFIG_LEDS_TRIGGER_CPU=y
# CONFIG_CFS_BANDWIDTH=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES=y
# CONFIG_CGROUP_SCHED=y
# CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_RT_GROUP_SCHED=y
# CONFIG_LOCALVERSION_AUTO=n
# CONFIG_BLK_DEV_INITRD=y
# CONFIG_INITRAMFS_SOURCE=""
# CONFIG_INITRAMFS_ROOT_UID=0
# CONFIG_INITRAMFS_ROOT_GID=0
# CONFIG_RD_GZIP=y
# CONFIG_RD_BZIP2=y
# CONFIG_RD_LZMA=y
# CONFIG_RD_XZ=y
# CONFIG_RD_LZO=y
# CONFIG_RD_LZ4=y
EOT
echo "Kernel Custom Patch added"
echo "config file mods applied"

cd ${KERNEL_BUILD_DIR}
patch  -p2 < ${PATCH_SCRIPT_DIR}/kernel-4.9.30-uEnv.txt-deb.patch
}

rt_patch_kernel() {
cd ${KERNEL_PARENT_DIR}
if [ ! -f ${RT_PATCH_FILE} ]; then #if file with that name not exists
        echo "fetching patch"
        wget ${RT_PATCH_URL}
fi
cd ${KERNEL_BUILD_DIR}
xzcat ../${RT_PATCH_FILE} | patch -p1
echo "rt-Patch applied"
#Uio Patch:
uiomod_kernel
}

## parameters: 1: folder name, 2: patch file name
git_patch() {
	echo "MGG: Applying patch ${2}"
	cd "${1}"
	git am --signoff < ${2}
}

## parameters: 1: folder name, 2: url, 3: branch name, 4: checkout options, 5: patch file name
git_fetch() {
	if [ ! -d ${CURRENT_DIR}/${1} ]; then
		echo "MSG: cloning ${2}"
		git clone ${2} ${1}
	fi

	cd ${CURRENT_DIR}/${1}
	if [ ! -z "${3}" ]; then
		git fetch origin
		git reset --hard origin/master
		echo "MSG: Will now check out " ${3}
		git checkout ${3} ${4}
		if [ ! -z "${5}" ]; then
			echo "MSG: Will now apply patch: " ${PATCH_SCRIPT_DIR}/${5}
			git_patch ${CURRENT_DIR}/${1} ${PATCH_SCRIPT_DIR}/${5}
		fi
	fi
	cd ..
}

## parameters: 1: folder name, 2: config string 3: build string
armhf_build() {
	cd ${1}
	## configure - compile
	export ARCH=arm
	export PATH=$CC_DIR/bin/:$PATH
	export CROSS_COMPILE=$CC

	echo "MSG: configuring ${1}"
	echo "MSG: as ${2}"
	make -j${NCORES} mrproper
#	make -j${NCORES} ${KERNEL_CONF} ARCH=arm NAME="Michael Brown" EMAIL="producer@holotronic.dk" KBUILD_DEBARCH=armhf
	make -j${NCORES} ${2} ARCH=arm NAME="Michael Brown" EMAIL="producer@holotronic.dk"
	if [ ! -z "${3}" ]; then
		echo "MSG: compiling ${1}"
#		make -j$NCORES ${3} ARCH=arm NAME="Michael Brown" EMAIL="producer@holotronic.dk" KBUILD_DEBARCH=armhf
		make -j$NCORES ${3} ARCH=arm NAME="Michael Brown" EMAIL="producer@holotronic.dk"
	fi
}

## parameters: 1: distro name,
add_kernel2repo(){
#sudo systemctl stop apache2

echo ""
echo "Scr_MSG: Repo content before -->"
echo ""
LIST1=`reprepro -b ${HOME_REPO_DIR} -C main -A armhf --list-format='''${package}\n''' list ${1} | { grep ${KERNEL_VERSION} || true; }`
echo "Got list1"
JESSIE_LIST1=$"${LIST1}"

echo "JESSIE_LIST1"

echo "${JESSIE_LIST1}"
echo "Scr_MSG: Contents of JESSIE_LIST1 -->"
echo "${JESSIE_LIST1}"

echo ""

if [ ! -z "${JESSIE_LIST1}" ]; then
	echo ""
	echo "Scr_MSG: Will remove former version from repo"
	echo ""
	reprepro -b ${HOME_REPO_DIR} -C main -A armhf remove ${1} ${JESSIE_LIST1}
	reprepro -b ${HOME_REPO_DIR} -C main -A armhf remove ${1} linux-libc-dev
	reprepro -b ${HOME_REPO_DIR} export ${1}
	echo "Scr_MSG: Restarting web server"

	sudo systemctl restart apache2
	reprepro -b ${HOME_REPO_DIR} export ${1}
else
	echo ""
	echo "Scr_MSG: Former version not found"
	echo ""
fi
echo ""

#
# if [[ ${CLEAN_KERNELREPO} == 'yes' ]]; then
# CLEAN_ALL_LIST=`reprepro -b ${HOME_REPO_DIR} -C main -A armhf --list-format='''${package}\n''' list ${1}`
#
# JESSIE_CLEAN_ALL_LIST=$"${CLEAN_ALL_LIST}"
#
# 	if [ ! -z "${JESSIE_CLEAN_ALL_LIST}" ]; then
# 		echo ""
# 		echo "Scr_MSG: Will clean repo"
# 		echo ""
# 		reprepro -b ${HOME_REPO_DIR} -C main -A armhf remove ${1} ${JESSIE_CLEAN_ALL_LIST}
#                 reprepro -b ${HOME_REPO_DIR} export ${1}
#                 echo "Scr_MSG: Restarting web server"
#                 sudo systemctl restart apache2
# 	else
# 		echo ""
# 		echo "Scr_MSG: Repo is empty"
# 		echo ""
# 	fi
# 	echo ""
# fi
#
reprepro -b ${HOME_REPO_DIR} -C main -A armhf includedeb ${1} ${KERNEL_PARENT_DIR}/*.deb
reprepro -b ${HOME_REPO_DIR} export ${1}
reprepro -b ${HOME_REPO_DIR} list ${1}

LIST2=`reprepro -b ${HOME_REPO_DIR} -C main -A armhf --list-format='''${package}\n''' list ${1}`
JESSIE_LIST2=$"${LIST2}"
echo  "${JESSIE_LIST2}"
echo ""
echo "Scr_MSG: Repo content After: -->"
echo ""
echo  "${JESSIE_LIST2}"
echo ""
echo "#--->       Repo updated                                                  <---#"
}

## parameters: 1: mount name, 2: kernel tag
inst_kernel_from_local_repo(){
sudo cp -f ${1}/etc/apt/sources.list-local ${1}/etc/apt/sources.list

sudo rm -f ${1}/etc/resolv.conf
sudo cp -f /etc/resolv.conf ${1}/etc/resolv.conf

#${apt_cmd} -y install hm2reg-uio-dkms

#sudo chroot --userspec=root:root ${1} /usr/bin/${apt_cmd} -y install apt-transport-https

#sudo sh -c 'echo "deb [arch=armhf] https://deb.mah.priv.at/ jessie socfpga" > '${1}'/etc/apt/sources.list.d/debmah.list'
sudo sh -c 'echo "deb [arch=armhf] http://kubuntu16-ws.holotronic.lan/debian '${distro}' main" > '${1}'/etc/apt/sources.list.d/mibsocdeb.list'
echo ""
echo "Script_MSG: Will now add key to kubuntu16-ws"
echo ""

sudo sh -c 'wget -O - http://kubuntu16-ws.holotronic.lan/debian/socfpgakernels.gpg.key|apt-key add -'
sudo chroot --userspec=root:root ${1} /usr/bin/${apt_cmd} -y update

# #sudo chroot --userspec=root:root ${1} /usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv 4FD9D713
# #sudo chroot --userspec=root:root ${1} /usr/bin/${apt_cmd} -y update
sudo chroot --userspec=root:root ${1} /usr/bin/${apt_cmd} -y --assume-yes --allow-unauthenticated upgrade

# echo ""
# echo "# --------->       Removing qemu policy file          <--------------- ---------"
# echo ""
# if [ -f ${POLICY_FILE} ]; then
#     echo "removing ${POLICY_FILE}"
#     sudo rm -f ${POLICY_FILE}
# fi

echo ""
echo "Script_MSG: Will now install kernel packages"
echo ""
sudo chroot --userspec=root:root ${1} /usr/bin/${apt_cmd} -y --assume-yes --allow-unauthenticated install --reinstall linux-headers-${2} linux-image-${2} linux-libc-dev


cd ${CURRENT_DIR}
sudo cp -f ${1}/etc/apt/sources.list-final ${1}/etc/apt/sources.list
sudo chroot --userspec=root:root ${1} /bin/rm -f /etc/resolv.conf
sudo chroot --userspec=root:root ${1} /bin/ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf

}

## parameters: 1: image name, 2: mount name
mount_imagefile(){
	mkdir -p ${2}
	sync
	echo "#--------------------------------------------------------------------------------------#"
	echo "# Scr_MSG:   mounting imagefile:                                                       #"
	sudo mount ${1} ${2}
	echo "# ${1}"
	echo "# Is mounted in ---> ${2}"
	echo "#                                                                                      #"
	echo "#--------------------------------------------------------------------------------------#"
}

## parameters: 1: image name, 2: mount name 3: img part num
mount_sd_imagefile(){
	mkdir -p ${2}
	sync
	echo "#--------------------------------------------------------------------------------------#"
	echo "# Scr_MSG:   mounting imagefile:                                                       #"
	if [ -z "${3}" ]; then
		echo "# Scr_MSG: 1 empty image:"
		LOOP_DEV=`eval sudo losetup -Pf --show ${1}`
		echo "# ${1}"
		echo "# Is mounted in ---> ${LOOP_DEV}"
	else
		LOOP_DEV=`eval sudo losetup -Pf --show ${1}`
		echo "# ${1}"
		echo "# Is mounted in ---> ${LOOP_DEV}"
		sudo mount ${LOOP_DEV}${3} ${2}
		echo "#                                                                                      #"
		echo "# ${LOOP_DEV}${3}"
		echo "# Is mounted in ---> ${2}"
		echo "#                                                                                      #"
		echo "#--------------------------------------------------------------------------------------#"
	fi
}

## parameters: 1: mount name
unmount_imagefile(){
	echo "Scr_MSG: Unmounting Imagefile in ---> ${1}"
	sudo umount -R ${1}
}

## parameters: 1: loop dev
unmount_loopdev(){
	echo "Scr_MSG: Unmounting loopdev in ---> ${1}"
	sudo losetup -d ${LOOP_DEV}
}

## parameters: 1: image name
create_rootfs_img() {
echo "#-------------------------------------------------------------------------------#"
echo "#-------------------------                      --------------------------------#"
echo "#---------------    +++ creating blank rootfs image  zzz  +++ .......  ---------#"
echo "#-----------------------------   wait   ----------------------------------------#"
echo "#-------------------------------------------------------------------------------#"

sudo dd if=/dev/zero of=${1}  bs=4K count=1000K
sudo sh -c "LC_ALL=C ${mkfs} ${mkfs_options} ${1} ${mkfs_label}"
}

## parameters: 1: loop dev name
fdisk_2part() {
sudo fdisk ${1} << EOF
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

## parameters: 1: loop dev name
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

+1024M
n
p
3


t
2
82
w
EOF
}

## parameters: 1: no of partitions, 2: img file name, 3: mount dev name, 4: rootfs partition
create_img() {
#--------------- Initial sd-card image - partitioned --------------
echo "#-------------------------------------------------------------------------------#"
echo "#-----------------------------          ----------------------------------------#"
echo "#---------------     +++ generating sd-card image  zzz  +++ ........  ----------#"
echo "#---------------------------  Please  wait   -----------------------------------#"
echo "#-------------------------------------------------------------------------------#"

mkfs_label="-L ${ROOTFS_LABEL}"

if [ "${1}" = "1" ]; then
	echo "# Scr_MSG: 1 part rootfs image"
	create_rootfs_img ${2}
elif [ "${1}" = "2" ] || [ "${1}" = "3" ]; then
	sudo dd if=/dev/zero of=${2} bs=4K count=1700K
	echo "Now mounting sd-image file"
	mount_sd_imagefile ${2} ${3}
	if [ "${1}" = "2" ]; then
		echo "# Scr_MSG: 2 part sd image"
		fdisk_2part ${LOOP_DEV}
	elif [ "${1}" = "3" ]; then
		echo "# Scr_MSG: 3 part sd image"
		fdisk_3part_swap ${LOOP_DEV}
	fi
	sudo sync
	echo "# Scr_MSG: will now part probe"
	sudo partprobe -s ${LOOP_DEV}
	sudo sync

	echo ""
	echo "SubScr_MSG: creating file systems"
	echo ""

	mkfs_partition="${LOOP_DEV}${media_rootfs_partition}"
	sudo sh -c "LC_ALL=C ${mkfs} ${mkfs_options} ${mkfs_partition} ${mkfs_label}"

	if [ "${1}" = "3" ]; then
		sudo mkswap -f ${LOOP_DEV}${media_swap_partition}
	fi

	sudo sync
	unmount_loopdev ${LOOP_DEV}
else
	echo ""
	echo "SubScr_MSG: create_img() No Valid number of partitions given ie: 1(rootfs only), 2 or 3(with swap)"
	echo ""
fi

}

## parameters: 1: mount dev name
bind_mounted(){
	sudo sync
	sudo mount --bind /dev ${1}/dev
	sudo mount --bind /proc ${1}/proc
	sudo mount --bind /sys ${1}/sys

	echo "#--------------------------------------------------------------------------------------#"
	echo "# Scr_MSG: ${1} Bind mounted                                                  #"
	echo "#                                                                                      #"
	echo "#--------------------------------------------------------------------------------------#"
}

## parameters: 1: mount dev name
kill_ch_proc(){
FOUND=0
PREFIX=${1}
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

## parameters: 1: mount dev name
unmount_binded(){
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
		echo "Scr_MSG: Will now (unbind) ummount ${1}"
		RES=`eval sudo umount -R ${1}`
		echo ""
		echo "Scr_MSG: Unmont result = ${RES}"
		echo "Scr_MSG: Unmont return value = ${?}"
	if [ -d "${1}/dev" ]; then
		echo ""
		kill_ch_proc ${1}
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

# parameters: 1: work dir, 2: mount dev name, 3: comp prefix
compress_rootfs(){
	COMPNAME=${COMP_REL}_${3}
	echo "#---------------------------------------------------------------------------#"
	echo "#Scr_MSG:                                                                   #"
	echo "compressing latest rootfs from image into: -->   ---------------------------#"
	echo " ${1}/${COMPNAME}-rootfs.tar.bz2"
	cd ${2}
	sudo tar -cjSf ${1}/${COMPNAME}-rootfs.tar.bz2 *
	cd ${1}
	echo "#                                                                           #"
	echo "#Scr_MSG:                                                                   #"
	echo "${COMPNAME}-rootfs.tar.bz2 rootfs compression finished ..."
	echo "#                                                                           #"
	echo "#---------------------------------------------------------------------------#"
}

# parameters: 1: work dir, 2: mount dev name, 3: comp prefix
extract_rootfs(){
if [ ! -z "${3}" ]; then
	COMPNAME=${COMP_REL}_${3}
	echo "Script_MSG: Extracting ${1}/${COMPNAME}-rootfs.tar.bz2"
	echo "Script_MSG: Into imagefile"
	echo "Rootfs configured ... extracting  ${COMPNAME} rootfs into image...."
	## extract rootfs into image:
	sudo tar xfj ${1}/${COMPNAME}-rootfs.tar.bz2 -C ${2}
	echo "${1}/${COMPNAME}-rootfs.tar.bz2 rootfs extraction finished .."
fi
}

# parameters: 1: work dir, 2: uboot dir, 3: uboot make config, 4: sd img file name
install_uboot() {
UBOOT_SPLFILE="${1}/${2}/${3}"
echo ""
echo "installing ${UBOOT_SPLFILE}"
echo ""
sudo dd bs=512 if=${UBOOT_SPLFILE} of=${4} seek=2048 conv=notrunc
sudo sync
}

# parameters: 1: work dir, 2: sd img file name
make_bmap_image() {
	echo ""
	echo "NOTE:  Will now make bmap image"
	echo ""
	cd ${1}
	bmaptool create -o ${2}.bmap ${2}
	tar -cjSf ${2}-bmap.tar.bz2 ${2} ${2}.bmap
	echo ""
	echo "NOTE:  Bmap image created"
	echo ""
}

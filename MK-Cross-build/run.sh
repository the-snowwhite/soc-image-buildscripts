#!/bin/bash

#set -x

SCRIPT_ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CURRENT_DIR=`pwd`
#WORK_DIR=$1
WORK_DIR=$CURRENT_DIR

REL_CURRENT_DATE=`date -I`
#REL_CURRENT_DATE="2016-03-07"

#ROOTFS_DIR=${WORK_DIR}/rootfs
#IMG_FILE=${CURRENT_DIR}/mksoc_sdcard-beta2.img
#IMG_FILE=${CURRENT_DIR}/mksoc_sdcard.img
SD_IMG_FILE=${CURRENT_DIR}/mksocfpga_jessie_machinekit_4.1-ltsi-rt-2016-10-24-de0-nano-soc_sd.img
SD_IMG_NAME=${CURRENT_DIR}/mksocfpga_jessie_machinekit_4.1-ltsi-rt-2016-10-24-de0-nano-soc_mk-rip_sd.img
#IMG_FILE=${CURRENT_DIR}/mksocfpga_jessie_socfpga-4.1-ltsi-rt-${REL_CURRENT_DATE}-nano_sd.img
IMG_ROOT_PART=p3
#ROOTFS_MNT=/mnt/rootfs
ROOTFS_MNT=/tmp/myimage

#DRIVE=/dev/mapper/loop2

MK_SOURCEFILE_NAME=machinekit-src.tar.bz2
MK_BUILTFOLDER_NAME=machinekit-built-src
MK_BUILTFILE_NAME=${MK_BUILTFOLDER_NAME}.tar.bz2

MK_RIPROOTFS_NAME=mksocfpga_jessie_socfpga-4.1-ltsi-rt-${REL_CURRENT_DATE}_mk-rip-rootfs-final.tar.bz2

# this is where the test build will go.
#MK_BUILDDIR=${ROOTFS_DIR}/machinekit/machinekit

# git repository to pull from
REPO=git://github.com/machinekit/machinekit.git

# the origin to use
ORIGIN=github-machinekit

# the branch to build
BRANCH=master

# this is where the clone will be.
MK_CLONEDIR=${WORK_DIR}/machinekit

install_clone_deps(){
# prerequisits for cloning Machinekit
# git
echo machinekit | sudo -S apt-get -y install git-core git-gui dpkg-dev
}

mk_clone() {
# refuse to clone into an existing directory.
if [ -d "${MK_CLONEDIR}" ]; then
    echo the target directory ${MK_CLONEDIR} already exists.
    echo cleaning repo
    cd ${MK_CLONEDIR}
    git clean -d -f -x
    cd ..
#    echo please remove or rename this directory and run again.
#    exit 1
else
# $MK_BUILDDIR does not exist. Make a shallow git clone into it.
# make sure you have around 200MB free space.

    git clone -b "${BRANCH}" -o "${ORIGIN}" --depth 1 "${REPO}" "${MK_CLONEDIR}"
fi
}

mount_sdimagefile(){
	sudo sync
	LOOP_DEV=`eval sudo losetup -Pf --show ${SD_IMG_FILE}`
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

unmount_sdimagefile(){
	echo ""
	echo "Scr_MSG: Unmounting ---> ${ROOTFS_MNT}"
	sudo umount -R ${ROOTFS_MNT}
	echo ""
	echo "Scr_MSG: Unmounting Imagefile in ---> ${LOOP_DEV}"
	sudo losetup -d ${LOOP_DEV}
	echo ""
}

bind_rootfs(){
	sudo sync
	sudo mount --bind /dev ${ROOTFS_MNT}/dev
	sudo mount --bind /proc ${ROOTFS_MNT}/proc
	sudo mount --bind /sys ${ROOTFS_MNT}/sys

	echo "#--------------------------------------------------------------------------------------#"
	echo "# Scr_MSG: ${ROOTFS_MNT} Bind mounted                                                  #"
	echo "#                                                                                      #"
	echo "#--------------------------------------------------------------------------------------#"
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
    COUNT=$((${COUNT}+1))
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
		PREFIX=${ROOTFS_MNT}
		kill_ch_proc
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

compress_clone(){
    echo "compressing machinekit folder"
    cd ${WORK_DIR}
    tar -jcf "${MK_SOURCEFILE_NAME}" ./machinekit
}

compress_built_source(){
    if [ -d ${WORK}/${MK_BUILTFOLDER_NAME} ]; then
        echo "the target directory ${MK_BUILTFOLDER_NAME} exists ... pre build compressing"
        cd ${WORK_DIR}
        tar -jcf "${MK_BUILTFILE_NAME}" ./${MK_BUILTFOLDER_NAME}
    fi
}

compress_mkrip_rootfs(){
    echo "compressing final mk-rip-rootfs"

    echo ""
    echo "NOTE: will mount ${SD_IMG_FILE}"
    echo ""

    mount_sdimagefile

    cd ${ROOTFS_MNT}
    sudo tar -cjSf ${CURRENT_DIR}/${MK_RIPROOTFS_NAME} *
    cd ${WORK_DIR}
    unmount_sdimagefile
}

# compress_mk_build(){
# cd ${HOME}
# if [ -d machinekit ]; then
#     echo "the target directory machinekit exists ... compressing"
#     tar -jcf "${MK_BUILTFILE_NAME}" ./machinekit
# fi
# }

copy_files(){
echo "copying build-script and machinekit tar.bz2"
sudo mkdir -p ${ROOTFS_MNT}/home/machinekit/
sudo cp -f ${SCRIPT_ROOT_DIR}/mk-rip-build.sh ${ROOTFS_MNT}/home/
sudo cp -f ${WORK_DIR}/${MK_SOURCEFILE_NAME} ${ROOTFS_MNT}/home/machinekit/
if [ -f ${WORK_DIR}/${MK_BUILTFILE_NAME} ]; then
    sudo cp -f ${WORK_DIR}/${MK_BUILTFILE_NAME} ${ROOTFS_MNT}/home/machinekit/
fi
}

gen_policy-rc.d() {
sudo sh -c 'cat <<EOT > '${ROOTFS_MNT}'/usr/sbin/policy-rc.d
echo "************************************" >&2
echo "All rc.d operations denied by policy" >&2
echo "************************************" >&2
exit 101
EOT'
}

POLICY_FILE=/usr/sbin/policy-rc.d

gen_build_sh() {
echo "------------------------------------------"
echo "generating run.sh chroot config script"
echo "------------------------------------------"
sudo sh -c 'cat <<EOT > '${ROOTFS_MNT}'/home/build.sh
#!/bin/bash

set -x


compress_mk_build(){
cd /home/machinekit
if [ -d machinekit ]; then
    echo "the target directory machinekit exists ... compressing"
    sudo rm -f '${MK_BUILTFILE_NAME}'
    tar -jcf '${MK_BUILTFILE_NAME}' ./machinekit
fi
}


/home/mk-rip-build.sh

if [ -f '${POLICY_FILE}' ]; then
    echo "removing '${POLICY_FILE}'"
    sudo rm -f '${POLICY_FILE}'
fi

compress_mk_build

exit
EOT'

sudo chmod +x ${ROOTFS_MNT}/home/build.sh
}
run_setup_initial_files() {
copy_files
gen_build_sh
gen_policy-rc.d
sudo cp -f ${ROOTFS_MNT}/etc/apt/sources.list-local ${ROOTFS_MNT}/etc/apt/sources.list
}

run_build_sh() {
echo "mounting SD-Image"

mount_sdimagefile

echo "------------------------------------------"
echo "   copying files to root mount            "
echo "------------------------------------------"

run_setup_initial_files

echo "------------------------------------------"
echo "running build.sh config script in chroot"
echo "------------------------------------------"
cd ${ROOTFS_MNT} # or where you are preparing the chroot dir

bind_rootfs

#echo "will now exit in mount"
#exit 1
# fix dns:
RESOLVCONF_FILE=${ROOTFS_MNT}/etc/resolv.conf


if [ -f ${RESOLVCONF_FILE} ]; then
    sudo rm ${RESOLVCONF_FILE}
fi

sudo cp -f /etc/resolv.conf ${RESOLVCONF_FILE}

HOSTS_FILE=${ROOTFS_MNT}/etc/hosts

if [ -f ${HOSTS_FILE} ]; then
    echo "renaming ${HOSTS_FILE}"
    sudo mv ${HOSTS_FILE} ${HOSTS_FILE}.bak
    echo "replacing ${HOSTS_FILE} with one from host"
    sudo cp /etc/hosts ${HOSTS_FILE}
else
    sudo cp /etc/hosts ${HOSTS_FILE}
fi

sudo chroot ${ROOTFS_MNT} /bin/su -l machinekit /bin/sh -c /home/build.sh

if [ -f ${HOSTS_FILE}.bak ]; then
    echo "restoring ${HOSTS_FILE}"
    sudo rm -f ${HOSTS_FILE}
    sudo mv ${HOSTS_FILE}.bak ${HOSTS_FILE}
fi
sudo cp -f ${ROOTFS_MNT}/etc/apt/sources.list-final ${ROOTFS_MNT}/etc/apt/sources.list
sudo rm ${ROOTFS_MNT}/etc/resolv.conf

cd ${CURRENT_DIR}


sudo cp -f ${ROOTFS_MNT}/home/machinekit/${MK_BUILTFILE_NAME}  ${WORK_DIR}
bind_unmount_rootfs_imagefile
compress_mkrip_rootfs

}

make_bmap_image() {
	echo ""
	echo "NOTE:  Will now make bmap image"
	echo ""
	cd ${CURRENT_DIR}
	sudo mv ${SD_IMG_FILE} ${SD_IMG_NAME}
	bmaptool create -o ${SD_IMG_NAME}.bmap ${SD_IMG_NAME}
#	tar -cjSf ${SD_IMG_FILE}.tar.bz2 ${SD_IMG_FILE}
#	tar -cjSf ${SD_IMG_FILE}-bmap.tar.bz2 ${SD_IMG_FILE}.tar.bz2 ${SD_IMG_FILE}.bmap
	tar -cjSf ${SD_IMG_NAME}-bmap.tar.bz2 ${SD_IMG_NAME} ${SD_IMG_NAME}.bmap
	echo ""
	echo "NOTE:  Bmap image created"
	echo ""
}

#---------------------------------------------------------------------------#
#----------- run functions -------------------------------------------------#
#---------------------------------------------------------------------------#

#install_clone_deps

#mk_clone

#compress_clone
#compress_built_source

#run_build_sh

#run_re_build_sh

make_bmap_image
echo "#+++   run.sh completed     ++++++++++++++++++#"
echo "#------ Machinekit Rip build completed -------#"

#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
OK="yes"

function contains() {
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++)) {
        if [ "${!i}" == "${value}" ]; then
#            echo "y"
            return 0
        fi
    }
#    echo "n"
    return 1
}

exit_fail() {
    echo "Script_MSG: Exit error: in function ${curr_function}"
    exit 1
}

extract_xz() {
    echo "MSG: using tar for xz extract"
    tar xfS ${1} --use-compress-program lbzip2
}

## parameters: 1: folder name, 2: url, 3: file name
get_and_extract() {
    if [ ! -f ${3} ]; then
        echo "MSG: downloading ${2}"
        wget -c ${2}
    fi
    echo "MSG: extracting ${3}"
    extract_xz ${3}
}

install_crossbuild_armhf() {
# install deps for u-boot build
    sudo apt -y build-dep linux
    sudo apt -y install
    sudo dpkg --add-architecture armhf
    sudo apt -y install --no-install-recommends build-essential crossbuild-essential-armhf
#    sudo apt -y install --reinstall lib32stdc++6 gcc-arm-linux-gnueabihf
    sudo apt -y install --reinstall lib32stdc++6-x32-cross gcc-arm-linux-gnueabihf
}

install_crossbuild_arm64() {
# install deps for u-boot build
    sudo apt -y build-dep linux
    sudo apt -y install
    sudo dpkg --add-architecture arm64
    sudo apt -y install --no-install-recommends build-essential crossbuild-essential-arm64
    sudo apt -y install --reinstall libstdc++6-arm64-cross gcc-5-aarch64-linux-gnu-base gcc-5-aarch64-linux-gnu
}

install_uboot_dep() {
# install deps for u-boot build
    sudo ${apt_cmd} -y install lib32z1 device-tree-compiler bc u-boot-tools
}

install_kernel_dep() {
# install deps for kernel build
    sudo ${apt_cmd} -y install fakeroot bc u-boot-tools
}

install_rootfs_dep() {
    sudo apt-get -y install qemu binfmt-support qemu-user-static schroot debootstrap libc6 debian-archive-keyring
    sudo apt update
#    sudo apt -y --force-yes upgrade
    sudo update-binfmts --display | grep interpreter
}

uiomod_kernel() {
cd ${RT_KERNEL_BUILD_DIR}
if [ "${KERNEL_PKG_VERSION}" == "0.1" ]; then
    patch  -p2 < ${PATCH_SCRIPT_DIR}/arm-linux-${RT_KERNEL_VERSION}_uio_patch.txt
else
    patch  -p2 < ${PATCH_SCRIPT_DIR}/arm-linux-${RT_KERNEL_VERSION}_uio-fb_patch.txt
    patch  -p2 < ${PATCH_SCRIPT_DIR}/arm-linux-${RT_KERNEL_VERSION}_socsynth-de1-audio_patch.txt
    patch  -p2 < ${PATCH_SCRIPT_DIR}/arm-linux-${RT_KERNEL_VERSION}_add-de1-soc-socsynth_patch.txt
fi
echo "Kernel Custom Patch added"
#cd ${RT_KERNEL_BUILD_DIR}
#Uio Config additions:
echo "config file mods applied"

}

rt_patch_kernel() {
cd ${RT_KERNEL_PARENT_DIR}
if [ ! -f ${RT_PATCH_FILE} ]; then #if file with that name not exists
        echo "fetching patch"
        wget ${RT_PATCH_URL}
fi
cd ${RT_KERNEL_BUILD_DIR}
xzcat ../${RT_PATCH_FILE} | patch -p1
echo "rt-Patch applied"
## Uio Patch:
uiomod_kernel
#cp /home/mib/intelFPGA/QuartusProjects/DE1-Soc/DE1-SoC-Sound/socfpga_cyclone5_DE1-SoC-FB.dts /home/mib/Development/HolosynthV-Image-gen/arm-linux-4.9.33-gnueabihf-kernel/linux-4.9.33/arch/arm/boot/dts
#cp /home/mib/intelFPGA/QuartusProjects/DE1-Soc/DE1-SoC-Sound/Makefile-dtb /home/mib/Development/HolosynthV-Image-gen/arm-linux-4.9.33-gnueabihf-kernel/linux-4.9.33/arch/arm/boot/dts/Makefile
}

## parameters: 1: folder name, 2: patch file name
git_patch() {
    echo "MGG: Applying patch ${2}"
    cd "${1}"
    git am --signoff < ${2}
}

## parameters: 1: top folder name, 2: url, 3: branch name, 4: checkout string, 5: clone folder name, 6: patch file name
git_fetch() {
#    set -x
    if [ ! -d "${1}" ]; then
        echo "MSG: dir ${1} does not exist"
        mkdir ${1}
    fi
    cd ${1}
    if [ ! -z "${5}" ]; then
        echo "MSG: cloning ${2} into ${5}"
        git clone ${2} ${5}
    else
        echo "MSG: cloning ${2}"
        git clone ${2}
    fi
    if [ ! -z "${5}" ]; then
        echo "MSG: cleaning repo"
        cd ${1}/${5}
#        git remote add linux ${KERNEL_URL}
        git clean -d -f -x
        git fetch origin
#        git reset --hard origin/${4}
        git reset --hard ${4}
        git checkout ${4}
    else
        cd ${1}
        if [ ! -z "${3}" ]; then
            git fetch origin
            git reset --hard origin/master
            echo "MSG: Will now check out " ${3}
            git checkout ${3} ${4}
        fi
    fi
    if [ ! -z "${6}" ]; then
        if [ -f "${PATCH_SCRIPT_DIR}/${6}" ]; then
            echo "MSG: Will now apply patch: " ${PATCH_SCRIPT_DIR}/${6}
            git_patch ${1}/${5} ${PATCH_SCRIPT_DIR}/${6}
        else
            echo "MSG: Patch file: " ${PATCH_SCRIPT_DIR}/${6} "not found"
        fi
    fi
    cd ..
}

## parameters: 1: folder name, 2: config string 3: build string 4: env_tools
armhf_build() {
#    set -x
    cd ${1}
    ## configure - compile
    export ARCH=arm
    export CROSS_COMPILE=$CC

    echo "MSG: configuring ${1}"
    echo "MSG: as ${2}"
    make -j${NCORES} mrproper
    if [ ! -z "${3}" ]; then
        echo "MSG: compiling ${1}"
        if [ "${3}" == "deb-pkg" ]; then
            make -j${NCORES} "${2}" NAME="Michael Brown" EMAIL="producer@holotronic.dk" ARCH=arm KBUILD_DEBARCH=armhf LOCALVERSION=-"socfpga-${KERNEL_PKG_VERSION}" KERNELRELEASE=${ALT_GIT_KERNEL_VERSION}-socfpga-rt-lts-1.0 deb-pkg
        else
            make -j${NCORES} "${2}"
            echo "MSG: building ${1}"
            make -j$NCORES "${3}"
            if [ ! -z "${4}" ]; then
                make CROSS_COMPILE=$CCROSS -j$NCORES "${4}"
            fi
        fi
    else
        make -j${NCORES} "${2}" NAME="Michael Brown" EMAIL="producer@holotronic.dk" ARCH=arm KBUILD_DEBARCH=armhf LOCALVERSION=-"socfpga-${KERNEL_PKG_VERSION}" KDEB_PKGVERSION="1" deb-pkg
    fi
}

## parameters: 1: folder name, 2: config string 3: build string 4: env_tools
arm64_build() {
#    set -x
    cd ${1}
    ## configure - compile
    export ARCH=arm64
#    export PATH=$CC_DIR/bin/:$PATH
    export CROSS_COMPILE=$CC_64

    echo "MSG: configuring ${1}"
    echo "MSG: as ${2}"
    make -j${NCORES} mrproper
    if [ ! -z "${3}" ]; then
        echo "MSG: compiling ${1}"
        if [ "${3}" == "deb-pkg" ]; then
            make -j${NCORES} "${2}" NAME="Michael Brown" EMAIL="producer@holotronic.dk" ARCH=arm64 KBUILD_DEBARCH=arm64 UIMAGE_LOADADDR=0x8000 LOCALVERSION=-"socfpga64-${KERNEL_PKG_VERSION}" KDEB_PKGVERSION="2" "${3}"
#            make -j${NCORES} "${2}" NAME="Michael Brown" EMAIL="producer@holotronic.dk" ARCH=arm64 KBUILD_DEBARCH=arm64 KBUILD_IMAGE=arch/arm64/boot/Image LOCALVERSION=-"socfpga64-${KERNEL_PKG_VERSION}" KDEB_PKGVERSION="2" linux.bin deb-pkg
#            make -j${NCORES} "${2}" NAME="Michael Brown" EMAIL="producer@holotronic.dk" ARCH=arm64 KBUILD_DEBARCH=arm64 KBUILD_IMAGE=Image LOCALVERSION=-"socfpga64-${KERNEL_PKG_VERSION}" KDEB_PKGVERSION="2" deb-pkg
            ${CROSS_COMPILE}objcopy -O binary -R .note -R .comment -S vmlinux linux.bin
            gzip -9 linux.bin
            mkimage -A ppc -O linux -T kernel -C gzip -a 0 -e 0 -n "Linux Kernel Image" -d linux.bin.gz uImage
        else
            make -j${NCORES} "${2}"
            echo "MSG: building ${1}"
            make -j$NCORES "${3}"
            if [ ! -z "${4}" ]; then
                make CROSS_COMPILE=$CC_64 -j$NCORES "${4}"
            fi
        fi
    else
        make -j${NCORES} "${2}" NAME="Michael Brown" EMAIL="producer@holotronic.dk" ARCH=arm64 KBUILD_DEBARCH=arm64 KBUILD_IMAGE=arch/arm64/boot/Image LOCALVERSION=-"socfpga64-${KERNEL_PKG_VERSION}" KDEB_PKGVERSION="2" deb-pkg
    fi
}

## parameters: 1: distro name, 2: dir, 3: dist arch, 4: file filter
add2repo(){
#sudo systemctl stop apache2
#set -x
    contains ${DISTROS[@]} ${1}
    if [ "$?" -eq 0 ]; then
        echo "Valid distroname = ${1} given"
        contains ${DISTARCHS[@]} ${3}
        if [ "$?" -eq 0 ]; then
            echo "Valid distarch = ${3} given"

            echo ""
            echo "Script_MSG: Repo content before -->"
            echo ""
            if [[ "${1}" == "bionic" ]]; then
                dist_flavor=ubuntu
            else
                dist_flavor=debian
            fi
            LIST1=`reprepro -b "${HOME_REPO_DIR}/${dist_flavor}" -C main -A ${3} --list-format='''${package}\n''' list ${1} | { grep -E "${4}" || true; }`
            echo "Got list1"
            REPO_LIST1=$"${LIST1}"

            echo "REPO_LIST1"

            echo "${REPO_LIST1}"
            echo "Script_MSG: Contents of REPO_LIST1 -->"
            echo "${REPO_LIST1}"

            echo ""

            if [ ! -z "${REPO_LIST1}" ]; then
                echo ""
                echo "Script_MSG: Will remove former version from repo"
                echo ""
                reprepro -b "${HOME_REPO_DIR}/${dist_flavor}" -C main -A ${3} remove ${1} ${REPO_LIST1}
                reprepro -b "${HOME_REPO_DIR}/${dist_flavor}" export ${1}
                echo "Script_MSG: Restarting web server"

                sudo systemctl restart apache2
                reprepro -b "${HOME_REPO_DIR}/${dist_flavor}" export ${1}
            else
                echo ""
                echo "Script_MSG: Former version not found"
                echo ""
            fi
            echo ""

            #
            # if [[ "${CLEAN_KERNELREPO}" ==  "${OK}" ]]; then
            # CLEAN_ALL_LIST=`reprepro -b "${HOME_REPO_DIR}/${dist_flavor}" -C main -A ${3} --list-format='''${package}\n''' list ${1}`
            #
            # JESSIE_CLEAN_ALL_LIST=$"${CLEAN_ALL_LIST}"
            #
            # 	if [ ! -z "${JESSIE_CLEAN_ALL_LIST}" ]; then
            # 		echo ""
            # 		echo "Script_MSG: Will clean repo"
            # 		echo ""
            # 		reprepro -b "${HOME_REPO_DIR}/${dist_flavor}" -C main -A ${3} remove ${1} ${JESSIE_CLEAN_ALL_LIST}
            #                 reprepro -b "${HOME_REPO_DIR}/${dist_flavor}" export ${1}
            #                 echo "Script_MSG: Restarting web server"
            #                 sudo systemctl restart apache2
            # 	else
            # 		echo ""
            # 		echo "Script_MSG: Repo is empty"
            # 		echo ""
            # 	fi
            # 	echo ""
            # fi
            #
            reprepro -b "${HOME_REPO_DIR}/${dist_flavor}" -C main -A ${3} includedeb ${1} ${2}/*.deb
            reprepro -b "${HOME_REPO_DIR}/${dist_flavor}" export ${1}
            reprepro -b "${HOME_REPO_DIR}/${dist_flavor}" list ${1}

            LIST2=`reprepro -b "${HOME_REPO_DIR}/${dist_flavor}" -C main -A ${3} --list-format='''${package}\n''' list ${1}`
            REPO_LIST2=$"${LIST2}"
            echo  "${REPO_LIST2}"
            echo ""
            echo "Script_MSG: Repo content After: -->"
            echo ""
            echo  "${REPO_LIST2}"
            echo ""
            echo "#--->       Repo updated                                                  <---#"
        else
            echo "--xxx2repo bad argument --> ${3}"
            echo "Use =distroname=distarch"
            echo "Valid distarchs are:"
            echo " ${DISTARCHS[@]}"
        fi
    else
        echo "--xxx2repo bad argument --> ${1}"
        echo "Use =distroname=distarch"
        echo "Valid distrosnames are:"
        echo " ${DISTROS[@]}"
        echo "Valid distarchs are:"
        echo " ${DISTARCHS[@]}"
    fi
}

## parameters: 1: dev mount name, 2: kernel tag
inst_kernel_from_local_repo(){

cd ${CURRENT_DIR}

sudo cp -f ${1}/etc/apt/sources.list-local ${1}/etc/apt/sources.list
sudo rm -f ${1}/etc/resolv.conf
sudo cp -f /etc/resolv.conf ${1}/etc/resolv.conf

echo ""
sudo chroot --userspec=root:root ${1} /bin/mkdir -p /var/tmp
sudo chroot --userspec=root:root ${1} /bin/chmod 1777 /var/tmp
sudo chroot --userspec=root:root ${1} /usr/bin/${apt_cmd} -y update
#
sudo chroot --userspec=root:root ${1} /usr/bin/${apt_cmd} -y update

sudo chroot --userspec=root:root ${1} /usr/bin/${apt_cmd} -y upgrade

echo ""
echo "Script_MSG: Will now install kernel packages"
echo ""
sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install linux-headers-'${2}' linux-image-'${2}''


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
    echo "# Script_MSG:   mounting imagefile:                                                       #"
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
    echo "# Script_MSG:   mounting imagefile:                                                       #"
    if [ -z "${3}" ]; then
        echo "# Script_MSG: 1 empty image:"
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
    echo "Script_MSG: Unmounting Imagefile in ---> ${1}"
    sudo umount -R ${1}
}

## parameters: 1: loop dev
unmount_loopdev(){
    echo "Script_MSG: Unmounting loopdev in ---> ${1}"
    sudo losetup -d ${LOOP_DEV}
}

## parameters: 1: image name
create_rootfs_img() {
echo "#-------------------------------------------------------------------------------#"
echo "#-------------------------                      --------------------------------#"
echo "#---------------    +++ creating blank rootfs image  zzz  +++ .......  ---------#"
echo "#-----------------------------   wait   ----------------------------------------#"
echo "#-------------------------------------------------------------------------------#"

sudo dd if=/dev/zero of=${1}  bs=4K count=1500K
sudo sh -c "LC_ALL=C ${mkfs} ${mkfs_options} ${1} ${mkfs_label}"
}

## parameters: 1: loop dev name, 2: boot partition
fdisk_2part() {
sudo fdisk ${1} << EOF
n
p
1

+1G
t
a2
n
p
2


a
${2}
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
a
3
w
EOF
}

## parameters: 1: no of partitions, 2: img file name, 3: mount dev name, 4: rootfs partition, 5: boot partition
create_img() {
#--------------- Initial sd-card image - partitioned --------------
echo "#-------------------------------------------------------------------------------#"
echo "#-----------------------------          ----------------------------------------#"
echo "#---------------     +++ generating sd-card image  zzz  +++ ........  ----------#"
echo "#---------------------------  Please  wait   -----------------------------------#"
echo "#-------------------------------------------------------------------------------#"

mkfs_label="-L ${ROOTFS_LABEL}"

if [ "${1}" = "1" ]; then
    echo "# Script_MSG: 1 part rootfs image"
    create_rootfs_img ${2}
elif [ "${1}" = "2" ] || [ "${1}" = "3" ]; then
    sudo dd if=/dev/zero of=${2} bs=4K count=1850K
#    sudo dd if=/dev/zero of=${2} bs=4K count=3525K
    echo "Now mounting sd-image file"
    mount_sd_imagefile ${2} ${3}
    if [ "${1}" = "2" ]; then
        echo "# Script_MSG: 2 part sd image"
        fdisk_2part ${LOOP_DEV} ${5}
    elif [ "${1}" = "3" ]; then
        echo "# Script_MSG: 3 part sd image"
        fdisk_3part_swap ${LOOP_DEV}
    fi
    sudo sync
    echo "# Script_MSG: will now part probe"
    sudo partprobe -s ${LOOP_DEV}
    sudo sync

    echo ""
    echo "SubScript_MSG: creating file systems"
    echo ""

    sudo sh -c "LC_ALL=C mkfs -t vfat -n BOOT ${LOOP_DEV}p1"
    if [ "${1}" = "2" ]; then
        mkfs_partition="${LOOP_DEV}p2"
        sudo sh -c "LC_ALL=C ${mkfs} ${mkfs_options} ${mkfs_partition} ${mkfs_label}"
    elif [ "${1}" = "3" ]; then
        mkfs_partition="${LOOP_DEV}${4}"
        sudo sh -c "LC_ALL=C ${mkfs} ${mkfs_options} ${mkfs_partition} ${mkfs_label}"
    fi

    if [ "${1}" = "3" ]; then
        sudo mkswap -f ${LOOP_DEV}${media_swap_partition}
    fi

    sudo sync
    unmount_loopdev ${LOOP_DEV}
else
    echo ""
    echo "SubScript_MSG: create_img() No Valid number of partitions given ie: 1(rootfs only), 2 or 3(with swap)"
    echo ""
fi

}

## parameters: 1: mount dev name
bind_mounted(){
    sudo mkdir -p ${1}/dev
    sudo mkdir -p ${1}/proc
    sudo mkdir -p ${1}/sys
    sudo sync
    sudo mount --bind /dev ${1}/dev
    sudo mount --bind /proc ${1}/proc
    sudo mount --bind /sys ${1}/sys

    echo "#--------------------------------------------------------------------------------------#"
    echo "# Script_MSG: ${1} now Bind mounted                                                  #"
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
    echo "Script_MSG: current dir is now: ${CDR}"
    echo ""
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo ""
    sudo sync
        echo "Script_MSG: Will now ummount ${1}"
        RES=`eval sudo umount -R ${1}`
        echo ""
        echo "Script_MSG: Unmont result = ${RES}"
        echo "Script_MSG: Unmont return value = ${?}"
    if [ -d "${1}/dev" ]; then
        echo ""
        echo "Script_MSG: umount -R failed"
        echo "Script_MSG: Will now run  kill_ch_proc ${1}"
        echo ""
        kill_ch_proc ${1}
        if [ -d "${1}/dev" ]; then
            echo "Script_MSG: kill_ch_proc ${1} failed also "
            exit 1
        else
            echo ""
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo ""
            echo "Script_MSG: ${1} was unmounted correctly with kill_ch_proc"
            echo ""
            echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo ""
        fi
    else
        echo ""
        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ""
        echo "Script_MSG: ${1} was unmounted correctly with umount -R"
        echo ""
        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo ""
    fi
}

# parameters: 1: work dir, 2: mount dev name, 3: comp prefix, 4 distro name
compress_rootfs(){
    if [ "${4}" == "bionic" ]; then
        COMPNAME=ubuntu-${4}-${3}
    else
        COMPNAME=debian-${4}-${3}
    fi
    echo "#---------------------------------------------------------------------------#"
    echo "#Script_MSG:                                                                   #"
    echo "compressing latest rootfs from image into: -->                              #"
    echo " ${1}/${COMPNAME}_rootfs.tar.bz2"
    echo "----------------------------------------------------------------------------#"
    cd ${2}
    sudo tar -cSf ${1}/${COMPNAME}_rootfs.tar.bz2 --exclude=proc --exclude=mnt --exclude=lost+found --exclude=dev --exclude=sys . --use-compress-program lbzip2
    cd ${1}
    echo "#                                                                           #"
    echo "#Script_MSG:                                                                   #"
    echo "${COMPNAME}_rootfs.tar.bz2 rootfs compression finished ..."
    echo "#                                                                           #"
    echo "#---------------------------------------------------------------------------#"
}

# parameters: 1: work dir, 2: mount dev name, 3: comp prefix, 4 distro name
extract_rootfs(){
if [ ! -z "${3}" ]; then
    if [ "${4}" == "bionic" ]; then
        COMPNAME=ubuntu-${4}-${3}
    else
        COMPNAME=debian-${4}-${3}
    fi
    echo "Script_MSG: Extracting ${1}/${COMPNAME}_rootfs.tar.bz2"
    echo "Script_MSG: Into imagefile"
    echo "Rootfs configured ... extracting  ${COMPNAME} rootfs into image...."
    ## extract rootfs into image:
    sudo tar xfS ${1}/${COMPNAME}_rootfs.tar.bz2 -C ${2} --use-compress-program lbzip2
    echo "${1}/${COMPNAME}_rootfs.tar.bz2 rootfs extraction finished .."
fi
}

# parameters: 1: variable name, 2: variable value
sv(){
#fw_setenv [-c /my/fw_env.config] [-a key] [variable name] [variable value]
sudo sh -c 'fw_setenv -c '${CURRENT_DIR}'/fw_env.config '"${1}"' '"${2}"''
}

# parameters: 1: local destination 2: rootfs mount, 3: board name
set_fw_uboot_env_mnt(){
echo ""
echo "NOTE:  Will now generate ${2}/etc/fw_env.config"
echo ""
sudo sh -c 'cat <<EOT > '${2}'/etc/fw_env.config
# MMC device name       Device offset   Env. size       Flash sector size       Number of sectors
/dev/mmcblk0            0x4000          0x2000
EOT'
echo ""
echo "NOTE:  Generated ${2}/etc/fw_env.config"

#cat <<EOT > ${CURRENT_DIR}/fw_env.config
# MMC device name       Device offset   Env. size       Flash sector size       Number of sectors
#${1}            0x4000          0x2000
#EOT

}


# parameters: 1: uboot dir, 2: uboot filename, 3: sd img file name
install_uboot() {
UBOOT_SPLFILE="${1}/${2}"
echo ""
echo "installing ${UBOOT_SPLFILE}"
echo ""
sudo dd bs=512 if=${UBOOT_SPLFILE} of=${3} seek=2048 conv=notrunc
sudo sync
}

# parameters: 1: work dir, 2: sd img file name
make_bmap_image() {
    echo ""
    echo "NOTE:  Now making bmap image"
    cd ${1}
    bmaptool create -o ${2}.bmap ${2}
    echo "Done ...."
    echo ""
    echo "NOTE:  Now making compressed image file (lbzip2)"
    tar -cSf ${2}.tar.bz2 ${2} --use-compress-program lbzip2
    echo "Done ...."
    echo ""
    echo "NOTE:  Now making md5sum of compressed image file"
    md5sum ${2}.tar.bz2 > ${2}.tar.bz2.md5
    echo "Done ...."
    echo ""
    echo "NOTE:  Bmap image created"
    echo ""
}

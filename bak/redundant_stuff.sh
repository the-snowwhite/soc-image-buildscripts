#!/bin/bash

#GCC v6
#http://releases.linaro.org/components/toolchain/binaries/6.3-2017.05/arm-linux-gnueabihf/gcc-linaro-6.3.1-2017.05-x86_64_arm-linux-gnueabihf.tar.xz
#GCC_REL="6.3"
#GCC_VER="1"
#GCC_REV="2017.05"
#PCH63_CC_FOLDER_NAME="gcc-linaro-${GCC_REL}.${GCC_VER}-${GCC_REV}-x86_64_${CROSS_GNU_ARCH}"
#PCH63_CC_FILE="${PCH63_CC_FOLDER_NAME}.tar.xz"
#PCH63_CC_URL="http://releases.linaro.org/components/toolchain/binaries/${GCC_REL}-${GCC_REV}/${CROSS_GNU_ARCH}/${PCH63_CC_FILE}"


#GCC v5
#PCH52_CC_FOLDER_NAME="gcc-linaro-5.2-2015.11-1-x86_64_${CROSS_GNU_ARCH}"
#PCH52_CC_FILE="${PCH52_CC_FOLDER_NAME}.tar.xz"
#PCH52_CC_URL="http://releases.linaro.org/components/toolchain/binaries/5.2-2015.11-1/${CROSS_GNU_ARCH}/${PCH52_CC_FILE}"

#TOOLCHAIN_DIR=${HOME}/bin


#-----------------------------------------------------------------------------------
# local functions
#-----------------------------------------------------------------------------------
usage()
{
    echo ""
    echo "    -h --help (this printout)"
    echo "    --deps    Will install build deps"
#     echo "    --build_rt-ltsi-kernel   Will download rt-ltsi kernel, patch and build kernel (add =c to skip build)"
#     echo "    --rtkernel2repo   Will add kernel .debs to local repo"
#     echo "    --build_qt_cross  Will build and install qt in rootfs image"
#     echo "    --crossbuild_qt_plugins  Will build and install qt plugins in qt_rootfs image"
    echo "    --assemble_qt_dev_sd_img   Will generate full populated sd imagefile with QT-dev and bmap file"
    echo ""
}


# build_rt_ltsi_kernel() {
#     distro="stretch"
#     if [ -d ${RT_KERNEL_BUILD_DIR} ]; then
#         echo the kernel target directory ${RT_KERNEL_BUILD_DIR} already exists cleaning ...
#         rm -R ${RT_KERNEL_BUILD_DIR}
#         cd ${RT_KERNEL_PARENT_DIR}
#         extract_xz ${RT_KERNEL_FILE_NAME}
#     else
#         mkdir -p ${RT_KERNEL_PARENT_DIR}
#         cd ${RT_KERNEL_PARENT_DIR}
#         get_and_extract ${RT_KERNEL_PARENT_DIR} ${KERNEL_URL} ${RT_KERNEL_FILE_NAME}
#     fi
#     rt_patch_kernel
#     if [ "${1}" != "c" ]; then
#     armhf_build "${RT_KERNEL_BUILD_DIR}" "${KERNEL_PRE_CONFIGSTRING}"
#     fi
# }

#,task-lxde-desktop,lxsession,xinput

# run_qt_qemu_debootstrap() {
# sudo qemu-debootstrap --foreign --arch=${4} --variant=buildd  --keyring /usr/share/keyrings/debian-archive-keyring.gpg --include=sudo,locales,nano,vim,adduser,apt-utils,rsyslog,libssh2-1,openssh-client,openssh-server,openssl,leafpad,kmod,dbus,dbus-x11,upower,udev,net-tools,lsof,less,accountsservice,iputils-ping,python,python3,ifupdown,iproute2,avahi-daemon,uuid-runtime,avahi-discover,libnss-mdns,traceroute,strace,u-boot-tools,initramfs-tools,gnupg2,dirmngr,wget,xorg,cgroupfs-mount,ntp,autofs,libpam-systemd,systemd-sysv,fuse,cgmanager,policykit-1,gtk2-engines-pixbuf,fontconfig,fontconfig-config,console-setup,fbset,libdirectfb-1.2-9,x11-xserver-utils,gksu,acpid ${2} ${1} ${3}
# output=${?}
# }
#,alsa-utils,alsamixergui,midish,midisnoop,multimedia-midi,anacron,jackd2,qjackctl,jack-tools,meterbridge
#
# ## parameters: 1: mount dev name, 2: distro name, 3: repo url, 4: distro arch
# run_qt_qemu_debootstrap() {
# sudo qemu-debootstrap --foreign --arch=${4} --variant=buildd --include=cgmanager,cgroupfs-mount,ntp,autofs,policykit-1,gtk2-engines-pixbuf,budgie-indicator-applet,sudo,locales,nano,apt-utils,adduser,rsyslog,console-setup,fbset,libdirectfb-1.2-9,libssh-4,openssh-client,openssh-server,openssl,leafpad,kmod,dbus,dbus-x11,x11-xserver-utils,upower,xorg,busybox,openbox,lxsession,xinput,udev,gksu,net-tools,lsof,less,accountsservice,iputils-ping,python,python3,ifupdown,iproute2,dhcpcd5,acpid,avahi-daemon,uuid-runtime,avahi-discover,libnss-mdns,traceroute,strace,u-boot-tools,initramfs-tools,alsa-utils,alsamixergui,midish,midisnoop,multimedia-midi,anacron,jackd2,qjackctl,jack-tools,meterbridge,fontconfig,fontconfig-config ${2} ${1} ${3}
# output=${?}
# }
#
#
# run_qt_qemu_debootstrap() {
# sudo qemu-debootstrap --foreign --arch=${4}--variant=buildd  --keyring /usr/share/keyrings/debian-archive-keyring.gpg --include=sudo,locales,nano,apt-utils,rsyslog,console-setup,fbset,libdirectfb-1.2-9,libssh2-1,openssh-client,openssh-server,openssl,leafpad,kmod,dbus,dbus-x11,x11-xserver-utils,xorg,busybox,openbox,lxsession,task-lxde-desktop,xinput,policykit-1,gtk2-engines-pixbuf,gksu,net-tools,lsof,less,accountsservice,iputils-ping,python,ifupdown,iproute2,dhcpcd5,acpid,avahi-daemon,uuid-runtime,avahi-discover,libnss-mdns,traceroute,strace,cgroupfs-mount,ntp,autofs,u-boot-tools,initramfs-tools,alsa-utils,alsamixergui,midish,midisnoop,multimedia-midi,anacron  ${2} ${1} ${3}
# }

# parameters: 1: board name
# gen_uboot_env_vars(){
# echo ""
# echo "NOTE:  Now setting uboot variables"
#
# # --- default env ----
# sv eth1addr
# sv eth3addr
# sv eth5addr
# sv ethaddr
# sv arch arm
# sv board ${1}
# sv board_name ${1}
# sv boot_net_usb_start "usb start"
# sv boot_targets "mmc0 pxe dhcp"
# sv bootcmd "run distro_bootcmd"
# sv bootcmd_dhcp "run boot_net_usb_start\; if dhcp \$\{scriptaddr\} \$\{boot_script_dhcp\}\; then source \$\{scriptaddr\}\; fi\;"
# sv bootcmd_host0 "setenv devnum 0\; run host_boot"
# sv bootcmd_mmc0 "setenv devnum 0\; run mmc_boot"
# sv bootcmd_pxe "run boot_net_usb_start\; dhcp\; if pxe get\; then pxe boot\; fi"
# sv bootm_size 0xa000000
# sv cpu armv7
# sv fdt_addr_r 0x02000000
# sv fdtfile "socfpga_cyclone5_${1}.dtb"
# sv host_boot "if host dev \$\{devnum\}\; then setenv devtype host\; run scan_dev_for_boot_part\; fi"
# sv kernel_addr_r 0x01000000
# sv loadaddr 0x01000000
# sv mmc_boot "if mmc dev \$\{devnum\}\; then setenv devtype mmc\; run scan_dev_for_boot_part\; fi"
# sv pxefile_addr_r x02200000
# sv ramdisk_addr_r 0x02300000
# sv scan_dev_for_boot "echo Scanning \$\{devtype\} \$\{devnum\}\:\$\{distro_bootpart\}\.\.\.\; for prefix in \$\{boot_prefixes\}\; do run scan_dev_for_extlinux\; run scan_dev_for_scripts\; done\;"
# sv scriptaddr 0x02100000
# sv soc socfpga
# sv usb_boot "usb start\; if usb dev \$\{devnum\}\; then setenv devtype usb\; run scan_dev_for_boot_part\; fi"
# sv vendor terasic
#
# # set hostname:
# sv hostname ${HOST_NAME}
# if [ "${DESKTOP}" == "yes" ]; then
# # load fpga:
# echo ""
# echo "NOTE:  Now setting uboot fpga load variables"
# sv axibridge ffd0501c
# sv axibridge_handoff 0x00000000
# sv bitimage /boot/DE1_SOC_Linux_FB.rbf
# sv boot_extlinux "run fpgaload\; run bridge_enable_handoff\; sysboot \$\{devtype\} \$\{devnum\}:\$\{distro_bootpart\} any \$\{scriptaddr\} \$\{prefix\}extlinux/extlinux.conf"
# sv bridge_enable_handoff "mw \$\{fpgaintf\} \$\{fpgaintf_handoff\}\; mw \$\{fpga2sdram\} \$\{fpga2sdram_handoff\}\; mw \$\{axibridge\} \$\{axibridge_handoff\}\; mw \$\{l3remap\} \$\{l3remap_handoff\}"
# sv fpga2sdram ffc25080
# sv fpga2sdram_apply 3ff795a4
# sv fpga2sdram_handoff 0x00000000
# sv fpgaintf ffd08028
# sv fpgaintf_handoff 0x00000000
# sv fpgaload "mmc rescan\; load mmc 0\:\$\{distro_bootpart\} \$\{loadaddr\} \$\{bitimage\}\; fpga load 0 \$\{loadaddr\} \$\{filesize\}"
# sv l3remap ff800000
# sv l3remap_handoff 0x00000019
# fi
# echo ""
# echo "NOTE:  u boot variables set OK"
# }



## parameters: 1: dev mount name
inst_qt_build_deps(){
echo ""
echo "Script_MSG: Installing Qt Build Deps"
echo ""

sudo cp -f ${1}/etc/apt/sources.list-local ${1}/etc/apt/sources.list

sudo rm -f ${1}/etc/resolv.conf
sudo cp -f /etc/resolv.conf ${1}/etc/resolv.conf

sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' update'
sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install --reinstall libharfbuzz0b libc6 libc6-dev'
sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install libpcre2-32-0 libpcre2-dev x11proto-core-dev libsm6 libsm-dev libgtk-3-common libgtk-3-0 libgtk-3-dev'

set +e
sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y build-dep qt5-default'
#sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install'
sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install qtbase5-dev'

sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install --reinstall "^libxcb.*" libxcb1-dev libx11-xcb-dev libxrender-dev libxi-dev libglu1-mesa-dev libinput10 libinput-pad1 libinput-dev libinput-pad-dev'
sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install libharfbuzz-dev libxcb-xkb1 libxkbcommon-dev libxkbcommon-x11-0 libxkbcommon-x11-dev libxkbcommon0 libxkbfile-dev libxkbfile1 libasound2-dev libmtdev1 libmtdev-dev'
#libgtk2.0-0 libgtk2.0-common libgtk2.0-dev libgtk-3-common libgtk-3-0 libgtk-3-dev libgdk-pixbuf2.0-dev libhunspell-1.3-0 libhunspell-dev hunspell-en-us libgl1-mesa-dev libglu1-mesa-dev
#libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev
sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install libxcb1 libxcb1-dev libx11-xcb1 libx11-xcb-dev libxcb-keysyms1 libxcb-keysyms1-dev libxcb-image0 libxcb-image0-dev libxcb-shm0 libxcb-shm0-dev libxcb-icccm4 libxcb-icccm4-dev libxcb-sync1 libxcb-sync0-dev libxcb-sync-dev libxcb-xfixes0-dev libxrender-dev libxcb-shape0-dev libxcb-randr0-dev libxcb-render-util0 libxcb-render-util0-dev libxcb-glx0-dev libxcb-xinerama0-dev libfontconfig1 libevdev2 libevdev-dev libudev1 libudev-dev libfontconfig1-dev'

#libegl1-mesa-dev libgegl-dev

# echo ""
# echo "Script_MSG: Installing Qt into rootfs.img "
# echo ""
cd ${CURRENT_DIR}

sudo cp -f ${1}/etc/apt/sources.list-final ${1}/etc/apt/sources.list
sudo chroot --userspec=root:root ${1} /bin/rm -f /etc/resolv.conf
sudo chroot --userspec=root:root ${1} /bin/ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
}



#
# qt_build(){
# echo ""
# echo "Script_MSG: Running qt_build.sh script"
# echo ""
# sh -c "${SUB_SCRIPT_DIR}/build_qt.sh ${CURRENT_DIR}" | tee ${CURRENT_DIR}/build_qt-log.txt
# }

qt_gen_mkspec(){

    rm -R -f ${QTDIR}/qtbase/mkspecs/linux-arm-gnueabihf-g++
    mkdir -p ${QTDIR}/qtbase/mkspecs/linux-arm-gnueabihf-g++
    cp -f -R ${QTDIR}/qtbase/mkspecs/linux-arm-gnueabi-g++/* ${QTDIR}/qtbase/mkspecs/linux-arm-gnueabihf-g++/

# qmake.conf contents:
#sh -c 'cat <<EOF > "${QTDIR}/qtbase/mkspecs/linux-arm-gnueabihf-g++/qmake.conf"
sh -c 'cat <<EOF > '${QTDIR}'/qtbase/mkspecs/linux-arm-gnueabihf-g++/qmake.conf
#
# qmake configuration for building with linux-arm-gnueabihf-g++
#

MAKEFILE_GENERATOR      = UNIX
CONFIG                 += incremental gdb_dwarf_index
QMAKE_INCREMENTAL_STYLE = sublib

include(../common/linux.conf)
include(../common/gcc-base-unix.conf)
include(../common/g++-unix.conf)

CROSS_GNU_ARCH          = linux-arm-gnueabihf
warning("preparing QMake configuration for '${CROSS_GNU_ARCH}'")
CONFIG += '${CROSS_GNU_ARCH}'


QT_QPA_DEFAULT_PLATFORM = xcb

# modifications to g++.conf -fPIC
QMAKE_CC                = '${QT_CC}'gcc
QMAKE_CXX               = '${QT_CC}'g++ -fPIC
QMAKE_LINK              = '${QT_CC}'g++ -fPIC
QMAKE_LINK_SHLIB        = '${QT_CC}'g++ -fPIC

# modifications to linux.conf
QMAKE_AR                = '${QT_CC}'ar cqs
QMAKE_OBJCOPY           = '${QT_CC}'objcopy
QMAKE_NM                = '${QT_CC}'nm -P
QMAKE_STRIP             = '${QT_CC}'strip

#modifications to gcc-base.conf
QMAKE_CFLAGS           += '"${QT_CFLAGS}"'
QMAKE_CXXFLAGS         += '"${QT_CFLAGS}"'
QMAKE_CXXFLAGS_RELEASE += -O3

QMAKE_LIBS             += -lrt -lpthread -ldl

QMAKE_RPATHLINKDIR += '${QT_ROOTFS_MNT}'/lib/linux-arm-gnueabihf
QMAKE_RPATHLINKDIR += '${QT_ROOTFS_MNT}'/usr/lib/linux-arm-gnueabihf
QMAKE_RPATHLINKDIR += '${QT_ROOTFS_MNT}'/usr/lib/

#QMAKE_LFLAGS_RELEASE=-"Wl,-O1,-rpath,'${QT_ROOTFS_MNT}'/usr/lib,-rpath,'${QT_ROOTFS_MNT}'/usr/lib/'${CROSS_GNU_ARCH}',-rpath,'${QT_ROOTFS_MNT}'/lib/'${CROSS_GNU_ARCH}'"
#QMAKE_LFLAGS_DEBUG += "-Wl,-rpath,'${QT_ROOTFS_MNT}'/usr/lib,-rpath,'${QT_ROOTFS_MNT}'/usr/lib/${CROSS_GNU_ARCH},-rpath,'${QT_ROOTFS_MNT}'/lib/${CROSS_GNU_ARCH}"

#QMAKE_INCDIR='${QT_ROOTFS_MNT}'/usr/include
#QMAKE_LIBDIR='${QT_ROOTFS_MNT}'/usr/lib
#QMAKE_LIBDIR+='${QT_ROOTFS_MNT}'/usr/lib/'${CROSS_GNU_ARCH}'
#QMAKE_LIBDIR+='${QT_ROOTFS_MNT}'/lib/'${CROSS_GNU_ARCH}'
#QMAKE_INCDIR_X11='${QT_ROOTFS_MNT}'/usr/include
#QMAKE_LIBDIR_X11='${QT_ROOTFS_MNT}'/usr/lib
#QMAKE_INCDIR_OPENGL='${QT_ROOTFS_MNT}'/usr/include
#QMAKE_LIBDIR_OPENGL='${QT_ROOTFS_MNT}'/usr/lib

load(qt_config)

EOF'
# solve pkg-config:
mkdir "${QTDIR}/qtbase/mkspecs/linux-arm-gnueabihf-g++/features"
cat <<EOF > "${QTDIR}/qtbase/mkspecs/linux-arm-gnueabihf-g++/features/link_xpkgconfig"
for(PKGCONFIG_LIB, $$list($$unique(PKGCONFIG))) {
    PKG_CONFIG_LIBDIR=/usr/${QT_ROOTFS_MNT}/lib/pkgconfig
    QMAKE_CXXFLAGS += $$system(PKG_CONFIG_LIBDIR=${PKG_CONFIG_LIBDIR} pkg-config --cflags ${PKGCONFIG_LIB})
    QMAKE_CFLAGS += $$system(PKG_CONFIG_LIBDIR=${PKG_CONFIG_LIBDIR} pkg-config --cflags ${PKGCONFIG_LIB})
    LIBS += $$system(PKG_CONFIG_LIBDIR=${PKG_CONFIG_LIBDIR} pkg-config --libs ${PKGCONFIG_LIB})
EOF
}
# Your project file then needs these lines added (alsa and pango are just examples):
#
# linux-g++ {
# CONFIG += link_pkgconfig
# PKGCONFIG += alsa pango
# }
#
# count(CROSS_GNU_ARCH, 1) {
# CONFIG += link_xpkgconfig
# PKGCONFIG += alsa pango
# }

#-no-opengl -skip qtdeclarative -system-xcb
qt_configure(){
curr_function="qt_configure()"
# ../configure -help
../configure -release -opensource -confirm-license -nomake examples -qreal float -skip webengine -nomake tests -system-xcb -no-pch -shared -sysroot ${QT_ROOTFS_MNT} -xplatform linux-arm-gnueabihf-g++ -force-pkg-config -gui -linuxfb -widgets -device-option CROSS_COMPILE=${QT_CC} -prefix ${QT_PREFIX} -no-use-gold-linker

#../configure -release -opensource -confirm-license -nomake examples -nomake tools -skip webengine -nomake tests -system-xcb -no-pch -shared -sysroot ${QT_ROOTFS_MNT} -xplatform linux-arm-gnueabihf-g++ -force-pkg-config -gui -linuxfb -widgets -device-option CROSS_COMPILE=${QT_CC} -prefix ${QT_PREFIX} -no-use-gold-linker
#../configure -release -opensource -confirm-license -optimize-size -nomake tools -nomake examples -skip webengine -skip qtvirtualkeyboard -skip qtwayland -system-pcre -no-opengl -no-use-gold-linker -no-eglfs -nomake tests -system-xcb -no-pch -sysroot ${QT_ROOTFS_MNT} -xplatform linux-arm-gnueabihf-g++ -force-pkg-config -linuxfb -widgets -device-option CROSS_COMPILE=${QT_CC} -prefix /usr/local/lib/qt-${QT_VER}-altera-soc
# -qreal float -no-use-gold-linker -static -ltcg -qt-pcre, -system-pcre -gui -shared

#-platform linux-g++
#../configure -confirm-license -prefix "${QT_ROOTFS_MNT}/usr" -bindir "${QT_ROOTFS_MNT}/usr/lib/linux-arm-gnueabihf/qt5/bin" -libdir "${QT_ROOTFS_MNT}/usr/lib/linux-arm-gnueabihf" -docdir "${QT_ROOTFS_MNT}/usr/share/qt5/doc" -headerdir "${QT_ROOTFS_MNT}/usr/include/linux-arm-gnueabihf/qt5" -datadir "${QT_ROOTFS_MNT}/usr/share/qt5" -archdatadir "${QT_ROOTFS_MNT}/usr/lib/linux-arm-gnueabihf/qt5" -plugindir "${QT_ROOTFS_MNT}/usr/lib/linux-arm-gnueabihf/qt5/plugins" -importdir "${QT_ROOTFS_MNT}/usr/lib/linux-arm-gnueabihf/qt5/imports" -translationdir "${QT_ROOTFS_MNT}/usr/share/qt5/translations" -hostdatadir "${QT_ROOTFS_MNT}/usr/lib/linux-arm-gnueabihf/qt5" -sysconfdir "${QT_ROOTFS_MNT}/etc/xdg" -examplesdir "${QT_ROOTFS_MNT}/usr/lib/linux-arm-gnueabihf/qt5/examples" -opensource -plugin-sql-mysql -plugin-sql-odbc -plugin-sql-psql -plugin-sql-sqlite -no-sql-sqlite2 -plugin-sql-tds -system-sqlite -system-harfbuzz -system-zlib -system-libpng -system-libjpeg -system-doubleconversion -openssl -no-rpath -verbose -optimized-qmake -dbus-linked -no-strip -no-separate-debug-info -qpa xcb -xcb -glib -icu -accessibility -compile-examples -no-directfb -gstreamer 1.0 -plugin-sql-ibase  -no-opengl -no-eglfs -xplatform linux-arm-gnueabihf-g++
    output=${?}
    output1=${output}
    if [ ${output} -gt 0 ]; then
        exit_fail
    else
        echo "Script_MSG: function --> ${curr_function} exited with success"
    fi
}


qt_build(){
echo ""
echo "Script_MSG: Running qt_build"
echo ""

export PKG_CONFIG_PATH=${QT_ROOTFS_MNT}/usr/lib/linux-arm-gnueabihf/pkgconfig
export PKG_CONFIG_SYSROOT_DIR=${QT_ROOTFS_MNT}
export CROSS_COMPILE=${QT_CC}

GEN_MKSPEC_QT="yes";
CONFIGURE_QT="yes";
#
BUILD_QT="yes";
#
INSTALL_QT="yes";

mkdir -p ${CURRENT_DIR}/Qt_logs

if [[ "${GEN_MKSPEC_QT}" ==  "${OK}" ]]; then
    qt_gen_mkspec
    echo ""
    echo "Script_MSG: generated mkspecs"
#	wget https://raw.githubusercontent.com/riscv/riscv-poky/master/scripts/sysroot-relativelinks.py
fi


if [[ "${CONFIGURE_QT}" ==  "${OK}" ]]; then
    sudo rm -Rf ${QTDIR}/build
    mkdir -p ${QTDIR}/build
    cd ${QTDIR}/build
    qt_configure 2>&1| tee ${CURRENT_DIR}/Qt_logs/qt_configure-log.txt
    echo ""
    echo " qt_configure return value = ${output1}"
    echo ""
#	sudo cp -R '/usr/local/lib/qt-'${QT_VER}'-altera-soc' ''${QT_ROOTFS_MNT}'/usr/local/lib'
fi

if [[ "${BUILD_QT}" ==  "${OK}" ]]; then
    sudo ~/bin/sysroot-relativelinks.py ${QT_ROOTFS_MNT}
    cd ${QTDIR}/build
    make -j${NCORES} 2>&1| tee ${CURRENT_DIR}/Qt_logs/qt_build-log.txt
    output=${?}
    output2=${output}
    curr_function="make"
    if [ ${output} -gt 0 ]; then
        exit_fail
    fi
    echo ""
    echo " qt make return value = '${output2}"
    echo ""
fi

if [[ "${INSTALL_QT}" ==  "${OK}" ]]; then
    cd ${QTDIR}/build
    sudo make install 2>&1| tee ${CURRENT_DIR}/Qt_logs/qt_install-log.txt
    output=${?}
    output3=${output}
    curr_function="make_install"
    if [ ${output} -gt 0 ]; then
        exit_fail
    fi
    echo ""
    echo " qt_configure return value = ${output1}"
    echo ""
    echo ""
    echo " qt make return value = ${output2}"
    echo ""
    echo ""
    echo " qt make install return value = ${output3}"
    echo ""
#	sudo cp -R '/usr/local/lib/qt-'${QT_VER}'-altera-soc' ''${QT_ROOTFS_MNT}'/usr/local/lib'
fi
}

# configure_for_qt_qwt(){
# echo ""
# echo "Script_MSG: Setting up QWT"
# sudo cp -r ${QWT_PREFIX} ${QT_ROOTFS_MNT}/usr/local
# sudo sh -c 'echo "'${QWT_PREFIX}'/lib" > '${QT_ROOTFS_MNT}'/etc/ld.so.conf.d/qt.conf'
#
# sudo sh -c 'echo "\nexport LD_LIBRARY_PATH=$PATH:'${QWT_PREFIX}'/lib\n" >> '${QT_ROOTFS_MNT}'/etc/profile'
# sudo sh -c 'echo "\nexport LD_LIBRARY_PATH=$PATH:'${QWT_PREFIX}'/lib\n" >> '${QT_ROOTFS_MNT}'/.bashrc'
# sudo sh -c 'echo "\nexport LD_LIBRARY_PATH=$PATH:'${QWT_PREFIX}'/lib\n" >> '${QT_ROOTFS_MNT}'/.profile'
#
# sudo chroot --userspec=root:root ${QT_ROOTFS_MNT} /sbin/ldconfig
# }
#
# # parameters: 1: plugin name
# build_qt_plugins(){
# #
# BUILD_QWT="yes";
#
# CONFIGURE_FOR_QWT="yes";
# #CONFIGURE_FOR_QWT="no";
# QWT_PREFIX="/usr/local/qwt-6.3.0-svn"
#
# if [[ "${BUILD_QWT}" ==  "${OK}" ]]; then
#     export PKG_CONFIG_PATH=${QT_ROOTFS_MNT}/usr/lib/linux-arm-gnueabihf/pkgconfig
#     export PKG_CONFIG_SYSROOT_DIR=${QT_ROOTFS_MNT}
#     export CROSS_COMPILE=${QT_CC}
#     sudo rm -Rf ${QWTDIR}/../build
#     mkdir -p ${QWTDIR}/../build
#     cd ${QWTDIR}/../build
# #    "/usr/local/lib/qt-${QT_VER}-altera-soc/bin/qmake ${QWTDIR}/qwt.pro" 2>&1| tee ${CURRENT_DIR}/Qt_logs/qwt_qmake-log.txt
# #    qmake -makefile -qtconf /tmp/qmake.conf QMAKE_CC=arm-linux-gnueabihf-gcc QMAKE_CXX=arm-linux-gnueabihf-g++ QMAKE_LINK=arm-linux-gnueabihf-g++ ${QWTDIR}/qwt.pro 2>&1| tee ${CURRENT_DIR}/Qt_logs/qwt_build-log.txt
#     ${QT_ROOTFS_MNT}/${QT_PREFIX}/bin/qmake ${QWTDIR}/qwt.pro 2>&1| tee ${CURRENT_DIR}/Qt_logs/qwt_build-log.txt
#     make -j${NCORES} 2>&1| tee ${CURRENT_DIR}/Qt_logs/qwt_build-log.txt
#     sudo make install 2>&1| tee ${CURRENT_DIR}/Qt_logs/qwt_install-log.txt
# fi
# if [[ "${CONFIGURE_FOR_QWT}" ==  "${OK}" ]]; then
#     configure_for_qt_qwt
# fi
# }


while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE1=`echo $1 | awk -F= '{print $2}'`
    VALUE2=`echo $1 | awk -F= '{print $3}'`
    VALUE3=`echo $1 | awk -F= '{print $4}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
#         --build_rt-ltsi-kernel)
#             build_rt_ltsi_kernel "${VALUE1}"
#            ;;
#        --rtkernel2repo)
#            add2repo ${distro} ${RT_KERNEL_PARENT_DIR} ${RT_KERNEL_TAG}
#            add2repo "stretch" ${RT_KERNEL_PARENT_DIR} "${RT_KERNEL_TAG}-socfpga-${KERNEL_PKG_VERSION}|linux-libc-dev"
#            ;;
        --gen-base-qemu-rootfs) 
            ## parameters: 1: mount dev name, 2: image name, 3: distro name, 4: distro arch
            gen_rootfs_image ${ROOTFS_MNT} "${CURRENT_DIR}/base-qemu-${VALUE2}_${ROOTFS_IMG}" "${VALUE1}" "${VALUE2}" | tee ${CURRENT_DIR}/Logs/gen-qemu-base_rootfs-log.txt
            ;;
        --gen-base-qemu-rootfs-desktop)
            DESKTOP="yes"
            ## parameters: 1: mount dev name, 2: image name, 3: distro name, 4: distro arch
            gen_rootfs_image ${ROOTFS_MNT} "${CURRENT_DIR}/base-qemu-${VALUE2}-desktop_${ROOTFS_IMG}" "${VALUE1}" "${VALUE2}" | tee ${CURRENT_DIR}/Logs/gen-qemu-base_rootfs-log.txt
            ;;

#         --build_qt_cross)
#             if [ "$(ls -A ${QT_1})" ]; then
#                 echo "Script_MSG: !! Found ${QT_1} mounted .. will unmount now"
#                 unmount_binded ${QT_1}
#             fi
#             create_img "1" "${CURRENT_DIR}/${ROOTFS_IMG}"
#             mount_imagefile "${CURRENT_DIR}/${ROOTFS_IMG}" ${QT_1}
#             bind_mounted ${QT_1}
#             extract_rootfs ${CURRENT_DIR} ${QT_1} "${USER_NAME}_finalized-fully-configured-with-kernel-and-desktop-and-qt-deps"
#             qt_build
#             compress_rootfs ${CURRENT_DIR} ${QT_1} "${USER_NAME}_finalized-fully-configured-with-kernel-and-desktop-and-qtbuilt"
#             unmount_binded ${QT_1}
#             ;;
#         --crossbuild_qt_plugins)
#             if [ "$(ls -A ${QT_1})" ]; then
#                 echo "Script_MSG: !! Found ${QT_1} mounted .. will unmount now"
#                 unmount_binded ${QT_1}
#             fi
#             create_img "1" "${CURRENT_DIR}/${QT_ROOTFS_IMG}"
#             mount_imagefile "${CURRENT_DIR}/${QT_ROOTFS_IMG}" ${QT_1}
#             bind_mounted ${QT_ROOTFS_MNT}
#             extract_rootfs ${CURRENT_DIR} ${QT_ROOTFS_MNT} "${USER_NAME}_finalized-fully-configured-with-kernel-and-desktop-and-qtbuilt"
#             build_qt_plugins
#             compress_rootfs ${CURRENT_DIR} ${QT_ROOTFS_MNT} "${USER_NAME}_finalized-fully-configured-with-kernel-and-desktop-and-qtbuilt-and-qt-plugins"
#             unmount_binded ${QT_ROOTFS_MNT}
#             ;;
        --assemble_qt_dev_sd_img)
            DESKTOP="yes"
#            assemble_full_sd_img "finalized-fully-configured-with-kernel-and-qt-installed"
#            assemble_full_sd_img "${USER_NAME}_finalized-fully-configured-with-kernel-and-desktop-and-qtbuilt-and-qt-plugins" "${VALUE1}"
            assemble_full_sd_img "${USER_NAME}_finalized-fully-configured-with-kernel-and-desktop-and-qt-deps" "${VALUE1}"
            ;;

#!/bin/bash

## parameters: 1: mount dev name, 2: distro name, 3: repo url
run_qt_qemu_debootstrap() {
sudo qemu-debootstrap --foreign --arch=armhf --variant=buildd --include=budgie-desktop,xinput,cgmanager,cgroupfs-mount,ntp,autofs,policykit-1,gtk2-engines-pixbuf,budgie-indicator-applet,sudo,locales,nano,apt-utils,adduser,rsyslog,console-setup,fbset,libdirectfb-1.2-9,libssh-4,openssh-client,openssh-server,openssl,leafpad,kmod,dbus,dbus-x11,x11-xserver-utils,upower,xorg,udev,systemd,libpam-systemd,gksu,net-tools,lsof,less,accountsservice,iputils-ping,python,python3,ifupdown,iproute2,dhcpcd5,acpid,avahi-daemon,uuid-runtime,avahi-discover,libnss-mdns,traceroute,strace,u-boot-tools,initramfs-tools,alsa-utils,alsamixergui,midish,midisnoop,multimedia-midi,anacron,jackd2,qjackctl,jack-tools,meterbridge ${2} ${1} ${3}
output=${?}
}
#
# run_qt_qemu_debootstrap() {
# sudo qemu-debootstrap --foreign --arch=armhf --variant=buildd  --keyring /usr/share/keyrings/debian-archive-keyring.gpg --include=sudo,locales,nano,apt-utils,rsyslog,console-setup,fbset,libdirectfb-1.2-9,libssh2-1,openssh-client,openssh-server,openssl,leafpad,kmod,dbus,dbus-x11,x11-xserver-utils,xorg,busybox,openbox,lxsession,task-lxde-desktop,xinput,policykit-1,gtk2-engines-pixbuf,gksu,net-tools,lsof,less,accountsservice,iputils-ping,python,ifupdown,iproute2,dhcpcd5,acpid,avahi-daemon,uuid-runtime,avahi-discover,libnss-mdns,traceroute,strace,cgroupfs-mount,ntp,autofs,u-boot-tools,initramfs-tools,alsa-utils,alsamixergui,midish,midisnoop,multimedia-midi,anacron  ${2} ${1} ${3}
# }

#
gen_policy_rc_d() {
sudo sh -c 'cat <<EOT > '${ROOTFS_MNT}'/usr/sbin/policy-rc.d
echo "************************************" >&2
echo "All rc.d operations denied by policy" >&2
echo "************************************" >&2
exit 101
EOT'
}

gen_sudoers() {
sudo sh -c 'cat <<EOT > '${ROOTFS_MNT}'/etc/sudoers
#
# This file MUST be edited with the 'visudo' command as root.
#
# Please consider adding local content in /etc/sudoers.d/ instead of
# directly modifying this file.
#
# See the man page for details on how to write a sudoers file.
#
Defaults        env_reset
Defaults        mail_badpass
Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Host alias specification

# User alias specification

# Cmnd alias specification

# User privilege specification
root    ALL=(ALL:ALL) ALL
'${USER_NAME}'    ALL=(ALL:ALL) ALL

# Allow members of group sudo to execute any command
%sudo   ALL=(ALL:ALL) ALL

# See sudoers(5) for more information on "#include" directives:

#includedir /etc/sudoers.d

'${USER_NAME}' ALL=(ALL:ALL) NOPASSWD: ALL
%'${USER_NAME}' ALL=(ALL:ALL) NOPASSWD: ALL
EOT'

}


gen_final_sources_list() {
sudo sh -c 'cat <<EOT > '${ROOTFS_MNT}'/etc/apt/sources.list-final
#------------------------------------------------------------------------------#
#                   OFFICIAL DEBIAN REPOS
#------------------------------------------------------------------------------#

###### Debian Main Repos
deb '${final_repo}' '$distro' main contrib non-free
deb-src '${final_repo}' '$distro' main

###### Debian Update Repos
deb http://security.debian.org/ '$distro'/updates main contrib non-free

EOT'

}

gen_local_sources_list() {

sudo sh -c 'cat <<EOT > '$ROOTFS_MNT'/etc/apt/sources.list-local
#------------------------------------------------------------------------------#
#                   OFFICIAL DEBIAN REPOS
#------------------------------------------------------------------------------#


##### Local Debian mirror
deb '${local_kernel_repo}' '$distro' main
deb '${local_repo}' '$distro' main contrib non-free
#deb-src '${local_kernel_repo}' '$distro' main
#deb-src '${local_repo}' '$distro' main

###### Debian Update Repos
deb http://security.debian.org/ '$distro'/updates main contrib non-free

EOT'
echo ""
echo "Script_MSG: Created new sources.list to local apt mirror"
echo ""

}

gen_fstab(){
sudo sh -c 'cat <<EOT > '${ROOTFS_MNT}'/etc/fstab
# /etc/fstab: static file system information.
#
# <file system>    <mount point>   <type>  <options>       <dump>  <pass>
/dev/root          /               ext4    noatime,errors=remount-ro 0 1
tmpfs              /tmp            tmpfs   defaults                  0 0
none               /dev/shm        tmpfs   rw,nosuid,nodev,noexec    0 0
/sys/kernel/config /config         none    bind                      0 0
EOT'

}

gen_hosts() {

sudo sh -c 'echo '${HOST_NAME}' > '${ROOTFS_MNT}'/etc/hostname'

sudo sh -c 'cat <<EOT > '${ROOTFS_MNT}'/etc/hosts
127.0.0.1       localhost.localdomain       localhost   '${HOST_NAME}'
127.0.1.1       '${HOST_NAME}'.local        '${HOST_NAME}'
EOT'

}

gen_network_interface_setup() {

sudo sh -c 'cat <<EOT > '${ROOTFS_MNT}'/etc/systemd/network/20-dhcp.network
[Match]
Name=eth0

[Network]
DHCP=v4
MTU=9000

[DHCP]
UseDomains=true

EOT'
}

gen_add_user_sh() {
echo "------------------------------------------"
echo "generating add_user.sh chroot config script"
echo "------------------------------------------"
export DEFGROUPS="sudo,kmem,adm,dialout,${USER_NAME},video,plugdev"

sudo sh -c 'cat <<EOF > '${ROOTFS_MNT}'/home/add_user.sh
#!/bin/bash

set -x

export DEFGROUPS="sudo,kmem,adm,dialout,'${USER_NAME}',video,plugdev"
export LANG=C

'${apt_cmd}' -y update
'${apt_cmd}' -y --assume-yes --allow-unauthenticated upgrade
echo "root:'${USER_NAME}'" | chpasswd

echo "ECHO: " "Will add user '${USER_NAME}' pw: '${USER_NAME}'"
/usr/sbin/useradd -s /bin/bash -d /home/'${USER_NAME}' -m '${USER_NAME}'
echo "'${USER_NAME}':'${USER_NAME}'" | chpasswd
adduser '${USER_NAME}' sudo
chsh -s /bin/bash '${USER_NAME}'

echo "ECHO: ""User '${USER_NAME}' Added"

echo "ECHO: ""Will now add user to groups"
usermod -a -G '${DEFGROUPS}' '${USER_NAME}'
sync

cat <<EOT >> /home/'${USER_NAME}'/.bashrc

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
EOT

cat <<EOT >> /home/'${USER_NAME}'/.profile

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
EOT

cat <<EOT >> /root/.bashrc

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
EOT

cat <<EOT >> /root/.profile

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
EOT


exit
EOF'

sudo chmod +x ${ROOTFS_MNT}/home/add_user.sh

sudo chroot ${ROOTFS_MNT} /bin/su -l root /usr/sbin/locale-gen en_GB.UTF-8 en_US.UTF-8

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
/dev/mmcblk0p2     swap            swap    defaults                  0 0
EOT


echo "ECHO: Will now run '${apt_cmd}' update, upgrade"
'${apt_cmd}' -y update
'${apt_cmd}' -y --assume-yes --allow-unauthenticated upgrade

rm -f /etc/resolv.conf

# enable systemd-networkd
if [ ! -L '/lib/systemd/system/systemd-networkd.service' ]; then
	echo ""
	echo "ECHO:--> Enabling Systemd Networkd"
	echo ""
	ln -s /lib/systemd/system/systemd-networkd.service ${EnableSystemdNetworkedLink}
fi

enable systemd-resolved
if [ ! -L '/lib/systemd/system/systemd-resolved.service' ]; then
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

sudo rm -f ${ROOTFS_MNT}/etc/resolv.conf
sudo cp /etc/resolv.conf ${ROOTFS_MNT}/etc/resolv.conf

echo "Script_MSG: Now adding user: ${USER_NAME}"
gen_add_user_sh
echo "Script_MSG: gen_add_user_sh finished ... will now run in chroot"

sudo chroot ${ROOTFS_MNT} /bin/bash -c /home/add_user.sh

echo ""
echo "Scr_MSG: fix no sudo user ping:"
echo ""
sudo chmod u+s ${ROOTFS_MNT}/bin/ping ${ROOTFS_MNT}/bin/ping6

echo "Script_MSG: installing apt-transport-https"
sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/${apt_cmd} -y update
sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/${apt_cmd} -y --assume-yes --allow-unauthenticated upgrade
sudo chroot --userspec=root:root ${ROOTFS_MNT} /usr/bin/${apt_cmd} -y install apt-transport-https

if [[ "${USER_NAME}" == "machinekit" ]]; then
	add_mk_repo
fi

gen_initial_sh
echo "Script_MSG: gen_initial.sh finhed ... will now run in chroot"

sudo chroot ${ROOTFS_MNT} /bin/bash -c /home/initial.sh

sudo sync

cd ${CURRENT_DIR}
sudo cp -f ${ROOTFS_MNT}/etc/apt/sources.list-final ${ROOTFS_MNT}/etc/apt/sources.list

echo "Script_MSG: initial_rootfs_user_setup_sh finished .. ok .."

}

finalize(){
if [[ "${USER_NAME}" == "holosynth" ]]; then
	sudo cp ${HOLOSYNTH_QUAR_PROJ_FOLDER}/output_files/DE10_NANO_SOC_FB.rbf ${ROOTFS_MNT}/boot
	sudo cp ${HOLOSYNTH_QUAR_PROJ_FOLDER}/socfpga.dtb ${ROOTFS_MNT}/boot
	sudo sh -c 'echo options uio_pdrv_genirq of_id="uioreg_io,generic-uio,ui_pdrv" > '$ROOTFS_MNT'/etc/modprobe.d/uioreg.conf'
	echo ""
	echo "# --------->   Flip framebuffer upside down and no blanking fix    <--------------- ---------"
	echo ""
	sudo sh -c 'cat <<EOF >> '${ROOTFS_MNT}'/boot/uEnv.txt
mmcboot=setenv bootargs console=ttyS0,115200 root=\${mmcroot} rootfstype=ext4 rw rootwait fbcon=rotate:2;bootz \${loadaddr} - \${fdt_addr}
EOF'
fi
	sudo sh -c 'echo "KERNEL==\"uio0\",MODE=\"666\"" > '$ROOTFS_MNT'/etc/udev/rules.d/10-local.rules'

sudo sh -c 'cat <<EOF > '${ROOTFS_MNT}'/etc/X11/xorg.conf
Section "Device"
    Identifier      "Frame Buffer"
    Driver  "fbdev"
    Option "Rotate" "UD"
EndSection

Section "ServerLayout"
    Identifier "ServerLayout0"
    Option "BlankTime"   "0"
    Option "StandbyTime" "0"
    Option "SuspendTime" "0"
    Option "OffTime" "0"
EndSection

EOF'

sudo sh -c 'cat <<EOF > '${ROOTFS_MNT}'/home/holosynth/.xsessionrc
xinput set-prop 6 "Evdev Axis Inversion" 1,1
xinput set-prop 6 "Evdev Axes Swap" 0

EOF'

sudo mkdir -p ${ROOTFS_MNT}/home/holosynth/Desktop
sudo sh -c 'cat <<EOF > '${ROOTFS_MNT}'/home/holosynth/Desktop/HolosynthVEd.sh
xinput set-prop 6 "Evdev Axis Inversion" 1,1
xinput set-prop 6 "Evdev Axes Swap" 0
/home/holosynth/prg/HolosynthVEd -nograb -platform xcb

EOF'

	sudo chmod +x ${ROOTFS_MNT}/home/holosynth/Desktop/HolosynthVEd.sh
	sudo chown -R mib:mib ${ROOTFS_MNT}/home/holosynth/Desktop

	echo ""
	echo "# --------->       Removing qemu policy file          <--------------- ---------"
	echo ""

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
	echo "Script_MSG:  All Config files genetated"
	echo ""
	echo ""
	echo "# --------- ------------>   Finalized    --- --------- --------------- ---------"
echo ""
}

setup_configfiles() {

echo "Setting up config files "

gen_policy_rc_d

gen_sudoers

gen_final_sources_list
gen_local_sources_list
sudo cp ${ROOTFS_MNT}/etc/apt/sources.list-local ${ROOTFS_MNT}/etc/apt/sources.list

gen_fstab

gen_hosts

sudo mkdir -p ${ROOTFS_MNT}/etc/systemd/network

gen_network_interface_setup

sudo sh -c 'echo T0:2345:respawn:rootfs/sbin/getty -L ttyS0 115200 vt100 >> '${ROOTFS_MNT}'/etc/inittab'

#gen_locale_gen

sudo sh -c 'cat <<EOT > '${ROOTFS_MNT}'/etc/locale.conf
LANG=en_US.UTF-8 UTF-8
LC_COLLATE=C
LC_TIME=en_GB.UTF-8
EOT'

if [ "${USER_NAME}" == "machinekit" ]; then
sudo sh -c 'cat <<EOT > '${ROOTFS_MNT}'/etc/X11/xorg.conf

Section "Screen"
       Identifier   "Default Screen"
       tDevice       "Dummy"
       DefaultDepth 24
EndSection

Section "Device"
    Identifier "Dummy"
    Driver "dummy"
    Option "IgnoreEDID" "true"
    Option "NoDDC" "true"
EndSection
EOT'
fi
}

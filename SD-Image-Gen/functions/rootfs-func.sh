#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# lightdm,lxqt
# ## parameters: 1: mount dev name, 2: distro name, 3: repo url, 4: distro arch
## E: Couldn't find these debs: libdirectfb-1.7-7 libssh2-1 cgroupfs-mount gnupg2 ntp avahi-discover traceroute ifupdown2,cgmanager
run_debootstrap_bionic() {
arguments="--arch=${4} --variant=buildd --include=sudo,locales,nano,adduser,apt-utils,rsyslog,openssh-client,openssh-server,openssl,leafpad,kmod,dbus,dbus-x11,upower,udev,net-tools,lsof,less,accountsservice,iputils-ping,python,python3,ifupdown,iproute2,avahi-daemon,uuid-runtime,avahi-discover,libnss-mdns,traceroute,strace,u-boot-tools,initramfs-tools,gnupg2,dirmngr,wget,git,curl,xorg,cgroupfs-mount,ntp,autofs,libpam-systemd,systemd-sysv,fuse,policykit-1,gtk2-engines-pixbuf,fontconfig,fontconfig-config,console-setup,fbset,x11-xserver-utils,acpid ${2} ${1} ${3}"

if [[ `eval lscpu | grep Architecture` == *"aarch64"* ]]; then
  sudo debootstrap $arguments
else
  sudo qemu-debootstrap --foreign $arguments
fi  
output=${?}
}

# lightdm,lxqt
# ## parameters: 1: mount dev name, 2: distro name, 3: repo url, 4: distro arch
run_desktop_debootstrap_bionic() {
arguments="--arch=${4} --variant=buildd --include=sudo,locales,nano,adduser,apt-utils,rsyslog,openssh-client,openssh-server,openssl,kmod,dbus,dbus-x11,upower,udev,net-tools,lsof,less,accountsservice,iputils-ping,python,python3,ifupdown,iproute2,avahi-daemon,uuid-runtime,libnss-mdns,strace,u-boot-tools,initramfs-tools,dirmngr,wget,git,curl,xorg,autofs,libpam-systemd,systemd-sysv,fuse,policykit-1,gtk2-engines-pixbuf,fontconfig,fontconfig-config,console-setup,fbset,x11-xserver-utils,acpid ${2} ${1} ${3}"

if [[ `eval lscpu | grep Architecture` == *"aarch64"* ]]; then
  sudo debootstrap $arguments
else
  sudo qemu-debootstrap --foreign $arguments
fi  
output=${?}
}

# ## parameters: 1: mount dev name, 2: distro name, 3: repo url, 4: distro arch
run_desktop_debootstrap_bullseye() {
arguments="--arch=${4} --variant=buildd  --keyring /usr/share/keyrings/debian-archive-keyring.gpg --include=sudo,locales,nano,vim,adduser,apt-utils,rsyslog,libssh2-1,openssh-client,openssh-server,openssl,kwrite,kmod,dbus,dbus-x11,upower,udev,net-tools,lsof,less,accountsservice,iputils-ping,python3,ifupdown,iproute2,avahi-daemon,uuid-runtime,avahi-discover,libnss-mdns,traceroute,strace,u-boot-tools,initramfs-tools,gnupg2,dirmngr,wget,xorg,cgroupfs-mount,autofs,libpam-systemd,systemd-sysv,fuse,cgroup-tools,policykit-1,gtk2-engines-pixbuf,fontconfig,fontconfig-config,console-setup,fbset,libdirectfb-1.7-7,x11-xserver-utils,acpid ${2} ${1} ${3}"

if [[ `eval lscpu | grep Architecture` == *"aarch64"* ]]; then
  sudo debootstrap $arguments
else
  sudo qemu-debootstrap --foreign $arguments
fi
output=${?}
}

# ## parameters: 1: mount dev name, 2: distro name, 3: repo url, 4: distro arch
run_desktop_debootstrap_buster() {
arguments="--arch=${4} --variant=buildd  --keyring /usr/share/keyrings/debian-archive-keyring.gpg --include=sudo,locales,nano,vim,adduser,apt-utils,rsyslog,libssh2-1,openssh-client,openssh-server,openssl,kwrite,kmod,dbus,dbus-x11,upower,udev,net-tools,lsof,less,accountsservice,iputils-ping,python,python3,ifupdown,iproute2,avahi-daemon,uuid-runtime,avahi-discover,libnss-mdns,traceroute,strace,u-boot-tools,initramfs-tools,gnupg2,dirmngr,wget,xorg,cgroupfs-mount,ntp,autofs,libpam-systemd,systemd-sysv,fuse,cgmanager,policykit-1,gtk2-engines-pixbuf,fontconfig,fontconfig-config,console-setup,fbset,libdirectfb-1.7-7,x11-xserver-utils,acpid ${2} ${1} ${3}"

if [[ `eval lscpu | grep Architecture` == *"aarch64"* ]]; then
  sudo debootstrap $arguments
else
  sudo qemu-debootstrap --foreign $arguments
fi
output=${?}
}

# ## parameters: 1: mount dev name, 2: distro name, 3: repo url, 4: distro arch
#leafpad,
run_debootstrap() {
arguments="--arch=${4} --variant=buildd  --keyring /usr/share/keyrings/debian-archive-keyring.gpg --include=sudo,locales,nano,vim,adduser,apt-utils,rsyslog,libssh2-1,openssh-client,openssh-server,openssl,kmod,dbus,dbus-x11,upower,udev,net-tools,lsof,less,accountsservice,iputils-ping,python,python3,ifupdown,iproute2,avahi-daemon,uuid-runtime,avahi-discover,libnss-mdns,traceroute,strace,u-boot-tools,initramfs-tools,gnupg2,dirmngr,wget,xorg,cgroupfs-mount,ntp,autofs,xserver-xorg-video-dummy,libpam-systemd,systemd-sysv ${2} ${1} ${3}"

if [[ `eval lscpu | grep Architecture` == *"aarch64"* ]]; then
  sudo debootstrap $arguments
else
  sudo qemu-debootstrap --foreign $arguments
fi
output=${?}
}

## parameters: 1: mount dev name, 2: distro name, 3: repo url, 4: distro arch
#leafpad,libdirectfb-1.2-9,gksu
run_desktop_debootstrap_stretch() {
arguments="--arch=${4} --variant=buildd  --keyring /usr/share/keyrings/debian-archive-keyring.gpg --include=sudo,locales,nano,vim,adduser,apt-utils,rsyslog,libssh2-1,openssh-client,openssh-server,openssl,kmod,dbus,dbus-x11,upower,udev,net-tools,lsof,less,accountsservice,iputils-ping,python,python3,ifupdown,iproute2,avahi-daemon,uuid-runtime,avahi-discover,libnss-mdns,traceroute,strace,u-boot-tools,initramfs-tools,gnupg2,dirmngr,wget,xorg,cgroupfs-mount,ntp,autofs,libpam-systemd,systemd-sysv,fuse,cgmanager,policykit-1,gtk2-engines-pixbuf,fontconfig,fontconfig-config,console-setup,fbset,libdirectfb-1.2-9,x11-xserver-utils,acpid ${2} ${1} ${3}"

if [[ `eval lscpu | grep Architecture` == *"aarch64"* ]]; then
  sudo debootstrap $arguments
else
  sudo qemu-debootstrap --foreign $arguments
fi
output=${?}
}

## parameters: 1: mount dev name, 2: distro name, 3: repo url, 4: distro arch
#leafpad,libdirectfb-1.2-9,gksu
run_desktop_debootstrap() {
arguments="--arch=${4} --variant=buildd  --keyring /usr/share/keyrings/debian-archive-keyring.gpg --include=sudo,locales,nano,vim,adduser,apt-utils,rsyslog,libssh2-1,openssh-client,openssh-server,openssl,kmod,dbus,dbus-x11,upower,udev,net-tools,lsof,less,accountsservice,iputils-ping,python,python3,ifupdown,iproute2,avahi-daemon,uuid-runtime,avahi-discover,libnss-mdns,traceroute,strace,u-boot-tools,initramfs-tools,gnupg2,dirmngr,wget,xorg,cgroupfs-mount,ntp,autofs,libpam-systemd,systemd-sysv,fuse,cgmanager,policykit-1,gtk2-engines-pixbuf,fontconfig,fontconfig-config,console-setup,fbset,libdirectfb-1.7-7,x11-xserver-utils,acpid ${2} ${1} ${3}"

if [[ `eval lscpu | grep Architecture` == *"aarch64"* ]]; then
  sudo debootstrap $arguments
else
  sudo qemu-debootstrap --foreign $arguments
fi
output=${?}
}

# parameters: 1: mount dev name
gen_policy_rc_d() {
sudo sh -c 'cat <<EOT > '${1}'/usr/sbin/policy-rc.d
echo "************************************" >&2
echo "All rc.d operations denied by policy" >&2
echo "************************************" >&2
exit 101
EOT'
}

# parameters: 1: mount dev name, 2: user name
gen_sudoers() {
sudo sh -c 'cat <<EOT > '${1}'/etc/sudoers
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
'${2}'    ALL=(ALL:ALL) ALL

# Allow members of group sudo to execute any command
%sudo   ALL=(ALL:ALL) ALL

# See sudoers(5) for more information on "#include" directives:

#includedir /etc/sudoers.d

'${2}' ALL=(ALL:ALL) NOPASSWD: ALL
%'${2}' ALL=(ALL:ALL) NOPASSWD: ALL
EOT'

}

# parameters: 1: mount dev name, 2: distro
gen_final_sources_list() {
if [ "${2}" == "bionic" ]; then
sudo sh -c 'cat <<EOT > '${1}'/etc/apt/sources.list-final
#------------------------------------------------------------------------------#
#                   OFFICIAL UBUNTU REPOS
#------------------------------------------------------------------------------#

deb [arch=arm64] '${final_ub_repo}' '${2}' main restricted
deb-src [arch=arm64]  '${final_ub_repo}' '${2}' main restricted

deb [arch=arm64]  '${final_ub_repo}' '${2}'-updates main restricted
deb-src [arch=arm64] '${final_ub_repo}' '${2}'-updates main restricted

deb [arch=arm64] '${final_ub_repo}' '${2}' universe
deb-src [arch=arm64] '${final_ub_repo}' '${2}' universe
deb [arch=arm64] '${final_ub_repo}' '${2}'-updates universe
deb-src [arch=arm64] '${final_ub_repo}' '${2}'-updates universe

deb [arch=arm64] '${final_ub_repo}' '${2}' multiverse
deb-src [arch=arm64] '${final_ub_repo}' '${2}' multiverse
deb [arch=arm64] '${final_ub_repo}' '${2}'-updates multiverse
deb-src [arch=arm64] '${final_ub_repo}' '${2}'-updates multiverse

EOT'
else
sudo sh -c 'cat <<EOT > '${1}'/etc/apt/sources.list-final
#------------------------------------------------------------------------------#
#                   OFFICIAL DEBIAN REPOS
#------------------------------------------------------------------------------#

###### Debian Main Repos
deb '${final_deb_repo}' '${2}' main contrib non-free
deb-src '${final_deb_repo}' '${2}' main contrib non-free

###### Debian Update Repos
deb '${final_deb_repo}' '${2}'-updates main contrib non-free
deb-src '${final_deb_repo}' '${2}'-updates main contrib non-free
deb http://security.debian.org/ '${2}'/updates main contrib non-free
#deb http://ftp.debian.org/debian '${2}'-backports main contrib non-free

EOT'
fi
}

# parameters: 1: mount dev name, 2: distro
gen_local_sources_list() {

if [ "${2}" == "bionic" ]; then
sudo sh -c 'cat <<EOT > '${1}'/etc/apt/sources.list-local
#------------------------------------------------------------------------------#
#                   OFFICIAL UBUNTU REPOS
#------------------------------------------------------------------------------#

##### Local mirror
deb '${local_ub_kernel_repo}' '${2}' main

deb [arch=arm64] '${local_ub_repo}' '${2}' main restricted
deb-src [arch=arm64]  '${local_ub_repo}' '${2}' main restricted

deb [arch=arm64]  '${local_ub_repo}' '${2}'-updates main restricted
deb-src [arch=arm64] '${local_ub_repo}' '${2}'-updates main restricted

deb [arch=arm64] '${local_ub_repo}' '${2}' universe
deb-src [arch=arm64] '${local_ub_repo}' '${2}' universe
deb [arch=arm64] '${local_ub_repo}' '${2}'-updates universe
deb-src [arch=arm64] '${local_ub_repo}' '${2}'-updates universe

deb [arch=arm64] '${local_ub_repo}' '${2}' multiverse
deb-src [arch=arm64] '${local_ub_repo}' '${2}' multiverse
deb [arch=arm64] '${local_ub_repo}' '${2}'-updates multiverse
deb-src [arch=arm64] '${local_ub_repo}' '${2}'-updates multiverse

EOT'
else
sudo sh -c 'cat <<EOT > '${1}'/etc/apt/sources.list-local
#------------------------------------------------------------------------------#
#                   OFFICIAL DEBIAN REPOS
#------------------------------------------------------------------------------#


##### Local Debian mirror
deb '${local_kernel_repo}' '${2}' main
deb '${local_deb_repo}' '${2}' main contrib non-free
#deb-src '${local_kernel_repo}' '${2}' main
#deb-src '${local_deb_repo}' '${2}' main

###### Debian Update Repos
deb http://security.debian.org/ '${2}'/updates main contrib non-free
deb http://ftp.debian.org/debian '${2}'-backports main

EOT'
fi

echo ""
echo "Script_MSG: Created new sources.list to local apt mirror"
echo ""

}

# parameters: 1: img mount, 2: hostname
gen_hosts() {

sudo sh -c 'echo '${2}' > '${1}'/etc/hostname'

sudo sh -c 'cat <<EOT > '${1}'/etc/hosts
127.0.0.1   localhost.localdomain   localhost       '${2}'
127.0.1.1   '${2}'.local    '${2}'
EOT'

}

#1: net adapter name
gen_network_interface_setup() {

sudo sh -c 'cat <<EOT > '${ROOTFS_MNT}'/etc/systemd/network/20-dhcp.network
[Match]
Name='${1}'

[Network]
LinkLocalAddressing=ipv4
IPv6AcceptRA=no
DHCP=ipv4
MTU=1500

[DHCP]
UseDomains=true

EOT'
}

conf_timezone_locale(){
sudo sh -c 'cat <<EOF > '${ROOTFS_MNT}'/home/conf_timezone_locale.sh
#!/bin/bash

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8 da_DK.UTF-8 en_DK.UTF-8

echo "Europe/Copenhagen" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    sed -i -e '"'"'s/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/'"'"' /etc/locale.gen && \
    sed -i -e '"'"'s/# da_DK.UTF-8 UTF-8/da_DK.UTF-8 UTF-8/'"'"' /etc/locale.gen && \
    sed -i -e '"'"'s/# en_DK.UTF-8 UTF-8/en_DK.UTF-8 UTF-8/'"'"' /etc/locale.gen && \
    echo '"'"'LANG="en_US.UTF-8"'"'"'>/etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

exit
EOF'
sudo chmod +x ${ROOTFS_MNT}/home/conf_timezone_locale.sh
sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${ROOTFS_MNT}' '${shell_cmd}' -c /home/conf_timezone_locale.sh'

}

# parameters: 1: mount dev name, 2: user name
gen_add_user_sh() {
echo "------------------------------------------"
echo "generating add_user.sh chroot config script"
echo "------------------------------------------"
export DEFGROUPS="sudo,kmem,adm,dialout,${2},video,plugdev,netdev,audio,tty"

sudo sh -c 'cat <<EOF > '${1}'/home/add_user.sh
#!/bin/bash

#set -x

export DEFGROUPS="sudo,kmem,adm,dialout,'${2}',video,plugdev,netdev,audio,tty"
export LANG=C

'${apt_cmd}' -y update
'${apt_cmd}' -y --assume-yes upgrade
echo "root:'${2}'" | chpasswd

echo "ECHO: " "Will add user '${2}' pw: '${2}'"
/usr/sbin/useradd -s '${shell_cmd}' -d /home/'${2}' -m '${2}'
echo "'${2}':'${2}'" | chpasswd
adduser '${2}' sudo
chsh -s '${shell_cmd}' '${2}'

echo "ECHO: ""User '${2}' Added"

echo "ECHO: ""Will now add user to groups"
usermod -a -G '${DEFGROUPS}' '${2}'
sync

cat <<EOT >> /home/'${2}'/.bashrc

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
EOT

cat <<EOT >> /home/'${2}'/.profile

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

sudo chmod +x ${1}/home/add_user.sh
}

# parameters: 1: mount dev name, 2: distro arch
gen_initial_sh() {
echo "------------------------------------------"
echo "generating initial.sh chroot config script"
echo "------------------------------------------"
if [[ "${2}" == "arm64" ]]; then
sudo sh -c 'cat <<EOF > '${1}'/home/initial.sh
#!/bin/bash

#set -x

ln -s /proc/mounts /etc/mtab



cat << EOT >/etc/fstab
# /etc/fstab: static file system information.
#
# <file system>		<mount point>		<type>	<options>				<dump>	<pass>
/dev/root			/					ext4	noatime,errors=remount-ro	0 1
tmpfs				/tmp				tmpfs	defaults					0 0
none				/dev/shm			tmpfs	rw,nosuid,nodev,noexec		0 0
/sys/kernel/config	/config				none	bind						0 0
#/dev/mmcblk0p2		swap				swap	defaults					0 0
#debugfs				/sys/kernel/debug	debugfs	defaults					0 0
EOT


echo "ECHO: Will now run '${apt_cmd}' update, upgrade"
'${apt_cmd}' -y update
'${apt_cmd}' -y --assume-yes upgrade

rm -f /etc/resolv.conf

# enable systemd-networkd
# enable systemd-networkd
 if [ ! -e '/etc/systemd/system/multi-user.target.wants//systemd-networkd.service' ]; then
     echo ""
     echo "ECHO:--> Enabling Systemd Networkd"
     echo ""
     ln -s /lib/systemd/system/systemd-networkd.service '${EnableSystemdNetworkedLink}'
 fi

# enable systemd-resolved
 if [ ! -e '/etc/systemd/system/multi-user.target.wants//systemd-resolved.service' ]; then
     echo ""
     echo "ECHO:--> Enabling Systemd Resolved"
     echo ""
     ln -s /lib/systemd/system/systemd-resolved.service '${EnableSystemdResolvedLink}'
     rm -f /etc/resolv.conf
     ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
 fi

exit
EOF'
else
sudo sh -c 'cat <<EOF > '${1}'/home/initial.sh
#!/bin/bash

#set -x

ln -s /proc/mounts /etc/mtab



cat << EOT >/etc/fstab
# /etc/fstab: static file system information.
#
# <file system>		<mount point>		<type>	<options>				<dump>	<pass>
/dev/root			/					ext4	noatime,errors=remount-ro	0 1
tmpfs				/tmp				tmpfs	defaults					0 0
none				/dev/shm			tmpfs	rw,nosuid,nodev,noexec		0 0
/sys/kernel/config	/config				none	bind						0 0
/dev/mmcblk0p2		swap				swap	defaults					0 0
debugfs				/sys/kernel/debug	debugfs	defaults					0 0
EOT


echo "ECHO: Will now run '${apt_cmd}' update, upgrade"
'${apt_cmd}' -y update
'${apt_cmd}' -y --assume-yes upgrade
'${apt_cmd}' -y install connman

rm -f /etc/resolv.conf

exit
EOF'
fi
sudo chmod +x ${1}/home/initial.sh
}

# parameters: 1: mount dev name, 2: user name, 3: distro
add_mk_repo(){
echo "ECHO: adding mk sources.list"
sudo chroot --userspec=root:root ${1} /usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv 43DDF224
sudo sh -c 'echo "deb http://deb.machinekit.io/debian '${3}' main" > '${1}'/etc/apt/sources.list.d/'${2}'.list'
sudo chroot --userspec=root:root ${1} /usr/bin/${apt_cmd} -y update
}

# parameters: 1: mount dev name, 2: user name, 3: distro, 4: distro arch
setup_configfiles() {

echo "Setting up config files "

gen_policy_rc_d ${1}

gen_sudoers ${1} ${2}

gen_final_sources_list ${1} ${3}
gen_local_sources_list ${1} ${3}
sudo cp ${1}/etc/apt/sources.list-final ${1}/etc/apt/sources.list

if [ "${2}" == "machinekit" ]; then
    if [ "${4}" == "arm64" ]; then
        HOST_NAME="mksocfpga-xil"
    else
        HOST_NAME="mksocfpga"
    fi
elif [ "${2}" == "holosynth" ]; then
    if [ "${4}" == "arm64" ]; then
        HOST_NAME="holosynthv-xil"
    else
        HOST_NAME="holosynthv"
    fi
fi

gen_hosts ${1} ${HOST_NAME}

sudo mkdir -p ${1}/etc/systemd/network

 if [[ "${4}" == "arm64" ]]; then
     gen_network_interface_setup "enx*"
 else
    gen_network_interface_setup "eth0"
 fi

sudo sh -c 'echo T0:2345:respawn:rootfs/sbin/getty -L ttyS0 115200 vt100 >> '${1}'/etc/inittab'

conf_timezone_locale

sudo sh -c 'cat <<EOT > '${1}'/etc/locale.conf
LANG=en_US.UTF-8
LC_COLLATE=en_US.UTF-8
LC_TIME=en_GB.UTF-8
LC_ALL=en_US.UTF-8
EOT'
}

# parameters: 1: mount dev name, 2: user name, 3: distro, 4: distro arch
initial_rootfs_user_setup_sh() {
echo "------------------------------------------------------------"
echo "----  running initial_rootfs_user_setup_sh      ------------"
echo "------------------------------------------------------------"
# set -e
# set -x

sudo rm -f ${1}/etc/resolv.conf
sudo cp /etc/resolv.conf ${1}/etc/resolv.conf

echo "Script_MSG: Now adding user: ${2}"
sudo chroot --userspec=root:root ${1} /bin/mkdir -p /tmp
sudo chroot --userspec=root:root ${1} /bin/chmod 1777 /tmp
sudo chroot --userspec=root:root ${1} /bin/mkdir -p /var/tmp
sudo chroot --userspec=root:root ${1} /bin/chmod 1777 /var/tmp
sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y update'
sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y --assume-yes upgrade'
sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install debconf gnupg2 sudo wget apt-utils kmod'

sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install tzdata'
sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /bin/ln -fs /usr/share/zoneinfo/Europe/Copenhagen /etc/localtime'
sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/sbin/dpkg-reconfigure --frontend noninteractive tzdata'
sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install featherpad gnupg2 avahi-discover traceroute cgroupfs-mount ntp'

sudo chroot --userspec=root:root ${1} /usr/bin/wget http://${local_ws}/debian/socfpgakernel.gpg.key

sudo chroot --userspec=root:root ${1} /usr/bin/apt-key add socfpgakernel.gpg.key
sudo chroot --userspec=root:root ${1} /bin/rm socfpgakernel.gpg.key

sudo cp ${1}/etc/apt/sources.list-local ${1}/etc/apt/sources.list
gen_add_user_sh ${1} ${2}
echo "Script_MSG: gen_add_user_sh finished ... will now run in chroot"

sudo sh -c 'LANG=C.UTF-8 chroot '${1}' '${shell_cmd}' -c /home/add_user.sh'

if [ "${3}" == "buster" ]; then
    sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install iputils-ping xorg libpam-systemd systemd-sysv'
fi
echo ""
echo "Scr_MSG: fix no sudo user ping:"
echo ""
sudo chmod u+s ${1}/bin/ping ${1}/bin/ping6
echo "Script_MSG: installing apt-transport-https"
sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y update'
sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y --assume-yes upgrade'
sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install apt-transport-https'
if [[ "${2}" == "machinekit" ]]; then
    if [ "${4}" != "arm64" ]; then
        add_mk_repo ${1} ${2} ${3}
    fi
fi

if [ "${DESKTOP}" == "yes" ]; then
    echo "Scr_MSG: Installing lxqt"
    if [ "${3}" == "bionic" ] || [ "${3}" == "bullseye" ]; then
        if [ "${3}" == "bionic" ]; then
            sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install software-properties-common'
            sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install lxqt-core openbox lxqt-sudo'
            sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install lxqt'
            sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install tasksel'
            sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install task-lxqt-desktop'
            sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install sddm'
        fi
        if [ "${3}" == "bullseye" ]; then
            sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install software-properties-common'
            sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install lightdm'
#            sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install tasksel task-desktop'
            sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install tasksel'
            sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install lxqt'
            sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install task-lxqt-desktop'
            sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install breeze breeze-cursor-theme breeze-icon-theme'
        fi
    else
        sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install software-properties-common'
        sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install lxqt-core lxqt-sudo'
        sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install lxqt pcmanfm-qt5'
        sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install lxmenu-data  lxqt-globalkeys lxqt-panel lxqt'
        sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install breeze breeze-cursor-theme breeze-icon-theme'
    fi
    sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install mesa-utils mesa-utils-extra xfonts-cyrillic'
    sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y update'
    sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y autoremove'
    sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y update'
    sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y --assume-yes upgrade'

    if [[ "${4}" == "arm64" ]]; then
        if [ "${3}" == "bionic" ]; then
            sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install linux-firmware'
        else
            if [ "${3}" == "stretch" ]; then
                sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y -t '${3}'-backports install firmware-ti-connectivity'
            else
                sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install firmware-ti-connectivity'
            fi
        fi
        sudo cp ${WORK_DIR}/../bt/TIInit_11.8.32.bts ${1}/lib/firmware/ti-connectivity/
    fi
    if [[ "${2}" == "holosynth" ]]; then
        echo "Scr_MSG: Installing Cadence deps"
#        sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/wget https://launchpad.net/~kxstudio-debian/+archive/kxstudio/+files/kxstudio-repos_9.5.1~kxstudio3_all.deb'
#        sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/dpkg -i kxstudio-repos_9.5.1~kxstudio3_all.deb'
        sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install libglibmm-2.4-1v5'
#        sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/wget https://launchpad.net/~kxstudio-debian/+archive/kxstudio/+files/kxstudio-repos-gcc5_9.5.1~kxstudio3_all.deb'
#        sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/dpkg -i kxstudio-repos-gcc5_9.5.1~kxstudio3_all.deb'
#        sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y update'
#         sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install a2jmidid jackmeter carla-data lmms audacity'
#         sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install kxstudio-menu'
#
#         sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install libjack-dev libqt4-dev qt4-dev-tools'
#         sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install python-qt4-dev python3-pyqt4 pyqt4-dev-tools'

#        sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install git'
#        sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/git clone https://github.com/falkTX/Cadence.git'
    fi
fi

gen_initial_sh ${1} ${4}
echo "Script_MSG: gen_initial.sh finished ... will now run in chroot"

sudo chroot ${1} ${shell_cmd} -c /home/initial.sh

sudo sync

cd ${CURRENT_DIR}
sudo cp -f ${1}/etc/apt/sources.list-final ${1}/etc/apt/sources.list

echo "Script_MSG: initial_rootfs_user_setup_sh finished .. ok .."

}

# parameters: 1: mount dev name, 2: user name, 3: distro, 4: distro arch
finalize(){
if [[ "${2}" == "holosynth" ]]; then
#    sudo cp ${HOLOSYNTH_QUAR_PROJ_FOLDER}/output_files/DE1_SOC_Linux_FB.rbf ${1}/boot
#	sudo cp ${HOLOSYNTH_QUAR_PROJ_FOLDER}/socfpga.dtb ${R1}/boot
#    echo ""
#    echo "# --------->   Flip framebuffer upside down and no blanking fix    <--------------- ---------"
#    echo ""
#     sudo sh -c 'cat <<EOF >> '${1}'/boot/uEnv.txt
# mmcboot=setenv bootargs console=ttyS0,115200 root=\${mmcroot} rootfstype=ext4 rw rootwait fbcon=rotate:2;bootz \${loadaddr} - \${fdt_addr}
# EOF'

#    if [[ "${3}" == "stretch" ]]; then
#         sudo sh -c 'cat <<EOF > '${1}'/home/holosynth/.xsessionrc
# xinput set-prop 'eGalax Inc. eGalaxTouch EXC7910-1026-13.00.00' 'Coordinate Transformation Matrix' -1 0 1 0 -1 1 0 0 1
# EOF'

    mkdir -p ${1}/home/holosynth/Desktop
    mkdir -p ${1}/home/holosynth/.local/share/applications
    sudo sh -c 'cat <<EOF > '${1}'/home/holosynth/.local/share/applications/holosynthed.desktop
[Desktop Entry]
Name=HolosynthVEd
GenericName=HolosynthVEd
Comment=Synth Editor for HolosynthV
Exec=/home/holosynth/prg/HolosynthVEd -nograb -platform xcb
Icon=catia
Terminal=false
Type=Application
Categories=AudioVideo;AudioEditing;Qt
EOF'

    sudo sh -c 'cat <<EOF > '${1}'/home/holosynth/Desktop/HolosynthVEd.sh
/home/holosynth/prg/HolosynthVEd -nograb -platform xcb
EOF'

#    fi
    sudo chmod +x ${1}/home/holosynth/Desktop/HolosynthVEd.sh
    sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /bin/chown  -R '${2}':'${2}' /home/'${2}''
fi

if [ "${DESKTOP}" == "yes" ]; then
    if [[ "${4}" == "arm64" ]]; then
sudo sh -c 'cat <<EOF > '${1}'/etc/X11/xorg.conf
Section "Files"
    ModulePath "/usr/lib/xorg/modules"
EndSection

Section "InputDevice"
	Identifier	"System Mouse"
	Driver		"mouse"
	Option		"Device" "/dev/input/mouse0"
EndSection

Section "InputDevice"
	Identifier	"System Keyboard"
	Driver		"kbd"
	Option		"Device" "/dev/input/event0"
EndSection

Section "Device"
        Identifier      "ZynqMP"
        Driver          "armsoc"
        Option          "DRI2"                  "true"
        Option          "DRI2_PAGE_FLIP"        "false"
        Option          "DRI2_WAIT_VSYNC"       "true"
        Option          "SWcursorLCD"           "false"
        Option          "DEBUG"                 "false"
EndSection

Section "Screen"
        Identifier      "DefaultScreen"
        Device          "ZynqMP"
        DefaultDepth    16
EndSection

EOF'
    if [ ! "$(ls -A "./mali")" ]; then
        wget https://www.xilinx.com/publications/products/tools/mali-400-userspace.tar
        tar -xf mali-400-userspace.tar
    fi
    cd mali
    if [ "${3}" == "bullseye" ]; then
        if [ ! "$(ls -A "./mali-userspace-binaries")" ]; then
            git clone https://github.com/Xilinx/mali-userspace-binaries.git
        fi
        cd mali-userspace-binaries
        git checkout rel-v2020.1
        cd ${CURRENT_DIR}
#        sudo mkdir -p ${1}/usr/lib/aarch64-linux-gnu/mali-egl
        sudo cp -P mali/mali-userspace-binaries/r9p0-01rel0/arm-linux-gnueabihf/common/* ${1}/usr/lib/aarch64-linux-gnu
        sudo cp mali/mali-userspace-binaries/r9p0-01rel0/arm-linux-gnueabihf/x11/libMali.so.9.0  ${1}/usr/lib/aarch64-linux-gnu/libMali.so.9.0
        echo "MSG: Copy armsoc driver"
        sudo cp '/home/mib/Projects/2020v1/my-work/armsoc_drv.so'  ${1}/usr/lib/xorg/modules/drivers
    else
        if [ "${3}" == "buster" ]; then
            cd rel-v2019.1
            tar -xf r8p0-01rel0.tar
            cd ${CURRENT_DIR}
            sudo mkdir -p ${1}/usr/lib/aarch64-linux-gnu/mali-egl
            sudo cp -P mali/rel-v2019.1/r8p0-01rel0/aarch64-linux-gnu/common/* ${1}/usr/lib/aarch64-linux-gnu/mali-egl
            sudo cp mali/rel-v2019.1/r8p0-01rel0/aarch64-linux-gnu/x11/libMali.so.8.0 ${1}/usr/lib/aarch64-linux-gnu/mali-egl
            echo "MSG: Copy armsoc driver"
            sudo cp '/home/mib/Projects/2019v1/my-work/armsoc_drv.so'  ${1}/usr/lib/xorg/modules/drivers
        else
            if [[ "${3}" == "stretch" ]]; then
                cd rel-v2018.3
                tar -xf r8p0-01rel0.tar
                cd ${CURRENT_DIR}
                sudo mkdir -p ${1}/usr/lib/aarch64-linux-gnu/mali-egl
                sudo cp -P mali/rel-v2018.3/r8p0-01rel0/aarch64-linux-gnu/common/* ${1}/usr/lib/aarch64-linux-gnu/mali-egl
                sudo cp mali/rel-v2018.3/r8p0-01rel0/aarch64-linux-gnu/x11/libMali.so.8.0 ${1}/usr/lib/aarch64-linux-gnu/mali-egl
                echo "MSG: Copy armsoc driver"
                sudo cp '/home/mib/Projects/2019v1/my-work/armsoc_drv.so'  ${1}/usr/lib/xorg/modules/drivers
            fi
        fi
    fi
    else

sudo sh -c 'cat <<EOF > '${1}'/etc/X11/xorg.conf
Section "Device"
    Identifier      "Frame Buffer"
    Driver  "fbdev"
    Option "Rotate" "off"
EndSection

Section "ServerLayout"
    Identifier "ServerLayout0"
    Option "BlankTime"   "0"
    Option "StandbyTime" "0"
    Option "SuspendTime" "0"
    Option "OffTime" "0"
EndSection

EOF'

sudo sh -c 'cat <<EOF > '${1}'/etc/X11/Xwrapper.config
allowed_users=anybody
needs_root_rights=yes

EOF'
    fi
fi

sudo sh -c 'echo options uio_pdrv_genirq of_id="generic-uio,ui_pdrv" > '${1}'/etc/modprobe.d/uioreg.conf'
sudo sh -c 'echo "KERNEL==\"uio*\",MODE=\"666\"" > '${1}'/etc/udev/rules.d/10-local.rules'

echo ""
echo "# --------->       Restoring resolv.conf link         <--------------- ---------"
echo ""
sudo chroot --userspec=root:root ${1} /bin/rm -f /etc/resolv.conf
sudo chroot --userspec=root:root ${1} /bin/ln -s /run/systemd/resolve/resolv.conf  /etc/resolv.conf

echo ""
echo "Script_MSG:  All Config files genetated"
echo ""
echo ""
echo "# --------- ------------>   Finalized    --- --------- --------------- ---------"
echo ""
}

#!/bin/bash

# lightdm,lxqt
# ## parameters: 1: mount dev name, 2: distro name, 3: repo url, 4: distro arch
## E: Couldn't find these debs: libdirectfb-1.7-7 libssh2-1 cgroupfs-mount gnupg2 ntp avahi-discover traceroute ifupdown2,cgmanager
run_qemu_debootstrap_bionic() {
sudo qemu-debootstrap --foreign --arch=${4} --variant=buildd --include=sudo,locales,nano,adduser,apt-utils,rsyslog,openssh-client,openssh-server,openssl,leafpad,kmod,dbus,dbus-x11,upower,udev,net-tools,lsof,less,accountsservice,iputils-ping,python,python3,ifupdown,iproute2,avahi-daemon,uuid-runtime,avahi-discover,libnss-mdns,traceroute,strace,u-boot-tools,initramfs-tools,gnupg2,dirmngr,wget,git,curl,xorg,cgroupfs-mount,ntp,autofs,libpam-systemd,systemd-sysv,fuse,policykit-1,gtk2-engines-pixbuf,fontconfig,fontconfig-config,console-setup,fbset,x11-xserver-utils,acpid ${2} ${1} ${3}
output=${?}
}

# lightdm,lxqt
# ## parameters: 1: mount dev name, 2: distro name, 3: repo url, 4: distro arch
run_desktop_qemu_debootstrap_bionic() {
sudo qemu-debootstrap --foreign --arch=${4} --variant=buildd --include=sudo,locales,nano,adduser,apt-utils,rsyslog,openssh-client,openssh-server,openssl,kmod,dbus,dbus-x11,upower,udev,net-tools,lsof,less,accountsservice,iputils-ping,python,python3,ifupdown,iproute2,avahi-daemon,uuid-runtime,libnss-mdns,strace,u-boot-tools,initramfs-tools,dirmngr,wget,git,curl,xorg,autofs,libpam-systemd,systemd-sysv,fuse,policykit-1,gtk2-engines-pixbuf,fontconfig,fontconfig-config,console-setup,fbset,x11-xserver-utils,acpid ${2} ${1} ${3}
output=${?}
}

# ## parameters: 1: mount dev name, 2: distro name, 3: repo url, 4: distro arch
run_desktop_qemu_debootstrap_bullseye() {
sudo qemu-debootstrap --foreign --arch=${4} --variant=buildd  --keyring /usr/share/keyrings/debian-archive-keyring.gpg --include=sudo,locales,nano,vim,adduser,apt-utils,rsyslog,libssh2-1,openssh-client,openssh-server,openssl,kwrite,kmod,dbus,dbus-x11,upower,udev,net-tools,lsof,less,accountsservice,iputils-ping,python,python3,ifupdown,iproute2,avahi-daemon,uuid-runtime,avahi-discover,libnss-mdns,traceroute,strace,u-boot-tools,initramfs-tools,gnupg2,dirmngr,wget,xorg,cgroupfs-mount,autofs,libpam-systemd,systemd-sysv,fuse,cgmanager,policykit-1,gtk2-engines-pixbuf,fontconfig,fontconfig-config,console-setup,fbset,libdirectfb-1.7-7,x11-xserver-utils,acpid ${2} ${1} ${3}
output=${?}
}

# ## parameters: 1: mount dev name, 2: distro name, 3: repo url, 4: distro arch
run_desktop_qemu_debootstrap_buster() {
sudo qemu-debootstrap --arch=${4} --variant=buildd  --keyring /usr/share/keyrings/debian-archive-keyring.gpg --include=sudo,locales,nano,vim,adduser,apt-utils,rsyslog,libssh2-1,openssh-client,openssh-server,openssl,kwrite,kmod,dbus,dbus-x11,upower,udev,net-tools,lsof,less,accountsservice,iputils-ping,python,python3,ifupdown,iproute2,avahi-daemon,uuid-runtime,avahi-discover,libnss-mdns,traceroute,strace,u-boot-tools,initramfs-tools,gnupg2,dirmngr,wget,xorg,cgroupfs-mount,ntp,autofs,libpam-systemd,systemd-sysv,fuse,cgmanager,policykit-1,gtk2-engines-pixbuf,fontconfig,fontconfig-config,console-setup,fbset,libdirectfb-1.7-7,x11-xserver-utils,acpid ${2} ${1} ${3}
output=${?}
}

# # ## parameters: 1: mount dev name, 2: distro name, 3: repo url, 4: distro arch
# run_qemu_debootstrap_buster_lxqt() {
# sudo qemu-debootstrap --foreign --arch=${4} --variant=buildd  --keyring /usr/share/keyrings/debian-archive-keyring.gpg --include=sudo,locales,nano,apt-utils,rsyslog,libssh2-1,openssh-client,openssh-server,openssl,leafpad,kmod,dbus,dbus-x11,upower,udev,net-tools,lsof,less,accountsservice,iputils-ping,python,python3,ifupdown,iproute2,avahi-daemon,uuid-runtime,avahi-discover,libnss-mdns,traceroute,strace,u-boot-tools,initramfs-tools,gnupg2,dirmngr,wget,xorg,cgroupfs-mount,ntp,autofsfuse,cgmanager,policykit-1,gtk2-engines-pixbuf,fontconfig,fontconfig-config,console-setup,fbset,libdirectfb-1.7-7,x11-xserver-utils,acpid,lxqt-core,lxqt,task-lxqt-desktop ${2} ${1} ${3}
# output=${?}
# }
#,dhcpcd5,open-iscsi,

# ## parameters: 1: mount dev name, 2: distro name, 3: repo url, 4: distro arch
#leafpad,
run_qemu_debootstrap() {
sudo qemu-debootstrap --foreign --arch=${4} --variant=buildd  --keyring /usr/share/keyrings/debian-archive-keyring.gpg --include=sudo,locales,nano,vim,adduser,apt-utils,rsyslog,libssh2-1,openssh-client,openssh-server,openssl,kmod,dbus,dbus-x11,upower,udev,net-tools,lsof,less,accountsservice,iputils-ping,python,python3,ifupdown,iproute2,avahi-daemon,uuid-runtime,avahi-discover,libnss-mdns,traceroute,strace,u-boot-tools,initramfs-tools,gnupg2,dirmngr,wget,xorg,cgroupfs-mount,ntp,autofs,xserver-xorg-video-dummy,libpam-systemd,systemd-sysv ${2} ${1} ${3}
output=${?}
}

## parameters: 1: mount dev name, 2: distro name, 3: repo url, 4: distro arch
#leafpad,libdirectfb-1.2-9,gksu
run_desktop_qemu_debootstrap_stretch() {
sudo qemu-debootstrap --foreign --arch=${4} --variant=buildd  --keyring /usr/share/keyrings/debian-archive-keyring.gpg --include=sudo,locales,nano,vim,adduser,apt-utils,rsyslog,libssh2-1,openssh-client,openssh-server,openssl,kmod,dbus,dbus-x11,upower,udev,net-tools,lsof,less,accountsservice,iputils-ping,python,python3,ifupdown,iproute2,avahi-daemon,uuid-runtime,avahi-discover,libnss-mdns,traceroute,strace,u-boot-tools,initramfs-tools,gnupg2,dirmngr,wget,xorg,cgroupfs-mount,ntp,autofs,libpam-systemd,systemd-sysv,fuse,cgmanager,policykit-1,gtk2-engines-pixbuf,fontconfig,fontconfig-config,console-setup,fbset,libdirectfb-1.2-9,x11-xserver-utils,acpid ${2} ${1} ${3}
output=${?}
}

## parameters: 1: mount dev name, 2: distro name, 3: repo url, 4: distro arch
#leafpad,libdirectfb-1.2-9,gksu
run_desktop_qemu_debootstrap() {
sudo qemu-debootstrap --foreign --arch=${4} --variant=buildd  --keyring /usr/share/keyrings/debian-archive-keyring.gpg --include=sudo,locales,nano,vim,adduser,apt-utils,rsyslog,libssh2-1,openssh-client,openssh-server,openssl,kmod,dbus,dbus-x11,upower,udev,net-tools,lsof,less,accountsservice,iputils-ping,python,python3,ifupdown,iproute2,avahi-daemon,uuid-runtime,avahi-discover,libnss-mdns,traceroute,strace,u-boot-tools,initramfs-tools,gnupg2,dirmngr,wget,xorg,cgroupfs-mount,ntp,autofs,libpam-systemd,systemd-sysv,fuse,cgmanager,policykit-1,gtk2-engines-pixbuf,fontconfig,fontconfig-config,console-setup,fbset,libdirectfb-1.7-7,x11-xserver-utils,acpid ${2} ${1} ${3}
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
deb '${final_deb_repo}' '${2}'main contrib non-free
deb-src '${final_deb_repo}' '${2}'main contrib non-free

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

gen_locale_gen() {
sudo sh -c 'cat <<EOT > '$ROOTFS_DIR'/etc/locale.gen
# This file lists locales that you wish to have built. You can find a list
# of valid supported locales at /usr/share/i18n/SUPPORTED, and you can add
# user defined locales to /usr/local/share/i18n/SUPPORTED. If you change
# this file, you need to rerun locale-gen.


# aa_DJ ISO-8859-1
# aa_DJ.UTF-8 UTF-8
# aa_ER UTF-8
# aa_ER@saaho UTF-8
# aa_ET UTF-8
# af_ZA ISO-8859-1
# af_ZA.UTF-8 UTF-8
# ak_GH UTF-8
# am_ET UTF-8
# an_ES ISO-8859-15
# an_ES.UTF-8 UTF-8
# anp_IN UTF-8
# ar_AE ISO-8859-6
# ar_AE.UTF-8 UTF-8
# ar_BH ISO-8859-6
# ar_BH.UTF-8 UTF-8
# ar_DZ ISO-8859-6
# ar_DZ.UTF-8 UTF-8
# ar_EG ISO-8859-6
# ar_EG.UTF-8 UTF-8
# ar_IN UTF-8
# ar_IQ ISO-8859-6
# ar_IQ.UTF-8 UTF-8
# ar_JO ISO-8859-6
# ar_JO.UTF-8 UTF-8
# ar_KW ISO-8859-6
# ar_KW.UTF-8 UTF-8
# ar_LB ISO-8859-6
# ar_LB.UTF-8 UTF-8
# ar_LY ISO-8859-6
# ar_LY.UTF-8 UTF-8
# ar_MA ISO-8859-6
# ar_MA.UTF-8 UTF-8
# ar_OM ISO-8859-6
# ar_OM.UTF-8 UTF-8
# ar_QA ISO-8859-6
# ar_QA.UTF-8 UTF-8
# ar_SA ISO-8859-6
# ar_SA.UTF-8 UTF-8
# ar_SD ISO-8859-6
# ar_SD.UTF-8 UTF-8
# ar_SS UTF-8
# ar_SY ISO-8859-6
# ar_SY.UTF-8 UTF-8
# ar_TN ISO-8859-6
# ar_TN.UTF-8 UTF-8
# ar_YE ISO-8859-6
# ar_YE.UTF-8 UTF-8
# as_IN UTF-8
# ast_ES ISO-8859-15
# ast_ES.UTF-8 UTF-8
# ayc_PE UTF-8
# az_AZ UTF-8
# be_BY CP1251
# be_BY.UTF-8 UTF-8
# be_BY@latin UTF-8
# bem_ZM UTF-8
# ber_DZ UTF-8
# ber_MA UTF-8
# bg_BG CP1251
# bg_BG.UTF-8 UTF-8
# bhb_IN.UTF-8 UTF-8
# bho_IN UTF-8
# bn_BD UTF-8
# bn_IN UTF-8
# bo_CN UTF-8
# bo_IN UTF-8
# br_FR ISO-8859-1
# br_FR.UTF-8 UTF-8
# br_FR@euro ISO-8859-15
# brx_IN UTF-8
# bs_BA ISO-8859-2
# bs_BA.UTF-8 UTF-8
# byn_ER UTF-8
# ca_AD ISO-8859-15
# ca_AD.UTF-8 UTF-8
# ca_ES ISO-8859-1
# ca_ES.UTF-8 UTF-8
# ca_ES.UTF-8@valencia UTF-8
# ca_ES@euro ISO-8859-15
# ca_ES@valencia ISO-8859-15
# ca_FR ISO-8859-15
# ca_FR.UTF-8 UTF-8
# ca_IT ISO-8859-15
# ca_IT.UTF-8 UTF-8
# ce_RU UTF-8
# chr_US UTF-8
# cmn_TW UTF-8
# crh_UA UTF-8
# cs_CZ ISO-8859-2
# cs_CZ.UTF-8 UTF-8
# csb_PL UTF-8
# cv_RU UTF-8
# cy_GB ISO-8859-14
# cy_GB.UTF-8 UTF-8
# da_DK ISO-8859-1
da_DK.UTF-8 UTF-8
# de_AT ISO-8859-1
# de_AT.UTF-8 UTF-8
# de_AT@euro ISO-8859-15
# de_BE ISO-8859-1
# de_BE.UTF-8 UTF-8
# de_BE@euro ISO-8859-15
# de_CH ISO-8859-1
# de_CH.UTF-8 UTF-8
# de_DE ISO-8859-1
# de_DE.UTF-8 UTF-8
# de_DE@euro ISO-8859-15
# de_IT ISO-8859-1
# de_IT.UTF-8 UTF-8
# de_LI.UTF-8 UTF-8
# de_LU ISO-8859-1
# de_LU.UTF-8 UTF-8
# de_LU@euro ISO-8859-15
# doi_IN UTF-8
# dv_MV UTF-8
# dz_BT UTF-8
# el_CY ISO-8859-7
# el_CY.UTF-8 UTF-8
# el_GR ISO-8859-7
# el_GR.UTF-8 UTF-8
# en_AG UTF-8
# en_AU ISO-8859-1
# en_AU.UTF-8 UTF-8
# en_BW ISO-8859-1
# en_BW.UTF-8 UTF-8
# en_CA ISO-8859-1
# en_CA.UTF-8 UTF-8
# en_DK ISO-8859-1
# en_DK.ISO-8859-15 ISO-8859-15
en_DK.UTF-8 UTF-8
# en_GB ISO-8859-1
# en_GB.ISO-8859-15 ISO-8859-15
en_GB.UTF-8 UTF-8
# en_HK ISO-8859-1
# en_HK.UTF-8 UTF-8
# en_IE ISO-8859-1
# en_IE.UTF-8 UTF-8
# en_IE@euro ISO-8859-15
# en_IL UTF-8
# en_IN UTF-8
# en_NG UTF-8
# en_NZ ISO-8859-1
# en_NZ.UTF-8 UTF-8
# en_PH ISO-8859-1
# en_PH.UTF-8 UTF-8
# en_SG ISO-8859-1
# en_SG.UTF-8 UTF-8
# en_US ISO-8859-1
# en_US.ISO-8859-15 ISO-8859-15
en_US.UTF-8 UTF-8
# en_ZA ISO-8859-1
# en_ZA.UTF-8 UTF-8
# en_ZM UTF-8
# en_ZW ISO-8859-1
# en_ZW.UTF-8 UTF-8
# eo UTF-8
# es_AR ISO-8859-1
# es_AR.UTF-8 UTF-8
# es_BO ISO-8859-1
# es_BO.UTF-8 UTF-8
# es_CL ISO-8859-1
# es_CL.UTF-8 UTF-8
# es_CO ISO-8859-1
# es_CO.UTF-8 UTF-8
# es_CR ISO-8859-1
# es_CR.UTF-8 UTF-8
# es_CU UTF-8
# es_DO ISO-8859-1
# es_DO.UTF-8 UTF-8
# es_EC ISO-8859-1
# es_EC.UTF-8 UTF-8
# es_ES ISO-8859-1
# es_ES.UTF-8 UTF-8
# es_ES@euro ISO-8859-15
# es_GT ISO-8859-1
# es_GT.UTF-8 UTF-8
# es_HN ISO-8859-1
# es_HN.UTF-8 UTF-8
# es_MX ISO-8859-1
# es_MX.UTF-8 UTF-8
# es_NI ISO-8859-1
# es_NI.UTF-8 UTF-8
# es_PA ISO-8859-1
# es_PA.UTF-8 UTF-8
# es_PE ISO-8859-1
# es_PE.UTF-8 UTF-8
# es_PR ISO-8859-1
# es_PR.UTF-8 UTF-8
# es_PY ISO-8859-1
# es_PY.UTF-8 UTF-8
# es_SV ISO-8859-1
# es_SV.UTF-8 UTF-8
# es_US ISO-8859-1
# es_US.UTF-8 UTF-8
# es_UY ISO-8859-1
# es_UY.UTF-8 UTF-8
# es_VE ISO-8859-1
# es_VE.UTF-8 UTF-8
# et_EE ISO-8859-1
# et_EE.ISO-8859-15 ISO-8859-15
# et_EE.UTF-8 UTF-8
# eu_ES ISO-8859-1
# eu_ES.UTF-8 UTF-8
# eu_ES@euro ISO-8859-15
# eu_FR ISO-8859-1
# eu_FR.UTF-8 UTF-8
# eu_FR@euro ISO-8859-15
# fa_IR UTF-8
# ff_SN UTF-8
# fi_FI ISO-8859-1
# fi_FI.UTF-8 UTF-8
# fi_FI@euro ISO-8859-15
# fil_PH UTF-8
# fo_FO ISO-8859-1
# fo_FO.UTF-8 UTF-8
# fr_BE ISO-8859-1
# fr_BE.UTF-8 UTF-8
# fr_BE@euro ISO-8859-15
# fr_CA ISO-8859-1
# fr_CA.UTF-8 UTF-8
# fr_CH ISO-8859-1
# fr_CH.UTF-8 UTF-8
# fr_FR ISO-8859-1
# fr_FR.UTF-8 UTF-8
# fr_FR@euro ISO-8859-15
# fr_LU ISO-8859-1
# fr_LU.UTF-8 UTF-8
# fr_LU@euro ISO-8859-15
# fur_IT UTF-8
# fy_DE UTF-8
# fy_NL UTF-8
# ga_IE ISO-8859-1
# ga_IE.UTF-8 UTF-8
# ga_IE@euro ISO-8859-15
# gd_GB ISO-8859-15
# gd_GB.UTF-8 UTF-8
# gez_ER UTF-8
# gez_ER@abegede UTF-8
# gez_ET UTF-8
# gez_ET@abegede UTF-8etup_configfiles
# gl_ES ISO-8859-1
# gl_ES.UTF-8 UTF-8
# gl_ES@euro ISO-8859-15
# gu_IN UTF-8
# gv_GB ISO-8859-1
# gv_GB.UTF-8 UTF-8
# ha_NG UTF-8
# hak_TW UTF-8
# he_IL ISO-8859-8
# he_IL.UTF-8 UTF-8
# hi_IN UTF-8
# hne_IN UTF-8
# hr_HR ISO-8859-2
# hr_HR.UTF-8 UTF-8
# hsb_DE ISO-8859-2
# hsb_DE.UTF-8 UTF-8
# ht_HT UTF-8
# hu_HU ISO-8859-2
# hu_HU.UTF-8 UTF-8
# hy_AM UTF-8
# hy_AM.ARMSCII-8 ARMSCII-8
# ia_FR UTF-8
# id_ID ISO-8859-1
# id_ID.UTF-8 UTF-8
# ig_NG UTF-8
# ik_CA UTF-8
# is_IS ISO-8859-1
# is_IS.UTF-8 UTF-8
# it_CH ISO-8859-1
# it_CH.UTF-8 UTF-8
# it_IT ISO-8859-1
# it_IT.UTF-8 UTF-8
# it_IT@euro ISO-8859-15
# iu_CA UTF-8
# ja_JP.EUC-JP EUC-JP
# ja_JP.UTF-8 UTF-8
# ka_GE GEORGIAN-PS
# ka_GE.UTF-8 UTF-8
# kk_KZ PT154
# kk_KZ.RK1048 RK1048
# kk_KZ.UTF-8 UTF-8
# kl_GL ISO-8859-1
# kl_GL.UTF-8 UTF-8
# km_KH UTF-8
# kn_IN UTF-8
# ko_KR.EUC-KR EUC-KR
# ko_KR.UTF-8 UTF-8
# kok_IN UTF-8
# ks_IN UTF-8
# ks_IN@devanagari UTF-8
# ku_TR ISO-8859-9
# ku_TR.UTF-8 UTF-8
# kw_GB ISO-8859-1
# kw_GB.UTF-8 UTF-8
# ky_KG UTF-8
# lb_LU UTF-8
# lg_UG ISO-8859-10
# lg_UG.UTF-8 UTF-8
# li_BE UTF-8
# li_NL UTF-8
# lij_IT UTF-8
# ln_CD UTF-8
# lo_LA UTF-8
# lt_LT ISO-8859-13
# lt_LT.UTF-8 UTF-8
# lv_LV ISO-8859-13
# lv_LV.UTF-8 UTF-8
# lzh_TW UTF-8
# mag_IN UTF-8
# mai_IN UTF-8
# mg_MG ISO-8859-15
# mg_MG.UTF-8 UTF-8
# mhr_RU UTF-8
# mi_NZ ISO-8859-13
# mi_NZ.UTF-8 UTF-8
# mk_MK ISO-8859-5
# mk_MK.UTF-8 UTF-8
# ml_IN UTF-8
# mn_MN UTF-8
# mni_IN UTF-8
# mr_IN UTF-8
# ms_MY ISO-8859-1
# ms_MY.UTF-8 UTF-8
# mt_MT ISO-8859-3
# mt_MT.UTF-8 UTF-8
# my_MM UTF-8
# nan_TW UTF-8
# nan_TW@latin UTF-8
# nb_NO ISO-8859-1
# nb_NO.UTF-8 UTF-8
# nds_DE UTF-8
# nds_NL UTF-8
# ne_NP UTF-8
# nhn_MX UTF-8
# niu_NU UTF-8
# niu_NZ UTF-8
# nl_AW UTF-8
# nl_BE ISO-8859-1
# nl_BE.UTF-8 UTF-8
# nl_BE@euro ISO-8859-15
# nl_NL ISO-8859-1
# nl_NL.UTF-8 UTF-8
# nl_NL@euro ISO-8859-15
# nn_NO ISO-8859-1
# nn_NO.UTF-8 UTF-8
# nr_ZA UTF-8
# nso_ZA UTF-8
# oc_FR ISO-8859-1
# oc_FR.UTF-8 UTF-8
# om_ET UTF-8
# om_KE ISO-8859-1
# om_KE.UTF-8 UTF-8
# or_IN UTF-8
# os_RU UTF-8
# pa_IN UTF-8
# pa_PK UTF-8
# pap_AW UTF-8
# pap_CW UTF-8
# pl_PL ISO-8859-2
# pl_PL.UTF-8 UTF-8
# ps_AF UTF-8
# pt_BR ISO-8859-1
# pt_BR.UTF-8 UTF-8
# pt_PT ISO-8859-1
# pt_PT.UTF-8 UTF-8
# pt_PT@euro ISO-8859-15
# quz_PE UTF-8
# raj_IN UTF-8
# ro_RO ISO-8859-2
# ro_RO.UTF-8 UTF-8
# ru_RU ISO-8859-5
# ru_RU.CP1251 CP1251
# ru_RU.KOI8-R KOI8-R
# ru_RU.UTF-8 UTF-8
# ru_UA KOI8-U
# ru_UA.UTF-8 UTF-8
# rw_RW UTF-8
# sa_IN UTF-8
# sat_IN UTF-8
# sc_IT UTF-8
# sd_IN UTF-8
# sd_IN@devanagari UTF-8
# se_NO UTF-8
# sgs_LT UTF-8
# shs_CA UTF-8
# si_LK UTF-8
# sid_ET UTF-8
# sk_SK ISO-8859-2
# sk_SK.UTF-8 UTF-8
# sl_SI ISO-8859-2
# sl_SI.UTF-8 UTF-8
# so_DJ ISO-8859-1
# so_DJ.UTF-8 UTF-8
# so_ET UTF-8
# so_KE ISO-8859-1
# so_KE.UTF-8 UTF-8
# so_SO ISO-8859-1
# so_SO.UTF-8 UTF-8
# sq_AL ISO-8859-1
# sq_AL.UTF-8 UTF-8
# sq_MK UTF-8
# sr_ME UTF-8
# sr_RS UTF-8
# sr_RS@latin UTF-8
# ss_ZA UTF-8
# st_ZA ISO-8859-1
# st_ZA.UTF-8 UTF-8
# sv_FI ISO-8859-1
# sv_FI.UTF-8 UTF-8
# sv_FI@euro ISO-8859-15
# sv_SE ISO-8859-1
# sv_SE.ISO-8859-15 ISO-8859-15
# sv_SE.UTF-8 UTF-8
# sw_KE UTF-8
# sw_TZ UTF-8
# szl_PL UTF-8
# ta_IN UTF-8
# ta_LK UTF-8
# tcy_IN.UTF-8 UTF-8
# te_IN UTF-8
# tg_TJ KOI8-T
# tg_TJ.UTF-8 UTF-8
# th_TH TIS-620
# th_TH.UTF-8 UTF-8
# the_NP UTF-8
# ti_ER UTF-8
# ti_ET UTF-8
# tig_ER UTF-8
# tk_TM UTF-8
# tl_PH ISO-8859-1
# tl_PH.UTF-8 UTF-8
# tn_ZA UTF-8
# tr_CY ISO-8859-9
# tr_CY.UTF-8 UTF-8
# tr_TR ISO-8859-9
# tr_TR.UTF-8 UTF-8
# ts_ZA UTF-8
# tt_RU UTF-8
# tt_RU@iqtelif UTF-8
# ug_CN UTF-8
# uk_UA KOI8-U
# uk_UA.UTF-8 UTF-8
# unm_US UTF-8
# ur_IN UTF-8
# ur_PK UTF-8
# uz_UZ ISO-8859-1
# uz_UZ.UTF-8 UTF-8
# uz_UZ@cyrillic UTF-8
# ve_ZA UTF-8
# vi_VN UTF-8
# wa_BE ISO-8859-1
# wa_BE.UTF-8 UTF-8
# wa_BE@euro ISO-8859-15
# wae_CH UTF-8
# wal_ET UTF-8
# wo_SN UTF-8
# xh_ZA ISO-8859-1
# xh_ZA.UTF-8 UTF-8
# yi_US CP1255
# yi_US.UTF-8 UTF-8
# yo_NG UTF-8
# yue_HK UTF-8
# zh_CN GB2312
# zh_CN.GB18030 GB18030
# zh_CN.GBK GBK
# zh_CN.UTF-8 UTF-8
# zh_HK BIG5-HKSCS
# zh_HK.UTF-8 UTF-8
# zh_SG GB2312
# zh_SG.GBK GBK
# zh_SG.UTF-8 UTF-8
# zh_TW BIG5
# zh_TW.EUC-TW EUC-TW
# zh_TW.UTF-8 UTF-8
# zu_ZA ISO-8859-1
# zu_ZA.UTF-8 UTF-8
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
export DEFGROUPS="sudo,kmem,adm,dialout,${2},video,plugdev,netdev"

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

sudo sh -c 'LANG=C.UTF-8  chroot --userspec=root:root '${1}' /usr/sbin/locale-gen en_GB.UTF-8 en_US.UTF-8 da_DK.UTF-8 en_DK.UTF-8'

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
    HOST_NAME="mksocfpga-nano-soc"
elif [ "${2}" == "holosynth" ]; then
    if [ "${4}" == "arm64" ]; then
        HOST_NAME="holosynthv-u96"
    else
        HOST_NAME="holosynthv"
    fi
elif [ "${2}" == "ubuntu" ]; then
    HOST_NAME="ultra96"
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
sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y update'
sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y --assume-yes upgrade'
sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install debconf gnupg2 sudo wget apt-utils kmod'

sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install tzdata'
sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /bin/ln -fs /usr/share/zoneinfo/Europe/Copenhagen /etc/localtime'
sudo sh -c 'DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/sbin/dpkg-reconfigure --frontend noninteractive tzdata'
sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install featherpad gnupg2 avahi-discover traceroute cgroupfs-mount ntp'

if [ "${3}" == "bionic" ]; then
    sudo chroot --userspec=root:root ${1} /usr/bin/wget http://${local_ws}/ubuntu/socfpgakernel.gpg.key
else
    sudo chroot --userspec=root:root ${1} /usr/bin/wget http://${local_ws}/debian/socfpgakernel.gpg.key
fi

sudo chroot --userspec=root:root ${1} /usr/bin/apt-key add socfpgakernel.gpg.key
sudo chroot --userspec=root:root ${1} /bin/rm socfpgakernel.gpg.key

sudo cp ${1}/etc/apt/sources.list-local ${1}/etc/apt/sources.list
gen_add_user_sh ${1} ${2}
echo "Script_MSG: gen_add_user_sh finished ... will now run in chroot"

sudo sh -c 'LANG=C.UTF-8 chroot '${1}' '${shell_cmd}' -c /home/add_user.sh'

if [ "${3}" == "buster" ]; then
    sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install iputils-ping xorg libpam-systemd systemd-sysv'
fi
echo ""
echo "Scr_MSG: fix no sudo user ping:"
echo ""
sudo chmod u+s ${1}/bin/ping ${1}/bin/ping6
echo "Script_MSG: installing apt-transport-https"
sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y update'
sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y --assume-yes upgrade'
sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install apt-transport-https'
if [[ "${2}" == "machinekit" ]]; then
    if [ "${4}" != "arm64" ]; then
        add_mk_repo ${1} ${2} ${3}
    fi
fi

if [ "${DESKTOP}" == "yes" ]; then
    echo "Scr_MSG: Installing lxqt"
    if [ "${3}" == "bionic" ] || [ "${3}" == "bullseye" ]; then
        if [ "${3}" == "bionic" ]; then
            sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install software-properties-common'
            sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install lxqt-core openbox lxqt-sudo'
            sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install lxqt'
            sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install tasksel'
            sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install task-lxqt-desktop'
            sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install sddm'
        fi
        if [ "${3}" == "bullseye" ]; then
            sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install software-properties-common'
            sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install sddm sddm-theme-debian-elarun'
#            sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install tasksel task-desktop'
            sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install tasksel'
            sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install lxqt'
            sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install task-lxqt-desktop'
            sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install breeze breeze-cursor-theme breeze-icon-theme'
        fi
    else
        sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install software-properties-common'
        sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install lxqt-core lxqt-sudo'
        sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install lxqt pcmanfm-qt5'
        sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install lxmenu-data  lxqt-globalkeys lxqt-panel lxqt'
        sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install breeze breeze-cursor-theme breeze-icon-theme'
    fi
    sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install mesa-utils mesa-utils-extra xfonts-cyrillic'
    sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y update'
    sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y autoremove'
    sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y update'
    sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y --assume-yes upgrade'

    if [[ "${4}" == "arm64" ]]; then
        if [ "${3}" == "bionic" ]; then
            sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install linux-firmware'
        else
            if [ "${3}" == "stretch" ]; then
                sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y -t '${3}'-backports install firmware-ti-connectivity'
            else
                sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install firmware-ti-connectivity'
            fi
        fi
        sudo cp ${WORK_DIR}/../bt/TIInit_11.8.32.bts ${1}/lib/firmware/ti-connectivity/
    fi
    if [[ "${2}" == "holosynth" ]]; then
        echo "Scr_MSG: Installing Cadence deps"
#        sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/wget https://launchpad.net/~kxstudio-debian/+archive/kxstudio/+files/kxstudio-repos_9.5.1~kxstudio3_all.deb'
#        sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/dpkg -i kxstudio-repos_9.5.1~kxstudio3_all.deb'
        sudo sh -c 'LANG=C.UTF-8 chroot --userspec=root:root '${1}' /usr/bin/'${apt_cmd}' -y install libglibmm-2.4-1v5'
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

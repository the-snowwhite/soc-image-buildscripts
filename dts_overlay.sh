#!/bin/bash
# --------- Mount configfs --------------------------------#
# sudo sh -c 'cat << EOT >/etc/fstab
# # /etc/fstab: static file system information.
# #
# # <file system>    <mount point>   <type>  <options>       <dump>  <pass>
# /dev/root          /               ext4    noatime,errors=remount-ro 0 1
# tmpfs              /tmp            tmpfs   defaults                  0 0
# none               /dev/shm        tmpfs   rw,nosuid,nodev,noexec    0 0
# /sys/kernel/config /config         none    bind                      0 0
# EOT'

# --------- Overlay Fragment ------------------------------#

# /dts-v1/ /plugin/;
#
# / {
#    fragment@0 {
#       target-path = "/soc/base_fpga_region";
#       #address-cells = <1>;
#       #size-cells = <1>;
#       __overlay__ {
#          #address-cells = <1>;
#          #size-cells = <1>;
#
#          ranges = <0x00040000 0xff240000 0x00010000>;
#          firmware-name = "socfpga.rbf";
#
#          hm2reg_io_0: hm2-socfpg0@0x40000 {
#             compatible = "machkt,hm2reg-io-1.0";
#             reg = <0x40000 0x10000>;
#             clocks = <&osc1>;
#             address_width = <14>;
#             data_width = <32>;
#          };
#       };
#    };
# };

# --------- Install device-tools 1.4.1 --------------------#

# sudo apt -y install wget
#
# wget https://github.com/the-snowwhite/soc-image-buildscripts/raw/4.4-rt/dtc-overlay.sh
# chmod +x dtc-overlay.sh
# ./dtc-overlay.sh

# --------- Compile device tree overlay -------------------#

# sh -c 'cat << EOT > hm2reg_uio.dts
# /dts-v1/ /plugin/;
#
# / {
#    fragment@0 {
#       target-path = "/soc/base_fpga_region";
#       #address-cells = <1>;
#       #size-cells = <1>;
#       __overlay__ {
#          #address-cells = <1>;
#          #size-cells = <1>;
#
#          ranges = <0x00040000 0xff240000 0x00010000>;
#          firmware-name = "socfpga.rbf";
#
#          hm2reg_io_0: hm2-socfpg0@0x40000 {
#             compatible = "machkt,hm2reg-io-1.0";
#             reg = <0x40000 0x10000>;
#             clocks = <&osc1>;
#             address_width = <14>;
#             data_width = <32>;
#          };
#       };
#    };
# };
# EOT'
#
# dtc -I dts -O dtb -o hm2reg_uio.dtbo hm2reg_uio.dts

# --------- Copy bitfile to firmware search path ----------#

# sudo mkdir -p /lib/firmware
# sudo cp /boot/socfpga.rbf /lib/firmware

# install driver and config fpga
sudo mkdir /config/device-tree/overlays/uio0
sudo sh -c 'cat hm2reg_uio.dtbo > /config/device-tree/overlays/uio0/dtbo'

# mksocfpga login: [   45.188197] random: nonblocking pool is initialized
# [ 1753.355192] (NULL device *): Direct firmware load for hm2reg_uio.dtbo failed with error -2
# [ 1846.433179] fpga_manager fpga0: writing socfpga.rbf to Altera SOCFPGA FPGA Manager
# [ 1846.650956] hmsoc ff240000.hm2-socfpg0: setting: uioinfo->irq = UIO_IRQ_NONE

# uninstall driver
#sudo rmdir /config/device-tree/overlays/uio0



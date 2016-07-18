#!/bin/sh

projdirname=mksocfpga/HW/QuartusProjects
projects=$(ls ../$projdirname)
nanofolder=DE0_NANO_SOC_GHRD
sockitfolder=SoCkit_GHRD
de1folder=DE1_SOC_GHRD

#mkdir -p boot_files/folder1
#mkdir -p boot_files/folder2
set -e  # exit on all errors

if [ "$1" != "" ]; then
   if [ "$1" == "-c" ]; then
      for folder in $projects
      do
         echo ""
         echo "Will attempt to copy Boot files from: ${projdirname}"/"${folder}"
         mkdir -p boot_files/$folder

         cp -v ../$projdirname/$folder/output_files/soc_system.rbf boot_files/$folder/socfpga.rbf
         cp -v ../$projdirname/$folder/soc_system.dtb boot_files/$folder/socfpga.dtb
         cp -v ../$projdirname/$folder/soc_system.dts boot_files/$folder/socfpga.dts
         echo "Boot files copied to: boot_files"/"${folder}"
      done
   else
      lsblk
      echo ""
      echo "files will be installed on $1"
      echo ""
      if [ "$2" != "" ]; then
         if [ "$2" == "nano" ]; then
            cpfolder=${nanofolder}
         elif [ "$2" == "de1" ]; then
            cpfolder=${de1folder}
         elif [ "$2" == "sockit" ]; then
            cpfolder=${sockitfolder}
         fi
      fi
      if [ "$cpfolder" != "" ]; then
         sudo mkdir -p /mnt/rootfs
         sudo mount $1 /mnt/rootfs
         sudo cp -fv boot_files/${cpfolder}/socfpga* /mnt/rootfs/boot
         sync
         sudo umount /mnt/rootfs
#        sudo mkdir -p /mnt/boot
#        sudo mount -o rw -o uid=1000,gid=1000 $1 /mnt/boot
#        sudo cp -fv boot_files/socfpga* /mnt/boot
#        sync
#        sudo umount /mnt/boot
         sync
         echo "operation finished sucessfully"
      else
         echo "wrong board install option use: [/dev/sdxx] [nano or de1 or sockit]"
      fi
   fi
else
   lsblk
   echo ""
   echo "! -- no options given"
   echo "will only copy files to boot_folder"
   echo "to install files to sd"
   echo "use: [/dev/sdxx] [nano | de1 | sockit]"
   echo "Or:"
   echo "use: [-c] to copy Quartus output files from mksocfpga Quartus project folders"
   echo ""
fi


#!/bin/bash
set -m

buildHome="/media/oldlinux/Android-Kitchen/cm12.1"
echo -ne "Kernel Name: "
read kname
outZip="cm-12-Custom-OC-$kname-$(date +"%Y-%m-%d").zip"
cd $buildHome/

if [ -d "$buildHome/out/target/product/maserati/obj/KERNEL_OBJ" ]; then
  echo "Cleaning old KERNEL_OBJ folder"
  rm -rf $buildHome/out/target/product/maserati/obj/KERNEL_OBJ/
  rm $buildHome/out/target/product/maserati/kernel
  rm $buildHome/out/target/product/maserati/boot.img
fi
export LOCALVERSION="-JJB666-m-$kname-5.0"

printenv

. build/envsetup.sh && breakfast maserati
mka bootimage

if [ ! -f "$buildHome/out/target/product/maserati/kernel" ]; then
  echo "Kernel build failed."
  exit
fi

if [ ! -d "$buildHome/out/jjb666" ]; then
  mkdir $buildHome/out/jjb666
fi

cp -r $buildHome/kernel/motorola/omap4-common/buildfiles/META-INF $buildHome/out/jjb666/
cp -r /home/MADHOPS/jasonl/Android-Kitchen/6.0stash/kernel-mod/buildfiles/META-INF /media/oldlinux/Android-Kitchen/cm13/out/jjb666/
if [ ! -d "/media/oldlinux/Android-Kitchen/cm13/out/jjb666/system" ]; then
  mkdir /media/oldlinux/Android-Kitchen/cm13/out/jjb666/system
fi
if [ ! -d "/media/oldlinux/Android-Kitchen/cm13/out/jjb666/system/etc" ]; then
  mkdir /media/oldlinux/Android-Kitchen/cm13/out/jjb666/system/etc
fi
if [ ! -d "/media/oldlinux/Android-Kitchen/cm13/out/jjb666/system/etc/kexec" ]; then
  mkdir /media/oldlinux/Android-Kitchen/cm13/out/jjb666/system/etc/kexec
fi
cp ./out/target/product/maserati/kernel ./out/jjb666/system/etc/kexec
cd $buildHome/out/jjb666

printf 'ui_print(" |-*-*-|  CM12 Custom Kernel by JooJooBee666  |-*-*-|");'$'\n' > ./META-INF/com/google/android/updater-script
printf 'ui_print("                 Device: Moto OMAP4");'$'\n' >> ./META-INF/com/google/android/updater-script
printf "ui_print(\"      Build time: %s\");" "$(date)" >> ./META-INF/com/google/android/updater-script
printf $'\n' >> ./META-INF/com/google/android/updater-script
printf 'ui_print(" ");'$'\n' >> ./META-INF/com/google/android/updater-script
printf 'show_progress(0.500000, 3);'$'\n' >> ./META-INF/com/google/android/updater-script
printf 'mount("ext4", "EMMC", "/dev/block/system", "/system");'$'\n' >> ./META-INF/com/google/android/updater-script
printf 'package_extract_dir("system", "/system");'$'\n' >> ./META-INF/com/google/android/updater-script
printf 'show_progress(0.500000, 0);'$'\n' >> ./META-INF/com/google/android/updater-script
printf 'unmount("/system");'$'\n' >> ./META-INF/com/google/android/updater-script
printf 'ui_print("Completed. Reboot.");'$'\n' >> ./META-INF/com/google/android/updater-script
printf ''$'\n' >> ./META-INF/com/google/android/updater-script

zip -r "$outZip" *

mv $outZip $buildHome/out/$outZip
cd $buildHome/

echo "Created file: out/$outZip"

# cd /sys/devices/system/cpu/cpu0/cpufreq

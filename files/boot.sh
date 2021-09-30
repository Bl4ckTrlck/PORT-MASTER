PATCHDATE=$1
SOURCEROM=$2
OUTP=$3
MAK=$4
USERLUN=$5
CURRENTDIR=$6

set -e
cd $SOURCEROM

source ~/.profile
source ~/.bashrc
PATH=~/bin:$PATH


sed -i "/PLATFORM_SECURITY_PATCH :=/c\      PLATFORM_SECURITY_PATCH := $PATCHDATE" $SOURCEROM/build/core/version_defaults.mk
sed -i "$ i\BOARD_KERNEL_CMDLINE += androidboot.selinux=permissive" $SOURCEROM/device/xiaomi/sdm660-common/BoardConfigCommon.mk


source build/envsetup.sh
lunch $USERLUN
mka bootimage

cp -f out/target/product/$MAK/boot.img $OUTP/boot.img
clear
echo " process completed "
echo 
cd $CURRENTDIR

export CURRENTUSER=$(whoami)
SCRIPTDIR=$(readlink -f "$0")
CURRENTDIR=$(dirname "$SCRIPTDIR")
JAS=jasmine_sprout
WAY=wayne
lasys=$CURRENTDIR/lasys
CURRENTUSER=$2
PORTZIP=$1
imgs=$CURRENTDIR/fac
OUTP=$CURRENTDIR/out
set -e

rm -rf $OUTP $lasys || true
mkdir $OUTP

#MIUI ZIP Process
printf "\n" 
printf "starting process"
printf "\n" 
printf "take 1-? minutes...."
printf "\n" 
printf "\n" 
chown $CURRENTUSER:$CURRENTUSER $OUTP
cp -Raf $CURRENTDIR/zip $OUTP/
sleep 2s
clear
printf "\n" 
printf "converting zip"
printf "\n"
echo
sleep 1s
unzip -d $OUTP $PORTZIP system.transfer.list system.new.dat.br
brotli -j -v -d $OUTP/system.new.dat.br -o $OUTP/system.new.dat
$CURRENTDIR/sdat2img/sdat2img.py $OUTP/system.transfer.list $OUTP/system.new.dat $OUTP/system.img
rm $OUTP/system.new.dat $OUTP/system.transfer.list 

clear 
echo " loading... "
#mount imgs process
mkdir $lasys || true
mount -o rw,noatime $OUTP/system.img $lasys

PATCHDATE=$(sudo grep ro.build.version.security_patch= $lasys/system/build.prop | sed "s/ro.build.version.security_patch=//g"; )
if [[ -z $PATCHDATE ]]
then
echo "failed to find security patch date, aborting" && exit
fi
echo
echo " add source "
echo " like ~/komodo "
echo
read -p " source: " SOURCEROM
if [ "$SOURCEROM" ]; then
echo
else
echo " no source "
fi
sleep 2s
clear
echo
echo " wich is your device? "
echo " jasmine - 1 "
echo " wayne - 2 "
echo
read -p " wich ? " DEVICE
echo
if [ "$DEVICE" = "1" ]; then
sudo chmod +x $CURRENTDIR/boot.sh 
echo " you selected jasmine"
sleep 2s
clear
echo
echo " add lunch command "
echo 
echo " like: "
echo
echo " lunch aicp_jasmine_sprout-userdebug "
echo
read -p " Lunch: " USERLUN
if [ "$USERLUN" ]; then
echo
else
echo " no lunch "
fi
sleep 2s
clear
su -c "$CURRENTDIR/boot.sh $PATCHDATE $SOURCEROM $OUTP $JAS $USERLUN $CURRENTDIR" $CURRENTUSER
exit
fi
if [ "$DEVICE" = "2" ]; then
sudo chmod +x $CURRENTDIR/boot.sh 
echo " you selected wayne"
sleep 2s
clear
echo
echo " add lunch command "
echo 
echo " like: "
echo
echo " lunch aicp_wayne-userdebug "
echo
read -p " Lunch: " USERLUN
if [ "$USERLUN" ]; then
echo
else
echo " no lunch "
fi
sleep 2s
clear
su -c "$CURRENTDIR/boot.sh $PATCHDATE $SOURCEROM $OUTP $WAY $USERLUN $CURRENTDIR" $CURRENTUSER
exit
fi
umount $lasys
rmdir $lasys

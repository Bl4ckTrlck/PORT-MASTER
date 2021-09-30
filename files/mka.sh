export CURRENTUSER=$(whoami)
SCRIPTDIR=$(readlink -f "$0")
CURRENTDIR=$(dirname "$SCRIPTDIR")
JAS=jasmine_sprout
WAY=wayne
CURRENTUSER=$2
PROP=$1
OUTP=$CURRENTDIR/out
set -e

rm -rf $OUTP || true
mkdir $OUTP

printf "\n" 
printf "starting process"
printf "\n" 
printf "take 1-? minutes...."
printf "\n" 
printf "\n" 
sleep 2s
clear
chown $CURRENTUSER:$CURRENTUSER $OUTP

PATCHDATE=$(sudo grep ro.build.version.security_patch= $PROP | sed "s/ro.build.version.security_patch=//g"; )
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



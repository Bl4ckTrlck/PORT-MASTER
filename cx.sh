export CURRENTUSER=$(whoami)
SCRIPTDIR=$(readlink -f "$0")
CURRENTDIR=$(dirname "$SCRIPTDIR")
FIL=$CURRENTDIR/files

if [ $CURRENTUSER == root ]
then
echo "do not run as root" && exit
fi
echo "how you want to create boot.img?"
echo
echo "1 - with rom zip"
echo
echo "2 - with build.prop "
echo
echo "3 - with security patch date "
echo
read -p "wich ? " BOOT
echo
sleep 2s
clear
if [ "$BOOT" = "1" ]; then
sudo chmod +x $FIL/mak.sh 
echo " Add rom zip or location"
read -p " zip: " ROM
if [ "$ROM" ]; then
echo
else
echo " no zip"
fi
sleep 2s
clear
sudo su -c "$FIL/mak.sh $ROM $CURRENTUSER"
sudo mv $FIL/out/boot.img $CURRENTDIR/
exit
fi
if [ "$BOOT" = "2" ]; then
sudo chmod +x $FIL/mka.sh 
echo " Add build.prop or location"
read -p "File: " PROP
if [ "$PROP" ]; then
echo
fi
sleep 2s
clear
sudo su -c "$FIL/mka.sh $PROP $CURRENTUSER"
sudo mv $FIL/out/boot.img $CURRENTDIR/
exit
fi
if [ "$BOOT" = "3" ]; then
sudo chmod +x $FIL/kma.sh 
echo " write / add patch date"
echo
echo " year - month - day | like: 2021-06-01 "
read -p " Date: " PDATE
if [ "$PDATE" ]; then
echo
fi
sleep 2s
clear
sudo su -c "$FIL/kma.sh $PDATE $CURRENTUSER"
sudo mv $FIL/out/boot.img $CURRENTDIR/
exit
fi

export CURRENTUSER=$(whoami)
SCRIPTDIR=$(readlink -f "$0")
CURRENTDIR=$(dirname "$SCRIPTDIR")
FIL=$CURRENTDIR/files

echo "Add zip rom to port or location"
read -p "zip:" PORTZIP
if [ "$PORTZIP" ]; then
echo
else
echo " no zip"
fi
if [ $CURRENTUSER == root ]
then
echo "do not run as root" && exit
fi
echo "MI A2(jasmine) or 6X (wayne)"
echo "1 - jasmine"
echo "2 - wayne "
echo "3 - jasmine with boot"
echo "4 - wayne with boot "
read -p "wich ? " DEVICE
if [ "$DEVICE" = "1" ]; then
sudo chmod +x $FIL/man.sh 
sudo su -c "$FIL/man.sh $PORTZIP $CURRENTUSER"
sudo mv $FIL/out/* $CURRENTDIR/
sudo chmod 777 $CURRENTDIR/MIUI_.zip -R
exit
fi
if [ "$DEVICE" = "2" ]; then
sudo chmod +x $FIL/mal.sh 
sudo su -c "$FIL/mal.sh $PORTZIP $CURRENTUSER"
sudo mv $FIL/out/* $CURRENTDIR/
sudo chmod 777 $CURRENTDIR/MIUI_.zip -R
exit
fi
if [ "$DEVICE" = "3" ]; then
read -p "Source location:" SOURCE
if [ "$SOURCE" ]; then
echo
else
echo " no source"
fi
echo "add lunch, example: komodo_jasmine_sprout-user" 
read -p "add lunch:" LUNCHJA
if [ "$LUNCHJA" ]; then
echo
else
echo " no lunch"
fi
sudo rm -rf $FIL/boot-ja.sh $FIL/boot-wa.sh || true
cp $FIL/boot.sh $FIL/boot-ja.sh
sed -i "s/USERLUN/$LUNCHJA/g
s/DEVICE/jasmine_sprout/g" $FIL/boot-ja.sh
sudo chmod +x $FIL/mak.sh 
sudo chmod +x $FIL/boot-ja.sh 
sudo su -c "$FIL/mak.sh $PORTZIP $SOURCEROM $CURRENTUSER"
sudo mv $FIL/out/* $CURRENTDIR/
sudo chmod 777 $CURRENTDIR/MIUI_.zip -R
exit
fi
if [ "$DEVICE" = "4" ]; then
read -p "Source location:" SOURCE
if [ "$SOURCE" ]; then
echo
else
echo " no source"
fi
echo "add lunch, example: komodo_wayne-user" 
read -p "add lunch:" LUNCHJ
if [ "$LUNCHJ" ]; then
echo
else
echo " no lunch"
fi
sudo rm -rf $FIL/boot-wa.sh $FIL/boot-ja.sh || true
cp $FIL/boot.sh $FIL/boot-wa.sh
sed -i "s/USERLUN/$LUNCHJ/g
s/DEVICE/wayne/g" $FIL/boot-wa.sh
sudo chmod +x $FIL/mar.sh 
sudo chmod +x $FIL/boot-wa.sh 
sudo su -c "$FIL/mar.sh $PORTZIP $SOURCEROM $CURRENTUSER"
sudo mv $FIL/out/* $CURRENTDIR/
sudo chmod 777 $CURRENTDIR/MIUI_.zip -R
exit
fi

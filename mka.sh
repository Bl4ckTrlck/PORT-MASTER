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


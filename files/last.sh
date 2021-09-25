CURRENTUSER=$4
SOURCEROM=$3
SCRIPTDIR=$(readlink -f "$0")
CURRENTDIR=$(dirname "$SCRIPTDIR")
OUTP=$CURRENTDIR/out

sudo e2fsck -y -f $OUTP/system.img
sudo resize2fs $OUTP/system.img 786432

img2simg $OUTP/system.img $OUTP/sparsesystem.img
sudo rm $OUTP/system.img
$CURRENTDIR/img2sdat/img2sdat.py -v 4 -o $OUTP/zip -p system $OUTP/sparsesystem.img
sudo rm $OUTP/sparsesystem.img
img2simg $OUTP/vendor.img $OUTP/sparsevendor.img
sudo rm $OUTP/vendor.img
$CURRENTDIR/img2sdat/img2sdat.py -v 4 -o $OUTP/zip -p vendor $OUTP/sparsevendor.img
sudo rm $OUTP/sparsevendor.img
brotli -j -v -q 6 $OUTP/zip/system.new.dat
brotli -j -v -q 6 $OUTP/zip/vendor.new.dat

cd $OUTP/zip
zip -ry $OUTP/MIUI_$DEVICE-$ROMVERSION.zip *
cd $CURRENTDIR
rm -rf $OUTP/zip
chown -hR $CURRENTUSER:$CURRENTUSER $OUTP


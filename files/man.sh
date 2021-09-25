export CURRENTUSER=$(whoami)
SCRIPTDIR=$(readlink -f "$0")
CURRENTDIR=$(dirname "$SCRIPTDIR")
cam=$CURRENTDIR/cam
sys=$CURRENTDIR/lac
ven=$CURRENTDIR/dlac
lasys=$CURRENTDIR/lasys
laven=$CURRENTDIR/laven
CURRENTUSER=$2
PORTZIP=$1
imgs=$CURRENTDIR/fac
OUTP=$CURRENTDIR/out
set -e

rm -rf $OUTP $cam $sys $ven $lasys $laven || true
mkdir $OUTP

#MIUI ZIP Process
printf "\n" 
printf "starting process"
printf "\n" 
printf "take 1-? minutes...."
printf "\n" 
printf "\n" 
printf "Your device is A2"
printf "\n" 
printf "\n" 
chown $CURRENTUSER:$CURRENTUSER $OUTP
cp -Raf $CURRENTDIR/zip $OUTP/
unzip -d $OUTP $PORTZIP system.transfer.list vendor.transfer.list system.new.dat.br vendor.new.dat.br
brotli -j -v -d $OUTP/system.new.dat.br -o $OUTP/system.new.dat
brotli -j -v -d $OUTP/vendor.new.dat.br -o $OUTP/vendor.new.dat
$CURRENTDIR/sdat2img/sdat2img.py $OUTP/system.transfer.list $OUTP/system.new.dat $OUTP/system.img
$CURRENTDIR/sdat2img/sdat2img.py $OUTP/vendor.transfer.list $OUTP/vendor.new.dat $OUTP/vendor.img
rm $OUTP/system.new.dat $OUTP/vendor.new.dat $OUTP/system.transfer.list $OUTP/vendor.transfer.list

printf "\n" 
printf "converting rom"
printf "\n" 
#mount imgs process
mkdir $cam || true
mkdir $ven || true
mkdir $sys || true
mkdir $lasys || true
mkdir $laven || true

cp -af $imgs/caM.img $cam	
cp -af $imgs/Lac.img $sys
cp -af $imgs/Dlac.img $ven

mount -o rw,noatime $cam/caM.img $cam
mount -o rw,noatime $sys/Lac.img $sys
mount -o rw,noatime $ven/Dlac.img $ven
mount -o rw,noatime $OUTP/system.img $lasys
mount -o rw,noatime $OUTP/vendor.img $laven

printf "\n" 
printf "starting the porting OwO"
printf "\n" 
printf "\n" 
printf "." 

#BUILD.prop editing
sed -i "/persist.camera.HAL3.enabled=/c\persist.camera.HAL3.enabled=1
/persist.vendor.camera.HAL3.enabled=/c\persist.vendor.camera.HAL3.enabled=1
/ro.product.model=/c\ro.product.model=MI A2
/persist.vendor.camera.exif.model=/c\persist.vendor.camera.exif.model=MI A2
/ro.product.name=/c\ro.product.name=wayne
/ro.product.device=/c\ro.product.device=wayne
/ro.build.product=/c\ro.build.product=wayne
/ro.product.system.device=/c\ro.product.system.device=wayne
/ro.product.system.model=/c\ro.product.system.model=MI A2
/ro.product.system.name=/c\ro.product.system.name=wayne
/ro.miui.notch=/c\ro.miui.notch=0
/sys.paper_mode_max_level=/c\sys.paper_mode_max_level=32
\$ i sys.tianma_nt36672_offset=12
\$ i sys.tianma_nt36672_length=46
\$ i sys.jdi_nt36672_offset=9
\$ i sys.jdi_nt36672_length=45
/persist.vendor.camera.model=/c\persist.vendor.camera.model=MI A2" $lasys/system/build.prop

sed -i "/ro.build.characteristics=/c\ro.build.characteristics=nosdcard" $lasys/system/product/build.prop

sed -i "/ro.miui.has_cust_partition=/c\ro.miui.has_cust_partition=false" $lasys/system/etc/prop.default

sed -i "/ro.product.vendor.model=/c\ro.product.vendor.model=MI A2
/ro.product.vendor.name=/c\ro.product.vendor.name=wayne
/ro.product.vendor.device=/c\ro.product.vendor.device=wayne" $laven/build.prop

sed -i "/ro.product.odm.device=/c\ro.product.odm.device=wayne
/ro.product.odm.model=/c\ro.product.odm.model=MI A2
/ro.product.odm.device=/c\ro.product.odm.device=wayne
/ro.product.odm.name=/c\ro.product.odm.name=wayne" $laven/odm/etc/build.prop

echo "#properties for camera front flash lux
persist.vendor.imx376_sunny.low.lux=310
persist.vendor.imx376_sunny.light.lux=280
persist.vendor.imx376_ofilm.low.lux=310
persist.vendor.imx376_ofilm.light.lux=280" >> $lasys/system/build.prop

printf "\n" 
printf "." 

#boot process
mkdir $lasys/system/addon.d
setfattr -h -n security.selinux -v u:object_r:system_file:s0 $lasys/system/addon.d
chmod 755 $lasys/system/addon.d
cp -f $CURRENTDIR/bootctl $lasys/system/bin/
chmod 755 $lasys/system/bin/bootctl
setfattr -h -n security.selinux -v u:object_r:system_file:s0 $lasys/system/bin/bootctl
cp -af $sys/system/lib/vndk-29/android.hardware.boot@1.0.so $lasys/system/lib/vndk-29/android.hardware.boot@1.0.so
cp -af $sys/system/lib64/vndk-29/android.hardware.boot@1.0.so $lasys/system/lib64/vndk-29/android.hardware.boot@1.0.so
cp -af $sys/system/lib64/android.hardware.boot@1.0.so $lasys/system/lib64/android.hardware.boot@1.0.so

printf "\n" 
printf "." 
 
#Device_Feautures
cp -af $ven/etc/device_features/wayne.xml $lasys/system/etc/device_features/
mkdir $laven/etc/device_features || true
cp -af $ven/etc/device_features/wayne.xml $laven/etc/device_features/

cp -af $ven/etc/MIUI_DualCamera_watermark.png $lasys/system/etc/dualcamera.png
cp -af $ven/etc/MIUI_DualCamera_watermark.png $laven/etc/

printf "\n" 
printf "." 

#FIRMWARE
rm -rf $laven/firmware
cp -Raf $ven/firmware $laven/firmware

printf "\n" 
printf "." 

#DEBLOAT
rm -rf $lasys/system/priv-app/Updater
rm -rf $lasys/system/priv-app/MiBrowserGlobal
rm -rf $lasys/system/priv-app/MiShare
rm -rf $lasys/system/priv-app/MiService
rm -rf $lasys/system/priv-app/MiMover
rm -rf $lasys/system/priv-app/MiuiScanner
rm -rf $lasys/system/priv-app/Weather
rm -rf $lasys/system/app/Health
rm -rf $lasys/system/app/Notes
rm -rf $lasys/system/app/MiuiBugReport
rm -rf $lasys/system/app/Lens
rm -rf $lasys/system/product/priv-app/Velvet
rm -rf $lasys/system/product/priv-app/AndroidAutoStub

printf "\n" 
printf "." 

#VENDOR
cp -f $imgs/fstab.qcom $laven/etc/
chmod 644 $laven/etc/fstab.qcom
setfattr -h -n security.selinux -v u:object_r:vendor_configs_file:s0 $laven/etc/fstab.qcom
chown -hR root:root $laven/etc/fstab.qcom

cp -af $ven/bin/hw/android.hardware.boot@1.0-service $laven/bin/hw/android.hardware.boot@1.0-service
cp -af $ven/etc/init/android.hardware.boot@1.0-service.rc $laven/etc/init/android.hardware.boot@1.0-service.rc
cp -af $ven/lib/hw/bootctrl.sdm660.so $laven/lib/hw/bootctrl.sdm660.so
cp -af $ven/lib/hw/android.hardware.boot@1.0-impl.so $laven/lib/hw/android.hardware.boot@1.0-impl.so
cp -af $ven/lib64/hw/bootctrl.sdm660.so $laven/lib64/hw/bootctrl.sdm660.so
cp -af $ven/lib64/hw/android.hardware.boot@1.0-impl.so $laven/lib64/hw/android.hardware.boot@1.0-impl.so

sed -i "58 i \    <hal format=\"hidl\">
58 i \        <name>android.hardware.boot</name>
58 i \        <transport>hwbinder</transport>
58 i \        <version>1.0</version>
58 i \        <interface>
58 i \            <name>IBootControl</name>
58 i \            <instance>default</instance>
58 i \        </interface>
58 i \        <fqname>@1.0::IBootControl/default</fqname>
58 i \    </hal>" $laven/etc/vintf/manifest.xml

printf "\n" 
printf "." 

#KEYMASTER
rm -f $laven/etc/init/android.hardware.keymaster@4.0-service-qti.rc
cp -af $ven/etc/init/android.hardware.keymaster@3.0-service-qti.rc $laven/etc/init/android.hardware.keymaster@3.0-service-qti.rc
sed -i "181 s/        <version>4.0<\/version>/        <version>3.0<\/version>/g
s/4.0::IKeymasterDevice/3.0::IKeymasterDevice/g" $laven/etc/vintf/manifest.xml

printf "\n" 
printf "." 

#CAMERA_CURRENTDIR
rm -rf $laven/etc/sensors
cp -Raf $ven/etc/sensors $laven/etc/sensors
cp -af $ven/etc/camera/camera_config.xml $laven/etc/camera/camera_config.xml
cp -af $ven/etc/camera/csidtg_camera.xml $laven/etc/camera/csidtg_camera.xml
cp -af $ven/etc/camera/csidtg_chromatix.xml $laven/etc/camera/camera_chromatix.xml
cp -af $ven/lib/libMiWatermark.so $laven/lib/libMiWatermark.so
cp -af $ven/lib/libdng_sdk.so $laven/lib/libdng_sdk.so
cp -af $ven/lib/libvidhance_gyro.so $laven/lib/libvidhance_gyro.so
cp -af $ven/lib/libvidhance.so $laven/lib/
cp -af $ven/lib64/libmmcamera* $laven/lib64/
cp -af $ven/lib/libmmcamera* $laven/lib/

printf "\n" 
printf "." 

#CORRECTIONS-CAMERA
cp -af $cam/lib/* $laven/lib/
cp -f $cam/lib/hw/camera.sdm660.so $laven/lib/hw/
cp -af $ven/MiuiCamera.apk $lasys/system/priv-app/MiuiCamera

printf "\n" 
printf "." 

#FINGERPRINT_C
cp -af $CURRENTDIR/fingerprint/app/FingerprintExtensionService/FingerprintExtensionService.apk $laven/app/FingerprintExtensionService/FingerprintExtensionService.apk
setfattr -h -n security.selinux -v u:object_r:vendor_app_file:s0 $laven/app/FingerprintExtensionService/FingerprintExtensionService.apk
chmod 644 $laven/app/FingerprintExtensionService/FingerprintExtensionService.apk
chown -hR root:root $laven/app/FingerprintExtensionService/FingerprintExtensionService.apk
cp -af $CURRENTDIR/fingerprint/framework/com.fingerprints.extension.jar $laven/framework/com.fingerprints.extension.jar
setfattr -h -n security.selinux -v u:object_r:vendor_framework_file:s0 $laven/framework/com.fingerprints.extension.jar
chmod 644 $laven/framework/com.fingerprints.extension.jar
chown -hR root:root $laven/framework/com.fingerprints.extension.jar
cp -af $CURRENTDIR/fingerprint/lib64/hw/fingerprint.fpc.default.so $laven/lib64/hw/fingerprint.fpc.default.so
setfattr -h -n security.selinux -v u:object_r:vendor_file:s0 $laven/lib64/hw/fingerprint.fpc.default.so
chmod 644 $laven/lib64/hw/fingerprint.fpc.default.so
chown -hR root:root $laven/lib64/hw/fingerprint.fpc.default.so
cp -af $CURRENTDIR/fingerprint/lib64/hw/fingerprint.goodix.default.so $laven/lib64/hw/fingerprint.goodix.default.so
setfattr -h -n security.selinux -v u:object_r:vendor_file:s0 $laven/lib64/hw/fingerprint.goodix.default.so
chmod 644 $laven/lib64/hw/fingerprint.goodix.default.so
chown -hR root:root $laven/lib64/hw/fingerprint.goodix.default.so
cp -af $CURRENTDIR/fingerprint/lib64/vendor.qti.hardware.fingerprint@1.0.so $laven/lib64/vendor.qti.hardware.fingerprint@1.0.so
setfattr -h -n security.selinux -v u:object_r:vendor_file:s0 $laven/lib64/vendor.qti.hardware.fingerprint@1.0.so
chmod 644 $laven/lib64/vendor.qti.hardware.fingerprint@1.0.so
chown -hR root:root $laven/lib64/vendor.qti.hardware.fingerprint@1.0.so
cp -af $CURRENTDIR/fingerprint/lib64/libvendor.goodix.hardware.fingerprint@1.0-service.so $laven/lib64/libvendor.goodix.hardware.fingerprint@1.0-service.so
setfattr -h -n security.selinux -v u:object_r:vendor_file:s0 $laven/lib64/libvendor.goodix.hardware.fingerprint@1.0-service.so
chmod 644 $laven/lib64/libvendor.goodix.hardware.fingerprint@1.0-service.so
chown -hR root:root $laven/lib64/libvendor.goodix.hardware.fingerprint@1.0-service.so
cp -af $CURRENTDIR/fingerprint/lib64/libvendor.goodix.hardware.fingerprint@1.0.so $laven/lib64/libvendor.goodix.hardware.fingerprint@1.0.so
setfattr -h -n security.selinux -v u:object_r:vendor_file:s0 $laven/lib64/libvendor.goodix.hardware.fingerprint@1.0.so
chmod 644 $laven/lib64/libvendor.goodix.hardware.fingerprint@1.0.so
chown -hR root:root $laven/lib64/libvendor.goodix.hardware.fingerprint@1.0.so
cp -af $CURRENTDIR/fingerprint/lib64/com.fingerprints.extension@1.0.so $laven/lib64/com.fingerprints.extension@1.0.so
setfattr -h -n security.selinux -v u:object_r:vendor_file:s0 $laven/lib64/com.fingerprints.extension@1.0.so
chmod 644 $laven/lib64/com.fingerprints.extension@1.0.so
chown -hR root:root $laven/lib64/com.fingerprints.extension@1.0.so
cp -af $CURRENTDIR/fingerprint/lib64/libgf_ca.so $laven/lib64/libgf_ca.so
setfattr -h -n security.selinux -v u:object_r:vendor_file:s0 $laven/lib64/libgf_ca.so
chmod 644 $laven/lib64/libgf_ca.so
chown -hR root:root $laven/lib64/libgf_ca.so
cp -af $CURRENTDIR/fingerprint/lib64/libgf_hal.so $laven/lib64/libgf_hal.so
setfattr -h -n security.selinux -v u:object_r:vendor_file:s0 $laven/lib64/libgf_hal.so
chmod 644 $laven/lib64/libgf_hal.so
chown -hR root:root $laven/lib64/libgf_hal.so

cp -Raf $sys/system/usr/keylayout/uinput-fpc.kl $lasys/system/usr/keylayout/
cp -Raf $sys/system/usr/idc/uinput-fpc.idc $lasys/system/usr/idc/

sed -i "477 c\        <name>vendor.goodix.hardware.fingerprint</name>" $laven/etc/vintf/manifest.xml
sed -i "479 c\        <version>1.0</version>
481 c\            <name>IGoodixBiometricsFingerprint</name>
484 c\        <fqname>@1.0::IGoodixBiometricsFingerprint/default</fqname>
485d
486d
487d
488d
489d" $laven/etc/vintf/manifest.xml

printf "\n" 
printf "." 

#WIFI_HAL
cp -f $CURRENTDIR/libwifi-hal64.so $laven/lib64/libwifi-hal.so
chmod 644 $laven/lib64/libwifi-hal.so
chown -hR root:root $laven/lib64/libwifi-hal.so
setfattr -h -n security.selinux -v u:object_r:vendor_file:s0 $laven/lib64/libwifi-hal.so

cp -f $CURRENTDIR/libwifi-hal32.so $laven/lib/libwifi-hal.so
chmod 644 $laven/lib/libwifi-hal.so
chown -hR root:root $laven/lib/libwifi-hal.so
setfattr -h -n security.selinux -v u:object_r:vendor_file:s0 $laven/lib/libwifi-hal.so

printf "\n" 
printf "." 

#AUDIO
rm -rf $laven/etc/acdbdata
cp -Raf $ven/etc/acdbdata $laven/etc/acdbdata

printf "\n" 
printf "." 

#STATUSBAR
rm -rf $laven/app/NotchOverlay
cp -f $CURRENTDIR/overlay/DevicesOverlay.apk $laven/overlay/DevicesOverlay.apk
cp -f $CURRENTDIR/overlay/DevicesAndroidOverlay.apk $laven/overlay/DevicesAndroidOverlay.apk
chmod 644 $laven/overlay/DevicesOverlay.apk
chmod 644 $laven/overlay/DevicesAndroidOverlay.apk
chown -hR root:root $laven/overlay/DevicesOverlay.apk
chown -hR root:root $laven/overlay/DevicesAndroidOverlay.apk
setfattr -h -n security.selinux -v u:object_r:vendor_overlay_file:s0 $laven/overlay/DevicesOverlay.apk
setfattr -h -n security.selinux -v u:object_r:vendor_overlay_file:s0 $laven/overlay/DevicesAndroidOverlay.apk

printf "\n" 
printf "." 

#READINGMODE
cp -f $CURRENTDIR/readingmode/qdcm_calib_data_jdi_nt36672_fhd_video_mode_dsi_panel.xml $laven/etc/qdcm_calib_data_jdi_nt36672_fhd_video_mode_dsi_panel.xml
cp -f $CURRENTDIR/readingmode/qdcm_calib_data_tianma_nt36672_fhd_video_mode_dsi_panel.xml $laven/etc/qdcm_calib_data_tianma_nt36672_fhd_video_mode_dsi_panel.xml
chmod 644 $laven/etc/qdcm_calib_data_jdi_nt36672_fhd_video_mode_dsi_panel.xml
chmod 644 $laven/etc/qdcm_calib_data_tianma_nt36672_fhd_video_mode_dsi_panel.xml
chown -hR root:root $laven/etc/qdcm_calib_data_jdi_nt36672_fhd_video_mode_dsi_panel.xml
chown -hR root:root $laven/etc/qdcm_calib_data_tianma_nt36672_fhd_video_mode_dsi_panel.xml
setfattr -h -n security.selinux -v u:object_r:vendor_configs_file:s0 $laven/etc/qdcm_calib_data_jdi_nt36672_fhd_video_mode_dsi_panel.xml
setfattr -h -n security.selinux -v u:object_r:vendor_configs_file:s0 $laven/etc/qdcm_calib_data_tianma_nt36672_fhd_video_mode_dsi_panel.xml

printf "\n" 
printf "." 

#MARK-BOOT
sed -i "452 i \    exec_background u:object_r:system_file:s0 -- /system/bin/bootctl mark-boot-successful" $laven/etc/init/hw/init.qcom.rc

sed -i "124 i \

124 i \    # Wifi firmware reload path
124 i \    chown wifi wifi /sys/module/wlan/parameters/fwpath
124 i \

124 i \    # DT2W node
124 i \    chmod 0660 /sys/touchpanel/double_tap
124 i \    chown system system /sys/touchpanel/double_tap" $laven/etc/init/hw/init.target.rc
 
printf "\n" 
printf "converting to zip"
printf "\n" 

#ZIP
ROMVERSION=$(grep ro.system.build.version.incremental= $lasys/system/build.prop | sed "s/ro.system.build.version.incremental=//g"; )
sed -i "s/DEVICE/jasmine_sprout/g
s/XXXXX/MI_A2/g" $OUTP/zip/META-INF/com/google/android/updater-script

umount $cam
umount $sys
umount $ven
umount $laven
umount $lasys
rm -r $cam
rm -r $sys
rm -r $ven
rmdir $lasys
rmdir $laven

DEVICE=jasmine_Sprout
sudo su -c "$CURRENTDIR/last.sh $DEVICE $ROMVERSION $CURRENTUSER"

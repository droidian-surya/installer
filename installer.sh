#!/bin/bash
# A bash based installer for droidian in the Poco X3/NFC
# Licensed under the GPLv2
clear
DROOTFS="$(curl -s https://api.github.com/repos/droidian-images/rootfs-api29gsi-all/releases | grep browser_download_url | grep droidian-rootfs-api29gsi-arm64 | grep nightly | cut -d : -f 2,3  | tr -d \" )"
DADAPTSCRIPT="https://surya.bardia.tech/adaptation-surya-script.zip"
DTWRP=https://mirror.bardia.tech/surya/twrp-latest.img
if [ "$DROOTFS" = "" ]; then
    echo "Servers are updating please try again later."
    exit
fi
if [ "$(arch)" = x86_64 ]; then
    ARIA2BIN="$(dirname "$0")/support/x86_64/aria2c --continue=true"
fi
if [ "$(arch)" = x86_64 ]; then
    ADBBIN="$(dirname "$0")"/support/x86_64/adb
    FASTBOOTBIN="$(dirname "$0")"/support/x86_64/fastboot
    ARIA2BIN="$(dirname "$0")/support/x86_64/aria2c --continue=true"
fi
echo -e "You need to flash the latest MIUI Android 10 firmware for this OS if you havent flashed yet do it now (https://xiaomifirmwareupdater.com/miui/surya/stable/V12.0.9.0.QJGMIXM/)"

echo -e "Boot into fastboot and plug-in your phone ( Power off the device and HardReset.info: press Volume Down + Power key for a short while when booted into fastboot press enter )"
read -r nothinglol
CODENAME="$(fastboot getvar product 3>&1 1>&2 2>&3 | grep product | awk '{ print $2 }')"
if [ "$CODENAME" = surya ]; then
    DBOOT="https://surya.bardia.tech/boot-surya.img"
    DDTBO="https://surya.bardia.tech/dtbo-surya.img"
    DVBMETA="https://surya.bardia.tech/vbmeta-surya.img"
fi
if [ "$CODENAME" = karna ]; then
    DBOOT="https://surya.bardia.tech/boot-karna.img"
    DDTBO="https://surya.bardia.tech/dtbo-karna.img"
    DVBMETA="https://surya.bardia.tech/vbmeta-karna.img"
fi
if [ -z "$XDG_CACHE_HOME" ]; then
    CACHE=$CACHE
else
    CACHE=$XDG_CACHE_HOME
fi
if [ -d "CACHE/droidian-surya" ]; then
    true
else
    mkdir -p $CACHE/droidian-surya
fi
$ADBBIN start-server
clear; echo; echo; echo; echo; echo; echo -e "Downloading TWRP"; echo -e "   [=                ]" # 15 spaces
$ARIA2BIN -o $CACHE/droidian-surya/twrp-latest.img $DTWRP -q || echo "Downloading TWRP failed please try again or try flashing manually"
clear; echo; echo; echo; echo; echo; echo -e "Installing TWRP"; echo -e "   [==               ]" # 15 spaces
$FASTBOOTBIN flash recovery $CACHE/droidian-surya/twrp-latest.img
clear; echo; echo; echo; echo; echo; echo -e "Erasing Userdata"; echo -e "   [====             ]" # 15 spaces
$FASTBOOTBIN format userdata
clear; echo; echo; echo; echo; echo; echo -e "Downloading BOOT"; echo -e "   [=====            ]" # 15 spaces
$ARIA2BIN -o $CACHE/droidian-surya/boot.img $DBOOT -q || echo "Downloading BOOT failed please try again or try flashing manually"
clear; echo; echo; echo; echo; echo; echo -e "Flashing BOOT"; echo -e "   [======           ]" # 15 spaces
$FASTBOOTBIN flash boot $CACHE/droidian-surya/boot.img
clear; echo; echo; echo; echo; echo; echo -e "Downloading DTBO"; echo -e "   [=======          ]" # 15 spaces
$ARIA2BIN -o $CACHE/droidian-surya/dtbo.img $DDTBO -q || echo "Downloading DTBO failed please try again or try flashing manually"
clear; echo; echo; echo; echo; echo; echo -e "Flashing DTBO"; echo -e "   [========         ]" # 15 spaces
$FASTBOOTBIN flash dtbo $CACHE/droidian-surya/dtbo.img
clear; echo; echo; echo; echo; echo; echo -e "Downloading VBMETA"; echo -e "   [=========         ]" # 15 spaces
$ARIA2BIN -o $CACHE/droidian-surya/vbmeta.img $DVBMETA -q || echo "Downloading VBMETA failed please try again or try flashing manually"
clear; echo; echo; echo; echo; echo; echo -e "Flashing VBMETA"; echo -e "   [==========       ]" # 15 spaces
$FASTBOOTBIN --disable-verity --disable-verification flash vbmeta $CACHE/droidian-surya/vbmeta.img
clear; echo; echo; echo; echo; echo; echo -e "Rebooting to recovery.."; echo -e "   [===========      ]" # 15 spaces
$FASTBOOTBIN reboot recovery
clear; echo; echo; echo; echo; echo; echo -e "Downloading ROOTFS"; echo -e "   [============     ]" # 15 spaces
$ARIA2BIN -o $CACHE/droidian-surya/rootfs.zip "$DROOTFS" -q || echo "Downloading ROOTFS failed please try again or try flashing manually"
clear; echo; echo; echo; echo; echo; echo -e "Pushing ROOTFS"; echo -e "   [=============    ]" # 15 spaces
$ADBBIN push $CACHE/droidian-surya/rootfs.zip /tmp/
clear; echo; echo; echo; echo; echo; echo -e "Downloading ADAPTATION"; echo -e "   [==============   ]" # 15 spaces
$ARIA2BIN -o $CACHE/droidian-surya/adapt.zip $DADAPTSCRIPT -q || echo "Downloading ADAPTATION failed please try again or try flashing manually"
clear; echo; echo; echo; echo; echo; echo -e "Pushing ADAPTATION"; echo -e "   [================ ]" # 15 spaces
$ADBBIN push $CACHE/droidian-surya/adaptation-surya-script.zip /tmp/
clear; echo; echo; echo; echo; echo; echo -e "Installing ROOTFS"; echo -e "   [================ ]" # 15 spaces
$ADBBIN shell "twrp install /tmp/rootfs.zip"
clear; echo; echo; echo; echo; echo; echo -e "Installing ADAPTATION"; echo -e "   [=================]" # 15 spaces
$ADBBIN shell "cd /tmp/ && unzip adaptation-surya-script.zip cd adaptation-surya-script && chmod +x install.sh && ./install.sh"
clear; echo; echo; echo; echo; echo; echo -e "Rebooting... :)"; echo -e "   [=================]" # 15 spaces
$ADBBIN reboot
while true; do
    read -p "Would you like to remove the cache directory used for the installation? (Y/n)" yn
    case $yn in
         [Yy]* ) REMOVE_CACHE=true && break;;
         [Nn]* ) REMOVE_CACHE=false && break;;
         * ) echo "Please answer Y(es) or N(o).";;
    esac
done
if [ "$REMOVE_CACHE" == "true" ]; then
    rm -rf $CACHE/droidian-surya
else
    echo "Cache directory is available at $CACHE/droidian-surya"
fi

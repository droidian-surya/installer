#!/bin/bash
# A bash based installer for droidian in the Poco X3/NFC
# Licensed under the GPLv2
clear
DROOTFS="$(curl -s https://api.github.com/repos/droidian-images/rootfs-api29gsi-all/releases | grep "browser_download_url" | grep droidian-rootfs-api29gsi-arm64 | grep nightly | cut -d : -f 2,3  | tr -d \" )"
DADAPTSCRIPT="https://surya.bardia.tech/adaptation-surya-script.zip"
DTWRP=https://mirror.bardia.tech/surya/twrp-latest.img
if [ "$DROOTFS" = "" ]; then
    echo "Please try again later"
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
echo -e "You need latest MIUI A10 for this ROM if you havent flashed it do it now"
echo -e "Boot into fastboot and plug-in your phone ( Enter when done )"
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
$ADBBIN start-server
clear; echo; echo; echo; echo; echo; echo -e "Downloading TWRP"; echo -e "   [=                ]" # 15 spaces
$ARIA2BIN -o "$(dirname "$0")"/cache/twrp-latest.img $DTWRP -q || echo "Downloading TWRP failed please try again or fix" 
clear; echo; echo; echo; echo; echo; echo -e "Installing TWRP"; echo -e "   [==               ]" # 15 spaces
$FASTBOOTBIN flash recovery "$(dirname "$0")"/cache/twrp-latest.img
clear; echo; echo; echo; echo; echo; echo -e "Erasing Userdata"; echo -e "   [====             ]" # 15 spaces
$FASTBOOTBIN format userdata
clear; echo; echo; echo; echo; echo; echo -e "Downloading BOOT"; echo -e "   [=====            ]" # 15 spaces
$ARIA2BIN -o "$(dirname "$0")"/cache/boot.img $DBOOT -q || echo "Downloading BOOT failed please try again or fix" 
clear; echo; echo; echo; echo; echo; echo -e "Flashing BOOT"; echo -e "   [======           ]" # 15 spaces
$FASTBOOTBIN flash boot "$(dirname "$0")"/cache/boot.img
clear; echo; echo; echo; echo; echo; echo -e "Downloading DTBO"; echo -e "   [=======          ]" # 15 spaces
$ARIA2BIN -o "$(dirname "$0")"/cache/dtbo.img $DDTBO -q || echo "Downloading DTBO failed please try again or fix" 
clear; echo; echo; echo; echo; echo; echo -e "Flashing DTBO"; echo -e "   [========         ]" # 15 spaces
$FASTBOOTBIN flash dtbo "$(dirname "$0")"/cache/dtbo.img
clear; echo; echo; echo; echo; echo; echo -e "Downloading VBMETA"; echo -e "   [=========         ]" # 15 spaces
$ARIA2BIN -o "$(dirname "$0")"/cache/vbmeta.img $DVBMETA -q || echo "Downloading VBMETA failed please try again or fix" 
clear; echo; echo; echo; echo; echo; echo -e "Flashing VBMETA"; echo -e "   [==========       ]" # 15 spaces
$FASTBOOTBIN --disable-verity --disable-verification flash vbmeta "$(dirname "$0")"/cache/vbmeta.img
clear; echo; echo; echo; echo; echo; echo -e "Rebooting to recovery.."; echo -e "   [===========      ]" # 15 spaces
$FASTBOOTBIN reboot recovery
clear; echo; echo; echo; echo; echo; echo -e "Downloading ROOTFS"; echo -e "   [============     ]" # 15 spaces
$ARIA2BIN -o "$(dirname "$0")"/cache/rootfs.zip "$DROOTFS" -q || echo "Downloading ROOTFS failed please try again or fix" 
clear; echo; echo; echo; echo; echo; echo -e "Pushing ROOTFS"; echo -e "   [=============    ]" # 15 spaces
$ADBBIN push "$(dirname "$0")"/cache/rootfs.zip /tmp/
clear; echo; echo; echo; echo; echo; echo -e "Downloading ADAPTATION"; echo -e "   [==============   ]" # 15 spaces
$ARIA2BIN -o "$(dirname "$0")"/cache/adapt.zip $DADAPTSCRIPT -q || echo "Downloading ADAPTATION failed please try again or fix" 
clear; echo; echo; echo; echo; echo; echo -e "Pushing ADAPTATION"; echo -e "   [================ ]" # 15 spaces
$ADBBIN push "$(dirname "$0")"/cache/adaptation-surya-script.zip /tmp/
clear; echo; echo; echo; echo; echo; echo -e "Installing ROOTFS"; echo -e "   [================ ]" # 15 spaces
$ADBBIN shell "twrp install /tmp/rootfs.zip"
clear; echo; echo; echo; echo; echo; echo -e "Installing ADAPTATION"; echo -e "   [=================]" # 15 spaces
$ADBBIN shell "cd /tmp/ && unzip adaptation-surya-script.zip cd adaptation-surya-script && chmod +x install.sh && ./install.sh"
clear; echo; echo; echo; echo; echo; echo -e "Rebooting... :)"; echo -e "   [=================]" # 15 spaces
$ADBBIN reboot
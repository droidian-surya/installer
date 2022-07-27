#!/bin/bash
# A bash based installer for droidian in the Poco X3/NFC
# Licensed under the GPLv2
clear
DROOTFS="https://github.com/droidian-images/rootfs-api29gsi-all/releases/download/nightly/droidian-rootfs-api29gsi-arm64_20220727.zip"
DADAPTSCRIPT="https://surya.bardia.tech/adaptation-surya-script.zip"
DTWRP=https://mirror.bardia.tech/surya/twrp-latest.img
echo -e "Is Your Device Surya or Karna? (S/K)"
read -r CODENAME
if [ "$CODENAME" = S ]; then
    DBOOT="https://surya.bardia.tech/boot-surya.img"
    DDTBO="https://surya.bardia.tech/dtbo-surya.img"
    DVBMETA="https://surya.bardia.tech/vbmeta-surya.img"
fi
if [ "$CODENAME" = s ]; then
    DBOOT="https://surya.bardia.tech/boot-surya.img"
    DDTBO="https://surya.bardia.tech/dtbo-surya.img"
    DVBMETA="https://surya.bardia.tech/vbmeta-surya.img"
fi
if [ "$CODENAME" = K ]; then
    DBOOT="https://surya.bardia.tech/boot-karna.img"
    DDTBO="https://surya.bardia.tech/dtbo-karna.img"
    DVBMETA="https://surya.bardia.tech/vbmeta-karna.img"
fi
if [ "$CODENAME" = k ]; then
    DBOOT="https://surya.bardia.tech/boot-surya.img"
    DDTBO="https://surya.bardia.tech/dtbo-karna.img"
    DVBMETA="https://surya.bardia.tech/vbmeta-karna.img"
fi
if [ "$(arch)" = x86_64 ]; then
    ARIA2BIN="$(dirname "$0")"/support/x86_64/aria2c
fi
if [ "$(arch)" = x86_64 ]; then
    ADBBIN="$(dirname "$0")"/support/x86_64/adb
fi
if [ "$(arch)" = x86_64 ]; then
    FASTBOOTBIN="$(dirname "$0")"/support/x86_64/fastboot
fi
echo -e "Please plug-in your phone ( Press Enter if done )"
$ADBBIN start-server
$ADBBIN reboot bootloader
clear; echo; echo; echo; echo; echo; echo -e "Downloading TWRP"; echo -e "   [=                ]" # 15 spaces
$ARIA2BIN -o "$(dirname "$0")"/cache/twrp-latest.img $DTWRP -q || echo "Downloading TWRP failed please try again or fix" && exit
clear; echo; echo; echo; echo; echo; echo -e "Installing TWRP"; echo -e "   [==               ]" # 15 spaces
$FASTBOOTBIN flash recovery "$(dirname "$0")"/cache/twrp-latest.img
clear; echo; echo; echo; echo; echo; echo -e "Erasing Userdata"; echo -e "   [====             ]" # 15 spaces
$FASTBOOTBIN format userdata
clear; echo; echo; echo; echo; echo; echo -e "Downloading BOOT"; echo -e "   [=====            ]" # 15 spaces
$ARIA2BIN -o "$(dirname "$0")"/cache/boot.img $DBOOT -q || echo "Downloading BOOT failed please try again or fix" && exit
clear; echo; echo; echo; echo; echo; echo -e "Flashing BOOT"; echo -e "   [======           ]" # 15 spaces
$FASTBOOTBIN flash boot "$(dirname "$0")"/cache/boot.img
clear; echo; echo; echo; echo; echo; echo -e "Downloading DTBO"; echo -e "   [=======          ]" # 15 spaces
$ARIA2BIN -o "$(dirname "$0")"/cache/dtbo.img $DDTBO -q || echo "Downloading DTBO failed please try again or fix" && exit
clear; echo; echo; echo; echo; echo; echo -e "Flashing DTBO"; echo -e "   [========         ]" # 15 spaces
$FASTBOOTBIN flash dtbo "$(dirname "$0")"/cache/dtbo.img
clear; echo; echo; echo; echo; echo; echo -e "Downloading VBMETA"; echo -e "   [=========         ]" # 15 spaces
$ARIA2BIN -o "$(dirname "$0")"/cache/vbmeta.img $DVBMETA -q || echo "Downloading VBMETA failed please try again or fix" && exit
clear; echo; echo; echo; echo; echo; echo -e "Flashing VBMETA"; echo -e "   [==========       ]" # 15 spaces
$FASTBOOTBIN --disable-verity --disable-verification flash vbmeta "$(dirname "$0")"/cache/vbmeta.img
clear; echo; echo; echo; echo; echo; echo -e "Rebooting to recovery.."; echo -e "   [===========      ]" # 15 spaces
$FASTBOOTBIN reboot recovery
clear; echo; echo; echo; echo; echo; echo -e "Downloading ROOTFS"; echo -e "   [============     ]" # 15 spaces
$ARIA2BIN -o "$(dirname "$0")"/cache/rootfs.zip $DROOTFS -q || echo "Downloading ROOTFS failed please try again or fix" && exit
clear; echo; echo; echo; echo; echo; echo -e "Pushing ROOTFS"; echo -e "   [=============    ]" # 15 spaces
$ADBBIN push "$(dirname "$0")"/cache/rootfs.zip /tmp/
clear; echo; echo; echo; echo; echo; echo -e "Downloading ADAPTATION"; echo -e "   [==============   ]" # 15 spaces
$ARIA2BIN -o "$(dirname "$0")"/cache/adapt.zip $DADAPTSCRIPT -q || echo "Downloading ADAPTATION failed please try again or fix" && exit
clear; echo; echo; echo; echo; echo; echo -e "Pushing ADAPTATION"; echo -e "   [================ ]" # 15 spaces
$ADBBIN push "$(dirname "$0")"/cache/adaptation-surya-script.zip /tmp/
clear; echo; echo; echo; echo; echo; echo -e "Installing ROOTFS"; echo -e "   [================ ]" # 15 spaces
$ADBBIN shell "twrp install /tmp/rootfs.zip"
clear; echo; echo; echo; echo; echo; echo -e "Installing ADAPTATION"; echo -e "   [=================]" # 15 spaces
$ADBBIN shell "cd /tmp/ && unzip adaptation-surya-script.zip cd adaptation-surya-script && chmod +x install.sh && ./install.sh"
clear; echo; echo; echo; echo; echo; echo -e "Rebooting... :)"; echo -e "   [=================]" # 15 spaces
$ADBBIN reboot
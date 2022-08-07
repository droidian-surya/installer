#!/bin/bash
# A bash based installer for droidian
# Licensed under the GPLv2

#shellcheck disable=SC1090
clear
if [ -d "$(dirname $0)/support/x86_64" ]; then 
    PATH="$PATH:$(realpath "$(dirname $0)"/support/x86_64)"
    source "$(dirname $0)"/support/lib/cacheinit
    source "$(dirname $0)"/support/lib/cacheprompt
    source "$(dirname $0)"/support/lib/device_config
    source "$(dirname $0)"/support/lib/device_run
    source "$(dirname $0)"/support/lib/echomenu
    source "$(dirname $0)"/support/lib/erasedataprompt
    source "$(dirname $0)"/support/lib/steps
    source "$(dirname $0)"/support/lib/verprompt
    else
    source /usr/lib/droidian-surya/cacheinit
    source /usr/lib/droidian-surya/cacheprompt
    source /usr/lib/droidian-surya/device_config
    source /usr/lib/droidian-surya/device_run
    source /usr/lib/droidian-surya/echomenu
    source /usr/lib/droidian-surya/erasedataprompt
    source /usr/lib/droidian-surya/steps
    source /usr/lib/droidian-surya/verprompt
fi
echo "Welcome to the Droidian Unofficial Installer"
cacheinit # works
eraseprompt # works
verprompt #
device_config # works
device_run # WIP
cacheprompt # works?
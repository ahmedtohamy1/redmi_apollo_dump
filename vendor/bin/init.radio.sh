#! /vendor/bin/sh

#
# Make modem config folder and copy firmware config to that folder for RIL
#
if [ -f /data/vendor/modem_config/ver_info.txt ]; then
    prev_version_info=`cat /data/vendor/modem_config/ver_info.txt`
else
    prev_version_info=""
fi

#
# Determine version information not all builds have ver_info set so use SLPI
#
if [ -f /vendor/firmware_mnt/verinfo/ver_info.txt ]; then
    cur_version_info=`cat /vendor/firmware_mnt/verinfo/ver_info.txt`
else
    cur_version_info=`grep -ao "OEM_IMAGE_VERSION_STRING[ -~]*" \
                        /vendor/firmware_mnt/image/slpi.b04 | \
                      sed -e s/OEM_IMAGE_VERSION_STRING=// -e s/\(.*\).//`
fi

if [ "$prev_version_info" != "$cur_version_info" ]; then
    # add W for group recursively before delete
    chmod g+w -R /data/vendor/modem_config/*
    rm -rf /data/vendor/modem_config/*
    # Set the version information
    echo "$cur_version_info" > /data/vendor/modem_config/ver_info.txt
    # preserve the read only mode for all subdir and files
    cp --preserve=m -dr /vendor/firmware_mnt/image/modem_pr/mcfg/configs/* /data/vendor/modem_config
    cp --preserve=m -d /vendor/firmware_mnt/image/modem_pr/mbn_ota.txt /data/vendor/modem_config/
    # the group must be root, otherwise this script could not add "W" for group recursively
    chown -hR radio.root /data/vendor/modem_config/*
fi
chmod g-w /data/vendor/modem_config
setprop ro.vendor.ril.mbn_copy_completed 1

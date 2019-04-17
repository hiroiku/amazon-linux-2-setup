#!/bin/sh

cd `dirname $0`

if [ ${EUID:-${UID}} != 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

echo
fdisk -l | grep /dev
echo

while true; do
    echo -n "Please input device name: "
    read DEVICE_NAME

    DEVICE_EXISTS=$(lsblk $DEVICE_NAME | grep disk)
    if [ -n "$DEVICE_NAME" ] && [ -n "$DEVICE_EXISTS" ]; then
        break
    fi
done

while true; do
    echo -n "Please input mount path: "
    read MOUNT_PATH

    if [ -n "$MOUNT_PATH" ]; then
        break
    fi
done

# Make file system
lsblk
mkfs -t ext4 $DEVICE_NAME

# Add fstab
UUID=$(blkid $DEVICE_NAME | grep -oP 'UUID="(.*?)"' | sed 's/"//g')
if ! grep -sq "$UUID" /etc/fstab; then
    echo $UUID $MOUNT_PATH ext4 defaults 0 2 >> /etc/fstab
fi

# Mount
mkdir -p $MOUNT_PATH
chmod 755 $MOUNT_PATH
mount -a
chmod 755 $MOUNT_PATH

# echo
df -hT

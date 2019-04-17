#!/bin/sh

cd `dirname $0`

if [ ${EUID:-${UID}} != 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

while true; do
    echo -n "Please input filesystem ID: "
    read FILESYSTEM_ID

    if [ -n "$FILESYSTEM_ID" ]; then
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

# Install
yum install -y amazon-efs-utils

# Add fstab
if ! grep -sq "$FILESYSTEM_ID:$MOUNT_PATH" /etc/fstab; then
    echo $FILESYSTEM_ID:$MOUNT_PATH $MOUNT_PATH efs defaults,_netdev 0 0 >> /etc/fstab
fi

# Mount
mkdir -p $MOUNT_PATH
chmod 755 $MOUNT_PATH
mount -a
chmod 755 $MOUNT_PATH

# echo
df -hT

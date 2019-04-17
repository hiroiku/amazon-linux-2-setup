#!/bin/sh

cd `dirname $0`

if [ ${EUID:-${UID}} != 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

while true; do
    echo -n "Please input the swapfile path: "
    read SWAP_PATH

    if [ -n "$SWAP_PATH" ]; then
        break
    fi
done

# Create mkswap.sh
ESCAPED_SWAP_PATH=`echo $SWAP_PATH | sed "s/\//\\\\\\\\\//g"`
sed -e "s/{SWAP_PATH}/$ESCAPED_SWAP_PATH/g" ../templates/usr/local/bin/mkswap.sh > /usr/local/bin/mkswap.sh
chmod +x /usr/local/bin/mkswap.sh

# Create mkswap.service
cp ../templates/etc/systemd/system/mkswap.service /etc/systemd/system/mkswap.service

# Enable swap
systemctl enable mkswap

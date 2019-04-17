#!/bin/sh

SWAP_PATH={SWAP_PATH}
MEM_SIZE=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')

if [ $MEM_SIZE -lt 2097152 ]; then
  SIZE=$((MEM_SIZE * 2))
elif [ $MEM_SIZE -lt 8388608 ]; then
  SIZE=${MEM_SIZE}
elif [ $MEM_SIZE -lt 67108864 ]; then
  SIZE=$((MEM_SIZE / 2))
else
  SIZE=4194304
fi

if [ -e $SWAP_PATH ] ; then
  SWAP_SIZE=$(du $SWAP_PATH | awk '{print $1}')
else
  SWAP_SIZE=0
fi

if [ $SIZE -ne $SWAP_SIZE ]; then
  # dd if=/dev/zero of=$SWAP_PATH count=$SIZE bs=1K
  # chmod 600 $SWAP_PATH
  mkswap $SWAP_PATH
  swapon $SWAP_PATH
else
  swapon $SWAP_PATH
fi

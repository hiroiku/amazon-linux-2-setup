#!/bin/sh

if [ ${EUID:-${UID}} != 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

while true; do
    echo -n "Please input the swapfile path: "
    read FILE_PATH

    if [ -n "$FILE_PATH" ]; then
        break
    fi
done

# Create mkswap.sh
cat > /usr/local/bin/mkswap.sh << EOF
#!/bin/bash
SWAPFILENAME=$FILE_PATH
MEMSIZE=\$(cat /proc/meminfo | grep MemTotal | awk '{print \$2}')

if [ \$MEMSIZE -lt 2097152 ]; then
  SIZE=\$((MEMSIZE * 2))
elif [ \$MEMSIZE -lt 8388608 ]; then
  SIZE=\${MEMSIZE}
elif [ \$MEMSIZE -lt 67108864 ]; then
  SIZE=\$((MEMSIZE / 2))
else
  SIZE=4194304
fi

if [ -e \$SWAPFILENAME ] ; then
  SWAPSIZE=\$(du \$SWAPFILENAME | awk '{print \$1}')
else
  SWAPSIZE=0
fi

if [ \$SIZE -ne \$SWAPSIZE ]; then
  dd if=/dev/zero of=\$SWAPFILENAME count=\$SIZE bs=1K && chmod 600 \$SWAPFILENAME && mkswap \$SWAPFILENAME && swapon \$SWAPFILENAME
else
  swapon \$SWAPFILENAME
fi
EOF
chmod +x /usr/local/bin/mkswap.sh

# Create mkswap.service
cat > /etc/systemd/system/mkswap.service << EOF
[Unit]
Description=Make swapfile and swapon on boot.
After=local-fs.target
RequiresMountsFor=/

[Service]
RemainAfterExit=true
Type=oneshot
ExecStart=/usr/local/bin/mkswap.sh

[Install]
WantedBy=local-fs.target
EOF

# Enable swap
systemctl enable mkswap

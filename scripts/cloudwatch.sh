#!/bin/sh

cd `dirname $0`

if [ ${EUID:-${UID}} != 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Install
cd ~
curl -O http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip
unzip -o CloudWatchMonitoringScripts-1.2.1.zip
rm -fr CloudWatchMonitoringScripts-1.2.1.zip
mv -f aws-scripts-mon/ /usr/local/bin/

yum install -y perl-Switch perl-DateTime perl-Sys-Syslog perl-LWP-Protocol-https perl-Digest-SHA.x86_64
yum install -y expect
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//')
expect -c "
spawn aws configure
expect {
    \"AWS Access Key ID\" {
        send \"\n\"
        exp_continue
    }
    \"AWS Secret Access Key\" {
        send \"\n\"
        exp_continue
    }
    \"Default region name\" {
        send \"$REGION\n\"
        exp_continue
    }
    \"Default output format\" {
        send \"\n\"
        exp_continue
    }
}
"

echo

while true; do
    echo -n "Please input mount paths to watch, spreated by spaces: "
    read MOUNT_PATHS

    if [ -n "$MOUNT_PATHS" ]; then
        break
    fi
done

echo $MOUNT_PATHS
MOUNT_PATHS=(`echo $MOUNT_PATHS`)

for MOUNT_PATH in ${MOUNT_PATHS[@]}; do
    DISK_PATHS=("${DISK_PATHS[@]}" "--disk-path=$MOUNT_PATH")
done

WATCH_COMMAND="/usr/local/bin/aws-scripts-mon/mon-put-instance-data.pl --mem-util --mem-used --mem-used-incl-cache-buff --mem-avail --swap-util --swap-used --disk-space-util --disk-space-used --disk-space-avail ${DISK_PATHS[@]}"

crontab -l; echo "*/5 * * * *  $WATCH_COMMAND --from-cron" | crontab -u ec2-user -
sudo -u ec2-user $WATCH_COMMAND

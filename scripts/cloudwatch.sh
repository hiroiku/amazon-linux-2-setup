#!/bin/sh

# Install
cd ~
curl -O http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip
unzip -o CloudWatchMonitoringScripts-1.2.1.zip
rm -f CloudWatchMonitoringScripts-1.2.1.zip
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

crontab -l; echo "*/5 * * * * /usr/local/bin/aws-scripts-mon/mon-put-instance-data.pl --from-cron --mem-util --mem-used --mem-used-incl-cache-buff --mem-avail --swap-util --swap-used --disk-path=/ --disk-space-util --disk-space-used --disk-space-avail" | crontab -u ec2-user -
sudo -u ec2-user /usr/local/bin/aws-scripts-mon/mon-put-instance-data.pl --mem-util --mem-used --mem-used-incl-cache-buff --mem-avail --swap-util --swap-used --disk-path=/ --disk-space-util --disk-space-used --disk-space-avail

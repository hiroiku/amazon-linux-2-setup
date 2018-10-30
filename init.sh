#!/bin/sh

if [ ${EUID:-${UID}} != 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# System
# --------------------------------
yum update -y

# ELB
# --------------------------------
while true; do
    echo -n "Do you want to assign EBS? [y/n]: "
    read EBS_ENABLED
    case $EBS_ENABLED in
        y) break;;
        n) break;;
        *) ;;
    esac
done

if [ "$EBS_ENABLED" = "y" ]; then
    SCRIPT="./scripts/elb.sh"
    "$SCRIPT"
fi

# EFS
# --------------------------------
while true; do
    echo -n "Do you want to assign EFS? [y/n]: "
    read EFS_ENABLED
    case $EFS_ENABLED in
        y) break;;
        n) break;;
        *) ;;
    esac
done

if [ "$EFS_ENABLED" = "y" ]; then
    SCRIPT="./scripts/efs.sh"
    "$SCRIPT"
fi

# Swap
# --------------------------------
while true; do
    echo -n "Would you like to create a swapfile? [y/n]: "
    read SWAP_ENABLED
    case $SWAP_ENABLED in
        y) break;;
        n) break;;
        *) ;;
    esac
done

if [ "$SWAP_ENABLED" = "y" ]; then
    SCRIPT="./scripts/swap.sh"
    "$SCRIPT"
fi

# CloudWatch
# --------------------------------
while true; do
    echo -n "Would you like to enable CloudWatch? [y/n]: "
    read CLOUDWATCH_ENABLED
    case $CLOUDWATCH_ENABLED in
        y) break;;
        n) break;;
        *) ;;
    esac
done

if [ "$CLOUDWATCH_ENABLED" = "y" ]; then
    SCRIPT="./scripts/cloudwatch.sh"
    "$SCRIPT"
fi

# PHP
# --------------------------------
while true; do
    echo -n "Do you want to install PHP? [y/n]: "
    read PHP_ENABLED
    case $PHP_ENABLED in
        y) break;;
        n) break;;
        *) ;;
    esac
done

if [ "$PHP_ENABLED" = "y" ]; then
    SCRIPT="./scripts/php.sh"
    "$SCRIPT"
fi

# Nginx
# --------------------------------
while true; do
    echo -n "Do you want to install Nginx? [y/n]: "
    read NGINX_ENABLED
    case $NGINX_ENABLED in
        y) break;;
        n) break;;
        *) ;;
    esac
done

if [ "$NGINX_ENABLED" = "y" ]; then
    SCRIPT="./scripts/nginx.sh"
    "$SCRIPT"
fi

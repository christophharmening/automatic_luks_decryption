#!/bin/bash

#set -x

# Script create the possibility to decrypt LUKS Drive automatic
# This Script works for LVM Based encrypted LUKS root filesystem with unencrypted /boot partition


# Write here the partition for /boot an /
#BOOTPART=/dev/sda1 # /boot partition
#ROOTPART=/dev/sda5 # / partition

# root user ?
if [ "$EUID" -ne 0 ];then
    echo "Please run this script as root"
    exit 1
fi

# set timestamp
TIME=$(date +%d%m%y_%T)

# Debug messages
error_found() {
  printf "[ERROR] $@ \n"
  exit 1
}
warning_found() {
  printf "[WARNING] $@ \n"
}


# Check if partitions are set
if [ -z $BOOTPART ]; then BOOTPART=$(mount | grep " /boot " | awk '{print $1}'); fi
if [ -z $ROOTPART ]; then ROOTPART=$(mount | grep  " / " | awk '{print $1}'); fi

# If a volume group is found
if echo $BOOTPART | grep mapper > /dev/null ; then error_found "mapper in bootpartition $BOOTPART found!" ; fi
if echo $ROOTPART | grep mapper > /dev/null ; then error_found "mapper in rootpartition $ROOTPART found!" ; fi

# Create a keyfile
if [ ! -f /boot/keyfile ]; then
  dd if=/dev/urandom of=/boot/keyfile bs=1024 count=4
  chmod 0400 /boot/keyfile
else
  warning_found "Keyfile /boot/keyfile found!"
fi

# Add Keyfile to LUKS setup
cryptsetup -v luksAddKey $ROOTPART /boot/keyfile

# Get UUID from /boot
BOOTUUID=$(ls -l /dev/disk/by-uuid | grep $(echo $BOOTPART | awk -F\/ '{print $NF}') | awk '{print $9}')
if [ -z $BOOTUUID ]; then error_found "No UUID for /boot partition found!" ; fi

# Backup old crypttab
if [ ! -f /etc/crypttab ]; then error_found "No crypttab found! Is LUKS encrytion configured?" ; fi
echo "Backup crypttab to /etc/crypttab_$TIME"
cp /etc/crypttab /etc/crypttab.backup_$TIME
PART=$(cat /etc/crypttab | awk '{print $1}')
UUID=$(cat /etc/crypttab | awk '{print $2}')
echo "Write new crypttab with $PART root=$UUID and boot=$BOOTUUID"
echo "$PART $UUID /dev/disk/by-uuid/$BOOTUUID:/keyfile luks,keyscript=/lib/cryptsetup/scripts/passdev" > /etc/crypttab

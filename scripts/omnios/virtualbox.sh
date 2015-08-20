#!/bin/bash

set -e
set -x

sudo /usr/sbin/lofiadm -a VBoxGuestAdditions.iso /dev/lofi/1
sudo /usr/sbin/mount -F hsfs /dev/lofi/1 /mnt/
yes | sudo /usr/sbin/pkgadd -d /mnt/VBoxSolarisAdditions.pkg all
sudo /usr/sbin/umount /mnt
sudo /usr/sbin/lofiadm -d /dev/lofi/1
rm -f ~/VBoxGuestAdditions.iso

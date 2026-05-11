#!/bin/bash
# 1-mount-microsd.sh — format and mount microSD at /mnt/microsd
#
# Usage:
#   sudo bash ./scripts/1-mount-microsd.sh

set -euo pipefail

# require sudo
(( EUID == 0 )) || { echo "ERROR: run with sudo" >&2; exit 1; }
# capture the original user (set by sudo); abort if missing so files don't end up root-owned
TARGET_USER="${SUDO_USER:?run via sudo, not as root directly}"

# abort if no SD card detected
if [ ! -b /dev/mmcblk1 ]; then
  echo "ERROR: no SD card detected at /dev/mmcblk1 — insert the card and retry."
  exit 1
fi

# format as ext4
sudo mkfs.ext4 -F /dev/mmcblk1

sudo mkdir -p /mnt/microsd

# add to fstab for auto-mount on boot
if ! grep -q '/mnt/microsd' /etc/fstab; then
  echo '/dev/mmcblk1 /mnt/microsd ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab
fi

sudo mount -a
sudo chown "$TARGET_USER:$TARGET_USER" /mnt/microsd
sudo -u "$TARGET_USER" mkdir -p /mnt/microsd/models  # model storage directory, owned by user

echo
df -h /mnt/microsd

#!/bin/bash
set -euo pipefail

BACKTITLE="AstrOS Linux - Installation"

# rootcheck
if [[ $EUID -ne 0 ]]; then
  whiptail --backtitle "$BACKTITLE" --msgbox "This script must be run as root." 0 0
  exit 1
fi

# disk selection
## build a whiptail menu list from available disks
DISK_ARGS=()
while read -r NAME SIZE MODEL; do
  DISK_ARGS+=("/dev/$NAME" "$SIZE  $MODEL")
done < <(lsblk -dn -o NAME,SIZE,MODEL -e 7,11)

if [[ ${#DISK_ARGS[@]} -eq 0 ]]; then
  whiptail --backtitle "$BACKTITLE" --msgbox "No eligible disks were found." 0 0
  exit 1
fi

if ! DISK=$(whiptail --backtitle "$BACKTITLE" --title "Select disk" --menu \
  "Choose the disk to install AstrOS Linux to." \
  0 0 0 "${DISK_ARGS[@]}" 3>&1 1>&2 2>&3); then
  exit 1
fi

# confirm wipe
if ! whiptail --backtitle "$BACKTITLE" --title "Confirm disk wipe" --yesno \
  "WARNING: This will ERASE ALL DATA on $DISK.\n\nThis action cannot be undone. Continue?" \
  0 0 --defaultno; then
  whiptail --backtitle "$BACKTITLE" --msgbox "Installation cancelled. No changes were made." 0 0
  exit 1
fi

# wipe + partition
wipefs -a "$DISK"
unzstd -c /images/AstrOS.raw.zst | dd of="$DISK" bs=4M conv=fsync status=progress

# reboot
whiptail --backtitle "$BACKTITLE" --msgbox "Installation complete." 0 0
reboot

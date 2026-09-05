#!/bin/bash
set -euo pipefail

BACKTITLE="AstrOS - Installation"

# rootcheck
if [[ $EUID -ne 0 ]]; then
  whiptail --backtitle "$BACKTITLE" --msgbox "This script must be run as root." 0 0
  exit 1
fi

# check for tpm2
if ! systemd-analyze has-tpm2 --quiet; then
  if ! whiptail --backtitle "$BACKTITLE" --title "No usable TPM2" --yesno \
    "No usable TPM2 device was found.\n\nAstrOS encrypts the root partition against the TPM2 and requires one. Continuing will most likely result in a system that does not boot.\n\nContinue anyway?" \
    0 0 --defaultno; then
    whiptail --backtitle "$BACKTITLE" --msgbox "Installation cancelled. No changes were made." 0 0
    exit 1
  fi
fi

# check for the image
IMAGE=/images/AstrOS.raw.zst
if [[ ! -r $IMAGE ]]; then
  whiptail --backtitle "$BACKTITLE" --msgbox "Installation image not found: $IMAGE" 0 0
  exit 1
fi
if [[ ! -r $IMAGE.sha256 ]]; then
  whiptail --backtitle "$BACKTITLE" --msgbox "Checksum file not found: $IMAGE.sha256" 0 0
  exit 1
fi

# verify the image
if whiptail --backtitle "$BACKTITLE" --title "Verify image" --yesno \
  "Verify the integrity of the installation image?\n\nThis may take a moment, but it detects a corrupt image before anything is written to disk." \
  0 0; then
  whiptail --backtitle "$BACKTITLE" --title "Verifying image" --infobox \
    "Verifying the integrity of the installation image.\n\nThis may take a moment." 0 0
  if ! (cd "$(dirname "$IMAGE")" && sha256sum --quiet -c "$(basename "$IMAGE").sha256"); then
    whiptail --backtitle "$BACKTITLE" --title "Checksum mismatch" --msgbox \
      "The installation image failed verification.\n\nInstallation cancelled. No changes were made." \
      0 0
    exit 1
  fi
fi

# disk selection
# determine the live usb disk
LIVE_DISK=$(lsblk -no PKNAME "$(findmnt -no SOURCE --target /images)" 2>/dev/null | head -n1)

# create the disk list while excluding the live disk
DISK_ARGS=()
while read -r NAME SIZE MODEL; do
  [[ $NAME == "$LIVE_DISK" ]] && continue
  DISK_ARGS+=("/dev/$NAME" "$SIZE  ${MODEL:-Unknown}")
done < <(lsblk -dn -o NAME,SIZE,MODEL -e 7,11)

if [[ ${#DISK_ARGS[@]} -eq 0 ]]; then
  whiptail --backtitle "$BACKTITLE" --msgbox "No eligible disks were found." 0 0
  exit 1
fi

if ! DISK=$(whiptail --backtitle "$BACKTITLE" --title "Select disk" --menu \
  "Choose the disk to install AstrOS to." \
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

# wipe & dd the image to the selected disk
wipefs -a "$DISK"
unzstd -c "$IMAGE" | dd of="$DISK" bs=4M conv=fsync status=progress

# reboot
whiptail --backtitle "$BACKTITLE" --msgbox "Installation complete. Reboot now" 0 0
reboot

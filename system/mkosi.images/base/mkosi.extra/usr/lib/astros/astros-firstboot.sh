#!/bin/bash
set -euo pipefail

# branding
BACKTITLE="AstrOS Linux - First Boot Setup"

read -r -d '' WORDMARK <<'EOF' || true
==================================
    _        _         ___  ____
   / \   ___| |_ _ __ / _ \/ ___|
  / _ \ / __| __| '__| | | \___ \
 / ___ \\__ \ |_| |  | |_| |___) |
/_/   \_\___/\__|_|   \___/|____/
==================================
EOF

# rootcheck
if [[ $EUID -ne 0 ]]; then
  whiptail --backtitle "$BACKTITLE" --msgbox "This script must be run as root." 0 0
  exit 1
fi

# keymap
## create list
mapfile -t KEYMAP_LIST < <(localectl list-keymaps)
KEYMAP_MENU=()
for km in "${KEYMAP_LIST[@]}"; do
  KEYMAP_MENU+=("$km" "")
done

## show list and set keymap
KEYMAP=""
while true; do
  KEYMAP=$(whiptail --backtitle "$BACKTITLE" --title "Keymap" --menu \
    "Select a console keymap." 0 0 0 \
    "${KEYMAP_MENU[@]}" 3>&1 1>&2 2>&3) || KEYMAP=""
  if [[ -z "$KEYMAP" ]]; then
    whiptail --backtitle "$BACKTITLE" --title "Keymap" --msgbox \
      "A keymap selection is required.\nPlease try again." 0 0
    continue
  fi
  localectl set-keymap "$KEYMAP"
  break
done

# user
## username
USERNAME=""
while true; do
  USERNAME=$(whiptail --backtitle "$BACKTITLE" --title "Create user" --inputbox \
    "Enter the username to create." 0 0 3>&1 1>&2 2>&3) || USERNAME=""

  if [[ -z "$USERNAME" ]]; then
    whiptail --backtitle "$BACKTITLE" --msgbox "A username is required. User creation cannot be skipped." 0 0
    continue
  fi
  if ! [[ "$USERNAME" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    whiptail --backtitle "$BACKTITLE" --msgbox \
      "Invalid username.\nUse lowercase letters, digits, '-' or '_', starting with a letter or '_'." 0 0
    continue
  fi
  if id "$USERNAME" &>/dev/null; then
    whiptail --backtitle "$BACKTITLE" --msgbox "User '$USERNAME' already exists. Choose another name." 0 0
    continue
  fi
  break
done

## password
PASS1=""
PASS2=""
while true; do
  PASS1=$(whiptail --backtitle "$BACKTITLE" --title "Password" --passwordbox \
    "Enter password for '$USERNAME':" 0 0 3>&1 1>&2 2>&3) || PASS1=""
  PASS2=$(whiptail --backtitle "$BACKTITLE" --title "Password" --passwordbox \
    "Confirm password for '$USERNAME':" 0 0 3>&1 1>&2 2>&3) || PASS2=""

  if [[ -z "$PASS1" ]]; then
    whiptail --backtitle "$BACKTITLE" --msgbox "Password cannot be empty." 0 0
    continue
  fi
  if [[ "$PASS1" != "$PASS2" ]]; then
    whiptail --backtitle "$BACKTITLE" --msgbox "Passwords do not match. Try again." 0 0
    continue
  fi
  break
done

## apply
useradd -m "$USERNAME"
usermod -aG wheel "$USERNAME"
echo "$USERNAME:$PASS1" | chpasswd

# luks recovery key
## enroll a recovery key, unlocked via the already-enrolled TPM2 device
if RECOVERY_KEY=$(systemd-cryptenroll --recovery-key --unlock-tpm2-device=auto \
  /dev/disk/by-label/luks-AstrOS-root 2>/dev/null); then

  ## build the message: a note, the QR code, then the key in plain text
  QR=$(qrencode -t UTF8 "$RECOVERY_KEY")
  MESSAGE="A recovery key for the encrypted root disk has been enrolled.

Save it somewhere safe and offline. You will need it to unlock
this system if the automatic TPM2 unlock ever fails.

${QR}

${RECOVERY_KEY}"

  whiptail --backtitle "$BACKTITLE" --title "Recovery key" --msgbox \
    "$MESSAGE" 0 0
else
  whiptail --backtitle "$BACKTITLE" --msgbox \
    "Failed to enroll a recovery key for the encrypted disk. Please do it manually." 0 0
fi

# done
whiptail --backtitle "$BACKTITLE" --title "Setup complete" --msgbox \
  "$WORDMARK

Setup is complete. Welcome aboard, $USERNAME.

Documentation   https://docs.astros-linux.org

Update with 'updatectl update --reboot'

Optional features as well as nvidia drivers ship as system extensions:

  updatectl features        #show their current state
  updatectl enable --now    #enable nvidia drivers (reboot required to apply)

Without --now a feature only arrives with the next time running updatectl update." 0 0

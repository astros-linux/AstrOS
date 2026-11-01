#!/bin/bash
# enroll recovery key for fresh instalsl
set -euo pipefail

DEV=/dev/disk/by-designator/root-luks

udevadm wait --timeout=30 "$DEV"

# exit if there already is a recovery key
[[ $(systemd-cryptenroll "$DEV") == *recovery* ]] && exit 0

# enroll
KEY=$(systemd-cryptenroll --recovery-key --unlock-tpm2-device=auto "$DEV")

# write to /run so it can be displayed in first-boot
umask 077
printf '%s' "$KEY" >/run/distro-recovery-key

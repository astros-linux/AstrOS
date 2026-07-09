#!/bin/bash
set -euo pipefail

# network check
if ! curl -fsS --max-time 5 https://dl.flathub.org >/dev/null; then
  echo "No network available, skipping Flathub setup" >&2
  exit 1
fi

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak update --appstream

# don't run again on future boots
systemctl disable astros-flathub-fix.service

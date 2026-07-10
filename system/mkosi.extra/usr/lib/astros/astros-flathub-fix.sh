#!/bin/bash
set -euo pipefail

# flathub repo check
if ! curl -fsS --max-time 5 https://dl.flathub.org >/dev/null; then
  echo "Can't reach the flathub repos, skipping Flathub setup" >&2
  exit 1
fi

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak update --appstream

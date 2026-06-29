# AstrOS

[![status-badge](https://ci.astros-linux.org/api/badges/3/status.svg?events=push%2Ccron%2Cmanual)](https://ci.astros-linux.org/repos/3)

> [!CAUTION]
> highly unstable for now

[Download](https://dl.astros-linux.org/latest.raw)

I recommend [caligula](https://github.com/ifd3f/caligula) for writing the .raw image to a USB stick

## Install
Boot the live profile from the USB stick

Wipe the disk that you want to use for the installation: `wipefs -a /dev/sdX`

Run `systemd-repart --dry-run=no --empty=force --defer-partitions=root /dev/sdX`

Reboot and remove the USB stick

There's no user creation prompt yet. Open a tty with `ctrl` `alt` `F2`, login in as root and run: `useradd -m $your-name && usermod -aG wheel $your-name && passwd $your-name`. Login to your user and run `systemctl --user preset-all` .

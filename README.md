# AstrOS

> [!CAUTION]
> highly unstable for now

[Download](https://dl.astros-linux.org/latest.raw)

## Install
Boot the live profile

run `systemd-repart --dry-run=no --empty=force --defer-partitions=root /dev/<drive>`

There isn't a user creation yet. Open a tty with `ctrl` `alt` `F2`, login in as root and run: `useradd -m $your-name && usermod -aG wheel $your-name && passwd $your-name`. Login to your user and run `systemctl --user preset-all` .

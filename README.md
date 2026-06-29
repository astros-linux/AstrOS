# AstrOS

[![status-badge](https://ci.astros-linux.org/api/badges/3/status.svg?events=push%2Ccron%2Cmanual)](https://ci.astros-linux.org/repos/3)

**AstrOS** is an immutable, secure-by-default Linux distribution built on **Arch Linux**, **ParticleOS** and the **COSMIC** desktop.

> [!CAUTION]
> AstrOS is in **early development and highly unstable**. Expect breaking changes, missing features, and rough edges. Don't run it on a machine you depend on.

---

## Highlights

- **Immutable `/usr`** - the system partition is a signed read-only dm-verity image, leading to an immutable base that can't be altered.
- **A/B updates** - `systemd-sysupdate` fetches and applies signed image updates atomically, with the previous version kept for rollback.
- **Verified boot** - Unified Kernel Images are signed and measured, sealed against your TPM chip (PCR11); Secure Boot is supported.
- **Full-disk encryption** - the root partition (btrfs, holding `/home` and `/var`) is encrypted and unlocked automatically via TPM2.
- **COSMIC desktop** - the modern Rust-based desktop from System76, tightly integrated.
- **Containers ready** - Install GUI-Apps using `flatpak` and use `distrobox` for running terminal or non flatpak supported software.

---

## Requirements

- **x86-64** machine with **UEFI** firmware
- A **TPM 2.0** module
- 30GB disk space (both `/usr` partitions need at least 5GB)
- USB stick for installation

## Download

Grab the latest image:

[AstrOS_latest_x86-64.raw](https://dl.astros-linux.org/AstrOS_latest_x86-64.raw)

Write it to a USB stick. We recommend [caligula](https://github.com/ifd3f/caligula):

```sh
caligula burn AstrOS_latest_x86-64.raw
```

Any tool that writes a raw image (e.g. `dd`) works too.

## Install

> [!WARNING]
> The installer **erases the target disk**. Double-check the device name (`lsblk`) before running these commands.

1. Boot the live profile from the USB stick.

2. Wipe the disk you want to install to:

   ```sh
   wipefs -a /dev/sdX
   ```

3. Copy the system over:

   ```sh
   systemd-repart --dry-run=no --empty=force --defer-partitions=root /dev/sdX
   ```

4. Reboot and remove the USB stick.

### First boot

There's no automatic user-creation tool implemented yet, so create your account manually:

1. Switch to a TTY with <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>F2</kbd> and log in as `root`.

2. Create your user and grant admin rights:

   ```sh
   useradd -m yourname
   usermod -aG wheel yourname
   passwd yourname
   ```

3. Log in as your new user and enable the user-services:

   ```sh
   systemctl --user preset-all
   ```

Then restart the COSMIC session.

## Updating

AstrOS uses systemd-sysupdate. Use [updatectl](https://man.archlinux.org/man/updatectl.1) to update your system:

```sh
updatectl update
```

Use `updatectl vacuum` in case of the update failing because of previously unfinished updates.

---

## Building from source

AstrOS is built with [mkosi](https://github.com/systemd/mkosi).

```sh
git clone https://github.com/linux-universe/AstrOS
cd AstrOS
mkosi genkey # You'll need your own keys, or AstrOS will fail to build.
mkosi -f -B # This builds to `mkosi.output/`
```

## Credits & License

AstrOS is licensed under the **GNU General Public License v3** - see [`LICENSE`](./LICENSE).

The system's architecture and build configuration are highly inspired from **[ParticleOS](https://github.com/systemd/particleos)** by systemd, Thanks!

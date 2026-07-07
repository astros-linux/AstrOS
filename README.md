<p align="left">
  <img src="./brand/logo/logo.svg" width="50%"/>
</p>

[![status-badge](https://ci.astros-linux.org/api/badges/4/status.svg?events=push%2Ccron%2Cmanual)](https://ci.astros-linux.org/repos/4)

[![Reddit](https://img.shields.io/badge/Reddit-FF4500?style=for-the-badge&logo=reddit&logoColor=white)](https://www.reddit.com/r/AstrOS_Linux)

**AstrOS** is an immutable, secure-by-default Linux distribution built on **Arch Linux** and the **COSMIC** desktop.

> [!CAUTION]
> AstrOS is **pre-alpha software**.
>
> Expect breaking changes, missing features, and rough edges. Don't run it on a machine you depend on.

---

## Highlights

- **Immutable `/usr`** - the system partition is a signed read-only dm-verity image, leading to an immutable base that can't be altered.
- **A/B updates** - `systemd-sysupdate` fetches and applies signed image updates atomically, with the previous version kept for rollback.
- **Verified boot** - Unified Kernel Images are signed and measured, sealed against your TPM chip (PCR11); Secure Boot is supported.
- **Full-disk encryption** - the root partition (btrfs, holding `/home` and `/var`) is encrypted and unlocked automatically via TPM2.
- **COSMIC desktop** - the modern Rust-based desktop from System76, tightly integrated.
- **Container ready** - Install GUI-Apps using `flatpak` and use `distrobox` for running terminal or non flatpak supported software.

---

## Requirements

- **x86-64** machine with **UEFI** firmware
- A **TPM 2.0** module
- 30GB disk space (both `/usr` partitions need at least 5GB)
- 8GB USB stick for installation

## Download

Grab the latest image:

[AstrOS-installer_latest_x86-64.raw.zst](https://dl.astros-linux.org/AstrOS-installer_latest_x86-64.raw.zst)

[SHA256SUMS](https://dl.astros-linux.org/SHA256SUMS)

Write it to a USB stick. We recommend [caligula](https://github.com/ifd3f/caligula):

```sh
caligula burn AstrOS-installer_latest_x86-64.raw.zst
```

Any tool that writes a raw image (e.g. `dd`) works too.

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

The repart / sysupdate configuration are highly inspired from **[ParticleOS](https://github.com/systemd/particleos)** by systemd, Thanks!

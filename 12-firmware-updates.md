## sysupgrade (OTA)

If your camera has internet access, the fastest way to update is `sysupgrade`. It downloads and flashes a full firmware image directly from GitHub.

**Full upgrade from GitHub:**

```sh
sysupgrade -f
```

> **Warning:** `sysupgrade -f` performs a **full flash** -- it overwrites the data partition and **resets the U-Boot environment** (WiFi credentials, root password). You will need to reconfigure the camera after upgrading.

**Flashing a local file:**

```sh
sysupgrade /mnt/mmcblk0p1/autoupdate-full.bin
```

**Flashing from a URL:**

```sh
sysupgrade http://example.com/firmware.bin
```

On the ciao (stable) branch, `sysupgrade -f` now pulls from the ciao branch directly, so you stay on stable when updating.

Master branch builds now publish to their own dated release tags (`master-YYYY-MM-DD`) instead of sharing the generic `latest` tag with stable. This means `sysupgrade -f` on a master-branch camera pulls master firmware, and stable cameras are no longer accidentally served a master build.

Recent ciao builds add selective partition flashing and config backup/restore to sysupgrade, but a full upgrade still resets the environment.

Recent builds also improve sysupgrade reliability: it now takes over the watchdog (instead of just disarming it) to ensure the camera reboots cleanly after flashing, and suppresses noisy `dd` stderr output during the flash process for cleaner logs.

Recent ciao builds fix a segfault in sysupgrade that occurred when flashing the data partition after the rootfs during a full upgrade. The U-Boot autoupdate-full.bin SD card flashing path also received a reliability fix. During the reboot sequence after flashing, sysupgrade now runs from a tmpfs copy of busybox, so the flash and reboot no longer depend on a rootfs being unmounted underneath them.

Another ciao fix prevents partition corruption on **old flash layouts**: the 'upgrade' partition is a virtual partition that overlaps kernel/rootfs/extras, and the full-flash loop used to erase and re-flash over the partitions it had just written. The virtual partition is now skipped, matching the other layout calculations.

Latest builds fix full upgrades **across partition layout changes**: the flash loop now writes each running MTD device the image bytes at the same absolute offsets (32K blocks, byte-addressing fallback), so the image is copied byte-for-byte regardless of how the image itself is partitioned. Previously, non-64K-aligned layouts (e.g. a 32K env partition) were silently mis-sliced, which could leave U-Boot with no valid environment and a dead boot after reboot.

## SD Card Update

The most reliable update method, especially for cameras with unreliable WiFi:

1. Download the firmware `.bin` for your camera from [thingino.com](https://thingino.com) or build it with the [Image Builder](https://image-builder.thingino.com/)
2. Copy it to a FAT32 SD card as `autoupdate-full.bin`
3. Insert the SD card and reboot the camera
4. The camera flashes automatically on boot

> **Important:** The `autoupdate-full.bin` method only works when **Thingino is already installed** -- it is processed by Thingino's U-Boot. It will not work on factory/stock firmware.

> **SD card tip:** Use a 2GB--8GB card. Some 16GB and 32GB cards may not be recognized in U-Boot's 1-bit MMC mode, particularly on T23N cameras.

## Web UI OTA

The Web UI upgrade page (tool-upgrade) is **not available** in standard production builds. It only appears when developer packages are enabled at build time (`BR2_THINGINO_DEV_PACKAGES=y`). For normal users, use `sysupgrade` or the SD card method.

## Checking Your Current Version

```sh
cat /etc/os-release
```

## Can't Find OTA in the Web UI?

OTA is not in the Tools menu for production builds. If you need to upgrade and do not have SSH access, use the SD card method above.

---

<- [Previous: System Configuration](11-system-config.md) | [Next: Troubleshooting](13-troubleshooting.md) ->

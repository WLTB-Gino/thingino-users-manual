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

Recent ciao builds add selective partition flashing and config backup/restore to sysupgrade, but a full upgrade still resets the environment.

Recent builds also improve sysupgrade reliability: it now takes over the watchdog (instead of just disarming it) to ensure the camera reboots cleanly after flashing, and suppresses noisy `dd` stderr output during the flash process for cleaner logs.

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

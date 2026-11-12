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

**Which branch you get:** `sysupgrade -f` pulls from the branch your camera's build tracks. A ciao (stable) camera pulls ciao firmware and stays on stable. Master-branch builds publish to their own dated release tags (`master-YYYY-MM-DD`) instead of the generic `latest` tag, so a master camera pulls master firmware and stable cameras are never served a master build.

sysupgrade supports selective partition flashing and config backup/restore alongside full upgrades; a full upgrade still resets the environment.

**Reliability behavior:** during flashing, sysupgrade takes over the hardware watchdog (instead of just disarming it) to ensure the camera reboots cleanly even if flashing stalls, and keeps `dd` output quiet for cleaner logs. The reboot sequence after flashing runs from a tmpfs copy of busybox, so the flash and reboot do not depend on a rootfs being unmounted underneath them.

**Partition layout:** the flash loop writes each running MTD device the image bytes at the same absolute offsets (32K blocks, with a byte-addressing fallback), so the image is copied byte-for-byte regardless of how the image itself is partitioned. The virtual `upgrade` partition is skipped, since it overlaps kernel/rootfs/extras. When upgrading, sysupgrade copies the partition layout from `/proc/cmdline` into the U-Boot environment if the environment has no `mtdparts` variable (for example after an env reset or a full-chip flash), and `flash-ota` (`make ota-upgrade`) falls back to reading the layout from `/proc/cmdline` -- what the running system actually booted with. If an older build aborts with "ERROR: cannot read current mtdparts", update to a current build or seed the variable manually (`fw_setenv mtdparts '<layout from /proc/cmdline, without the mtdparts= prefix>'`) and re-run.

**Oversize guard:** a flash is rejected *before* erasing anything if the image is bigger than the sum of the camera's real partitions, and `make ota` runs the same preflight checks at build time (kernel, data, bootloader slot, and total image size against the layout). An oversized build fails cleanly instead of leaving the camera with a zero-byte data partition. Nothing to configure; if you ever see the refusal, your build config overflows the camera's flash chip.

**Rootfs-only flashing:** `sysupgrade -r` flashes only the rootfs partition and requires a current build -- older builds could compute a zero rootfs size and erase the rootfs before aborting, leaving the camera unbootable. A full image (`sysupgrade -f` or a full `.bin`) does not run this code path. Note `make ota-rootfs` flashes without a config backup, so settings reset; prefer `make ota-upgrade IP=<camera>` for rootfs+data flashing from your build host.

**RAM:** a full-image OTA needs only the firmware size plus about 2 MB of headroom in free `/tmp` (RAM), so it works on low-RAM cameras (64 MB and less) with a storage card mounted.

**Config backup:** full upgrades snapshot your selected config files to the backup partition *before* flashing and skip that partition during the full-chip flash, so the snapshot survives; the payload is compressed with gzip when available. Run `cfg-backup restore` after the reboot to put the files back, or let the automatic restore handle it: a one-time `S37cfg-autorestore` init script runs at first boot after an upgrade, restores your files if a valid backup snapshot is present, and reboots once into the restored config. On a fresh install (no backup) it quietly removes itself; if the restore fails, it stays and retries on the next boot. The restore runs before the network comes up, but that is fine -- it only touches local files, no network needed.

The default backup list includes `/etc/thingino.json`, TIMPS streamer settings (`/etc/timps.conf`), and ONVIF settings (`/etc/onvif.json`); the backup list is the same on master and ciao, and on ciao the camera **name and raptor.conf** (`/etc/raptor.conf`) are preserved across a full upgrade alongside the rest. See `/etc/cfg-backup.list` for the full list and the "You can add more paths" section at the bottom for adding your own.

**Config file location:** the camera's config lives at `/etc/thingino.json`. If a script on your build references `/dev/thingino.json`, update to a current build -- configs in `/dev` did not survive a reboot.

## SD Card Update

The most reliable update method, especially for cameras with unreliable WiFi:

1. Download the firmware `.bin` for your camera from [thingino.com](https://thingino.com) or build it with the [Image Builder](https://image-builder.thingino.com/)
2. Copy it to a FAT32 SD card (MBR partition table) as `autoupdate-full.bin`
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

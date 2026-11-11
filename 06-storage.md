## SD Card

SD cards are mounted automatically at `/mnt/mmcblk0p1` in **async** mode, with a global dirty-page writeback bound. Sustained recording does not stall on every write to slow cards, which avoids periodic freezes and UI sluggishness on single-core cameras. Reliability is unaffected: diagnostics and recorder flows sync explicitly. A power cut can lose the last seconds of buffered writes (as with any async removable-media mount), but the filesystem itself is safe.

Format as FAT32 for best compatibility. Note that ext4 support is **not enabled by default** -- it requires enabling `BR2_PACKAGE_THINGINO_KOPT_EXTFS` in the build config. exFAT is supported via the `exfat-nofuse` kernel module and is the Web UI formatter's default. The exFAT module is preloaded at boot, so hot-inserted exFAT cards mount immediately: the card automounter only tries filesystems already loaded into the kernel. If an exFAT card never appears in `/mnt` on an older build, update the firmware (or format FAT32 as a workaround).

### SD Card Tips

- Use a 2GB--8GB card for best compatibility. Some 16GB and 32GB cards may not be recognized in U-Boot's 1-bit MMC mode, particularly on T23N cameras.
- Card detected but never shows up as `/dev/mmcblk0`? Builds that advertise only a narrow 3.2--3.4 V microSD/SDIO voltage window on T31 cameras let some cards fail voltage negotiation during enumeration, so the card never appears. Firmware advertising the full 2.7--3.6 V range initializes these cards normally. If a card works in other devices but never mounts on a T31 camera, update the firmware first.

### SD Card on T40/T41 (XBurst2)

SD card support on XBurst2 SoCs (T40/T41) works via the MSC controller. Cameras that declare SD card support in their profile (three XBurst2 profiles do) get the driver and automatic mounting.

## Motion Recording Recovery

After an unclean stop -- a crash, a power cut, or a watchdog restart -- the boot script clears stale recorder state, so if **Motion recording** is enabled it resumes automatically once the camera comes back. No action is needed.

## NFS Network Storage

Thingino supports NFS v2/v3 (not v4). NFS storage is **opt-in**: the share is not mounted at boot unless enabled. Configure it with the nested `nfs` object:

```sh
jct /etc/thingino.json set nfs.enabled true
jct /etc/thingino.json set nfs.share "server:/path/to/share"
```

The `S43mounts` init script mounts the share at `/mnt/nfs` on boot (using `-o nolock`). Verify with `mount | grep nfs`. Configurations still carrying the old top-level `nfs_share` key keep working. With `nfs.enabled` false the boot scripts simply skip the mount (the init script logs a notice instead of failing silently). To keep the configured address but mount right now, run `S43mounts force` -- it flips `nfs.enabled` to true and mounts immediately. The share value is redacted from diagnostics reports. Full setup notes: `docs/thingino/nfs-share.md` in the firmware tree.

The mount is **hard** (`hard,timeo=30,retrans=2`): if the NFS server stalls or disappears, writes block instead of silently losing data. Check `mount | grep nfs` if a stuck write ever freezes the camera -- that is the trade-off.

Recordings that lost their MP4 init segment (the `ftyp`+`moov` bytes a stalled write swallowed) can be repaired with `scripts/recover-nfs-recordings.py` from the firmware tree: it detects prudynt-t recordings with a missing init segment, copies it from a healthy recording of the same camera and stream settings (auto-detected, or `--donor FILE`), and writes `<name>.recovered.mp4` beside each damaged file. Originals are never modified, so it is safe to re-run. Stop the recording first -- the segment currently being written gets recovered half-finished.

Boot-time NFS mounts work reliably even when the NFS server is specified by **hostname**: the mount helper passes the bare hostname (not `server:/path`) to the kernel's route lookup.

### Media File Permissions

Snapshots and clips published by the notification system to storage (SD card or NFS share) are written world-readable (mode 644). Files saved by older builds keep their restrictive permissions -- a one-time `chmod 644` on the share fixes those.

## Filesystem Overlay

Thingino uses OverlayFS to provide a writable layer over the read-only root filesystem:

- **Lower layer** -- Read-only rootfs on the flash partition
- **Upper layer** -- Writable JFFS2 partition (`data.jffs2`)

Changes to configuration files persist across reboots. The overlay partition is limited in size -- use SD card or NFS for large files.

---

<- [Previous: Streaming and Video](05-streaming.md) | [Next: Night Vision and Lighting](07-night-vision.md) ->

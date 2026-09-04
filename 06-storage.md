## SD Card

SD cards are mounted automatically at `/mnt/mmcblk0p1`, **async** on both ciao (since 2026-08-25) and master (since 2026-09-03, PR #1535), with a global dirty-page writeback bound. Sustained recording no longer stalls on every write to slow cards -- a long-standing source of periodic freezes and UI sluggishness on single-core cameras. Reliability is unaffected: diagnostics and recorder flows sync explicitly. A power cut can lose the last seconds of buffered writes (as with any async removable-media mount), but the filesystem itself is safe.

Format as FAT32 for best compatibility. Note that ext4 support is **not enabled by default** -- it requires enabling `BR2_PACKAGE_THINGINO_KOPT_EXTFS` in the build config. exFAT may also require additional kernel options.

### SD Card Tips

- Use a 2GB--8GB card for best compatibility. Some 16GB and 32GB cards may not be recognized in U-Boot's 1-bit MMC mode, particularly on T23N cameras.
- To trigger a diagnostics report via SD card, create a file named `.diag` in the root of a blank SD card and insert it into the running camera.

### SD Card on T40/T41 (XBurst2)

Recent master and ciao builds add SD card support on XBurst2 SoCs (T40/T41) via the MSC controller. Cameras that declare SD card support in their profile (three XBurst2 profiles already do) get the driver and automatic mounting.

## NFS Network Storage

Thingino supports NFS v2/v3 (not v4). To set up persistent NFS storage, configure the share path and the `S43mounts` init script mounts it automatically at boot:

```sh
jct /etc/thingino.json set nfs_share "server:/path/to/share"
```

The share will be mounted at `/mnt/nfs` on boot (using `-o nolock`). Verify with `mount | grep nfs`.

Since ciao 2026-08-25, NFS shares were mounted **soft** with bounded retries (`soft,timeo=30,retrans=2`) instead of hard. If the NFS server stalls or disappears, processes get an I/O error instead of hanging the whole camera in D-state. Access is also noticeably more responsive when the server is slow.

**Reversed on ciao 2026-09-03:** the mount is **hard** again (`hard,timeo=30,retrans=2`). In practice the soft mount turned a stalled server into silent data loss -- the recorder's write returns an error after ~9 seconds, and with no error checking in place the recording kept going with a hole in it (typically exactly where the MP4 init segment lives), producing unplayable files. A hard mount blocks instead of losing data. Check `mount | grep nfs` if a stuck write ever freezes the camera -- that is the trade-off.

## Filesystem Overlay

Thingino uses OverlayFS to provide a writable layer over the read-only root filesystem:

- **Lower layer** -- Read-only rootfs on the flash partition
- **Upper layer** -- Writable JFFS2 partition (`data.jffs2`)

Changes to configuration files persist across reboots. The overlay partition is limited in size -- use SD card or NFS for large files.

---

<- [Previous: Streaming and Video](05-streaming.md) | [Next: Night Vision and Lighting](07-night-vision.md) ->

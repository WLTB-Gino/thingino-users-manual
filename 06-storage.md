# 6. Storage & Recording

## SD Card

SD cards are mounted automatically at `/mnt/mmcblk0p1`. Format as FAT32 for best compatibility. Note that ext4 support is **not enabled by default** — it requires enabling `BR2_PACKAGE_THINGINO_KOPT_EXTFS` in the build config. exFAT may also require additional kernel options.

To trigger a diagnostics report via SD card, create a file named `.diag` in the root of a blank SD card and insert it into the running camera.

## NFS Network Storage

Thingino supports NFS v2/v3 (not v4). To set up persistent NFS storage, configure the share path and the `S43mounts` init script will mount it automatically at boot:

```sh
jct /etc/thingino.json set nfs_share "server:/path/to/share"
```

The share will be mounted at `/mnt/nfs` on boot (using `-o nolock`). Verify with `mount | grep nfs`.

## Filesystem Overlay

Thingino uses OverlayFS to provide a writable layer over the read-only root filesystem:

- **Lower layer** — Read-only rootfs on the flash partition
- **Upper layer** — Writable JFFS2 partition (`data.jffs2`)

Changes to configuration files persist across reboots. The overlay partition is limited in size — use SD card or NFS for large files.

---

← [Previous: Streaming & Video](05-streaming.md) | [Next: Night Vision & Lighting](07-night-vision.md) →


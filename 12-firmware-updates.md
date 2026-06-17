# 12. Firmware Updates

## OTA (Over-the-Air)

If your camera has internet access, firmware updates are available directly from GitHub.

**Prerequisite:** OTA updates must be explicitly enabled first:

```sh
fw_setenv enable_updates true
```

Reboot the camera after enabling. Then update via:

1. Web UI → **System → Firmware Update**
2. Or via Home Assistant firmware update entity

## Manual Update via SD Card

1. Download the firmware `.bin` for your camera from [thingino.com](https://thingino.com)
2. Copy to a FAT32 SD card as `autoupdate-full.bin`
3. Insert into the camera and reboot
4. The camera flashes automatically on boot

## Checking Current Version

```sh
cat /etc/os-release
```

Thingino releases are tagged as `firmware-YYYY-MM-DD` on GitHub.

---

← [Previous: System Configuration](11-system-config.md) | [Next: Troubleshooting](13-troubleshooting.md) →


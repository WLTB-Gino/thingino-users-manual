# 13. Troubleshooting

## Diagnostics

Generate a diagnostics report:

```sh
# Save to temp file
thingino-diag

# Upload to tb.thingino.com (returns a shareable link)
thingino-diag -u

# Save to specific file
thingino-diag -o /mnt/mmc/diag.txt

# JSON output
thingino-diag -j

# Force / skip consent prompt
thingino-diag -f

# Stream to stdout
thingino-diag -o -
```

Or via SD card: create a `.diag` file on a blank SD card and insert it into the running camera.

## No Image / Wrong Sensor

Thingino detects the image sensor by its ID at boot. If the wrong sensor driver is configured, you'll see a clear error in the boot log and **no image will be produced**. Check the boot log for sensor mismatch messages.

## WiFi Won't Connect

- Check reason codes in the log
- Ensure WPA2 passphrase is correct
- Try moving camera closer to the AP
- Verify the WiFi module's GPIO power config in `/etc/thingino.json`

## WebRTC 400 Bad Request (Firefox)

Set `media.gmp-gmpopenh264.enabled` to `true` in Firefox `about:config`.

## Unbricking

**Soft brick** (bootloader works): Place `autoupdate-full.bin` on a FAT32 SD card and reboot.

**Hard brick** (bootloader broken): Use the [universal unbricker](https://unbricker.wltechblog.com/) to create a recovery SD card, then use the flash glitch method (short pins 5 & 6 on the flash chip during power-on). **Note:** The universal unbricker does **not** work with Wyze devices.

Unbricker video walkthrough: https://www.youtube.com/watch?v=qDzM3QEmY6Q

## Camera Sensor Identification

Camera sensors **cannot** be identified visually. Check `/proc/device-info` or boot logs for the sensor model. GalaxyCore sensors (GC-prefixed) generally have better low-light performance.

---

← [Previous: Firmware Updates](12-firmware-updates.md) | [Next: Glossary](14-glossary.md) →


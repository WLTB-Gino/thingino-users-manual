## Diagnostics

Generate a diagnostics report to share with support or attach to a bug report:

```sh
# Save to temp file (default)
thingino-diag

# Upload to tb.thingino.com (returns a shareable link)
thingino-diag -u

# Save to specific file
thingino-diag -o /mnt/mmc/diag.txt

# Upload and return JSON link
thingino-diag -j

# Force / skip consent prompt
thingino-diag -f

# Stream to stdout
thingino-diag -o -
```

Recent builds redact sensitive fields (WiFi credentials, MAC addresses, and other identifying details) from diagnostics output for privacy. This means your credentials are safe to share when posting diagnostics in support channels.

Diagnostics uploads to tb.thingino.com now use HTTPS for secure transfer. If the upload fails, the Web UI reports the error instead of redirecting to an empty page.

Or via SD card: create a `.diag` file on a blank SD card and insert it into the running camera.

## No Image / Wrong Sensor

Thingino detects the image sensor by its ID at boot. If the wrong sensor driver is configured, you see a clear error in the boot log and **no image is produced**. Check the boot log for sensor mismatch messages.

Camera sensors **cannot** be identified visually. Check `/proc/device-info` or boot logs for the sensor model. GalaxyCore sensors (GC-prefixed) generally have better low-light performance.

## WiFi Won't Connect

- Check reason codes in the log (see [Networking](04-networking.md))
- Ensure your WPA2 passphrase is correct
- Try moving the camera closer to the AP
- Verify the WiFi module's GPIO power config in `/etc/thingino.json`

## WebRTC 400 Bad Request (Firefox)

Set `media.gmp-gmpopenh264.enabled` to `true` in Firefox `about:config`.

## Settings Won't Save in Web UI

On stable (Prudynt) builds, the Web UI talks directly to the streamer API on port 8080 using an API key at `/etc/thingino-api.key`. If settings fail to load or save:

- Check that the streamer is running: `pidof prudynt_t`
- Verify the API key exists: `cat /etc/thingino-api.key`
- You may need to update to a newer ciao build that includes the fix

## Unbricking

### Soft Brick (Bootloader Works)

Place `autoupdate-full.bin` on a FAT32 SD card and reboot. This only works when Thingino is already installed. Use a 2GB--8GB SD card for best compatibility.

### Hard Brick (Bootloader Broken)

Use the [universal unbricker](https://unbricker.wltechblog.com/) to create a recovery SD card, then use the flash glitch method (short pins 5 and 6 on the flash chip during power-on).

> **Note:** The universal unbricker does **not** work with Wyze devices.

For flashing with a CH341A programmer, use the [Scriba Web Flasher](https://scriba.thingino.com/) -- it runs in Chrome, no drivers needed.

Unbricker video walkthrough: https://www.youtube.com/watch?v=qDzM3QEmY6Q

## U-Boot NetConsole (No Serial Port Needed)

NetConsole gives you an interactive U-Boot prompt over UDP -- useful on cameras with no serial header (for example Wyze Cam v3) to inspect the boot environment or interrupt a bad boot without opening the case.

> **Availability:** opt-in and currently on the `ciao` branch only (enable `BR2_PACKAGE_THINGINO_UBOOT_NETCONSOLE=y` in the camera defconfig; off by default, byte-identical bootloader otherwise). Not yet on `master`.

On a camera already carrying the shipped defaults, build the client once and reboot the board:

```sh
U=output/ciao/<camera>-<kernel>-<libc>/build/uboot-2013.07
gcc -o $U/tools/ncb $U/tools/ncb.c
$U/tools/netconsole 192.168.1.10 6666   # the board's ipaddr
```

Hold Ctrl-C until the prompt appears; `boot` resumes, `reset` reboots, Ctrl-T exits the client. If keystrokes never arrive, switch to broadcast (`255.255.255.255` instead of the board IP) -- it needs no ARP entry.

**WiFi-only cameras:** since 2026-08-31 NetConsole also runs over a USB-Ethernet dongle plugged into the USB OTG data port (ASIX AX88772 works out of the box; for an AX88179 run `fw_setenv nc_ethact axg0` on the board). The dongle must be on the same network segment as the client.

**Security:** NetConsole has no authentication. In broadcast mode any host on the subnet can interrupt autoboot and get a U-Boot prompt -- enable it only on trusted networks. To pin a single client: `fw_setenv ncip <your-host-ip>`.

Covers the U-Boot phase only; kernel messages still need a serial console or Linux-side netconsole.

## Copying Files via SCP

Thingino uses Dropbear SSH, which does **not** support SFTP. Always use the `-O` flag with OpenSSH 9.0+:

```sh
scp -O file.txt root@hostname.local:/tmp/
```

Without `-O`, OpenSSH defaults to the SFTP protocol and the transfer will fail.

## Remote Logging to a Syslog Server

The camera can send its logs to a central syslog server (configurable in the Web UI under **Settings**). Two ready-made receiver setups are documented in the firmware docs (`docs/thingino/services/rsyslog.md`):

**Debian/Ubuntu:** install `rsyslog`, enable `imudp` on port 514, restart the service.

**Alpine Linux:** replace the default busybox syslogd with `rsyslog` (`apk add rsyslog logrotate`), keep the shipped OpenRC init script as-is (a custom script that pre-creates the pidfile makes rsyslogd exit silently), and use the `dynafile` parameter for per-camera log files named by source IP -- on rsyslog 8.2604+, `file=` with placeholders is treated literally. Apply changes with `rc-service rsyslog restart` (reload may not take effect).

---

<- [Previous: Firmware Updates](12-firmware-updates.md) | [Next: Glossary](14-glossary.md) ->

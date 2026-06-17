# Thingino User's Manual

*Version 1.0 — June 2026*

Thingino is open source firmware for IP cameras built on Ingenic
SoCs. It replaces the stock firmware on supported cameras, bringing
a clean web UI, RTSP/WebRTC streaming, and a rich set of features
without vendor lock-in.

> **Note:** The stable user release (ciao branch) uses **Prudynt** as
> the streaming service. Development builds (master branch) use
> **Raptor**. This manual reflects the user-facing experience (Prudynt). SoCs. This manual covers configuration, networking, streaming, automation, and troubleshooting. For installation instructions, see the [Thingino Wiki](https://github.com/themactep/thingino-firmware/wiki).

---

## Table of Contents

1. [Overview](#1-overview)
2. [First Boot & Initial Setup](#2-first-boot--initial-setup)
3. [Web UI](#3-web-ui)
4. [Networking](#4-networking)
5. [Streaming & Video](#5-streaming--video)
6. [Storage & Recording](#6-storage--recording)
7. [Night Vision & Lighting](#7-night-vision--lighting)
8. [Motion Detection & Alerts](#8-motion-detection--alerts)
9. [Home Automation & Integration](#9-home-automation--integration)
10. [PTZ (Pan-Tilt-Zoom)](#10-ptz-pan-tilt-zoom)
11. [System Configuration](#11-system-configuration)
12. [Firmware Updates](#12-firmware-updates)
13. [Troubleshooting](#13-troubleshooting)
14. [Glossary](#14-glossary)

---

## 1. Overview

### What is Thingino?

Thingino is an open source firmware that replaces the stock firmware on IP cameras powered by Ingenic T-series SoCs (T10, T20, T21, T23, T30, T31). It provides a full-featured camera system with RTSP streaming, ONVIF support, motion detection, night vision, and home automation integration — without cloud dependencies or vendor lock-in.

### Design Philosophy

- **Tailored, not universal** — Each camera gets firmware specifically built for its hardware, with minimum overhead.
- **Common sense engineering** — Simplicity and practicality over unnecessary complexity.
- **Open source** — All components, including U-Boot and the Linux kernel, are publicly available.

### Streamer

Thingino is transitioning from **prudynt** to **Raptor**, its own fully open modular streaming system. Raptor is now the default streamer in the master branch.

### Community

- **Telegram**: https://t.me/thingino
- **Discord**: https://discord.gg/gFc9jR2eXV
- **Wiki**: https://github.com/themactep/thingino-firmware/wiki

---

## 2. First Boot & Initial Setup

### Provisioning

On first boot, the camera creates a WiFi access point for provisioning. Connect to it and follow the setup wizard to configure your WiFi credentials and hostname.

### Accessing the Camera

After provisioning, access the camera via:
- **Hostname**: `http://hostname.local`
- **IP address**: `http://192.168.1.100` (replace with your camera's IP)

### Default Credentials

- **Username**: `thingino`
- **Password**: `thingino`

Change these after initial setup via the Web UI or shell.

### Time & Date

Thingino syncs time via NTP. The NTP server and timezone can be configured automatically via DHCP:

- **NTP server** — DHCP Option 42
- **Timezone** — DHCP Option 101 (IANA TZ database name, e.g., `America/New_York`)

To set timezone manually on the camera:
```sh
jct /etc/thingino.json set timezone "America/New_York"
```

### Shell Access

SSH (Dropbear) is available for command-line access:
```sh
ssh root@hostname.local
```

---

## 3. Web UI

The Web UI provides a browser-based interface for managing your camera.

### Key Features

- **Live Preview** — Real-time video feed with low-latency preview
- **PTZ Controls** — Hover over the preview to reveal pan/tilt controls. Double-click the center circle to reset position.
- **Night Vision** — Hover over the bottom of the preview for night vision settings (day/night threshold, tolerance)
- **Settings** — Network, video, motion, OSD, and system configuration
- **Tools** — MQTT, email, telegram, diagnostics, and more

### Configuration Editor

Advanced settings are available through the Web UI's configuration editor, which directly edits `/etc/thingino.json`. You can also use the `jct` CLI tool from the shell.

---

## 4. Networking

### WiFi

WiFi credentials are set during provisioning. To reconfigure:

```sh
jct /etc/thingino.json set wifi.ssid "YourNetwork"
jct /etc/thingino.json set wifi.key "YourPassword"
/etc/init.d/S36wireless restart
```

#### WiFi Disconnect Reason Codes

If WiFi drops, check the log for WPA-supplicant reason codes. Common ones:

| Code | Meaning |
|------|---------|
| 4 | Disassociated due to inactivity |
| 7 | Class 3 frame from non-associated station |
| 15 | 4-way handshake timeout |
| 71 | Disassociated due to poor RSSI |

Full reference: [WiFi Reason Codes](https://github.com/themactep/thingino-firmware/blob/master/docs/wifi.md)

### Ethernet (Wired)

Wired Ethernet is plug-and-play on devices with an Ethernet port. The MAC address is automatically derived from the SoC serial number (via the `S03mac` init script on recent firmware).

### USB Ethernet

Thingino supports USB Ethernet adapters out of the box:

- **ASIX AX88772** — Best compatibility (supported in both U-Boot and Linux)
- **CDC-Ethernet** — Supported in Linux only
- **CDC-NCM** — Modern adapters, higher throughput

Simply plug in the adapter; it should be recognized automatically.

### VPNs

Thingino supports several VPN solutions for remote access:

- **ZeroTier** — See the [ZeroTier wiki page](https://github.com/themactep/thingino-firmware/wiki/VPN:-Zerotier)
- **Wireguard** — Available as a package
- **OpenVPN** — Available as a package

---

## 5. Streaming & Video

### RTSP

RTSP is the primary streaming protocol. Streams are available at:

```
rtsp://thingino:thingino@<camera-ip>:554/ch0   (main stream)
rtsp://thingino:thingino@<camera-ip>:554/ch1   (sub stream)
```

#### Testing the stream
```sh
curl -v -X DESCRIBE rtsp://thingino:thingino@192.168.1.10:554/ch1
```

#### Saving to file
```sh
ffmpeg -i rtsp://thingino:thingino@192.168.1.10:554/ch1 -map 0 -c copy -f mpegts record.ts
```

#### Low-latency playback (mpv)
```sh
mpv rtsp://thingino:thingino@192.168.1.10:554/ch0 --profile=low-latency --no-cache --cache-secs=0 --demuxer-readahead-secs=0 --cache-pause=no
```

### WebRTC (Live View)

WebRTC provides ultra-low-latency live view in the Web UI. The camera's streaming daemon handles WebRTC negotiation automatically.

> **Firefox note**: If you get a 400 Bad Request error, ensure `media.gmp-gmpopenh264.enabled` is set to `true` in Firefox's `about:config`. The camera only supports H.264 video.

### ONVIF

Thingino provides ONVIF Profile S compliance, enabling compatibility with NVRs, VMS software, and home automation platforms. ONVIF services include:

- Media streaming (RTSP)
- PTZ control
- Event notifications (motion detection)
- Imaging settings

ONVIF motion events work with UniFi Protect and other NVRs that support third-party ONVIF cameras.

### OSD (On-Screen Display)

Thingino supports customizable OSD overlays:

- **Time/Date** — Display current time
- **Custom Text** — User-defined text label
- **Brightness indicator** — Shows current ISP gain
- **Logo** — Custom BGRA image overlay

#### Creating a logo

Create a transparent PNG, then convert to BGRA:
```sh
convert logo-100x30-alpha.png -depth 8 bgra:logo.bgra
```

### Video Privacy Mode

Privacy mode blacks out all video streams (RTSP, recordings, JPEG) while keeping the ISP running:

```sh
printf 'PRIVACY ch=0 value=on\n' > /run/prudynt/video_ctrl
printf 'PRIVACY ch=0 value=off\n' > /run/prudynt/video_ctrl
```

Use `ch=all` or omit `ch=` to toggle all streams.

### Encoder Rate Control

Advanced encoders support custom quantizer and bitrate limits via the streamer config:

```json
"stream0": {
    "mode": "VBR",
    "qp_init": 30,
    "qp_min": 28,
    "qp_max": 45,
    "max_bitrate": 4200000
}
```

---

## 6. Storage & Recording

### SD Card

SD cards are mounted automatically at `/mnt/mmc`. Format as FAT32, exFAT, or ext4.

To trigger a diagnostics report via SD card, create a file named `.diag` in the root of a blank SD card and insert it into the running camera.

### NFS Network Storage

Thingino supports NFS v2/v3 (not v4). To set up persistent NFS storage, configure the share path and the `S43mounts` init script will mount it automatically at boot:

```sh
jct /etc/thingino.json set nfs_share "server:/path/to/share"
```

The share will be mounted at `/mnt/nfs` on boot (using `-o nolock`). Verify with `mount | grep nfs`.

### Filesystem Overlay

Thingino uses OverlayFS to provide a writable layer over the read-only root filesystem:

- **Lower layer** — Read-only rootfs on the flash partition
- **Upper layer** — Writable JFFS2 partition (`data.jffs2`)

Changes to configuration files persist across reboots. The overlay partition is limited in size — use SD card or NFS for large files.

---

## 7. Night Vision & Lighting

### Day/Night Mode

Thingino automatically switches between day (color) and night (IR) modes based on ambient light:

- **Day/Night Threshold** — Light level at which the camera switches modes
- **Day/Night Tolerance** — Buffer to prevent frequent switching from minor light changes

Both are adjustable from the Web UI (hover over the bottom of the live preview) or via `jct`.

### IR-CUT Filter

The IR-CUT filter blocks infrared light during the day for accurate colors and removes it at night to allow IR illumination. Control manually with the `ircut` command:

```sh
ircut on      # Day mode (filter in — blocks IR)
ircut off     # Night mode (filter out — allows IR)
ircut toggle  # Switch to opposite state
ircut status  # Show current state
```

GPIO pins for the IR-CUT filter are configured under `gpio.ircut` in `/etc/thingino.json`.

### IR LEDs

Most cameras have integrated IR LED arrays (850nm or 940nm). Some use an LDR (light-dependent resistor) to auto-switch LEDs independently of the camera.

IR LED beam angle should match the lens:
- 45° for 8mm lens
- 60° for 6mm lens
- 80° for 4mm lens
- 90° for 3.6mm lens

### White Light LEDs

Some cameras include white light LEDs for full-color night vision. These can be controlled via the Web UI, `jct`, or Home Assistant.

---

## 8. Motion Detection & Alerts

### Motion Guard

Motion detection is built into the camera using the SoC's hardware IVS (Intelligent Video System). Enable it from the Web UI under **Motion Guard**.

### Alert Methods

When motion is detected, Thingino can send alerts via:

- **MQTT** — Publish a message to your MQTT broker (`send2mqtt`)
- **Email** — Send notification email (`send2email`)
- **Telegram** — Send message via Telegram bot (`send2telegram`)
- **Webhook** — HTTP callback to a custom endpoint (`send2webhook`)
- **ntfy** — Push notifications via ntfy.sh (`send2ntfy`)
- **Gotify** — Self-hosted push notifications (`send2gotify`)
- **FTP** — Upload snapshots/clips to an FTP server (`send2ftp`)
- **Storage** — Save recordings to SD card or NFS (`send2storage`)
- **XMPP** — Send message via Jabber/XMPP (`send2xmpp`)

Enable via the Web UI under **Tools** or through `jct /etc/prudynt.json`.

---

## 9. Home Automation & Integration

### Home Assistant

Thingino has native Home Assistant integration via MQTT auto-discovery. No YAML required.

**Setup:**
```sh
jct /etc/thingino.json set ha.enabled true
/etc/init.d/S93ha restart
```

**Available entities:**

| Entity | Type | Description |
|--------|------|-------------|
| Motion detected | Binary sensor | Motion state |
| Motion Guard | Switch | Enable/disable motion |
| IR Cut Filter | Switch | Day/night filter |
| Day/Night Mode | Select | Day/Night toggle |
| Privacy Screen | Switch | Black out video |
| Color Mode | Switch | Color vs monochrome |
| IR LED 850nm | Switch | 850nm IR LEDs |
| IR LED 940nm | Switch | 940nm IR LEDs |
| White Light | Switch | White LEDs |
| WiFi RSSI | Sensor | Signal strength |
| Snapshot | Button | Take snapshot |
| Firmware Update | Update | OTA from GitHub |
| PTZ | Buttons | Up/Down/Left/Right/Home |

Disable individual entities:
```sh
jct /etc/thingino.json set ha.enable_reboot false
```

All MQTT topics use the prefix `cameras/<mac_address>/`.

### MQTT

Thingino includes `mosquitto_pub` and `mosquitto_sub` clients. Configure broker settings under **Services → MQTT Subscriptions** in the Web UI.

Motion publish script: `/usr/sbin/send2mqtt`

### NVR / VMS Compatibility

Thingino works with most NVR/VMS software via ONVIF or direct RTSP:

- **UniFi Protect** — ONVIF events (motion) work
- **Frigate** — Use RTSP URL
- **Blue Iris** — Use RTSP URL
- **Synology Surveillance Station** — Use ONVIF or RTSP
- **iSpy / Agent DVR** — Use RTSP URL

---

## 10. PTZ (Pan-Tilt-Zoom)

### Web UI

Hover over the live preview to access PTZ controls. Double-click the center circle to return to home position.

### MQTT / Home Assistant

Enable PTZ buttons in HA:
```sh
jct /etc/thingino.json set ha.enable_ptz true
```

Commands: `cameras/<id>/ptz/{up,down,left,right,home}/set`

### Motor Configuration

PTZ motor GPIO configuration is defined in `/etc/thingino.json` under the `motors` key. VCM (Voice Coil Motor) focus control uses the `dw9714-ctrl` script, with GPIO config in `motors.json`.

---

## 11. System Configuration

### Configuration Files

| File | Purpose |
|------|---------|
| `/etc/thingino.json` | Main configuration (network, system, services) |
| `/etc/prudynt.json` | Prudynt streamer config (streams, OSD, video) |
| `/etc/rc.local` | Custom startup commands |
| `/etc/init.d/S*` | Init scripts |

### JCT (JSON Configuration Tool)

`jct` is the CLI tool for editing JSON configuration:

```sh
# Read a value
jct /etc/thingino.json get wifi.ssid

# Set a value
jct /etc/thingino.json set wifi.ssid "MyNetwork"

# Delete a key
jct /etc/thingino.json delete wifi.key
```

### GPIO Configuration

GPIO pins for SD card power and WiFi modules are configured in `/etc/thingino.json` under `gpio.mmc_power` and `gpio.wlan`. Supports legacy strings, single objects, or ordered arrays:

```json
"gpio": {
    "wlan": [
        { "pin": 47, "state": 1 },
        { "pin": 47, "action": "toggle" }
    ]
}
```

### OverlayFS Layers

- **`overlay/`** (build-time) — Replaces files in the read-only rootfs
- **`user/common/overlay/`** — Writable partition, persists user changes
- **`user/<camera>/overlay/`** — Camera-specific user overlay

### DHCP Timezone

Thingino automatically receives timezone from DHCP Option 101 and NTP server from DHCP Option 42.

---

## 12. Firmware Updates

### OTA (Over-the-Air)

If your camera has internet access, firmware updates are available directly from GitHub.

**Prerequisite:** OTA updates must be explicitly enabled first:

```sh
fw_setenv enable_updates true
```

Reboot the camera after enabling. Then update via:

1. Web UI → **System → Firmware Update**
2. Or via Home Assistant firmware update entity

### Manual Update via SD Card

1. Download the firmware `.bin` for your camera from [thingino.com](https://thingino.com)
2. Copy to a FAT32 SD card as `autoupdate-full.bin`
3. Insert into the camera and reboot
4. The camera flashes automatically on boot

### Checking Current Version

```sh
cat /etc/os-release
```

Thingino releases are tagged as `firmware-YYYY-MM-DD` on GitHub.

---

## 13. Troubleshooting

### Diagnostics

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

### No Image / Wrong Sensor

Thingino detects the image sensor by its ID at boot. If the wrong sensor driver is configured, you'll see a clear error in the boot log and **no image will be produced**. Check the boot log for sensor mismatch messages.

### WiFi Won't Connect

- Check reason codes in the log
- Ensure WPA2 passphrase is correct
- Try moving camera closer to the AP
- Verify the WiFi module's GPIO power config in `/etc/thingino.json`

### WebRTC 400 Bad Request (Firefox)

Set `media.gmp-gmpopenh264.enabled` to `true` in Firefox `about:config`.

### Unbricking

**Soft brick** (bootloader works): Place `autoupdate-full.bin` on a FAT32 SD card and reboot.

**Hard brick** (bootloader broken): Use the [universal unbricker](https://unbricker.wltechblog.com/) to create a recovery SD card, then use the flash glitch method (short pins 5 & 6 on the flash chip during power-on).

Unbricker video walkthrough: https://www.youtube.com/watch?v=qDzM3QEmY6Q

### Camera Sensor Identification

Camera sensors **cannot** be identified visually. Check `/proc/device-info` or boot logs for the sensor model. GalaxyCore sensors (GC-prefixed) generally have better low-light performance.

### Unsupported Camera Types

**Solar and battery-powered cameras are NOT supported.** They use the Zeratul platform with a separate MCU that controls power — Thingino cannot keep the main SoC powered on.

---

## 14. Glossary

| Term | Definition |
|------|------------|
| **3A** | Auto Exposure, Auto White Balance, Auto Focus |
| **AE** | Automatic Exposure |
| **AF** | Automatic Focus |
| **AWB** | Automatic White Balance |
| **BLC** | Backlight Compensation |
| **DNR** | Digital Noise Reduction (3D-DNR = temporal) |
| **GPIO** | General Purpose Input/Output |
| **ICR / IR-CUT** | Infrared Cut Filter Removal |
| **IMP** | Ingenic Media Platform (SDK) |
| **ISP** | Image Signal Processor |
| **IVS** | Intelligent Video System (hardware motion detection) |
| **JCT** | JSON Configuration Tool (Thingino CLI) |
| **NVR** | Network Video Recorder |
| **ONVIF** | Open Network Video Interface Forum (standard) |
| **OSD** | On-Screen Display |
| **PTZ** | Pan-Tilt-Zoom |
| **RTSP** | Real Time Streaming Protocol |
| **SoC** | System on a Chip |
| **OverlayFS** | Filesystem layering (read-only base + writable overlay) |
| **U-Boot** | Universal Bootloader |

---

*This manual is a living document. Submit corrections or suggestions via the [Thingino community](https://discord.gg/gFc9jR2eXV).*

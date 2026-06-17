# 11. System Configuration

## Configuration Files

| File | Purpose |
|------|---------|
| `/etc/thingino.json` | Main configuration (network, system, services) |
| `/etc/prudynt.json` | Prudynt streamer config (streams, OSD, video) |
| `/etc/rc.local` | Custom startup commands |
| `/etc/init.d/S*` | Init scripts |

## JCT (JSON Configuration Tool)

`jct` is the CLI tool for editing JSON configuration:

```sh
# Read a value
jct /etc/thingino.json get wifi.ssid

# Set a value
jct /etc/thingino.json set wifi.ssid "MyNetwork"

# Delete a key
jct /etc/thingino.json delete wifi.key
```

## GPIO Configuration

GPIO pins for SD card power and WiFi modules are configured in `/etc/thingino.json` under `gpio.mmc_power` and `gpio.wlan`. Supports legacy strings, single objects, or ordered arrays:

```json
"gpio": {
    "wlan": [
        { "pin": 47, "state": 1 },
        { "pin": 47, "action": "toggle" }
    ]
}
```

## OverlayFS Layers

- **`overlay/`** (build-time) — Replaces files in the read-only rootfs
- **`user/common/overlay/`** — Writable partition, persists user changes
- **`user/<camera>/overlay/`** — Camera-specific user overlay

## DHCP Timezone

Thingino automatically receives timezone from DHCP Option 101 and NTP server from DHCP Option 42.

---

← [Previous: PTZ (Pan-Tilt-Zoom)](10-ptz.md) | [Next: Firmware Updates](12-firmware-updates.md) →


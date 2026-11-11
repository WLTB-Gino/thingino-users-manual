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
jct /etc/thingino.json get ha.enabled

# Set a value
jct /etc/thingino.json set ha.enabled true

# Delete a key
jct /etc/thingino.json delete ha.enable_reboot
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

`gpio.speaker` sets the speaker amp enable pin (pin number or object form) and is read at build time -- it feeds the gpio-userkeys module config and the U-Boot device tree, so changing it requires a rebuild rather than a runtime `jct` edit.

**Finding pins:** the `gpio scan` command sweeps every free pin as an input and reports which ones change state -- handy when populating `gpio.mmc_power` or `gpio.wlan` on an undocumented board. Pins 55, 56 and pins referenced in `/etc/web.conf` are skipped automatically; `gpio scan 12 13` additionally leaves pins 12 and 13 alone.

## Hostname

The hostname suffix is derived at boot from the SoC serial number (same function that generates the MAC), and it is never regenerated from a later MAC change. A custom hostname set via `conf s hostname` is stored in the provisioning key/value store and applied on boot.

Changes to configuration files persist across reboots. The overlay partition is limited in size -- use SD card or NFS for large files. The SSH shell banner displays overlay usage statistics, so you can see at a glance how much overlay space is consumed.

## OverlayFS Layers

- **`overlay/`** (build-time) -- Replaces files in the read-only rootfs
- **`user/common/overlay/`** -- Writable partition, persists user changes
- **`user/<camera>/overlay/`** -- Camera-specific user overlay

## DHCP Timezone

Thingino automatically receives timezone from DHCP Option 101 and NTP server from DHCP Option 42. DHCP can deliver timezone names with underscores, and the camera maps underscores to spaces so the zone resolves instead of falling back to UTC.

---

<- [Previous: PTZ (Pan-Tilt-Zoom)](10-ptz.md) | [Next: Firmware Updates](12-firmware-updates.md) ->

## WiFi

WiFi credentials are stored in `/etc/wpa_supplicant.conf`, not in JSON config. To reconfigure:

```sh
# Non-interactively (positional args, no flags)
wlan configure "YourNetwork" "YourPassword"

# Interactive wizard
wlan setup

# Remove stored credentials
wlan reset
```

A reboot is required after changing WiFi credentials.

### Pre-configuring WiFi via SD Card

Place a `runonce.sh` script on the SD card root:

```sh
#!/bin/sh
wlan configure "YourNetwork" "YourPassword"
```

The camera runs it once on boot, then deletes it.

### WiFi Disconnect Reason Codes

If WiFi drops, check the log for WPA-supplicant reason codes. Common ones:

| Code | Meaning |
|------|---------|
| 4 | Disassociated due to inactivity |
| 7 | Class 3 frame from non-associated station |
| 15 | 4-way handshake timeout |
| 71 | Disassociated due to poor RSSI |

Full reference: [WiFi Reason Codes](https://github.com/themactep/thingino-firmware/blob/master/docs/wifi.md)

## Ethernet (Wired)

Wired Ethernet is plug-and-play on devices with an Ethernet port. The MAC address is automatically derived from the SoC serial number.

## Time and Timezone

Recent ciao builds introduce **timectl**, the single entry point for clock, timezone, and NTP configuration:

```sh
timectl set-timezone "Europe/Berlin"
timectl pin-timezone        # disable automatic timezone from DHCP
timectl unpin-timezone      # re-enable automatic timezone
```

All time-related paths (Web UI, WiFi portal, `tzselect`, and the DHCP client scripts) now route through `timectl`. The old `dhcp.ignore_timezone` setting is migrated automatically. Docs: `docs/timezone.md` in the firmware repo.

## USB Ethernet

Thingino supports USB Ethernet adapters out of the box:

- **ASIX AX88772** -- Best compatibility (supported in both U-Boot and Linux)
- **CDC-Ethernet** -- Supported in Linux only
- **CDC-NCM** -- Modern adapters, higher throughput

Plug in the adapter and it should be recognized automatically.

## USB WiFi Dongles

**Ralink RT5370** USB WiFi dongles are supported on master builds from 2026-08-23 (`242d92daf`). Useful as a replacement radio for cams with damaged internal WiFi or where you want to reposition the antenna.

## mDNS / Bonjour Discovery

Thingino cameras advertise themselves on the local network via mDNS (Bonjour/Avahi). The service type is `_thingino._tcp`, broadcast on the camera's HTTP port.

This means you can discover cameras without knowing their IP address:
- **Linux**: `avahi-browse -rt _thingino._tcp`
- **macOS**: Use Bonjour Browser or Safari's Bonjour bookmarks
- **Home Assistant**: mDNS devices appear automatically in discovery

The camera's hostname (e.g., `ing-t31x-1234.local`) is also resolvable via mDNS.

## SNMP

Thingino includes an optional **thingino-snmpd** package (mini-snmpd 2.0) for SNMP monitoring. When enabled at build time, it provides a WebUI plugin for configuration and exposes system metrics to SNMP managers.

## VPNs

Thingino supports VPN solutions for remote access:

- **WireGuard** -- Included by default in all releases
- **ZeroTier** -- Available in custom builds for cameras with 16MB flash. See the [ZeroTier wiki page](https://github.com/themactep/thingino-firmware/wiki/VPN:-Zerotier)

> **Note:** OpenVPN is not tested or promoted. Use WireGuard for VPN access.

### WiFi Roaming

Builds from 2026-08-25 fix a bug where the *disable-roaming* patches on Realtek USB drivers (8188/8189/8192/8733/8812 families) never actually took effect -- layer-2 roaming was always compiled in. If you disable roaming in your build config, these builds honor it; roaming clients that hop between APs should behave more predictably.

---

<- [Previous: Web UI](03-web-ui.md) | [Next: Streaming and Video](05-streaming.md) ->

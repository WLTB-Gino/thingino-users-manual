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

## USB Ethernet

Thingino supports USB Ethernet adapters out of the box:

- **ASIX AX88772** -- Best compatibility (supported in both U-Boot and Linux)
- **CDC-Ethernet** -- Supported in Linux only
- **CDC-NCM** -- Modern adapters, higher throughput

Plug in the adapter and it should be recognized automatically.

## VPNs

Thingino supports VPN solutions for remote access:

- **WireGuard** -- Included by default in all releases
- **ZeroTier** -- Available in custom builds for cameras with 16MB flash. See the [ZeroTier wiki page](https://github.com/themactep/thingino-firmware/wiki/VPN:-Zerotier)

> **Note:** OpenVPN is not tested or promoted. Use WireGuard for VPN access.

---

<- [Previous: Web UI](03-web-ui.md) | [Next: Streaming and Video](05-streaming.md) ->

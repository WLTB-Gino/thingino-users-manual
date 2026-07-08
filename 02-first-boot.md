# 2. First Boot & Initial Setup

## Provisioning

On first boot, the camera creates a WiFi access point for provisioning. Connect to it and follow the setup wizard to configure your WiFi credentials and hostname.

## Accessing the Camera

After provisioning, access the camera via:
- **Hostname**: `http://hostname.local`
- **IP address**: `http://192.168.1.100` (replace with your camera's IP)

## Default Credentials

The default `thingino`/`thingino` credentials are used for **streamer and ONVIF connections** (RTSP, ONVIF). The username and password you set during **provisioning** are used for the **Web UI and SSH**.

## Time & Date

Thingino syncs time via NTP. The NTP server and timezone can be configured automatically via DHCP:

- **NTP server** — DHCP Option 42
- **Timezone** — DHCP Option 101 (IANA TZ database name, e.g., `America/New_York`)

To set timezone manually on the camera:
```sh
# Set by name
tzselect -n "America/New_York"

# Or use interactive mode
tzselect -i
```

## Factory Reset

If you need to start over (e.g., wrong WiFi credentials, misconfigured settings), you can perform a factory reset:

1. **Hold down the camera's button** (the same button used for provisioning)
2. **Plug in power** while continuing to hold the button
3. **Keep holding for 5 seconds** after power is applied, then release
4. The camera will **erase all configuration data** and boot back into provisioning mode

> ⚠️ **Important:** Do not interrupt the reset process or you may end up with a bricked camera. Let it complete fully.

This is the fastest way to recover from incorrect WiFi credentials without needing to access the camera over the network.

## Shell Access

SSH (Dropbear) is available for command-line access:
```sh
ssh root@hostname.local
```

---

← [Previous: Overview](01-overview.md) | [Next: Web UI](03-web-ui.md) →


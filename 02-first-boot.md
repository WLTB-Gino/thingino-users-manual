## Provisioning

On first boot, the camera creates a WiFi access point for provisioning. Connect to it and follow the setup wizard to configure your WiFi credentials and hostname.

### Pre-configuring WiFi Without the Wizard

If you prefer to set up WiFi before the camera even boots, place a `runonce.sh` script on the SD card root:

```sh
#!/bin/sh
wlan configure "YourNetwork" "YourPassword"
```

The camera runs this script once on boot, configures WiFi, then deletes it.

During provisioning, the setup portal pre-scans for WiFi networks before bringing up its own access point, so the network list you see is a real scan of your environment (not a stale cache). If the scan times out, the portal falls back to a manual SSID entry.

If the camera never broadcasts its setup hotspot on first boot, a stale `wpa_supplicant.conf` may be the culprit: on mt7601u cameras the portal's AP settings can end up in the persistent WiFi config, so the camera skips provisioning entirely. Re-flash or factory-reset to get the portal back.

## Accessing the Camera

After provisioning, access the camera via:

- **Hostname**: `http://hostname.local`
- **IP address**: `http://192.168.1.100` (replace with your camera's IP)

## Default Credentials

The default `thingino`/`thingino` credentials are used for **streamer and ONVIF connections** (RTSP, ONVIF). The username and password you set during **provisioning** are used for the **Web UI and SSH**.

Note: the Web UI only accepts logins from the root account -- the `thingino` service account cannot open a web session, even with correct credentials.

You can change both the root (SSH) password and the streaming user password from the Web UI **Settings** page.

## Time and Date

Thingino syncs time via NTP. The NTP server and timezone can be configured automatically through DHCP:

- **NTP server** -- DHCP Option 42
- **Timezone** -- DHCP Option 101 (IANA TZ database name, e.g., `America/New_York`)

To set the timezone manually on the camera:

```sh
# Set by name
tzselect -n "America/New_York"

# Or use interactive mode
tzselect -i
```

## Factory Reset

If you need to start over -- wrong WiFi credentials, misconfigured settings -- a factory reset wipes everything and returns the camera to provisioning mode:

1. **Hold down the camera's button** (the same button used for provisioning)
2. **Plug in power** while continuing to hold the button
3. **Keep holding for 5 seconds** after power is applied, then release
4. The camera erases all configuration data and boots back into provisioning mode

> **Warning:** Do not interrupt the reset process. Let it complete fully or you risk bricking the camera.

This is the fastest way to recover from incorrect WiFi credentials without needing network access.

### Factory reset internals

Factory reset is safe on current builds:

- `firstboot -e` clears provisioning keys only instead of erasing the whole U-Boot environment. (Erasing the env would make U-Boot boot its built-in defaults, including `bootcmd=bootp`, and lose the `mtdparts` that sysupgrade wrote, so the next boot could no longer load the kernel.)
- The Web UI's factory-reset page wipes the overlay via `firstboot -e` instead of erasing `/dev/mtd2`, which is actually the config backup partition -- a web-triggered reset does not destroy your settings backup.

## Shell Access

SSH (Dropbear) is available for command-line access:

```sh
ssh root@hostname.local
```

Thingino cameras do **not** have an SFTP server. When copying files with `scp`, add the `-O` flag if your OpenSSH client is version 9.0 or newer:

```sh
scp -O file.txt root@hostname.local:/tmp/
```

Without `-O`, OpenSSH defaults to the SFTP protocol and the transfer will fail.

---

<- [Previous: Overview](01-overview.md) | [Next: Web UI](03-web-ui.md) ->

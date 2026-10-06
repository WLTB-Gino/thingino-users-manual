## What is Thingino?

Thingino is open source firmware that replaces the stock firmware on IP cameras powered by Ingenic T-series SoCs (T10, T20, T21, T23, T30, T31, T32, T33, T40, T41). You get a full-featured camera system with RTSP streaming, ONVIF support, motion detection, night vision, and home automation integration -- without cloud dependencies or vendor lock-in.

## Design Philosophy

- **Tailored, not universal** -- Each camera gets firmware built specifically for its hardware, with minimum overhead.
- **Common sense engineering** -- Simplicity and practicality over unnecessary complexity.
- **Open source** -- All components, including U-Boot and the Linux kernel, are publicly available.

## Streamer

Thingino's stable release builds use **Prudynt**, the production streamer. OSD data is embedded as SEI metadata in the H.264 stream by default, and recent ciao builds add an optional burn-in mode that renders OSD directly into video pixels.

**TIMPS** (Tiny IMP Streamer) is a newer lightweight alternative by Lu-Fi, available as a package in recent builds. It offers on-demand encoding (idle at 0% CPU), a live control API (POST/GET /control), SSE event push (/events), per-stream TrueType OSD, grid motion detection (IMP_IVS), native day/night detection, privacy cover masks, local SD recording, and optional Opus audio codec. Supports RTSP Digest/HTTP Basic auth and token auth.

**Raptor** is the next-generation modular streaming system, currently in development builds only. It will become the default in future releases. As of recent master builds, Raptor now uses **daynightd** as its day/night engine (replacing the older RIC tool), with dedicated `daynight`, `ircut`, and `light` wrapper scripts for both Web UI and command-line use.

Recent master and ciao builds also integrate the **open-isp** package -- a complete open media stack for ISP tuning and development, including an `isp-inspector` tool that displays exposure values as log2 stops.

## SoC Support

Thingino currently runs on **Ingenic** T-series SoCs (T10, T20, T21, T23, T30, T31, T32, T33, T40, T41). The first T32 camera profile landed on master in September 2026 (Cinnado D1 T32LQ) -- builds for T32 are new and experimental. Early groundwork for **SigmaStar** (Infinity6e/SSC30KQ) support has been merged, but no usable SigmaStar camera builds exist yet.

## SNMP Monitoring

Thingino includes an optional **thingino-snmpd** package (mini-snmpd 2.0) for network monitoring via SNMP. When enabled, it integrates with the Web UI as a plugin and exposes camera system metrics to SNMP managers like PRTG, Zabbix, or LibreNMS.

## Recently Added Cameras

- **Petcube C401A** (T31LC, MIS2008 sensor, ATBM6012B WiFi) -- master, cameras-exp (added 2026-10-05)
- **Teacup DevBoard** (T31ZX, IMX219 sensor, Ethernet, 16MB flash) -- ciao branch (experimental, added 2026-09-29)
- **Eufy T8416 (E220 family), dual-sensor mode** (T40XP, two sensors at 20 fps each) -- master. The T40 dual-sensor mode is real on master as of 2026-09-15: both lenses stream concurrently, with per-sensor Raptor configuration keys and U-Boot now parking every sensor's IR-cut pins at boot. Building a T40 dual image still needs the boosted rmem recipe (BR2_THINGINO_RMEM_MB=134, NMEM=22)
- **Infiya K1** (T31L, SC231HAI sensor, ATBM6132CU WiFi) -- ciao branch (experimental, added 2026-09-11). Profile corrections landed 2026-09-27: the BT-combo `0x6162` USB revision of the WiFi module is auto-flagged for the driver, the audio/LED GPIOs switched to active-low symbols, and the ISP settings now carry per-line comments
- **DEKCO DC5L** (T23N, SC3332P sensor, WS73V100 USB WiFi, 16MB flash) -- ciao branch (added 2026-09-20; promoted to the mainline camera list)
- **Shelly S1** (T23N, MIS20C1 sensor, ATBM6132CU WiFi) -- supported on both branches (ciao 2026-09-09, master 2026-09-10). A hardware revision with USB ethernet instead of the wireless module is also supported (ciao, cameras-exp, 2026-09-17)
- **Sonoff S3W** (T23N, SC231HAI or SC200AI sensor, ATBM6132CU WiFi) -- ciao branch (added 2026-09-17). Two sensor variants exist, one profile each. Recent builds also handle both USB hardware revisions of the ATBM6132CU module: units reporting USB ID `0x6162` are the Bluetooth-combo variant and need the matching driver option (`BR2_PACKAGE_WIFI_ATBM6132CU_6162`, selected automatically for the S3W profile), which ships the combo firmware, enables WiFi+BT sharing (`wifi_bt_comb=1`) and drops the driver's `p2p0` network device
- **Sonoff CAM-B1P and CAM-PT2** (T23, SC2337P sensor) -- ciao branch (added 2026-10-03). These units carry the SC2337P die, which shares its chip ID with the more common SC2336P; builds from 2026-10-03 auto-tell the two dies apart at boot (see [Troubleshooting](13-troubleshooting.md)), so the wrong profile now fails with a clear sensor error instead of binding the wrong image tuning.
- **SecuPlug SP1** (T10L, JXH42 sensor, MT7601 USB WiFi) -- ciao branch (added 2026-09-24; motor speed/travel calibrated)
- **Wyze Cam v3 + RT5370 USB dongle** (T31X, GC2053 -- for units with unsupported internal WiFi; uses an external RT5370 USB dongle) -- ciao (experimental)
- **Vanhua S62I** (T40XP, SPI-NAND, IMX307, Ethernet) -- master and ciao (experimental)
- **Vanhua Z55** (T31X, GC4653 4MP, Ethernet) -- master. Builds from 2026-08-28 repin the AVPU hardware encoder clock to a reachable 600 MHz, so it sustains H.265 2560x1440 at 30 fps with lower CPU use (previously the encoder silently ran at 400 MHz and dropped frames at 25 fps)
- **Wyze Cam Pan V1** (JXF23 sensor + RTL8189FTV WiFi variant) -- master and ciao
- **Wyze Floodlight V2** (T41NQ) -- ciao branch
  - The Floodlight v1 light (via Wyze Cam Floodlight v1 accessory) now has a `floodlight_ctl` CLI for brightness control: `floodlight_ctl on <1-100>` / `floodlight_ctl off` (verbose with `-v`)
- **Wyze Lamp Socket** accessory (ciao `3eabd559b`, 2026-10-06): the socket's switched power outlet is controllable from the Web UI and as a Home Assistant switch entity (see [Web UI](03-web-ui.md) and [Home Automation](09-home-automation.md))
- **Hugolog E5P** (T41LQ) -- ciao branch
- **Kiwibit BC111** (T23ZN) -- ciao branch
- **Cinnado B6** (T23ZN) -- ciao branch
- **Cinnado D1, T32 variant** (T32LQ, SC4336P sensor, ATBM6132U WiFi) -- master (experimental). First camera profile on the Ingenic T32 family -- T32 support is now real hardware, not just a name on the SoC list. Motors are wired in the profile but pan/tilt behavior is unverified on this variant. Caution: the D1 ships with several different SoCs (T23N, T31L, T41NQ, T32) -- identify your hardware before flashing any D1 image

Check [thingino.com](https://thingino.com) for the full list of supported cameras.

## Unsupported Camera Types

**Solar and battery-powered cameras are not supported.** They use the Zeratul platform with a separate MCU that controls power -- Thingino cannot keep the main SoC powered on.

## Secure Boot (eFuse-Locked) Cameras

Some cameras ship with eFuse secure boot locked: Wyze Cam V4, Wyze Doorbell V2, Wyze Cam Pan 3/4, and select Galayou, Xiaomi, and Camsoy models. Thingino `master` builds patch the U-Boot SPL at build time (the `secureboop` package) so firmware images boot on these SoCs. Models on T23/T32/T40/T41 need no extra data; T31-based locked models additionally require the vendor RSA modulus extracted from a stock flash dump.

## Community

- **Telegram**: https://t.me/thingino
- **Discord**: https://discord.gg/gFc9jR2eXV
- **Wiki**: https://github.com/themactep/thingino-firmware/wiki

## Web Tools

Two browser-based tools make Thingino more accessible:

- **[Image Builder](https://image-builder.thingino.com/)** -- Select your branch and camera model, and it builds a fresh firmware image in about 18 minutes. Useful if you cannot do a local build.
- **[Scriba Web Flasher](https://scriba.thingino.com/)** -- A browser-based CH341A flash tool (read, write, erase) that runs in Chrome. No drivers or local software to install. This is the recommended method for flashing with a programmer.

---

[Next: First Boot & Initial Setup](02-first-boot.md) ->

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

If the camera never broadcasts its setup hotspot on first boot, a stale `wpa_supplicant.conf` may be the culprit. Older builds (before 2026-08-24, `06cf8c284`) wrote the portal's AP settings into the persistent WiFi config on mt7601u cameras, so the camera skipped provisioning entirely. Re-flash or factory-reset to get the portal back.

## Accessing the Camera

After provisioning, access the camera via:

- **Hostname**: `http://hostname.local`
- **IP address**: `http://192.168.1.100` (replace with your camera's IP)

## Default Credentials

The default `thingino`/`thingino` credentials are used for **streamer and ONVIF connections** (RTSP, ONVIF). The username and password you set during **provisioning** are used for the **Web UI and SSH**.

Note: builds from 2026-08-23 (`0240c30be`) restrict Web UI login to the root account only -- the `thingino` service account can no longer open a web session, even with correct credentials.

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

The Web UI gives you a browser-based interface for managing your camera. Open it at `http://hostname.local` or `http://<camera-ip>`.

**Since ciao 2026-10-04 (`7cafa145e`), camera pages notice an expired login.** While the tab is visible, the page re-checks the session with the camera once a minute and redirects to the login screen when the session has expired. Before this, a page left open could keep running on an already-expired session (the background heartbeat stream authenticates only once when it opens), and you would only find out when a control silently failed. If you return to a camera tab and find yourself at the login page, that is this check working as intended -- log back in and continue.

## Live Preview

Since ciao 2026-09-04 (`052f13613`), the preview player recovers on its own when the browser backgrounded or throttled the tab: a watchdog monitors frame progress and force-reconnects after ~20 seconds without video while the tab is visible, and reconnect/retry budgets reset whenever you press Connect. Hover over the preview to reveal PTZ controls. On raptor-streamer builds (from 2026-08-24, `785447b84`) the live preview is proxied through rhd's native MJPEG stream, keeping the JPEG encoder warm and delivering frames at the configured JPEG FPS instead of the previous 3-4 second cadence.

On stable (Prudynt) builds, the OSD overlay is rendered as an SVG overlay in the Web UI only -- it is not burned into video. See [Streaming and Video](05-streaming.md) for the full OSD story.

### Live View (fMP4)

Since ciao 2026-09-09, Prudynt builds ship a native low-latency live view: the **Live View (fMP4)** page plays the camera's H.264 stream directly in the browser. No re-encoding -- it reuses the existing encode, so image quality matches what RTSP viewers get, with audio playback (volume slider + mute) and zoom controls. Switching main/sub streams is race-free, and streamer plugin preview pages integrate on it like on the classic preview.

Since ciao 2026-09-10 (`a3c1847e8`), Live View (fMP4) is the **default** preview that loads with the camera's page; the classic MJPEG preview remains available alongside it. Both preview styles, plus direct MJPEG stream URLs, are authenticated with the camera's API key (`/etc/thingino-api.key`, passed as `?token=...`) -- direct stream URLs embedded in other tools must include the token parameter.

**Since ciao 2026-09-24, the default preview page is the new PTZ live view** (`/preview.html`): the fMP4 live view with pan/tilt controls, ten preset slots and the OSD overlay combined on one page. The plain fMP4 player remains reachable at `/preview-fmp4.html` (MJPEG unchanged). Preset slots: long-press to name and store the current position, right-click to delete. On cameras without pan/tilt hardware the controls render disabled behind a note, so the same page works everywhere; after a playback stall the player seeks back to the live edge instead of staying behind.

**Fixed 2026-09-14 (ciao `74cf774a4`, prudynt-t `354b1b4`): memory exhaustion with multiple fMP4 preview viewers.** Under multi-client load the fMP4 preview could exhaust camera RAM and take the streamer down. Prudynt-t now releases the fMP4 worker claim after the last previewer disconnects and recycles frame buffers between sessions. If your camera has dropped its stream while the fMP4 preview was in use, flashing a ciao build from 2026-09-14 or newer resolves it.

**Fixed 2026-09-21 (ciao `229c87945`): long-session stability.** The fMP4 preview could die after many minutes (`ERR_INCOMPLETE_CHUNKED_ENCODING` in the browser console) when the camera's send buffer backed up, and a stalled playhead -- background tab, blocked autoplay -- let the buffered video grow without bound. The preview now reads and appends independently with a byte-capped backlog, trims its buffer against the live edge, and **reconnects automatically** after a drop instead of leaving a black player. Long sessions on older builds: refresh the page, or flash a ciao build from 2026-09-21 or newer.

**Since ciao 2026-09-29, the preview pages show a strip of direct-stream endpoint links** below the player: RTSP, fMP4, MJPEG, and snapshot URLs for both the main (ch0) and sub (ch1) streams. Click any link to copy its URL to the clipboard. The RTSP links embed your RTSP username and password (default `thingino`/`thingino`), and the browser/stream/snapshot links include your camera's API key as a `token` parameter, so a copied URL works as-is in another player or tool. The strip follows your configured RTSP endpoints, port, and credentials, and appears on both the classic MJPEG preview and the fMP4/PTZ live view.

**Fixed 2026-10-03 (ciao `d61abd1a2`): fMP4 preview drifting minutes behind.** After a playback stall the camera could keep feeding stale fragments at exactly realtime, so the video played smoothly at 1x while sitting tens of seconds behind the actual scene -- and never recovered until a manual refresh, because the player only compared the playhead to its own buffer (which stayed ~1 s ahead no matter how stale the content was). The player now anchors the stream position to the wall clock and silently reconnects when it detects real drift. If your preview lags the scene, refresh the page once; builds from 2026-10-03 keep themselves honest afterwards.

**Fixed 2026-10-03 (ciao `95e64d6c2`): tiny 16x16 MJPEG on T23 cameras.** A query-string parsing bug in Prudynt's inter-process channel could misread the `ch=1` parameter of one viewer as a 1-pixel height for another, shrinking the shared JPEG encoder to 16x16 pixels for the rest of the stream's life on some T23 builds. The parser now matches whole parameter names only. If your MJPEG preview or stream pages showed a thumbnail-sized image, flashing a ciao build from 2026-10-03 or newer fixes it permanently.

**Fixed 2026-10-04 (ciao `9ba8919c2`, prudynt-t `6e48034`): fMP4 preview frozen on the first frame when the audio encoder fails.** Prudynt advertised an audio track in the fMP4 preview even when its audio encoder had failed to start (the encoder object existed but produced no frames), so the browser waited forever for audio data that never came and never played the video either -- the preview froze on frame one until a page reload briefly recovered it. The audio track is now only advertised when the encoder is actually running: affected cameras get a video-only preview that plays normally, and cameras with healthy audio keep it. If your preview locks on the first frame, a ciao build from 2026-10-04 or newer is the fix.

**Since ciao 2026-10-06, the fMP4 live view also plays H.265 main streams.** The player first tries the browser's built-in decoder (works in Safari and in Chrome/Edge with hardware HEVC), and where that is unavailable -- plain `http://` pages in Chromium, or Firefox -- it falls back to a WebCodecs canvas player instead of showing nothing; a status line points at the H.264 substream if the browser cannot decode at all. A header-repair fix (ciao `151cc18d8`) in the same batch corrects a corrupted H.265 header that previously made the preview reconnect forever instead of starting. On older builds an H.265 main stream shows "unsupported codec" -- switch the previewed stream to H.264, use the MJPEG preview, or flash a ciao build from 2026-10-06 or newer.

## PTZ Controls

Two control modes are available under **Settings -> Pan/Tilt Motors -> Behavior -> Preview PTZ controls**:

- **Step move** (default) -- Click or double-click directional buttons to move in steps
- **Continuous move** -- Press and hold directional buttons for smooth continuous movement

## Streamer

The Streamer section contains OSD editor, main stream, sub-stream, image, and sensor configuration. The sensor page reports the real SoC family (fixed in ciao `51dc49f77`, 2026-10-06 -- it could previously show the wrong family on some builds).

On stable builds using Prudynt, the Web UI talks directly to the streamer's API on port 8080 using an API key stored at `/etc/thingino-api.key`. If settings fail to load or save, the API key may be missing or the streamer may not be running.

### OSD Editor

The OSD editor at **Streamer -> OSD** lets you add, remove, and configure elements (timestamp, hostname, IP address, uptime, gain, static text, logo). Each element has position, font, color, and format settings.

Recent ciao builds support both SEI metadata mode (default) and an optional **burn-in** mode that renders the OSD directly into video pixels, making it visible in RTSP players and recordings.

### Timelapse

The Timelapse tool is now part of the streamer packages instead of a shared Tools page. On Prudynt (stable) it works via a cron schedule invoking the streamer's `timelapse` command; on Raptor (master) it drives the `[timelapse]` section of `raptor.conf` (enabled, interval, playback\_fps, file\_frames, max\_mb) through `raptorctl`, with native capture and rotation -- no cron needed. Find it under the Services menu on both streamers.

On TIMPS cameras the built-in timelapse **player** (in the camera's web UI) got a playback-smoothness overhaul on ciao builds from 2026-09-20: frames are served without closing the connection each time and the player keeps a deeper prefetch window, so playback no longer stutters between shots.

## Web UI Plugin Architecture

Thingino's Web UI uses a modular plugin system. Optional packages ship their own configuration pages as plugins that are automatically integrated into the navigation menu at build time. If a package is not installed, its Web UI pages simply don't appear -- no stale menus or dead links.

Currently migrated to the plugin system:
- **Motors** (PTZ configuration)
- **Day/Night** (IR-CUT, IR LEDs, scheduling)
- **GPIO** (pin configuration)
- **MQTT** (broker subscriptions)
- **Telegram Bot** (notification configuration)
- **WireGuard** (VPN setup)
- **ZeroTier** (network overlay)
- **Privacy** (privacy mask configuration)
- **SNMP** (monitoring)
- **Doorbell** (chime and button configuration)
- **Wyze accessories** (when the camera supports them): Floodlight v1 light control, and **Lamp Socket** power control (since ciao `3eabd559b`, 2026-10-06 -- the socket's switched outlet exposes on/off in the Web UI and as a Home Assistant `switch` entity; see [Home Automation](09-home-automation.md))
- **Commands and logs** (since ciao `5d05ecb37`, 2026-10-06): the former eleven separate Information entries are folded into one page with tabbed sections (Files / Logs / Info); deep links of the old `info.html?<section>` form still work
- **Streamer pages** (OSD, streams, image, sensor, audio) -- per-streamer plugins; Prudynt pages ship with the prudynt-t package, Raptor pages with the thingino-raptor package, and TIMPS pages with the timps package

Note: On master builds using Raptor there is no streamer config API. Stream settings must be edited directly in `/etc/raptor.conf` (see [Streaming and Video](05-streaming.md)). From builds of 2026-08-28 (`cdb3b8f26`) the Image page controls (white balance, gain, AE compensation, flips) are wired to the agent API and work in the Web UI; only stream parameters still require editing `raptor.conf`. On master builds using **TIMPS** instead, the full set of streamer pages is available in the Web UI (streams, OSD, image, sensor, audio, motion, privacy, recordings, timelapse) via the timps plugin; the raw config stays at `/etc/timps.conf` under **Info -> File: timps.conf**.

## Settings

Network, video, motion, OSD, and system configuration. Advanced settings are available through the configuration editor, which directly edits `/etc/thingino.json`. You can also use the `jct` CLI tool from the shell.

## Tools

Email, webhook, ntfy, gotify, FTP, storage, diagnostics, and more. Speaker configuration is available under **Motion Guard** when a speaker is present. (MQTT, Telegram, and VPN tools have migrated to the plugin-based Settings pages.)

The **Cameras on LAN** page lists other Thingino cameras discovered via mDNS. Since ciao 2026-09-03 / master 2026-09-05 it shows model, firmware build, and streamer for each camera, sorts by column, caches results between visits, and highlights the local camera's row (the streamer name is plain text, not a link). Discovery is bounded and complete, so large networks don't truncate the list. On cameras running Prudynt, the build ID for each camera links directly to its exact commit on GitHub.

Discovery is also tuned for busy networks: the browse runs two short passes with merged results (so a dropped multicast reply on congested Wi-Fi doesn't make a camera vanish), and per-camera detail queries are batched to avoid flooding the network.

---

<- [Previous: First Boot & Initial Setup](02-first-boot.md) | [Next: Networking](04-networking.md) ->

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

## Network Watchdog (netwatch)

Ciao builds from 2026-09-10 include an optional **network watchdog** that can reboot the camera when it loses connectivity: every 30 seconds it pings the network gateway, and after 3 consecutive failures it reboots the camera. A hardware watchdog backs the mechanism up, so even a completely wedged network stack cannot block the recovery reboot.

**As of 2026-09-20 the watchdog is opt-in** -- it no longer arms by default. (Earlier ciao builds rebooted every unit after 3 failed pings, which could turn a marginal Wi-Fi link into a reboot loop.) Enable it under **Settings -> Network** or in the config:

```sh
jct /etc/thingino.json set netwatch.enabled true
```

Arm/check/reboot decisions are logged -- when diagnosing a flaky link, look for the `netwatch` tag in `logread`.

Keys: `netwatch.enabled` (default `false`), `netwatch.fail_count` (default `3`), `netwatch.interval` (default `30` seconds).

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

Since ciao 2026-09-03, the mDNS daemon watches **all** network interfaces in client mode instead of pinning to the first up non-loopback one. Previously a camera with a disconnected Ethernet port and an active WiFi connection could bind mDNS to the dead `eth0` and vanish from LAN discovery scans entirely; interfaces that come up later are now picked up automatically too. In AP/captive-portal mode the daemon still pins to a single interface so phones connecting to the camera's hotspot don't get a captive-portal login prompt pushed at them.

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

## RTSP

RTSP is the primary streaming protocol. Streams are available at:

```
rtsp://thingino:thingino@<camera-ip>:554/ch0   (main stream)
rtsp://thingino:thingino@<camera-ip>:554/ch1   (sub stream)
```

### Testing the stream

```sh
curl -v -X DESCRIBE rtsp://thingino:thingino@192.168.1.10:554/ch1
```

### Saving to file

```sh
ffmpeg -i rtsp://thingino:thingino@192.168.1.10:554/ch1 -map 0 -c copy -f mpegts record.ts
```

### Low-latency playback (mpv)

```sh
mpv rtsp://thingino:thingino@192.168.1.10:554/ch0 \
  --profile=low-latency --no-cache --cache-secs=0 \
  --demuxer-readahead-secs=0 --cache-pause=no
```

## WebRTC (Live View)

> **Note:** WebRTC is only available with **Raptor**, which is in development builds only. It is **not available** in stable release builds (which use Prudynt).

When available, WebRTC provides ultra-low-latency live view in the Web UI. The camera's streaming daemon handles WebRTC negotiation automatically.

### WebRTC / WHEP on TIMPS (v1.9.13+)

TIMPS gained its own WebRTC implementation in v1.9.13, refined through v1.9.14. It serves a standard **WHEP** endpoint (WebRTC-HTTP Egress Protocol): a player POSTs an SDP offer to the camera and receives H.264 video (plus audio) over ICE-lite/DTLS-SRTP -- no plugin, and none of the MSE buffering the fMP4 preview has.

```
POST   http://<camera-ip>:8880/webrtc/whep        # send the SDP offer, get the answer
DELETE http://<camera-ip>:8880/webrtc/whep/<id>   # tear a session down
```

A standalone test page ships with the TIMPS source (`scripts/whep-test.html`).

Deliberate limitations, worth knowing before you try it:

- **LAN/VPN only** -- one host candidate, no STUN/TURN, no NAT traversal, no IPv6
- **H.264 video only** (the `webrtc.channel` stream) plus **G.711 audio** (PCMU/PCMA) only when the camera actually encodes G.711 -- on AAC cameras, turn on the second encode with `audio.codec2` (below). No Opus, AAC or H.265 over WebRTC; no transcoding
- **No NACK/retransmission, FEC, or congestion control** -- a LAN live-view path, not a loss-recovery one
- **Firefox usually will not decode it** (the answer's `profile-level-id` comes from the live SPS, which defaults to High profile); Chrome/Chromium is the tested target
- **At most 4 concurrent sessions** -- a 5th offer gets `503`, and stalled sessions are reclaimed after 30 seconds

The endpoint is compiled in behind a build flag and **runtime-gated by `webrtc.enabled`** in `/etc/timps.conf`: `1` = on, `2` = on and also accept plaintext WHEP POSTs on a TLS port (the default on WebRTC builds since v1.9.14), `0` = off. With a TLS-protected port (`http.https=1`), plaintext WHEP POSTs are otherwise refused with `426 Upgrade Required` -- signalling belongs on HTTPS. Note that since 2026-09-15 the ciao TIMPS package selects the WebRTC build flag by default (commit `bf0c9111e`; master's package was brought in line on 2026-09-26), so recent images of both branches ship with the endpoint compiled in -- no custom build needed. Older images still lack it.

### WebRTC audio on AAC cameras (`audio.codec2`)

TIMPS v1.9.13/v1.9.14 add an optional **second audio encode** whose only job is to feed WebRTC's G.711-only path: the camera encodes AAC (for RTSP/fMP4) and PCMU side by side. `audio.codec2` in `/etc/timps.conf` accepts `pcmu` or `off` and defaults to `pcmu` on WebRTC builds. The same releases polished the remaining WebRTC audio defaults: `audio.gain` returned to 25, and the inbound SRTCP replay protection is keyed per sender SSRC.

> **Firefox note:** If you get a 400 Bad Request error, set `media.gmp-gmpopenh264.enabled` to `true` in Firefox's `about:config`. The camera only supports H.264 video.

### Server-side stats (`GET /control?stats=1`, v1.9.16+)

The control API gained a server-side stats endpoint, separate from the per-stream stats: `curl http://<camera-ip>:8880/control?stats=1`. It reports the streamer's own counters (session counts, encode drops) in the same JSON shape as the rest of `/control`. Note the scoped-sub-endpoint convention that also landed in v1.9.16: `?stats=1` and friends are matched as scoped queries rather than free-form config reads.

## ONVIF

Thingino provides ONVIF Profile S compliance, enabling compatibility with NVRs, VMS software, and home automation platforms. ONVIF services include:

- Media streaming (RTSP)
- PTZ control
- Event notifications (motion detection)
- Imaging settings

ONVIF motion events work with UniFi Protect and other NVRs that support third-party ONVIF cameras.

Recent builds fix a crash in ONVIF `GetProfiles` when audio output is disabled -- some NVRs would fail to add the camera if it reported audio capabilities it could not deliver.

## OSD (On-Screen Display)

Thingino supports customizable OSD overlays with the following element types:

- **Timestamp** -- Display current date/time (strftime format)
- **Hostname** -- Camera hostname
- **IP Address** -- Camera's IP address
- **Uptime** -- Time since boot
- **Gain** -- ISP gain indicator
- **Static Text** -- User-defined text label
- **Logo** -- Custom image overlay

### How OSD Works on Stable (Prudynt)

On stable release builds, OSD data is **embedded as SEI metadata** within the H.264 stream by default -- it is **not burned into the video pixels**. This means:

- Standard RTSP players (VLC, Blue Iris, Frigate) **cannot display** the OSD overlay
- Only the Thingino **Web UI dashboard** renders the OSD (as an SVG overlay on top of the video)
- The OSD is not visible in recorded video clips
- This design avoids performance issues on less powerful camera hardware

Recent ciao builds add an optional **burn-in** mode (`BR2_PACKAGE_PRUDYNT_T_OSD_BURNIN`) that renders OSD directly into video pixels at build time. This makes OSD visible in all RTSP players and recordings.

### Sub-Stream OSD Burn-In Control

With Prudynt 0881124 (now in ciao), you can keep OSD burned into the main stream while disabling the burned-in timestamp on the sub-stream:

```sh
jct /etc/prudynt.json set osd.burnin.substream_disabled true
service restart prudynt
```

This is a config-only flag -- the Web UI SVG overlay (SEI) works on all streams when `osd.sei.enabled` is set to `true` (it is off by default and must be explicitly enabled).

On Raptor (master), per-stream OSD control is a native config key: set `osd_enabled = false` under any `[streamN]` section in `raptor.conf` to drop the OSD from that stream while keeping it on others.

### Prudynt Reliability Improvements

Recent Prudynt updates (b8d94db) include:

- **UDP burst handling** -- Initial frame bursts are now paced to prevent jitter buffer overflow in RTSP clients
- **RTCP SR reliability** -- Sender reports use a fresh clock sample for accurate NTP-to-RTP timestamp pairing
- **JPEG encoder FPS** -- Uses configured FPS instead of a hardcoded 24 fps
- **Night FPS** (Raptor, master) -- `night_fps` knob in the stream config lowers the frame rate in night mode to save bandwidth and reduce noise (e.g. `jct /etc/raptor.conf set stream0.night_fps 10`)
- **Shutdown stability** -- Prevents hang in video/JPEG worker threads during shutdown
- **RTSP audio-only fix** -- Audio-only RTSP sessions no longer crash or hang (Prudynt 6afc440)

### Stream watchdog (Prudynt builds, September 2026)

Prudynt now ships with a supervisor: if the streamer dies (crash, OOM kill), the `S32prudyntwd` watchdog detects it within about a minute and restarts it automatically — previously a dead streamer stayed dead until a manual reboot. How it behaves:

- Liveness is probed via the local HTTP API (with an RTSP probe as fallback), so it works regardless of RTSP authentication settings.
- After 3 failed restarts in a row it backs off for 10 minutes between rounds, letting transient faults clear instead of restart-looping.
- If the streamer still has not recovered after 9 failed restarts (~34 minutes), the camera **reboots itself** (with a hardware-watchdog fallback in case the normal reboot path is wedged).
- **Fixed 2026-10-03 (ciao `2b9361fb0`): the watchdog could not clear a wedged streamer.** When Prudynt hung inside a driver call, the stop routine could not kill the process (logging "no /usr/bin/prudynt found; none killed"), so the watchdog's restart was a no-op and the camera stayed streamless until a manual reboot. Stop now captures the PID before the pidfile is removed and force-kills it directly. If one of your cameras "only a reboot fixes", a build from 2026-10-03 or newer addresses it.
- To disable the self-reboot and only log/back off, edit `REBOOT_AFTER=0` in `/etc/init.d/S32prudyntwd`.

### PTZ Live View (Prudynt builds, ciao 2026-09-24)

Prudynt builds gain a combined live view: the H.264 stream plays in the browser with pan/tilt controls, ten preset slots and the OSD overlay on a single page. It lives at `/preview.html` and is what the **Preview** nav item opens from 2026-09-24; the plain fMP4 player remains at `/preview-fmp4.html`. Presets are managed in-page: long-press a slot to name and store the current position, right-click to delete it. On cameras without pan/tilt hardware the controls render disabled with a note, so the page serves as a universal default.

### Colour Fidelity (full-range luma + colour matrix in SPS VUI)

If video from a Prudynt camera looked washed out or had slightly wrong colours in some players, firmware from 2026-08-25 (prudynt-t `b609f30`) fixes it. The encoder now declares full-range luma and an explicit BT.709 colour matrix in the H.264/H.265 SPS VUI, at every resolution -- the pipeline is BT.709 end to end, so a low-resolution substream publishes the same matrix as the main stream and the JPEG snapshot. Previously the stream could be signalled as limited range or even an invalid `gbr` matrix, which some decoders honoured literally. (An earlier revision of the fix wrongly labelled sub-720p streams BT.601; that was a mistake, corrected.) The signal now matches the actual pixels; no configuration needed.

### Automatic Bitrate Scaling

Prudynt (since `3188189`) derives each stream's default bitrate from its encoded resolution -- roughly 1 Mbps per megapixel -- instead of a fixed value. Users who set an explicit bitrate keep their setting; this only affects streams left at the default.

### Restoring OSD in RTSP and Recordings (SEI Mode)

Two scripts on the firmware repo's `ciao` branch handle post-processing:

- **`sei-overlay.py`** -- Extracts SEI metadata from recorded MP4 files and burns it into the video, or exports as ASS/SRT subtitles
- **`sei-rtsp.py`** -- Real-time tool that pulls a live RTSP stream, extracts SEI, and re-broadcasts with OSD burned in (via ffmpeg drawtext)

### OSD Configuration

OSD is configured per-stream in `/etc/prudynt.json` under `osd`. Each element has a type, format, and position. Position uses `x,y` format with negative values offset from the right/bottom edge. The Web UI has a dedicated OSD editor at **Streamer -> OSD**.

### Creating a Logo

Create a transparent PNG, then convert to BGRA:

```sh
convert logo-100x30-alpha.png -depth 8 bgra:logo.bgra
```

## TIMPS (Alternative Streamer)

TIMPS (Tiny IMP Streamer) is a lightweight streamer available as an alternative to Prudynt/Raptor. As of v1.9.19 (ciao builds from 2026-09-23), a dropped P-frame reliably triggers an instant keyframe recovery request across all transports -- RTSP, SRT, WebRTC and fMP4 -- instead of leaving a smeared picture until the next natural keyframe (per-protocol 1-second gates used to swallow some recovery requests); and ciao builds apply per-camera `timps.conf` defaults from the camera profile automatically (firmware `ccc103513`), so a profile-tuned camera needs no manual streamer config. On recent builds TIMPS installs its own Web UI plugin (preview page, motors controls, SSE position fallback -- 2026-09-04, firmware commits `39523b778`/`7b4e81dc3`). When using TIMPS, these features are available:

### Live Control API

TIMPS exposes a live control API at `http://<camera-ip>:8880/control` (GET to read, POST to change):

- Adjust bitrate, FPS, GOP, and resolution on the fly
- Toggle audio, backchannel, privacy mode
- Control motion sensitivity in real time (IMP_IVS)
- Take snapshots
- Encoder rate-control knobs (qp, min/max QP, quality_lvl, i_bias_lvl, fluc_lvl) -- applied live where the SoC allows, with `deferred_keys` in the reply naming anything that waits for a restart
- `encoder.<n>.rc` readback showing what the encoder actually holds right now

Example -- change main stream bitrate:

```sh
curl -X POST http://192.168.1.10:8880/control -d '{"stream0.bitrate": 2000000}'
```

The reply names any request fields it ignored, so a typo in a mixed request no longer looks like a clean success.

### Day/Night Detection

TIMPS has built-in adaptive day/night detection with configurable boot-settle period and periodic night reconfirmation. This prevents false day/night flapping from temporary light changes.

**v1.9.6 (2026-09-01) adds browser push-to-talk and fixes day/night on cameras that rest fully dark.** Highlights:

- **Talk through the camera from the browser.** The preview gains a talk button: the page captures your microphone and streams it to the camera's speaker over a WebSocket (`/talk` endpoint), alongside the existing RTSP/ONVIF talk paths. Multiple simultaneous talkers are arbitrated the same way as RTSP talkers, and a stalled WiFi connection drops its audio backlog instead of playing it seconds late. Runtime `audio.talk_ws` in `/etc/timps.conf` (default off, restart to apply): `0` = disabled, `1` = on but TLS-only, `2` = on and accepts plain `ws://` too (for a camera without HTTPS where you grant the origin a secure context by hand in the browser -- mic audio then crosses the network unencrypted). Since firmware v1.9.7 the feature is compiled in by default (`BR2_PACKAGE_TIMPS_BC_WS`, no longer requires TLS at build time) and `audio.backchannel`/`audio.talk_ws` auto-enable when built in.
- **Day/night fix for boards whose dark rest state is a fully-clipped meter** (zero exposure headroom, e.g. the T20 in Wyze Pan): the night reference and the trend detector could both get permanently stuck on such cameras, leaving only the 12-hour reconfirmation heartbeat. A clipped reading that has held stable now counts as valid data for both paths.

**v1.9.8 (2026-09-03) hardens recording and transport edges.** Recording now prunes with a sanity-capped `record.min_free_mb` -- absurd values are refused and surfaced via `/control` status instead of wedging the SD loop, and the recorder backs off gracefully while the free-space target stays unreachable. Pre-roll re-anchors to the oldest available keyframe in the ring, so clips start on complete frames. RTSP-over-UDP clients that reconnect from a new source port (NAT rebinding) keep receiving video without a client restart. Day/night gets an illuminator relight when an abandoned silent probe would otherwise leave the IR light in the wrong state.

**v1.9.9 (2026-09-07) tames night exposure and hardens the audio path.** Two day/night wins for night footage: a new opt-in `ae_it_max_us` key caps the AE integration time, so a dark scene can no longer stretch exposure far enough to smear motion across frames -- set it in `/etc/timps.conf` (e.g. `ae_it_max_us 20000` for a 20 ms ceiling); leaving it unset keeps the old uncapped behaviour. Day/night now reads the real AE exposure from IMP as its primary signal (with an estimate-based fallback when the scrape only has an estimate), so the dark/light decision tracks actual sensor exposure. On the audio side, the talk-back channel elects its owner only on real audio packets, so non-audio traffic can no longer claim the speaker. The built-in preview/control HTTP server accepts 16 concurrent clients (previously 8).

**v1.9.10 (2026-09-09) makes motion sensitivity changes stick.** Setting `motion.sensitivity` through `/control` or the Web UI now updates the running detector *and* survives a restart -- previously the new value could be reverted by a stale read-back and the change never reached `/etc/timps.conf`. Also along for the ride: the motion helper now spawns via `posix_spawn` (kinder to memory-tight cameras) and QA coverage for the encoder read-back path.

**v1.9.11 (2026-09-11) adds a proper HTTP/HTTPS mode switch and same-port HTTPS.** The new `http.https` setting in `/etc/timps.conf` is a tri-state: `0` = plain HTTP (was the only behaviour of the setting before), `1` = the web UI port serves HTTP and HTTPS together (the server peeks at each connection's first byte and answers HTTP or TLS accordingly), `2` = HTTPS only, plain-HTTP requests are rejected. Self-signed TLS certificates are generated for you when strict mode (`2`) is enabled. Practical effect: a camera without a trusted certificate no longer has to choose between a broken HTTPS preview and an unencrypted port -- mode `1` lets normal browsers keep using `http://` while apps that require a secure context (camera-add flows, PWA installs, some mobile clients) get a real `https://` endpoint on the same port. Firmware-side (ciao PR `#1626`/`#1627`), the setting is only auto-written when the uhttpd redirect prerequisite is present, and the web UI's preview links follow the page scheme. This ships with the v1.9.11 binary -- older v1.9.10 builds misread the `2` as plain HTTP, so the firmware pin bump matters.

> **Note on pins:** ciao bumped to TIMPS v1.9.11 on 2026-09-12 (PRs `#1626`/`#1627`); master caught up the same day with the v1.9.8 -> v1.9.11 bump (PR `#1635`). Everything above ships on new images of both branches.

**v1.9.12 (2026-09-12) rounds out v1.9.11's HTTPS story:** with `http.https=1`, HTTPS responses now gain `Cross-Origin-Opener-Policy`/`Cross-Origin-Embedder-Policy` headers so browser camera-add and PWA flows treat the camera as a secure context, and a plaintext WHEP POST to a TLS port is refused with `426 Upgrade Required` instead of silently misbehaving.

**v1.9.13 (2026-09-13) adds the WHEP WebRTC endpoint** described in the WebRTC section above -- first release to ship it.

**v1.9.14 (2026-09-14) makes WebRTC the default where it exists and polishes its audio:** `webrtc.enabled` now defaults to `2` (on, plaintext-accepting) on WebRTC builds, the WebRTC audio path defaults to G.711 (`audio.codec2=pcmu`), and `audio.gain` is back at 25 after the brief 15 experiment. The endpoint distinguishes "disabled by config" (`503`) from "not built in" (`404`).

**v1.9.23 (2026-09-25) polishes the live-control contract and speeds up WebRTC crypto.** `POST /webrtc/whep?chn=N` picks the video stream per session (main/sub) without changing the global `webrtc.channel` default -- an out-of-range, not-running or non-H.264 stream is refused with `400` (`caps.webrtc.chn_select: 1` advertises the feature). `/control` now grades the audio and OSD sections correctly: keys that genuinely need `S95timps restart` (e.g. `audio.codec`, `osd.enabled`) are listed by name in `caps.restart` and come back in the POST reply's `deferred_keys`, and the Web UI stops asking for pointless restarts; `videoN.rtsp_path` is no longer reported as deferred. WebRTC SRTP encryption is 2.4x faster (390 -> 165 us per packet on a T31). The auto `sensor.fps` cap now follows the fastest enabled `videoN.fps` instead of hard-stopping at 30.

**v1.9.24/v1.9.25 (2026-09-26) answer "who is watching this camera?".** `GET /control?clients=1` lists every connected consumer -- RTSP sessions, fMP4/MJPEG/events connections, WebRTC sessions and SRT receivers -- each with `ip`, `port`, `proto`, `chn`, `since_s` (connected seconds), a live `kbps` reading and the client's `agent` (User-Agent, e.g. `FFmpeg Frigate/0.17.2` or `LibVLC/3.0.20`). One-shot requests (snapshots) are not listed; the table costs ~8 KB RAM for 40 entries. v1.9.25 adds per-client `bytes` (total sent since connect) and connect/disconnect log lines naming the User-Agent and bytes moved, so a client that wedges and vanishes silently leaves a trail. The TIMPS Web UI shows the same table with a Total column.

**v1.9.26 (2026-09-26) adds per-client latency.** `GET /control?clients=1` gains `lat_ms`: how old a frame is when timps hands it to each client (sensor capture to send, averaged) -- typically 5-25 ms on T31 -- across RTSP, WebRTC, fMP4, MJPEG and SRT. The Web UI shows a Latency column, and the preview status line adds the browser's own share (`delay ≈ N ms`: network + jitter buffer + decode for WebRTC, decode + render for the realtime modes, playback buffer for the MSE modes) with the breakdown as a tooltip.

**v1.9.27 (2026-09-27) fixes scheduled day/night switching far from Greenwich.** In `mode=schedule` the sunrise/sunset calendar picked "today" by the UTC day, so west of roughly the US Pacific coast the calendar day rolled over hours before sunset: the camera adopted the *next* day's times and flipped to night at UTC midnight -- 17:00 on the US west coast -- instead of at real sunset. The calendar day is now chosen by local solar time, so the chosen date always contains the sunrise/sunset it refers to. Reported from Vancouver and covered by a new unit test (`scripts/test_daynight_sun.c`).

**v1.9.28 (2026-09-28) is a security and reliability hardening pass over the whole daemon.** The changes a camera owner notices: the `osd.vars_file` config key is gone -- the `{placeholder}` vars file is now fixed at `/tmp/timps_osd.vars` -- because the key was remotely settable through `/control`, letting a caller render secrets from `/etc/timps.conf` into the video overlay; cross-origin POSTs that ride cached browser Basic/Digest credentials are refused with `403 bad origin` (browsers re-send those credentials on any cross-site form post, so a random web page could otherwise drive `/control` on a camera you are logged into -- token, loopback and script clients that send no `Origin` header are unaffected); RTSP closes a connection after 5 rejected logins (ending unlimited password guessing on a single connection) and drops connections that never reach `PLAY` within 60 s, so idle `OPTIONS` loops can no longer lock everyone out; and config rewrites keep the file's permissions, so a hand-applied `chmod 600` on `/etc/timps.conf` survives POSTs instead of being reset to `0644`. Two storage-safety changes: `record.dir`/`timelapse.dir` pointing at the root filesystem are refused (an SD mount point with no card in it used to silently record into flash; the refusal also shows up in `record.last_error`), and a too-large `timelapse.keep_days` no longer deletes the whole archive -- the retention cutoff used to overflow 32-bit arithmetic into the future, so `99999` meant as "keep forever" expired every single shot; the key is now clamped to 0..3650. On T23 builds with software rotation, OSD `font_size` is now absolute pixels like every other path, so text on a rotated sub-1080 stream may need a smaller value. Performance: RTSPS video goes out in staged 16 KB TLS writes instead of one TLS record per packet (one RTSPS client now costs 13.6% CPU against plain RTSP's 7.4%, previously roughly double), cold streams deliver their first frame in 64-137 ms, `GET /control` no longer stalls when the SD card wedges (`record.free_mb`/`timelapse.free_mb` refresh on a 10 s background clock), and a `{"record":{"clip":...}}` capture no longer blocks every other `/control` POST for its whole duration. SRT listeners without a passphrase now log a warning when RTSP/HTTP credentials are set, since such a listener serves video to anyone.

> **Note on pins:** the 2026-09-26 firmware pin batch closes a four-release lag in one go: ciao jumped v1.9.22 -> v1.9.26 (PR `#1706`), and master's package was brought in line with ciao, v1.9.8 -> v1.9.26 (PR `#1707`). Lu-Fi kept the cadence the next day: v1.9.27 was pinned on both branches within the hour of release (PRs `#1709` ciao / `#1710` master). New images of both branches carry everything above, including the streaming-client table, the latency display and the v1.9.27 day/night calendar fix. timps upstream released v1.9.28 (the security hardening pass, see its entry above) on 2026-09-28; the firmware pin batch for it had not landed at the time of writing, so new builds still carried v1.9.27 until it does.

**v1.9.5 (2026-08-29) fixes fMP4 lip-sync after WiFi stalls, shares the web UI's TLS certificate, and cuts OSD CPU cost.** Highlights a camera owner would notice:

- **A/V sync after a network stall (browser/MP4 playback).** If a weak-WiFi client stalled for more than 10 seconds, the video track silently fell behind audio by the length of the stall and stayed offset for the rest of the session (a real 24-second skew was captured in QA). The video timeline now re-anchors to true media time, so lip-sync survives delivery gaps. RTSP playback was never affected; this hits the MP4/preview path and the SD recorder.
- **HTTPS preview on iOS Safari.** The preview at port 8880 now presents the *same* TLS certificate as the web UI on port 443 (via a symlink resolved at boot). Previously the second self-signed cert could not earn browser trust from JavaScript -- Safari shows no click-through for a failed fetch, so enabling HTTPS produced a silent "Load failed" error. One trust decision now covers both ports.
- **TLS session resumption** (RFC 5077 tickets) -- repeat HTTPS/RTSPS connections skip the expensive full handshake.
- **OSD rendering is ~39% cheaper on the CPU** (measured on T31), from a rewritten TrueType glyph rasterizer. Visually identical output.
- **Numerous internal performance wins** (batched TCP RTSP sends, hourly timelapse retention, one clock read per frame) that reduce CPU load and SD-card churn on long-running cameras. The recording prune is now a single SD walk; if you tune `record.min_free_mb` upward, note it lives (default 200 MB, applies live on the next record cycle, documented range 0-1048576).
- Day/night board hooks (`daynight.switch_cmd`/`irprobe_cmd`) that hang can no longer freeze day/night switching or daemon shutdown -- they are killed after a timeout.

**v1.9.3 (2026-08-23) makes boot measure before it decides, and made the daemon survive bad restarts.** Three fleet-incident fixes:

- **Boot no longer trusts the saved day/night state.** The old path restored the persisted mode immediately and never physically asserted it on the board -- five fleet cameras that rebooted after dark spent the night with the IR LEDs off because the runtime state file resets to `day` on every reboot and nothing re-drove it. Boot now waits for the AE to settle, runs one ordinary probe, and asserts the measured answer on the board once. `daynight.boot_probe=0` opts out of the *measurement* only -- the persisted value is still asserted physically.
- **A service restart can no longer strand the daemon dead.** After `S95timps restart`, the old instance's rmem is not always released when the new one starts, and a single encoder-start failure used to exit the process permanently (5 of 12 cameras died this way on 2026-08-22). Start failures now retry with backoff, are capped at 10 attempts, and escalate to exactly one real reboot before giving up -- a persistent marker file guarantees it cannot become a boot loop.
- **The rate-control keys became real config keys and apply live where the SoC allows.** `videoN.quality_lvl`, `change_pos`, `i_bias_lvl`, `fluc_lvl` were hardcoded literals; `qualityLvl` in particular imposed an invisible 60% bitrate floor (measured: 2091 kbit/s where the scene needed 278). Live application per platform is advertised honestly via `caps.video_live`, and POST replies carry `deferred_keys` listing anything that waits for a restart. `GET /control` gains `encoder.<n>.rc` -- a live readback of what the encoder actually holds, so writes can be verified against reality. The `daynight` config surface shrank by ten keys (`learn`/`state_path` removed, eight tuning constants hardcoded -- old configs still parse with a grace-period warning).

**v1.9.2 (2026-08-21) closed the day/night trust loop against the hardware.** A camera could switch itself to day, log success on every layer, and have the ISP keep rendering night for half an hour -- the automaton trusted its own commanded state and only WARNed on divergence, never the actual readback. The ISP's reported running mode is now a first-class sample, and every mode switch arms a verification 18 s later: agreement closes quietly, disagreement warns and forces exactly one transition through the opposite mode (measured to be the only repair: a stuck exposure fell 131072 -> 5720). Persistent standing disagreement is reported but never enforced, so manual ISP overrides are not fought; `daynight.isp_desync` appears on `/control` and `/events` for dashboards.

**v1.9.1 (2026-08-21) hardened the v1.9.0 day/night automaton.** The fixes target a class of defects where the automaton *trusted measurements it should not have*: a railed AE meter (no exposure reserve left) can justify a "night" verdict but must never be remembered as a reference level -- a camera booting with its meter pegged at the dark end previously anchored its night reference on that worthless reading, making a twentyfold-too-dark night look normal. Clipped readings are now barred from long-term memory across the reference anchor, the revert ratchet, the filter-cost learning, the probe threshold diagnostic, and the trend memory. A railed boot is now repaired by a genuine mode transition through the other mode rather than re-asserting the running mode (re-assertion was a no-op on the already-persisted value). Cameras whose ISP dump lacks gain-ceiling fields (unknown AE reserve) no longer get structurally stuck in night mode: unknown reserve now escalates to the audible probe instead of being read as "proof" of a pegged meter. The day/night probe escalations from v1.9.0 now actually reach the audible path (an internal latch bug could silently loop probes forever without ever consulting the day pipeline), and the filter-cost projection verdict now lowers the reference like every other night verdict, stopping an every-26-seconds probe loop on scenes resting below the bar.

**v1.9.0 (2026-08-19) rebuilt the day/night automaton** around four independent decision paths with an IR-ratio verdict, a trend trigger (gradual light changes now trigger transitions without waiting for a sudden jump), and IR-ratio thresholds re-derived from a full night of data rather than estimates. The dusk-switch cost earlier testing suggested was withdrawn -- it turned out to be the test camera itself being tested.

You can now ask for a day/night probe on demand via the control API:

```sh
curl -X POST http://192.168.1.10:8880/control -d '{"daynight":{"probe":1}}'
```

This arms a silent IR probe for the next automaton tick -- useful to verify a camera can actually see daylight instead of waiting up to half an hour for the heartbeat. Cameras without `daynight.irprobe_cmd` configured cannot probe silently and report that refusal instead of silently doing nothing.

**v1.9.0 API grading changes:** `/control` now advertises what this build can do (capabilities) instead of overloading HTTP 422 for every refusal. Value rejection moved from 422 to 409, and an empty string clears a text field instead of being refused. API clients should treat these codes accordingly.

Earlier v1.8.x releases fix three compounding defects that caused a perpetual day/night flip loop, route the adaptive night-to-day transition through the brightening probe only (preventing oscillation), and warn on persistent running mode divergence. The GOP setting on new-API SoCs (T23+) is also fixed -- it was running at double the configured value. Additional fixes halve the sustained-brightening confirm period (60s to 30s) for faster day recovery, close an ambiguous-probe loophole that could cause a spurious day trigger, and guard the periodic reconfirm against baseline drift.

TIMPS images now also install the shared board day/night hardware scripts (`daynight`, `ircut`, `light`); previously only Prudynt builds got them, so a TIMPS camera could correctly detect night but fail to actually move the IR-cut filter or light the IR LEDs (image turns purple/IR-tinted). If you run a TIMPS build from before this fix (2026-08), update the firmware.

On master builds from 2026-09-04 (firmware commits `39523b778`/`7b4e81dc3`), the TIMPS package also brings its own Web UI preview page and motors controls, replacing the earlier thingino-webui fork approach. The motors page gains an SSE position fallback for builds without the WS transport, and the motors-UI reapply hook is applied via a global finalize hook so it wins its config merge deterministically.

**v1.9.0 reliability fixes:** shutdown no longer leaves stream threads running while tearing down their state (teardown with a client attached went from 20.5 s to 26-30 ms), SRT client sockets close before the shutdown drain, an fMP4 init segment can no longer ship with an empty codec configuration box, and software-rotation now enforces the configured FPS (measured on hardware).

### Data Race Hardening (v1.7.8)

TIMPS v1.7.8 adds C11 data race protections on live-mutable config. If you adjust stream parameters via the control API while streaming, changes are now atomic and cannot corrupt internal state.

### Optional Opus Audio

TIMPS can optionally stream audio using the Opus codec in addition to AAC.

### SSE Events

Server-Sent Events at `/events` provide real-time push notifications for motion, day/night changes, and other events.

### Browser Preview

TIMPS includes a built-in browser preview at `http://<camera-ip>:8880/` with snapshot, MJPEG, and MP4 streaming options.

## Two-Way Audio (RTSP Backchannel)

Two-way audio works over the RTSP backchannel (ONVIF Profile T). Clients send audio to the camera speaker; the camera picks the codec by what the client sends (TCP or UDP).

**Raptor (development builds)** now offers five talk-back codecs: **PCMU, PCMA, Opus, AAC and L16**, with UDP transport, receiver reports, and BYE leave handling. You can restrict the offer at build time with `backchannel_codecs` (e.g. `"pcmu,opus"`; empty offers everything the build carries). PCMU is the ONVIF Profile T baseline -- excluding it is honored but warned.

**Prudynt (stable)** offers PCMU, PCMA, Opus and AAC; `audio.output_enabled` gates the backchannel entirely.

## UDP Push (Raptor)

Raptor's RSP can push ring video to a raw UDP target (`udp://host:port` in the `[rsp]` section of `/etc/raptor.conf`). This sends RTP datagrams with no session or handshake -- ideal for WFB-NG and similar video links. SPS/PPS are sent in-band on every keyframe, and the sender waits for a keyframe before starting. Video only (audio still requires RTMP). Changing the scheme requires a restart.

## Video Privacy Mode

Privacy mode blacks out all video streams (RTSP, recordings, JPEG) while keeping the ISP running:

```sh
privacy on
privacy off
```

## Encoder Rate Control

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

<- [Previous: Networking](04-networking.md) | [Next: Storage and Recording](06-storage.md) ->

## SD Card

SD cards are mounted automatically at `/mnt/mmcblk0p1`, **async** on both ciao (since 2026-08-25) and master (since 2026-09-03, PR #1535), with a global dirty-page writeback bound. Sustained recording no longer stalls on every write to slow cards -- a long-standing source of periodic freezes and UI sluggishness on single-core cameras. Reliability is unaffected: diagnostics and recorder flows sync explicitly. A power cut can lose the last seconds of buffered writes (as with any async removable-media mount), but the filesystem itself is safe.

Format as FAT32 for best compatibility. Note that ext4 support is **not enabled by default** -- it requires enabling `BR2_PACKAGE_THINGINO_KOPT_EXTFS` in the build config. exFAT may also require additional kernel options.

### SD Card Tips

- Use a 2GB--8GB card for best compatibility. Some 16GB and 32GB cards may not be recognized in U-Boot's 1-bit MMC mode, particularly on T23N cameras.
- Card detected but never shows up as `/dev/mmcblk0`? On T31 cameras the advertised microSD/SDIO voltage window was too narrow (3.2--3.4 V), so some cards failed voltage negotiation during enumeration and never appeared. Master builds since 2026-09-18 advertise the full 2.7--3.6 V range and affected cards initialize normally. If a card works in other devices but never mounts on a T31 camera, update the firmware first.
- To trigger a diagnostics report via SD card, create a file named `.diag` in the root of a blank SD card and insert it into the running camera.

### SD Card on T40/T41 (XBurst2)

Recent master and ciao builds add SD card support on XBurst2 SoCs (T40/T41) via the MSC controller. Cameras that declare SD card support in their profile (three XBurst2 profiles already do) get the driver and automatic mounting.

## NFS Network Storage

Thingino supports NFS v2/v3 (not v4). To set up persistent NFS storage, configure the share path and the `S43mounts` init script mounts it automatically at boot:

```sh
jct /etc/thingino.json set nfs_share "server:/path/to/share"
```

The share will be mounted at `/mnt/nfs` on boot (using `-o nolock`). Verify with `mount | grep nfs`.

Since ciao 2026-08-25, NFS shares were mounted **soft** with bounded retries (`soft,timeo=30,retrans=2`) instead of hard. If the NFS server stalls or disappears, processes get an I/O error instead of hanging the whole camera in D-state. Access is also noticeably more responsive when the server is slow.

**Reversed on ciao 2026-09-03:** the mount is **hard** again (`hard,timeo=30,retrans=2`). In practice the soft mount turned a stalled server into silent data loss -- the recorder's write returns an error after ~9 seconds, and with no error checking in place the recording kept going with a hole in it (typically exactly where the MP4 init segment lives), producing unplayable files. A hard mount blocks instead of losing data. Check `mount | grep nfs` if a stuck write ever freezes the camera -- that is the trade-off.

Already have unplayable files from the soft-mount era? Since ciao 2026-09-06 the firmware tree ships `scripts/recover-nfs-recordings.py`, which repairs exactly this failure: it detects prudynt-t recordings that lost their MP4 init segment (the `ftyp`+`moov` bytes the lost writes swallowed), copies the init segment from a healthy recording of the same camera and stream settings (auto-detected, or `--donor FILE`), and writes `<name>.recovered.mp4` beside each damaged file. Originals are never modified, so it is safe to re-run. Stop the recording first -- the segment currently being written gets recovered half-finished.

Since ciao 2026-09-10 (`d836336d2`), the boot-time NFS mount works reliably even when the NFS server is specified by **hostname**: the mount helper now passes the bare hostname (not `server:/path`) to the kernel's route lookup, which previously failed and left the share unmounted after every boot until mounted by hand.

**NFS is now opt-in (ciao builds from 2026-10-05).** The mount configuration moved from the flat `nfs_share` string to a nested `nfs` object, and the share is no longer mounted at boot unless you ask for it:

```sh
jct /etc/thingino.json set nfs.enabled true
jct /etc/thingino.json set nfs.share "server:/path/to/share"
```

With `nfs.enabled` false the boot scripts simply skip the mount (the init script logs a notice instead of failing silently). To keep the configured address but mount right now, run `S43mounts force` -- it flips `nfs.enabled` to true and mounts immediately. Configurations still carrying the old top-level `nfs_share` key keep working. The nested share value is redacted from diagnostics reports. Full setup notes: `docs/thingino/nfs-share.md` in the firmware tree.

## Filesystem Overlay

Thingino uses OverlayFS to provide a writable layer over the read-only root filesystem:

- **Lower layer** -- Read-only rootfs on the flash partition
- **Upper layer** -- Writable JFFS2 partition (`data.jffs2`)

Changes to configuration files persist across reboots. The overlay partition is limited in size -- use SD card or NFS for large files.

---

<- [Previous: Streaming and Video](05-streaming.md) | [Next: Night Vision and Lighting](07-night-vision.md) ->

## Day/Night Mode

Thingino automatically switches between day (color) and night (IR) modes based on ambient light. A dedicated **daynightd** daemon coordinates the IR-CUT filter, IR LEDs, white LEDs, and ISP color mode. As of recent builds, the old `thingino-daynight` package has been consolidated into `thingino-daynightd` -- all day/night logic now lives in a single daemon with a Web UI plugin for configuration.

### Manual Control

```sh
daynight day     # Switch to day mode (IR-CUT in, IR LEDs off, color)
daynight night   # Switch to night mode (IR-CUT out, IR LEDs on, mono)
daynight toggle  # Switch to opposite state
daynight status  # Show current mode
```

### Individual Component Commands

You can also control components individually:

```sh
ircut on|off|toggle|status   # IR-CUT filter
light ir850 on|off           # 850nm IR LEDs
light ir940 on|off           # 940nm IR LEDs
light white on|off           # White light LEDs
color on|off|toggle          # ISP color/monochrome mode (Raptor only)
```

### Configuration

Day/night behavior is configured in `/etc/thingino.json` under `daynight.controls`. Each component can be individually enabled or disabled:

```sh
jct /etc/thingino.json set daynight.controls.color true
jct /etc/thingino.json set daynight.controls.ircut true
jct /etc/thingino.json set daynight.controls.ir850 true
jct /etc/thingino.json set daynight.controls.ir940 false
jct /etc/thingino.json set daynight.controls.white false
```

When a control is set to `false`, the `daynight` script skips that component during mode switches.

### Sun-Based Scheduling

Thingino can switch modes based on actual sunrise/sunset times using `dusk2dawn`:

```sh
jct /etc/thingino.json set daynight.sun.enabled true
```

When enabled, cron entries are automatically generated for your location's sunrise and sunset times.

### Threshold and Tolerance

The daynightd daemon uses EV log2 as the primary brightness metric (T31/T23/T21/T30) or gain log2 (T20). The thresholds are configurable:

**Fixed 2026-10-03 (ciao `ff431842d`): cameras stuck in night mode in bright scenes.** The ISP reports EV log2 as 0 at the brightest measurable scene, but the daemon treated a legitimate 0 as a missing reading -- so a camera whose auto-exposure bottomed out could latch in night (IR) mode and never switch back to day. The zero reading is now accepted as valid. If your camera stayed in black-and-white night mode under bright light, updating to a ciao build from 2026-10-03 or newer fixes it.

- **Night threshold** -- EV log2 value at which the camera switches to night mode (default: `550000`). The percentage-based `night_threshold` default was raised from 20 to 25 in recent ciao builds for less flapping at dusk.
- **Day threshold** -- EV log2 value at which the camera switches back to day mode (default: `350000`)
- **Brightness percentage thresholds** -- Optional overrides (`night_threshold_pct`, `day_threshold_pct`) that use a 0--100 brightness metric instead of raw EV values

### Tuning day/night thresholds (v1.9.15+)

Thresholds that ship with the firmware are averages. Dark-room readings vary per sensor and mounting (enclosure, IR reflection); when a camera ignores its thresholds, measure instead of guessing.

TIMPS v1.9.15 added a built-in tuning loop that closes this loop entirely on the camera:

- **`GET /control?dn_history=1`** serves the daemon's day/night decision history ring — per-sample brightness values and the mode at each point. Read it right after you see a wrong switch: `curl http://<camera-ip>:8880/control?dn_history=1`
- **`daynight.diagnose_thresholds`** is reported in `GET /control` status JSON (v1.9.15+), so scripts can detect misconfiguration.

Two more day/night improvements shipped with the 2026-09-26 TIMPS pin batch: the configurable day/night switch and IR-probe commands (`daynight.switch_cmd`/`daynight.irprobe_cmd`) are now started with `vfork()` (v1.9.23), so boards under memory pressure no longer fail to launch them -- the old `fork()` could fail with ENOMEM and silently skip the IR-cut flip; and the day/night controls in the TIMPS Web UI apply immediately instead of waiting for the next day/night edge (ciao builds from 2026-09-26, PR `#1708`). On T20 cameras the routine `isp_info` fallback log line is INFO instead of WARN (v1.9.26), so the Web UI health tile no longer flags healthy day/night as "errors". v1.9.27 (firmware pins 2026-09-27, both branches) fixes scheduled mode (`daynight.schedule`) west of roughly the US Pacific coast: the sunrise/sunset calendar keyed its "today" on the UTC day, so the camera adopted the next day's times and switched to night at UTC midnight (17:00 on the west coast) instead of at real sunset; the calendar day is now chosen by local solar time.

**Measure first, then bracket:** read your actual brightness values (daylight, dusk, fully dark), then set percentage thresholds that bracket them. The percentage keys (`day_threshold`/`night_threshold`, 0-100 scale) map logarithmically to the daemon's raw brightness metric — intermediate readings land in the hysteresis zone and hold the current mode, which is the point of the two thresholds.

**Real-world example (WUUK Y0510 / SC4336P, ciao 2488702):** the shipped raw-EV defaults (night >550000, day <350000) were miscalibrated for that sensor: daylight read ~737k (misread as night), a hand-covered lens read ~1114k — below the computed 1125k night line, so night mode could never engage in the dark. First fix attempt (raw `ev_*` thresholds 800000/1200000) booted to day but still never reached night: the daemon's percentage keys (`daynight.day_threshold`/`night_threshold`, default 50/25) silently override the raw `ev_*` keys whenever they are set — set the percentage keys, don't mix scales. Working calibration:

```sh
jct /etc/thingino.json set daynight.day_threshold 38
jct /etc/thingino.json set daynight.night_threshold 30
service restart daynightd
logread | grep "Initial mode"   # verify thresholds took effect
```

Two extra practical rules from that case: brightness under a covered lens is bounded by the sensor's max gain (don't chase ever-higher values), and give the daemon ~20 seconds of sustained samples before expecting a mode flip. When a schedule-based mode is preferable, `daynight.schedule` with start/stop times is the stable fallback.

The daemon also includes configurable sample counts (how many consecutive samples must exceed the threshold before switching) and a hysteresis factor to prevent flapping.

```sh
jct /etc/thingino.json set daynight.ev_night_threshold 550000
jct /etc/thingino.json set daynight.ev_day_threshold 350000
```

Day/night thresholds and behavior are also adjustable from the Web UI configuration page.

### Live Day/Night Tuning (Raptor, master)

On master (Raptor), the whole day/night policy is runtime-tunable through `raptorctl ric` -- no reboot needed:

```sh
raptorctl ric set-threshold adc_night 200   # ADC below this = night
raptorctl ric set-threshold adc_day 600     # ADC above this = day
raptorctl ric get-thresholds                # show every tunable + trigger mode
raptorctl ric config save                   # persist the tune
```

Everything is live except the IR-CUT wiring and `enabled` (re-pinning a live ircut coil is a hardware hazard, not a tuning knob). Tunables include the ADC pair (`adc_night` must stay below `adc_day`), photo EV thresholds (`photo_ev_night`/`photo_ev_day`), the LED probe trio (`probe_gain_pct`, `probe_recheck_sec`), bank policies for `ir850`/`ir940` (apply immediately, even mid-night -- e.g. dropping the 850nm bank to kill a window reflection), `pulse_ms`, and trigger choice via `set-trigger`. Changes apply at runtime; `config save` persists them.

### Night-Mode FPS Reduction

On ciao (Prudynt) builds, night-mode FPS halving is now handled directly by Prudynt rather than a separate script. This produces smoother transitions and avoids brief stream interruptions when switching modes.

## IR-CUT Filter

The IR-CUT filter blocks infrared light during the day for accurate colors and removes it at night to allow IR illumination. GPIO pins are configured under `gpio.ircut` in `/etc/thingino.json`.

### IRCUT Pulse Duration

Recent builds add a configurable `pulse_ms` option for the IR-CUT filter actuation pulse. This controls how long the GPIO pulse lasts when switching the filter. If your camera's IR-CUT filter is unreliable or switches too slowly/fast, adjust this:

```sh
jct /etc/thingino.json set gpio.pulse_ms 10
```

This is available on both master (Raptor) and ciao (Prudynt) branches.

## IR LEDs

Most cameras have integrated IR LED arrays (850nm or 940nm). Some use an LDR (light-dependent resistor) to auto-switch LEDs independently of the camera.

Match IR LED beam angle to your lens:

| Lens | Beam Angle |
|------|------------|
| 8mm | 45 degrees |
| 6mm | 60 degrees |
| 4mm | 80 degrees |
| 3.6mm | 90 degrees |

## White Light LEDs

Some cameras include white light LEDs for full-color night vision. Control them via the Web UI, `jct`, or Home Assistant.

---

<- [Previous: Storage and Recording](06-storage.md) | [Next: Motion Detection and Alerts](08-motion-alerts.md) ->

## Motion Guard

Motion detection uses the SoC's hardware IVS (Intelligent Video System). Enable it from the Web UI under **Motion Guard**.

Motion is configured in `/etc/prudynt.json` under the `motion` section. Key settings:

- **Sensitivity** -- Motion detection sensitivity level
- **ROI (Region of Interest)** -- Define rectangular regions to monitor for motion
- **Cooldown time** -- Seconds to wait before allowing another motion trigger
- **Video length** -- Duration of recorded clips when motion is detected
- **Monitor stream** -- Which stream to monitor (0 = main, 1 = sub)

Since ciao 2026-10-03 (`06590c9d8`), the motion ROI coordinates are interpreted against the monitored stream's own resolution instead of the sensor's, so an ROI drawn for the substream matches the frames the motion engine actually sees. On older builds an ROI configured on the Web UI could cover a different part of the picture than intended when the monitor stream was not the main one -- if your ROI seemed offset, re-save it after updating.

Alert timing also changed on ciao 2026-10-03 (`9f2222d4b`): speaker alerts and text-only notifications now fire the moment motion is detected, while snapshot/clip uploads still wait for the recording to finish. Previously every alert waited for the full clip capture (up to `video_length` + 10 s), which made speaker alerts lag noticeably behind the event on long clip settings.

## Alert Methods

When motion is detected, Thingino can send alerts via:

| Method | Script | Description |
|--------|--------|-------------|
| MQTT | `send2mqtt` | Publish a message to your MQTT broker |
| Email | `send2email` | Send notification email |
| Telegram | `send2telegram` | Send message via Telegram bot |
| Webhook | `send2webhook` | HTTP callback to a custom endpoint |
| ntfy | `send2ntfy` | Push notifications via ntfy.sh |
| Gotify | `send2gotify` | Self-hosted push notifications |
| Pushover | `send2pushover` | Push notifications to iOS/Android/desktop |

Recent ciao builds fix both ntfy and webhook notifications: `send2ntfy` now honors the configured scheme/SSL, sends the title and priority headers correctly, and forces HTTP/1.1 (HTTP/2 uploads to ntfy.sh stalled around 84%); `send2webhook` sends a raw JSON POST body for text-only messages and a proper multipart payload when a photo/video/file is attached -- builds from 2026-09-21 (fixes #1681) no longer fail on every webhook that carries an attachment.

Motion events are suppressed while pan/tilt motors are active: the motors daemon publishes `/run/motors-active` while a move is in flight, and every streamer's motion bridge (Prudynt, Raptor, TIMPS) checks it, so panning the camera no longer fires false motion alerts or clips.
| FTP | `send2ftp` | Upload snapshots/clips to an FTP server |
| Storage | `send2storage` | Save recordings to SD card or NFS |
| XMPP | `send2xmpp` | Send message via Jabber/XMPP |
| Speaker | `playonspeaker` | Play an audio alert through the camera's speaker |

Enable via the Web UI under **Tools** or through `jct /etc/prudynt.json`.

**Note on master builds**: `send2xmpp` is a master-branch addition; on ciao/stable only the methods listed above it are available.

## send2 Toolkit Architecture (master)

On the master branch the send2 notification scripts live in a standalone `thingino-send2` package shared by all three streamers (Prudynt, Raptor, TIMPS), with per-streamer adapter helpers:

- Capture is split per streamer -- no runtime streamer branching, each streamer uses its own adapter (`prudynt-helpers` for Prudynt, snapshot helpers for Raptor/TIMPS)
- Storage and FTP extensions handle extensionless temporary files correctly
- Raptor ships a live motion->send2 bridge (`raptor-motion` + `S32raptor-motion`), so motion alerts now work with Raptor, not just Prudynt
- Settings live in `/etc/send2.json` as before

## Audio Alerts (Speaker)

Cameras with a built-in speaker can play audio alerts when motion is detected. Configure this from the Web UI under **Motion Guard**:

- **Speaker file** -- Optional. Audio file to play (must be Opus format on 8 MB flash cameras; MP3 requires 16 MB+ flash). Leave it empty to use a bundled sound: the test button plays `chime_1`, motion alerts play `motiondetectionactivated`.
- **Volume** -- Speaker volume (0--120)
- **Gain** -- Audio gain (0--31)
- **Repeat** -- Number of times to play (0 = forever)

The speaker settings share a save button with motion detection settings in recent builds. Use the **Test** button to preview the sound without triggering motion. In builds from before October 2026 the test button reported success even when no speaker file was configured (the alert was a silent no-op); current builds fall back to the bundled sound and report the real result.

---

<- [Previous: Night Vision and Lighting](07-night-vision.md) | [Next: Home Automation and Integration](09-home-automation.md) ->

## Home Assistant

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
| Brightness | Sensor | Camera brightness, 0--100 percent |
| Day/Night State | Sensor | Current day/night mode (day or night) |
| Snapshot | Button | Take snapshot |
| Firmware Update | Update | Fixed in ciao builds from 2026-10-03 (`ea78f63cf`): the button now runs the supported full-upgrade path (`sysupgrade -f -B`, with a config backup) instead of the retired partial-upgrade command, so Install actually updates the camera. Requires the camera to be online with GitHub access; on older builds the button logged "starting partial firmware upgrade" and did nothing -- use System -> Upgrade or `sysupgrade -f` there |
| PTZ | Buttons | Up/Down/Left/Right/Home |
| Lamp Socket (Wyze) | Switch | On/off control of a Wyze Lamp Socket's switched outlet (ciao `3eabd559b`, 2026-10-06), alongside the existing Floodlight v1 light switch |

The Brightness and Day/Night State entities (from daynightd) are gated behind their own enable flags in recent ciao builds (2026-10-03, `429badb45`) -- previously they could not be enabled or disabled independently of the gain/daynight entities. Brightness is only discovered on cameras running the daynightd daemon.

Disable individual entities:

```sh
jct /etc/thingino.json set ha.enable_reboot false
```

All MQTT topics use the prefix `cameras/<hostname>/`. Recent builds use the camera **hostname** as its identity (instead of MAC address or SoC serial), making it easier to identify cameras in your HA dashboard.

**FQDN-style hostnames:** HA silently drops discovery topics whose node id contains characters outside `a-zA-Z0-9_-`, so a hostname like `cam-hall.rdw.one` used to produce discovery messages HA discarded. Builds from 2026-09-20 derive a sanitized node id for discovery topics only -- state topics still use the full hostname -- so such cameras appear correctly in HA.

The HA integration also auto-discovers the camera's **sensor model** and **device model** from `/etc/os-release`, so the correct hardware name appears in HA automatically.

## MQTT

Thingino includes `mosquitto_pub` and `mosquitto_sub` clients. Configure broker settings under **Services -> MQTT Subscriptions** in the Web UI.

Motion publish script: `/usr/sbin/send2mqtt`

**Encrypted brokers (MQTTS, port 8883):** builds from 2026-09-06 use the OS certificate store for TLS (`--tls-use-os-certs`), so brokers with valid certificates -- a Let's Encrypt-secured Home Assistant broker, for example -- connect without extra setup. Earlier builds passed `--capath`, which the camera's mbedTLS mosquitto backend does not implement, so TLS connections failed certificate verification.

## NVR / VMS Compatibility

Thingino works with most NVR/VMS software via ONVIF or direct RTSP:

| Software | Method |
|----------|--------|
| UniFi Protect | ONVIF |
| Frigate | ONVIF (see note) |
| Blue Iris | ONVIF |
| Synology Surveillance Station | ONVIF (see note) |
| iSpy / Agent DVR | ONVIF |

Note for Synology Surveillance Station: cameras on builds from 2026-08-17 (thingino-onvif `70d35cf`) can opt into compatibility shims that coax Synology's non-standard camera setup flow (synthetic CreateProfile response, deletable SynoProfileToken). On custom builds enable the `Synology Surveillance Station compatibility` package option (build-time) and set `"adv_synology_nvr": true` in `/etc/onvif.json` at runtime. Default builds stay strictly ONVIF spec-compliant.

Note for Frigate + PTZ cameras: an ONVIF GetStatus bug (fixed in thingino-onvif `6f299f3`, included in builds from 2026-08-16) caused Frigate to crash with `AttributeError: 'NoneType' object has no attribute 'Position'` on cameras without zoom. Update your firmware if you hit this; old firmware pins also accept a manual workaround (upload the `GetStatus_nozoom.xml` template to `/var/www/onvif/ptz_service_files/`).

Frigate reads the camera's PTZ preset **names** from `GetPresets`, so the descriptions you set in the web UI appear in Frigate's preset menu instead of generic `preset_N` labels. This needs firmware builds from 2026-09-20 (earlier builds exposed only the raw token). Frigate keys its menu by the lowercased name and the preset token is unchanged, so existing `GotoPreset` calls keep working.

---

<- [Previous: Motion Detection and Alerts](08-motion-alerts.md) | [Next: PTZ (Pan-Tilt-Zoom)](10-ptz.md) ->

## Web UI

Hover over the live preview to access PTZ controls. Two control modes are available in **Settings -> Pan/Tilt Motors -> Behavior -> Preview PTZ controls**:

- **Step move** (default) -- Click or double-click directional buttons to move in steps
- **Continuous move** -- Press and hold directional buttons for smooth continuous movement

On ciao and master builds with TIMPS as the streamer, a low-latency **WebSocket control path** is used for preview PTZ (`BR2_PACKAGE_THINGINO_MOTORS_WS`, on by default when TIMPS is selected). Since 2026-09-17 (ciao PR #1669) this is WebSocket-only: the CGI fallback was removed because it re-fired every 90 ms against an 82--275 ms round trip, backing up the web server and making held moves overshoot the button release by about two seconds. Every TIMPS build ships the socket, so no socket now means no control path -- the widget shows a notice instead of silently degrading. The joystick also gates its minor axis with hysteresis, so a near-axis hold sends a clean single-axis vector. The preview also gains an on-screen **joystick** and motor sensitivity sliders in the motors settings, plus a motors daemon version badge.

Keyboard jog on the preview page uses **Shift + arrow keys** -- one discrete step per press, browser auto-repeat ignored. Plain arrow keys (and other modifiers) are left to the browser for normal page scrolling.

On ciao builds (2026-09-08+), the preview also shows a **preset quick-bar** under the video: ten slots -- click to move, long-press to save the current position. The bar initially went missing from reflashed cameras because its script was never committed; firmware commit `10bd51d53` fixed the packaging.

**Drag-to-point PTZ (TIMPS v1.9.18):** on TIMPS cameras, the preview video itself is now the PTZ control -- click or tap a spot in the frame and the camera pans/tilts so that point moves to the center, with the motors UI syncing its settings panel in real time. The same release names presets in the toast when you move to one and tolerates motor settle drift when highlighting the active preset. The long-standing arrows/joystick controls remain for fine adjustment.

## Presets

The Web UI includes a **PTZ Presets** card on **Settings -> Pan/Tilt Motors**: move the camera to a position, give it a description, and save it. Presets are stored in the `motors.presets` array of `/etc/thingino.json` (each entry has a stable numeric `id`, a free-form `description`, and `x`/`y` coordinates) and can be edited and reordered in a **PTZ settings modal**. The id never changes on reorder or rename, and ONVIF clients see a stable token (`PresetToken_<id>`); builds from 2026-09-20 also report your description as the preset **name**, so NVRs like Frigate show the labels you set instead of generic `preset_N` entries. Preset edits made in the preview-page PTZ settings modal persist from 2026-09-20 builds too (they used to vanish on restart -- only the settings-page card wrote to disk). The **first preset doubles as the initial point** -- the motor daemon parks the camera at presets[0] on boot. `ptz_presets` CLI management still works (`-g`/`-a`/`-r`/`-o` reorder), and upgraded cameras import an existing `/etc/ptz_presets.conf` once, automatically.

## MQTT / Home Assistant

Enable PTZ buttons in HA:

```sh
jct /etc/thingino.json set ha.enable_ptz true
```

Commands: `cameras/<id>/ptz/{up,down,left,right,home}/set`

## Motor Configuration

PTZ motor configuration lives in `/etc/thingino.json` under the `motors` key. All motor settings -- GPIO pins, step modes, speed, range -- are unified into this single config file. There is no separate `motors.json`.

**Reload without restart** (`motors -R`): asks the running motor daemon to re-read `/etc/thingino.json` so config changes -- direction inversion, flips, sensitivity -- apply live. Prefer `motors -R` over `/etc/init.d/S59motor restart`: a full restart cycles the kernel module (`modprobe -r` / `modprobe`), which has caused kernel panics on live cameras.

VCM (Voice Coil Motor) focus control uses the `dw9714-ctrl` script.

### Motor Direction Inversion

**Ciao builds (Aug 24, 2026+) and current master:** the long-standing direction bugs are fixed, but the fix changed how inversion is expressed on GPIO/TCU cameras (commit `419eb8667`):

- **SPI motor cameras** (Tapo C200 class): `invert_x` / `invert_y` remain kernel module params in `/etc/thingino.json` and work as documented.
- **GPIO/TCU stepper cameras** (Cinnado D1 class): tilt direction is now defined by the *pin order* of `gpio_tilt` in the camera profile -- `invert_y` is ignored entirely. If your tilt moves the wrong way, swap the two pins in `motors.gpio_tilt` instead. Profiles that previously used `invert_y:true` as a wiring fixup were migrated in the same commit.

```sh
jct /etc/thingino.json get motors.gpio_tilt
```

The earlier double-inversion bug (init script re-applying the daemon's inversion, making the setting a no-op) and the position-counter overshoot are fixed on all motor types; the runtime `motors -I x/y` block for non-SPI cameras was removed from `S59motor`.

**Fixed 2026-10-03 (ciao `277805e1b`): pan/tilt stopped responding until reboot.** The motor service's stop routine could not actually stop the daemon (its PID file was stale from the moment it was written, because the daemon forks itself into the background), so a restart left the old daemon running with the kernel driver removed underneath it -- PTZ then went dead until the camera was rebooted. Stop now finds the real PID and kills it before unloading the module; a stale `S59motor restart` no longer breaks motors on any camera that has panned at least once.

### Upside-Down Mounts

If the camera is mounted upside-down and you compensate with **Image Flip** (hflip/vflip) in the streamer, the motor directions now follow the on-screen picture automatically. The streamer's `image.hflip` / `image.vflip` are combined with `invert_x` / `invert_y`, so a flipped mount needs no hand-tuned motor inversion:

```
net_x = invert_x XOR hflip
net_y = invert_y XOR vflip
```

Flip changes are picked up when the motor daemon reloads its config (`S59motor reload` / IPC 'R'), without a reboot.

---

<- [Previous: Home Automation and Integration](09-home-automation.md) | [Next: System Configuration](11-system-config.md) ->

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

## Hostname

The hostname suffix is derived at boot from the SoC serial number (same function that generates the MAC), and it is never regenerated from a later MAC change. A custom hostname set via `conf s hostname` is stored in the provisioning key/value store and applied on boot.

Changes to configuration files persist across reboots. The overlay partition is limited in size -- use SD card or NFS for large files.

Recent builds display overlay usage statistics in the SSH shell banner, so you can see at a glance how much overlay space is consumed.

## OverlayFS Layers

- **`overlay/`** (build-time) -- Replaces files in the read-only rootfs
- **`user/common/overlay/`** -- Writable partition, persists user changes
- **`user/<camera>/overlay/`** -- Camera-specific user overlay

## DHCP Timezone

Thingino automatically receives timezone from DHCP Option 101 and NTP server from DHCP Option 42.

---

<- [Previous: PTZ (Pan-Tilt-Zoom)](10-ptz.md) | [Next: Firmware Updates](12-firmware-updates.md) ->

## sysupgrade (OTA)

If your camera has internet access, the fastest way to update is `sysupgrade`. It downloads and flashes a full firmware image directly from GitHub.

**Full upgrade from GitHub:**

```sh
sysupgrade -f
```

> **Warning:** `sysupgrade -f` performs a **full flash** -- it overwrites the data partition and **resets the U-Boot environment** (WiFi credentials, root password). You will need to reconfigure the camera after upgrading.

**Flashing a local file:**

```sh
sysupgrade /mnt/mmcblk0p1/autoupdate-full.bin
```

**Flashing from a URL:**

```sh
sysupgrade http://example.com/firmware.bin
```

On the ciao (stable) branch, `sysupgrade -f` now pulls from the ciao branch directly, so you stay on stable when updating.

Master branch builds now publish to their own dated release tags (`master-YYYY-MM-DD`) instead of sharing the generic `latest` tag with stable. This means `sysupgrade -f` on a master-branch camera pulls master firmware, and stable cameras are no longer accidentally served a master build.

Recent ciao builds add selective partition flashing and config backup/restore to sysupgrade, but a full upgrade still resets the environment.

Recent builds also improve sysupgrade reliability: it now takes over the watchdog (instead of just disarming it) to ensure the camera reboots cleanly after flashing, and suppresses noisy `dd` stderr output during the flash process for cleaner logs.

**Config path fix (2026-09-15):** early September builds briefly wrote the camera's config to `/dev/thingino.json` on some paths; current master and ciao read and write `/etc/thingino.json` consistently (fixed in sysupgrade and the watchdog/failsafe scripts). If a script on your build references `/dev/thingino.json`, update the firmware — configs in `/dev` did not survive a reboot.

**`flash-ota` mtdparts fallback (2026-09-16):** `make ota-upgrade` used to abort with "ERROR: cannot read current mtdparts" on cameras whose U-Boot environment had no `mtdparts` variable (env reset, full-chip flash, or an installer that never seeded it) — GitHub issue #1540. The script now falls back to reading the layout from the kernel command line (`/proc/cmdline`), which is what the running system actually booted with. If you hit that error on an older build, update the firmware or seed the variable manually (`fw_setenv mtdparts '<layout from /proc/cmdline, without the mtdparts= prefix>'`) and re-run.

**Oversize guard (ciao builds from 2026-09-18):** OTA flashing now refuses to run when the built image does not actually fit the target's flash partitions -- both at build time (`make ota` preflight checks kernel, data, bootloader slot, and total image size against the layout) and on the device (the camera-side check rejects the flash *before* erasing anything if the image is bigger than the sum of the real partitions). Previously an oversized image (rootfs grown to fill an 8 MiB chip) could be flashed and leave the camera with a zero-byte data partition, so this turns a brick-risk into a clean build failure. Nothing to configure; if you ever see the refusal, your build config overflows the camera's flash chip.

Recent ciao builds fix a segfault in sysupgrade that occurred when flashing the data partition after the rootfs during a full upgrade. The U-Boot autoupdate-full.bin SD card flashing path also received a reliability fix. During the reboot sequence after flashing, sysupgrade now runs from a tmpfs copy of busybox, so the flash and reboot no longer depend on a rootfs being unmounted underneath them.

Another ciao fix prevents partition corruption on **old flash layouts**: the 'upgrade' partition is a virtual partition that overlaps kernel/rootfs/extras, and the full-flash loop used to erase and re-flash over the partitions it had just written. The virtual partition is now skipped, matching the other layout calculations.

Latest builds fix full upgrades **across partition layout changes**: the flash loop now writes each running MTD device the image bytes at the same absolute offsets (32K blocks, byte-addressing fallback), so the image is copied byte-for-byte regardless of how the image itself is partitioned. Previously, non-64K-aligned layouts (e.g. a 32K env partition) were silently mis-sliced, which could leave U-Boot with no valid environment and a dead boot after reboot.

Latest builds also make **config backup on upgrade actually work**. `sysupgrade -B` (and full upgrades generally) referenced a `cfg-backup` tool that was never installed, so config backups silently never happened. The tool now ships with thingino-sysupgrade: full upgrades snapshot your selected config files to the backup partition *before* flashing and skip that partition during the full-chip flash, so the snapshot survives. Run `cfg-backup restore` after the reboot to put the files back.

**And the restore is now automatic** (thingino firmware from 2026-08-22): a one-time `S37cfg-autorestore` init script runs at first boot after an upgrade. If a valid backup snapshot is present it restores your files and reboots once into the restored config; on a fresh install (no backup) it quietly removes itself. If the restore fails, the script stays and retries on the next boot. Note the chicken-and-egg on WiFi-only cameras: the restore runs before the network comes up, but that is fine -- it only touches local files, no network needed.

The default backup list keeps growing: TIMPS streamer settings (`/etc/timps.conf`) and ONVIF settings (`/etc/onvif.json`) are included since 2026-09-06, alongside `/etc/thingino.json`. See `/etc/cfg-backup.list` for the full list and the "You can add more paths" section at the bottom for adding your own.

## SD Card Update

The most reliable update method, especially for cameras with unreliable WiFi:

1. Download the firmware `.bin` for your camera from [thingino.com](https://thingino.com) or build it with the [Image Builder](https://image-builder.thingino.com/)
2. Copy it to a FAT32 SD card as `autoupdate-full.bin`
3. Insert the SD card and reboot the camera
4. The camera flashes automatically on boot

> **Important:** The `autoupdate-full.bin` method only works when **Thingino is already installed** -- it is processed by Thingino's U-Boot. It will not work on factory/stock firmware.

> **SD card tip:** Use a 2GB--8GB card. Some 16GB and 32GB cards may not be recognized in U-Boot's 1-bit MMC mode, particularly on T23N cameras.

## Web UI OTA

The Web UI upgrade page (tool-upgrade) is **not available** in standard production builds. It only appears when developer packages are enabled at build time (`BR2_THINGINO_DEV_PACKAGES=y`). For normal users, use `sysupgrade` or the SD card method.

## Checking Your Current Version

```sh
cat /etc/os-release
```

## Can't Find OTA in the Web UI?

OTA is not in the Tools menu for production builds. If you need to upgrade and do not have SSH access, use the SD card method above.

---

<- [Previous: System Configuration](11-system-config.md) | [Next: Troubleshooting](13-troubleshooting.md) ->

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

**SC2336P vs SC2337P (Sonoff and similar T23 cameras, fixed in builds from 2026-10-03):** these two dies report the *same* chip ID to the driver, so older builds could not tell them apart -- a profile built for one bound the other's init timings and image tuning, giving a wrong-looking or broken picture instead of a clean error. The sensor driver now checks a revision register and selects the right die: a mismatched profile fails loudly at `AddSensor` (the usual "no image" path) instead of silently misbehaving. If your SC2336P/SC2337P camera showed odd colors or a dead image on an older build and the boot log mentions a sensor mismatch, identify the exact die and pick the matching profile on a build from 2026-10-03 or newer.

Camera sensors **cannot** be identified visually. Check `/proc/device-info` or boot logs for the sensor model. GalaxyCore sensors (GC-prefixed) generally have better low-light performance.

## WiFi Won't Connect

**4.4-kernel cameras (T40/T41) with a `gpio.wlan` pin sequence in the profile (fixed in builds from 2026-10-03):** some boards power or reset their WiFi module through GPIOs, and the boot script only applied that pin sequence on 3.10-kernel builds -- on T40/T41 it logged "Skipping WLAN GPIO toggling for kernel 4.4" and did nothing, so the WiFi module never powered up (`590f68bdc`). If a T40/T41 camera's WiFi was dead from first boot with no driver error, updating fixes it.

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

## Reboot Hangs (older master builds)

`reboot` could hang forever on master builds: the kernel shutdown path disarmed the hardware watchdog, so when shutdown or the low-level restart routine stalled, nothing reset the SoC and the camera sat there until power-cycled. Master builds since 2026-09-18 (`c4d3bcc01`, ported from the ciao branch) keep the watchdog armed across shutdown as a fallback -- a wedged reboot now self-resets after the configured watchdog timeout. If your camera hangs on `reboot`, power-cycle it and update the firmware.

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
| **SEI** | Supplemental Enhancement Information (H.264 metadata for OSD) |
| **SoC** | System on a Chip |
| **TIMPS** | Tiny IMP Streamer (lightweight alternative streamer for Ingenic SoCs) |
| **OverlayFS** | Filesystem layering (read-only base + writable overlay) |
| **U-Boot** | Universal Bootloader |

---

*This manual is a living document. Submit corrections or suggestions via the [Thingino community](https://discord.gg/gFc9jR2eXV).*

---

<- [Previous: Troubleshooting](13-troubleshooting.md)

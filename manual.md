## What is Thingino?

Thingino is open source firmware that replaces the stock firmware on IP cameras powered by Ingenic T-series SoCs (T10, T20, T21, T23, T30, T31, T32, T33, T40, T41). You get a full-featured camera system with RTSP streaming, ONVIF support, motion detection, night vision, and home automation integration -- without cloud dependencies or vendor lock-in.

## Design Philosophy

- **Tailored, not universal** -- Each camera gets firmware built specifically for its hardware, with minimum overhead.
- **Common sense engineering** -- Simplicity and practicality over unnecessary complexity.
- **Open source** -- All components, including U-Boot and the Linux kernel, are publicly available.

## Streamer

Thingino's stable release builds use **Prudynt**, the production streamer. OSD data is embedded as SEI metadata in the H.264 stream by default; ciao builds offer an optional burn-in mode that renders OSD directly into video pixels.

**TIMPS** (Tiny IMP Streamer) is a lightweight alternative by Lu-Fi, available as an optional package. It offers on-demand encoding (idle at 0% CPU), a live control API (POST/GET /control), SSE event push (/events), per-stream TrueType OSD, grid motion detection (IMP_IVS), native day/night detection, privacy cover masks, local SD recording, and optional Opus audio codec. It supports RTSP Digest/HTTP Basic auth and token auth.

**Divinus** is a third, experimental streamer option: a compact proof-of-concept for T31 cameras with RTSP, a snapshot web server and fMP4 recording. Select it at build time, run it by hand and tune `/etc/divinus.yaml`; it is not yet wired into the WebUI, day/night or ONVIF the way the other two are (see [Streaming](05-streaming.md)).

**Raptor** is the next-generation modular streaming system, currently in development builds only. It will become the default in future releases. Raptor uses **daynightd** as its day/night engine (the successor to the older RIC tool), with dedicated `daynight`, `ircut`, and `light` wrapper scripts for both Web UI and command-line use.

The **open-isp** package is also integrated in master and ciao builds -- a complete open media stack for ISP tuning and development, including an `isp-inspector` tool that displays exposure values as log2 stops.

## SoC Support

Thingino runs on **Ingenic** T-series SoCs (T10, T20, T21, T23, T30, T31, T32, T33, T40, T41). The first T32 camera profile is the Cinnado D1 T32LQ; builds for T32 are new and experimental. Early groundwork for **SigmaStar** (Infinity6e/SSC30KQ) support is merged, but no usable SigmaStar camera builds exist yet.

See [thingino.com](https://thingino.com) for the full list of supported cameras.

## SNMP Monitoring

Thingino includes an optional **thingino-snmpd** package (mini-snmpd 2.0) for network monitoring via SNMP. When enabled, it integrates with the Web UI as a plugin and exposes camera system metrics to SNMP managers like PRTG, Zabbix, or LibreNMS.

## Unsupported Camera Types

**Solar and battery-powered cameras are not supported.** They use the Zeratul platform with a separate MCU that controls power -- Thingino cannot keep the main SoC powered on.

## Secure Boot (eFuse-Locked) Cameras

Some cameras ship with eFuse secure boot locked: Wyze Cam V4, Wyze Doorbell V2, Wyze Cam Pan 3/4, and select Galayou, Xiaomi, and Camsoy models. Thingino `master` builds patch the U-Boot SPL at build time (the `secureboop` package) so firmware images boot on these SoCs. Models on T23/T32/T40/T41 need no extra data; T31-based locked models additionally require the vendor RSA modulus extracted from a stock flash dump.

## Community

- **Telegram**: https://t.me/thingino
- **Discord**: https://discord.gg/gFc9jR2eXV
- **Wiki**: https://github.com/themactep/thingino-firmware/wiki

## Video Guides, Unbricking & Installer Images

- **[WLTechBlog on YouTube](https://www.youtube.com/@WLTechBlog)** -- Step-by-step installation and unbricking videos, plus a curated list of cameras that are easy to install Thingino on.
- **[Universal Unbricker](https://unbricker.wltechblog.com/)** -- Web tool by Josh at WLTechBlog that builds a per-camera unbrick image for the flash glitch recovery method. Check the device list for supported models.
- **[thingino-installers](https://github.com/wltechblog/thingino-installers)** -- Ready-made per-model SD-card installer images for the first flash from stock to Thingino. Installers are for initial installation only -- never use them to update an existing install; do a full firmware upgrade afterwards instead.

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

The Web UI gives you a browser-based interface for managing your camera. Open it at `http://hostname.local` or `http://<camera-ip>`.

While a camera tab is visible, the page re-checks the session with the camera once a minute and redirects to the login screen when the session has expired. If you return to a camera tab and find yourself at the login page, that is this check working as intended -- log back in and continue.

## Live Preview

The preview player recovers on its own when the browser backgrounded or throttled the tab: a watchdog monitors frame progress and force-reconnects after ~20 seconds without video while the tab is visible, and reconnect/retry budgets reset whenever you press Connect. Hover over the preview to reveal PTZ controls. On raptor-streamer builds the live preview is proxied through rhd's native MJPEG stream, keeping the JPEG encoder warm and delivering frames at the configured JPEG FPS.

On stable (Prudynt) builds, the OSD overlay is rendered as an SVG overlay in the Web UI only -- it is not burned into video. See [Streaming and Video](05-streaming.md) for the full OSD story.

### Live View (fMP4)

Prudynt builds ship a native low-latency live view: the **Live View (fMP4)** page plays the camera's H.264 stream directly in the browser. No re-encoding -- it reuses the existing encode, so image quality matches what RTSP viewers get, with audio playback (volume slider + mute) and zoom controls. Switching main/sub streams is race-free, and streamer plugin preview pages integrate on it like on the classic preview.

The default page that loads with the camera is the **PTZ live view** (`/preview.html`): the fMP4 live view with pan/tilt controls, ten preset slots and the OSD overlay combined on one page. The plain fMP4 player remains reachable at `/preview-fmp4.html` (MJPEG unchanged), and the classic MJPEG preview remains available alongside. Preset slots: long-press to name and store the current position, right-click to delete. On cameras without pan/tilt hardware the controls render disabled behind a note, so the same page works everywhere; after a playback stall the player seeks back to the live edge instead of staying behind.

All preview styles, plus direct MJPEG stream URLs, are authenticated with the camera's API key (`/etc/thingino-api.key`, passed as `?token=...`) -- direct stream URLs embedded in other tools must include the token parameter. The `X-API-Key` header also reaches CGI scripts on uhttpd builds, so tools that prefer header authentication instead of the `?token=` URL parameter work as documented.

The preview pages show a strip of direct-stream endpoint links below the player: RTSP, fMP4, MJPEG, and snapshot URLs for both the main (ch0) and sub (ch1) streams. Click any link to copy its URL to the clipboard. The RTSP links embed your RTSP username and password (default `thingino`/`thingino`), and the browser/stream/snapshot links include your camera's API key as a `token` parameter, so a copied URL works as-is in another player or tool. The strip follows your configured RTSP endpoints, port, and credentials, and appears on both the classic MJPEG preview and the fMP4/PTZ live view.

Long sessions and multiple viewers stay stable: the streamer releases the fMP4 worker claim after the last previewer disconnects and recycles frame buffers between sessions, and the player reads and appends independently with a byte-capped backlog, trims its buffer against the live edge, and reconnects automatically after a drop. The playhead is anchored to the wall clock, so the preview silently reconnects when it detects real drift instead of falling minutes behind the scene.

The preview advertises its audio track only when the audio encoder is actually running -- a camera whose audio encoder failed to start serves a video-only preview that plays normally, and cameras with healthy audio keep theirs. Small offsets between the audio and video clocks at startup are tolerated, so video renders immediately.

The fMP4 live view also plays H.265 main streams. The player first tries the browser's built-in decoder (works in Safari and in Chrome/Edge with hardware HEVC); where that is unavailable -- plain `http://` pages in Chromium, or Firefox -- it falls back to a WebCodecs canvas player instead of showing nothing, and a status line points at the H.264 substream if the browser cannot decode at all.

The player prefers ManagedMediaSource when present -- iOS 17.1+ Safari ships only ManagedMediaSource, which requires the `disableremoteplayback` attribute on the video element, and the preview pages carry it -- so live view works in Safari on iPhones. Browsers with neither MediaSource interface drop straight into the existing MJPEG preview instead of hanging on "Connecting...".

## PTZ Controls

Two control modes are available under **Settings -> Pan/Tilt Motors -> Behavior -> Preview PTZ controls**:

- **Step move** (default) -- Click or double-click directional buttons to move in steps
- **Continuous move** -- Press and hold directional buttons for smooth continuous movement

## Streamer

The Streamer section contains OSD editor, main stream, sub-stream, image, and sensor configuration. The sensor page reports the real SoC family.

On stable builds using Prudynt, the Web UI talks to the streamer's API through same-origin CGI endpoints on the camera itself, so the RTSP/ONVIF password form and the streamer settings pages also work when you browse the camera over HTTPS (the requests stay on the camera's own origin, so browsers do not block them as mixed content). The proxy keeps using the API key at `/etc/thingino-api.key` internally, so nothing changes for plain-HTTP users.

### OSD Editor

The OSD editor at **Streamer -> OSD** lets you add, remove, and configure elements (timestamp, hostname, IP address, uptime, gain, static text, logo). Each element has position, font, color, and format settings.

Both SEI metadata mode (default) and an optional **burn-in** mode are supported. Burn-in renders the OSD directly into video pixels, making it visible in RTSP players and recordings.

### Timelapse

The Timelapse tool is part of the streamer packages instead of a shared Tools page. On Prudynt (stable) it works via a cron schedule invoking the streamer's `timelapse` command; on Raptor (master) it drives the `[timelapse]` section of `raptor.conf` (enabled, interval, playback\_fps, file\_frames, max\_mb) through `raptorctl`, with native capture and rotation -- no cron needed. Find it under the Services menu on both streamers.

On TIMPS cameras the built-in timelapse player in the camera's web UI serves frames without closing the connection each time and keeps a deeper prefetch window, so playback does not stutter between shots.

## Web UI Plugin Architecture

Thingino's Web UI uses a modular plugin system. Optional packages ship their own configuration pages as plugins that are automatically integrated into the navigation menu at build time. If a package is not installed, its Web UI pages simply don't appear -- no stale menus or dead links.

Currently in the plugin system:
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
- **Wyze accessories** (when the camera supports them): Floodlight v1 light control, and **Lamp Socket** power control -- the socket's switched outlet exposes on/off in the Web UI and as a Home Assistant `switch` entity (see [Home Automation](09-home-automation.md))
- **Commands and logs**: one page with tabbed sections (Files / Logs / Info) replacing eleven separate Information entries; deep links of the `info.html?<section>` form still work
- **Streamer pages** (OSD, streams, image, sensor, audio) -- per-streamer plugins; Prudynt pages ship with the prudynt-t package, Raptor pages with the thingino-raptor package, and TIMPS pages with the timps package

Note: On master builds using Raptor there is no streamer config API. Stream settings must be edited directly in `/etc/raptor.conf` (see [Streaming and Video](05-streaming.md)). The Image Quality page controls (white balance, gain, AE compensation, flips, noise reduction and temporal noise reduction) are wired to the agent API and work in the Web UI; only stream parameters require editing `raptor.conf`. On master builds using **TIMPS** instead, the full set of streamer pages is available in the Web UI (streams, OSD, image, sensor, audio, motion, privacy, recordings, timelapse) via the timps plugin; the raw config stays at `/etc/timps.conf` under **Info -> File: timps.conf**. On ciao builds running TIMPS v1.10.1, the streamer pages also include **Crop/zoom** and **ROI** tabs on the overlays page -- a full-sensor crop editor with a draggable window and a zoom slider, plus per-region encoder quality editing -- and the Day/Night page includes an Idle-Dark card.

## Settings

Network, video, motion, OSD, and system configuration. Advanced settings are available through the configuration editor, which directly edits `/etc/thingino.json`. You can also use the `jct` CLI tool from the shell.

## Tools

Email, webhook, ntfy, gotify, FTP, storage, diagnostics, and more. Speaker configuration is available under **Motion Guard** when a speaker is present. MQTT, Telegram, and VPN tools are on the plugin-based Settings pages.

The **Cameras on LAN** page lists other Thingino cameras discovered via mDNS. It shows model, firmware build, and streamer for each camera, sorts by column, caches results between visits, and highlights the local camera's row (the streamer name is plain text, not a link). On cameras running Prudynt, the build ID for each camera links directly to its exact commit on GitHub. Discovery is bounded and complete, so large networks don't truncate the list.

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

Ciao builds include an optional **network watchdog** that can reboot the camera when it loses connectivity: every 30 seconds it pings the network gateway, and after 3 consecutive failures it reboots the camera. A hardware watchdog backs the mechanism up, so even a completely wedged network stack cannot block the recovery reboot.

The watchdog is **opt-in** -- it does not arm by default, so a marginal Wi-Fi link cannot turn into a reboot loop unless you enable it. Enable it under **Settings -> Network** or in the config:

```sh
jct /etc/thingino.json set netwatch.enabled true
```

Arm/check/reboot decisions are logged -- when diagnosing a flaky link, look for the `netwatch` tag in `logread`.

Keys: `netwatch.enabled` (default `false`), `netwatch.fail_count` (default `3`), `netwatch.interval` (default `30` seconds).

## Ethernet (Wired)

Wired Ethernet is plug-and-play on devices with an Ethernet port. The MAC address is automatically derived from the SoC serial number.

## Time and Timezone

**timectl** is the single entry point for clock, timezone, and NTP configuration:

```sh
timectl set-timezone "Europe/Berlin"
timectl pin-timezone        # disable automatic timezone from DHCP
timectl unpin-timezone      # re-enable automatic timezone
```

All time-related paths (Web UI, WiFi portal, `tzselect`, and the DHCP client scripts) route through `timectl`. The old `dhcp.ignore_timezone` setting is migrated automatically. Docs: `docs/timezone.md` in the firmware repo.

## USB Ethernet

Thingino supports USB Ethernet adapters out of the box:

- **ASIX AX88772** -- Best compatibility (supported in both U-Boot and Linux)
- **CDC-Ethernet** -- Supported in Linux only
- **CDC-NCM** -- Modern adapters, higher throughput

Plug in the adapter and it should be recognized automatically.

## USB WiFi Dongles

**Ralink RT5370** USB WiFi dongles are supported on master builds. Useful as a replacement radio for cams with damaged internal WiFi or where you want to reposition the antenna.

## mDNS / Bonjour Discovery

Thingino cameras advertise themselves on the local network via mDNS (Bonjour/Avahi). The service type is `_thingino._tcp`, broadcast on the camera's HTTP port.

This means you can discover cameras without knowing their IP address:
- **Linux**: `avahi-browse -rt _thingino._tcp`
- **macOS**: Use Bonjour Browser or Safari's Bonjour bookmarks
- **Home Assistant**: mDNS devices appear automatically in discovery

The camera's hostname (e.g., `ing-t31x-1234.local`) is also resolvable via mDNS.

The mDNS daemon watches **all** network interfaces in client mode instead of pinning to the first up non-loopback one, so interfaces that come up later are picked up automatically. In AP/captive-portal mode the daemon still pins to a single interface so phones connecting to the camera's hotspot don't get a captive-portal login prompt pushed at them.

## SNMP

Thingino includes an optional **thingino-snmpd** package (mini-snmpd 2.0) for SNMP monitoring. When enabled at build time, it provides a WebUI plugin for configuration and exposes system metrics to SNMP managers.

## VPNs

Thingino supports VPN solutions for remote access:

- **WireGuard** -- Included by default in all releases
- **ZeroTier** -- Available in custom builds for cameras with 16MB flash. See the [ZeroTier wiki page](https://github.com/themactep/thingino-firmware/wiki/VPN:-Zerotier)

> **Note:** OpenVPN is not tested or promoted. Use WireGuard for VPN access.

### WiFi Roaming

On Realtek USB WiFi drivers (8188/8189/8192/8733/8812 families), disabling roaming in your build config is honored: layer-2 roaming is not compiled in for these builds, and roaming clients that hop between APs behave predictably.

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

> **Note:** WebRTC requires **Raptor** (development builds) or a **TIMPS** streamer with the WebRTC endpoint compiled in. It is **not available** in stable release builds, which use Prudynt.

When available, WebRTC provides ultra-low-latency live view in the Web UI. The camera's streaming daemon handles WebRTC negotiation automatically.

On Raptor builds the preview page adds **digital zoom buttons** (1x to 4x). Zoom-in is applied in place; zoom-out may restart the streamer out-of-process (WebRTC buffers cannot grow in place), and the page reloads afterwards so the session reconnects at the new resolution. The buttons only appear when the running streamer supports zoom, and the currently applied level is marked.

### WebRTC / WHEP on TIMPS

TIMPS serves a standard **WHEP** endpoint (WebRTC-HTTP Egress Protocol): a player POSTs an SDP offer to the camera and receives H.264 video (plus audio) over ICE-lite/DTLS-SRTP -- no plugin, and none of the MSE buffering the fMP4 preview has.

```
POST   http://<camera-ip>:8880/webrtc/whep        # send the SDP offer, get the answer
DELETE http://<camera-ip>:8880/webrtc/whep/<id>   # tear a session down
```

`POST /webrtc/whep?chn=N` picks the video stream per session (main/sub) without changing the global `webrtc.channel` default; an out-of-range, not-running or non-H.264 stream is refused with `400` (advertised as `caps.webrtc.chn_select: 1`).

A standalone test page ships with the TIMPS source (`scripts/whep-test.html`).

Deliberate limitations, worth knowing before you try it:

- **LAN/VPN only** -- one host candidate, no STUN/TURN, no NAT traversal, no IPv6
- **H.264 video only** (the `webrtc.channel` stream) plus **G.711 audio** (PCMU/PCMA) only when the camera actually encodes G.711 -- on AAC cameras, enable the second audio encode with `audio.codec2` (below). No Opus, AAC or H.265 over WebRTC; no transcoding
- **No NACK/retransmission, FEC, or congestion control** -- a LAN live-view path, not a loss-recovery one
- **Firefox usually will not decode it** (the answer's `profile-level-id` comes from the live SPS, which defaults to High profile); Chrome/Chromium is the tested target
- **At most 4 concurrent sessions** -- a 5th offer gets `503`, and stalled sessions are reclaimed after 30 seconds

The endpoint is compiled in behind a build flag and **runtime-gated by `webrtc.enabled`** in `/etc/timps.conf`: `0` = off, `1` = on, `2` = on and also accepting plaintext WHEP POSTs on a TLS port (the default on WebRTC builds). With a TLS-protected port (`http.https=1`), plaintext WHEP POSTs are refused with `426 Upgrade Required` -- signalling belongs on HTTPS. The endpoint answers `503` when disabled by config and `404` when not built in.

> **Firefox note:** If you get a 400 Bad Request error, set `media.gmp-gmpopenh264.enabled` to `true` in Firefox's `about:config`. The camera only supports H.264 video.

### WebRTC Audio on AAC Cameras (`audio.codec2`)

TIMPS can run an optional **second audio encode** whose only job is to feed WebRTC's G.711-only path: the camera encodes AAC (for RTSP/fMP4) and PCMU side by side. `audio.codec2` in `/etc/timps.conf` accepts `pcmu` or `off` and defaults to `pcmu` on WebRTC builds. `audio.gain` defaults to 25, and inbound SRTCP replay protection is keyed per sender SSRC.

## ONVIF

Thingino provides ONVIF Profile S compliance, enabling compatibility with NVRs, VMS software, and home automation platforms. ONVIF services include:

- Media streaming (RTSP)
- PTZ control
- Event notifications (motion detection)
- Imaging settings

ONVIF motion events work with UniFi Protect and other NVRs that support third-party ONVIF cameras.

ONVIF `GetProfiles` only advertises capabilities the camera actually delivers, so NVRs can add a camera that has audio output disabled.

ONVIF credentials always follow the RTSP username/password: whatever works for `rtsp://` works for ONVIF. Saving a new password in **Settings -> RTSP/ONVIF** updates the credentials for both RTSP and ONVIF. You can also set the password over SSH:

```sh
jct /etc/prudynt.json set rtsp.password '...'
```

## OSD (On-Screen Display)

Thingino supports customizable OSD overlays with the following element types:

- **Timestamp** -- Display current date/time (strftime format)
- **Hostname** -- Camera hostname
- **IP Address** -- Camera's IP address
- **Uptime** -- Time since boot
- **Gain** -- ISP gain indicator
- **Static Text** -- User-defined text label
- **Logo** -- Custom image overlay

### How OSD Works on Prudynt (SEI vs Burn-In)

On stable release builds, OSD data is **embedded as SEI metadata** within the H.264 stream by default -- it is **not burned into the video pixels**. This means:

- Standard RTSP players (VLC, Blue Iris, Frigate) **cannot display** the OSD overlay
- Only the Thingino **Web UI dashboard** renders the OSD (as an SVG overlay on top of the video)
- The OSD is not visible in recorded video clips
- This design avoids performance issues on less powerful camera hardware

A build-time **burn-in** option (`BR2_PACKAGE_PRUDYNT_T_OSD_BURNIN`) renders OSD directly into video pixels instead, making it visible in all RTSP players and recordings.

### Per-Stream OSD Control

On Prudynt builds, you can keep OSD burned into the main stream while disabling the burned-in timestamp on the sub-stream:

```sh
jct /etc/prudynt.json set osd.burnin.substream_disabled true
service restart prudynt
```

The Web UI SVG overlay (SEI) works on all streams when `osd.sei.enabled` is set to `true` (it is off by default and must be explicitly enabled).

On Raptor (master), per-stream OSD control is a native config key: set `osd_enabled = false` under any `[streamN]` section in `raptor.conf` to drop the OSD from that stream while keeping it on others.

### Streaming Behavior (Prudynt)

- **UDP burst pacing** -- initial frame bursts are paced to prevent jitter buffer overflow in RTSP clients
- **RTCP SR accuracy** -- sender reports use a fresh clock sample for accurate NTP-to-RTP timestamp pairing
- **JPEG encoder FPS** -- the JPEG encoder runs at its configured FPS
- **Clean shutdown** -- video/JPEG worker threads do not hang during shutdown, and audio-only RTSP sessions are handled without crashes or hangs
- **Night FPS** (Raptor, master) -- `night_fps` in the stream config lowers the frame rate in night mode to save bandwidth and reduce noise (e.g. `jct /etc/raptor.conf set stream0.night_fps 10`)

### Colour Fidelity (SPS VUI)

Prudynt declares full-range luma and an explicit BT.709 colour matrix in the H.264/H.265 SPS VUI at every resolution. The pipeline is BT.709 end to end, so a low-resolution substream publishes the same matrix as the main stream and the JPEG snapshot, and the signalled range always matches the actual pixels. No configuration needed.

### Automatic Bitrate Scaling

Prudynt derives each stream's default bitrate from its encoded resolution -- roughly 1 Mbps per megapixel. An explicitly set bitrate is kept; scaling only affects streams left at the default.

### Stream Watchdog (Prudynt)

Prudynt ships with a supervisor: if the streamer dies (crash, OOM kill), the `S32prudyntwd` watchdog detects it within about a minute and restarts it automatically.

- Liveness is probed via the local HTTP API (with an RTSP probe as fallback), so it works regardless of RTSP authentication settings.
- A wedged streamer is force-killed (the PID is captured before the pidfile is removed), so the restart takes effect even when the process is stuck inside a driver call.
- After 3 failed restarts in a row it backs off for 10 minutes between rounds, letting transient faults clear instead of restart-looping.
- If the streamer still has not recovered after 9 failed restarts (~34 minutes), the camera **reboots itself** (with a hardware-watchdog fallback in case the normal reboot path is wedged).
- To disable the self-reboot and only log/back off, set `REBOOT_AFTER=0` in `/etc/init.d/S32prudyntwd`.

### PTZ Live View (Prudynt)

Prudynt builds offer a combined live view: the H.264 stream plays in the browser with pan/tilt controls, ten preset slots and the OSD overlay on a single page at `/preview.html` (what the **Preview** nav item opens). The plain fMP4 player remains at `/preview-fmp4.html`. Presets are managed in-page: long-press a slot to name and store the current position, right-click to delete it. On cameras without pan/tilt hardware the controls render disabled with a note, so the page serves as a universal default.

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

TIMPS (Tiny IMP Streamer) is a lightweight streamer available as an alternative to Prudynt/Raptor. The boot script runs `timpsd --check-libs`, which refuses to start against a mismatched `libimp` instead of crashing later. Notable streaming behavior:

- A dropped P-frame triggers an instant keyframe recovery request across all transports -- RTSP, SRT, WebRTC and fMP4 -- instead of leaving a smeared picture until the next natural keyframe.
- RTSP-over-UDP clients that reconnect from a new source port (NAT rebinding) keep receiving video without a client restart.
- A/V lip-sync survives delivery gaps on the MP4/preview path and the SD recorder: the video timeline re-anchors to true media time after a client stall.
- Camera profiles apply their per-camera `timps.conf` defaults automatically, so a profile-tuned camera needs no manual streamer config.
- TIMPS installs its own Web UI plugin (preview page, motor controls).

When using TIMPS, these features are available:

### Live Control API

TIMPS exposes a live control API at `http://<camera-ip>:8880/control` (GET to read, POST to change):

- Adjust bitrate, FPS, GOP, and resolution on the fly
- Toggle audio, backchannel, privacy mode
- Control motion sensitivity in real time (IMP_IVS); changes take effect on the running detector and survive a restart
- Take snapshots
- Encoder rate-control knobs (qp, min/max QP, quality_lvl, i_bias_lvl, fluc_lvl) -- applied live where the SoC allows (`caps.video_live` advertises which keys apply live), with `deferred_keys` in the reply naming anything that waits for a restart; `caps.restart` lists the keys that need a `S95timps` restart
- `encoder.<n>.rc` readback showing what the encoder actually holds right now, so writes can be verified against reality
- The auto `sensor.fps` cap follows the fastest enabled `videoN.fps`
- Config writes to flash are batched to at most once per 3 s (`persist_pending` in the status), so slider drags and automations do not hammer the flash

Config changes through the API are applied atomically, so adjusting stream parameters while streaming cannot corrupt internal state. POST replies carry a per-key `errors` object with numeric codes; value rejection is reported as `409`, and an empty string clears a text field. `GET /control` advertises what the build can do (`caps.*`) instead of refusing without explanation.

Example -- change main stream bitrate:

```sh
curl -X POST http://192.168.1.10:8880/control -d '{"stream0.bitrate": 2000000}'
```

The reply names any request fields it ignored, so a typo in a mixed request is visible instead of looking like a clean success.

### Day/Night Detection

TIMPS has a built-in adaptive day/night engine with a configurable boot-settle period and periodic night reconfirmation, so temporary light changes do not cause flapping. The engine reads the real AE exposure from IMP as its primary signal (with an estimate-based fallback when only an estimate is available), and verifies every switch against the ISP's reported running mode 18 seconds after the transition: agreement closes quietly, disagreement warns and forces exactly one repair transition through the opposite mode. The status appears as `daynight.isp_desync` on `/control` and `/events`; persistent standing disagreement is reported but never enforced, so manual ISP overrides are not fought.

Clipped meter readings are barred from long-term memory (the night reference, the trend detector, filter-cost learning and probe diagnostics), so cameras whose dark rest state is a fully-clipped meter -- zero exposure headroom, e.g. the T20 in Wyze Pan -- cannot anchor a worthless reference. A clipped reading that has held stable still counts as valid data. An illuminator relight runs when an abandoned silent probe would otherwise leave the IR light in the wrong state, and board hooks (`daynight.switch_cmd`/`irprobe_cmd`) are killed after a timeout, so a hanging hook cannot freeze day/night switching or daemon shutdown.

In `mode=schedule`, the sunrise/sunset calendar is chosen by local solar time, so the chosen date always contains the sunrise/sunset it refers to.

The optional `ae_it_max_us` key in `/etc/timps.conf` caps the AE integration time, so a dark scene cannot stretch exposure far enough to smear motion across frames -- e.g. `ae_it_max_us 20000` for a 20 ms ceiling; leaving it unset keeps the uncapped behavior.

You can ask for a day/night probe on demand via the control API:

```sh
curl -X POST http://192.168.1.10:8880/control -d '{"daynight":{"probe":1}}'
```

This arms a silent IR probe for the next automaton tick -- useful to verify a camera can actually see daylight instead of waiting up to half an hour for the heartbeat. Cameras without `daynight.irprobe_cmd` configured cannot probe silently and report that refusal instead of silently doing nothing.

> Builds with the redesigned day/night engine ignore the retired keys `probe_min_gap_s`, `probe_confirm_s`, `boot_probe` and `diagnose_thresholds` with a warning; `daynight.jump_pct` sets the brightness drop that triggers an early look. See [Night Vision](07-night-vision.md).

### Browser Talk-Back

The TIMPS preview offers talk-through-the-camera: the page captures your microphone and streams it to the camera's speaker over a WebSocket (`/talk` endpoint), alongside the existing RTSP/ONVIF talk paths. Multiple simultaneous talkers are arbitrated the same way as RTSP talkers, and a stalled WiFi connection drops its audio backlog instead of playing it seconds late.

Runtime `audio.talk_ws` in `/etc/timps.conf` (default off, restart to apply): `0` = disabled, `1` = on but TLS-only, `2` = on and accepts plain `ws://` too (for a camera without HTTPS where you grant the origin a secure context by hand in the browser -- mic audio then crosses the network unencrypted). The feature is compiled in by default (`BR2_PACKAGE_TIMPS_BC_WS`); when built in, `audio.backchannel` and `audio.talk_ws` auto-enable.

### HTTP/HTTPS Modes

`http.https` in `/etc/timps.conf` is a tri-state:

- `0` = plain HTTP
- `1` = the web UI port serves HTTP and HTTPS together (the server peeks at each connection's first byte and answers HTTP or TLS accordingly); HTTPS responses carry `Cross-Origin-Opener-Policy`/`Cross-Origin-Embedder-Policy` headers so browser camera-add and PWA flows treat the camera as a secure context
- `2` = HTTPS only; plain-HTTP requests are rejected, and self-signed TLS certificates are generated for you

Mode `1` lets normal browsers keep using `http://` while apps that require a secure context (camera-add flows, PWA installs, some mobile clients) get a real `https://` endpoint on the same port. Firmware-side, the setting is only auto-written when the uhttpd redirect prerequisite is present, and the web UI's preview links follow the page scheme. The preview at port 8880 presents the *same* TLS certificate as the web UI on port 443 (a symlink resolved at boot), so one browser trust decision covers both ports. TLS session resumption (RFC 5077 tickets) speeds up repeat HTTPS/RTSPS connections. The built-in preview/control HTTP server accepts 16 concurrent clients.

### Request Handling and Security

- Every non-loopback HTTP request must name the camera in its `Host` header (IP, `localhost` or the hostname) or get `421` -- this closes DNS-rebinding attacks against `/control`; `http.allowed_hosts` exists for reverse proxies and DNS aliases.
- Cross-origin POSTs that ride cached browser Basic/Digest credentials are refused with `403 bad origin` (browsers re-send those credentials on any cross-site form post, so a random web page could otherwise drive `/control` on a camera you are logged into). Token, loopback and script clients that send no `Origin` header are unaffected.
- HTTP Digest nonces are bound to the peer they were issued to, so a sniffed response cannot be replayed from another host.
- RTSP closes a connection after 5 rejected logins and drops connections that never reach `PLAY` within 60 s, so password guessing and idle `OPTIONS` loops cannot lock everyone out.
- Config rewrites keep the file's permissions, so a hand-applied `chmod 600` on `/etc/timps.conf` survives POSTs.
- The `{placeholder}` OSD vars file is fixed at `/tmp/timps_osd.vars`; `osd.vars_file` is not a config key.
- An SRT listener without a passphrase logs a warning when RTSP/HTTP credentials are set, since such a listener serves video to anyone.

### Client Table and Server Stats

`GET /control?clients=1` lists every connected consumer -- RTSP sessions, fMP4/MJPEG/events connections, WebRTC sessions and SRT receivers -- each with `ip`, `port`, `proto`, `chn`, `since_s` (connected seconds), a live `kbps` reading, total `bytes` sent and the client's `agent` (User-Agent, e.g. `FFmpeg Frigate/0.17.2` or `LibVLC/3.0.20`). It also reports `lat_ms`: how old a frame is when the streamer hands it to each client (sensor capture to send, averaged) -- typically 5-25 ms on T31 -- across all protocols. One-shot requests (snapshots) are not listed; the table costs ~8 KB RAM for 40 entries. The TIMPS Web UI shows the same table with Total and Latency columns, and the preview status line adds the browser's own share of the delay (`delay ≈ N ms`) with the breakdown as a tooltip.

`GET /control?stats=1` reports the streamer's own counters (session counts, encode drops) plus a `system` object (load average, total/available memory, machine and streamer CPU %) in the same JSON shape as the rest of `/control`; the Web UI shows it in the stats card. `?stats=1` and friends are matched as scoped queries rather than free-form config reads, and `/control` does not stall when the SD card wedges (`record.free_mb`/`timelapse.free_mb` refresh on a 10 s background clock).

### Recording on SD Card

- Recording prunes with a sanity-capped `record.min_free_mb` (default 200 MB, documented range 0-1048576, applies live on the next record cycle). Absurd values are refused and surfaced via `/control` status instead of wedging the SD loop, and the recorder backs off gracefully while the free-space target stays unreachable. The prune is a single SD walk.
- Pre-roll re-anchors to the oldest available keyframe in the ring, so clips start on complete frames.
- On-demand clips (`record.clip`) are RAM-budgeted -- a clip too large for the board is refused with a WARN instead of OOM-killing a 64 MB board.
- `record.dir`/`timelapse.dir` pointing at the root filesystem are refused (an SD mount point with no card in it would otherwise silently record into flash); the refusal shows up in `record.last_error`.
- `timelapse.keep_days` is clamped to 0..3650 -- a huge "keep forever" value no longer expires every single shot.

### Privacy Masking, Crop/Zoom and ROI

Availability of these image features is graded per build and SoC: `GET /control` reports `caps.roi` / `caps.fcrop` / `caps.rotation` tiers (`effective` / `experimental` / `unsupported`) -- encoder ROI needs an OpenIMP libimp, and most vendor blobs report `unsupported`. On capable builds:

- **Encoder ROI** (`roi<S>.<N>.*`, up to 4 regions per stream; 10 on T31 OpenIMP) keeps a monitored area -- a door, a gate -- at high quality while the rest of the frame compresses harder, cutting bitrate without losing detail where it matters. Applied live, per-region QP or delta-QP.
- **ISP FrontCrop / digital zoom** (`image.fcrop_*`) crops the sensor picture before encoding; the crop window follows `image.hflip`/`image.vflip` on OpenIMP. The Web UI offers **Crop/zoom** and **ROI** tabs on the overlays page with a full-sensor crop editor (drag the window, zoom slider to the real maximum) -- see [Web UI](03-web-ui.md).
- Rotation follows the encoder-side semantics (width/height multiples of 8 on T40/T41). The video page has a rotation selector, and `GET /control` reports `video.<N>.rotation_state` explaining why a stream runs unrotated.

### Open Media Stack Features (T40/T41, OpenIMP)

- **Image controls:** `image.drc_strength`, `image.dpc_strength` and `image.defog_strength` (0..255, 128 = the vendor default picture) are live-tunable.
- **Test-pattern buttons on the Web UI preview page:** modes 0-4 plus the mid-ISP pattern mode 5 where the build supports it. Day/night is held in day mode while a pattern runs, and mode 3 scores your motion detection (hits, misses, false alarms, detection delay).
- **Snapshots:** JPEG snapshots up to 4 MiB are supported.
- **T20 macroblock rate control is off by default:** the vendor encoder libraries enable macroblock-level QP control unless told otherwise -- on a T20 at 1080p15 that lifted streamer CPU use from ~7% to ~35% and made the first IDR at low bitrate coarser. Set `video.0.mbrc` to `1` via `POST /control` to re-enable (stream restart required); the state is reported as `video.<N>.mbrc` in `GET /control`.

### Seekable Recordings

The web server passes a player's `Range` header through to CGI scripts as `HTTP_RANGE`, so SD-card recordings streamed via the Web UI play seekable in VLC, Kodi and browsers instead of forcing a full-file download before playback.

### Optional Opus Audio

TIMPS can optionally stream audio using the Opus codec in addition to AAC.

### SSE Events

Server-Sent Events at `/events` provide real-time push notifications for motion, day/night changes, and other events.

### Browser Preview

TIMPS includes a built-in browser preview at `http://<camera-ip>:8880/` with snapshot, MJPEG, and MP4 streaming options.

### Divinus (experimental, T31)

Divinus is a compact proof-of-concept streamer for Ingenic T31 cameras, selectable as a build-time package alongside Prudynt and TIMPS. It speaks RTSP, serves JPEG snapshots from its own web server and can record fMP4. It is **not a working end-user package yet**: it builds and starts on a T31, but it is not integrated with the rest of the Thingino userland (day/night, OSD defaults, ONVIF discovery, WebUI) the way prudynt-t and timps are. Expect to run it by hand and adjust `/etc/divinus.yaml` for your sensor and board.

## Two-Way Audio (RTSP Backchannel)

Two-way audio works over the RTSP backchannel (ONVIF Profile T). Clients send audio to the camera speaker; the camera picks the codec by what the client sends (TCP or UDP).

**Raptor (development builds)** offers five talk-back codecs: **PCMU, PCMA, Opus, AAC and L16**, with UDP transport, receiver reports, and BYE leave handling. You can restrict the offer at build time with `backchannel_codecs` (e.g. `"pcmu,opus"`; empty offers everything the build carries). PCMU is the ONVIF Profile T baseline -- excluding it is honored but warned.

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

SD cards are mounted automatically at `/mnt/mmcblk0p1` in **async** mode, with a global dirty-page writeback bound. Sustained recording does not stall on every write to slow cards, which avoids periodic freezes and UI sluggishness on single-core cameras. Reliability is unaffected: diagnostics and recorder flows sync explicitly. A power cut can lose the last seconds of buffered writes (as with any async removable-media mount), but the filesystem itself is safe.

Format as FAT32 for best compatibility. Note that ext4 support is **not enabled by default** -- it requires enabling `BR2_PACKAGE_THINGINO_KOPT_EXTFS` in the build config. exFAT is supported via the `exfat-nofuse` kernel module and is the Web UI formatter's default. The exFAT module is preloaded at boot, so hot-inserted exFAT cards mount immediately: the card automounter only tries filesystems already loaded into the kernel. If an exFAT card never appears in `/mnt` on an older build, update the firmware (or format FAT32 as a workaround).

### SD Card Tips

- Use a 2GB--8GB card for best compatibility. Some 16GB and 32GB cards may not be recognized in U-Boot's 1-bit MMC mode, particularly on T23N cameras.
- Card detected but never shows up as `/dev/mmcblk0`? Builds that advertise only a narrow 3.2--3.4 V microSD/SDIO voltage window on T31 cameras let some cards fail voltage negotiation during enumeration, so the card never appears. Firmware advertising the full 2.7--3.6 V range initializes these cards normally. If a card works in other devices but never mounts on a T31 camera, update the firmware first.

### SD Card on T40/T41 (XBurst2)

SD card support on XBurst2 SoCs (T40/T41) works via the MSC controller. Cameras that declare SD card support in their profile (three XBurst2 profiles do) get the driver and automatic mounting.

## Motion Recording Recovery

After an unclean stop -- a crash, a power cut, or a watchdog restart -- the boot script clears stale recorder state, so if **Motion recording** is enabled it resumes automatically once the camera comes back. No action is needed.

**A full card does not take recording down.** When the SD card fills up, the recorder and recording manager handle the card-full condition cleanly instead of crashing or wedging the stream, and the cause is visible in the recorder's status. Free up space (or let automatic pruning do it) and recording continues.

## NFS Network Storage

Thingino supports NFS v2/v3 (not v4). NFS storage is **opt-in**: the share is not mounted at boot unless enabled. Configure it with the nested `nfs` object:

```sh
jct /etc/thingino.json set nfs.enabled true
jct /etc/thingino.json set nfs.share "server:/path/to/share"
```

The `S43mounts` init script mounts the share at `/mnt/nfs` on boot (using `-o nolock`). Verify with `mount | grep nfs`. Configurations still carrying the old top-level `nfs_share` key keep working. With `nfs.enabled` false the boot scripts simply skip the mount (the init script logs a notice instead of failing silently). To keep the configured address but mount right now, run `S43mounts force` -- it flips `nfs.enabled` to true and mounts immediately. The share value is redacted from diagnostics reports. Full setup notes: `docs/thingino/nfs-share.md` in the firmware tree.

The mount is **hard** (`hard,timeo=30,retrans=2`): if the NFS server stalls or disappears, writes block instead of silently losing data. Check `mount | grep nfs` if a stuck write ever freezes the camera -- that is the trade-off.

Recordings that lost their MP4 init segment (the `ftyp`+`moov` bytes a stalled write swallowed) can be repaired with `scripts/recover-nfs-recordings.py` from the firmware tree: it detects prudynt-t recordings with a missing init segment, copies it from a healthy recording of the same camera and stream settings (auto-detected, or `--donor FILE`), and writes `<name>.recovered.mp4` beside each damaged file. Originals are never modified, so it is safe to re-run. Stop the recording first -- the segment currently being written gets recovered half-finished.

Boot-time NFS mounts work reliably even when the NFS server is specified by **hostname**: the mount helper passes the bare hostname (not `server:/path`) to the kernel's route lookup.

### Media File Permissions

Snapshots and clips published by the notification system to storage (SD card or NFS share) are written world-readable (mode 644). Files saved by older builds keep their restrictive permissions -- a one-time `chmod 644` on the share fixes those.

## Filesystem Overlay

Thingino uses OverlayFS to provide a writable layer over the read-only root filesystem:

- **Lower layer** -- Read-only rootfs on the flash partition
- **Upper layer** -- Writable JFFS2 partition (`data.jffs2`)

Changes to configuration files persist across reboots. The overlay partition is limited in size -- use SD card or NFS for large files.

---

<- [Previous: Streaming and Video](05-streaming.md) | [Next: Night Vision and Lighting](07-night-vision.md) ->

## Day/Night Mode

Thingino automatically switches between day (color) and night (IR) modes based on ambient light. A single **daynightd** daemon coordinates the IR-CUT filter, IR LEDs, white LEDs, and ISP color mode, configured via a Web UI plugin. If your build still ships the old `thingino-daynight` package, update the firmware.

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

When enabled, cron entries are automatically generated for your location's sunrise and sunset times. Scheduled mode (`daynight.schedule`) keys its calendar to local solar time, so cameras in far-west time zones switch at real sunset rather than at UTC midnight.

### How Switching Works

The daemon uses EV log2 as the primary brightness metric (T31/T23/T21/T30) or gain log2 (T20). A reading of zero is valid -- the ISP reports EV log2 as 0 at the brightest measurable scene. Configurable sample counts set how many consecutive samples must exceed the threshold before switching, and a hysteresis factor prevents flapping.

The engine works in periodic dark looks: every 45 minutes, or sooner when brightness falls 20% (`daynight.jump_pct`) below the last look, it takes a silent 8-second look with the IR illuminator off. Failed day-checks back off exponentially (1, 2, 4 ... minutes, capped at 16 minutes), and the lamps recover within 60 seconds of a failed check.

At night the camera also watches the colour of the IR-lit picture (ISP AWB statistics). When a lamp or dawn shifts that colour by more than `daynight.color_pct` (default 3%, 0 = off, applied live) for 20 seconds, the daemon takes an extra dark look immediately instead of waiting for the next timer look, so a weak illuminator ends night mode within about 40 seconds. Colour looks are at least 5 minutes apart and the gap doubles toward 45 minutes; with a working colour trigger the periodic look stretches to every 6 hours, so a night sees about 6 dark looks instead of 16. Every failed check teaches the daemon how much brighter that light source reads, so a living-room lamp or a neighbour's IR camera no longer buys a look pair at every brightness jump.

A "day" verdict must hold: a check decides "day" only once the reading has stayed on the day side for 10 seconds after settling, so drivers that report a stale exposure for a few seconds after the IR switch cannot strand the camera in day mode with the lamp off. The boot-time check waits at most 30 seconds for a steady exposure and recognises an obviously-bright scene at once. Each stream gets a keyframe about 0.8 s after an IR or IR-cut switch, once auto-exposure has settled, so players show the new scene instead of the old one until the next GOP boundary.

Dawns stay calm: after a colour look the engine only re-checks while the reading is actually near the day boundary, and the overnight watchdog limit is 18 hours, so long winter nights do not end with a spurious check before dawn.

Two implementation notes: timed switches and IR-probe commands (`daynight.switch_cmd`, `daynight.irprobe_cmd`) are launched with `vfork()`, so they still run on boards under memory pressure; and on T20 cameras the routine `isp_info` fallback is logged at INFO, so the Web UI health tile does not flag healthy day/night as errors. On T21 cameras running the vendor ISP driver, day/night reads exposure from the IMP library instead of the `isp_path` proc file, which that driver corrupts on read.

The Web UI Day/Night page offers an Idle-Dark card for an optional extra-dark idle night mode (off by default).

### Threshold and Tolerance

- **Night threshold** -- EV log2 value at which the camera switches to night mode (default: `550000`)
- **Day threshold** -- EV log2 value at which the camera switches back to day mode (default: `350000`)
- **Brightness percentage thresholds** -- Optional overrides (`night_threshold_pct`, `day_threshold_pct`) that use a 0--100 brightness metric instead of raw EV values (defaults: 25 night / 50 day)

```sh
jct /etc/thingino.json set daynight.ev_night_threshold 550000
jct /etc/thingino.json set daynight.ev_day_threshold 350000
```

Day/night thresholds and behavior are also adjustable from the Web UI configuration page.

### Tuning Day/Night Thresholds

Thresholds that ship with the firmware are averages. Dark-room readings vary per sensor and mounting (enclosure, IR reflection); when a camera ignores its thresholds, measure instead of guessing.

**Measure first, then bracket:** read your actual brightness values (daylight, dusk, fully dark), then set percentage thresholds that bracket them. The percentage keys (`day_threshold`/`night_threshold`, 0-100 scale) map logarithmically to the daemon's raw brightness metric -- intermediate readings land in the hysteresis zone and hold the current mode, which is the point of the two thresholds. Percentage keys silently override the raw `ev_*` keys whenever they are set -- set one scale, don't mix them.

`GET /control?dn_history=1` serves the daemon's day/night decision history ring -- per-sample brightness values and the mode at each point. Read it right after you see a wrong switch:

```sh
curl http://<camera-ip>:8880/control?dn_history=1
```

Give the daemon about 20 seconds of sustained samples before expecting a mode flip, and remember that brightness under a covered lens is bounded by the sensor's max gain. When fixed times are preferable to auto-switching, `daynight.schedule` with start/stop times is the stable fallback.

The tuning constants `probe_min_gap_s`, `probe_confirm_s`, `boot_probe` and `diagnose_thresholds` are retired: they are ignored with a warning and no longer echoed in the status output.

**Real-world example (WUUK Y0510 / SC4336P):** the shipped raw-EV defaults (night >550000, day <350000) are miscalibrated for that sensor: daylight reads ~737k (misread as night) and a hand-covered lens reads ~1114k -- below the computed 1125k night line, so night mode can never engage in the dark, and because the percentage keys override raw `ev_*` values, raw thresholds alone cannot fix it. Working calibration:

```sh
jct /etc/thingino.json set daynight.day_threshold 38
jct /etc/thingino.json set daynight.night_threshold 30
service restart daynightd
logread | grep "Initial mode"   # verify thresholds took effect
```

If a camera latches in black-and-white night mode under bright light even though the lens is uncovered, update the firmware: builds that treat a zero EV reading as a missing reading cause exactly this.

### Live Day/Night Tuning (Raptor, master)

On master (Raptor), the whole day/night policy is runtime-tunable through `raptorctl ric` -- no reboot needed:

```sh
raptorctl ric set-threshold adc_night 200   # ADC below this = night
raptorctl ric set-threshold adc_day 600     # ADC above this = day
raptorctl ric get-thresholds                # show every tunable + trigger mode
raptorctl ric config save                   # persist the tune
```

Everything is live except the IR-CUT wiring and `enabled` (re-pinning a live ircut coil is a hardware hazard, not a tuning knob). Tunables include the ADC pair (`adc_night` must stay below `adc_day`), photo EV thresholds (`photo_ev_night`/`photo_ev_day`), the LED probe trio (`probe_gain_pct`, `probe_recheck_sec`), bank policies for `ir850`/`ir940` (apply immediately, even mid-night -- e.g. dropping the 850nm bank to kill a window reflection), `pulse_ms`, and trigger choice via `set-trigger`. Changes apply at runtime; `config save` persists them.

**IRCUT tuning keys (Raptor)** -- the ric daemon reads these from the `ircut` section of `/etc/raptor.conf` at startup (set with `raptorctl config set ircut <key> <value>` + `service restart raptor`):

- `trigger` -- `luma` (default), `gain`, `adc` or `photo`; picks the transition policy.
- `night_gain` / `night_luma` -- ISP total gain and luma limits for entering night mode.
- `day_gain_pct` / `probe_gain_pct` -- day-exit and IR-probe arm points as a percentage of the night baseline.
- `probe_holdoff_sec` / `probe_recheck_sec` -- LED-probe pacing (`probe_recheck_sec` > 0 forces a probe on that cadence even with no brightness dip).
- `hysteresis_sec` -- seconds a candidate mode must hold before a switch commits.
- `poll_interval_ms`, `pulse_ms`, `night_fps` -- polling cadence, IR-CUT coil pulse width, and night-mode frame rate.

On some boards (Wyze Cam v4 / OS04D10 tested) `ae_luma` is pinned near a constant by the auto-exposure loop, so `night_luma` never trips; entry is driven by total gain and the exit path runs on the EV baseline. Set thresholds from `raptorctl rvd get-exposure` readings on your own camera, not from another board's values.

### Night-Mode FPS Reduction

On ciao (Prudynt) builds, night-mode FPS halving is handled directly by Prudynt rather than a separate script. This produces smoother transitions and avoids brief stream interruptions when switching modes.

## IR-CUT Filter

The IR-CUT filter blocks infrared light during the day for accurate colors and removes it at night to allow IR illumination. GPIO pins are configured under `gpio.ircut` in `/etc/thingino.json`.

Cameras with a **dual-pin solenoid IR-CUT** (two GPIO pins, e.g. Wyze Cam v4) use a pin *pair* whose order encodes polarity. For the Wyze Cam v4 the correct declaration is:

```sh
jct /etc/thingino.json set gpio.ircut "50 49"
```

If both directions of the filter behave swapped (day actuation does what night should), reverse the pin order. Missing `gpio.ircut` entirely leaves the mechanical filter unmoved -- day/night switching then happens in the ISP only and night shots get a color cast under IR.

### IRCUT Pulse Duration

The `pulse_ms` option controls how long the GPIO pulse lasts when switching the IR-CUT filter. If your camera's IR-CUT filter is unreliable or switches too slowly/fast, adjust this:

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

ROI coordinates are interpreted against the monitored stream's own resolution, not the sensor's, so an ROI drawn for the substream matches the frames the motion engine actually sees. If an ROI on an older build seems offset, re-save it after updating.

Alert timing differs by alert type: speaker alerts and text-only notifications fire the moment motion is detected, while snapshot/clip uploads wait for the recording to finish (up to `video_length` + 10 s). On builds before this change, speaker alerts lag noticeably behind the event on long clip settings.

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
| FTP | `send2ftp` | Upload snapshots/clips to an FTP server |
| FTPS | `send2ftp` | Same upload over explicit TLS (AUTH TLS, port 21) for hosts that require it, e.g. Hetzner Storage Box -- enable "Use FTPS (explicit TLS)" in the notification settings; self-signed certificates are supported via the ignore-certificate option. The scheme is curl's explicit-TLS variant, not implicit TLS on port 990 |
| Storage | `send2storage` | Save recordings to SD card or NFS |
| XMPP | `send2xmpp` | Send message via Jabber/XMPP |
| Speaker | `playonspeaker` | Play an audio alert through the camera's speaker |

Enable via the Web UI under **Tools** or through `jct /etc/prudynt.json`.

**Note on master builds**: `send2xmpp` is a master-branch addition; on ciao/stable only the methods listed above it are available.

`send2ntfy` honors the configured scheme/SSL, sends the title and priority headers correctly, and forces HTTP/1.1 (HTTP/2 uploads to ntfy.sh stall around 84%). `send2webhook` sends a raw JSON POST body for text-only messages and a proper multipart payload when a photo/video/file is attached.

**Motion sensitivity applies to the whole frame:** when OSD burn-in splits the motion grid into horizontal strips around the timestamp, every strip honours the configured sensitivity, the timestamp exclusion zone is measured from the actually rendered timestamp, and changing the sensitivity applies without a manual restart.

**Motion snapshots are always fresh:** the snapshot attached to a motion alert is captured for that event, even with the snapshot worker idle (`jpeg_idle_fps=0`), instead of delivering the stale frame left in the snapshot buffer.

**Snapshots and clips land with readable permissions:** storage uploads (SD card or NFS, including the test snapshot) are written mode 644, so whatever lands in your share is readable by your NVR, HA, or other local users. On older builds the workaround was `find /mnt/... -name '*.jpg' -perm 600 -exec chmod a+r {} +`.

Motion events are suppressed while pan/tilt motors are active: the motors daemon publishes `/run/motors-active` while a move is in flight, and every streamer's motion bridge (Prudynt, Raptor, TIMPS) checks it, so panning the camera does not fire false motion alerts or clips.

## send2 Toolkit Architecture (master)

On the master branch the send2 notification scripts live in a standalone `thingino-send2` package shared by all three streamers (Prudynt, Raptor, TIMPS), with per-streamer adapter helpers:

- Capture is split per streamer -- no runtime streamer branching, each streamer uses its own adapter (`prudynt-helpers` for Prudynt, snapshot helpers for Raptor/TIMPS)
- Storage and FTP extensions handle extensionless temporary files correctly
- Raptor ships a live motion->send2 bridge (`raptor-motion` + `S32raptor-motion`), so motion alerts work with Raptor, not just Prudynt
- Settings live in `/etc/send2.json` as before

## Audio Alerts (Speaker)

Cameras with a built-in speaker can play audio alerts when motion is detected. Configure this from the Web UI under **Motion Guard**:

- **Speaker file** -- Optional. Audio file to play (must be Opus format on 8 MB flash cameras; MP3 requires 16 MB+ flash). Leave it empty to use a bundled sound: the test button plays `chime_1`, motion alerts play `motiondetectionactivated`.
- **Volume** -- Speaker volume (0--120)
- **Gain** -- Audio gain (0--31)
- **Repeat** -- Number of times to play (0 = forever)

The speaker settings share a save button with motion detection settings. Use the **Test** button to preview the sound without triggering motion; when no speaker file is configured it falls back to the bundled sound and reports the real result.

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
| WiFi RSSI | Sensor | Signal strength; the camera probes every wireless interface for the reading, so dual-radio boards (for example 2.4/5 GHz combos) report signal instead of staying unknown |
| Brightness | Sensor | Camera brightness, 0--100 percent |
| Day/Night State | Sensor | Current day/night mode (day or night) |
| Snapshot | Button | Take snapshot |
| Firmware Update | Update | Runs the supported full-upgrade path (`sysupgrade -f -B`, with a config backup). Requires the camera to be online with GitHub access |
| PTZ | Buttons | Up/Down/Left/Right/Home |
| Lamp Socket (Wyze) | Switch | On/off control of a Wyze Lamp Socket's switched outlet, alongside the Floodlight v1 light switch |

The Brightness and Day/Night State entities can be enabled or disabled independently of the gain/daynight entities via their own flags; Brightness is only discovered on cameras running the daynightd daemon.

On Raptor builds the agent adapter reads exposure and gain from Raptor's `rvd` runtime interface, and gain is reported in **dB** with a brightness entity that does not depend on daynightd. On builds that predate these changes the gain entity stays unknown.

Disable individual entities:

```sh
jct /etc/thingino.json set ha.enable_reboot false
```

All MQTT topics use the prefix `cameras/<hostname>/`. The camera's **hostname** is its identity, making it easy to identify cameras in your HA dashboard.

Discovery topics use a sanitized node id derived from the hostname: HA silently drops discovery topics whose node id contains characters outside `a-zA-Z0-9_-`, so an FQDN-style hostname like `cam-hall.rdw.one` is sanitized for discovery only -- state topics still use the full hostname -- and such cameras appear correctly in HA.

The HA integration also auto-discovers the camera's **sensor model** and **device model** from `/etc/os-release`, so the correct hardware name appears in HA automatically.

## MQTT

Thingino includes `mosquitto_pub` and `mosquitto_sub` clients. Configure broker settings under **Services -> MQTT Subscriptions** in the Web UI.

Motion publish script: `/usr/sbin/send2mqtt`

**Encrypted brokers (MQTTS, port 8883):** TLS uses the OS certificate store (`--tls-use-os-certs`), so brokers with valid certificates -- a Let's Encrypt-secured Home Assistant broker, for example -- connect without extra setup.

## NVR / VMS Compatibility

Thingino works with most NVR/VMS software via ONVIF or direct RTSP:

| Software | Method |
|----------|--------|
| UniFi Protect | ONVIF |
| Frigate | ONVIF (see note) |
| Blue Iris | ONVIF |
| Synology Surveillance Station | ONVIF (see note) |
| iSpy / Agent DVR | ONVIF |

Note for Synology Surveillance Station: cameras can opt into compatibility shims that coax Synology's non-standard camera setup flow (synthetic CreateProfile response, deletable SynoProfileToken). On custom builds enable the `Synology Surveillance Station compatibility` package option (build-time) and set `"adv_synology_nvr": true` in `/etc/onvif.json` at runtime. Default builds stay strictly ONVIF spec-compliant.

Note for Frigate + PTZ cameras: Frigate reads the camera's PTZ preset **names** from `GetPresets`, so the descriptions you set in the web UI appear in Frigate's preset menu instead of generic `preset_N` labels. Frigate keys its menu by the lowercased name and the preset token is unchanged, so existing `GotoPreset` calls keep working.

---

<- [Previous: Motion Detection and Alerts](08-motion-alerts.md) | [Next: PTZ (Pan-Tilt-Zoom)](10-ptz.md) ->

## Web UI

Hover over the live preview to access PTZ controls. Two control modes are available in **Settings -> Pan/Tilt Motors -> Behavior -> Preview PTZ controls**:

- **Step move** (default) -- Click or double-click directional buttons to move in steps
- **Continuous move** -- Press and hold directional buttons for smooth continuous movement

In continuous mode a fast double-tap is ignored as a double-tap (a second press on the same direction within 300 ms), and the control pad sets `touch-action: manipulation` so holding a direction on a phone does not trigger the browser's pinch-zoom.

On ciao and master builds with TIMPS as the streamer, preview PTZ uses a low-latency **WebSocket control path** (`BR2_PACKAGE_THINGINO_MOTORS_WS`, on by default when TIMPS is selected). Every TIMPS build ships the socket: if it is not running, the widget shows a notice instead of silently degrading. The joystick gates its minor axis with hysteresis, so a near-axis hold sends a clean single-axis vector. The preview also provides an on-screen **joystick** and motor sensitivity sliders in the motors settings, plus a motors daemon version badge.

Keyboard jog on the preview page uses **Shift + arrow keys** -- one discrete step per press, browser auto-repeat ignored. Plain arrow keys (and other modifiers) are left to the browser for normal page scrolling.

The preview also shows a **preset quick-bar** under the video: ten slots -- click to move, long-press to save the current position.

**Drag-to-point PTZ:** on TIMPS cameras, the preview video itself is a PTZ control -- click or tap a spot in the frame and the camera pans/tilts so that point moves to the center, with the motors UI syncing its settings panel in real time. Moving to a preset names it in the toast, the active preset highlight tolerates motor settle drift, and the arrows/joystick controls remain for fine adjustment.

## Presets

The Web UI includes a **PTZ Presets** card on **Settings -> Pan/Tilt Motors**: move the camera to a position, give it a description, and save it. Presets are stored in the `motors.presets` array of `/etc/thingino.json` (each entry has a stable numeric `id`, a free-form `description`, and `x`/`y` coordinates) and can be edited and reordered in a **PTZ settings modal**. The id never changes on reorder or rename, ONVIF clients see a stable token (`PresetToken_<id>`), and your description is reported as the preset **name**, so NVRs like Frigate show the labels you set instead of generic `preset_N` entries. Preset edits made in the preview-page PTZ settings modal persist across restarts. The **first preset doubles as the initial point** -- the motor daemon parks the camera at presets[0] on boot. `ptz_presets` CLI management still works (`-g`/`-a`/`-r`/`-o` reorder), and a pre-existing `/etc/ptz_presets.conf` is imported once, automatically.

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

Direction is determined by camera type:

- **SPI motor cameras** (Tapo C200 class): `invert_x` / `invert_y` are kernel module params in `/etc/thingino.json` and work as documented.
- **GPIO/TCU stepper cameras** (Cinnado D1 class): tilt direction is defined by the *pin order* of `gpio_tilt` in the camera profile -- `invert_y` is ignored entirely. If your tilt moves the wrong way, swap the two pins in `motors.gpio_tilt` instead.

```sh
jct /etc/thingino.json get motors.gpio_tilt
```

A flip set via `motors.invert_y` takes effect on reboot; the stop routine finds the real daemon PID and kills it before unloading the kernel module, so a restart does not leave PTZ dead, and a stop command during motion bails out before the daemon can enter the kernel wait that leaves `motors-daemon` stuck in D-state (worst case the move continues to its target or parks, and the camera stays responsive).

### Upside-Down Mounts

If the camera is mounted upside-down and you compensate with **Image Flip** (hflip/vflip) in the streamer, the motor directions follow the on-screen picture automatically. The streamer's `image.hflip` / `image.vflip` are combined with `invert_x` / `invert_y`, so a flipped mount needs no hand-tuned motor inversion:

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

**Which branch you get:** `sysupgrade -f` pulls from the branch your camera's build tracks. A ciao (stable) camera pulls ciao firmware and stays on stable. Master-branch builds publish to their own dated release tags (`master-YYYY-MM-DD`) instead of the generic `latest` tag, so a master camera pulls master firmware and stable cameras are never served a master build.

sysupgrade supports selective partition flashing and config backup/restore alongside full upgrades; a full upgrade still resets the environment.

**Reliability behavior:** during flashing, sysupgrade takes over the hardware watchdog (instead of just disarming it) to ensure the camera reboots cleanly even if flashing stalls, and keeps `dd` output quiet for cleaner logs. The reboot sequence after flashing runs from a tmpfs copy of busybox, so the flash and reboot do not depend on a rootfs being unmounted underneath them.

**Partition layout:** the flash loop writes each running MTD device the image bytes at the same absolute offsets (32K blocks, with a byte-addressing fallback), so the image is copied byte-for-byte regardless of how the image itself is partitioned. The virtual `upgrade` partition is skipped, since it overlaps kernel/rootfs/extras. When upgrading, sysupgrade copies the partition layout from `/proc/cmdline` into the U-Boot environment if the environment has no `mtdparts` variable (for example after an env reset or a full-chip flash), and `flash-ota` (`make ota-upgrade`) falls back to reading the layout from `/proc/cmdline` -- what the running system actually booted with. If an older build aborts with "ERROR: cannot read current mtdparts", update to a current build or seed the variable manually (`fw_setenv mtdparts '<layout from /proc/cmdline, without the mtdparts= prefix>'`) and re-run.

**Oversize guard:** a flash is rejected *before* erasing anything if the image is bigger than the sum of the camera's real partitions, and `make ota` runs the same preflight checks at build time (kernel, data, bootloader slot, and total image size against the layout). An oversized build fails cleanly instead of leaving the camera with a zero-byte data partition. Nothing to configure; if you ever see the refusal, your build config overflows the camera's flash chip.

**Rootfs-only flashing:** `sysupgrade -r` flashes only the rootfs partition and requires a current build -- older builds could compute a zero rootfs size and erase the rootfs before aborting, leaving the camera unbootable. A full image (`sysupgrade -f` or a full `.bin`) does not run this code path. Note `make ota-rootfs` flashes without a config backup, so settings reset; prefer `make ota-upgrade IP=<camera>` for rootfs+data flashing from your build host.

**RAM:** a full-image OTA needs only the firmware size plus about 2 MB of headroom in free `/tmp` (RAM), so it works on low-RAM cameras (64 MB and less) with a storage card mounted.

**Config backup:** full upgrades snapshot your selected config files to the backup partition *before* flashing and skip that partition during the full-chip flash, so the snapshot survives; the payload is compressed with gzip when available. Run `cfg-backup restore` after the reboot to put the files back, or let the automatic restore handle it: a one-time `S37cfg-autorestore` init script runs at first boot after an upgrade, restores your files if a valid backup snapshot is present, and reboots once into the restored config. On a fresh install (no backup) it quietly removes itself; if the restore fails, it stays and retries on the next boot. The restore runs before the network comes up, but that is fine -- it only touches local files, no network needed.

The default backup list includes `/etc/thingino.json`, TIMPS streamer settings (`/etc/timps.conf`), and ONVIF settings (`/etc/onvif.json`); the backup list is the same on master and ciao, and on ciao the camera **name and raptor.conf** (`/etc/raptor.conf`) are preserved across a full upgrade alongside the rest. See `/etc/cfg-backup.list` for the full list and the "You can add more paths" section at the bottom for adding your own.

**Config file location:** the camera's config lives at `/etc/thingino.json`. If a script on your build references `/dev/thingino.json`, update to a current build -- configs in `/dev` did not survive a reboot.

## SD Card Update

The most reliable update method, especially for cameras with unreliable WiFi:

1. Download the firmware `.bin` for your camera from [thingino.com](https://thingino.com) or build it with the [Image Builder](https://image-builder.thingino.com/)
2. Copy it to a FAT32 SD card (MBR partition table) as `autoupdate-full.bin`
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

Diagnostics output redacts sensitive fields (WiFi credentials, MAC addresses, and other identifying details) for privacy, so the report is safe to share in support channels. Uploads to tb.thingino.com use HTTPS; if the upload fails, the Web UI reports the error instead of redirecting to an empty page.

Or via SD card: create a `.diag` file on a blank SD card and insert it into the running camera.

## No Image / Wrong Sensor

Thingino detects the image sensor by its ID at boot. If the wrong sensor driver is configured, you see a clear error in the boot log and **no image is produced**. Check the boot log for sensor mismatch messages.

**SC2336P vs SC2337P (Sonoff and similar T23 cameras):** these two dies report the *same* chip ID to the driver, so they cannot be told apart by ID alone -- a profile built for one bound the other's init timings and image tuning, giving a wrong-looking or broken picture instead of a clean error. The sensor driver checks a revision register and selects the right die: a mismatched profile fails loudly at `AddSensor` (the usual "no image" path) instead of silently misbehaving. If your SC2336P/SC2337P camera shows odd colors or a dead image and the boot log mentions a sensor mismatch, identify the exact die and pick the matching profile. Requires a current build.

**T33DL mislabeled as T33LQ:** older SoC identification tables mapped the chip-ID byte 0x11 to "T33LQ", but that die is actually **T33DL** -- so affected cameras reported the wrong SoC name in the Web UI footer and `soc` output, along with several other T32/T33 variant names. Current builds also recognize the T32Pro and CW080 dies. If your camera shows the wrong chip family in the UI, update to a current build; hardware behavior is unchanged.

**Wyze Cam v4 sensor never detected / no video:** on some v4 units the OS04D10 sensor receives its 24 MHz master clock at too weak a GPIO drive strength, the sensor never answers on I2C, and the boot fails with "sensor undetect" -- no image. The camera profile raises the clock pin's drive strength via the device tree, and affected units detect and stream on first boot. If your v4 shows no video with a sensor-probe error in the log, update to a current build.

Camera sensors **cannot** be identified visually. Check `/proc/device-info` or boot logs for the sensor model. GalaxyCore sensors (GC-prefixed) generally have better low-light performance.

## WiFi Won't Connect

- Check reason codes in the log (see [Networking](04-networking.md))
- Ensure your WPA2 passphrase is correct
- Try moving the camera closer to the AP
- Verify the WiFi module's GPIO power config in `/etc/thingino.json`

**Boards that power WiFi through GPIOs:** some profiles use a `gpio.wlan` pin sequence to power or reset the WiFi module, and that sequence is applied on all kernel builds. If a camera's WiFi was dead from first boot with no driver error and the boot log says "Skipping WLAN GPIO toggling", update to a current build.

**aic8800-based cameras:** the boot script waits for the interface in `ip link` output (not `/proc/net/wireless`, which only lists WEXT-capable drivers -- full-MAC cfg80211 drivers like aic8800 never appear there). If startup shows a "WiFi missing" wait delay even though `wlan0` is up, update to a current build.

**First-boot stuck at "Running pre-portal WiFi scan":** during provisioning the camera scans for networks before starting its setup hotspot. A wedged WiFi driver could hang that scan indefinitely -- the camera sits at "Running pre-portal WiFi scan" for ten minutes, never broadcasts the setup AP, and gives no login prompt. Current builds hard-bound the scan to a few seconds. On an older build: power-cycle the camera (a retry usually gets past it), then flash a current build for a permanent fix.

## WebRTC 400 Bad Request (Firefox)

Set `media.gmp-gmpopenh264.enabled` to `true` in Firefox `about:config`.

## Settings Won't Save in Web UI

On stable (Prudynt) builds, the Web UI talks directly to the streamer API on port 8080 using an API key at `/etc/thingino-api.key`. If settings fail to load or save:

- Check that the streamer is running: `pidof prudynt_t`
- Verify the API key exists: `cat /etc/thingino-api.key`
- You may need to update to a current build

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

**Wired options for WiFi-only cameras:** NetConsole runs over a USB-Ethernet dongle plugged into the USB OTG data port (ASIX AX88772 works out of the box; for an AX88179 run `fw_setenv nc_ethact axg0` on the board). The dongle must be on the same network segment as the client.

**Security:** NetConsole has no authentication. In broadcast mode any host on the subnet can interrupt autoboot and get a U-Boot prompt -- enable it only on trusted networks. To pin a single client: `fw_setenv ncip <your-host-ip>`.

Covers the U-Boot phase only; kernel messages still need a serial console or Linux-side netconsole.

## Reboot Hangs (older builds)

`reboot` can hang forever on older builds: the kernel shutdown path disarms the hardware watchdog, so when shutdown or the low-level restart routine stalls, nothing resets the SoC and the camera sits there until power-cycled. Current builds keep the watchdog armed across shutdown as a fallback -- a wedged reboot self-resets after the configured watchdog timeout. If your camera hangs on `reboot`, power-cycle it and update the firmware.

## Copying Files via SCP

Thingino uses Dropbear SSH, which does **not** support SFTP. Always use the `-O` flag with OpenSSH 9.0+:

```sh
scp -O file.txt root@hostname.local:/tmp/
```

Without `-O`, OpenSSH defaults to the SFTP protocol and the transfer will fail.

## curl HTTPS Failures to Some Servers

On-device curl (used by notification scripts such as `send2telegram` and custom webhooks) negotiated TLS 1.3, but the small MIPS TLS stack fails the handshake against some servers -- typically self-hosted endpoints -- with "A field in a message was incorrect or inconsistent". Current builds cap curl at TLS 1.2 across all call sites. If an older build cannot reach your HTTPS endpoint, update the firmware.

The certificate bundle ships refreshed, and a `make update-certs` target lets image builders refresh it from the current Mozilla bundle at build time. If the camera must reach a server whose certificate chain postdates your firmware image, either update the firmware or run `make update-certs` before building.

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
| **Divinus** | Experimental proof-of-concept streamer for T31 cameras (RTSP, JPEG snapshots, fMP4 recording) |
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

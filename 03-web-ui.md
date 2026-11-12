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

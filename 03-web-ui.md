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

On stable builds using Prudynt, the Web UI talks to the streamer's API through same-origin CGI endpoints on the camera itself (since ciao `d48cfc659`, 2026-10-07). This matters if you browse the camera over HTTPS: pages loaded over HTTPS used to talk to the streamer's API on port 8080 over plain HTTP, and browsers blocked those requests as mixed content -- the RTSP/ONVIF password form and the streamer settings pages would fail to load or save with the console full of "blocked: mixed-content" errors. The proxy keeps using the API key at `/etc/thingino-api.key` internally, so nothing changes for plain-HTTP users; HTTPS users just need a ciao build from 2026-10-07 or newer.

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

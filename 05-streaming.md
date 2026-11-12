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

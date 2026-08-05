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

> **Firefox note:** If you get a 400 Bad Request error, set `media.gmp-gmpopenh264.enabled` to `true` in Firefox's `about:config`. The camera only supports H.264 video.

## ONVIF

Thingino provides ONVIF Profile S compliance, enabling compatibility with NVRs, VMS software, and home automation platforms. ONVIF services include:

- Media streaming (RTSP)
- PTZ control
- Event notifications (motion detection)
- Imaging settings

ONVIF motion events work with UniFi Protect and other NVRs that support third-party ONVIF cameras.

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

TIMPS (Tiny IMP Streamer) is a lightweight streamer available as an alternative to Prudynt/Raptor. When using TIMPS, these features are available:

### Live Control API

TIMPS exposes a live control API at `http://<camera-ip>:8880/control` (GET to read, POST to change):

- Adjust bitrate, FPS, GOP, and resolution on the fly
- Toggle audio, backchannel, privacy mode
- Control motion sensitivity in real time (IMP_IVS)
- Take snapshots

Example -- change main stream bitrate:

```sh
curl -X POST http://192.168.1.10:8880/control -d '{"stream0.bitrate": 2000000}'
```

### Day/Night Detection

TIMPS has built-in adaptive day/night detection with configurable boot-settle period and periodic night reconfirmation. This prevents false day/night flapping from temporary light changes.

### Optional Opus Audio

TIMPS can optionally stream audio using the Opus codec in addition to AAC.

### SSE Events

Server-Sent Events at `/events` provide real-time push notifications for motion, day/night changes, and other events.

### Browser Preview

TIMPS includes a built-in browser preview at `http://<camera-ip>:8880/` with snapshot, MJPEG, and MP4 streaming options.

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

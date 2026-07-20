# 5. Streaming & Video

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
mpv rtsp://thingino:thingino@192.168.1.10:554/ch0 --profile=low-latency --no-cache --cache-secs=0 --demuxer-readahead-secs=0 --cache-pause=no
```

## WebRTC (Live View)

> **Note**: WebRTC is only available with **Raptor**, which is currently in development builds only. It is **not available** in stable release builds (which use Prudynt).

When available, WebRTC provides ultra-low-latency live view in the Web UI. The camera's streaming daemon handles WebRTC negotiation automatically.

> **Firefox note**: If you get a 400 Bad Request error, ensure `media.gmp-gmpopenh264.enabled` is set to `true` in Firefox's `about:config`. The camera only supports H.264 video.

## ONVIF

Thingino provides ONVIF Profile S compliance, enabling compatibility with NVRs, VMS software, and home automation platforms. ONVIF services include:

- Media streaming (RTSP)
- PTZ control
- Event notifications (motion detection)
- Imaging settings

ONVIF motion events work with UniFi Protect and other NVRs that support third-party ONVIF cameras.

## OSD (On-Screen Display)

Thingino supports customizable OSD overlays with the following element types:

- **Timestamp** — Display current date/time (strftime format)
- **Hostname** — Camera hostname
- **IP Address** — Camera's IP address
- **Uptime** — Time since boot
- **Gain** — ISP gain indicator
- **Static Text** — User-defined text label

### How OSD Works on Stable (Prudynt)

On stable release builds, OSD data is **embedded as SEI metadata** within the H.264 stream — it is **not burned into the video pixels**. This means:

- Standard RTSP players (VLC, Blue Iris, Frigate) **cannot display** the OSD overlay
- Only the Thingino **Web UI dashboard** renders the OSD (as an SVG overlay on top of the video)
- The OSD is not visible in recorded video clips
- This design avoids performance issues on less powerful camera hardware

### Restoring OSD in RTSP/Recordings

Two scripts are available on the firmware repo's `ciao` branch for post-processing:

- **`sei-overlay.py`** — Extracts SEI metadata from recorded MP4 files and burns it into the video, or exports as ASS/SRT subtitles
- **`sei-rtsp.py`** — Real-time tool that pulls a live RTSP stream, extracts SEI, and re-broadcasts with OSD burned in (via ffmpeg drawtext)

### OSD Configuration

OSD is configured per-stream in `/etc/prudynt.json` under `osd`. Each element has a type, format, and position. Position uses `x,y` format with negative values offset from the right/bottom edge. The Web UI has a dedicated OSD editor page at **Streamer → OSD**.

### Creating a Logo

Create a transparent PNG, then convert to BGRA:
```sh
convert logo-100x30-alpha.png -depth 8 bgra:logo.bgra
```

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

← [Previous: Networking](04-networking.md) | [Next: Storage & Recording](06-storage.md) →


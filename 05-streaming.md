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

> **Note**: WebRTC is only available with **Raptor**, which is currently in development builds only. It is not available in release builds (which use prudynt) until Raptor becomes part of the release.

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

Thingino supports customizable OSD overlays:

- **Time/Date** — Display current time
- **Custom Text** — User-defined text label
- **Brightness indicator** — Shows current ISP gain
- **Logo** — Custom BGRA image overlay

### Creating a logo

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


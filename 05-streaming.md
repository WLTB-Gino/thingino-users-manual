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

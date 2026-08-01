The Web UI gives you a browser-based interface for managing your camera. Open it at `http://hostname.local` or `http://<camera-ip>`.

## Live Preview

Real-time video feed with low-latency preview. Hover over the preview to reveal PTZ controls.

On stable (Prudynt) builds, the OSD overlay is rendered as an SVG overlay in the Web UI only -- it is not burned into video. See [Streaming and Video](05-streaming.md) for the full OSD story.

## PTZ Controls

Two control modes are available under **Settings -> Pan/Tilt Motors -> Behavior -> Preview PTZ controls**:

- **Step move** (default) -- Click or double-click directional buttons to move in steps
- **Continuous move** -- Press and hold directional buttons for smooth continuous movement

## Streamer

The Streamer section contains OSD editor, main stream, sub-stream, image, and sensor configuration.

On stable builds using Prudynt, the Web UI talks directly to the streamer's API on port 8080 using an API key stored at `/etc/thingino-api.key`. If settings fail to load or save, the API key may be missing or the streamer may not be running.

### OSD Editor

The OSD editor at **Streamer -> OSD** lets you add, remove, and configure elements (timestamp, hostname, IP address, uptime, gain, static text, logo). Each element has position, font, color, and format settings.

Recent ciao builds support both SEI metadata mode (default) and an optional **burn-in** mode that renders the OSD directly into video pixels, making it visible in RTSP players and recordings.

## Settings

Network, video, motion, OSD, and system configuration. Advanced settings are available through the configuration editor, which directly edits `/etc/thingino.json`. You can also use the `jct` CLI tool from the shell.

## Tools

MQTT, email, Telegram, webhook, ntfy, gotify, FTP, storage, diagnostics, and more.

---

<- [Previous: First Boot & Initial Setup](02-first-boot.md) | [Next: Networking](04-networking.md) ->

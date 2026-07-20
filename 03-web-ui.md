# 3. Web UI

The Web UI provides a browser-based interface for managing your camera.

## Key Features

- **Live Preview** — Real-time video feed with low-latency preview. On stable (Prudynt) builds, the OSD overlay is rendered as an SVG overlay in the Web UI only (not burned into video — see [Streaming & Video](05-streaming.md) for details).
- **PTZ Controls** — Hover over the preview to reveal pan/tilt controls. Choose between "Step move" (click/double-click, default) or "Continuous move" (press and hold) via **Settings → Pan/Tilt Motors → Behavior → Preview PTZ controls**.
- **Streamer** — OSD editor, main stream, sub-stream, image, and sensor configuration
- **Settings** — Network, video, motion, OSD, and system configuration
- **Tools** — MQTT, email, telegram, webhook, ntfy, gotify, FTP, storage, diagnostics, and more

## OSD Overlay in Web UI

On stable builds using Prudynt, the Web UI renders the OSD as an SVG overlay on top of the live preview. This is the only place where OSD is visible — it is not embedded in RTSP streams or recordings. The OSD editor at **Streamer → OSD** lets you add, remove, and configure elements (timestamp, hostname, IP address, uptime, gain, static text).

## Configuration Editor

Advanced settings are available through the Web UI's configuration editor, which directly edits `/etc/thingino.json`. You can also use the `jct` CLI tool from the shell.

---

← [Previous: First Boot & Initial Setup](02-first-boot.md) | [Next: Networking](04-networking.md) →


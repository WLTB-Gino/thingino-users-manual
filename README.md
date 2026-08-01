# Thingino User's Manual

<img src="thingino-logo.svg" width="120" alt="Thingino Logo" />

> Open source firmware for IP cameras powered by Ingenic SoCs.

Welcome to the community-maintained user's manual for [Thingino](https://github.com/themactep/thingino-firmware). This guide covers everything you need to use your Thingino-powered camera -- from first boot to advanced configuration, home automation, and troubleshooting.

## Contents

| # | Chapter | Description |
|---|---------|-------------|
| 1 | [Overview](01-overview.md) | What Thingino is, design philosophy, community links |
| 2 | [First Boot & Initial Setup](02-first-boot.md) | Provisioning, credentials, time sync, shell access |
| 3 | [Web UI](03-web-ui.md) | Live preview, PTZ controls, night vision, settings |
| 4 | [Networking](04-networking.md) | WiFi, Ethernet, USB Ethernet, VPNs |
| 5 | [Streaming & Video](05-streaming.md) | RTSP, WebRTC, ONVIF, OSD, privacy mode |
| 6 | [Storage & Recording](06-storage.md) | SD card, NFS, OverlayFS |
| 7 | [Night Vision & Lighting](07-night-vision.md) | Day/night mode, IR-CUT, IR LEDs, white light |
| 8 | [Motion Detection & Alerts](08-motion-alerts.md) | Motion guard, alert methods |
| 9 | [Home Automation & Integration](09-home-automation.md) | Home Assistant, MQTT, NVR compatibility |
| 10 | [PTZ (Pan-Tilt-Zoom)](10-ptz.md) | Web UI controls, MQTT, motor configuration |
| 11 | [System Configuration](11-system-config.md) | JCT, GPIO, config files, OverlayFS |
| 12 | [Firmware Updates](12-firmware-updates.md) | OTA, SD card updates, version checking |
| 13 | [Troubleshooting](13-troubleshooting.md) | Diagnostics, common issues, unbricking |
| 14 | [Glossary](14-glossary.md) | Terms and abbreviations |

## What is Thingino?

Thingino replaces the stock firmware on IP cameras powered by Ingenic T-series SoCs (T10--T31). It provides a clean web UI, RTSP/WebRTC streaming, ONVIF support, motion detection, night vision, and home automation integration -- without cloud dependencies or vendor lock-in.

## Useful Links

- [Thingino Firmware Repo](https://github.com/themactep/thingino-firmware)
- [Wiki](https://github.com/themactep/thingino-firmware/wiki)
- [Telegram](https://t.me/thingino) / [Discord](https://discord.gg/gFc9jR2eXV)
- [WLTechBlog YouTube](https://www.youtube.com/@wltechblog) -- setup guides and reviews
- [Universal Unbricker](https://unbricker.wltechblog.com/)
- [Image Builder](https://image-builder.thingino.com/) -- build firmware in your browser
- [Scriba Web Flasher](https://scriba.thingino.com/) -- flash with a CH341A, no drivers needed

## About This Manual

This manual is validated against actual source code where possible and reflects the **ciao** (stable user release) branch. Development builds (master) may differ.

For installation instructions, see the [Thingino Wiki](https://github.com/themactep/thingino-firmware/wiki).

---

*This is a living document. Contributions and corrections are welcome!*

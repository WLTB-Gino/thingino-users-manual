# 1. Overview

## What is Thingino?

Thingino is an open source firmware that replaces the stock firmware on IP cameras powered by Ingenic T-series SoCs (T10, T20, T21, T23, T30, T31, T32, T33). It provides a full-featured camera system with RTSP streaming, ONVIF support, motion detection, night vision, and home automation integration — without cloud dependencies or vendor lock-in.

## Design Philosophy

- **Tailored, not universal** — Each camera gets firmware specifically built for its hardware, with minimum overhead.
- **Common sense engineering** — Simplicity and practicality over unnecessary complexity.
- **Open source** — All components, including U-Boot and the Linux kernel, are publicly available.

## Streamer

Thingino's stable release builds use **Prudynt**, the production streamer. OSD data is embedded as SEI metadata in the H.264 stream rather than burned into the video pixels.

**TIMPS** (Tiny IMP Streamer) is a newer lightweight alternative streamer by Lu-Fi, available as a package in recent builds. It offers on-demand encoding, live control API, per-stream OSD, grid motion detection, and native day/night detection.

**Raptor** is the next-generation modular streaming system, currently in development builds only. It will become the default in future releases.

## Unsupported Camera Types

**Solar and battery-powered cameras are NOT supported.** They use the Zeratul platform with a separate MCU that controls power — Thingino cannot keep the main SoC powered on.

## Community

- **Telegram**: https://t.me/thingino
- **Discord**: https://discord.gg/gFc9jR2eXV
- **Wiki**: https://github.com/themactep/thingino-firmware/wiki

---

[Next: First Boot & Initial Setup](02-first-boot.md) →


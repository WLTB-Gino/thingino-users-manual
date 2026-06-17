# 1. Overview

## What is Thingino?

Thingino is an open source firmware that replaces the stock firmware on IP cameras powered by Ingenic T-series SoCs (T10, T20, T21, T23, T30, T31). It provides a full-featured camera system with RTSP streaming, ONVIF support, motion detection, night vision, and home automation integration — without cloud dependencies or vendor lock-in.

## Design Philosophy

- **Tailored, not universal** — Each camera gets firmware specifically built for its hardware, with minimum overhead.
- **Common sense engineering** — Simplicity and practicality over unnecessary complexity.
- **Open source** — All components, including U-Boot and the Linux kernel, are publicly available.

## Streamer

Thingino is transitioning from **prudynt** to **Raptor**, its own fully open modular streaming system. Raptor is now the default streamer in the master branch.

## Unsupported Camera Types

**Solar and battery-powered cameras are NOT supported.** They use the Zeratul platform with a separate MCU that controls power — Thingino cannot keep the main SoC powered on.

## Community

- **Telegram**: https://t.me/thingino
- **Discord**: https://discord.gg/gFc9jR2eXV
- **Wiki**: https://github.com/themactep/thingino-firmware/wiki

---

[Next: First Boot & Initial Setup](02-first-boot.md) →


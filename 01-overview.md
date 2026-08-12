## What is Thingino?

Thingino is open source firmware that replaces the stock firmware on IP cameras powered by Ingenic T-series SoCs (T10, T20, T21, T23, T30, T31, T32, T33, T40, T41). You get a full-featured camera system with RTSP streaming, ONVIF support, motion detection, night vision, and home automation integration -- without cloud dependencies or vendor lock-in.

## Design Philosophy

- **Tailored, not universal** -- Each camera gets firmware built specifically for its hardware, with minimum overhead.
- **Common sense engineering** -- Simplicity and practicality over unnecessary complexity.
- **Open source** -- All components, including U-Boot and the Linux kernel, are publicly available.

## Streamer

Thingino's stable release builds use **Prudynt**, the production streamer. OSD data is embedded as SEI metadata in the H.264 stream by default, and recent ciao builds add an optional burn-in mode that renders OSD directly into video pixels.

**TIMPS** (Tiny IMP Streamer) is a newer lightweight alternative by Lu-Fi, available as a package in recent builds. It offers on-demand encoding (idle at 0% CPU), a live control API (POST/GET /control), SSE event push (/events), per-stream TrueType OSD, grid motion detection (IMP_IVS), native day/night detection, privacy cover masks, local SD recording, and optional Opus audio codec. Supports RTSP Digest/HTTP Basic auth and token auth.

**Raptor** is the next-generation modular streaming system, currently in development builds only. It will become the default in future releases. As of recent master builds, Raptor now uses **daynightd** as its day/night engine (replacing the older RIC tool), with dedicated `daynight`, `ircut`, and `light` wrapper scripts for both Web UI and command-line use.

Recent master and ciao builds also integrate the **open-isp** package -- a complete open media stack for ISP tuning and development, including an `isp-inspector` tool that displays exposure values as log2 stops.

## SoC Support

Thingino currently runs on **Ingenic** T-series SoCs (T10, T20, T21, T23, T30, T31, T32, T33, T40, T41). Early groundwork for **SigmaStar** (Infinity6e/SSC30KQ) support has been merged, but no usable SigmaStar camera builds exist yet.

## SNMP Monitoring

Thingino includes an optional **thingino-snmpd** package (mini-snmpd 2.0) for network monitoring via SNMP. When enabled, it integrates with the Web UI as a plugin and exposes camera system metrics to SNMP managers like PRTG, Zabbix, or LibreNMS.

## Recently Added Cameras

- **Wyze Cam Pan V1** (JXF23 sensor + RTL8189FTV WiFi variant) -- master and ciao
- **Wyze Floodlight V2** (T41NQ) -- ciao branch
- **Hugolog E5P** (T41LQ) -- ciao branch
- **Kiwibit BC111** (T23ZN) -- ciao branch
- **Cinnado B6** (T23ZN) -- ciao branch

Check [thingino.com](https://thingino.com) for the full list of supported cameras.

## Unsupported Camera Types

**Solar and battery-powered cameras are not supported.** They use the Zeratul platform with a separate MCU that controls power -- Thingino cannot keep the main SoC powered on.

## Community

- **Telegram**: https://t.me/thingino
- **Discord**: https://discord.gg/gFc9jR2eXV
- **Wiki**: https://github.com/themactep/thingino-firmware/wiki

## Web Tools

Two browser-based tools make Thingino more accessible:

- **[Image Builder](https://image-builder.thingino.com/)** -- Select your branch and camera model, and it builds a fresh firmware image in about 18 minutes. Useful if you cannot do a local build.
- **[Scriba Web Flasher](https://scriba.thingino.com/)** -- A browser-based CH341A flash tool (read, write, erase) that runs in Chrome. No drivers or local software to install. This is the recommended method for flashing with a programmer.

---

[Next: First Boot & Initial Setup](02-first-boot.md) ->

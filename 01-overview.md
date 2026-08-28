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

- **Shelly S1** (T23N, MIS20C1 sensor, ATBM6132CU WiFi) -- master and ciao (experimental)
- **Wyze Cam v3 + RT5370 USB dongle** (T31X, GC2053 -- for units with unsupported internal WiFi; uses an external RT5370 USB dongle) -- ciao (experimental)
- **Vanhua S62I** (T40XP, SPI-NAND, IMX307, Ethernet) -- master and ciao (experimental)
- **Vanhua Z55** (T31X, GC4653 4MP, Ethernet) -- master and ciao. Builds from 2026-08-28 repin the AVPU hardware encoder clock to a reachable 600 MHz, so it sustains H.265 2560x1440 at 30 fps with lower CPU use (previously the encoder silently ran at 400 MHz and dropped frames at 25 fps)
- **Wyze Cam Pan V1** (JXF23 sensor + RTL8189FTV WiFi variant) -- master and ciao
- **Wyze Floodlight V2** (T41NQ) -- ciao branch
  - The Floodlight v1 light (via Wyze Cam Floodlight v1 accessory) now has a `floodlight_ctl` CLI for brightness control: `floodlight_ctl on <1-100>` / `floodlight_ctl off` (verbose with `-v`)
- **Hugolog E5P** (T41LQ) -- ciao branch
- **Kiwibit BC111** (T23ZN) -- ciao branch
- **Cinnado B6** (T23ZN) -- ciao branch

Check [thingino.com](https://thingino.com) for the full list of supported cameras.

## Unsupported Camera Types

**Solar and battery-powered cameras are not supported.** They use the Zeratul platform with a separate MCU that controls power -- Thingino cannot keep the main SoC powered on.

## Secure Boot (eFuse-Locked) Cameras

Some cameras ship with eFuse secure boot locked: Wyze Cam V4, Wyze Doorbell V2, Wyze Cam Pan 3/4, and select Galayou, Xiaomi, and Camsoy models. Thingino `master` builds patch the U-Boot SPL at build time (the `secureboop` package) so firmware images boot on these SoCs. Models on T23/T32/T40/T41 need no extra data; T31-based locked models additionally require the vendor RSA modulus extracted from a stock flash dump.

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

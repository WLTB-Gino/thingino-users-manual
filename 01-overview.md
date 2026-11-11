## What is Thingino?

Thingino is open source firmware that replaces the stock firmware on IP cameras powered by Ingenic T-series SoCs (T10, T20, T21, T23, T30, T31, T32, T33, T40, T41). You get a full-featured camera system with RTSP streaming, ONVIF support, motion detection, night vision, and home automation integration -- without cloud dependencies or vendor lock-in.

## Design Philosophy

- **Tailored, not universal** -- Each camera gets firmware built specifically for its hardware, with minimum overhead.
- **Common sense engineering** -- Simplicity and practicality over unnecessary complexity.
- **Open source** -- All components, including U-Boot and the Linux kernel, are publicly available.

## Streamer

Thingino's stable release builds use **Prudynt**, the production streamer. OSD data is embedded as SEI metadata in the H.264 stream by default; ciao builds offer an optional burn-in mode that renders OSD directly into video pixels.

**TIMPS** (Tiny IMP Streamer) is a lightweight alternative by Lu-Fi, available as an optional package. It offers on-demand encoding (idle at 0% CPU), a live control API (POST/GET /control), SSE event push (/events), per-stream TrueType OSD, grid motion detection (IMP_IVS), native day/night detection, privacy cover masks, local SD recording, and optional Opus audio codec. It supports RTSP Digest/HTTP Basic auth and token auth.

**Divinus** is a third, experimental streamer option: a compact proof-of-concept for T31 cameras with RTSP, a snapshot web server and fMP4 recording. Select it at build time, run it by hand and tune `/etc/divinus.yaml`; it is not yet wired into the WebUI, day/night or ONVIF the way the other two are (see [Streaming](05-streaming.md)).

**Raptor** is the next-generation modular streaming system, currently in development builds only. It will become the default in future releases. Raptor uses **daynightd** as its day/night engine (the successor to the older RIC tool), with dedicated `daynight`, `ircut`, and `light` wrapper scripts for both Web UI and command-line use.

The **open-isp** package is also integrated in master and ciao builds -- a complete open media stack for ISP tuning and development, including an `isp-inspector` tool that displays exposure values as log2 stops.

## SoC Support

Thingino runs on **Ingenic** T-series SoCs (T10, T20, T21, T23, T30, T31, T32, T33, T40, T41). The first T32 camera profile is the Cinnado D1 T32LQ; builds for T32 are new and experimental. Early groundwork for **SigmaStar** (Infinity6e/SSC30KQ) support is merged, but no usable SigmaStar camera builds exist yet.

See [thingino.com](https://thingino.com) for the full list of supported cameras.

## SNMP Monitoring

Thingino includes an optional **thingino-snmpd** package (mini-snmpd 2.0) for network monitoring via SNMP. When enabled, it integrates with the Web UI as a plugin and exposes camera system metrics to SNMP managers like PRTG, Zabbix, or LibreNMS.

## Unsupported Camera Types

**Solar and battery-powered cameras are not supported.** They use the Zeratul platform with a separate MCU that controls power -- Thingino cannot keep the main SoC powered on.

## Secure Boot (eFuse-Locked) Cameras

Some cameras ship with eFuse secure boot locked: Wyze Cam V4, Wyze Doorbell V2, Wyze Cam Pan 3/4, and select Galayou, Xiaomi, and Camsoy models. Thingino `master` builds patch the U-Boot SPL at build time (the `secureboop` package) so firmware images boot on these SoCs. Models on T23/T32/T40/T41 need no extra data; T31-based locked models additionally require the vendor RSA modulus extracted from a stock flash dump.

## Community

- **Telegram**: https://t.me/thingino
- **Discord**: https://discord.gg/gFc9jR2eXV
- **Wiki**: https://github.com/themactep/thingino-firmware/wiki

## Video Guides, Unbricking & Installer Images

- **[WLTechBlog on YouTube](https://www.youtube.com/@WLTechBlog)** -- Step-by-step installation and unbricking videos, plus a curated list of cameras that are easy to install Thingino on.
- **[Universal Unbricker](https://unbricker.wltechblog.com/)** -- Web tool by Josh at WLTechBlog that builds a per-camera unbrick image for the flash glitch recovery method. Check the device list for supported models.
- **[thingino-installers](https://github.com/wltechblog/thingino-installers)** -- Ready-made per-model SD-card installer images for the first flash from stock to Thingino. Installers are for initial installation only -- never use them to update an existing install; do a full firmware upgrade afterwards instead.

## Web Tools

Two browser-based tools make Thingino more accessible:

- **[Image Builder](https://image-builder.thingino.com/)** -- Select your branch and camera model, and it builds a fresh firmware image in about 18 minutes. Useful if you cannot do a local build.
- **[Scriba Web Flasher](https://scriba.thingino.com/)** -- A browser-based CH341A flash tool (read, write, erase) that runs in Chrome. No drivers or local software to install. This is the recommended method for flashing with a programmer.

---

[Next: First Boot & Initial Setup](02-first-boot.md) ->

# Thingino User's Manual — Validation Report vs. Source Code

## ✅ CORRECT (no changes needed)

| Section | Claim | Verified Against |
|---------|-------|-----------------|
| 1. Overview | SoCs: T10-T31 | Config structure |
| 1. Overview | Raptor is default streamer | S31raptor in master |
| 2. First Boot | Default creds thingino/thingino | prudynt.json |
| 2. First Boot | DHCP Option 42 (NTP), 101 (timezone) | S49ntpd, S01timezone |
| 2. First Boot | SSH via Dropbear | S50dropbear |
| 4. Networking | WiFi reconfigure via jct + S36wireless | S36wireless.in |
| 4. Networking | Ethernet MAC from SoC serial | S03mac |
| 4. Networking | Wireguard available | S42wireguard |
| 5. Streaming | RTSP endpoints ch0/ch1 | prudynt.json |
| 5. Streaming | WebRTC Firefox OpenH264 fix | Memory correction |
| 5. Streaming | OSD config fields | prudynt.json stream0.osd |
| 7. Night Vision | Day/Night threshold/tolerance | prudynt.json daynight |
| 9. HA | MQTT auto-discovery + entity table | docs/homeassistant.md |
| 10. PTZ | Motor config, dw9714-ctrl | thingino-motors |
| 11. Config | jct commands, rc.local via S94 | S94rc.local |
| 12. Updates | OTA from GitHub | sysupgrade script |
| 13. Troubleshooting | thingino-diag -u -o flags | thingino-diag |

## ❌ ERRORS (factually wrong)

1. **Privacy Mode (§5)** — Manual shows prudynt's `/run/prudynt/video_ctrl`. Raptor (current default) uses `raptorctl rod privacy on [channel]`. Fix needed.

2. **IRCUT command (§7)** — Manual shows `jct set ircut true/false`. Actual binary is `overlay/usr/sbin/ircut` with args: `ircut on|off|toggle|status`. GPIO configured under `gpio.ircut` in thingino.json.

3. **NFS persistent mount (§6)** — Manual says add to rc.local. Actually handled by S43mounts automatically: `jct /etc/thingino.json set nfs_share "server:/path"` → mounts at `/mnt/nfs` with `-o nolock`.

4. **Config files table (§11)** — Only lists prudynt.json. Should include `/etc/raptor.conf` as the primary config for current firmware.

## ⚠️ INCOMPLETE / MISSING

5. **Alert methods (§8)** — Missing: send2ntfy, send2gotify, send2ftp, send2storage, send2xmpp (new in Figata).

6. **Firmware update prerequisite (§12)** — Must run `fw_setenv enable_updates true` then reboot before OTA works (per sysupgrade script).

7. **Diagnostics upload URL (§13)** — Uploads to `tb.thingino.com` via send2termbin, not "thingino.com". Missing `-j` and `-f` flags.

8. **`.diag` SD trigger (§6/§13)** — Could not find code backing this. May be a wiki myth — needs verification or removal.

## Summary

| Category | Count |
|----------|-------|
| ✅ Correct | 17+ |
| ❌ Errors | 4 |
| ⚠️ Incomplete | 4 |

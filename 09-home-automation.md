## Home Assistant

Thingino has native Home Assistant integration via MQTT auto-discovery. No YAML required.

**Setup:**

```sh
jct /etc/thingino.json set ha.enabled true
/etc/init.d/S93ha restart
```

**Available entities:**

| Entity | Type | Description |
|--------|------|-------------|
| Motion detected | Binary sensor | Motion state |
| Motion Guard | Switch | Enable/disable motion |
| IR Cut Filter | Switch | Day/night filter |
| Day/Night Mode | Select | Day/Night toggle |
| Privacy Screen | Switch | Black out video |
| Color Mode | Switch | Color vs monochrome |
| IR LED 850nm | Switch | 850nm IR LEDs |
| IR LED 940nm | Switch | 940nm IR LEDs |
| White Light | Switch | White LEDs |
| WiFi RSSI | Sensor | Signal strength |
| Snapshot | Button | Take snapshot |
| Firmware Update | Update | OTA from GitHub -- currently broken: the button still calls the retired `sysupgrade -p`, which modern builds reject. Update from the Web UI (System -> Upgrade) or with `sysupgrade -f` instead |
| PTZ | Buttons | Up/Down/Left/Right/Home |

Disable individual entities:

```sh
jct /etc/thingino.json set ha.enable_reboot false
```

All MQTT topics use the prefix `cameras/<hostname>/`. Recent builds use the camera **hostname** as its identity (instead of MAC address or SoC serial), making it easier to identify cameras in your HA dashboard.

**FQDN-style hostnames:** HA silently drops discovery topics whose node id contains characters outside `a-zA-Z0-9_-`, so a hostname like `cam-hall.rdw.one` used to produce discovery messages HA discarded. Builds from 2026-09-20 derive a sanitized node id for discovery topics only -- state topics still use the full hostname -- so such cameras appear correctly in HA.

The HA integration also auto-discovers the camera's **sensor model** and **device model** from `/etc/os-release`, so the correct hardware name appears in HA automatically.

## MQTT

Thingino includes `mosquitto_pub` and `mosquitto_sub` clients. Configure broker settings under **Services -> MQTT Subscriptions** in the Web UI.

Motion publish script: `/usr/sbin/send2mqtt`

**Encrypted brokers (MQTTS, port 8883):** builds from 2026-09-06 use the OS certificate store for TLS (`--tls-use-os-certs`), so brokers with valid certificates -- a Let's Encrypt-secured Home Assistant broker, for example -- connect without extra setup. Earlier builds passed `--capath`, which the camera's mbedTLS mosquitto backend does not implement, so TLS connections failed certificate verification.

## NVR / VMS Compatibility

Thingino works with most NVR/VMS software via ONVIF or direct RTSP:

| Software | Method |
|----------|--------|
| UniFi Protect | ONVIF |
| Frigate | ONVIF (see note) |
| Blue Iris | ONVIF |
| Synology Surveillance Station | ONVIF (see note) |
| iSpy / Agent DVR | ONVIF |

Note for Synology Surveillance Station: cameras on builds from 2026-08-17 (thingino-onvif `70d35cf`) can opt into compatibility shims that coax Synology's non-standard camera setup flow (synthetic CreateProfile response, deletable SynoProfileToken). On custom builds enable the `Synology Surveillance Station compatibility` package option (build-time) and set `"adv_synology_nvr": true` in `/etc/onvif.json` at runtime. Default builds stay strictly ONVIF spec-compliant.

Note for Frigate + PTZ cameras: an ONVIF GetStatus bug (fixed in thingino-onvif `6f299f3`, included in builds from 2026-08-16) caused Frigate to crash with `AttributeError: 'NoneType' object has no attribute 'Position'` on cameras without zoom. Update your firmware if you hit this; old firmware pins also accept a manual workaround (upload the `GetStatus_nozoom.xml` template to `/var/www/onvif/ptz_service_files/`).

Frigate reads the camera's PTZ preset **names** from `GetPresets`, so the descriptions you set in the web UI appear in Frigate's preset menu instead of generic `preset_N` labels. This needs firmware builds from 2026-09-20 (earlier builds exposed only the raw token). Frigate keys its menu by the lowercased name and the preset token is unchanged, so existing `GotoPreset` calls keep working.

---

<- [Previous: Motion Detection and Alerts](08-motion-alerts.md) | [Next: PTZ (Pan-Tilt-Zoom)](10-ptz.md) ->

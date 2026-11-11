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
| WiFi RSSI | Sensor | Signal strength; the camera probes every wireless interface for the reading, so dual-radio boards (for example 2.4/5 GHz combos) report signal instead of staying unknown |
| Brightness | Sensor | Camera brightness, 0--100 percent |
| Day/Night State | Sensor | Current day/night mode (day or night) |
| Snapshot | Button | Take snapshot |
| Firmware Update | Update | Runs the supported full-upgrade path (`sysupgrade -f -B`, with a config backup). Requires the camera to be online with GitHub access |
| PTZ | Buttons | Up/Down/Left/Right/Home |
| Lamp Socket (Wyze) | Switch | On/off control of a Wyze Lamp Socket's switched outlet, alongside the Floodlight v1 light switch |

The Brightness and Day/Night State entities can be enabled or disabled independently of the gain/daynight entities via their own flags; Brightness is only discovered on cameras running the daynightd daemon.

On Raptor builds the agent adapter reads exposure and gain from Raptor's `rvd` runtime interface, and gain is reported in **dB** with a brightness entity that does not depend on daynightd. On builds that predate these changes the gain entity stays unknown.

Disable individual entities:

```sh
jct /etc/thingino.json set ha.enable_reboot false
```

All MQTT topics use the prefix `cameras/<hostname>/`. The camera's **hostname** is its identity, making it easy to identify cameras in your HA dashboard.

Discovery topics use a sanitized node id derived from the hostname: HA silently drops discovery topics whose node id contains characters outside `a-zA-Z0-9_-`, so an FQDN-style hostname like `cam-hall.rdw.one` is sanitized for discovery only -- state topics still use the full hostname -- and such cameras appear correctly in HA.

The HA integration also auto-discovers the camera's **sensor model** and **device model** from `/etc/os-release`, so the correct hardware name appears in HA automatically.

## MQTT

Thingino includes `mosquitto_pub` and `mosquitto_sub` clients. Configure broker settings under **Services -> MQTT Subscriptions** in the Web UI.

Motion publish script: `/usr/sbin/send2mqtt`

**Encrypted brokers (MQTTS, port 8883):** TLS uses the OS certificate store (`--tls-use-os-certs`), so brokers with valid certificates -- a Let's Encrypt-secured Home Assistant broker, for example -- connect without extra setup.

## NVR / VMS Compatibility

Thingino works with most NVR/VMS software via ONVIF or direct RTSP:

| Software | Method |
|----------|--------|
| UniFi Protect | ONVIF |
| Frigate | ONVIF (see note) |
| Blue Iris | ONVIF |
| Synology Surveillance Station | ONVIF (see note) |
| iSpy / Agent DVR | ONVIF |

Note for Synology Surveillance Station: cameras can opt into compatibility shims that coax Synology's non-standard camera setup flow (synthetic CreateProfile response, deletable SynoProfileToken). On custom builds enable the `Synology Surveillance Station compatibility` package option (build-time) and set `"adv_synology_nvr": true` in `/etc/onvif.json` at runtime. Default builds stay strictly ONVIF spec-compliant.

Note for Frigate + PTZ cameras: Frigate reads the camera's PTZ preset **names** from `GetPresets`, so the descriptions you set in the web UI appear in Frigate's preset menu instead of generic `preset_N` labels. Frigate keys its menu by the lowercased name and the preset token is unchanged, so existing `GotoPreset` calls keep working.

---

<- [Previous: Motion Detection and Alerts](08-motion-alerts.md) | [Next: PTZ (Pan-Tilt-Zoom)](10-ptz.md) ->

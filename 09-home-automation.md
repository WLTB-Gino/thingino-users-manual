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

Settings are validated: invalid values sent to the configuration pages (for example a malformed boolean) are rejected instead of being written to `/etc/thingino.json`.

Disable individual entities:

```sh
jct /etc/thingino.json set ha.enable_reboot false
```

All MQTT topics use the prefix `cameras/<hostname>/`. The camera's **hostname** is its identity, making it easy to identify cameras in your HA dashboard.

Discovery topics use a sanitized node id derived from the hostname: HA silently drops discovery topics whose node id contains characters outside `a-zA-Z0-9_-`, so an FQDN-style hostname like `cam-hall.rdw.one` is sanitized for discovery only -- state topics still use the full hostname -- and such cameras appear correctly in HA.

The HA integration also auto-discovers the camera's **sensor model** and **device model** from `/etc/os-release`, so the correct hardware name appears in HA automatically.

## Programmable buttons

Cameras and doorbells with a physical button expose it as a Linux input key. The `thingino-button` service watches the button and runs shell commands from `/etc/thingino-button.conf` when it is pressed, released, or held.

Rules are one per line:

```
KEY_<name> <action> <seconds> <command>
```

- **Key names:** `KEY_0` through `KEY_9`, `KEY_MINUS`, and `KEY_ENTER`. Doorbell products map the doorbell button to `KEY_1`; the setup button on most cameras is `KEY_ENTER`.
- **Actions:**
  - `PRESS 0` -- command runs the moment the button goes down.
  - `RELEASE 0` -- command runs when the button comes back up.
  - `TIMED <seconds>` -- command runs on release if the button was held at least that long. When several TIMED rules match a hold, only the one with the longest time runs.
  - `TIMED_FIRE <seconds>` -- command runs while the button is still held, as soon as the time elapses.
- **Command:** the rest of the line, run through `/bin/sh`.

On Wyze doorbells, `KEY_1` ships configured to ring the chime (`doorbell_event button_press`) and play a local doorbell sound. Rules you append run alongside those.

### Example: webhook on doorbell press

```sh
echo KEY_1 RELEASE 0 send2webhook -u http://192.168.1.10:9000/hooks/chime -m \'{"action":"chime"}\' >> /etc/thingino-button.conf
/etc/init.d/S15thingino-button restart
```

Notes:

- `PRESS` and `RELEASE` differ only by the physical press duration (typically 0.1--0.3 seconds). Either is fine on a doorbell button.
- On setup buttons, prefer `TIMED` rules for user commands: `PRESS` and `RELEASE` fire on every press, including the long-press maintenance holds (a 5 second hold resets wireless, a 20 second hold factory-resets the camera), while a `TIMED` rule below those thresholds stays silent whenever a longer hold action claims the event. When two TIMED rules share the same duration, the one listed first in the file wins.
- Keep each rule on its own line, and add it once -- re-running the `echo` line duplicates the rule and the command fires twice per press.
- The file lives on the writable overlay: rules survive reboots but a firmware reflash resets them.

### Seeing button events

```sh
logread | grep thingino-button
```

Each press logs the detected key code and which rule fired.

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

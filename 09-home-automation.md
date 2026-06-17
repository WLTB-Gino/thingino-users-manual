# 9. Home Automation & Integration

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
| Firmware Update | Update | OTA from GitHub |
| PTZ | Buttons | Up/Down/Left/Right/Home |

Disable individual entities:
```sh
jct /etc/thingino.json set ha.enable_reboot false
```

All MQTT topics use the prefix `cameras/<mac_address>/`.

## MQTT

Thingino includes `mosquitto_pub` and `mosquitto_sub` clients. Configure broker settings under **Services → MQTT Subscriptions** in the Web UI.

Motion publish script: `/usr/sbin/send2mqtt`

## NVR / VMS Compatibility

Thingino works with most NVR/VMS software via ONVIF or direct RTSP:

| Software | Method |
|----------|--------|
| **UniFi Protect** | ONVIF events (motion) |
| **Frigate** | RTSP |
| **Blue Iris** | RTSP |
| **Synology Surveillance Station** | ONVIF or RTSP |
| **iSpy / Agent DVR** | RTSP |

---

← [Previous: Motion Detection & Alerts](08-motion-alerts.md) | [Next: PTZ (Pan-Tilt-Zoom)](10-ptz.md) →


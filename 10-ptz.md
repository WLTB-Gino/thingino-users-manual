# 10. PTZ (Pan-Tilt-Zoom)

## Web UI

Hover over the live preview to access PTZ controls. Double-click the center circle to return to home position.

## MQTT / Home Assistant

Enable PTZ buttons in HA:
```sh
jct /etc/thingino.json set ha.enable_ptz true
```

Commands: `cameras/<id>/ptz/{up,down,left,right,home}/set`

## Motor Configuration

PTZ motor GPIO configuration is defined in `/etc/thingino.json` under the `motors` key. VCM (Voice Coil Motor) focus control uses the `dw9714-ctrl` script, with GPIO config in `motors.json`.

---

← [Previous: Home Automation & Integration](09-home-automation.md) | [Next: System Configuration](11-system-config.md) →


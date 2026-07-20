# 10. PTZ (Pan-Tilt-Zoom)

## Web UI

Hover over the live preview to access PTZ controls. Two control modes are available in **Settings → Pan/Tilt Motors → Behavior → Preview PTZ controls**:

- **Step move** (default) — Click or double-click directional buttons to move in steps
- **Continuous move** — Press and hold directional buttons for smooth continuous movement

## MQTT / Home Assistant

Enable PTZ buttons in HA:
```sh
jct /etc/thingino.json set ha.enable_ptz true
```

Commands: `cameras/<id>/ptz/{up,down,left,right,home}/set`

## Motor Configuration

PTZ motor configuration is defined in `/etc/thingino.json` under the `motors` key. All motor settings (GPIO pins, step modes, speed, range) are unified into this single config file — there is no longer a separate `motors.json`. VCM (Voice Coil Motor) focus control uses the `dw9714-ctrl` script.

---

← [Previous: Home Automation & Integration](09-home-automation.md) | [Next: System Configuration](11-system-config.md) →


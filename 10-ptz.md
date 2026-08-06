## Web UI

Hover over the live preview to access PTZ controls. Two control modes are available in **Settings -> Pan/Tilt Motors -> Behavior -> Preview PTZ controls**:

- **Step move** (default) -- Click or double-click directional buttons to move in steps
- **Continuous move** -- Press and hold directional buttons for smooth continuous movement

## MQTT / Home Assistant

Enable PTZ buttons in HA:

```sh
jct /etc/thingino.json set ha.enable_ptz true
```

Commands: `cameras/<id>/ptz/{up,down,left,right,home}/set`

## Motor Configuration

PTZ motor configuration lives in `/etc/thingino.json` under the `motors` key. All motor settings -- GPIO pins, step modes, speed, range -- are unified into this single config file. There is no separate `motors.json`.

VCM (Voice Coil Motor) focus control uses the `dw9714-ctrl` script.

### Motor Direction Inversion

Recent builds fix a long-standing bug where `invert_x` and `invert_y` in `/etc/thingino.json` were silently ignored. If your camera's pan or tilt moved the wrong direction, these settings now work correctly:

```sh
jct /etc/thingino.json set motors.invert_y true
```

A double-inversion issue that caused position counter overshoot (blocking all further movement in that axis) has also been fixed.

---

<- [Previous: Home Automation and Integration](09-home-automation.md) | [Next: System Configuration](11-system-config.md) ->

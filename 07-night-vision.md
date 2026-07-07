# 7. Night Vision & Lighting

## Day/Night Mode

Thingino automatically switches between day (color) and night (IR) modes based on ambient light. The switching is handled by a unified `daynight` system that coordinates the IR-CUT filter, IR LEDs, white LEDs, and ISP color mode.

### Manual Control

Use the `daynight` command to switch modes manually:

```sh
daynight day     # Switch to day mode (IR-CUT in, IR LEDs off, color)
daynight night   # Switch to night mode (IR-CUT out, IR LEDs on, mono)
daynight toggle  # Switch to opposite state
daynight status  # Show current mode
```

### Individual Component Commands

Individual components can still be controlled directly:

```sh
ircut on|off|toggle|status   # IR-CUT filter
light ir850 on|off           # 850nm IR LEDs
light ir940 on|off           # 940nm IR LEDs
light white on|off           # White light LEDs
color on|off|toggle          # ISP color/monochrome mode (Raptor only)
```

### Configuration

Day/night behavior is configured in `/etc/thingino.json` under `daynight.controls`. Each component can be individually enabled or disabled:

```sh
jct /etc/thingino.json set daynight.controls.color true
jct /etc/thingino.json set daynight.controls.ircut true
jct /etc/thingino.json set daynight.controls.ir850 true
jct /etc/thingino.json set daynight.controls.ir940 false
jct /etc/thingino.json set daynight.controls.white false
```

When a control is set to `false`, the `daynight` script skips that component during mode switches.

### Sun-Based Scheduling

Thingino can switch modes based on actual sunrise/sunset times using `dusk2dawn`:

```sh
jct /etc/thingino.json set daynight.sun.enabled true
```

When enabled, cron entries are automatically generated for your location's sunrise and sunset times.

### Threshold & Tolerance

- **Day/Night Threshold** — Light level at which the camera switches modes
- **Day/Night Tolerance** — Buffer to prevent frequent switching from minor light changes

Both are adjustable from the Web UI configuration menu or via `jct`.

## IR-CUT Filter

The IR-CUT filter blocks infrared light during the day for accurate colors and removes it at night to allow IR illumination. GPIO pins are configured under `gpio.ircut` in `/etc/thingino.json`.

## IR LEDs

Most cameras have integrated IR LED arrays (850nm or 940nm). Some use an LDR (light-dependent resistor) to auto-switch LEDs independently of the camera.

IR LED beam angle should match the lens:

| Lens | Beam Angle |
|------|------------|
| 8mm | 45° |
| 6mm | 60° |
| 4mm | 80° |
| 3.6mm | 90° |

## White Light LEDs

Some cameras include white light LEDs for full-color night vision. These can be controlled via the Web UI, `jct`, or Home Assistant.

---

← [Previous: Storage & Recording](06-storage.md) | [Next: Motion Detection & Alerts](08-motion-alerts.md) →


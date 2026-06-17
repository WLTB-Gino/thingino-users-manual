# 7. Night Vision & Lighting

## Day/Night Mode

Thingino automatically switches between day (color) and night (IR) modes based on ambient light:

- **Day/Night Threshold** — Light level at which the camera switches modes
- **Day/Night Tolerance** — Buffer to prevent frequent switching from minor light changes

Both are adjustable from the Web UI configuration menu or via `jct`.

## IR-CUT Filter

The IR-CUT filter blocks infrared light during the day for accurate colors and removes it at night to allow IR illumination. Control manually with the `ircut` command:

```sh
ircut on      # Day mode (filter in — blocks IR)
ircut off     # Night mode (filter out — allows IR)
ircut toggle  # Switch to opposite state
ircut status  # Show current state
```

GPIO pins for the IR-CUT filter are configured under `gpio.ircut` in `/etc/thingino.json`.

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


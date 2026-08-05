## Day/Night Mode

Thingino automatically switches between day (color) and night (IR) modes based on ambient light. A dedicated **daynightd** daemon coordinates the IR-CUT filter, IR LEDs, white LEDs, and ISP color mode.

### Manual Control

```sh
daynight day     # Switch to day mode (IR-CUT in, IR LEDs off, color)
daynight night   # Switch to night mode (IR-CUT out, IR LEDs on, mono)
daynight toggle  # Switch to opposite state
daynight status  # Show current mode
```

### Individual Component Commands

You can also control components individually:

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

### Threshold and Tolerance

The daynightd daemon uses EV log2 as the primary brightness metric (T31/T23/T21/T30) or gain log2 (T20). The thresholds are configurable:

- **Night threshold** -- EV log2 value at which the camera switches to night mode (default: `550000`)
- **Day threshold** -- EV log2 value at which the camera switches back to day mode (default: `350000`)
- **Brightness percentage thresholds** -- Optional overrides (`night_threshold_pct`, `day_threshold_pct`) that use a 0--100 brightness metric instead of raw EV values

The daemon also includes configurable sample counts (how many consecutive samples must exceed the threshold before switching) and a hysteresis factor to prevent flapping.

```sh
jct /etc/thingino.json set daynight.ev_night_threshold 550000
jct /etc/thingino.json set daynight.ev_day_threshold 350000
```

Day/night thresholds and behavior are also adjustable from the Web UI configuration page.

## IR-CUT Filter

The IR-CUT filter blocks infrared light during the day for accurate colors and removes it at night to allow IR illumination. GPIO pins are configured under `gpio.ircut` in `/etc/thingino.json`.

### IRCUT Pulse Duration

Recent builds add a configurable `pulse_ms` option for the IR-CUT filter actuation pulse. This controls how long the GPIO pulse lasts when switching the filter. If your camera's IR-CUT filter is unreliable or switches too slowly/fast, adjust this:

```sh
jct /etc/thingino.json set gpio.pulse_ms 10
```

This is available on both master (Raptor) and ciao (Prudynt) branches.

## IR LEDs

Most cameras have integrated IR LED arrays (850nm or 940nm). Some use an LDR (light-dependent resistor) to auto-switch LEDs independently of the camera.

Match IR LED beam angle to your lens:

| Lens | Beam Angle |
|------|------------|
| 8mm | 45 degrees |
| 6mm | 60 degrees |
| 4mm | 80 degrees |
| 3.6mm | 90 degrees |

## White Light LEDs

Some cameras include white light LEDs for full-color night vision. Control them via the Web UI, `jct`, or Home Assistant.

---

<- [Previous: Storage and Recording](06-storage.md) | [Next: Motion Detection and Alerts](08-motion-alerts.md) ->

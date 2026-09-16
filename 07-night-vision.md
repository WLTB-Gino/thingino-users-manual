## Day/Night Mode

Thingino automatically switches between day (color) and night (IR) modes based on ambient light. A dedicated **daynightd** daemon coordinates the IR-CUT filter, IR LEDs, white LEDs, and ISP color mode. As of recent builds, the old `thingino-daynight` package has been consolidated into `thingino-daynightd` -- all day/night logic now lives in a single daemon with a Web UI plugin for configuration.

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

- **Night threshold** -- EV log2 value at which the camera switches to night mode (default: `550000`). The percentage-based `night_threshold` default was raised from 20 to 25 in recent ciao builds for less flapping at dusk.
- **Day threshold** -- EV log2 value at which the camera switches back to day mode (default: `350000`)
- **Brightness percentage thresholds** -- Optional overrides (`night_threshold_pct`, `day_threshold_pct`) that use a 0--100 brightness metric instead of raw EV values

### Tuning day/night thresholds (v1.9.15+)

Thresholds that ship with the firmware are averages. Dark-room readings vary per sensor and mounting (enclosure, IR reflection); when a camera ignores its thresholds, measure instead of guessing.

TIMPS v1.9.15 added a built-in tuning loop that closes this loop entirely on the camera:

- **`GET /control?dn_history=1`** serves the daemon's day/night decision history ring — per-sample brightness values and the mode at each point. Read it right after you see a wrong switch: `curl http://<camera-ip>:8880/control?dn_history=1`
- **`daynight.diagnose_thresholds`** is reported in `GET /control` status JSON (v1.9.15+), so scripts can detect misconfiguration.

**Measure first, then bracket:** read your actual brightness values (daylight, dusk, fully dark), then set percentage thresholds that bracket them. The percentage keys (`day_threshold`/`night_threshold`, 0-100 scale) map logarithmically to the daemon's raw brightness metric — intermediate readings land in the hysteresis zone and hold the current mode, which is the point of the two thresholds.

**Real-world example (WUUK Y0510 / SC4336P, ciao 2488702):** the shipped raw-EV defaults (night >550000, day <350000) were miscalibrated for that sensor: daylight read ~737k (misread as night), a hand-covered lens read ~1114k — below the computed 1125k night line, so night mode could never engage in the dark. First fix attempt (raw `ev_*` thresholds 800000/1200000) booted to day but still never reached night: the daemon's percentage keys (`daynight.day_threshold`/`night_threshold`, default 50/25) silently override the raw `ev_*` keys whenever they are set — set the percentage keys, don't mix scales. Working calibration:

```sh
jct /etc/thingino.json set daynight.day_threshold 38
jct /etc/thingino.json set daynight.night_threshold 30
service restart daynightd
logread | grep "Initial mode"   # verify thresholds took effect
```

Two extra practical rules from that case: brightness under a covered lens is bounded by the sensor's max gain (don't chase ever-higher values), and give the daemon ~20 seconds of sustained samples before expecting a mode flip. When a schedule-based mode is preferable, `daynight.schedule` with start/stop times is the stable fallback.

The daemon also includes configurable sample counts (how many consecutive samples must exceed the threshold before switching) and a hysteresis factor to prevent flapping.

```sh
jct /etc/thingino.json set daynight.ev_night_threshold 550000
jct /etc/thingino.json set daynight.ev_day_threshold 350000
```

Day/night thresholds and behavior are also adjustable from the Web UI configuration page.

### Live Day/Night Tuning (Raptor, master)

On master (Raptor), the whole day/night policy is runtime-tunable through `raptorctl ric` -- no reboot needed:

```sh
raptorctl ric set-threshold adc_night 200   # ADC below this = night
raptorctl ric set-threshold adc_day 600     # ADC above this = day
raptorctl ric get-thresholds                # show every tunable + trigger mode
raptorctl ric config save                   # persist the tune
```

Everything is live except the IR-CUT wiring and `enabled` (re-pinning a live ircut coil is a hardware hazard, not a tuning knob). Tunables include the ADC pair (`adc_night` must stay below `adc_day`), photo EV thresholds (`photo_ev_night`/`photo_ev_day`), the LED probe trio (`probe_gain_pct`, `probe_recheck_sec`), bank policies for `ir850`/`ir940` (apply immediately, even mid-night -- e.g. dropping the 850nm bank to kill a window reflection), `pulse_ms`, and trigger choice via `set-trigger`. Changes apply at runtime; `config save` persists them.

### Night-Mode FPS Reduction

On ciao (Prudynt) builds, night-mode FPS halving is now handled directly by Prudynt rather than a separate script. This produces smoother transitions and avoids brief stream interruptions when switching modes.

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

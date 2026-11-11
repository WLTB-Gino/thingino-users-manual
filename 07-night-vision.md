## Day/Night Mode

Thingino automatically switches between day (color) and night (IR) modes based on ambient light. A single **daynightd** daemon coordinates the IR-CUT filter, IR LEDs, white LEDs, and ISP color mode, configured via a Web UI plugin. If your build still ships the old `thingino-daynight` package, update the firmware.

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

When enabled, cron entries are automatically generated for your location's sunrise and sunset times. Scheduled mode (`daynight.schedule`) keys its calendar to local solar time, so cameras in far-west time zones switch at real sunset rather than at UTC midnight.

### How Switching Works

The daemon uses EV log2 as the primary brightness metric (T31/T23/T21/T30) or gain log2 (T20). A reading of zero is valid -- the ISP reports EV log2 as 0 at the brightest measurable scene. Configurable sample counts set how many consecutive samples must exceed the threshold before switching, and a hysteresis factor prevents flapping.

The engine works in periodic dark looks: every 45 minutes, or sooner when brightness falls 20% (`daynight.jump_pct`) below the last look, it takes a silent 8-second look with the IR illuminator off. Failed day-checks back off exponentially (1, 2, 4 ... minutes, capped at 16 minutes), and the lamps recover within 60 seconds of a failed check.

At night the camera also watches the colour of the IR-lit picture (ISP AWB statistics). When a lamp or dawn shifts that colour by more than `daynight.color_pct` (default 3%, 0 = off, applied live) for 20 seconds, the daemon takes an extra dark look immediately instead of waiting for the next timer look, so a weak illuminator ends night mode within about 40 seconds. Colour looks are at least 5 minutes apart and the gap doubles toward 45 minutes; with a working colour trigger the periodic look stretches to every 6 hours, so a night sees about 6 dark looks instead of 16. Every failed check teaches the daemon how much brighter that light source reads, so a living-room lamp or a neighbour's IR camera no longer buys a look pair at every brightness jump.

A "day" verdict must hold: a check decides "day" only once the reading has stayed on the day side for 10 seconds after settling, so drivers that report a stale exposure for a few seconds after the IR switch cannot strand the camera in day mode with the lamp off. The boot-time check waits at most 30 seconds for a steady exposure and recognises an obviously-bright scene at once. Each stream gets a keyframe about 0.8 s after an IR or IR-cut switch, once auto-exposure has settled, so players show the new scene instead of the old one until the next GOP boundary.

Dawns stay calm: after a colour look the engine only re-checks while the reading is actually near the day boundary, and the overnight watchdog limit is 18 hours, so long winter nights do not end with a spurious check before dawn.

Two implementation notes: timed switches and IR-probe commands (`daynight.switch_cmd`, `daynight.irprobe_cmd`) are launched with `vfork()`, so they still run on boards under memory pressure; and on T20 cameras the routine `isp_info` fallback is logged at INFO, so the Web UI health tile does not flag healthy day/night as errors. On T21 cameras running the vendor ISP driver, day/night reads exposure from the IMP library instead of the `isp_path` proc file, which that driver corrupts on read.

The Web UI Day/Night page offers an Idle-Dark card for an optional extra-dark idle night mode (off by default).

### Threshold and Tolerance

- **Night threshold** -- EV log2 value at which the camera switches to night mode (default: `550000`)
- **Day threshold** -- EV log2 value at which the camera switches back to day mode (default: `350000`)
- **Brightness percentage thresholds** -- Optional overrides (`night_threshold_pct`, `day_threshold_pct`) that use a 0--100 brightness metric instead of raw EV values (defaults: 25 night / 50 day)

```sh
jct /etc/thingino.json set daynight.ev_night_threshold 550000
jct /etc/thingino.json set daynight.ev_day_threshold 350000
```

Day/night thresholds and behavior are also adjustable from the Web UI configuration page.

### Tuning Day/Night Thresholds

Thresholds that ship with the firmware are averages. Dark-room readings vary per sensor and mounting (enclosure, IR reflection); when a camera ignores its thresholds, measure instead of guessing.

**Measure first, then bracket:** read your actual brightness values (daylight, dusk, fully dark), then set percentage thresholds that bracket them. The percentage keys (`day_threshold`/`night_threshold`, 0-100 scale) map logarithmically to the daemon's raw brightness metric -- intermediate readings land in the hysteresis zone and hold the current mode, which is the point of the two thresholds. Percentage keys silently override the raw `ev_*` keys whenever they are set -- set one scale, don't mix them.

`GET /control?dn_history=1` serves the daemon's day/night decision history ring -- per-sample brightness values and the mode at each point. Read it right after you see a wrong switch:

```sh
curl http://<camera-ip>:8880/control?dn_history=1
```

Give the daemon about 20 seconds of sustained samples before expecting a mode flip, and remember that brightness under a covered lens is bounded by the sensor's max gain. When fixed times are preferable to auto-switching, `daynight.schedule` with start/stop times is the stable fallback.

The tuning constants `probe_min_gap_s`, `probe_confirm_s`, `boot_probe` and `diagnose_thresholds` are retired: they are ignored with a warning and no longer echoed in the status output.

**Real-world example (WUUK Y0510 / SC4336P):** the shipped raw-EV defaults (night >550000, day <350000) are miscalibrated for that sensor: daylight reads ~737k (misread as night) and a hand-covered lens reads ~1114k -- below the computed 1125k night line, so night mode can never engage in the dark, and because the percentage keys override raw `ev_*` values, raw thresholds alone cannot fix it. Working calibration:

```sh
jct /etc/thingino.json set daynight.day_threshold 38
jct /etc/thingino.json set daynight.night_threshold 30
service restart daynightd
logread | grep "Initial mode"   # verify thresholds took effect
```

If a camera latches in black-and-white night mode under bright light even though the lens is uncovered, update the firmware: builds that treat a zero EV reading as a missing reading cause exactly this.

### Live Day/Night Tuning (Raptor, master)

On master (Raptor), the whole day/night policy is runtime-tunable through `raptorctl ric` -- no reboot needed:

```sh
raptorctl ric set-threshold adc_night 200   # ADC below this = night
raptorctl ric set-threshold adc_day 600     # ADC above this = day
raptorctl ric get-thresholds                # show every tunable + trigger mode
raptorctl ric config save                   # persist the tune
```

Everything is live except the IR-CUT wiring and `enabled` (re-pinning a live ircut coil is a hardware hazard, not a tuning knob). Tunables include the ADC pair (`adc_night` must stay below `adc_day`), photo EV thresholds (`photo_ev_night`/`photo_ev_day`), the LED probe trio (`probe_gain_pct`, `probe_recheck_sec`), bank policies for `ir850`/`ir940` (apply immediately, even mid-night -- e.g. dropping the 850nm bank to kill a window reflection), `pulse_ms`, and trigger choice via `set-trigger`. Changes apply at runtime; `config save` persists them.

**IRCUT tuning keys (Raptor)** -- the ric daemon reads these from the `ircut` section of `/etc/raptor.conf` at startup (set with `raptorctl config set ircut <key> <value>` + `service restart raptor`):

- `trigger` -- `luma` (default), `gain`, `adc` or `photo`; picks the transition policy.
- `night_gain` / `night_luma` -- ISP total gain and luma limits for entering night mode.
- `day_gain_pct` / `probe_gain_pct` -- day-exit and IR-probe arm points as a percentage of the night baseline.
- `probe_holdoff_sec` / `probe_recheck_sec` -- LED-probe pacing (`probe_recheck_sec` > 0 forces a probe on that cadence even with no brightness dip).
- `hysteresis_sec` -- seconds a candidate mode must hold before a switch commits.
- `poll_interval_ms`, `pulse_ms`, `night_fps` -- polling cadence, IR-CUT coil pulse width, and night-mode frame rate.

On some boards (Wyze Cam v4 / OS04D10 tested) `ae_luma` is pinned near a constant by the auto-exposure loop, so `night_luma` never trips; entry is driven by total gain and the exit path runs on the EV baseline. Set thresholds from `raptorctl rvd get-exposure` readings on your own camera, not from another board's values.

### Night-Mode FPS Reduction

On ciao (Prudynt) builds, night-mode FPS halving is handled directly by Prudynt rather than a separate script. This produces smoother transitions and avoids brief stream interruptions when switching modes.

## IR-CUT Filter

The IR-CUT filter blocks infrared light during the day for accurate colors and removes it at night to allow IR illumination. GPIO pins are configured under `gpio.ircut` in `/etc/thingino.json`.

Cameras with a **dual-pin solenoid IR-CUT** (two GPIO pins, e.g. Wyze Cam v4) use a pin *pair* whose order encodes polarity. For the Wyze Cam v4 the correct declaration is:

```sh
jct /etc/thingino.json set gpio.ircut "50 49"
```

If both directions of the filter behave swapped (day actuation does what night should), reverse the pin order. Missing `gpio.ircut` entirely leaves the mechanical filter unmoved -- day/night switching then happens in the ISP only and night shots get a color cast under IR.

### IRCUT Pulse Duration

The `pulse_ms` option controls how long the GPIO pulse lasts when switching the IR-CUT filter. If your camera's IR-CUT filter is unreliable or switches too slowly/fast, adjust this:

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

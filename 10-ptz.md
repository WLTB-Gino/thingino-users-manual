## Web UI

Hover over the live preview to access PTZ controls. Two control modes are available in **Settings -> Pan/Tilt Motors -> Behavior -> Preview PTZ controls**:

- **Step move** (default) -- Click or double-click directional buttons to move in steps
- **Continuous move** -- Press and hold directional buttons for smooth continuous movement

In continuous mode a fast double-tap is ignored as a double-tap (a second press on the same direction within 300 ms), and the control pad sets `touch-action: manipulation` so holding a direction on a phone does not trigger the browser's pinch-zoom.

On ciao and master builds with TIMPS as the streamer, preview PTZ uses a low-latency **WebSocket control path** (`BR2_PACKAGE_THINGINO_MOTORS_WS`, on by default when TIMPS is selected). Every TIMPS build ships the socket: if it is not running, the widget shows a notice instead of silently degrading. The joystick gates its minor axis with hysteresis, so a near-axis hold sends a clean single-axis vector. The preview also provides an on-screen **joystick** and motor sensitivity sliders in the motors settings, plus a motors daemon version badge.

Keyboard jog on the preview page uses **Shift + arrow keys** -- one discrete step per press, browser auto-repeat ignored. Plain arrow keys (and other modifiers) are left to the browser for normal page scrolling.

The preview also shows a **preset quick-bar** under the video: ten slots -- click to move, long-press to save the current position.

**Drag-to-point PTZ:** on TIMPS cameras, the preview video itself is a PTZ control -- click or tap a spot in the frame and the camera pans/tilts so that point moves to the center, with the motors UI syncing its settings panel in real time. Moving to a preset names it in the toast, the active preset highlight tolerates motor settle drift, and the arrows/joystick controls remain for fine adjustment.

## Presets

The Web UI includes a **PTZ Presets** card on **Settings -> Pan/Tilt Motors**: move the camera to a position, give it a description, and save it. Presets are stored in the `motors.presets` array of `/etc/thingino.json` (each entry has a stable numeric `id`, a free-form `description`, and `x`/`y` coordinates) and can be edited and reordered in a **PTZ settings modal**. The id never changes on reorder or rename, ONVIF clients see a stable token (`PresetToken_<id>`), and your description is reported as the preset **name**, so NVRs like Frigate show the labels you set instead of generic `preset_N` entries. Preset edits made in the preview-page PTZ settings modal persist across restarts. The **first preset doubles as the initial point** -- the motor daemon parks the camera at presets[0] on boot. `ptz_presets` CLI management still works (`-g`/`-a`/`-r`/`-o` reorder), and a pre-existing `/etc/ptz_presets.conf` is imported once, automatically.

## MQTT / Home Assistant

Enable PTZ buttons in HA:

```sh
jct /etc/thingino.json set ha.enable_ptz true
```

Commands: `cameras/<id>/ptz/{up,down,left,right,home}/set`

## Motor Configuration

PTZ motor configuration lives in `/etc/thingino.json` under the `motors` key. All motor settings -- GPIO pins, step modes, speed, range -- are unified into this single config file. There is no separate `motors.json`.

**Reload without restart** (`motors -R`): asks the running motor daemon to re-read `/etc/thingino.json` so config changes -- direction inversion, flips, sensitivity -- apply live. Prefer `motors -R` over `/etc/init.d/S59motor restart`: a full restart cycles the kernel module (`modprobe -r` / `modprobe`), which has caused kernel panics on live cameras.

VCM (Voice Coil Motor) focus control uses the `dw9714-ctrl` script.

### Motor Direction Inversion

Direction is determined by camera type:

- **SPI motor cameras** (Tapo C200 class): `invert_x` / `invert_y` are kernel module params in `/etc/thingino.json` and work as documented.
- **GPIO/TCU stepper cameras** (Cinnado D1 class): tilt direction is defined by the *pin order* of `gpio_tilt` in the camera profile -- `invert_y` is ignored entirely. If your tilt moves the wrong way, swap the two pins in `motors.gpio_tilt` instead.

```sh
jct /etc/thingino.json get motors.gpio_tilt
```

A flip set via `motors.invert_y` takes effect on reboot; the stop routine finds the real daemon PID and kills it before unloading the kernel module, so a restart does not leave PTZ dead, and a stop command during motion bails out before the daemon can enter the kernel wait that leaves `motors-daemon` stuck in D-state (worst case the move continues to its target or parks, and the camera stays responsive).

### Upside-Down Mounts

If the camera is mounted upside-down and you compensate with **Image Flip** (hflip/vflip) in the streamer, the motor directions follow the on-screen picture automatically. The streamer's `image.hflip` / `image.vflip` are combined with `invert_x` / `invert_y`, so a flipped mount needs no hand-tuned motor inversion:

```
net_x = invert_x XOR hflip
net_y = invert_y XOR vflip
```

Flip changes are picked up when the motor daemon reloads its config (`S59motor reload` / IPC 'R'), without a reboot.

---

<- [Previous: Home Automation and Integration](09-home-automation.md) | [Next: System Configuration](11-system-config.md) ->

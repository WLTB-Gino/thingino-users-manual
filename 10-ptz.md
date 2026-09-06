## Web UI

Hover over the live preview to access PTZ controls. Two control modes are available in **Settings -> Pan/Tilt Motors -> Behavior -> Preview PTZ controls**:

- **Step move** (default) -- Click or double-click directional buttons to move in steps
- **Continuous move** -- Press and hold directional buttons for smooth continuous movement

On ciao and master builds with TIMPS as the streamer, a low-latency **WebSocket control path** is used for preview PTZ (`BR2_PACKAGE_THINGINO_MOTORS_WS`, on by default when TIMPS is selected), with the CGI path kept as an automatic fallback. The preview also gains an on-screen **joystick** and motor sensitivity sliders in the motors settings, plus a motors daemon version badge.

Keyboard jog on the preview page uses **Shift + arrow keys** -- one discrete step per press, browser auto-repeat ignored. Plain arrow keys (and other modifiers) are left to the browser for normal page scrolling.

## Presets

The Web UI includes a **PTZ Presets** card on **Settings -> Pan/Tilt Motors**: move the camera to a position, give it a description, and save it. Presets are stored in the `motors.presets` array of `/etc/thingino.json` (each entry has a stable numeric `id`, a free-form `description`, and `x`/`y` coordinates) and can be edited and reordered in a **PTZ settings modal**. The id never changes on reorder or rename, and ONVIF clients see a derived machine name (`Preset_<id>`) so NVR labels can't get mangled. The **first preset doubles as the initial point** -- the motor daemon parks the camera at presets[0] on boot. `ptz_presets` CLI management still works (`-g`/`-a`/`-r`/`-o` reorder), and upgraded cameras import an existing `/etc/ptz_presets.conf` once, automatically.

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

**Ciao builds (Aug 24, 2026+) and current master:** the long-standing direction bugs are fixed, but the fix changed how inversion is expressed on GPIO/TCU cameras (commit `419eb8667`):

- **SPI motor cameras** (Tapo C200 class): `invert_x` / `invert_y` remain kernel module params in `/etc/thingino.json` and work as documented.
- **GPIO/TCU stepper cameras** (Cinnado D1 class): tilt direction is now defined by the *pin order* of `gpio_tilt` in the camera profile -- `invert_y` is ignored entirely. If your tilt moves the wrong way, swap the two pins in `motors.gpio_tilt` instead. Profiles that previously used `invert_y:true` as a wiring fixup were migrated in the same commit.

```sh
jct /etc/thingino.json get motors.gpio_tilt
```

The earlier double-inversion bug (init script re-applying the daemon's inversion, making the setting a no-op) and the position-counter overshoot are fixed on all motor types; the runtime `motors -I x/y` block for non-SPI cameras was removed from `S59motor`.

### Upside-Down Mounts

If the camera is mounted upside-down and you compensate with **Image Flip** (hflip/vflip) in the streamer, the motor directions now follow the on-screen picture automatically. The streamer's `image.hflip` / `image.vflip` are combined with `invert_x` / `invert_y`, so a flipped mount needs no hand-tuned motor inversion:

```
net_x = invert_x XOR hflip
net_y = invert_y XOR vflip
```

Flip changes are picked up when the motor daemon reloads its config (`S59motor reload` / IPC 'R'), without a reboot.

---

<- [Previous: Home Automation and Integration](09-home-automation.md) | [Next: System Configuration](11-system-config.md) ->

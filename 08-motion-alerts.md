## Motion Guard

Motion detection uses the SoC's hardware IVS (Intelligent Video System). Enable it from the Web UI under **Motion Guard**.

Motion is configured in `/etc/prudynt.json` under the `motion` section. Key settings:

- **Sensitivity** -- Motion detection sensitivity level
- **ROI (Region of Interest)** -- Define rectangular regions to monitor for motion
- **Cooldown time** -- Seconds to wait before allowing another motion trigger
- **Video length** -- Duration of recorded clips when motion is detected
- **Monitor stream** -- Which stream to monitor (0 = main, 1 = sub)

## Alert Methods

When motion is detected, Thingino can send alerts via:

| Method | Script | Description |
|--------|--------|-------------|
| MQTT | `send2mqtt` | Publish a message to your MQTT broker |
| Email | `send2email` | Send notification email |
| Telegram | `send2telegram` | Send message via Telegram bot |
| Webhook | `send2webhook` | HTTP callback to a custom endpoint |
| ntfy | `send2ntfy` | Push notifications via ntfy.sh |
| Gotify | `send2gotify` | Self-hosted push notifications |
| FTP | `send2ftp` | Upload snapshots/clips to an FTP server |
| Storage | `send2storage` | Save recordings to SD card or NFS |
| XMPP | `send2xmpp` | Send message via Jabber/XMPP |
| Speaker | `playonspeaker` | Play an audio alert through the camera's speaker |

Enable via the Web UI under **Tools** or through `jct /etc/prudynt.json`.

## send2 Toolkit Architecture (master)

On the master branch the send2 notification scripts live in a standalone `thingino-send2` package shared by all three streamers (Prudynt, Raptor, TIMPS), with per-streamer adapter helpers:

- Capture is split per streamer -- no runtime streamer branching, each streamer uses its own adapter (`prudynt-helpers` for Prudynt, snapshot helpers for Raptor/TIMPS)
- Storage and FTP extensions handle extensionless temporary files correctly
- Raptor ships a live motion->send2 bridge (`raptor-motion` + `S32raptor-motion`), so motion alerts now work with Raptor, not just Prudynt
- Settings live in `/etc/send2.json` as before

## Audio Alerts (Speaker)

Cameras with a built-in speaker can play audio alerts when motion is detected. Configure this from the Web UI under **Motion Guard**:

- **Speaker file** -- Audio file to play (must be Opus format on 8 MB flash cameras; MP3 requires 16 MB+ flash)
- **Volume** -- Speaker volume (0--120)
- **Gain** -- Audio gain (0--31)
- **Repeat** -- Number of times to play (0 = forever)

The speaker settings share a save button with motion detection settings in recent builds. Use the **Test** button to preview the sound without triggering motion.

---

<- [Previous: Night Vision and Lighting](07-night-vision.md) | [Next: Home Automation and Integration](09-home-automation.md) ->

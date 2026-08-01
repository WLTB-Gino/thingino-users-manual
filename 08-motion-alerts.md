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

Enable via the Web UI under **Tools** or through `jct /etc/prudynt.json`.

---

<- [Previous: Night Vision and Lighting](07-night-vision.md) | [Next: Home Automation and Integration](09-home-automation.md) ->

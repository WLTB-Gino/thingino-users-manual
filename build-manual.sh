#!/bin/bash
# Regenerate manual.md from the chapter files in this repo.
# Run from the repo root: ./build-manual.sh
cd "$(dirname "$0")" || exit 1
{
cat 01-overview.md
echo
cat 02-first-boot.md
echo
cat 03-web-ui.md
echo
cat 04-networking.md
echo
cat 05-streaming.md
echo
cat 06-storage.md
echo
cat 07-night-vision.md
echo
cat 08-motion-alerts.md
echo
cat 09-home-automation.md
echo
cat 10-ptz.md
echo
cat 11-system-config.md
echo
cat 12-firmware-updates.md
echo
cat 13-troubleshooting.md
echo
cat 14-glossary.md
} > manual.md
echo "done"

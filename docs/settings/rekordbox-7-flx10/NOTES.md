# Rekordbox 7 + DDJ-FLX10 (stretch)

Keep Rekordbox **closed** while proving Traktor + S8 + S88.

On the last laptop, Rekordbox captured Traktor MIDI and drove the wrong buttons. This Mac already has leftover maps. Do **not** enable them.

**In this repo:** [`files/`](files/) — leftover `*.midi.csv` maps only (a few dozen bytes). Evidence. **Do not enable.**

**Never copy here:** `master.db`, the rekordbox library, `rekordbox Aggregate Device` (leave it in Audio MIDI Setup).

## Leftover MIDI maps

`~/Library/Application Support/Pioneer/rekordbox6/MidiMappings/`

| File | First line (device tag) |
|------|-------------------------|
| `Traktor Kontrol S8.midi.csv` | `@file,1,Traktor Kontrol S8` |
| `Traktor Kontrol S8 Input.midi.csv` | (S8 input map) |
| `KOMPLETE KONTROL S88 MK2 Port 1.midi.csv` | `@file,1,KOMPLETE KONTROL S88 MK2 Port 1` |
| `KOMPLETE KONTROL S88 MK2 Port 2.midi.csv` | Port 2 / DIN |
| `Komplete Kontrol DAW - 1.midi.csv` | DAW port |

These are the smoking gun for “RB driving Traktor buttons.” Treat as evidence, not as a setup to restore.

## FLX10 vs this rig

- FLX10 may become macOS **default output** when plugged in. Leave it. Traktor stays on **Aggregate Device Maschine**.
- Do not fold FLX10 into the Traktor aggregate until S8 + KK/Maschine on Channel D stay trusted.
- Gemini’s old note (Traktor Master = FLX10 9–10) does **not** match the Intel screenshots and is not this Mac’s graph.

## When we get here

New notes only: isolate MIDI so Rekordbox cannot bind S8 or S88. Dual-software is phase 5, not the working 2ch commit.

## 11b — FLX10 → Maschine In 3 — **parked 2026-09-19**

Using `FLX10 + BlackHole 2ch` as the Rekordbox **device** silenced master, booth, and the Sony. David, 2026-09-23: that silence needed a reboot. It is not a ban on a digital feed. The aggregate was destroyed that day. Rekordbox is on **DDJ-FLX10** until a deliberate retry. Bridge stopped. 11a (16ch @ 48 kHz, 26/20) untouched.

**2026-09-23 target (TODO 40, not 11b).** Whole S8/Traktor mix on FLX10 **CH2 switch B**. **LINE** stays the analog tester. S8 master and booth jacks should sit idle. Room hub is the FLX10: Sony STR-AN1000 master, AudioQuest + sub controller → SVS sub, KRK Rokit 5 booth. Serials later.

B is the second USB port (PC-B). This Mac is on one port, so B is silent. Next try when David says go: second cable into the other FLX10 USB port, Rekordbox stays on the current device, bridge Traktor Record **7/8** into that second device’s channel-2 output at 44.1. Sony down. Move only CH2 to B.

PC MASTER OUT → `MASTER + BlackHole 2ch` lands on the master bus, not on the CH2 fader. Scripts remain (`flx10-2ch`, `flx10-bridge`). A retry of `flx10-2ch` as the Rekordbox device waits until David asks, with the Sony down, and a reboot if the receiver drops.

Do not add FLX10 to `Traktor S8 + BlackHole`. Do not edit `rekordbox Aggregate Device`. Leftover S8/S88 maps stay off.

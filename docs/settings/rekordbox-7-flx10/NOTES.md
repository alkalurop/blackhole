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

**2026-09-23 afternoon (TODO 40, not 11b).** LINE cannot be fed like S8 Channel D. Channel D is Traktor Live Input on BlackHole (aggregate In 10/11) with the TRAKTOR button. FLX10 LINE is the rear RCA, mixed in hardware. A/B play a deck from DJ software; Rekordbox has no Live Input. One `DDJ-FLX10` in CoreAudio is 10 in / 4 out at 44.1: master and phones. There is no channel-2 output to write. Those four outs skip the fader and can reach the Sony. Setting Utility “CH2 Control Tone DIGITAL” is mixer → computer. Working feed is the S8 RCA on LINE. No bridge was started. Detail: `ix` `docs/notes.md`.

PC MASTER OUT → `MASTER + BlackHole 2ch` lands on the master bus, not on the CH2 fader. Scripts remain (`flx10-2ch`, `flx10-bridge`). Do not point them at FLX10 Out 0/1. A retry of `flx10-2ch` as the Rekordbox device still waits until David asks, Sony down, reboot if the receiver drops. It does not create a CH2 input.

Do not add FLX10 to `Traktor S8 + BlackHole`. Do not edit `rekordbox Aggregate Device`. Leftover S8/S88 maps stay off.

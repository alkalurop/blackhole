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

Using `FLX10 + BlackHole 2ch` as the Rekordbox **device** broke FLX10 master / booth / receiver. That aggregate is **destroyed**. Rekordbox stays **DDJ-FLX10**. Bridge stopped. 11a (16ch @ 48 kHz, 26/20) untouched.

Next try, when David asks: native **DDJ-FLX10** + **PC MASTER OUT** → `MASTER + BlackHole 2ch` (never 16ch). Scripts remain (`flx10-2ch`, `flx10-bridge`).

Do not add FLX10 to `Traktor S8 + BlackHole`. Do not edit `rekordbox Aggregate Device`. Leftover S8/S88 maps stay off.

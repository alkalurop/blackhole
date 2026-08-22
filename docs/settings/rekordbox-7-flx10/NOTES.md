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

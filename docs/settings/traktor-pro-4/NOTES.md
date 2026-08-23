# Traktor Pro 4.5.1 + Kontrol S8

Working mixer settings for Channel D live input. Do not commit `Traktor Settings.tsi`.

**In this repo (download / restore):** [`files/Traktor-Settings-2026-08-22-working-2ch.tsi`](files/Traktor-Settings-2026-08-22-working-2ch.tsi) — 100 KB snapshot from disk after Channel D worked.

**Live on this Mac:** `~/Documents/Native Instruments/Traktor 4.5.1/Traktor Settings.tsi`

Quit Traktor before replacing that file. Never rewrite the TSI while the app is open. After restore, confirm Audio Device is still **Aggregate Device Maschine** (the TSI stores the name; the aggregate must exist first — `python3 scripts/rig.py aggregates --create`).

## Audio Setup

| Field | Working value |
|-------|----------------|
| Audio Device | **Aggregate Device Maschine (CoreAudio)** |
| Sample Rate | **48000** Hz |
| Buffer Size | **512** (27.3 ms overall on this Mac) |
| Phono / Line | “not supported” on the aggregate — ignore |
| Swap Channels | unused |
| Multi-Core Processing | on |

Do **not** select: `Traktor Kontrol S8` alone, `Traktor S8 + BlackHole` (16ch leftover), FLX10, BlackHole 2ch/16ch as Traktor’s device.

After a reboot, if Input D only lists Channel A L/R, Traktor is on a 2ch fallback (usually BlackHole 2ch). This Mac is set to **not** reopen apps at login. Launch Traktor yourself → Audio Device **Aggregate Device Maschine** → Input D **11 / 12**.

## Output Routing

| Field | Working value |
|-------|----------------|
| Mixing Mode | **Internal** |
| Output Master L / R | **1 Master Left / 2 Master Right** (S8) |
| Output Monitor L / R | **3 Monitor Left / 4 Monitor Right** (S8 phones) |
| Output Record | **- not connected -** |

Record on aggregate **5 / 6** (BlackHole) while Channel D is in the master = feedback. Mix Recorder **Internal** to a file is the 2ch resample. Live A→Maschine tap waits for 16ch.

## Input Routing

| Field | Working value |
|-------|----------------|
| Input Deck A / B / C | not connected |
| Input Deck D L / R | **11 / 12** (`Aggregate Device Maschine In 10` / `In 11` — 0-based names for BlackHole 2ch 1–2) |
| Input FX Send (Ext) | not connected |
| Input Aux | not connected |

Deck D header: **Live Input** (not Stem). Click the deck letter if it says Stem.

## S8 hardware

- Channel D **TRAKTOR** button on (live in, not a deck stem).
- Hear KK/Maschine only with the **Channel D** fader up. A/B/C down to prove it.
- S8 HID mapping in Controller Manager was **not** edited for this graph.

## Privacy

System Settings → Privacy & Security → **Microphone**: Traktor must be allowed, or Live In stays silent.

## Orange speaker in the header

Aggregates often stay orange. That is not “wrong device” by itself. Dark master meters with a playing deck = Output Master dropped or you are listening to the Mac/FLX10.

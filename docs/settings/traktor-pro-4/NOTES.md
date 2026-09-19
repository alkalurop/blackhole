# Traktor Pro 4.5.1 + Kontrol S8

Working mixer settings for Channel D live input. Do not commit `Traktor Settings.tsi`.

**Live (2026-09-19):** device **Traktor S8 + BlackHole (CoreAudio)**. 16ch Channel D proven (tone + A stem + S88 on D). On-disk TSI may still say **Aggregate Device Maschine** until Traktor quits — GUI is the source of truth while the app is open.

**2ch rollback (download / restore):** [`files/Traktor-Settings-2026-08-22-working-2ch.tsi`](files/Traktor-Settings-2026-08-22-working-2ch.tsi) and `~/Music/blackhole_2ch/`. After restore, Audio Device **Aggregate Device Maschine**. Aggregate must exist first — `python3 scripts/rig.py aggregates --create`.

**Live file:** `~/Documents/Native Instruments/Traktor 4.5.1/Traktor Settings.tsi`. Quit Traktor before replacing. Never rewrite the TSI while the app is open.

## Audio Setup

| Field | Working value |
|-------|----------------|
| Audio Device | **Traktor S8 + BlackHole (CoreAudio)** (16ch live). Rollback: **Aggregate Device Maschine**. |
| Sample Rate | **48000** Hz |
| Buffer Size | **512** (27.3 ms overall on this Mac) |
| Phono / Line | “not supported” on the aggregate — ignore |
| Swap Channels | unused |
| Multi-Core Processing | on |

Do **not** select: `Traktor Kontrol S8` alone, FLX10, or BlackHole 2ch/16ch as Traktor’s device (those have no S8 master outs).

After a reboot, if Input D only lists Channel A L/R, Traktor woke on a 2ch fallback. Launch Traktor yourself → Audio Device **Traktor S8 + BlackHole** → Input D **11 / 12**. Rollback device: **Aggregate Device Maschine**.

## Output Routing

| Field | Working value |
|-------|----------------|
| Mixing Mode | **Internal** |
| Output Master L / R | **1 Master Left / 2 Master Right** (S8) |
| Output Monitor L / R | **3 Monitor Left / 4 Monitor Right** (S8 phones) |
| Output Record | **7 / 8** = `Out 6` / `Out 7` (BH 3–4). Idle: **- not connected -**. Never **5 / 6** (`Out 4`/`Out 5` = D). Never **8 / 9** (split). |

Record on the first BlackHole pair (aggregate **5 / 6** = BH 1–2) while Channel D is in the master = feedback. 11a live tap is Record **7 / 8** (BH 3–4) with D fader **down** while sampling (Record is the Internal master mix, not a per-deck out). Mix Recorder **Internal** → file is the no-routing fallback. Do not switch Mixing Mode to External.

## Input Routing

| Field | Working value |
|-------|----------------|
| Input Deck A / B / C | not connected |
| Input Deck D L / R | **11 / 12** (0-based `In 10` / `In 11` — first BlackHole pair on the 16ch aggregate; same numbers as the 2ch night) |
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

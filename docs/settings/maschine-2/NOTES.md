# Maschine 2 + S88 Mk2

Same Channel D pipe as Komplete Kontrol. Last night this Mac had Maschine on **BlackHole 16ch** — that pair is **not** Deck D.

**In this repo:** [`files/`](files/) — `com.native-instruments.Maschine-2.plist` (audio/MIDI prefs). `MaschineCommon.plist` and `UserData.json` were empty/tiny on this Mac.

**Not copied (libraries):** `komplete.db3` (~27 MB), `autosave.mxprj`.

**Live:** `~/Library/Preferences/com.native-instruments.Maschine 2.plist`. Quit Maschine before replacing. Device must be **BlackHole 2ch**, not 16ch.

## Audio

| Field | Working value |
|-------|----------------|
| Device | **BlackHole 2ch** |
| Out 1 | **1 / 2** |
| Input on BlackHole | **Off** (loop / howl) |

Do not select Aggregate Device Maschine, Traktor Kontrol S8, or BlackHole 16ch.

## MIDI Input

| Device | Working |
|--------|---------|
| KOMPLETE KONTROL S88 MK2 **(Port 1)** | **On** |
| Port 2 | Off |
| Traktor Kontrol S8 | Off |
| FLX10 | Off |

Quit Komplete Kontrol so Maschine owns the S88.

## Resample from Traktor Channel A (2ch)

Do **not** set Traktor Output Record to aggregate 5/6 while Channel D is up.

- Safe: Traktor Mix Recorder **Internal** → file → drag into a Maschine pad → play S88 → D.
- Live tap without muting D wants **16ch** (future).

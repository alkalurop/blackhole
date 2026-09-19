# Maschine 2 + S88 Mk2

Same Channel D pipe as Komplete Kontrol. **Live (2026-09-19):** device **BlackHole 16ch**, Out 1 = 1/2 → Traktor D on `Traktor S8 + BlackHole` in 11–12. 2ch still works as rollback (`~/Music/blackhole_2ch/`). On-disk plist may still say 2ch until Maschine quits.

**In this repo:** [`files/`](files/) — `com.native-instruments.Maschine-2.plist` (audio/MIDI prefs). `MaschineCommon.plist` and `UserData.json` were empty/tiny on this Mac.

**Not copied (libraries):** `komplete.db3` (~27 MB), `autosave.mxprj`.

**Live:** `~/Library/Preferences/com.native-instruments.Maschine 2.plist`. Quit Maschine before replacing. Device must be **BlackHole 16ch** (rollback: **BlackHole 2ch**).

## Audio

| Field | Working value |
|-------|----------------|
| Device | **BlackHole 16ch** |
| Out 1 | **1 / 2** |
| Input on BlackHole | **Off** (loop / howl) |

Do not select Aggregate Device Maschine, Traktor Kontrol S8, or the 16ch aggregate as Maschine’s device (that is Intel-on-master). Rollback device: **BlackHole 2ch**.

## MIDI Input

| Device | Working |
|--------|---------|
| KOMPLETE KONTROL S88 MK2 **(Port 1)** | **On** |
| Port 2 | Off |
| Traktor Kontrol S8 | Off |
| FLX10 | Off |

Quit Komplete Kontrol so Maschine owns the S88.

## Resample from Traktor A / B / C (11a)

Do **not** set Traktor Output Record to the same pair that feeds Channel D (16ch aggregate **5 / 6** = BH 1–2).

- Live tap: Traktor Record **7 / 8** = `Out 6` / `Out 7`. Maschine In 2 = `In 2` / `In 3` (BH 3–4). In 1 and In 3+ disconnected.
- First sample (software, no Maschine controller): click an **empty** Sound (9+), not a named drum. Waveform button **left of the group name** (e.g. Drums) — swaps the piano roll for **Record**. SOURCE **Ext. Ster.**, INPUT **In 2**, MODE **Detect**, THRESHOLD **Off**, MONITOR **Off**. S8: A up, B/C down, **D down**. Start, wait a few bars, Stop. Then D up, click the Sound / play an S88 key. Do not use SOURCE Internal or INPUT In 1.
- File fallback: Mix Recorder **Internal** → file → drag into a pad.
- In 1 on BH 1–2 stays **off** (loop / howl).

## FLX10 tap (11b)

Device stays **BlackHole 16ch**. Do not switch to 2ch.

| Field | Value |
|-------|--------|
| In 3 L / R | `In 4` / `In 5` (BH 5–6) |
| Sampler INPUT | **In 3** |
| SOURCE / MONITOR | Ext. Ster. / **Off** |

Needs `python3 scripts/rig.py flx10-bridge` running. In 2 stays the Traktor A/B/C tap.

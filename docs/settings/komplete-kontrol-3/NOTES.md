# Komplete Kontrol 3.5.4 + S88 Mk2

Preferences that exist: **Audio, MIDI, General, Library, Plug-ins**. There is no Hardware page, no Light Guide toggle, no mouse piano.

**In this repo:** [`files/`](files/) — `Komplete-Kontrol-MK2-Settings.dat` (15 KB) and `com.native-instruments.Komplete-Kontrol.plist`.

**Live on this Mac:** `~/Library/Application Support/Native Instruments/Komplete Kontrol/` and `~/Library/Preferences/com.native-instruments.Komplete Kontrol.plist`. Quit KK before replacing. After restore, confirm Audio = **BlackHole 16ch** (rollback **BlackHole 2ch**) and MIDI Input **Port 1** only — the dump is a snapshot, the NOTES are the source of truth if they drift.

## Audio (Channel D)

| Field | Working value |
|-------|----------------|
| Driver | CoreAudio |
| Device | **BlackHole 16ch** (rollback: **BlackHole 2ch**) |
| Sample Rate | 48000 |
| Buffer Size | 512 |
| Out 1 L / R | **1** / **2** |
| Out 2 and below | **not connected** |

**Do not use (Intel-on-master, faders do nothing):**

- Device **Aggregate Device Maschine**
- Out 1 = Master L/R, Out 2 = Monitor L/R

That path is real and loud on S8 master. It is not Channel D.

## MIDI Input (silent piano fix)

Preferences → MIDI → **Input** (not Output):

| Device | Working |
|--------|---------|
| KOMPLETE KONTROL S88 MK2 **(Port 1)** | **On** — keybed |
| KOMPLETE KONTROL S88 MK2 **(Port 2)** | **Off** — rear 5-pin DIN |
| Traktor Kontrol S8 | Off |
| Traktor Kontrol S8 Input | Off |
| Komplete Kontrol DAW - 1 | Off |
| DDJ-FLX10 / anything Pioneer | Off |

Output: do not enable S8 or FLX10.

Takeover Mode: None. Arp Channel Pressure: Ignore (as last seen).

Header **88** = S88 claimed. Close Preferences before playing. Browser prehear (Battery ticks) is not a loaded piano — load until the computer name matches, then play.

## USB / power

- S88 **direct to the Mac** + wall wart.
- Firmware flash was **not** required. KK 3.5.4 already claimed the board.

## With Maschine

Quit KK. The S88 Mk2 talks to Maschine 2 without this app open. Both apps on BlackHole 2ch share one Channel D fader.

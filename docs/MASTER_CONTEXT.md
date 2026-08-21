# ALKALUROPS / DAVID — BlackHole + Controller Rig

## 1. Environment
- **User / Machine**: David / Mac (Apple Silicon), host `ix`
- **Shell**: Zsh
- **IDE**: Cursor
- **GitHub**: https://github.com/ixamal/blackhole (docs + routing notes; no audio)
- **Sibling library repo**: https://github.com/ixamal/music_migration (canned 2026-08-20)
- **Apps**: Traktor Pro 4.5.1 (`/Applications/Native Instruments/Traktor Pro 4/`), Rekordbox 7
- **Journal**: `docs/PROGRESS.md` + `git log`

---

## 2. Device map

| Role | Device | Status (2026-08-21) |
|------|--------|---------------------|
| Virtual audio | BlackHole (Existential Audio) | **Not installed** |
| Traktor primary | Native Instruments Kontrol **S88 MkII** | Not seen on USB/audio this session — plug in when we map |
| Traktor secondary / stems | Native Instruments Kontrol **S8** | Not seen this session. Rekordbox already has leftover MIDI maps named `Traktor Kontrol S8` |
| Rekordbox (stretch) | Pioneer / AlphaTheta **DDJ-FLX10** | **Connected**; currently macOS **default output** |
| Already present | `rekordbox Aggregate Device` | Exists in Audio MIDI Setup (FLX10-shaped: 10 in / 4 out) |
| Ignore for DJ I/O | Dell monitors, Wacom, Realtek USB mic, Mac speakers | Desktop, not the rig |

Library paths stay in the music_migration repo. This repo does not move audio.

---

## 3. Phases

1. **BlackHole** — install (likely 16ch for two apps), create a documented aggregate if needed, prove loopback with a test tone. Keep FLX10 from remaining the system default while Traktor is the focus.
2. **S88 MkII + Traktor only** — one controller, one app. Confirm MIDI in/out, decks, mixer, no stray bindings.
3. **Add S8** — stems / secondary surface. Must not steal S88 channels or MIDI ports.
4. **Stretch: Rekordbox + FLX10** — last laptop: Rekordbox drove Traktor MIDI buttons. Isolate MIDI (disable RB mappings for S8/S88, no MIDI clock/through unless explicit). Only after 1–3 are trusted.

---

## 4. Known MIDI conflict (stretch)

Rekordbox 7 already has mappings on this Mac:

- `~/Library/Application Support/Pioneer/rekordbox6/MidiMappings/Traktor Kontrol S8.midi.csv`
- `~/Library/Application Support/Pioneer/rekordbox6/MidiMappings/Traktor Kontrol S8 Input.midi.csv`

Treat those as the smoking gun for “RB driving Traktor buttons.” Do not enable them while proving Traktor + NI hardware.

---

## 5. Safety
- Change one layer at a time (install → Traktor audio → one controller → second controller → second app).
- Screenshot / note Audio MIDI Setup before aggregates.
- Quit Traktor and Rekordbox before rewriting their MIDI/audio prefs.
- Never commit `.tsi`, NML, `master.db`, or audio.

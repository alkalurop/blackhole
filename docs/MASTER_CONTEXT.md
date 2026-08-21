# ALKALUROPS / DAVID — BlackHole + Controller Rig

## 1. Environment
- **User / Machine**: David / MacBook Pro 16-inch (M5 Max, 64 GB), host `ix`
- **OS**: macOS Tahoe 26.5.1
- **Shell**: Zsh
- **IDE**: Cursor
- **GitHub**: https://github.com/ixamal/blackhole (docs + routing notes; no audio)
- **Sibling library repo**: https://github.com/ixamal/music_migration (canned 2026-08-20)
- **Apps**: Traktor Pro 4.5.1 (`/Applications/Native Instruments/Traktor Pro 4/`), Maschine, Komplete / Komplete Kontrol, Rekordbox 7
- **Journal**: `docs/PROGRESS.md` + `git log`

---

## 2. Device map

| Role | Device | Status (2026-08-21, aggregate up) |
|------|--------|-----------------------------------|
| Traktor audio device | **Traktor S8 + BlackHole** | **Created** — 26 in / 20 out @ 48 kHz; UID `com.ixamal.traktor-s8-blackhole`; clock = S8; drift on BlackHole. **Not** the Mac default. |
| Virtual audio | **BlackHole 16ch** v0.7.1 | Installed. Subdevice of the aggregate (channels after S8). |
| Traktor mixer / performance | Native Instruments Kontrol **S8** | USB + audio; aggregate clock master. Channel **D** = live input from BlackHole. |
| Keyboard → NI production | Native Instruments Kontrol **S88 MkII** | USB as `KOMPLETE KONTROL S88 MK2`; not an audio device. |
| Rekordbox (stretch) | Pioneer / AlphaTheta **DDJ-FLX10** | USB active @ 44.1 kHz. **Mac default output** (speaker icon). Ignore for Traktor. |
| Leave alone | `rekordbox Aggregate Device` | Still present. **Do not edit.** |
| Mac defaults (not the rig) | AirPods / speakers / built-in mic | May hop. Do **not** set the Traktor aggregate as system output. |

Library paths stay in the music_migration repo. This repo does not move audio.

---

## 3. Intended audio graph (this session)

```
S88 MkII  --native USB-->  Komplete Kontrol
                              |  Out 1 → BlackHole 16ch 1–2
                         Traktor S8 + BlackHole  @ 48 kHz
                              |  in 11–12 = BH 1–2
                         Traktor Channel D  →  S8 Channel D
```

Prove **Komplete Kontrol + S88 → S8 D** first. Maschine later (same BlackHole 1–2, or 3–4 if they should stay separate). Do not enable S8 or FLX10 in KK MIDI.

**Old Intel graph (Gemini, known-good — do not rebuild FLX10 into the aggregate until S8 D is proven):** BlackHole **2ch** + S8 + FLX10, clock S8, KK → BlackHole 2ch, Traktor Input D = BlackHole, Monitor = S8 3–4, Master = FLX10 9–10, **Microphone permission** for Traktor + KK, S8 Channel D **TRAKTOR** button on.

**This Mac:** Microphone permission unblocked Live In. KK must output to **BlackHole 16ch 1–2**, not the aggregate (aggregate 1–4 is S8 master — browse preview then ignores Traktor faders). Piano = load the instrument and play keys; Battery menu ticks are prehear, not the same path.

**Aggregate channel map** (S8 first, then BlackHole):

| Aggregate | Maps to |
|-----------|---------|
| In 1–10 | S8 physical inputs |
| In 11–12 | BlackHole 1–2 → Maschine → Traktor Channel D |
| In 13–14 | BlackHole 3–4 → Komplete (also to D, or mute independently) |
| In 15–26 | BlackHole 5–16 spare |
| Out 1–4 | S8 hardware outputs (keep Traktor master/phones here) |
| Out 5–20 | BlackHole — do not send Traktor master here |

- Clock source = **Traktor Kontrol S8**. Drift correction = **BlackHole 16ch only**.
- Create/destroy: `swift scripts/traktor_s8_blackhole_aggregate.swift` / `--destroy`. Never destroy `rekordbox Aggregate Device`.
- Rollback for Audio MIDI Setup / defaults is in `PROGRESS.md`.

---

## 4. Phases

1. **BlackHole** — **16ch + aggregate confirmed** in Audio MIDI Setup and Traktor.
2. **S8 + Traktor** — device and Channel D in 11–12 confirmed. Prove the live path next.
3. **S88 MkII + Maschine / Komplete** — output those apps to BlackHole 16ch 1–2; S88 MIDI stays there; audio hits S8 Channel D via Traktor. Must not steal S8 MIDI.
4. **Stretch: Rekordbox + FLX10** — last laptop: Rekordbox drove Traktor MIDI buttons. Isolate MIDI. Only after 1–3 are trusted.

---

## 5. Known MIDI conflict (stretch)

Rekordbox 7 already has mappings on this Mac:

- `~/Library/Application Support/Pioneer/rekordbox6/MidiMappings/Traktor Kontrol S8.midi.csv`
- `~/Library/Application Support/Pioneer/rekordbox6/MidiMappings/Traktor Kontrol S8 Input.midi.csv`

Treat those as the smoking gun for “RB driving Traktor buttons.” Do not enable them while proving Traktor + NI hardware.

---

## 6. Safety
- Change one layer at a time (install → Traktor audio → one controller → second controller → second app).
- Screenshot / note Audio MIDI Setup before aggregates.
- Quit Traktor and Rekordbox before rewriting their MIDI/audio prefs.
- Never commit `.tsi`, NML, `master.db`, or audio.

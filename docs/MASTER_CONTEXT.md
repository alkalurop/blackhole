# ALKALUROPS / DAVID — BlackHole + Controller Rig

## 1. Environment
- **User / Machine**: David / MacBook Pro 16-inch (M5 Max, 64 GB), host `ix`
- **OS**: macOS Tahoe 26.5.1
- **Shell**: Zsh
- **IDE**: Cursor
- **GitHub**: https://github.com/ixamal/blackhole (docs + routing notes; no audio)
- **Sibling library repo**: https://github.com/ixamal/music_migration (canned 2026-08-20)
- **Apps**: Traktor Pro 4.5.1 (`/Applications/Native Instruments/Traktor Pro 4/`), Maschine, Komplete / Komplete Kontrol, Rekordbox 7
- **How-to**: `docs/RUNBOOK.md`. Per-app notes: `docs/settings/`. Tools: `python3 scripts/rig.py`
- **2ch archive (2026-09-19, off git)**: `~/Music/blackhole_2ch/`
- **Journal**: `docs/PROGRESS.md` + `git log`

---

## 2. Device map

**Working 16ch Channel D** (2026-09-19). Same fader isolation as the 2ch night. 2ch aggregates stay as rollback. Full recreate: `docs/RUNBOOK.md`.

| Role | Device | Status (2026-09-19) |
|------|--------|-----------------------------------|
| Traktor audio device | **Traktor S8 + BlackHole** | **Working** — 26 in / 20 out @ 48 kHz; UID `com.ixamal.traktor-s8-blackhole`; clock = S8; drift on BH 16ch. Master 1–2 / Monitor 3–4 / Deck D = 11–12. **Not** the Mac default. |
| Keyboard / KK audio | **BlackHole 16ch** | Out 1 = BH 1–2; MIDI Input Port 1; Traktor Channel D. |
| Maschine | **BlackHole 16ch** | Same first pair as KK (one D fader). Input on BH **off**. |
| Rollback aggregate | **Aggregate Device Maschine** | Still present — 12/8; UID `com.ixamal.aggregate-maschine`. Switch Traktor here if 16ch fails. |
| Other 2ch aggregate | **Aggregate Device s88 MK2** | Still present — 12/6; UID `com.ixamal.aggregate-s88-mk2`. Spare. |
| Virtual audio | BlackHole **2ch** + **16ch** v0.7.1 | Both installed. Live graph uses 16ch. |
| Traktor mixer | Native Instruments Kontrol **S8** | USB + audio; clock master. |
| Keyboard → NI | Native Instruments Kontrol **S88 MkII** | USB as `KOMPLETE KONTROL S88 MK2`; not an audio device. |
| Rekordbox (stretch) | Pioneer / AlphaTheta **DDJ-FLX10** | Ignore for Traktor. |
| Leave alone | `rekordbox Aggregate Device` | Still present. **Do not edit.** |
| Mac defaults (not the rig) | AirPods / speakers / built-in mic | May hop. Do **not** set the Traktor aggregate as system output. |

Library paths stay in the music_migration repo. This repo does not move audio.

---

## 3. Intended audio graph (Intel copy)

```
S88 MkII  --USB MIDI Port 1-->  Komplete Kontrol
                              |  device = BlackHole 2ch
                              |  Out 1 = BH 1–2
                         Aggregate Device Maschine in 11–12
                         Traktor Channel D Live Input  →  S8 Channel D
```

Do not put KK back on **Aggregate Device Maschine** Out 1 = Master — that bypasses every fader.

Do not enable S8 or FLX10 in KK MIDI.

**Intel known-good (screenshots 2026-08-22, S8 unplugged in AMS so it shows 0/0):**

| Layer | Old Mac |
|-------|---------|
| Virtual cable | **BlackHole 2ch** @ 48 kHz |
| Traktor device | **Aggregate Device Maschine** = S8 + BlackHole 2ch + Mac speakers. Clock **BlackHole 2ch** in the shots (S8 offline); use **S8** as clock when it is plugged in. Drift on BH and speakers. |
| Other aggregate | **Aggregate Device s88 MK2** = S8 + BlackHole 2ch (2/2 when S8 dark) |
| rekordbox aggregate | FLX10 + External Headphones — leave it |
| Traktor I/O | Internal. Master **1–2** (S8 Master), Monitor **3–4** (S8 phones). Deck D = Live Input |
| Maschine | Device **BlackHole 2ch**. In 1 = BH L/R (loopback) |
| Komplete Kontrol | Device **Aggregate Device Maschine**. Out 1 = **Master L/R**, Out 2 = **Monitor L/R** |

That KK path is **not** Channel D. KK sums onto S8 master/phones at Core Audio. Traktor faders do not mute it. Maschine → BlackHole → aggregate inputs is the Live Input D path. Gemini’s “Master = FLX10 9–10” does **not** match these shots.

**This Mac (`ix`, 2026-09-19):** Traktor on `Traktor S8 + BlackHole` (16ch). KK / Maschine on **BlackHole 16ch** pair 1–2 → aggregate in 11–12 → Channel D. Intel 2ch aggregates stay for rollback. Do not put KK back on aggregate Master 1–2.

**Aggregate Device Maschine channel map** (S8 first, then BlackHole 2ch, then speakers):

| Aggregate | Maps to |
|-----------|---------|
| In 1–10 | S8 physical inputs |
| In 11–12 | BlackHole 2ch 1–2 → Maschine → Traktor Channel D |
| Out 1–4 | S8 hardware (Traktor + KK Master / Monitor) |
| Out 5–6 | BlackHole 2ch |
| Out 7–8 | MacBook Pro Speakers |

- Clock source = **Traktor Kontrol S8**. Drift = **BlackHole 2ch** and **speakers**.
- Create/destroy Intel pair: `swift scripts/intel_aggregates.swift` / `--destroy`.
- Last night’s 16ch device: `swift scripts/traktor_s8_blackhole_aggregate.swift --destroy` only after Intel is trusted.
- Never destroy `rekordbox Aggregate Device`.
- Rollback for Audio MIDI Setup / defaults is in `PROGRESS.md`.

---

## 4. Phases

1. **BlackHole 2ch + Intel aggregates** — **created**.
2. **S8 + Traktor** — **Aggregate Device Maschine**, Master 1–2 / Monitor 3–4, Deck D = 11–12 Live Input.
3. **S88 + KK** — MIDI Input Port 1; audio **BlackHole 2ch** → Channel D. **Working.**
4. **Maschine** — same 2ch pair; quit KK so the S88 is free. **Working enough to pause.**
5. **16ch Channel D + 11a** — **proven 2026-09-19.** Internal Record **7/8** → Maschine In 2 → S88 → D. Link is clock.
6. **FLX10 → Maschine (11b)** — **parked.** Native `DDJ-FLX10` required. Next try: PC MASTER OUT + BlackHole 2ch, never 16ch. Leftover S8/S88 maps unused.

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
- Never commit NML, `master.db`, or audio. Dated routing snapshots may live only under `docs/settings/*/files/`.

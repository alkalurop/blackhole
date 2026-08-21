# Progress Log — blackhole

Chronological notes for the performance rig. Canonical device map lives in [`MASTER_CONTEXT.md`](MASTER_CONTEXT.md).

This file + `git log` is the project journal.

---

## 2026-08-21 — Repo bootstrap

Created `~/github/ixamal/blackhole` (GitHub `ixamal/blackhole`). Nested with `music_migration` under `~/github/ixamal/`. `~/github/alkalurop/` remains empty for org repos.

Inventory on this Mac (no settings changed):

- **BlackHole**: not installed (no Existential Audio HAL plugin; only `ParrotAudioPlugin.driver`)
- **Traktor Pro 4**: installed
- **Rekordbox 7**: installed
- **DDJ-FLX10**: USB connected; currently macOS default output; `rekordbox Aggregate Device` already exists
- **S88 MkII / S8**: not visible on USB/audio this session
- Rekordbox leftover MIDI maps for **Traktor Kontrol S8** — relevant to the old MIDI-bleed bug

Plan: BlackHole → Traktor + S88 MkII → add S8 → stretch FLX10 / Rekordbox without MIDI capture.

Library work stays in [ixamal/music_migration](https://github.com/ixamal/music_migration).

---

## 2026-08-21 — Channel D graph; pick 16ch

Music apps closed. David is wiring **S8 + Traktor 4** as the mixer, **S88 MkII** as the keyboard into Maschine/Komplete, and wants those apps’ audio on **S8 Channel D**.

**BlackHole version: 16ch** (not 2ch, not 64ch). Channel D is still one stereo strip; 16ch keeps Maschine and Komplete on separate pairs (1–2 vs 3–4) with headroom. 64ch only bloats Traktor’s I/O list.

Not installed yet. Do not change Audio MIDI Setup / Traktor I/O until the pkg is down and a rollback note is here.

---

## 2026-08-21 — BlackHole 16ch installed (verified)

David ran the Existential Audio installer. No Audio MIDI Setup / Traktor / Rekordbox prefs were changed this step.

**Verified**

- Driver: `/Library/Audio/Plug-Ins/HAL/BlackHole16ch.driver` (CFBundle `audio.existential.BlackHole16ch`, version **0.7.1**)
- Core Audio device **BlackHole 16ch**: 16 in / 16 out, 48 kHz, manufacturer Existential Audio Inc., transport Virtual
- No 2ch or 64ch plugin present

**USB this session**

- `Traktor Kontrol S8` — audio device 10 in / 4 out @ 48 kHz
- `KOMPLETE KONTROL S88 MK2` — on USB, **not** listed as an audio device (expected for this graph)
- `DDJ-FLX10` — still macOS default output **and** default system output @ 44.1 kHz

**Rollback snapshot (Audio MIDI Setup / defaults — restore to this if we break something)**

| Setting | Current (leave it) |
|---------|--------------------|
| Default output | DDJ-FLX10 |
| Default system output | DDJ-FLX10 |
| Default input | MacBook Pro Microphone |
| Existing aggregate | `rekordbox Aggregate Device` = FLX10 (master) + David’s AirPods Pro. **Do not edit or delete.** |
| S8 sample rate | 48 kHz |
| BlackHole sample rate | 48 kHz |

**Next (not done):** prove BlackHole loopback, then create a **new** aggregate `Traktor S8 + BlackHole` (clock = S8 @ 48 kHz, drift on BlackHole). Do not make BlackHole or that aggregate the Mac’s default output. Traktor Channel D mapping comes after the aggregate exists.

---

## 2026-08-21 — Aggregate `Traktor S8 + BlackHole` created

Music apps still closed. Created a **new** public aggregate via `scripts/traktor_s8_blackhole_aggregate.swift`. Did not edit `rekordbox Aggregate Device`. Did not set the new device as macOS default.

**Device**

- Name: `Traktor S8 + BlackHole`
- UID: `com.ixamal.traktor-s8-blackhole`
- 26 in / 20 out @ 48 kHz (S8 10/4 + BlackHole 16/16)
- Clock / master: Traktor Kontrol S8 (`AppleUSBAudioEngine:Native Instruments:Traktor Kontrol S8:33CEB9D1:1,2`)
- Drift correction: BlackHole 16ch only (`BlackHole16ch_UID`)

**Channel map (S8 first)**

- In 11–12 = BlackHole 1–2 (Maschine → Traktor Channel D)
- In 13–14 = BlackHole 3–4 (Komplete)
- Out 1–4 = S8 mixer (keep Traktor master here)

**Rollback**

- Destroy only this aggregate: `swift scripts/traktor_s8_blackhole_aggregate.swift --destroy`
- Do **not** delete `rekordbox Aggregate Device`
- Mac default was **not** pointed at the aggregate. At create time it was MacBook Pro Speakers; AirPods Pro later became default on their own. Leave whatever the Mac is using.

**Also this session:** DDJ-FLX10 is unplugged (was default earlier). S88 MkII still USB-only.

**Next:** In Audio MIDI Setup confirm clock = S8 and drift only on BlackHole. Then Traktor audio device = this aggregate; Channel D live in = aggregate 11–12. Do not make this the Mac’s default output.

---

## 2026-08-21 — Traktor audio → aggregate, Channel D = BH 1–2

FLX10 is USB-active again @ 44.1 kHz. Mac default is still AirPods. Neither is Traktor’s device.

**Rollback:** copy this file back over `Traktor Settings.tsi` (Traktor must be quit first):

`~/Documents/Native Instruments/Traktor 4.5.1/Backup/Settings/settings_2026y08m21d_00h45m39s_pre_blackhole.tsi`

**Patched (Traktor closed, then launched):**

| Pref | Value |
|------|--------|
| Audio Device | `Traktor S8 + BlackHole` |
| Sample rate | 48 kHz |
| Output Master | 1–2 (S8) |
| Output Monitor (phones) | 3–4 (S8) |
| Input Deck D | 11–12 (BlackHole 1–2; 0-indexed 10/11) |
| Deck D flavor | Live Input (factory enum `2`) |

S8 HID mapping in `DeviceIO.Config.Controller` was not touched. Rekordbox was not opened. Aggregate is still not the Mac default.

**Confirm in Traktor:** Preferences → Audio Setup → device is **Traktor S8 + BlackHole** (not `Traktor Kontrol S8`, not FLX10). Input Routing → Input Deck D meters move when BlackHole 1–2 has signal. Deck D header says **Live Input**; if it says Stem, click the deck letter and pick Live Input.

---

## 2026-08-21 — Screenshots: routing is correct

David confirmed in the GUIs:

- Audio MIDI Setup: `Traktor S8 + BlackHole`, clock = S8, 48 kHz, drift on BlackHole only. In 1–10 S8, 11–26 BlackHole. Out 1–4 S8 master/monitor.
- Traktor Audio Setup: device `Traktor S8 + BlackHole (CoreAudio)`, 48 kHz, buffer 512.
- Input Routing Deck D = **11 / 12** (`In 10` / `In 11` are 0-based names for BlackHole 1–2). That is the intended pair.
- FLX10 is macOS default output. Leave it. Do not select FLX10 in Traktor.

**Next:** Maschine + Komplete output to **BlackHole 16ch 1–2**. S88 MkII stays MIDI into those apps. Prove: play a note → Deck D input meters move → S8 Channel D fader hears it. Do not open Rekordbox.

---

## 2026-08-21 — No sound: faders down + listen on S8

David hears nothing. Routing is still right. Causes in the screenshots:

- Traktor mixer: **all four channel faders at zero** (Deck A is playing; master meters dark). Raise A to prove Traktor→S8. Raise D for Maschine.
- Listen on the **S8** (phones or master). Traktor is not going to FLX10 / Mac speakers.
- Maschine Audio device = BlackHole 16ch @ 48 kHz: correct. He is on **Routings → Input**. Need **Output**: Maschine Out 1 → BlackHole 1–2. Disconnect Maschine In from BlackHole 1–2 (loop).
- MIDI: leave FLX10 and S8 unchecked. `Komplete Kontrol DAW - 1` is enough if KK is running; otherwise enable `KOMPLETE KONTROL S88 MK2 (Port 1)` only.

---

## 2026-08-21 — KK first: S88 → BlackHole → S8 D

Pause Maschine. KK Audio is already correct: device **BlackHole 16ch**, Out 1 L/R = BH 0/1 (pair 1–2). S88 is claimed (header **88**). KK MIDI Output checkboxes all empty — **leave them**. S88 talks to KK over NIHIA, not those ports. Checking S8 or FLX10 there would steal MIDI.

Hear it: load a preset, play S88, watch Traktor Input Deck D meters, raise **Channel D** on the S8, listen on S8 phones/master.

---

## 2026-08-21 — Still silent; orange speaker + dead master meter

Deck A playing, Channel A fader up, **master meters dark**, header **speaker orange**. NI: orange = Traktor does not see a dedicated interface (aggregates often stay orange). Dark master = mix bus empty or Output Master unassigned in the live session.

Do not change MIDI. Open **Preferences → Output Routing**: Mixing Mode **Internal**, Output Master **1/2** (S8 Master L/R), Output Monitor **3/4** (S8 phones). Unassign Channel A from the crossfader. Headphone MIX fully to **Master**, phones in the **S8**. TSI on disk already has those routes; the running app may have dropped them.

---

## 2026-08-21 — D cue silent (live in not arriving)

Output Routing is correct per David. **Cue D is empty** — that is the input path, not Master/Monitor. KK is on standalone **BlackHole 16ch** 1–2 while Traktor has the aggregate open; those BlackHole inputs often stay silent inside the aggregate. Next: confirm Input Routing Deck D meters while holding a key. If they stay dead, point KK at **Traktor S8 + BlackHole** and Out 1 = aggregate **5 / 6** (first BlackHole pair). Never 1–4 (those are S8 master). Cue A on the playing track to prove phones.

---

## 2026-08-21 — Old Intel Gemini notes vs this Mac

David’s working Intel setup: BlackHole **2ch**, aggregate S8 + FLX10 + BH, KK → BH 2ch, Traktor D = BH, Monitor S8 3–4, Master FLX10 9–10, **Microphone privacy ON** for Traktor + KK, S8 Channel D **TRAKTOR** button lit.

That matches silent **Cue D** here: Live In is an input; macOS blocks it without Microphone access. Also the S8 D TRAKTOR button. Do **not** fold FLX10 into this aggregate until D is proven on the S8. 16ch can stay; 2ch is optional simplification later.

---

## 2026-08-21 — KK prehear on all S8 channels

Mic permission helped. Battery menu ticks are KK **browser prehear** hitting S8 master (KK using the aggregate, outs 1–2), so Traktor faders do nothing. Put KK device back to **BlackHole 16ch**, Out 1 = 1–2. Then only Deck D (11–12) should hear it. Piano: fully load, play keys — many pianos have no browse prehear.

---

## 2026-08-21 — S88 browse vs load (Gentleman stuck)

Channel D path is working for Battery-style **prehear**. Header showed **In The Face** while the slot was still **The Gentleman** — S88 encoder was highlighting, not loading. Push the encoder to load, wait for the GUI to match, then exit Browse so keys play. Pianos often have no prehear tick.

---

## 2026-08-21 — Restarted Komplete Kontrol

Quit and relaunched KK; Traktor/aggregate left running. S88 USB replug only if the header **88** does not return. Then encoder **push** to load so the GUI matches the preset name.

---

## 2026-08-21 — Libs not corrupt; load vs prehear

Gentleman samples are intact (`/Users/Shared/The Gentleman Library` 3.4 GB, `.nkx` ~3.2 GB). ~35 NI products on disk. Hit-and-miss is browse **prehear** (Battery ticks) vs loaded Kontakt not getting notes or not outputting to KK Out 1. Do not repair/reinstall libraries yet. Test: Gentleman GUI up, play keys AND click Kontakt’s on-screen keyboard; if only prehear hits D, it is MIDI/browse, not disk.

---

## 2026-08-21 — S88 Light Guide

Key LEDs should flash on **note-on** once KK has the instance (header **88**, browser closed). Browse/select does not light the keybed. If keys stay dark, KK is not getting MIDI (S88 in MIDI mode, or another app). Rekordbox still has leftover S88 maps on disk; leave RB closed.

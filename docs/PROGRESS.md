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

---

## 2026-08-22 — Intel screenshots (known-good)

David pulled AMS + Traktor + Maschine + KK from the old Mac. S8 was unplugged in AMS (subdevice 0/0).

- **BlackHole 2ch**, not 16ch.
- Two user aggregates: **Aggregate Device Maschine** (S8 + BH 2ch + Mac speakers, 2 in / 4 out with S8 dark) and **Aggregate Device s88 MK2** (S8 + BH 2ch).
- Traktor audio device = **Aggregate Device Maschine**. Internal. Master 1–2 / Monitor 3–4 (S8 names). Deck D Live Input.
- Maschine device = **BlackHole 2ch**.
- KK device = **Aggregate Device Maschine**, Out 1 = Master L/R, Out 2 = Monitor L/R — **straight to S8 outs**, not through Channel D.
- rekordbox aggregate still FLX10 + headphones, offline.

Gemini’s FLX10-as-master note is wrong vs these shots. Next: pick whether `ix` copies KK-on-S8-master (old hear-it-now) or keeps KK → BlackHole → Traktor D (last night’s ask).

---

## 2026-08-22 — Start from Intel (16ch path abandoned)

Last night’s 16ch Channel D path never fully worked on `ix`. The Intel Mac did. Copy that graph.

**Rollback (leave these alone)**

- `rekordbox Aggregate Device` — do not edit
- `Traktor S8 + BlackHole` (16ch) — leftover; do not select; destroy later if Intel is trusted (`swift scripts/traktor_s8_blackhole_aggregate.swift --destroy`)
- Traktor TSI rollback still: `~/Documents/Native Instruments/Traktor 4.5.1/Backup/Settings/settings_2026y08m21d_00h45m39s_pre_blackhole.tsi`
- Mac default I/O — do not point at the new aggregates

**Done after reboot**

- **BlackHole 2ch** v0.7.1 present: 2 in / 2 out @ 48 kHz.
- `swift scripts/intel_aggregates.swift` created both devices. Mac defaults stayed Speakers / Mic.
  - **Aggregate Device Maschine** — 12 in / 8 out; UID `com.ixamal.aggregate-maschine`; clock S8; drift on BH 2ch + MacBook Pro Speakers
  - **Aggregate Device s88 MK2** — 12 in / 6 out; UID `com.ixamal.aggregate-s88-mk2`
- Destroy those two only: `swift scripts/intel_aggregates.swift --destroy`

**Next (GUIs — do not rewrite TSI while Traktor is open)**

1. Traktor → Preferences → Audio Setup → device **Aggregate Device Maschine** (not last night’s `Traktor S8 + BlackHole`, not the S8 alone). Keep Internal, Master **1–2**, Monitor **3–4**.
2. Komplete Kontrol → Audio → same **Aggregate Device Maschine**, Out 1 = **Master L/R**, Out 2 = **Monitor L/R**.
3. Load a preset, play the S88, listen on S8 master/phones. KK will ignore Channel D faders (Intel behavior).
4. Maschine later: device **BlackHole 2ch**.

**Do not** fold FLX10 into these aggregates. Keep Rekordbox closed. Leave S8/FLX10 unchecked in KK MIDI.

---

## 2026-08-22 — Intel graph selected; piano / half KK still silent

David’s GUIs match Intel:

- Traktor device **Aggregate Device Maschine**, 48 kHz, Internal, Master 1–2, Monitor 3–4
- Deck D live in still 11–12 (BH 2ch) — unused until Maschine
- KK device same aggregate, Out 1 = Master, Out 2 = Monitor
- S8 + S88 USB present. Rekordbox not running.

He hears some KK on **S8 master only**, and most pianos / about half of KK stay silent. That is not a wrong device. KK on the aggregate **is** S8 master/phones; Traktor faders cannot mute it.

Two leftover causes from last night:

1. KK **Out 3+** auto-mapped to aggregate 5–8 (BlackHole / Mac speakers). Instruments that use those outs never hit S8 master. Set Out 3 and below to unused.
2. Battery **browse prehear** vs piano **load**. Scroll ticks are not a loaded instrument. Push the S88 encoder, wait until the computer name matches, exit Browse, then play keys **and** click Kontakt’s on-screen keyboard. If the GUI keys speak and the S88 does not, it is MIDI (header should show **88**; Light Guide should flash).

---

## 2026-08-22 — Same silence; KK log is browse + prefs dialog

David disconnected KK Out 2+ (only Out 1 → S8 Master). Gentleman **Dolled Up** and Vintage Organs **Transistor Compact** are on screen. Header **88**. Audio path is the Intel one.

`~/Library/Logs/Native Instruments/Komplete Kontrol.log` after reboot: S88 claimed (`Device connected`, `Instance has focus`). Kontakt 8 loaded once for Dolled Up. After that the log is almost only `Saying "Preset…"` / `Saying "Product…"` (browser scroll) and `Saying "A dialog box has opened in the software"` (Preferences). Hardware never left browse/dialog, so keys will not play the loaded piano. Same as last night; changing the aggregate cannot fix it.

Later the log did reach Gentleman knobs (`Saying "Anatomy, Dynamic"`, `Saying "Reso Vol"`), then Preferences opened again. David still reports silence. Aggregate is not hogged. Played a 440 Hz 1.5s tone on **Aggregate Device Maschine** outs 1–2 via `swift scripts/tone_aggregate.swift` (does not change defaults). **David heard the beep on S8 master** — aggregate → S8 is good. Remaining: KK/Kontakt output and S88 MIDI.

KK standalone has **no mouse piano**. David cannot click keys in the Gentleman NKS view. Sent middle C to `Komplete Kontrol DAW - 1` via `scripts/midi_note.swift` (standalone KK may ignore that port). Next: Light Guide on S88 with prefs/browser closed; optional Kontakt 8 standalone on-screen keyboard on the same aggregate.

---

## 2026-08-22 — S88 USB path (not direct)

`ioreg` : S88 is **USB 2.0 High Speed** behind a USB 2 hub (`@02143000`), on the same controller as the S8 (`@02110000`), a Thunderbolt 4 dock, and the Wacom. It is not on a Mac USB-C port. Direct + the S88 wall wart is worth a reliability pass; it will not make MIDI “faster,” and it will not fix silent Kontakt if the header already shows **88**.

David moved S88 **direct to the Mac**. Now `KOMPLETE KONTROL S88 MK2@02100000` sits on `AppleT8142USBXHCI@02000000` with no hub. S8 stayed on the dock hub (`@01110000`). KK log: disconnect/reconnect, then `Instance has focus: KOMPLETE KONTROL S88 MK2`. Ready to test keys.

S88 keys still do not light. Do **not** flash firmware yet. KK **3.5.4** already claims the board (`Instance has focus`). MK2 firmware is end-of-life for new features. The log after the cable move is still `Saying "Browser"` / preset names — Light Guide does not flash on note-on in Browse. Check Hardware → Light Guide = On, and that the S88 is not in MIDI mode, before Native Access.

---

## 2026-08-22 — KK 3.5 UI correction

David: a lot of the listed KK controls do not exist. 3.5.4 Preferences are only **Audio / MIDI / General / Library / Plug-ins**. There is no Hardware page, no Light Guide toggle, no on-screen piano. Official KK 3 standalone setup: Preferences → **MIDI** → **Input** → enable the Komplete Kontrol / S88 input checkboxes (leave S8 and FLX10 unchecked). That is also what the KK 3 manual says makes notes hit the instrument and the Light Guide. Earlier “leave all MIDI boxes empty” was about Output / not stealing the S8.

MIDI Input screenshot: S88 Port 1 **and** Port 2 checked; S8 boxes off. Port 1 = keybed. Port 2 = rear 5-pin DIN. Uncheck Port 2 unless something is plugged into the S88 MIDI IN.

---

## 2026-08-22 — Piano + Light Guide work; move KK onto Channel D

S88 keys play Gentleman and LEDs flash. That was MIDI Input **Port 1**. Audio is still Intel-style: KK on the aggregate Master 1–2, so the whole S8 mix hears it and Traktor faders do nothing.

Channel D (Intel’s Maschine path, now for KK):

- Traktor stays on **Aggregate Device Maschine**. Deck D already 11–12. Do not rewrite TSI.
- KK → Preferences → **Audio** → Device **BlackHole 2ch**. Out 1 L/R = 1 / 2. Out 2+ stay not connected.
- Listen: Traktor Input Deck D meters should move. S8 Channel D fader up, A/B/C down. Cue D if using phones.

If D meters stay dead, KK is writing to 2ch but the aggregate is not seeing it (last night’s 16ch symptom). Fallback: KK device back to the aggregate, Out 1 = **5 / 6** (BlackHole), never 1–4 (S8 master).

**KK on Channel D works.** Next: Maschine. Last night this Mac had Maschine on **BlackHole 16ch**, which will not hit Deck D (D is 2ch). Do not leave it on the aggregate or the S8. Same Audio page as KK: device **BlackHole 2ch**, Out 1 = 1/2. KK + Maschine then share one Channel D fader. Leave Maschine **Input** off BlackHole (loop). Leave S8 unchecked in Maschine MIDI.

S88 Mk2 talks to **Maschine 2 without KK open**. Close KK so they don’t fight for the keyboard. Maschine MIDI Input: S88 Port 1 on, Port 2 / S8 off. Audio still BlackHole 2ch → Channel D.

Resample Traktor A → Maschine / S88: do **not** record the master into BlackHole while Channel D is up (feedback). Either Mix Recorder Internal (file → Maschine) or Output Record = aggregate **5/6** with D fader down, Maschine Sampling input = BlackHole 2ch, input monitor off, then play the pad on D.

---

## 2026-08-22 — Toolkit + runbook (review before commit)

Working 2ch Channel D documented. 16ch parked as future.

- `docs/RUNBOOK.md` — recreate, GUI (KK 3.5.4 pages that exist), rollback, failures
- `python3 scripts/rig.py` — `status`, `tone`, `midi`, `aggregates --create|--destroy`, `leftover-16ch --create|--destroy`
- Swift: `rig_status.swift`, `tone_aggregate.swift`, `midi_note.swift`, `intel_aggregates.swift`, `traktor_s8_blackhole_aggregate.swift`
- README / MASTER_CONTEXT / `.cursorrules` point at the runbook

`rig.py status` confirmed both Intel aggregates, both BlackHoles, S8, leftover 16ch, S88 direct on `@02100000`, S8 on the dock hub. Mac default had hopped to FLX10 — leave it.

No commit yet — David reviews, then commit + push.

---

## 2026-08-22 — App settings folders (notes, not dumps)

Apache-2.0 `LICENSE` added. Notes plus small **routing** backups under each `docs/settings/*/files/` (working Traktor TSI, KK Settings.dat, Maschine plist, leftover RB MIDI csv). Still no NML, `master.db`, or Maschine `komplete.db3`. `.gitignore` allows only those `files/` snapshots.

---

## 2026-08-22 — Session wrap

2ch Channel D is the parked working rig. Next blackhole session: **16ch**, Traktor **A/B/C → Maschine sampler → S88 keys**. KK does **not** sample live deck audio; leave it quit for that work. Open question: Internal Traktor may not offer three independent deck outs — 16ch alone does not invent them.

David moving to a new music-cataloging repo in the meantime.

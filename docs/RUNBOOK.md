# RUNBOOK — working 2ch Channel D rig (`ix`, 2026-08-22)

How we got S88 keys into Channel D and nowhere else. Recreate from here.

[`MASTER_CONTEXT.md`](MASTER_CONTEXT.md) · [`PROGRESS.md`](PROGRESS.md) · [`settings/`](settings/README.md) · [`../scripts/README.md`](../scripts/README.md)

**2ch is parked and on GitHub.** Next open: port this onto 16ch and *prove it* before any A/B/C sampling.

---

## 0. What “working” means

Proven on `ix` (MacBook Pro 16-inch M5 Max, macOS Tahoe 26.5.1):

1. A 440 Hz tone on **Aggregate Device Maschine** outs 1–2 is heard on **S8 master**.
2. S88 keys play **The Gentleman** in Komplete Kontrol **3.5.4**, Light Guide flashes.
3. KK audio device is **BlackHole 2ch**, Out 1 = 1/2. Traktor **Input Deck D** meters move. Sound follows the **S8 Channel D** fader only (A/B/C down).
4. Same BlackHole 2ch pair is the intended Maschine output (KK closed so they do not fight for the S88).

If (1) fails, the aggregate / S8 listen path is broken. If (2) fails, it is MIDI (KK Preferences → MIDI → Input). If (3) fails, KK is still on the aggregate **Master 1–2** (whole mixer, no faders) or Traktor is not on the aggregate.

---

## 1. Hardware that must be true

| Piece | Role | USB / power |
|-------|------|-------------|
| **Traktor Kontrol S8** | Mixer + Traktor HID + clock master | May stay on the Thunderbolt dock hub |
| **KOMPLETE KONTROL S88 MK2** | Keyboard only (not an audio device) | **Direct USB to the Mac** + **wall wart**. NI does not support unpowered hubs. Speed is USB 2.0 either way; direct is stability, not latency. |
| Mac speakers | Subdevice of Aggregate Device Maschine (drift) | Built-in |
| DDJ-FLX10 | Stretch only | Ignore. Do not add to Traktor’s device. |
| S88 5-pin DIN | Unused | Leave empty; KK MIDI **Port 2** off |

Verified working USB after the cable move:

- S88: `KOMPLETE KONTROL S88 MK2@02100000` on `AppleT8142USBXHCI@02000000` (no hub).
- S8: `Traktor Kontrol S8@01110000` on the dock hub (`USB2.0 Hub@01100000`).

Check anytime:

```bash
python3 scripts/rig.py status
```

---

## 2. Drivers (do not uninstall)

| Driver | Path / name | Version that worked |
|--------|-------------|---------------------|
| BlackHole **2ch** | `/Library/Audio/Plug-Ins/HAL/BlackHole2ch.driver` — device **BlackHole 2ch** | 0.7.1 (Existential Audio pkg; reboot required) |
| BlackHole **16ch** | `/Library/Audio/Plug-Ins/HAL/BlackHole16ch.driver` — device **BlackHole 16ch** | 0.7.1, **unused** in the working graph |
| S8 | Apple USB audio + NI HID | 10 in / 4 out @ 48 kHz |

Installer for 2ch (if this Mac is wiped): official pkg from [existential.audio/blackhole](https://existential.audio/blackhole) or `brew install --cask blackhole-2ch` (needs sudo + reboot). Homebrew cannot type the password from this environment; open the pkg and Restart when asked.

**Do not** set BlackHole or any aggregate as the Mac’s default output. Defaults hop (speakers, AirPods, **FLX10** when it is plugged in). Leave them. Traktor must not follow.

### Login — empty desk (2026-08-23)

macOS was restoring whatever was open (Traktor included). Traktor then woke on a 2ch fallback before the aggregate was ready. D’s Maschine inputs vanished.

KISS: **boot with no apps.** Set on this Mac:

- `TALLogoutSavesState` = false
- `LoginwindowLaunchesRelaunchApps` = false
- `NSQuitAlwaysKeepsWindows` = false (Desktop & Dock: Close windows when quitting)

Next Restart dialog: uncheck **Reopen windows when logging back in** if it still shows.

Stay at login: Google Drive, Dropbox, NI hardware agents, Adobe CC, Autodesk Flow.

**Epic Games Launcher is off.** It had its own LaunchAgent (`~/Library/LaunchAgents/com.epicgames.launcher.plist`, silent boot). Job disabled, `RunAtLoad` false, `StartOnBoot=False` in its settings. Next time you open Epic, uncheck **Run When My Computer Starts** or it will try to write that agent again.

After a reboot: wait for S8 USB, then launch Traktor yourself. Audio Setup → **Aggregate Device Maschine**. Input D = 11/12.

---

## 3. Aggregates (Core Audio)

Created by `python3 scripts/rig.py aggregates --create` (wrapper around `scripts/intel_aggregates.swift`).

| Name | UID | Subdevices (order) | Clock | Drift | I/O @ 48 kHz |
|------|-----|--------------------|-------|-------|--------------|
| **Aggregate Device Maschine** | `com.ixamal.aggregate-maschine` | 1. Traktor Kontrol S8  2. BlackHole 2ch  3. MacBook Pro Speakers | S8 | BH + speakers | 12 in / 8 out |
| **Aggregate Device s88 MK2** | `com.ixamal.aggregate-s88-mk2` | 1. S8  2. BlackHole 2ch | S8 | BH | 12 in / 6 out |

Intel spare: **Aggregate Device s88 MK2** can stay. Traktor and KK/Maschine do not select it.

### Channel map — Aggregate Device Maschine

S8 is first so Traktor Master/Monitor stay on hardware 1–4.

| Aggregate ch | Physical |
|--------------|----------|
| In 1–10 | S8 physical inputs |
| In 11–12 | BlackHole 2ch 1–2 ← KK / Maschine |
| Out 1–2 | S8 Master |
| Out 3–4 | S8 Monitor (phones) |
| Out 5–6 | BlackHole 2ch (Traktor must **not** send Master here) |
| Out 7–8 | MacBook Pro Speakers |

Destroy only these two: `python3 scripts/rig.py aggregates --destroy`.

### Protected / leftover

| Device | Rule |
|--------|------|
| `rekordbox Aggregate Device` | **Never** edit or destroy. Scripts refuse it. |
| `Traktor S8 + BlackHole` | Last night’s 16ch leftover (26/20). Do **not** select in Traktor. Destroy only when ready: `python3 scripts/rig.py leftover-16ch --destroy`. Recreate later for 16ch: `--create`. |

Scripts **do not** change macOS default input/output.

---

## 4. Traktor Pro 4.5.1 (GUI only while the app is open)

Do **not** rewrite `Traktor Settings.tsi` while Traktor is running.

| Pref page | Setting |
|-----------|---------|
| Audio Setup | Device **Aggregate Device Maschine (CoreAudio)**. 48 kHz. Buffer 512 worked. |
| Output Routing | Mixing Mode **Internal**. Master **1 / 2**. Monitor **3 / 4**. Record **not connected** (connecting Record to 5/6 while D is up = feedback). |
| Input Routing | Deck D **11 / 12** (`Aggregate Device Maschine In 10` / `In 11` are 0-based names for BH 1–2). A/B/C disconnected. |
| Deck D header | **Live Input** (not Stem). |

S8 hardware: Channel D **TRAKTOR** button on. Raise **D** to hear KK/Maschine. A/B/C down to prove isolation.

TSI rollback (Traktor quit first), copy over Settings:

`~/Documents/Native Instruments/Traktor 4.5.1/Backup/Settings/settings_2026y08m21d_00h45m39s_pre_blackhole.tsi`

Microphone privacy: Traktor (and KK) need **Microphone** access or Live In stays silent.

---

## 5. Komplete Kontrol 3.5.4 — only pages that exist

Preferences sidebar is **Audio, MIDI, General, Library, Plug-ins**. There is **no** Hardware page, **no** Light Guide toggle, **no** mouse piano.

### MIDI (this was the silent-piano fix)

Preferences → **MIDI** → **Input**:

| Box | State |
|-----|--------|
| KOMPLETE KONTROL S88 MK2 **(Port 1)** | **On** — keybed |
| KOMPLETE KONTROL S88 MK2 **(Port 2)** | **Off** — rear 5-pin DIN |
| Traktor Kontrol S8 | **Off** |
| Traktor Kontrol S8 Input | **Off** |
| Komplete Kontrol DAW - 1 | **Off** |
| Anything FLX10 | **Off** |

Output checkboxes: do not enable S8 or FLX10 (that steals Traktor MIDI).

Header should show **88** when the S88 is claimed. Close Preferences before playing (dialog mode eats the keybed).

### Audio (Channel D, not Intel-on-master)

Preferences → **Audio**:

| Field | Value |
|-------|--------|
| Driver | CoreAudio |
| Device | **BlackHole 2ch** |
| Out 1 L / R | **1** and **2** |
| Out 2 and below | **not connected** |

**Wrong (we proved it):** Device = Aggregate Device Maschine, Out 1 = Master L/R. That hits S8 master/phones at Core Audio. Every channel hears it. Traktor faders do nothing.

### Apps fighting

KK and Maschine both want the S88. For Maschine-only: **quit KK**. MK2 talks to Maschine 2 without KK open.

---

## 6. Maschine 2

Last night this Mac had Maschine on **BlackHole 16ch**. That pair is **not** Deck D.

| Page | Value |
|------|--------|
| Audio device | **BlackHole 2ch** |
| Out 1 | 1 / 2 |
| Input on BlackHole | **Off** (loop) |
| MIDI Input | S88 Port 1 on; Port 2 off; S8 off |

KK + Maschine on the same 2ch pair = one Channel D fader, summed. Split pairs = 16ch later.

---

## 7. Rekordbox (keep closed)

Leftover maps — do not enable:

- `~/Library/Application Support/Pioneer/rekordbox6/MidiMappings/Traktor Kontrol S8.midi.csv`
- `.../Traktor Kontrol S8 Input.midi.csv`
- `.../KOMPLETE KONTROL S88 MK2 Port 1.midi.csv`
- `.../KOMPLETE KONTROL S88 MK2 Port 2.midi.csv`
- `.../Komplete Kontrol DAW - 1.midi.csv`

---

## 8. Prove the path (in order)

From repo root. S8 plugged in. Listen on S8 master/phones, not the Mac.

```bash
python3 scripts/rig.py status
python3 scripts/rig.py tone
```

You must hear the beep on S8 master. Then:

1. Traktor device = Aggregate Device Maschine. Play a track on A, Channel A up — S8 master hears Traktor.
2. KK (or Maschine) on BlackHole 2ch. Play S88. **Input Deck D** meters move. Only Channel D fader hears it.

Optional: `python3 scripts/rig.py midi` sends middle C to `Komplete Kontrol DAW - 1`. Standalone KK often **ignores** that port; Port 1 on the MIDI Input page is what made keys work.

---

## 9. What failed (so we do not repeat it)

| Attempt | Result |
|---------|--------|
| KK on BlackHole 16ch + Traktor on 16ch aggregate | Browse prehear sometimes hit D; loaded pianos often silent. |
| KK on aggregate Master 1–2 | Sound on whole S8 mix; faders useless. **Intel KK path.** |
| KK MIDI Input all empty | Keys + Light Guide dead. KK 3 standalone needs **Port 1**. |
| Invented KK UI (Hardware / Light Guide / press B / mouse keys) | Does not exist in 3.5.4. |
| Firmware flash | Not needed. KK 3.5.4 already claimed the S88. |
| S88 on dock hub | Worked after MIDI Input; direct USB is still the preferred cable. |
| Output Record → BH while D is up | Feedback. Mix Recorder to a **file** is the 2ch resample. Live A→Maschine tap wants 16ch. |
| Gemini “Master = FLX10 9–10” | Does not match Intel screenshots. |

Browse vs load: Battery ticks in the KK browser are **prehear**. Pianos often have none. Load the preset until the computer name matches, leave the browser, then play.

---

## 10. Recreate from a clean Mac (checklist)

1. Install BlackHole 2ch 0.7.1. Reboot. Confirm device in `python3 scripts/rig.py status`.
2. Plug S8. Plug S88 **direct** + PSU. Leave FLX10 out of Traktor.
3. `python3 scripts/rig.py aggregates --create`. Confirm 12/8 and 12/6. Defaults still Speakers/Mic.
4. Quit Traktor. Set Audio device / I/O as in §4 (or restore from the TSI backup, then fix device name). Launch Traktor. Confirm GUI.
5. KK MIDI Input Port 1 only. Audio = BlackHole 2ch Out 1 = 1/2.
6. Tone test. Then piano on D.
7. Maschine: same audio/MIDI as §6. KK quit if Maschine needs the S88.

---

## 11. Next session — order of work (do not skip ahead)

Commit `fc0a0fe` is the 2ch park. **Do not commit/push again until this 16ch port is proven.** Then try sampling.

### Step A — Port what works now onto 16ch

Same listen path, more pipes. Do **not** start A/B/C mapping until this matches today’s 2ch behavior.

1. Keep Intel 2ch aggregates until the 16ch device is trusted (rollback: stay on `Aggregate Device Maschine`).
2. Create/use `Traktor S8 + BlackHole` (S8 first + BlackHole **16ch**, clock S8, drift BH). Script: `python3 scripts/rig.py leftover-16ch --create`.
3. Traktor: device = that 16ch aggregate. Internal. Master **1–2**, Monitor **3–4**. Deck D Live Input = first BlackHole pair (in 11–12 if S8 is still first).
4. KK / Maschine: device **BlackHole 16ch**, Out 1 = **1 / 2** only (not aggregate Master). MIDI Input S88 Port 1; S8 off. KK quit if Maschine owns the S88.
5. **Validate = today’s proof:** `python3 scripts/rig.py tone --device "Traktor S8 + BlackHole"` heard on S8 master. Traktor A plays on S8. S88 → KK or Maschine → **only Channel D** fader. A/B/C down.

If that fails, destroy nothing; switch Traktor back to **Aggregate Device Maschine** and stop.

### Step B — After Step A is solid: A/B/C → Maschine → S88 keys

**Komplete Kontrol will not do this.** No live-deck sampler. Maschine records; S88 plays. KK stays quit.

Internal mixing still has no “Output Deck A/B/C.” 16ch does not invent those buses. Decide Internal-vs-External (or Ext FX / sequential solo) before assigning BH 3–4, 5–6, 7–8. Never dump Master/Record onto the same pair that feeds Channel D.

### Step C — Web check: Link vs audio

Before inventing a tap, search what others did with **Traktor + Maschine + Ableton Link** (NI calls it Link; header button **LINK** in both apps). Official NI: Link syncs **tempo and phase only** on the same Mac or LAN. It does **not** move Channel A audio into Maschine. Dubspot-style writeups use Link for clock and a **separate** loopback for Maschine→Traktor D (the reverse of A/B/C→Maschine). Look for anyone who sampled Traktor decks into Maschine pads/keys; do not treat Link as the sample path.

Start here: [NI — Sync Traktor and Maschine using Ableton Link](https://support.native-instruments.com/hc/en-us/articles/214423065-How-to-Sync-TRAKTOR-and-MASCHINE-Using-Ableton-Link).

### Step D — Then commit and push

Only after Step A is validated (and notes updated). Sampling (B) can be the session after that if A ate the night.

---

## 12. Rollback

| Layer | Rollback |
|-------|----------|
| Intel aggregates | `python3 scripts/rig.py aggregates --destroy` |
| 16ch leftover | `python3 scripts/rig.py leftover-16ch --destroy` |
| Traktor TSI | Quit Traktor; restore `settings_2026y08m21d_00h45m39s_pre_blackhole.tsi` |
| Mac defaults | Never pointed at the aggregates; leave Speakers / Mic / whatever hopped (AirPods, FLX10) |
| rekordbox aggregate | Do not touch |

---

## 13. Repo / git

- Remote: https://github.com/ixamal/blackhole
- Docs + scripts only. Never commit audio, NML, TSI, `master.db`.
- Commits are David alone. No Cursor attribution trailers.

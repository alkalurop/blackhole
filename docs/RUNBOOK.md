# RUNBOOK — working Channel D rig (`ix`)

How we got S88 keys into Channel D and nowhere else. Recreate from here.

[`MASTER_CONTEXT.md`](MASTER_CONTEXT.md) · [`PROGRESS.md`](PROGRESS.md) · [`settings/`](settings/README.md) · [`../scripts/README.md`](../scripts/README.md)

**Live (2026-09-19):** **16ch Channel D** + **11a**. Traktor Record **7/8** (`Out 6`/`Out 7`) → Maschine In 2 → S88 → D. A, B, and C check. 2ch park: `~/Music/blackhole_2ch/`. Never Record **5/6**.

---

## 0. What “working” means

Proven on `ix` (MacBook Pro 16-inch M5 Max, macOS Tahoe 26.5.1):

**16ch (2026-09-19, live):**

1. A 440 Hz tone on **Traktor S8 + BlackHole** outs 1–2 is heard on **S8 master** (`python3 scripts/rig.py tone --device "Traktor S8 + BlackHole"`).
2. Traktor A plays a stem on S8 (Internal, Master 1–2 / Monitor 3–4).
3. S88 → KK or Maschine on **BlackHole 16ch** Out 1 = 1/2. Traktor **Input Deck D** = 11/12. Sound follows the **S8 Channel D** fader only (A/B/C down).

**2ch (2026-08-22, rollback):** same proof on **Aggregate Device Maschine** + **BlackHole 2ch**. Archive: `~/Music/blackhole_2ch/`.

If (1) fails, the aggregate / S8 listen path is broken. If (2) fails, Traktor is not on the 16ch aggregate or Output Master dropped. If (3) fails, KK/Maschine is still on the aggregate **Master 1–2** (whole mixer, no faders) or still writing **BlackHole 2ch** while Traktor is listening to 16ch.

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

### Step A — Port 2ch onto 16ch — **done 2026-09-19**

Same listen path, more pipes. David heard the 16ch tone on S8, A played a stem, S88 stayed on Channel D only. 2ch aggregates left in place. Disk TSI/plists still say 2ch until Traktor / Maschine quit (do not snapshot while they are open).

1. Keep Intel 2ch aggregates (rollback: **Aggregate Device Maschine** + `~/Music/blackhole_2ch/`).
2. Use `Traktor S8 + BlackHole` (already created). Recreate: `python3 scripts/rig.py leftover-16ch --create`.
3. Traktor GUI: device **Traktor S8 + BlackHole**. Internal. Master **1–2**, Monitor **3–4**. Deck D Live Input = **11 / 12**. Record not connected.
4. KK / Maschine GUI: device **BlackHole 16ch**, Out 1 = **1 / 2**. MIDI Input S88 Port 1; S8 off. KK quit if Maschine owns the S88.
5. Proof: tone on that aggregate, Traktor A on S8, S88 only on D.

### Step B — A/B/C → Maschine → S88 keys — **done 2026-09-19**

**Komplete Kontrol will not do this.** No live-deck sampler. Maschine records; S88 plays. KK stays quit.

**Do not switch Mixing Mode to External.** That drops the S8 Internal mixer. NI Output Deck A/B/C and Send FX exist only in External. 16ch does not invent those buses.

**Do not use Ableton Link as the tap.** [NI](https://support.native-instruments.com/hc/en-us/articles/214423065-How-to-Sync-TRAKTOR-and-MASCHINE-Using-Ableton-Link): tempo and phase only. Dubspot-style writeups use Link for clock plus a **separate** loopback. That loopback here is already Maschine → BH 1–2 → Channel D (the reverse of 11a).

`Traktor S8 + BlackHole` I/O: S8 first (in 10 / out 4), then BlackHole 16ch. Named outs are S8 Master 1–2 and Monitor 3–4; unnamed outs 5–20 are BH 1–16. Named ins 1–10 are S8; unnamed ins 11–26 are BH 1–16.

| Bus | Aggregate pair | BlackHole 16ch | Use |
|-----|----------------|----------------|-----|
| Master / Monitor | 1–2 / 3–4 | — | Leave. S8 listen. |
| Channel D | In 11/12 (`In 10`/`In 11`), Out **5/6** | 1–2 | Maschine Out 1. **Never Record here.** |
| Sample tap | Out **7/8** → In 13/14 | 3–4 | Output Record. Maschine In 2. |
| Later decks | 9/10, 11/12, … | 5–6, 7–8, … | Spare. Same sequential tap can reuse 7/8. |

GUI (apps stay open; do not rewrite the TSI):

1. Traktor → Output Routing: stay **Internal**. Master **1/2**, Monitor **3/4**. Record **7 / 8** = `Out 6` / `Out 7`. Not **5/6** (`Out 4`/`Out 5` = D). Not **8/9** (`Out 7`/`Out 8` = split, same class as last night’s D In 11/12).
2. Input D stays **11/12**. A/B/C inputs stay disconnected. FX Send stays disconnected.
3. Isolate one deck: that fader up, the other two down, **D down** while recording (Record is the master mix).
4. Maschine device stays **BlackHole 16ch**. Out 1 = **0/1**. Out 2+ disconnected. In 1 disconnected (loop). In 2 = **2/3** (BH 3–4). Input monitor **off**.
5. Sampler source = Ext In 2 (3/4). Record. Then D fader up, play the S88 pad — Channel D only.
6. Repeat for B, then C on the same Record pair.

File fallback: Mix Recorder **Internal** → file → drag onto a pad. Same D-down rule if the file is the live mix.

### Step C — Web check: Link vs audio — **done 2026-09-19**

Link is clock. Official NI + Dubspot + Traktor 4 manual: Internal has Master / Monitor / Record only. Per-deck outs need External. This rig stays Internal and uses Record **7/8**.

### Step D — Then commit and push

Only after Step A is validated (and notes updated). Sampling (B) can be the session after that if A ate the night.

### Step E — FLX10 → Maschine In 3 (additive, do not touch 11a)

`python3 scripts/rig.py flx10-2ch --create` makes **FLX10 + BlackHole 2ch** @ 44.1. Script aborts if BlackHole 16ch is not 48 kHz or `Traktor S8 + BlackHole` is not 26/20.

`python3 scripts/rig.py flx10-bridge` copies BH 2ch onto BH 16ch **5–6** only. Never 1–4.

**Parked 2026-09-19.** Rekordbox device **DDJ-FLX10** only. The 2ch aggregate is destroyed (it broke master/booth). Next try: PC MASTER OUT → `MASTER + BlackHole 2ch`. Never 16ch. MIDI = FLX10 only.

Maschine In 3 = `In 4` / `In 5`. Sampler INPUT **In 3**. In 2 stays A/B/C.

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

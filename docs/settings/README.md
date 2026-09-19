# App settings (notes + small routing backups)

Apache-2.0 notes **and** dated copies of the **routing** files (100 KB Traktor TSI, KK Settings.dat, Maschine plists, leftover Rekordbox MIDI csvs). Those live in each app’s `files/` folder so you can download them from GitHub.

**Still never in git:** NML, `master.db`, Maschine `komplete.db3`, autosave projects, audio, library `.nkx`. Those are libraries, not routing.

A TSI can include local collection paths. Treat a restore as “audio + MIDI prefs,” then point the library back at [music_migration](https://github.com/ixamal/music_migration). Recreate the graph from [`../RUNBOOK.md`](../RUNBOOK.md) if a dump is stale.

| Folder | App | Status on `ix` (2026-09-19) |
|--------|-----|------------------------------|
| [`traktor-pro-4/`](traktor-pro-4/NOTES.md) | Traktor Pro 4.5.1 + S8 | **16ch** Channel D on `Traktor S8 + BlackHole` |
| [`komplete-kontrol-3/`](komplete-kontrol-3/NOTES.md) | Komplete Kontrol 3.5.4 + S88 Mk2 | Keys → BlackHole **16ch** 1–2 → D |
| [`maschine-2/`](maschine-2/NOTES.md) | Maschine 2 + S88 (KK quit) | Same 16ch pair as KK |
| [`rekordbox-7-flx10/`](rekordbox-7-flx10/NOTES.md) | Rekordbox 7 + DDJ-FLX10 | Stretch. Maps on disk. Keep closed. |

**2ch rollback (never in git):** `~/Music/blackhole_2ch/` — 2026-08-22 known-good + 2026-09-19 live dump. Restore there if 16ch fails. Snapshot the 16ch TSI/plists only after Traktor / KK / Maschine quit.

Older pointer: [`../../settings-snapshots/`](../../settings-snapshots/README.md) (empty on this Mac; Music folder is the rollback).

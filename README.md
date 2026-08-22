# blackhole

Performance-rig audio + MIDI routing for [ixamal](https://github.com/ixamal) / [alkalurops.org](https://www.alkalurops.org) on host `ix`.

**Working (2026-08-22):** S88 MkII → Komplete Kontrol 3.5.4 or Maschine 2 → **BlackHole 2ch** → Traktor Pro 4 Channel D (Live Input) → S8 Channel D fader. Traktor’s audio device is **Aggregate Device Maschine** (S8 + BlackHole 2ch + Mac speakers).

**16ch** is the next graph (separate pairs + a Traktor-A tap into Maschine). Do not switch the live session until the 2ch path is committed.

Rekordbox + DDJ-FLX10 is still a stretch (RB leftover MIDI maps can steal Traktor buttons). Keep RB closed.

Library repo: [ixamal/music_migration](https://github.com/ixamal/music_migration).

License: [Apache-2.0](LICENSE). App notes (not vendor dumps): [`docs/settings/`](docs/settings/README.md).

## Docs

| Doc | Purpose |
|-----|---------|
| [`docs/RUNBOOK.md`](docs/RUNBOOK.md) | Recreate the working rig, GUI settings, rollback, tools |
| [`docs/settings/`](docs/settings/README.md) | Per-app notes: Traktor, KK, Maschine, Rekordbox |
| [`docs/MASTER_CONTEXT.md`](docs/MASTER_CONTEXT.md) | Device map and audio graph |
| [`docs/PROGRESS.md`](docs/PROGRESS.md) | Session journal |
| [`scripts/README.md`](scripts/README.md) | `python3 scripts/rig.py` commands |

## Quick check

```bash
python3 scripts/rig.py status
python3 scripts/rig.py tone
```

Listen on the **S8**, not the Mac.

## Remote

- GitHub: https://github.com/ixamal/blackhole (docs + scripts only — no audio, NML, TSI, `master.db`)

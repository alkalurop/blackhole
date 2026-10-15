# blackhole

How my live rig actually routes: Maschine, Traktor S8, Rekordbox on the FLX10, S88, BlackHole — who hears what, and which order to quit apps so Rekordbox’s sample bank does not vanish. Written because guessing broke more sets than bad transitions.

Docs and small scripts, not audio. [ixamal](https://github.com/ixamal) · [alkalurops.org](https://www.alkalurops.org)

**Vibe coding.** Cursor and Codex only. Git commits are David — no Cursor or Codex co-author trailers.

**2026-09-19 — 16ch Channel D live.** Traktor device **Traktor S8 + BlackHole**. Deck D = In 10/11 (BH 1–2). Maschine **BlackHole 16ch** Out 1 only. S88 → Channel D. 2ch rollback: **Aggregate Device Maschine** + `~/Music/blackhole_2ch/`.

**11a live.** Traktor Record **7/8** (`Out 6`/`Out 7`) → Maschine In 2 → S88 → Channel D. Never Record **5/6**.

**11b parked.** Rekordbox stays **DDJ-FLX10**. The 2026-09-19 aggregate silence was a reboot. **2026-10-11:** opening Traktor or Maschine while Rekordbox is already up kills the sample-bank drop. Quit Maschine, then Traktor, then Rekordbox, and open Rekordbox again. **40:** CH2 **LINE** is the S8 RCA. It cannot take BlackHole the way Channel D does. **13 on hold** (S8 pads → S88). Next work is Floor on [ixamal/ix](https://github.com/ixamal/ix).

Library: [ixamal/music_migration](https://github.com/ixamal/music_migration). License: [Apache-2.0](LICENSE).

## Docs

| Doc | What |
|-----|------|
| [`docs/RUNBOOK.md`](docs/RUNBOOK.md) | How we actually did it |
| [`docs/settings/`](docs/settings/README.md) | Per-app notes + small routing backups |
| [`docs/MASTER_CONTEXT.md`](docs/MASTER_CONTEXT.md) | Device map |
| [`docs/PROGRESS.md`](docs/PROGRESS.md) | The log |
| [`scripts/README.md`](scripts/README.md) | `python3 scripts/rig.py` |

```bash
python3 scripts/rig.py status
python3 scripts/rig.py tone
```

Listen on the **S8**.

GitHub is docs + scripts. No audio, no NML, no random TSI, no `master.db`. Dated routing dumps only under `docs/settings/*/files/`.

# blackhole

David’s performance rig on `ix`. [ixamal](https://github.com/ixamal) / [alkalurops.org](https://www.alkalurops.org).

**Vibe coding.** Cursor and Codex only. Git commits are David — no Cursor or Codex co-author trailers.

**2026-09-19 — 16ch Channel D live.** Traktor device **Traktor S8 + BlackHole**. Deck D = In 10/11 (BH 1–2). Maschine **BlackHole 16ch** Out 1 only. S88 → Channel D. 2ch rollback: **Aggregate Device Maschine** + `~/Music/blackhole_2ch/`.

**11a live.** Traktor Record **7/8** (`Out 6`/`Out 7`) → Maschine In 2 → S88 → Channel D. Never Record **5/6**.

**11b parked.** Rekordbox stays **DDJ-FLX10**. Do not select an FLX10+BlackHole aggregate as the device (breaks master / booth / receiver). Next try: PC MASTER OUT → `MASTER + BlackHole 2ch`. **13 on hold** (S8 pads → S88). Next work is Floor on [ixamal/ix](https://github.com/ixamal/ix).

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

# blackhole

David’s performance rig on `ix`. I point, the agent heavy-lifts, we meet in the scripts. [ixamal](https://github.com/ixamal) / [alkalurops.org](https://www.alkalurops.org).

**2026-08-22 — success intensifies.** S88 keys (Light Guide and all) into Komplete Kontrol or Maschine, down **BlackHole 2ch**, into Traktor Channel D, out the S8 fader. Not the whole mixer. That was the fight. We won.

Traktor’s box: **Aggregate Device Maschine** (S8 + BlackHole 2ch + Mac speakers). S88 straight into the Mac + wall wart. Rekordbox / FLX10 stays a later problem — leftover maps on disk, keep RB shut.

**Next time:** copy this graph onto **16ch**, prove it still behaves, *then* tap Traktor A/B/C into Maschine for S88 sampling. KK does not sample decks. Ableton Link is clock, not audio. Cataloging lives in another repo until then.

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

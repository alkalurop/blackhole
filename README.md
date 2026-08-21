# blackhole

Performance-rig audio + MIDI routing for [ixamal](https://github.com/ixamal) / [alkalurops.org](https://www.alkalurops.org).

BlackHole virtual audio on David's Mac (`ix`). **Traktor Pro 4** on the **S8** (Channel D = live input). **S88 MkII** drives Maschine / Komplete; that audio reaches the S8 only through Traktor Channel D.

**Rekordbox + DDJ-FLX10** is a stretch goal. On the last laptop, Rekordbox captured Traktor MIDI and drove the wrong buttons. Do not dual-map until S88 and S8 are clean on Traktor alone.

Library migration is a separate canned repo: [ixamal/music_migration](https://github.com/ixamal/music_migration).

**Living log:** `docs/PROGRESS.md` + `git log`.

## Docs

| Doc | Purpose |
|-----|---------|
| [`docs/MASTER_CONTEXT.md`](docs/MASTER_CONTEXT.md) | Rig, devices, audio graph, phases |
| [`docs/PROGRESS.md`](docs/PROGRESS.md) | Session log |

## Phases

1. BlackHole **16ch** + aggregate `Traktor S8 + BlackHole` (clock = S8)
2. S8 + Traktor (Channel D = aggregate in 11–12)
3. S88 MkII + Maschine / Komplete without stealing S8 I/O
4. Stretch: Rekordbox on FLX10 without MIDI bleed into Traktor

## Remote

- GitHub: https://github.com/ixamal/blackhole
- Sibling: https://github.com/ixamal/music_migration

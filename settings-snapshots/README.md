# Local snapshots (not in git)

Copy vendor settings **here on this Mac only** if you want a dated rollback. The folder contents are gitignored except this README.

```text
settings-snapshots/
  README.md                 ← this file (committed)
  2026-08-22-working-2ch/   ← you create; never push
    traktor-pro-4/
    komplete-kontrol-3/
    maschine-2/
    rekordbox-7-flx10/
```

**Do not copy into git:** `.tsi`, `.nml`, `master.db`, audio, library `.nkx`.

Example (Traktor quit first):

```bash
mkdir -p settings-snapshots/2026-08-22-working-2ch/traktor-pro-4
cp "$HOME/Documents/Native Instruments/Traktor 4.5.1/Traktor Settings.tsi" \
  settings-snapshots/2026-08-22-working-2ch/traktor-pro-4/
```

The public, Apache-licensed record of what those files *mean* is [`docs/settings/`](../docs/settings/README.md).

# Rig tools

Python entry point: `python3 scripts/rig.py <command>` from the repo root.

Core Audio / MIDI work is Swift. The Python CLI only launches those scripts and prints the USB tree. Nothing here changes macOS default I/O. Aggregate scripts never touch `rekordbox Aggregate Device`.

Full procedure: [`docs/RUNBOOK.md`](../docs/RUNBOOK.md).

| Command | Script | What it does |
|---------|--------|----------------|
| `status` | `rig_status.swift` + `ioreg` | Devices, defaults, MIDI ports, S8/S88 USB path |
| `tone` | `tone_aggregate.swift` | 1.5 s 440 Hz on outs 1–2 (default **Aggregate Device Maschine**) |
| `tone --device "BlackHole 2ch"` | same | Same tone on another device |
| `midi` | `midi_note.swift` | Middle C → `Komplete Kontrol DAW - 1` (standalone KK often ignores this) |
| `aggregates --create` | `intel_aggregates.swift` | **Aggregate Device Maschine** + **Aggregate Device s88 MK2** |
| `aggregates --destroy` | same `--destroy` | Those two only |
| `leftover-16ch --create` | `traktor_s8_blackhole_aggregate.swift` | Last night / future `Traktor S8 + BlackHole` (16ch) |
| `leftover-16ch --destroy` | same `--destroy` | That leftover only |

Direct Swift (same as the CLI):

```bash
swift scripts/rig_status.swift
swift scripts/tone_aggregate.swift
swift scripts/intel_aggregates.swift
swift scripts/intel_aggregates.swift --destroy
swift scripts/traktor_s8_blackhole_aggregate.swift --destroy
```

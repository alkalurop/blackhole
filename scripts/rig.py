#!/usr/bin/env python3
"""CLI for the ix BlackHole / S8 / S88 rig tools.

Does not change macOS default I/O. Aggregate create/destroy never touches
rekordbox Aggregate Device.

Usage (from repo root):
  python3 scripts/rig.py status
  python3 scripts/rig.py tone
  python3 scripts/rig.py tone --device "BlackHole 2ch"
  python3 scripts/rig.py midi
  python3 scripts/rig.py midi --dest "Komplete Kontrol DAW - 1"
  python3 scripts/rig.py aggregates --create
  python3 scripts/rig.py aggregates --destroy
  python3 scripts/rig.py leftover-16ch --create
  python3 scripts/rig.py leftover-16ch --destroy
  python3 scripts/rig.py flx10-2ch --create
  python3 scripts/rig.py flx10-2ch --destroy
  python3 scripts/rig.py flx10-bridge
"""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCRIPTS = ROOT / "scripts"


def run_swift(script: str, extra: list[str] | None = None) -> int:
    path = SCRIPTS / script
    if not path.is_file():
        print(f"missing {path}", file=sys.stderr)
        return 2
    cmd = ["swift", str(path)]
    if extra:
        cmd.extend(extra)
    print("+", " ".join(cmd), file=sys.stderr)
    return subprocess.call(cmd)


def run_compiled_swift(script: str, binary_name: str) -> int:
    """Compile once to /tmp so AudioToolbox scripts are not interpreted."""
    src = SCRIPTS / script
    if not src.is_file():
        print(f"missing {src}", file=sys.stderr)
        return 2
    dest = Path("/tmp") / binary_name
    cmd = ["swiftc", "-O", str(src), "-o", str(dest)]
    print("+", " ".join(cmd), file=sys.stderr)
    compiled = subprocess.call(cmd)
    if compiled != 0:
        return compiled
    print("+", dest, file=sys.stderr)
    return subprocess.call([str(dest)])


def usb_ni() -> None:
    print("=== USB (S8 / S88 / first-hop hubs) ===")
    proc = subprocess.run(
        ["ioreg", "-p", "IOUSB", "-w0"],
        capture_output=True,
        text=True,
        check=False,
    )
    if proc.returncode != 0:
        print(proc.stderr or "ioreg failed", file=sys.stderr)
        return
    keys = (
        "S88",
        "S8",
        "Kontrol",
        "FLX",
        "Hub@",
        "Thunderbolt",
        "AppleT8142",
        "AppleT6050",
    )
    for line in proc.stdout.splitlines():
        if any(k in line for k in keys):
            print(line)


def cmd_status(_: argparse.Namespace) -> int:
    code = run_swift("rig_status.swift")
    print()
    usb_ni()
    return code


def cmd_tone(args: argparse.Namespace) -> int:
    extra = [args.device] if args.device else None
    return run_swift("tone_aggregate.swift", extra)


def cmd_midi(args: argparse.Namespace) -> int:
    extra = [args.dest] if args.dest else None
    return run_swift("midi_note.swift", extra)


def cmd_aggregates(args: argparse.Namespace) -> int:
    if args.destroy:
        return run_swift("intel_aggregates.swift", ["--destroy"])
    return run_swift("intel_aggregates.swift")


def cmd_leftover(args: argparse.Namespace) -> int:
    if args.destroy:
        return run_swift("traktor_s8_blackhole_aggregate.swift", ["--destroy"])
    return run_swift("traktor_s8_blackhole_aggregate.swift")


def cmd_flx10_2ch(args: argparse.Namespace) -> int:
    if args.destroy:
        return run_swift("flx10_blackhole_2ch_aggregate.swift", ["--destroy"])
    return run_swift("flx10_blackhole_2ch_aggregate.swift")


def cmd_flx10_bridge(_: argparse.Namespace) -> int:
    return run_compiled_swift("flx10_bridge.swift", "ix-flx10-bridge")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="ix BlackHole / S8 / S88 rig tools. See docs/RUNBOOK.md."
    )
    sub = parser.add_subparsers(dest="cmd", required=True)

    sub.add_parser("status", help="List audio devices, MIDI ports, USB NI path")

    p_tone = sub.add_parser("tone", help="440 Hz on outs 1–2 (default: Aggregate Device Maschine)")
    p_tone.add_argument("--device", help='Core Audio device name, e.g. "BlackHole 2ch"')

    p_midi = sub.add_parser("midi", help="Middle C to a CoreMIDI destination")
    p_midi.add_argument(
        "--dest",
        help='Destination name (default: "Komplete Kontrol DAW - 1")',
    )

    p_agg = sub.add_parser("aggregates", help="Create or destroy the Intel-named 2ch aggregates")
    g = p_agg.add_mutually_exclusive_group(required=True)
    g.add_argument("--create", action="store_true")
    g.add_argument("--destroy", action="store_true")

    p_16 = sub.add_parser(
        "leftover-16ch",
        help="Create or destroy last night's Traktor S8 + BlackHole (16ch). Future resample.",
    )
    g16 = p_16.add_mutually_exclusive_group(required=True)
    g16.add_argument("--create", action="store_true")
    g16.add_argument("--destroy", action="store_true")

    p_flx = sub.add_parser(
        "flx10-2ch",
        help="Create or destroy FLX10 + BlackHole 2ch (Rekordbox-only, 44.1). Leaves 16ch/11a alone.",
    )
    gflx = p_flx.add_mutually_exclusive_group(required=True)
    gflx.add_argument("--create", action="store_true")
    gflx.add_argument("--destroy", action="store_true")

    sub.add_parser(
        "flx10-bridge",
        help="SRC BlackHole 2ch → BlackHole 16ch 5–6 only. Ctrl-C to stop.",
    )

    args = parser.parse_args()
    dispatch = {
        "status": cmd_status,
        "tone": cmd_tone,
        "midi": cmd_midi,
        "aggregates": cmd_aggregates,
        "leftover-16ch": cmd_leftover,
        "flx10-2ch": cmd_flx10_2ch,
        "flx10-bridge": cmd_flx10_bridge,
    }
    return dispatch[args.cmd](args)


if __name__ == "__main__":
    sys.exit(main())

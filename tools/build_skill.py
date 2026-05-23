#!/usr/bin/env python3
"""build_skill.py — build (and verify) zergling.skill from tracked sources.

Invoked by pack.sh and pack.ps1. Keeps the build logic in one cross-platform
place so the shell wrappers stay thin and there is no quoting hell.

Usage:
    python tools/build_skill.py [--check-only]

Resolves the repo root as the parent of this file's directory.
"""
from __future__ import annotations
import os
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT  = ROOT / "zergling.skill"

# (tracked source rel path, arcname inside the zip)
ENTRIES: list[tuple[str, str]] = [
    ("INSTALL.md",              "zergling/INSTALL.md"),
    ("SKILL.md",                "zergling/SKILL.md"),
    ("assets/bootstrap.html",   "zergling/assets/bootstrap.html"),
]
EXPECTED = {arc for _, arc in ENTRIES}


def build() -> None:
    for src_rel, _ in ENTRIES:
        p = ROOT / src_rel
        if not p.is_file():
            sys.exit(f"error: missing tracked source: {p}")
    with zipfile.ZipFile(OUT, "w", zipfile.ZIP_DEFLATED) as z:
        for src_rel, arc in ENTRIES:
            z.write(ROOT / src_rel, arcname=arc)
            print(f"  + {arc}")


def verify() -> None:
    with zipfile.ZipFile(OUT) as z:
        actual = set(z.namelist())
    extra   = actual - EXPECTED
    missing = EXPECTED - actual
    if extra:   print(f"  unexpected entries: {sorted(extra)}")
    if missing: print(f"  missing entries:    {sorted(missing)}")
    if extra or missing:
        sys.exit("archive structure mismatch")
    print(f"  ok ({len(actual)} entries)")


def main() -> int:
    check_only = "--check-only" in sys.argv[1:]
    if check_only:
        if not OUT.exists():
            sys.exit(f"error: {OUT} not found")
        print(f"verifying {OUT}")
        verify()
        return 0
    print(f"building {OUT}")
    build()
    print()
    print("verifying archive structure")
    verify()
    return 0


if __name__ == "__main__":
    sys.exit(main())

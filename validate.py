#!/usr/bin/env python3
"""validate.py — lightweight checks for zergling sources and package.

Checks:
  1. SKILL.md frontmatter parses; has `name`, `description`; description
     length is sane; optional `version` is a non-empty string if present.
  2. assets/bootstrap.html includes an auto-refresh mechanism
     (either a meta http-equiv refresh or a setTimeout reload).
  3. zergling.skill exists, is a ZIP, contains exactly the expected
     entries, and each packaged file is byte-identical to its tracked source.
  4. (optional) Runs `agentskills validate <skill-dir>` if `agentskills`
     is on PATH. A missing binary is not an error.

Exit code 0 on pass, non-zero on any failure.
Run from anywhere — the script resolves its own directory.
"""
from __future__ import annotations
import hashlib
import os
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent

EXPECTED_ENTRIES = {
    "zergling/INSTALL.md":            "INSTALL.md",
    "zergling/SKILL.md":              "SKILL.md",
    "zergling/assets/bootstrap.html": "assets/bootstrap.html",
}
SKILL_PKG = ROOT / "zergling.skill"

DESC_MAX = 1024  # generous; most validators cap around 1024 chars

errors: list[str] = []
warnings: list[str] = []


def fail(msg: str) -> None:
    errors.append(msg)


def warn(msg: str) -> None:
    warnings.append(msg)


def step(label: str) -> None:
    print(f"\n== {label} ==")


def parse_frontmatter(text: str) -> dict[str, str] | None:
    m = re.match(r"^---\s*\n(.*?)\n---\s*\n", text, re.DOTALL)
    if not m:
        return None
    fm: dict[str, str] = {}
    for line in m.group(1).splitlines():
        if ":" not in line:
            continue
        k, _, v = line.partition(":")
        fm[k.strip()] = v.strip()
    return fm


def check_skill_md() -> None:
    step("SKILL.md frontmatter")
    p = ROOT / "SKILL.md"
    if not p.is_file():
        fail(f"missing: {p}")
        return
    fm = parse_frontmatter(p.read_text(encoding="utf-8"))
    if fm is None:
        fail("SKILL.md: no YAML frontmatter delimited by '---' lines")
        return
    name = fm.get("name", "")
    desc = fm.get("description", "")
    print(f"  name        = {name!r}")
    print(f"  description = {desc[:80]!r}{'...' if len(desc) > 80 else ''}")
    print(f"  desc length = {len(desc)} chars")
    if name != "zergling":
        fail(f"SKILL.md: name must be 'zergling', got {name!r}")
    if not desc:
        fail("SKILL.md: description is empty")
    elif len(desc) > DESC_MAX:
        fail(f"SKILL.md: description exceeds {DESC_MAX} chars ({len(desc)})")
    if "version" in fm:
        v = fm["version"]
        print(f"  version     = {v!r}")
        if not v or not re.match(r"^\d+\.\d+(\.\d+)?(-[\w.]+)?$", v):
            fail(f"SKILL.md: version {v!r} is not a valid semver-ish string")
    else:
        warn("SKILL.md: no `version` field in frontmatter (optional but recommended)")


def check_bootstrap() -> None:
    step("assets/bootstrap.html auto-refresh")
    p = ROOT / "assets" / "bootstrap.html"
    if not p.is_file():
        fail(f"missing: {p}")
        return
    body = p.read_text(encoding="utf-8")
    has_meta    = bool(re.search(r'<meta\s+http-equiv=["\']refresh["\']', body, re.I))
    has_reload  = bool(re.search(r"setTimeout\s*\(\s*[^,]*location\.reload", body))
    if has_meta:
        print("  ok: meta http-equiv=refresh present")
    elif has_reload:
        print("  ok: setTimeout(location.reload) present")
    else:
        fail("bootstrap.html: no auto-refresh found (expected meta refresh or setTimeout reload)")


def sha256(p: Path) -> str:
    h = hashlib.sha256()
    h.update(p.read_bytes())
    return h.hexdigest()


def check_package() -> None:
    step("zergling.skill archive")
    if not SKILL_PKG.is_file():
        fail(f"missing: {SKILL_PKG}")
        return
    try:
        z = zipfile.ZipFile(SKILL_PKG)
    except zipfile.BadZipFile as e:
        fail(f"zergling.skill is not a valid ZIP: {e}")
        return
    with z:
        names = set(z.namelist())
        print(f"  entries: {sorted(names)}")
        expected = set(EXPECTED_ENTRIES.keys())
        extra   = names - expected
        missing = expected - names
        if extra:   fail(f"unexpected entries in package: {sorted(extra)}")
        if missing: fail(f"missing entries in package: {sorted(missing)}")
        if extra or missing:
            return
        tmp = Path(tempfile.mkdtemp(prefix="zergling-validate-"))
        try:
            z.extractall(tmp)
            for arc, rel in EXPECTED_ENTRIES.items():
                packed_path = tmp / arc.replace("/", os.sep)
                source_path = ROOT / rel
                if not source_path.is_file():
                    fail(f"tracked source missing: {source_path}")
                    continue
                if sha256(packed_path) != sha256(source_path):
                    fail(f"package drift: {arc} differs from tracked {rel}")
                else:
                    print(f"  ok: {arc} matches {rel}")
        finally:
            shutil.rmtree(tmp, ignore_errors=True)


def check_agentskills_validator() -> None:
    step("agentskills validate (optional)")
    if not shutil.which("agentskills"):
        print("  skip: `agentskills` not on PATH")
        return
    tmp = Path(tempfile.mkdtemp(prefix="zergling-agentskills-"))
    try:
        with zipfile.ZipFile(SKILL_PKG) as z:
            z.extractall(tmp)
        skill_dir = tmp / "zergling"
        proc = subprocess.run(
            ["agentskills", "validate", str(skill_dir)],
            capture_output=True, text=True,
        )
        out = (proc.stdout or "") + (proc.stderr or "")
        print(out.rstrip() or "  (no output)")
        if proc.returncode != 0:
            fail(f"agentskills validate failed (exit {proc.returncode})")
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def main() -> int:
    print(f"validating zergling at {ROOT}")
    check_skill_md()
    check_bootstrap()
    check_package()
    check_agentskills_validator()

    print()
    if warnings:
        print(f"warnings ({len(warnings)}):")
        for w in warnings:
            print(f"  - {w}")
    if errors:
        print(f"\nFAIL ({len(errors)} error{'s' if len(errors) != 1 else ''}):")
        for e in errors:
            print(f"  - {e}")
        return 1
    print("PASS")
    return 0


if __name__ == "__main__":
    sys.exit(main())

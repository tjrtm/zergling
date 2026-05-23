# Changelog

All notable changes to **zergling** are documented in this file. The format is loosely based on [Keep a Changelog](https://keepachangelog.com/), and the project follows [Semantic Versioning](https://semver.org/).

## [0.2.0] — 2026-05-23

First public-ready release. The project graduates from a personal prototype to something installable, packageable, and verifiable.

### Added

- **`pack.sh` / `pack.ps1`** and `tools/build_skill.py` — rebuild the `zergling.skill` ZIP from tracked source files and verify the archive layout.
- **`validate.py`** — sanity checks for `SKILL.md` frontmatter, the bootstrap auto-refresh, and byte-level package-vs-source parity. Optionally runs `agentskills validate` if it's on `PATH`.
- **`uninstall.sh` / `uninstall.ps1`** — remove the skill cleanly. `--purge-world` / `-PurgeWorld` also wipes `~/.claude/zergling-world/`. `--dry-run` previews any action.
- **`install-into-project.sh` / `install-into-project.ps1`** — drop cross-vendor shims (`AGENTS.md`, `.cursor/rules/`, `.github/`) into any project so non-Claude harnesses pick up the same instruction.
- **`--dry-run`** and **`--overwrite-current`** / **`-Force`** flags on the install scripts.
- **`tools/rebuild_playlist.py`** — regenerate `history/playlist.js` by scanning the `history/` directory; preserves notes across rebuilds.
- **`examples/`** — three curated static frames (`01-quiet.html`, `02-loud.html`, `03-canvas.html`) illustrating the aesthetic range without invoking the skill.
- **`.github/workflows/validate.yml`** — CI on push / PR runs whitespace check, Bash and PowerShell syntax checks, a `pack` round-trip, and `validate.py`.
- **`.gitattributes`** — normalizes line endings (`*.sh` and `*.md` → LF, `*.ps1` → CRLF, `*.skill` → binary).
- **`SKILL.md` — "External generative tools — use them if you have them"** section. Tells the agent: if the harness exposes image gen, TTS, ASR, music, video, code-exec, or any other tool, use it as part of the expression and save artifacts under `~/.claude/zergling-world/media/`.
- **`SKILL.md`** — `version: 0.2.0` field in frontmatter.
- **README** — package-integrity, security/trust, and tooling-requirements sections; portability table; examples gallery with mood captions.
- **CHANGELOG.md**, **CONTRIBUTING.md**, **SECURITY.md** — public-project hygiene.

### Changed

- **Renamed** the project from `agent-mirror` to `zergling`. All identifiers, paths (`~/.claude/skills/zergling/`, `~/.claude/zergling-world/`), file names, and documentation rebranded.
- **`SKILL.md` description** rewritten to describe *when* to invoke (semantic triggers like "express yourself", "show state", "live status") instead of self-referencing the skill name.
- **Installers** now seed `~/.claude/zergling-world/current.html` only if absent. Re-running never trashes a user-modified shell. `--overwrite-current` opts back into reseeding.
- **`pack.sh` and `pack.ps1`** centralized through `tools/build_skill.py`; both probe for a working `python` / `python3` (the Windows App Execution Alias stub is detected and skipped).
- **Skill package** (`zergling.skill`) trimmed to exactly three entries: `zergling/SKILL.md`, `zergling/INSTALL.md`, `zergling/assets/bootstrap.html`. No installer scripts, no shell, no examples in the ZIP.
- **CI `git diff --check`** now runs against the PR base ref instead of being a no-op.

### Fixed

- **Timelapse player** — three bugs in `history/index.html`:
  - Cache-busted the `playlist.js` script tag so the browser never serves a stale playlist.
  - Player now opens at frame 1/N (oldest) and auto-plays, instead of opening at the newest and looking like there's only one frame.
  - Iframe sandbox now uses `allow-scripts allow-same-origin` (matching the live shell), so Chrome stops blocking `file://` history frames with *"Not allowed to load local resource"*.
- **PowerShell function naming** — `Done-Msg` in `uninstall.ps1` renamed to `Write-Done` (approved verb).
- **`install-into-project`** help-text and file-path alignment cleaned up after the rebrand.
- **README** file-tree alignment restored after the rebrand-induced spacing drift.

### Removed

- All references to **Hermes Agent** and **OpenClaw** as auto-detected install targets (unverified harnesses; their absence was effectively dead code).
- Overclaim *"Other harnesses that understand the `.skill` format can import it directly"* — softened to call out Claude Code as the primary skill-aware runtime today.

### Security

- `SKILL.md` continues to forbid trackers, analytics, and non-CDN runtime calls.
- The agent is instructed to write only under `~/.claude/zergling-world/`; this is documented in the README *Security and trust* section along with a recommendation to inspect the skill before installing.

---

## [0.1.0] — first spawn

Original `agent-mirror` v1 (commit `a81da6f`). Single-file `SKILL.md`, a self-refreshing `current.html`, and a basic installer. Established the core idea: the page is the agent's body for the moment, refreshed in the user's browser tab.

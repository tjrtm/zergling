# Changelog

All notable changes to **zergling** are documented in this file. The format is loosely based on [Keep a Changelog](https://keepachangelog.com/), and the project follows [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Fixed

- **The shell (`current.html`) was never created on native `.skill` installs — the headline "page never updates / never reloads" bug.** The `.skill` package shipped only `SKILL.md`, `INSTALL.md`, and `assets/bootstrap.html`, with no shell and no installer. Claude Code's native skill install runs no installer script, so `current.html` was never seeded; the agent wrote frames into a world with no shell to display them, and `SKILL.md` explicitly told the agent not to create `current.html`. Fixes:
  - **Self-bootstrapping skill.** `SKILL.md` now has a "First run — seed the world" step: if `current.html` (or the timelapse files / `version.js` / `frame.html`) is missing, the agent seeds it once from the skill's bundled `assets/` templates. It only ever *creates* a missing `current.html`, never overwrites an existing one.
  - **Package carries the templates.** `tools/build_skill.py` (and `validate.py`'s expected-entries set) now include `assets/shell.html`, `assets/version.js`, `assets/timelapse-index.html`, and `assets/timelapse-playlist.js`, so the self-seed step has its sources. `zergling.skill` rebuilt.
  - **`install-into-project.sh` / `.ps1` seeded the wrong file** — they copied `bootstrap.html` *as* `current.html` (a static placeholder that never loads `frame.html`). They now seed `current.html` from `shell.html` and seed a complete minimal world (`frame.html`, `version.js`, `history/index.html`, `history/playlist.js`), each only if absent.
  - **`install.sh` / `install.ps1` / `web-install.sh` / `web-install.ps1`** now also place all world templates into the skill's `assets/` dir, so a clone/web-installed skill is self-sufficient too.
- **Stale guardrail wording.** "Always include the auto-reload" (in `SKILL.md`, `AGENTS.md`, and `.github/copilot-instructions.md`) contradicted the shell architecture — it could push agents to put a frame-killing `<meta refresh>` inside `frame.html`. Reworded to "always bump `version.js`; never self-reload inside the frame."
- **`validate.py`** now asserts `assets/shell.html` is a real polling shell (references `version.js` + `frame.html`, has a `setInterval` loop), not just a meta-refresh placeholder.

## [0.2.0] — 2026-05-23

First public-ready release. The project graduates from a personal prototype to something installable, packageable, and verifiable.

### Added

- **One-line web installers**: `web-install.sh` and `web-install.ps1` so non-tech users can install with a single curl/iex line — no git clone, no manual download. Mirror uninstallers (`web-uninstall.sh` / `web-uninstall.ps1`) follow the same pattern.
- **`pack.sh` / `pack.ps1`** and `tools/build_skill.py` — rebuild the `zergling.skill` ZIP from tracked source files and verify the archive layout.
- **`validate.py`** — sanity checks for `SKILL.md` frontmatter, the bootstrap auto-refresh, and byte-level package-vs-source parity. Optionally runs `agentskills validate` if it's on `PATH`.
- **`uninstall.sh` / `uninstall.ps1`** — remove the skill cleanly. `--purge-world` / `-PurgeWorld` also wipes `~/.claude/zergling-world/`. `--dry-run` previews any action.
- **`install-into-project.sh` / `install-into-project.ps1`** — drop cross-vendor shims (`AGENTS.md`, `.cursor/rules/`, `.github/`) into any project so non-Claude harnesses pick up the same instruction.
- **`--dry-run`** and **`--overwrite-current`** / **`-Force`** flags on the install scripts.
- **`tools/rebuild_playlist.py`** — regenerate `history/playlist.js` by scanning the `history/` directory; preserves notes across rebuilds.
- **`examples/`** — three curated static frames (`01-quiet.html`, `02-loud.html`, `03-canvas.html`) illustrating the aesthetic range without invoking the skill.
- **`.gitattributes`** — normalizes line endings (`*.sh` and `*.md` → LF, `*.ps1` → CRLF, `*.skill` → binary).
- **`SKILL.md` — "External generative tools — use them if you have them"** section. Tells the agent: if the harness exposes image gen, TTS, ASR, music, video, code-exec, or any other tool, use it as part of the expression and save artifacts under `~/.claude/zergling-world/media/`.
- **`SKILL.md`** — `version: 0.2.0` field in frontmatter.
- **README** — rewritten lead for non-technical users (one-line install, plain-English "what you'll see", advanced docs collapsed below). Package-integrity, portability table, and examples gallery moved into `<details>` sections so the front page stays simple.
- **CHANGELOG.md**, **CONTRIBUTING.md**, **SECURITY.md** — public-project hygiene.

### Changed

- **Renamed** the project from `agent-mirror` to `zergling`. All identifiers, paths (`~/.claude/skills/zergling/`, `~/.claude/zergling-world/`), file names, and documentation rebranded.
- **Single source of truth for version**: removed the duplicated `Version 0.2.0` banner from `README.md` and `INSTALL.md`. The canonical version now lives in **`SKILL.md` frontmatter** (`version: 0.2.0`) and in **`CHANGELOG.md`** entry headings. Bumping a release means updating exactly two places.
- **`SKILL.md` description** rewritten to describe *when* to invoke (semantic triggers like "express yourself", "show state", "live status") instead of self-referencing the skill name.
- **Installers** now seed `~/.claude/zergling-world/current.html` only if absent. Re-running never trashes a user-modified shell. `--overwrite-current` opts back into reseeding.
- **`pack.sh` and `pack.ps1`** centralized through `tools/build_skill.py`; both probe for a working `python` / `python3` (the Windows App Execution Alias stub is detected and skipped).
- **Skill package** (`zergling.skill`) trimmed to exactly three entries: `zergling/SKILL.md`, `zergling/INSTALL.md`, `zergling/assets/bootstrap.html`. No installer scripts, no shell, no examples in the ZIP.
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

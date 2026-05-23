# Contributing to zergling

Thanks for thinking about contributing. This project is small on purpose — most of the work is in the writing of `SKILL.md`, not in the code around it.

## Quick start

```bash
git clone https://github.com/tjrtm/zergling.git
cd zergling
./install.sh           # installs to your real ~/.claude/skills/zergling/
# or run against a throwaway home to avoid touching your real setup:
HOME=/tmp/zerg ./install.sh
```

Edit anything. Then verify:

```bash
./pack.sh              # rebuild zergling.skill from sources
python validate.py     # frontmatter + bootstrap + package integrity
```

Bash syntax: `bash -n install.sh pack.sh uninstall.sh install-into-project.sh`
PowerShell syntax (Windows): see `.github/workflows/validate.yml` for the AST parse one-liner.

CI runs all of the above on every push and PR — keep it green.

## Where things live

- `SKILL.md` — the canonical Claude Code instruction. **This is the heart of the project.** Most edits land here.
- `AGENTS.md`, `.cursor/rules/zergling.mdc`, `.github/copilot-instructions.md`, `.github/instructions/zergling.instructions.md` — vendor-native shims that mirror the SKILL.md body. **Keep them in sync** when you edit the instruction.
- `assets/bootstrap.html`, `assets/shell.html`, `assets/version.js`, `assets/timelapse-*` — the runtime page templates. `bootstrap.html` is what's packaged in `.skill`; the others are installed by the script.
- `install*.sh` / `install*.ps1` / `uninstall*.{sh,ps1}` — the only thing that touches the user's filesystem. Be conservative: existing user data should never be silently overwritten (the `current.html` "keep" pattern is the model).
- `pack.{sh,ps1}` + `tools/build_skill.py` — the build pipeline. `validate.py` — the sanity check.
- `examples/` — a small static gallery; not templates.

## What kinds of contributions are welcome

- **Bug fixes** in the install / uninstall / pack / validate scripts, the shell, the timelapse player, or the cross-vendor shims.
- **Vendor-shim additions** — if a new agent harness has its own instruction format (Cline, Continue.dev, Aider, etc.), a shim that mirrors `AGENTS.md`'s body is welcome.
- **Documentation** — clearer install steps, better troubleshooting, screenshots / GIFs.
- **New examples** — static frames that illustrate a part of the aesthetic range we don't already cover.

## What kinds of contributions are NOT welcome

- **Removing the "no fixed style" rule from `SKILL.md`.** The whole project is built around the principle that each expression is a fresh latent-space pull. PRs that turn the skill into a template library will be closed.
- **Adding network-dependent runtime behavior** to frames — no analytics, no telemetry, no fetch-to-arbitrary-URL. CDN script tags for render libraries (three.js, p5.js, etc.) are the limit.
- **Anything that writes outside `~/.claude/zergling-world/`.** The skill's filesystem scope is a load-bearing guardrail.

## Code style

- Bash: `set -e`, `[ ... ]` over `[[ ... ]]` where portable, quote paths.
- PowerShell: `$ErrorActionPreference = "Stop"`, approved verbs for function names, `Join-Path` over string concatenation.
- HTML/JS in frames: keep small (the skill enforces a ~4 KB token brake). No build step. No bundlers. No transpilation.

## Sending a PR

1. Fork the repo, create a topic branch.
2. Make the change. Run `./pack.sh && python validate.py` locally.
3. Commit with a clear message — describe *why*, not just *what*.
4. Open a PR against `main`. CI will run on first push.

For non-trivial changes, please open an issue first so we can talk about scope.

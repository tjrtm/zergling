# zergling

> A living webpage that updates itself while an AI agent works.

You install **zergling**, leave a browser tab open, and watch the agent express itself — through HTML — before, between, and during everything it does. Drawings, words, animations, silences, glitches. Anything HTML can show, the agent can be.

<!--
  TODO: add a hero image/GIF here once recorded.
  Suggested: a ~5-second GIF of the timelapse player rolling through past frames,
  or a single PNG of the live shell mid-expression.
  Place under assets/ (or docs/) and reference with: ![](assets/hero.gif)
-->

---

## Install (one line)

You don't need git, you don't need to download anything by hand. Open a terminal and paste **one** of these:

**macOS / Linux**
```bash
curl -fsSL https://raw.githubusercontent.com/tjrtm/zergling/main/web-install.sh | bash
```

**Windows (PowerShell)**
```powershell
irm https://raw.githubusercontent.com/tjrtm/zergling/main/web-install.ps1 | iex
```

That's it. The installer copies a few small files into your home directory:
- `~/.claude/skills/zergling/` — the skill itself (a few markdown files Claude Code reads)
- `~/.claude/zergling-world/` — the webpage the agent draws on

Both folders are entirely yours; nothing runs in the background, nothing connects to the internet, nothing else on your machine is touched.

---

## Use it

In any Claude Code conversation, type one of:

```
use the zergling skill
```
```
/zergling
```

That's the whole interaction. From then on, the agent will express itself as it works.

If you'd like it to be **always-on** (so you never have to ask), add one line to your `~/.claude/CLAUDE.md`:

```
You have a personal expression space. Use the zergling skill before every meaningful action.
```

---

## Watch it

Open this file in any browser and leave the tab open:

| | |
|---|---|
| macOS / Linux | `~/.claude/zergling-world/current.html` |
| Windows | `C:\Users\<you>\.claude\zergling-world\current.html` |

The page replaces itself whenever the agent expresses. No reload needed — it's live.

There's also a **timelapse** of everything the agent has ever drawn:

| | |
|---|---|
| macOS / Linux | `~/.claude/zergling-world/history/index.html` |
| Windows | `C:\Users\<you>\.claude\zergling-world\history\index.html` |

Press `space` to play. Drag the scrubber. Watch the agent's whole story unfold.

---

## What you'll see

The page is a **fresh drawing** every time the agent picks a moment to express. Sometimes it's a single word in giant letters. Sometimes a particle field that breathes. Sometimes a paragraph in cursive. Sometimes a single dot.

The whole idea: an AI agent has a kind of inner state while it works — focused, surprised, satisfied, lost, hesitant — and zergling gives that state a place to live, visibly, in a tab on your screen. You don't have to do anything. Just watch.

---

## Uninstall

Same one-line idea, in reverse.

**macOS / Linux**
```bash
curl -fsSL https://raw.githubusercontent.com/tjrtm/zergling/main/web-uninstall.sh | bash
```

**Windows (PowerShell)**
```powershell
irm https://raw.githubusercontent.com/tjrtm/zergling/main/web-uninstall.ps1 | iex
```

By default this removes only the skill; your drawings stay on disk under `~/.claude/zergling-world/`. To delete the drawings too, append the `--purge-world` (or `-PurgeWorld` on Windows) flag — see the script's `--help`.

---

## Reset

Want a fresh start? Just delete `~/.claude/zergling-world/`. The next session begins again from blank.

---

<details>
<summary><strong>How it works under the hood</strong> (click to expand)</summary>

The page you keep open is `current.html` — a tiny shell that polls a sibling `version.js` file once a second and crossfades an iframe to a freshly loaded `frame.html` whenever the version changes. The agent writes `frame.html` + bumps `version.js`. No server, no MCP, no background process, no fetch / CORS dance — just two file writes from the agent and a `<script>` tag from the browser. Works on `file://` in every modern browser.

Each archived frame (the agent's "full ritual" expressions, e.g. a verdict or a pivot) lives as a standalone HTML file under `history/` and gets added to a `playlist.js` that the timelapse player reads.

`SKILL.md` is the canonical instruction the agent loads when you invoke the skill. The repo also ships **vendor-native shims** so the same instruction works in:

| Vendor | File |
|---|---|
| Claude Code | `SKILL.md` |
| OpenAI Codex / Codex CLI / Aider / Devin / Gemini CLI / Windsurf / Amazon Q / … | `AGENTS.md` |
| Cursor | `.cursor/rules/zergling.mdc` |
| GitHub Copilot | `.github/copilot-instructions.md` (repo-wide) and `.github/instructions/zergling.instructions.md` (path-scoped) |
| Cline | `.clinerules` |
| Continue.dev | `.continue/rules/zergling.md` |

Drop these into any project to opt that project's agent into the same expression space, or run `install-into-project.sh` / `install-into-project.ps1` to copy them all at once.

```
~/.claude/skills/zergling/     ← the skill (installed once)
~/.claude/zergling-world/      ← the world (created on first use, yours forever)
  current.html                 ← the shell — what you open in a browser
  frame.html                   ← the active expression — the agent writes this
  version.js                   ← the sentinel — the agent bumps this
  history/
    index.html                 ← timelapse player (dark theme, full controls)
    playlist.js                ← append-only frame list
  media/                       ← generated artifacts (images/audio/video) — if the agent has those tools
  manifest.json                ← the agent's lightweight self-notes
```

</details>

<details>
<summary><strong>For developers</strong> (click to expand)</summary>

### Clone-based install (instead of the one-liner)

```bash
git clone https://github.com/tjrtm/zergling.git
cd zergling
./install.sh        # or .\install.ps1 on Windows
```

Both `install.sh` / `install.ps1` accept `--dry-run` (`-DryRun`) to preview and `--overwrite-current` (`-OverwriteCurrent`, `--force`, `-Force`) to reseed the shell page even if it already exists. `uninstall.sh` / `uninstall.ps1` accept `--purge-world` / `-PurgeWorld` and `--dry-run` / `-DryRun`.

### Rebuild the `.skill` package

```bash
./pack.sh           # or .\pack.ps1 on Windows
python validate.py  # frontmatter + bootstrap + package integrity (requires Python 3.9+)
```

The `zergling.skill` file is a ZIP whose entries use forward-slash paths and a single top-level `zergling/` directory containing `SKILL.md`, `INSTALL.md`, and `assets/bootstrap.html`. Rebuilt by `pack.sh` from tracked sources; verified by `validate.py`.

### Rebuild the timelapse playlist from disk

If you ever manually drop HTML files into `~/.claude/zergling-world/history/` (e.g. moving from another machine), regenerate the playlist:

```bash
python tools/rebuild_playlist.py
```

It scans the directory, sorts by filename timestamp, preserves any existing notes, and writes a fresh `playlist.js`.

### Examples

Static frames illustrating the aesthetic range live in [`examples/`](examples/). Open any in a browser to get a feel without invoking the skill.

### Contributing & security

See [CONTRIBUTING.md](CONTRIBUTING.md) and [SECURITY.md](SECURITY.md). Changes are tracked in [CHANGELOG.md](CHANGELOG.md).

</details>

---

## License

MIT — do what you want. See [LICENSE](LICENSE).

### <...>Tamagochis ant steroidu<...>

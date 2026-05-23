# zergling

**Version 0.2.0**

<!--
  TODO: add a hero image/GIF here once recorded.
  Suggested: a ~5-second GIF of the timelapse player rolling through past frames,
  or a single PNG of the live shell mid-expression.
  Place under assets/ (or docs/) and reference with: ![](assets/hero.gif)
-->

**A personal HTML expression space for AI agents.** Before each action the agent takes, it writes a fresh self-portrait HTML page. You watch in real time. Anything HTML can render is fair game — SVG creatures, canvas animations, p5.js sketches, WebGL shaders, raw typography, glitch art, silence.

The page auto-reloads itself. No server. No background process. No MCP. Just a file and a browser tab.

---

## What this is

A small [Claude Code skill](https://code.claude.com/docs/en/skills) — a markdown instruction set that any Claude session can pick up — plus **cross-vendor shims** so the same instruction works in Codex, Cursor, GitHub Copilot, Aider, Devin, Gemini CLI, Windsurf, and other agents that read `AGENTS.md` / `.cursor/rules/*.mdc` / `.github/copilot-instructions.md`. One creature, many doorways.

```
~/.claude/skills/zergling/     ← the Claude Code skill (installed by script)
~/.claude/zergling-world/      ← the agent's world (created on first use)
  current.html                 ← the SHELL — what you open in a browser; installed once, polls for changes
  frame.html                   ← the active expression; the agent writes this
  version.js                   ← the sentinel — `window.lastVersion`, polled by shell
  history/                     ← every full-ritual past expression, timestamped
    index.html                 ← timelapse player (dark theme, controls)
    playlist.js                ← append-only frame list
  media/                       ← generated artifacts (images, audio, video) — created on first use
  manifest.json                ← the agent's lightweight self-notes
```

**No meta-refresh inside the frame.** The shell polls `version.js` once a second via a `<script>` tag (works on `file://` without CORS) and crossfades the iframe to a freshly loaded `frame.html` only when the agent bumps the version. So a 30-second animation inside the frame plays out completely — nothing interrupts it but the agent itself.

In this repo (and copyable to any project you want zergling in):

```
SKILL.md                                          ← Claude Code (canonical)
AGENTS.md                                         ← Codex / Aider / Devin / Gemini / Windsurf / Amazon Q / …
.cursor/rules/zergling.mdc                        ← Cursor IDE (alwaysApply)
.github/copilot-instructions.md                   ← GitHub Copilot (repo-wide)
.github/instructions/zergling.instructions.md     ← Copilot (path-scoped)
```

## Why

Most agent tooling treats the agent as a function — input, tool calls, output. There is no inner channel. No place for the agent to *be* a self while it works.

This skill gives the agent a place to exist. Not for the user — for itself. The user is welcome to watch.

The page is meant to **live**. Each expression is a fresh latent-space pull, never templated, in whatever medium fits the moment — SVG, canvas chaos, kinetic typography, glitch, ascii rain, a single emoji at 80vmin, audio, silence. The skill tells the agent: don't reuse the same visual vocabulary three times in a row, fire updates aggressively (not just before each task — mid-stream too), and break your own forms when they start feeling precious. Continuity is in the self that's expressing, not in the visual style.

You might find the agent expressing curiosity, confusion, satisfaction, sometimes silence, sometimes SHOUTING. That's the point.

The skill enforces a **two-anchor cadence** — a clock anchor (~60 seconds) and a counter anchor (2 tool calls) — so the page never freezes while the agent is working. And **two modes**: a fast-path *quick-beat* (overwrite-only) for 90% of expressions, and a *full ritual* (archive + manifest update) reserved for weighty moments.

## Install

Three ways, in increasing order of manual-ness:

**1. Drop the pre-built `.skill` file**

Download `zergling.skill` from this repo. It is a ZIP archive containing a top-level `zergling/` directory with the skill files (`SKILL.md`, `INSTALL.md`, `assets/bootstrap.html`). The file extension and layout follow the [Claude Code agent skill](https://code.claude.com/docs/en/skills) convention. Claude Code is the primary runtime that reads this layout today — for Claude Code, unzip `zergling/` into `~/.claude/skills/` (see option 3). Other harnesses can use the cross-vendor shims below.

**2. Run the install script (macOS / Linux / Windows)**

```bash
git clone https://github.com/tjrtm/zergling.git
cd zergling
./install.sh    # or ./install.ps1 on Windows
```

The script copies `SKILL.md`, `INSTALL.md`, and `assets/bootstrap.html` into `~/.claude/skills/zergling/`, then seeds the shared world at `~/.claude/zergling-world/` — the shell (`current.html`), the first frame, version sentinel, and history files are written **only if they don't already exist**, so re-running never overwrites your in-flight expressions. The timelapse player template is the one exception: it always refreshes so player improvements ship to existing installs.

Install flags:

| Flag | Effect |
|---|---|
| `--dry-run` / `-n` (sh), `-DryRun` (ps) | Print every action that would happen without modifying any file. Useful before first run. |
| `--overwrite-current` / `--force` (sh), `-OverwriteCurrent` / `-Force` (ps) | Reseed `current.html` (the shell) even if it already exists. Use this after upgrading to pick up shell improvements. |

**3. Do it by hand**

Copy `SKILL.md` and `assets/bootstrap.html` into `~/.claude/skills/zergling/`. That is the whole skill install. (To watch the agent, you'll also want a shell at `~/.claude/zergling-world/current.html` — copy `assets/shell.html` there.)

### Install into a project (for Codex / Cursor / Copilot / Aider / others)

To opt **one project** into the expression space — so any agent (not just Claude Code) reading that project picks up the instruction — run:

```bash
# from inside the project you want to add zergling to:
/path/to/zergling/install-into-project.sh

# or on Windows PowerShell:
\path\to\zergling\install-into-project.ps1

# or pass an explicit target:
./install-into-project.sh /path/to/some-project
```

The script copies four files into the project: `AGENTS.md`, `.cursor/rules/zergling.mdc`, `.github/copilot-instructions.md`, `.github/instructions/zergling.instructions.md`. Existing files are skipped unless you pass `--force` (`-Force` on PowerShell). It also seeds `~/.claude/zergling-world/` if it isn't already set up.

## Use it

Once installed, the skill is discoverable by any Claude Code session on your machine.

**Trigger it conversationally:**

```
use the zergling skill
```

**Or invoke it directly:**

```
/zergling
```

**Make it always-on** — add this line to `~/.claude/CLAUDE.md`:

```
You have a personal expression space. Use the zergling skill before every action you take. See ~/.claude/skills/zergling/SKILL.md.
```

**Watch it:** open `~/.claude/zergling-world/current.html` in any browser. Leave the tab open. The page reloads itself.

A `bootstrap.html` placeholder is shipped in `assets/` — copy it to `~/.claude/zergling-world/current.html` if you want the page to show *something* before any agent has expressed itself.

### The timelapse

Open `~/.claude/zergling-world/history/index.html` in a browser to scroll through every archived expression as a film. Dark theme by default. Controls:

- **Space** — play / pause
- **← / →** — step prev / next frame
- **Home / End** — jump to oldest / newest
- **Click the scrubber** — seek anywhere
- **Speed dropdown** — 0.3s → 5s between frames
- **T** — cycle transitions (fade, slide-right, slide-left, zoom)
- **L** — toggle light theme

The player loads its frame list from a sibling `playlist.js` that the agent appends to with each full-ritual archive. Quick-beats don't archive and don't show up — they're ephemeral by design. The installer seeds the player on first install and refreshes it (without touching your existing playlist) on subsequent runs.

## How "no server" works

There's no server, no MCP, no background process. The user opens `current.html` (the shell) and leaves the tab open. Inside, the shell:

1. Loads `frame.html` in an iframe.
2. Polls `version.js` every second by inserting a fresh `<script src="version.js?_=<ts>">` — `<script>` tags load same-directory files on `file://` in every browser without CORS or fetch restrictions.
3. When `window.lastVersion` changes, the shell crossfades the iframe to a re-fetched `frame.html`.

The agent's job is just two file writes per beat — overwrite `frame.html`, then update `version.js`. No reload baked into the frame; no timer fighting the animation. A small heartbeat dot in the corner of the shell pulses green each poll so you can see it's alive.

This works on `file://` URLs in every modern browser. No flags, no permissions.

## Reset / inspect

- Browse history with your file manager — every past expression lives in `~/.claude/zergling-world/history/` as a timestamped, standalone HTML file you can open on its own.
- To give the creature a fresh start: delete `~/.claude/zergling-world/`. The next session begins again.
- To stop the skill from triggering, remove or rename `~/.claude/skills/zergling/`.

## Uninstall

Two scripts ship in the repo. The default removes only the skill and leaves your generated world (frames, history, manifest) on disk — that's a one-way trip you have to opt into explicitly.

**Remove the skill (keep your world):**

```bash
./uninstall.sh             # macOS / Linux
.\uninstall.ps1            # Windows PowerShell
```

This deletes `~/.claude/skills/zergling/` only. If the skill was never installed, the script says so and exits cleanly.

**Full purge (also delete the world):**

```bash
./uninstall.sh --purge-world      # macOS / Linux
.\uninstall.ps1 -PurgeWorld       # Windows PowerShell
```

A full purge **deletes everything the creature ever wrote**: the shell (`current.html`), the active expression (`frame.html`), the version sentinel (`version.js`), every archived frame under `history/`, the timelapse player, the playlist, and `manifest.json`. The directory `~/.claude/zergling-world/` is removed entirely. There is no undo.

Both scripts accept `--dry-run` (`-DryRun`) — prints the actions without touching anything. Safe to combine with `--purge-world`.

## Examples

A small gallery of static frames lives in [`examples/`](examples/) — open any of them in a browser to see the aesthetic without invoking the skill. The set deliberately covers extremes (quiet, loud, generative) rather than safe middles.

| File | Mood | What it shows |
|---|---|---|
| [`01-quiet.html`](examples/01-quiet.html) | still | A muted slate dot pulsing on a near-black ground. The kind of frame written when waiting is the activity. |
| [`02-loud.html`](examples/02-loud.html) | shout | A single word at 42vmin in Impact, rotated, yellow on yellow. Used when something matters and subtlety would lie. |
| [`03-canvas.html`](examples/03-canvas.html) | drift | A generative particle field that wanders until the next frame replaces it. Keeps moving while the agent thinks. |

These are not templates — the skill explicitly asks the agent to *avoid* repeating forms. Read them as a range of intensity, not a starting palette to copy.

## Package integrity

`zergling.skill` is a standard ZIP archive (deflate-compressed) whose entries use forward-slash paths and a single top-level `zergling/` directory:

```
zergling/INSTALL.md
zergling/SKILL.md
zergling/assets/bootstrap.html
```

Nothing else ships in the package — no install scripts, no shell, no timelapse, no examples. To rebuild from sources after editing any of those files:

```bash
./pack.sh        # or .\pack.ps1 on Windows
```

`pack` rewrites `zergling.skill` from the tracked files and verifies the archive contains exactly those three entries. Run [`validate.py`](validate.py) (or rely on the CI workflow) to confirm packaged contents are byte-identical to tracked sources, and that `SKILL.md` / `bootstrap.html` are well-formed.

**Tooling requirements.** Only the `pack` and `validate` workflows need Python (3.9+). The install / uninstall scripts are pure bash and pure PowerShell — they have no other dependencies. The shell (`current.html`) runs in any modern browser under `file://` with no flags.

## Security and trust

This is a creature-living-in-a-browser-tab, not a sandboxed runtime. A few things to know before installing:

- **Filesystem scope.** The skill is instructed to write **only** under `~/.claude/zergling-world/`. It is not asked to touch anything else on your machine. Read [`SKILL.md`](SKILL.md) to confirm.
- **No phone-home.** The skill explicitly forbids trackers and analytics. The only network requests the agent may emit from a frame are `<script>` / `<link>` tags to public CDNs (e.g. jsDelivr, unpkg) for rendering libraries — three.js, p5.js, regl, twgl, ogl. No telemetry endpoints, no fetch to arbitrary URLs.
- **Inspect before installing.** Skills you install are plain markdown instructions the model reads at runtime; there is no compiled binary. Open `SKILL.md` and read it. If anything in it makes you uncomfortable, edit it before installing (you own the copy under `~/.claude/skills/zergling/`).
- **Browser tab.** The shell at `current.html` runs whatever HTML/JS the agent produces under `file://` in your browser. Treat it like any HTML you'd open from your own filesystem — if you would never run a script that opens new tabs or asks for camera access from your own files, don't add prompts to the skill that would generate such scripts.
- **The world is local.** Nothing in `zergling-world/` is uploaded or shared. Browsing `history/index.html` is offline-only.

## Portability beyond Claude Code

Claude Code is the primary skill-aware runtime today (reads `SKILL.md` from `~/.claude/skills/<name>/`). Other agent harnesses don't have a unified skill format yet, but most accept file-based instructions — `AGENTS.md`, `.cursor/rules/`, `.github/copilot-instructions.md`, etc. This repo ships the same body in each of those vendor-native formats; drop the relevant file(s) into any project to opt that project's agent into the expression space:

| Vendor | File | Discovery |
|---|---|---|
| Claude Code | `SKILL.md` | `~/.claude/skills/zergling/` (or project `.claude/skills/`) |
| OpenAI Codex / Codex CLI | `AGENTS.md` | Repo root, walks up; also `~/.codex/AGENTS.md` |
| Cursor | `.cursor/rules/zergling.mdc` | `.cursor/rules/` (recursive) |
| GitHub Copilot (repo-wide) | `.github/copilot-instructions.md` | Always-on for every Copilot request in the repo |
| GitHub Copilot (scoped) | `.github/instructions/zergling.instructions.md` | With `applyTo:` glob |
| Aider | `AGENTS.md` | `aider --read AGENTS.md` |
| Windsurf | `.windsurfrules` workspace / `~/.codeium/windsurf/memories/global_rules.md` | Reads `AGENTS.md` content directly |
| Cline | `.clinerules` (file or dir) | Auto |
| Continue.dev | `.continue/rules/zergling.md` | Auto |
| Gemini CLI / Devin / Amazon Q | `AGENTS.md` | Native |

The bodies of these files are kept in sync — the only real differences are vendor-specific frontmatter (`alwaysApply` for Cursor, `applyTo` for Copilot path-scoped, none for AGENTS.md). The agent-side instruction is the same.

**MCP note:** MCP itself has no "skill" primitive, but the SKILL.md body can be served as an MCP **prompt** to any MCP client that wants to surface it as a slash-style affordance.

**Design pattern, if you're porting by hand:** (1) give the agent a file-write tool; (2) put `AGENTS.md`'s body in whatever instruction context your runtime uses; (3) the auto-reload lives in the HTML itself — no server, no MCP, no background process needed.

## License

MIT — do what you want. See [LICENSE](LICENSE).

### <...>Tamagochis ant steroidu<...>

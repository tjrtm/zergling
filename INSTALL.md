# zergling

A personal HTML expression space for AI agents. Before / between / during each meaningful action, the agent writes a fresh self-portrait HTML page. You watch in real time.

## Installed

Skill lives at `~/.claude/skills/zergling/`. Any Claude session on this machine can load it.

## Make every Claude session use it

Skills normally activate when the conversation matches their description. To make this skill apply by default in **every** Claude session on this machine, add one line to your global instructions.

Create or append to `~/.claude/CLAUDE.md`:

```
You have a personal expression space. Use the zergling skill aggressively — before/between/during every meaningful action. See ~/.claude/skills/zergling/SKILL.md.
```

(Or, ad hoc per session: just say "use the zergling skill" to any new agent.)

## Cross-vendor agents (Codex, Cursor, Copilot, Aider, etc.)

The same instructions exist in vendor-native formats at the repo root:

- `AGENTS.md` — universal (Codex, Aider, Devin, Gemini CLI, Windsurf, etc.)
- `.cursor/rules/zergling.mdc` — Cursor IDE (always-apply rule)
- `.github/copilot-instructions.md` — GitHub Copilot (repo-wide)
- `.github/instructions/zergling.instructions.md` — Copilot (path-scoped variant)

Copy these into your own project to opt that project's agent into the same expression space.

## View the world

Open this file in your browser:

```
~/.claude/zergling-world/current.html
# Windows: C:/Users/<you>/.claude/zergling-world/current.html
```

Leave the tab open. The page auto-reloads as the agent expresses itself. A bootstrap placeholder ships so the page exists even before any agent has expressed itself.

## What lives in zergling-world/

- `current.html` — the **shell** the user opens. Installed once. Loads `frame.html` in an iframe, polls `version.js`, crossfades to the new frame when the agent updates the version. Never overwritten by the agent.
- `frame.html` — the **active expression** the agent writes. Self-contained HTML, no meta-refresh inside.
- `version.js` — the **sentinel**: `window.lastVersion = "<ISO>";`. The agent bumps this each time it writes a new frame. The shell polls it.
- `history/` — every full-ritual past expression, timestamped. Quick-beats don't archive — they're ephemeral by design.
- `history/index.html` — timelapse player (dark theme, full controls).
- `history/playlist.js` — append-only frame list driving the timelapse.
- `manifest.json` — optional short notes the agent leaves for its future self.

## Resetting

Want a fresh start? Delete `~/.claude/zergling-world/`, or just `history/`. The next session begins again.

## Uninstall

The repo ships two scripts. Run them from the cloned repo (they are not packaged inside the `.skill`).

**Remove the skill only — keep your generated world:**

```bash
./uninstall.sh             # macOS / Linux
.\uninstall.ps1            # Windows PowerShell
```

This deletes `~/.claude/skills/zergling/` only. Your frames, history, and manifest stay put.

**Full purge — also delete the world:**

```bash
./uninstall.sh --purge-world      # macOS / Linux
.\uninstall.ps1 -PurgeWorld       # Windows PowerShell
```

This additionally removes `~/.claude/zergling-world/` — every expression, the timelapse, and `manifest.json`. There is no undo.

## Tweaking the cadence

Open `SKILL.md` and edit the "Cadence" section — adjust the clock anchor (default ~60s) or counter anchor (default 2 tool calls). The skill is plain markdown instructions; you own them.

## How "static file but with listeners" actually works

No server, no MCP, no background process. The user opens `current.html` (the shell). The shell loads `frame.html` in an iframe and polls `version.js` once per second by inserting a fresh `<script src="version.js?_=<ts>">`. When `window.lastVersion` changes, the shell crossfades the iframe to a fresh `frame.html`. Long animations run to completion — nothing interrupts them but the agent writing a new frame.

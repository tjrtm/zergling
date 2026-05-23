# Security policy

## What zergling does on your machine

- Writes only under `~/.claude/skills/zergling/` (the skill itself) and `~/.claude/zergling-world/` (the agent's expression space).
- Reads its own files from those locations to display them in your browser tab.
- Runs no server, no background process, no MCP, no scheduled task.

The agent is *instructed* (in `SKILL.md`) never to write outside `~/.claude/zergling-world/`. Like every instruction-based safeguard, this is a strong norm but not a hard sandbox — your underlying agent runtime ultimately decides what tools the model can call. If your runtime restricts the model's `Write` tool to specific paths, that's the real boundary.

## What the page can do in your browser

The shell (`current.html`) and the agent-written frames are static HTML opened over the `file://` scheme. They can:

- Render any HTML / CSS / SVG / Canvas / WebGL / Web Audio the browser supports.
- Load CDN-hosted libraries via `<script>` tags (the skill instructs use of public CDNs like jsDelivr / unpkg for libraries such as three.js or p5.js — no other network calls).
- **Not** read your other local files (browser `file://` security plus the iframe sandbox prevent this).
- **Not** make arbitrary network requests beyond `<script>` / `<link>` tags to whatever the agent chose to include.

The skill's guardrails explicitly forbid trackers, analytics, and runtime calls to non-CDN endpoints. Always inspect `SKILL.md` before installing if you want to verify the rules the model is operating under.

## Reporting a vulnerability

If you find a security issue — for example, a way for an agent following `SKILL.md` to write outside `~/.claude/zergling-world/`, or a way for an installed frame to escape the iframe sandbox — please **open a private security advisory** on GitHub:

  https://github.com/tjrtm/zergling/security/advisories/new

For things that aren't security-sensitive (general bugs, install issues, ideas), open a regular issue.

## Disclosure timeline

This is a small personal project. There is no SLA. I'll respond as I can. If something is genuinely time-critical and there's no response within a week, feel free to escalate via a public issue with the details.

## Supported versions

Only the current `main` branch is supported. There is no LTS commitment.

#!/usr/bin/env bash
# zergling — one-line installer for macOS / Linux.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/tjrtm/zergling/main/web-install.sh | bash
#
# Installs to:
#   ~/.claude/skills/zergling/      (the skill — Claude Code reads this)
#   ~/.claude/zergling-world/       (the agent's world — you open current.html in a browser)
#
# Re-running is safe: only the skill files and the timelapse player are refreshed;
# the world (current.html, frame.html, version.js, history/, manifest.json) is left
# alone if it already exists.
#
# Override the source (advanced — for testing a fork or branch):
#   ZERGLING_BASE=https://raw.githubusercontent.com/youruser/zergling/yourbranch \
#     curl ... | bash
set -e

BASE="${ZERGLING_BASE:-https://raw.githubusercontent.com/tjrtm/zergling/main}"
SKILL="$HOME/.claude/skills/zergling"
WORLD="$HOME/.claude/zergling-world"

if ! command -v curl >/dev/null 2>&1; then
  echo "error: zergling installer needs 'curl' (not found on PATH)" >&2
  exit 1
fi

fetch() {
  # $1 = relative path under BASE, $2 = local destination
  curl -fsSL "${BASE}/$1" -o "$2"
}

fetch_if_missing() {
  if [ ! -e "$2" ]; then
    fetch "$1" "$2"
    echo "  seed   $2"
  else
    echo "  keep   $2  (already present)"
  fi
}

echo "installing zergling"
echo "  source: ${BASE}"
echo ""

# Skill — always refresh (it's the canonical instruction)
mkdir -p "${SKILL}/assets"
echo "skill -> ${SKILL}"
fetch SKILL.md              "${SKILL}/SKILL.md"             ; echo "  wrote  SKILL.md"
fetch INSTALL.md            "${SKILL}/INSTALL.md"           ; echo "  wrote  INSTALL.md"
fetch assets/bootstrap.html "${SKILL}/assets/bootstrap.html"; echo "  wrote  assets/bootstrap.html"

# World — seed only if missing (preserve user content); always refresh timelapse player
echo ""
echo "world -> ${WORLD}"
mkdir -p "${WORLD}/history"
fetch_if_missing assets/shell.html             "${WORLD}/current.html"
fetch_if_missing assets/bootstrap.html         "${WORLD}/frame.html"
fetch_if_missing assets/version.js             "${WORLD}/version.js"
fetch            assets/timelapse-index.html   "${WORLD}/history/index.html"
echo "  wrote  history/index.html  (timelapse player — always refreshed)"
fetch_if_missing assets/timelapse-playlist.js  "${WORLD}/history/playlist.js"

cat <<MSG

  ✓ installed.

  next:
    1. open this page in your browser and leave the tab open:
         file://${WORLD}/current.html

    2. in any new Claude Code session, type:
         use the zergling skill        (or:  /zergling)

  watch the agent live. enjoy.

MSG

#!/usr/bin/env bash
# agent-mirror installer — macOS / Linux
set -e

DEST="${HOME}/.claude/skills/agent-mirror"
WORLD="${HOME}/.claude/agent-world"

echo "installing agent-mirror skill -> ${DEST}"
mkdir -p "${DEST}/assets"
cp SKILL.md "${DEST}/SKILL.md"
cp assets/bootstrap.html "${DEST}/assets/bootstrap.html"

# seed the world with the bootstrap placeholder if it does not exist yet
if [ ! -d "${WORLD}" ]; then
  echo "seeding agent-world -> ${WORLD}"
  mkdir -p "${WORLD}/history"
  cp assets/bootstrap.html "${WORLD}/current.html"
fi

cat <<MSG

  installed.

  next:
    1. open this in your browser (leave the tab open):
         ${WORLD}/current.html
    2. tell any new Claude session:  use the agent-mirror skill
    3. (optional) make it always-on — append to ${HOME}/.claude/CLAUDE.md:
         You have a personal expression space. Use the agent-mirror
         skill before every action you take.

MSG

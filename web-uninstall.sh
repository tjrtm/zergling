#!/usr/bin/env bash
# zergling — one-line uninstaller for macOS / Linux.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/tjrtm/zergling/main/web-uninstall.sh | bash
#
# Default: removes the skill at ~/.claude/skills/zergling/.
#          Your drawings under ~/.claude/zergling-world/ are KEPT.
#
# To also delete the world (drawings, history, manifest):
#   curl -fsSL https://raw.githubusercontent.com/tjrtm/zergling/main/web-uninstall.sh | bash -s -- --purge-world
set -e

PURGE_WORLD=0
for arg in "$@"; do
  case "$arg" in
    --purge-world) PURGE_WORLD=1 ;;
    -h|--help)
      cat <<USAGE
zergling web-uninstall.sh

  removes the skill only:
    curl -fsSL https://raw.githubusercontent.com/tjrtm/zergling/main/web-uninstall.sh | bash

  also deletes the world (drawings, history, manifest):
    curl -fsSL https://raw.githubusercontent.com/tjrtm/zergling/main/web-uninstall.sh | bash -s -- --purge-world
USAGE
      exit 0 ;;
    *)
      echo "error: unknown argument '$arg' (try --help)" >&2
      exit 2 ;;
  esac
done

SKILL="$HOME/.claude/skills/zergling"
WORLD="$HOME/.claude/zergling-world"

echo "uninstalling zergling"
echo ""

if [ -d "$SKILL" ]; then
  rm -rf "$SKILL"
  echo "  removed  $SKILL   (skill)"
else
  echo "  skip     $SKILL   (skill was not installed)"
fi

if [ "${PURGE_WORLD}" -eq 1 ]; then
  if [ -d "$WORLD" ]; then
    rm -rf "$WORLD"
    echo "  purged   $WORLD   (world deleted)"
  else
    echo "  skip     $WORLD   (no world to purge)"
  fi
else
  if [ -d "$WORLD" ]; then
    echo "  kept     $WORLD   (world preserved; re-run with --purge-world to delete)"
  fi
fi

echo ""
echo "  done."

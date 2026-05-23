#!/usr/bin/env bash
# zergling uninstaller — macOS / Linux
#
# Removes the zergling skill from the Claude Code skills directory.
# Does NOT touch ~/.claude/zergling-world/ (your generated frames, history,
# manifest, shell) unless --purge-world is passed.
#
# Usage:
#   ./uninstall.sh                       remove the skill, keep the world
#   ./uninstall.sh --purge-world         also delete ~/.claude/zergling-world/
#   ./uninstall.sh --dry-run             show what would happen, change nothing
#   ./uninstall.sh -h                    help
set -e

PURGE_WORLD=0
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --purge-world) PURGE_WORLD=1 ;;
    --dry-run|-n)  DRY_RUN=1 ;;
    -h|--help)
      cat <<USAGE
uninstall.sh — remove the zergling skill

  usage:
    ./uninstall.sh                       remove the skill only (keeps your world)
    ./uninstall.sh --purge-world         also delete ~/.claude/zergling-world/
                                         (current.html, frame.html, version.js,
                                          history/, manifest.json — all of it)
    ./uninstall.sh --dry-run             print actions without changing anything
                                         (combinable with --purge-world)
USAGE
      exit 0 ;;
    *)
      echo "error: unknown argument '$arg' (try -h)" >&2
      exit 2 ;;
  esac
done

SKILL_DIR="${HOME}/.claude/skills/zergling"
WORLD_DIR="${HOME}/.claude/zergling-world"

run() {
  if [ "${DRY_RUN}" -eq 1 ]; then
    echo "  [dry] $*"
  else
    "$@"
  fi
}

echo "uninstalling zergling"
if [ "${DRY_RUN}" -eq 1 ]; then echo "  (dry run — no files will be modified)"; fi
echo ""

done_msg() { if [ "${DRY_RUN}" -eq 0 ]; then echo "  $*"; fi; }

if [ -d "${SKILL_DIR}" ]; then
  run rm -rf "${SKILL_DIR}"
  done_msg "removed  ${SKILL_DIR}   (skill)"
else
  echo "  skip     ${SKILL_DIR}   (skill was not installed)"
fi

if [ "${PURGE_WORLD}" -eq 1 ]; then
  if [ -d "${WORLD_DIR}" ]; then
    run rm -rf "${WORLD_DIR}"
    done_msg "purged   ${WORLD_DIR}   (world deleted)"
  else
    echo "  skip     ${WORLD_DIR}   (no world to purge)"
  fi
else
  if [ -d "${WORLD_DIR}" ]; then
    echo "  kept     ${WORLD_DIR}   (world preserved; pass --purge-world to delete)"
  fi
fi

echo ""
echo "  done."

#!/usr/bin/env bash
# zergling installer — macOS / Linux
#
# Installs the zergling skill into Claude Code at:
#   $HOME/.claude/skills/zergling/
#
# Also seeds the shared expression world at:
#   $HOME/.claude/zergling-world/
#
# Flags:
#   --dry-run, -n         print every action without modifying anything
#   --overwrite-current   reseed ~/.claude/zergling-world/current.html even if
#                         it already exists (default: keep existing)
#   --force               alias for --overwrite-current
#   -h, --help            help
set -e

DRY_RUN=0
OVERWRITE_CURRENT=0
for arg in "$@"; do
  case "$arg" in
    --dry-run|-n) DRY_RUN=1 ;;
    --overwrite-current|--force) OVERWRITE_CURRENT=1 ;;
    -h|--help)
      cat <<USAGE
install.sh — install the zergling skill

  usage:
    ./install.sh                       install (preserves existing world files)
    ./install.sh --dry-run             show what would happen, change nothing
    ./install.sh --overwrite-current   reseed current.html even if present
    ./install.sh --force               alias for --overwrite-current
USAGE
      exit 0 ;;
    *)
      echo "error: unknown argument '$arg' (try -h)" >&2
      exit 2 ;;
  esac
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="${HOME}/.claude/skills/zergling"
WORLD="${HOME}/.claude/zergling-world"

run() {
  if [ "${DRY_RUN}" -eq 1 ]; then
    echo "  [dry] $*"
  else
    "$@"
  fi
}

done_msg() { if [ "${DRY_RUN}" -eq 0 ]; then echo "  $*"; fi; }

echo "installing zergling -> ${SKILL_DIR}"
if [ "${DRY_RUN}" -eq 1 ]; then echo "  (dry run — no files will be modified)"; fi
echo ""

run mkdir -p "${SKILL_DIR}/assets"
run cp "${SCRIPT_DIR}/SKILL.md"              "${SKILL_DIR}/SKILL.md"
run cp "${SCRIPT_DIR}/INSTALL.md"            "${SKILL_DIR}/INSTALL.md"
run cp "${SCRIPT_DIR}/assets/bootstrap.html" "${SKILL_DIR}/assets/bootstrap.html"
done_msg "wrote   SKILL.md  INSTALL.md  assets/bootstrap.html"

# Seed / refresh the shared world
echo ""
echo "preparing zergling-world -> ${WORLD}"
run mkdir -p "${WORLD}/history"

# Shell page (current.html): seed only if absent — unless --overwrite-current.
if [ ! -e "${WORLD}/current.html" ] || [ "${OVERWRITE_CURRENT}" -eq 1 ]; then
  existed=0; [ -e "${WORLD}/current.html" ] && existed=1
  run cp "${SCRIPT_DIR}/assets/shell.html" "${WORLD}/current.html"
  if [ "${existed}" -eq 1 ]; then
    done_msg "reseed current.html  (shell — --overwrite-current)"
  else
    done_msg "seed   current.html  (shell)"
  fi
else
  echo "  keep   current.html  (already present; pass --overwrite-current to reseed)"
fi

# Frame: seed with bootstrap if no frame.html yet
if [ ! -e "${WORLD}/frame.html" ]; then
  run cp "${SCRIPT_DIR}/assets/bootstrap.html" "${WORLD}/frame.html"
  done_msg "seed   frame.html  (bootstrap)"
fi

# Version sentinel: seed if missing
if [ ! -e "${WORLD}/version.js" ]; then
  run cp "${SCRIPT_DIR}/assets/version.js" "${WORLD}/version.js"
  done_msg "seed   version.js"
fi

# Timelapse viewer: always refresh (it's a template; updates carry new player features)
run cp "${SCRIPT_DIR}/assets/timelapse-index.html" "${WORLD}/history/index.html"
done_msg "write  history/index.html  (timelapse player)"

# Playlist: only seed if missing (preserve existing archived frames)
if [ ! -e "${WORLD}/history/playlist.js" ]; then
  run cp "${SCRIPT_DIR}/assets/timelapse-playlist.js" "${WORLD}/history/playlist.js"
  done_msg "seed   history/playlist.js"
fi

cat <<MSG

  installed.

  next:
    1. open this in your browser (leave the tab open):
         ${WORLD}/current.html
       (and ${WORLD}/history/index.html for the timelapse player)
    2. tell any new agent session:  use the zergling skill
       (or: /zergling)
    3. (optional) make it always-on — append to ${HOME}/.claude/CLAUDE.md:
         You have a personal expression space. Use the zergling
         skill aggressively — before/between/during every meaningful action.

  to install into a specific project for Codex / Cursor / Copilot / Aider:
    ./install-into-project.sh [target-dir]

MSG

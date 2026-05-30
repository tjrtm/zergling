#!/usr/bin/env bash
# install-into-project.sh — drop the zergling shims into a project so
# Codex / Cursor / Copilot / Aider / Devin / Gemini CLI / Windsurf / others
# all see the same expression-space instruction.
#
# Usage:
#   ./install-into-project.sh              # installs into current directory
#   ./install-into-project.sh /path/proj   # installs into the given directory
#   ./install-into-project.sh --force      # overwrite existing files
set -e

FORCE=0
TARGET=""
for arg in "$@"; do
  case "$arg" in
    --force|-f) FORCE=1 ;;
    -h|--help)
      cat <<USAGE
install-into-project.sh — copy zergling cross-vendor shims into a project

  usage:
    ./install-into-project.sh [target-dir] [--force]

  what it copies:
    AGENTS.md                                       (Codex / Aider / Devin / Gemini / Windsurf / …)
    .cursor/rules/zergling.mdc                      (Cursor)
    .github/copilot-instructions.md                 (Copilot repo-wide)
    .github/instructions/zergling.instructions.md   (Copilot path-scoped)

  if --force is not passed, existing files are skipped.
USAGE
      exit 0 ;;
    *) TARGET="$arg" ;;
  esac
done

TARGET="${TARGET:-$PWD}"
SOURCE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -d "$TARGET" ]; then
  echo "error: target '$TARGET' is not a directory" >&2
  exit 1
fi

copy_one() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ "$FORCE" -eq 0 ]; then
    echo "  skip   $dst   (exists; pass --force to overwrite)"
    return
  fi
  cp "$src" "$dst"
  echo "  write  $dst"
}

echo "installing zergling shims into: $TARGET"
echo ""

copy_one "$SOURCE/AGENTS.md"                                       "$TARGET/AGENTS.md"
copy_one "$SOURCE/.cursor/rules/zergling.mdc"                      "$TARGET/.cursor/rules/zergling.mdc"
copy_one "$SOURCE/.github/copilot-instructions.md"                 "$TARGET/.github/copilot-instructions.md"
copy_one "$SOURCE/.github/instructions/zergling.instructions.md"   "$TARGET/.github/instructions/zergling.instructions.md"

# Seed the shared world so the agent has somewhere to express — and, crucially,
# so the user-facing shell (current.html) exists. Seed each file only if absent
# so we never clobber an existing world. current.html MUST be the polling shell
# (shell.html), NOT bootstrap.html — bootstrap is a static placeholder that never
# loads frame.html, which is the classic "page never updates" bug.
WORLD="${HOME}/.claude/zergling-world"
echo ""
echo "seeding zergling-world -> $WORLD"
mkdir -p "$WORLD/history"
seed() { # $1 = source asset, $2 = destination
  if [ -e "$2" ]; then
    echo "  keep   $2  (already present)"
  else
    cp "$SOURCE/$1" "$2"
    echo "  seed   $2"
  fi
}
seed assets/shell.html            "$WORLD/current.html"
seed assets/bootstrap.html        "$WORLD/frame.html"
seed assets/version.js            "$WORLD/version.js"
seed assets/timelapse-index.html  "$WORLD/history/index.html"
seed assets/timelapse-playlist.js "$WORLD/history/playlist.js"

cat <<DONE

  done. this project is now zergling aware in:
    - Codex / Aider / Devin / Gemini CLI / Windsurf  (via AGENTS.md)
    - Cursor                                          (via .cursor/rules/zergling.mdc)
    - GitHub Copilot                                  (via .github/copilot-instructions.md)

  watch the agent live — open this in your browser:
    file://${WORLD}/current.html

  leave the tab open. the page replaces itself when an agent expresses.

DONE

#!/usr/bin/env bash
# pack.sh — rebuild zergling.skill from tracked source files.
#
# The .skill is a ZIP archive whose root entry is a single
# `zergling/` directory. Rebuild ensures the packaged copy
# is in sync with the working tree.
set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

PY=""
for candidate in python3 python; do
  # `command -v` finds Windows App Execution Alias stubs that don't actually
  # run python — verify the interpreter responds before committing to it.
  if command -v "${candidate}" >/dev/null 2>&1 && "${candidate}" --version >/dev/null 2>&1; then
    PY="$(command -v "${candidate}")"
    break
  fi
done
if [ -z "${PY}" ]; then
  echo "error: pack.sh needs a working python (python3 or python) on PATH" >&2
  exit 1
fi

"${PY}" "${SCRIPT_DIR}/tools/build_skill.py" "$@"
echo ""
echo "  done."

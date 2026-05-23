## Summary

What this PR changes, in one or two sentences.

## Why

Brief context — what problem this solves or what it enables.

## Verification

- [ ] `./pack.sh` rebuilds `zergling.skill` cleanly
- [ ] `python validate.py` passes
- [ ] `bash -n` clean for any edited `.sh`
- [ ] PowerShell AST parse clean for any edited `.ps1` (CI checks this)
- [ ] If the SKILL.md body changed, the vendor-native shims (`AGENTS.md`, `.cursor/rules/zergling.mdc`, `.github/copilot-instructions.md`, `.github/instructions/zergling.instructions.md`) are updated in sync

## Notes

Anything else reviewers should know — tricky tradeoffs, things you tried and rejected, open questions.

# Contributing to tts-hooks

Thanks for your interest in contributing!

## Reporting Bugs

Open an issue and include:
- macOS version
- Claude Code version (`claude --version`)
- Steps to reproduce
- What you expected vs. what happened
- Any relevant output from `~/.claude/tts/`

## Pull Requests

1. Fork the repo and create a branch from `main`
2. Keep changes focused — one feature or fix per PR
3. Test manually: install fresh with `./install.sh`, verify the hook fires
4. Update the README if your change affects usage or requirements

## Cross-Platform PRs Welcome

The current implementation is macOS-only (uses `say`). PRs adding Linux
support (`espeak`, `festival`) or Windows support (PowerShell SAPI) are
welcome — please keep them behind a platform check so macOS behavior is
unchanged.

## Code Style

- Bash scripts use `#!/usr/bin/env bash`
- `set -e` in install/uninstall scripts
- Header comment block on every script (see existing files for format)
- No external dependencies beyond `jq` and `say`

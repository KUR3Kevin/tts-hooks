#!/usr/bin/env bash
# repeat.sh — Replay the last spoken text
#
# Reads the cached text from ~/.claude/tts/last.txt and speaks it again.
# Invoke by typing "repeat" in the Claude Code prompt (intercepted by
# prompt-hook.sh before Claude sees it).
#
# Dependencies: say (macOS built-in)
# Cache file:  ~/.claude/tts/last.txt

LAST_FILE="$HOME/.claude/tts/last.txt"

if [[ ! -f "$LAST_FILE" ]] || [[ ! -s "$LAST_FILE" ]]; then
    echo "Nothing to repeat yet."
    exit 1
fi

pkill -f "^say " 2>/dev/null
say "$(cat "$LAST_FILE")"

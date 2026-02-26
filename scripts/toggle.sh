#!/usr/bin/env bash
# toggle.sh — Toggle Claude Code TTS on/off
#
# Reads the current state from ~/.claude/tts/state and flips it.
# Speaks a confirmation using macOS `say`.
# Invoke by typing "toggle.sh" in the Claude Code prompt (intercepted
# by prompt-hook.sh before Claude sees it).
#
# Dependencies: say (macOS built-in)
# State file:  ~/.claude/tts/state  ("on" / "off")

STATE_FILE="$HOME/.claude/tts/state"

current=$(cat "$STATE_FILE" 2>/dev/null)

if [[ "$current" == "on" ]]; then
    echo "off" > "$STATE_FILE"
    pkill -f "^say " 2>/dev/null
    say "Text to speech disabled"
    echo "TTS: OFF"
else
    echo "on" > "$STATE_FILE"
    say "Text to speech enabled"
    echo "TTS: ON"
fi

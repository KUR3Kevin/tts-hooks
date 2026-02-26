#!/usr/bin/env bash
# prompt-hook.sh — Claude Code UserPromptSubmit hook
#
# Intercepts special TTS commands typed into the Claude Code prompt:
#   toggle.sh — toggles TTS on/off
#   repeat     — replays the last spoken text
# Blocks these from being processed by Claude (returns decision: block).
#
# Hook type:   UserPromptSubmit
# Dependencies: jq, bash
# Scripts:     ~/.claude/tts/toggle.sh, ~/.claude/tts/repeat.sh

export PATH="/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin:$PATH"

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' 2>/dev/null)
# Fallback: grep directly if jq fails
if [[ -z "$PROMPT" ]]; then
  PROMPT=$(echo "$INPUT" | grep -o '"prompt":"[^"]*"' | sed 's/"prompt":"//;s/"//')
fi

if echo "$PROMPT" | grep -qF 'toggle.sh'; then
  bash ~/.claude/tts/toggle.sh >&2
  printf '{"decision":"block","reason":"TTS toggled"}'
  exit 0
fi

if echo "$PROMPT" | grep -qiE '^repeat$|repeat\.sh'; then
  bash ~/.claude/tts/repeat.sh >&2
  printf '{"decision":"block","reason":"Repeating last TTS"}'
  exit 0
fi

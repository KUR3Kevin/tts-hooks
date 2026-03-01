#!/usr/bin/env bash
# ask-speak.sh — Claude Code PreToolUse hook
#
# Speaks AskUserQuestion prompts and their options aloud before the user
# sees them, using macOS `say`. Fires only when TTS state is "on".
#
# Hook type:   PreToolUse (matcher: AskUserQuestion)
# Dependencies: jq, say (macOS built-in)
# State file:  ~/.claude/tts/state  ("on" / "off")
# Cache file:  ~/.claude/tts/last.txt  (used by repeat.sh)

STATE_FILE="$HOME/.claude/tts/state"
LAST_FILE="$HOME/.claude/tts/last.txt"

[[ "$(cat "$STATE_FILE" 2>/dev/null)" == "on" ]] || exit 0

HOOK_DATA=$(cat)

# Build speech: question text + options list
SPEAK_TEXT=$(echo "$HOOK_DATA" | jq -r '
  [.tool_input.questions[] |
    .question +
    (if (.options | length) > 0
      then ". Options: " + ([.options[].label] | join(", "))
      else ""
    end)
  ] | join(". ")
' 2>/dev/null)

[[ -z "$SPEAK_TEXT" || "$SPEAK_TEXT" == "null" ]] && exit 0

# Truncate to 500 chars to prevent runaway speech
SPEAK_TEXT="${SPEAK_TEXT:0:500}"

# Save for repeat (strip any control characters before writing)
printf '%s\n' "$SPEAK_TEXT" | tr -d '\000-\010\013-\037\177' > "$LAST_FILE"

# Stop any current speech then speak
pkill -f "^say " 2>/dev/null
say "$SPEAK_TEXT" &
disown

#!/usr/bin/env bash
# stop-speak.sh — Claude Code Stop hook
#
# Reads the latest assistant response from the session transcript, strips
# markdown formatting, and speaks it using macOS `say`. Polls up to 6
# seconds for the transcript to be updated before reading.
#
# Hook type:   Stop
# Dependencies: jq, say (macOS built-in)
# State file:  ~/.claude/tts/state  ("on" / "off")
# Cache file:  ~/.claude/tts/last.txt  (used by repeat.sh)

export PATH="/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin:$PATH"

STATE_FILE="$HOME/.claude/tts/state"
LAST_FILE="$HOME/.claude/tts/last.txt"

[[ "$(cat "$STATE_FILE" 2>/dev/null)" == "on" ]] || exit 0

HOOK_DATA=$(cat)
TRANSCRIPT=$(echo "$HOOK_DATA" | jq -r '.transcript_path // empty' 2>/dev/null)

[[ -z "$TRANSCRIPT" || ! -f "$TRANSCRIPT" ]] && exit 0

get_last_text() {
  jq -rs '
    [.[] | select(.type == "assistant") |
      select((.message.content | type) == "array") |
      select(any(.message.content[]; .type == "text"))
    ] | last |
    if . == null then ""
    else [.message.content[] | select(.type == "text") | .text] | join(" ")
    end
  ' "$1" 2>/dev/null
}

# Record transcript size at hook start
INITIAL_SIZE=$(wc -c < "$TRANSCRIPT" 2>/dev/null || echo 0)

# Wait up to 6s for transcript to grow (new response written), then read it
SPEAK_TEXT=""
for i in $(seq 1 12); do
  sleep 0.5
  CURRENT_SIZE=$(wc -c < "$TRANSCRIPT" 2>/dev/null || echo 0)
  if [[ "$CURRENT_SIZE" -gt "$INITIAL_SIZE" ]]; then
    SPEAK_TEXT=$(get_last_text "$TRANSCRIPT")
    [[ -n "$SPEAK_TEXT" && "$SPEAK_TEXT" != "null" ]] && break
  fi
done

# If transcript didn't grow, read whatever is there now
if [[ -z "$SPEAK_TEXT" || "$SPEAK_TEXT" == "null" ]]; then
  SPEAK_TEXT=$(get_last_text "$TRANSCRIPT")
fi

[[ -z "$SPEAK_TEXT" || "$SPEAK_TEXT" == "null" ]] && exit 0

# Don't repeat the same text
PREV_TEXT=$(cat "$LAST_FILE" 2>/dev/null)
[[ "$SPEAK_TEXT" == "$PREV_TEXT" ]] && exit 0

# Strip common markdown so it reads naturally
SPEAK_TEXT=$(echo "$SPEAK_TEXT" \
  | sed -E 's/```[a-zA-Z]*/. Code block. /g; s/```/. /g' \
  | sed -E 's/`([^`]+)`/\1/g' \
  | sed -E 's/\*\*([^*]+)\*\*/\1/g' \
  | sed -E 's/\*([^*]+)\*/\1/g' \
  | sed -E 's/^#{1,6} //' \
  | sed -E 's/\[([^\]]+)\]\([^)]+\)/\1/g' \
  | tr -s '\n' ' ' \
  | sed -E 's/ +/ /g; s/^ | $//' \
  | cut -c1-2000)

[[ -z "$SPEAK_TEXT" ]] && exit 0

# Save for repeat
echo "$SPEAK_TEXT" > "$LAST_FILE"

pkill -f "^say " 2>/dev/null
say "$SPEAK_TEXT" &
disown

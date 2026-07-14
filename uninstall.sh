#!/usr/bin/env bash
# uninstall.sh — Remove tts-hooks from Claude Code

set -e

TTS_DIR="$HOME/.claude/tts"
SETTINGS="$HOME/.claude/settings.json"

echo "Uninstalling tts-hooks..."

# --- Remove hooks from settings.json ---
if [[ -f "$SETTINGS" ]] && command -v jq >/dev/null 2>&1; then
  cp "$SETTINGS" "${SETTINGS}.bak"

  jq '
    if (.hooks.UserPromptSubmit | type) == "array" then
      .hooks.UserPromptSubmit |= map(
        select(any(.hooks[]?; (.command? // "") | contains("tts/prompt-hook.sh")) | not)
      )
    else . end |
    if (.hooks.PreToolUse | type) == "array" then
      .hooks.PreToolUse |= map(
        select(any(.hooks[]?; (.command? // "") | contains("tts/ask-speak.sh")) | not)
      )
    else . end |
    if (.hooks.Stop | type) == "array" then
      .hooks.Stop |= map(
        select(any(.hooks[]?; (.command? // "") | contains("tts/stop-speak.sh")) | not)
      )
    else . end
  ' "$SETTINGS" > "${SETTINGS}.tmp" && mv "${SETTINGS}.tmp" "$SETTINGS"

  echo "Hooks removed from settings.json (backup: ${SETTINGS}.bak)"
fi

# --- Remove install directory ---
if [[ -d "$TTS_DIR" ]]; then
  rm -rf "$TTS_DIR"
  echo "Removed $TTS_DIR"
fi

echo ""
echo "tts-hooks uninstalled."

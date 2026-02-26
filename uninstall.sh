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
    if .hooks.UserPromptSubmit then
      .hooks.UserPromptSubmit = [
        .hooks.UserPromptSubmit[] |
        select(.hooks[].command | contains("tts/prompt-hook.sh") | not)
      ]
    else . end |
    if .hooks.PreToolUse then
      .hooks.PreToolUse = [
        .hooks.PreToolUse[] |
        select(.hooks[].command | contains("tts/ask-speak.sh") | not)
      ]
    else . end |
    if .hooks.Stop then
      .hooks.Stop = [
        .hooks.Stop[] |
        select(.hooks[].command | contains("tts/stop-speak.sh") | not)
      ]
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

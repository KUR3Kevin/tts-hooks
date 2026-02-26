#!/usr/bin/env bash
# install.sh — Install tts-hooks for Claude Code (macOS)
#
# 1. Copies all scripts to ~/.claude/tts/
# 2. Registers the 3 Claude Code hooks in ~/.claude/settings.json
# 3. Creates runtime files (state, last.txt)

set -e

TTS_DIR="$HOME/.claude/tts"
SETTINGS="$HOME/.claude/settings.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing tts-hooks..."

# --- Dependency checks ---
if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required. Install it with: brew install jq"
  exit 1
fi

if ! command -v say >/dev/null 2>&1; then
  echo "Error: 'say' command not found. tts-hooks requires macOS."
  exit 1
fi

# --- Check for existing install ---
if [[ -f "$TTS_DIR/stop-speak.sh" ]]; then
  echo "tts-hooks appears to already be installed at $TTS_DIR."
  echo "Run ./uninstall.sh first, then re-run ./install.sh."
  exit 1
fi

# --- Copy scripts ---
mkdir -p "$TTS_DIR"
cp "$SCRIPT_DIR/hooks/ask-speak.sh"   "$TTS_DIR/"
cp "$SCRIPT_DIR/hooks/stop-speak.sh"  "$TTS_DIR/"
cp "$SCRIPT_DIR/hooks/prompt-hook.sh" "$TTS_DIR/"
cp "$SCRIPT_DIR/scripts/toggle.sh"    "$TTS_DIR/"
cp "$SCRIPT_DIR/scripts/repeat.sh"    "$TTS_DIR/"
chmod +x "$TTS_DIR"/*.sh

# --- Create runtime files ---
[[ -f "$TTS_DIR/state" ]]    || echo "on" > "$TTS_DIR/state"
[[ -f "$TTS_DIR/last.txt" ]] || touch "$TTS_DIR/last.txt"

# --- Patch settings.json ---
if [[ ! -f "$SETTINGS" ]]; then
  echo '{}' > "$SETTINGS"
fi

cp "$SETTINGS" "${SETTINGS}.bak"

jq '
  .hooks.UserPromptSubmit = (.hooks.UserPromptSubmit // []) +
    [{"hooks": [{"type": "command", "command": "bash ~/.claude/tts/prompt-hook.sh"}]}] |
  .hooks.PreToolUse = (.hooks.PreToolUse // []) +
    [{"matcher": "AskUserQuestion", "hooks": [{"type": "command", "command": "'"$TTS_DIR"'/ask-speak.sh"}]}] |
  .hooks.Stop = (.hooks.Stop // []) +
    [{"hooks": [{"type": "command", "command": "'"$TTS_DIR"'/stop-speak.sh"}]}]
' "$SETTINGS" > "${SETTINGS}.tmp" && mv "${SETTINGS}.tmp" "$SETTINGS"

echo ""
echo "tts-hooks installed successfully!"
echo ""
echo "  TTS is ON by default."
echo "  Type 'toggle.sh' in Claude Code to toggle on/off."
echo "  Type 'repeat'    in Claude Code to replay the last response."
echo ""
echo "Settings backed up to: ${SETTINGS}.bak"

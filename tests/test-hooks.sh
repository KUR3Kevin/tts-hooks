#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TEST_HOME=$(mktemp -d "${TMPDIR:-/tmp}/tts-hooks-test.XXXXXX")
trap 'rm -rf "$TEST_HOME"' EXIT

mkdir -p "$TEST_HOME/.claude/tts"
printf '%s\n' '#!/usr/bin/env bash' 'printf toggle >&2' > "$TEST_HOME/.claude/tts/toggle.sh"
printf '%s\n' '#!/usr/bin/env bash' 'printf repeat >&2' > "$TEST_HOME/.claude/tts/repeat.sh"

ordinary_output=$(printf '%s' '{"prompt":"please explain toggle.sh"}' |
  HOME="$TEST_HOME" bash "$ROOT_DIR/hooks/prompt-hook.sh")
[[ -z "$ordinary_output" ]]

toggle_output=$(printf '%s' '{"prompt":"  toggle.sh  "}' |
  HOME="$TEST_HOME" bash "$ROOT_DIR/hooks/prompt-hook.sh" 2>/dev/null)
[[ "$toggle_output" == *'"decision":"block"'* ]]

cat > "$TEST_HOME/.claude/settings.json" <<'JSON'
{
  "hooks": {
    "UserPromptSubmit": [
      {"hooks": [{"type": "command", "command": "bash ~/.claude/tts/prompt-hook.sh"}]},
      {"hooks": [{"type": "command", "command": "bash ~/.claude/other-hook.sh"}]}
    ],
    "PreToolUse": null,
    "Stop": [
      {"hooks": [{"type": "command", "command": "bash ~/.claude/tts/stop-speak.sh"}]}
    ]
  }
}
JSON

HOME="$TEST_HOME" bash "$ROOT_DIR/uninstall.sh" >/dev/null

jq -e '.hooks.UserPromptSubmit | length == 1' "$TEST_HOME/.claude/settings.json" >/dev/null
jq -e '.hooks.UserPromptSubmit[0].hooks[0].command | contains("other-hook.sh")' \
  "$TEST_HOME/.claude/settings.json" >/dev/null
jq -e '.hooks.Stop | length == 0' "$TEST_HOME/.claude/settings.json" >/dev/null

printf 'hook tests passed\n'

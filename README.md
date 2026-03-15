# tts-hooks

Claude Code hooks that speak responses and questions aloud using macOS text-to-speech.

## What it does

- **Speaks assistant responses** when Claude finishes its turn (Stop hook)
- **Speaks questions and options** from `AskUserQuestion` before you see them (PreToolUse hook)
- **Toggle on/off** by typing `toggle.sh` in the Claude Code prompt
- **Replay** the last spoken text by typing `repeat`

## Requirements

- macOS
- [Claude Code](https://claude.ai/code)
- [`jq`](https://jqlang.github.io/jq/) — install with `brew install jq`
- [`edge-tts`](https://github.com/rany2/edge-tts) — install with `pip install edge-tts`
  (used by `stop-speak.sh` for high-quality neural TTS; `ask-speak.sh` and `toggle.sh` use the built-in `say`)

## Install

```bash
git clone https://github.com/KUR3Kevin/tts-hooks.git
cd tts-hooks
./install.sh
```

TTS is **on** by default after install. Restart Claude Code for hooks to take effect.

## Usage

| Action | How |
|--------|-----|
| Toggle TTS on/off | Type `toggle.sh` in the Claude Code prompt |
| Replay last response | Type `repeat` in the Claude Code prompt |

## How it works

Three hooks register with Claude Code:

```
UserPromptSubmit → prompt-hook.sh   intercepts toggle/repeat commands
PreToolUse       → ask-speak.sh     speaks AskUserQuestion prompts
Stop             → stop-speak.sh    speaks the assistant's response
```

Scripts are installed to `~/.claude/tts/`. Hooks are registered in `~/.claude/settings.json`.

## Uninstall

```bash
./uninstall.sh
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).

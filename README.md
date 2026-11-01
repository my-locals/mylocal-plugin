# mylocal plugin for AI coding agents

An AI coding agent skill for the `mylocal` CLI of MyLocal. It lets your agent analyze MyLocal's activity log, diagnose problems, see which dev servers are open and why they would be cleaned up, and change the schedule, rules and cleanup settings.

The agent does not stop, keep or snooze servers. You decide that in the MyLocal app.

## Install

### Claude Code

```bash
# Add the marketplace (first time only)
claude plugin marketplace add my-locals/mylocal-plugin

# Install the plugin
claude plugin install mylocal@mylocal
```

For local development:

```bash
git clone https://github.com/my-locals/mylocal-plugin.git
claude --plugin-dir ./mylocal-plugin
```

### OpenAI Codex CLI

```bash
codex plugin marketplace add my-locals/mylocal-plugin
codex plugin install mylocal
```

### Google Antigravity CLI

```bash
agy plugin install https://github.com/my-locals/mylocal-plugin
```

## Requirements

Installing MyLocal with Homebrew also links the `mylocal` CLI that comes inside the app.

```bash
brew tap my-locals/mylocal
brew trust --tap my-locals/mylocal
brew install --cask mylocal
mylocal schema > /dev/null && echo ok
```

If you installed from the DMG, link the CLI into `~/.local/bin` with the command shown in the app under General > About.

## What's included

| Agent | File | Scope |
|---|---|---|
| Claude Code | `skills/mylocal/SKILL.md` | `/mylocal` skill: triggers on requests about MyLocal's activity log, diagnostics, schedule and rules |
| Codex CLI | `skills/mylocal/SKILL.md` | `@mylocal` skill |
| Antigravity CLI | `skills/mylocal/SKILL.md` | Plugin skill |

## Update

```bash
claude plugin update mylocal        # Claude Code
codex plugin upgrade mylocal        # Codex CLI
agy plugin install https://github.com/my-locals/mylocal-plugin   # Antigravity CLI
```

## Uninstall

```bash
claude plugin uninstall mylocal     # Claude Code
codex plugin uninstall mylocal      # Codex CLI
agy plugin uninstall mylocal        # Antigravity CLI
```

## Feedback

Bugs and ideas go to [my-locals/mylocal](https://github.com/my-locals/mylocal), in English or 한국어.

## License

Apache 2.0. See [LICENSE](LICENSE).

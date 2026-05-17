# Claude Code Usage

[Claude Code](https://code.claude.com/docs/en/overview) reads `~/.claude/settings.json` ([model config reference](https://code.claude.com/docs/en/model-config)):

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "http://<xavier-ip>:8080",
    "CLAUDE_CODE_AUTO_COMPACT_WINDOW": "<per-slot-ctx>"
  }
}
```

- `CLAUDE_CODE_AUTO_COMPACT_WINDOW` — set to per-slot context. Defaults to 200K.

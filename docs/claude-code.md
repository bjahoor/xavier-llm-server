# Claude Code / Agent SDK Usage

Both Claude Code and the [Claude Agent SDK](https://code.claude.com/docs/en/agent-sdk/overview) read the same `~/.claude/settings.json` ([model config reference](https://code.claude.com/docs/en/model-config)):

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "http://<xavier-ip>:8080",
    "CLAUDE_CODE_AUTO_COMPACT_WINDOW": "<per-slot-ctx>"
  }
}
```

`CLAUDE_CODE_AUTO_COMPACT_WINDOW` is required — without it, Claude Code assumes a 200K window and overshoots the server's per-slot cap.

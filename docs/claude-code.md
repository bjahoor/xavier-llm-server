# Claude Code / Agent SDK Usage

Both Claude Code and the [Claude Agent SDK](https://code.claude.com/docs/en/agent-sdk/overview) read the same `~/.claude/settings.json` ([model config reference](https://code.claude.com/docs/en/model-config)):

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "http://<xavier-ip>:8080",
    "CLAUDE_CODE_AUTO_COMPACT_WINDOW": "<per-slot-ctx>",
    "CLAUDE_CODE_ATTRIBUTION_HEADER": "0"
  }
}
```

- `CLAUDE_CODE_AUTO_COMPACT_WINDOW` — required. Defaults to 200K and overshoots the per-slot cap. Set to `131072` (128K) so compaction fires at ~95% = ~124K, well before the slot ceiling. Lower for shorter but more frequent stalls.
- `CLAUDE_CODE_ATTRIBUTION_HEADER` — must be `"0"`. Default adds a per-request fingerprint that busts the prefix-cache match and forces full re-prefill **every turn**.

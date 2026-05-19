# llama-server flags

Reference for the `llama-server` flags used in [services/](../services/).

| Flag | Purpose |
| --- | --- |
| `-m` | path to the GGUF model file |
| `-fa` | flash attention — required for long-context efficiency |
| `-ctk` / `-ctv` | quantization type for the KV cache (keys / values) |
| `--jinja` | use the model's Jinja2 chat template — required for accurate tool calling |
| `-dio` | direct I/O — skips OS caching; model loads straight into tensor buffers |
| `-fit off` | disable auto-tuning of runtime parameters |
| `-c` | total context window across all slots |
| `-np` | number of parallel slots |
| `-b` / `-ub` | prefill batch / chunk size — tuned for faster prompt processing |
| `-ctxcp` | max context checkpoints per slot |
| `--cache-ram 0` | disable the host RAM cache — frees memory for slots |
| `--host` | network interface to bind |
| `--port` | port for API requests |

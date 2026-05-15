# Manual Run

```bash
sudo sh -c 'sync && echo 3 > /proc/sys/vm/drop_caches'  # clear page cache before loading any model
```

```bash
GGML_CUDA_ENABLE_UNIFIED_MEMORY=1 llama-server \
  -m /mnt/microsd/models/<model>.gguf \  # model path
  -fa on \                               # flash attention
  -ctk f16 -ctv f16 \                    # KV cache type
  --jinja -dio \                         # model's chat template + skips OS cache
  -c <total-ctx> -np <slots> \           # total ctx = per-slot × slots
  -b 4096 -ub 2048 \                     # prefill batch / chunk size
  -ctxcp 1 \                             # max checkpoints per slot
  --cache-ram 0 \                        # disable server prompt cache (saves RAM)
  --host 0.0.0.0 --port 8080             # bind all interfaces
```

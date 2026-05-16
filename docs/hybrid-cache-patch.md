# Hybrid Model Cache Patch

Until [#23121](https://github.com/ggml-org/llama.cpp/pull/23121) lands upstream, apply the patch locally on each device.

---

## Apply the patch

Stop any running llama-server service first:

```bash
sudo systemctl stop 'llama-cpp-*'
```

Checkout the patched file from the fix branch and rebuild:

```bash
cd ~/llama.cpp
git checkout master
git pull
git fetch https://github.com/bjahoor/llama.cpp.git fix/hybrid-cache-restore
git checkout FETCH_HEAD -- tools/server/server-context.cpp
cmake --build build -j
```

The patch lives as an unstaged change in your working tree — no commit, no git identity needed.

Restart the service:

```bash
sudo systemctl start <service-name>
```

---

## Pull upstream updates later

Drop the patch, pull, and re-apply:

```bash
cd ~/llama.cpp
git checkout HEAD -- tools/server/server-context.cpp
git pull
git fetch https://github.com/bjahoor/llama.cpp.git fix/hybrid-cache-restore
git checkout FETCH_HEAD -- tools/server/server-context.cpp
cmake --build build -j
```

Once [#23121](https://github.com/ggml-org/llama.cpp/pull/23121) merges upstream, skip the re-apply step — the fix will already be in master.

---

## Reset to clean upstream

```bash
cd ~/llama.cpp
git fetch origin
git reset --hard origin/master
cmake --build build -j
```

Destroys the local patch and any uncommitted changes. Leaves you at exactly upstream master.

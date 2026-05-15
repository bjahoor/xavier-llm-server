# Hybrid Model Cache Patch

Until [#23121](https://github.com/ggml-org/llama.cpp/pull/23121) lands upstream, apply the patch locally on each device.

---

## Apply the patch

Stop any running llama-server service first:

```bash
sudo systemctl stop 'llama-cpp-*'
```

Cherry-pick the patch onto your existing llama.cpp clone and rebuild:

```bash
cd ~/llama.cpp
git checkout master
git fetch https://github.com/bjahoor/llama.cpp.git fix/hybrid-cache-restore
git cherry-pick FETCH_HEAD
cmake --build build -j
```

Restart the service:

```bash
sudo systemctl start <service-name>
```

---

## Pull upstream updates later

```bash
cd ~/llama.cpp
git pull --rebase
cmake --build build -j
```

Once [#23121](https://github.com/ggml-org/llama.cpp/pull/23121) merges upstream, the rebase will detect the duplicate commit and drop the local cherry-pick automatically.

---

## Reset to clean upstream

```bash
cd ~/llama.cpp
git fetch origin
git reset --hard origin/master
cmake --build build -j
```

Destroys the local patch and any uncommitted changes. Leaves you at exactly upstream master.

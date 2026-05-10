# Jetson AGX Xavier llama.cpp Server

---

This repo contains scripts and service files to configure a **Jetson AGX Xavier** to run as an LLM server using **[llama.cpp](https://github.com/ggml-org/llama.cpp)** — the best inference engine option for sm_72 (Jetson Volta).

The server exposes OpenAI-compatible endpoints (Anthropic-compatible endpoints also supported) for use with **[Hermes Agent](https://github.com/NousResearch/hermes-agent)** and other compatible clients.

Models from **[Unsloth](https://huggingface.co/collections/unsloth/unsloth-dynamic-20-quants)** on HuggingFace are the best source for GGUF quants.

---

## Setup

```bash
git clone https://github.com/bjahoor/xavier-llm-server.git ~/xavier-llm-server
```

```bash
cd ~/xavier-llm-server
bash ./scripts/0-device-setup.sh    # upgrade system, install JetPack, jtop, Tailscale
sudo tailscale up --auth-key=<your-auth-key> --hostname=<your-hostname> --ssh
sudo reboot                         # next boot is headless — connect via Tailscale SSH from here on
```

```bash
cd ~/xavier-llm-server
bash ./scripts/1-mount-microsd.sh   # optional: microSD card for models (recommended)
```

```bash
cd ~/xavier-llm-server
bash ./scripts/2-setup-llamacpp.sh  # install build deps + compile llama.cpp (~45 min); re-run to update
```

```bash
cd /mnt/microsd/models                      # navigate to model storage
curl -L -C - -O <huggingface-model-url>     # download the model file
```

```bash
cd ~/xavier-llm-server
sudo cp services/*.service /etc/systemd/system/      # install service files
sudo systemctl daemon-reload                         # reload systemd
sudo systemctl enable <service-name>                 # auto-start on boot
# sudo systemctl enable llama-cpp-qwen3.5-9b
sudo reboot                                          # starts llama-server
```

## Hermes Agent Usage

Add to `~/.hermes/config.yaml` ([custom providers](https://hermes-agent.nousresearch.com/docs/integrations/providers#custom--self-hosted-llm-providers), [llama-server setup](https://hermes-agent.nousresearch.com/docs/integrations/providers#llamacpp--llama-server--cpu--metal-inference)):

```yaml
model:
  default: <model-filename>.gguf
  provider: custom
  base_url: http://<xavier-ip>:8080/v1/

custom_providers:
- name: <display-name>
  base_url: http://<xavier-ip>:8080/v1/
  model: <model-filename>.gguf
```

### Manual Run

```bash
sudo sh -c 'sync && echo 3 > /proc/sys/vm/drop_caches'  # clear page cache before loading any model
```

```bash
GGML_CUDA_ENABLE_UNIFIED_MEMORY=1 llama-server \
  -m /mnt/microsd/models/<model>.gguf \  # model path
  -fa on -ctk q8_0 -ctv q8_0 \           # flash attn + kv cache quantization
  --jinja -dio \                         # model's chat template + skips OS cache
  -c <total-ctx> -np <slots> \           # total ctx = per-slot × slots
  --cache-ram 0 \                        # disable server prompt cache (saves RAM)
  --host 0.0.0.0 --port 8080             # bind all interfaces
```


## Performance Bottlenecks

**Dense — memory bandwidth bound.** Every token reads all weights from unified memory into the GPU cores. Throughput ceiling = bandwidth ÷ model size — [Qwen3.6-27B Q8_0](https://huggingface.co/unsloth/Qwen3.6-27B-GGUF/blob/main/Qwen3.6-27B-Q8_0.gguf) at 28.6 GB on Xavier's [136.5 GB/s](https://www.nvidia.com/en-us/autonomous-machines/embedded-systems/jetson-xavier-series/) = **~4.8 tok/s ceiling**.

**MoE — CPU dispatch bound.** Each token passes through every layer, each with a router that picks which experts to run. CUDA 11.4 forces the CPU to handle dispatch after each routing decision — [Qwen3.6-35B-A3B](https://huggingface.co/unsloth/Qwen3.6-35B-A3B-GGUF/blob/main/Qwen3.6-35B-A3B-Q8_0.gguf)'s 40 layers means 40 CPU round trips per token, unavoidable.


## Recovery

Put the Xavier into Force Recovery mode, then from the host:

```bash
lsusb | grep 0955:7019                                                                        # expect: NVIDIA Corp. APX
cd ~/nvidia/nvidia_sdk/JetPack_5.1.6_Linux_JETSON_AGX_XAVIER_TARGETS/Linux_for_Tegra
sudo ./tools/l4t_flash_prerequisites.sh                                                       # one-time
sudo ./tools/kernel_flash/l4t_initrd_flash.sh --initrd jetson-agx-xavier-devkit <partition>   # <partition> inert with --initrd (RAM boot); any value works, e.g. nvme0n1p1
```

```bash
ssh-keygen -f "$HOME/.ssh/known_hosts" -R "fe80::1%eth0"  # only if ssh below fails with host-key warning, then retry ssh
```

```bash
ssh root@fe80::1%eth0  # password: root
```

In the recovery shell:

```bash
mkdir -p /mnt/root
lsblk -f  # find <rootfs-partition> (APP label) — eMMC: mmcblk0p1, microSD: mmcblk1p1, NVMe: nvme0n1p1
mount /dev/<rootfs-partition> /mnt/root  # e.g. /dev/nvme0n1p1
rm -f /mnt/root/etc/systemd/system/multi-user.target.wants/llama-cpp-*.service
rm -f /mnt/root/etc/systemd/system/default.target.wants/llama-cpp-*.service
sync
umount /mnt/root
reboot -f  # initrd has no systemd, plain `reboot` may hang
# then immediately unplug USB-C to prevent re-entering recovery mode
```


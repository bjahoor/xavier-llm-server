# Jetson AGX Xavier llama.cpp Server

---

This repo contains scripts and service files to configure a **Jetson AGX Xavier** to run as an LLM server using **[llama.cpp](https://github.com/ggml-org/llama.cpp)** — the best inference engine option for sm_72 (Volta).

The server exposes OpenAI-compatible endpoints (Anthropic-compatible endpoints also supported) for use with **[Hermes Agent](https://github.com/NousResearch/hermes-agent)** and other compatible clients.

Models from **[Unsloth](https://huggingface.co/collections/unsloth/unsloth-dynamic-20-quants)** on HuggingFace are the best source for GGUF quants.

---

## Setup

```bash
bash ./scripts/0-device-setup.sh    # upgrade system, install JetPack, jtop, Tailscale
sudo tailscale up --auth-key=<your-auth-key> --hostname=<your-hostname> --ssh
sudo reboot                         # next boot is headless — connect via Tailscale SSH from here on
bash ./scripts/1-mount-microsd.sh   # optional: microSD card for models (recommended)
bash ./scripts/2-setup-llamacpp.sh  # install build deps + compile llama.cpp (~45 min)
```

```bash
cd /mnt/microsd/models                      # navigate to model storage
curl -L -C - -O <huggingface-model-url>     # download the model file
```

```bash
sudo cp services/*.service /etc/systemd/system/      # install service files
sudo systemctl daemon-reload                         # reload systemd
sudo systemctl enable <service-name>                 # auto-start on boot
# sudo systemctl enable llama-cpp-qwen3.5-9b
sudo reboot                                          # starts llama-server
```

## Manual Run

```bash
sudo sh -c 'sync && echo 3 > /proc/sys/vm/drop_caches'  # clear page cache before loading any model
```

```bash
GGML_CUDA_ENABLE_UNIFIED_MEMORY=1 llama-server \
  -m /mnt/microsd/models/<model>.gguf \
  -fa on -ctk q8_0 -ctv q8_0 \
  --jinja -dio \
  -c <total-ctx> -np <slots> \
  --cache-ram 0 \
  --host 0.0.0.0 --port 8080
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


## Performance Bottlenecks

**Dense — memory bandwidth bound.** Every token reads all weights from unified memory into the GPU cores. Throughput ceiling = bandwidth ÷ model size — [Qwen3.6-27B Q8_0](https://huggingface.co/unsloth/Qwen3.6-27B-GGUF/blob/main/Qwen3.6-27B-Q8_0.gguf) at 28.6 GB on Xavier's [136.5 GB/s](https://www.nvidia.com/en-us/autonomous-machines/embedded-systems/jetson-xavier-series/) = **~4.8 tok/s ceiling**.

**MoE — CPU dispatch bound.** Each token passes through every layer, each with a router that picks which experts to run. CUDA 11.4 forces the CPU to handle dispatch after each routing decision — [Qwen3.6-35B-A3B](https://huggingface.co/unsloth/Qwen3.6-35B-A3B-GGUF/blob/main/Qwen3.6-35B-A3B-Q8_0.gguf)'s 40 layers means 40 CPU round trips per token, unavoidable.


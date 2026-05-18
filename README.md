# Jetson AGX Xavier llama.cpp Server

---

This repo contains scripts and service files to configure a **Jetson AGX Xavier** (tested on JetPack 5.1.6 — L4T R35.6.4) to run as an LLM server using **[llama.cpp](https://github.com/ggml-org/llama.cpp)** — the best inference engine option for sm_72 (Jetson Volta).

The server exposes OpenAI-compatible and Anthropic-compatible endpoints for use with compatible clients such as:

- [Hermes Agent](https://hermes-agent.nousresearch.com/)
- [OpenClaw](https://openclaw.ai/)
- [Claude Code](https://www.claude.com/product/claude-code)

Recommended sources for GGUF quants on HuggingFace:

- [ggml-org](https://huggingface.co/ggml-org)
- [Bartowski](https://huggingface.co/bartowski)
- [Unsloth AI](https://huggingface.co/unsloth)
- [team mradermacher](https://huggingface.co/mradermacher/models)
- [LM Studio Community](https://huggingface.co/lmstudio-community)

---

## Setup and Install

### 1. Clone repo

```bash
git clone https://github.com/bjahoor/xavier-llm-server.git ~/xavier-llm-server
```

### 2. Base install + setup

```bash
cd ~/xavier-llm-server
sudo bash ./scripts/0-device-setup.sh    # upgrade system, install JetPack, jtop, Tailscale
sudo tailscale up --auth-key=<your-auth-key> --hostname=<your-hostname> --ssh
sudo reboot                         # next boot is headless — connect via Tailscale SSH from here on
```

### 3. microSD storage (optional)

```bash
cd ~/xavier-llm-server
sudo bash ./scripts/1-mount-microsd.sh   # optional: microSD card for models (recommended)
```

### 4. Build llama.cpp

```bash
cd ~/xavier-llm-server
sudo bash ./scripts/2-setup-llamacpp.sh  # install build deps + compile llama.cpp (~45 min); re-run to update
source /etc/profile.d/llama-cpp.sh       # load PATH for current shell
```

### 5. Download a model

```bash
cd /mnt/microsd/models                      # navigate to model storage
curl -L -C - -O <huggingface-model-url>     # download the model file
```

### 6. Install services

```bash
cd ~/xavier-llm-server
sudo cp services/*.service /etc/systemd/system/      # install service files
sudo systemctl daemon-reload                         # reload systemd
sudo systemctl enable <service-name>                 # auto-start on boot
# sudo systemctl enable llama-cpp-nemotron-12b-microsd
sudo reboot                                          # starts llama-server
```

---

## Docs

- [Manual Run](docs/manual-run.md) — run llama-server directly without a service
- [Hermes Agent Usage](docs/hermes-agent.md) — point Nous Research's Hermes Agent at the server
- [Claude Code Usage](docs/claude-code.md) — point Claude Code at the server
- [Performance Constraints](docs/performance-constraints.md) — hardware ceilings that bound any workload
- [Recovery](docs/recovery.md) — recover the device via Force Recovery mode

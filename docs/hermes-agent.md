# Hermes Agent Usage

Edit `~/.hermes/config.yaml` ([custom providers](https://hermes-agent.nousresearch.com/docs/integrations/providers#custom--self-hosted-llm-providers), [llama-server setup](https://hermes-agent.nousresearch.com/docs/integrations/providers#llamacpp--llama-server--cpu--metal-inference)).

```yaml
model:
  provider: nemotron
```

```yaml
auxiliary:
  web_extract:
    provider: qwen
  compression:
    provider: qwen
  session_search:
    provider: qwen
  skills_hub:
    provider: qwen
  approval:
    provider: qwen
  mcp:
    provider: qwen
  title_generation:
    provider: qwen
  triage_specifier:
    provider: qwen
  curator:
    provider: qwen
```

```yaml
custom_providers:
- name: nemotron
  base_url: http://<xavier-ip>:8080/v1/
  model: NVIDIA-Nemotron-Labs-3-Elastic-12B-A2B.i1-Q5_K_M.gguf
- name: qwen
  base_url: http://<xavier-ip>:8080/v1/
  model: Qwen3.5-4B-UD-Q6_K_XL.gguf
```

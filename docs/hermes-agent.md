# Hermes Agent Usage

Edit `~/.hermes/config.yaml` ([custom providers](https://hermes-agent.nousresearch.com/docs/integrations/providers#custom--self-hosted-llm-providers), [llama-server setup](https://hermes-agent.nousresearch.com/docs/integrations/providers#llamacpp--llama-server--cpu--metal-inference)).

```yaml
model:
  provider: nemotron
```

```yaml
auxiliary:
  vision:
    provider: auto
  web_extract:
    provider: granite
  compression:
    provider: granite
  session_search:
    provider: granite
  skills_hub:
    provider: granite
  approval:
    provider: granite
  mcp:
    provider: nemotron
  title_generation:
    provider: granite
  triage_specifier:
    provider: nemotron
  kanban_decomposer:
    provider: nemotron
  profile_describer:
    provider: granite
  curator:
    provider: nemotron
  goal_judge:
    provider: nemotron
```

```yaml
custom_providers:
- name: nemotron
  base_url: http://<xavier-ip>:8080/v1/
  model: NVIDIA-Nemotron-Labs-3-Elastic-12B-A2B.i1-Q5_K_M.gguf
- name: granite
  base_url: http://<xavier-ip>:8080/v1/
  model: granite-4.0-h-tiny-UD-Q6_K_XL.gguf
```

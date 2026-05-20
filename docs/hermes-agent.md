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
    provider: jamba
  compression:
    provider: jamba
  session_search:
    provider: jamba
  skills_hub:
    provider: jamba
  approval:
    provider: jamba
  mcp:
    provider: nemotron
  title_generation:
    provider: jamba
  triage_specifier:
    provider: nemotron
  kanban_decomposer:
    provider: nemotron
  profile_describer:
    provider: jamba
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
- name: jamba
  base_url: http://<xavier-ip>:8080/v1/
  model: ai21labs_AI21-Jamba2-3B-Q6_K_L.gguf
```

# Hermes Agent Usage

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

compression:
  threshold: 0.95
```

`compression.threshold` defaults to `0.50` — every mid-conversation rewrite forces a full re-prefill (~15–30 min at 256K). Raising to `0.95` defers the stall to near the cap.

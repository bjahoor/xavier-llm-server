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
```

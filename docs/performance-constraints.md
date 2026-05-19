# Performance Constraints

---

## Memory capacity — ~32 GB LPDDR4x unified
Physical memory shared between CPU and GPU.

**Affects:** model size and context capacity (per-slot × slots).

## Memory bandwidth — ~136.5 GB/s
Rate at which data moves to/from unified memory.

**Affects:** decode and prefill (bytes/token vary by architecture, size, quantization).

## Compute — ~5–6 TOPS via DP4A on CUDA cores
Rate of arithmetic operations. Volta tensor cores (~11 FP16 TFLOPS) are unreachable on sm_72, and the build forces MMQ, so quantized weight computation always goes through INT8 DP4A. Decode attention with quantized KV is INT8 DP4A; prefill attention is FP16×FP16. Everything else (norms, softmax, RoPE, residuals) runs FP32 on the ~1.4 TFLOPS CUDA-core path. All accumulation FP32.

**Affects:** prefill throughput once batches saturate DP4A; decode is usually dispatch-bound before compute matters.

## Dispatch overhead — CUDA 11.4 / sm_72, no CUDA Graphs
Fixed CPU↔GPU round-trip cost per kernel launch. Cannot be batched away.

**Affects:** decode in general (every layer dispatches per token); worse for MoE (more routed kernels).

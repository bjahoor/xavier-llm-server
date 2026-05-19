# Performance Constraints

---

## Memory capacity — ~32 GB LPDDR4x unified
Physical memory shared between CPU and GPU.

**Affects:** model size and context capacity (per-slot × slots).

## Memory bandwidth — ~136.5 GB/s
Rate at which data moves to/from unified memory.

**Affects:** decode and prefill (bytes/token vary by architecture, size, quantization).

## Compute — ~11 FP16 TFLOPS / 22 INT8 TOPS (tensor cores unused)
Rate of arithmetic operations. Volta tensor cores exist but llama.cpp skips them on sm_72. Quantized weight math uses INT8 via DP4A. Attention layers (when present) use INT8 during decode and FP16 during prefill. All other kernel operations (including non-attention architecture compute) are FP32. All accumulation in FP32.

**Affects:** prefill throughput once batches saturate DP4A; decode rarely hits the compute ceiling (bandwidth or dispatch caps it first).

## Dispatch overhead — CUDA 11.4 / sm_72, no CUDA Graphs
Fixed CPU↔GPU round-trip cost per kernel launch. Cannot be batched away.

**Affects:** decode and small-batch prefill below DP4A saturation; varies by architecture.

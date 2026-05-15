# Performance Constraints

---

## Memory capacity — ~32 GB LPDDR4x unified
Physical memory shared between CPU and GPU.

**Affects:** model size and context capacity (per-slot × slots).

## Memory bandwidth — ~136.5 GB/s
Rate at which any data is read from unified memory.

**Affects:** decode. Bytes-per-token by architecture: dense > MoE > hybrid.

## Compute — ~11 FP16 TFLOPS
Rate of arithmetic operations. FP16 uses tensor cores; quantized formats use scalar DP4A INT8 instructions.

**Affects:** prefill at high batch sizes.

## Dispatch overhead — CUDA 11.4 / sm_72, no CUDA Graphs
Fixed CPU↔GPU round-trip cost per kernel launch. Cannot be batched away.

**Affects:** MoE expert routing — each routed layer needs a CPU dispatch per token. Hybrid pays only on its routed layers.

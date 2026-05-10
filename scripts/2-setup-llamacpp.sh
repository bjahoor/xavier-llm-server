#!/bin/bash
# 2-setup-llamacpp.sh — install build deps and compile llama.cpp for sm_72 (~45 min)
#
# Usage:
#   bash ./scripts/2-setup-llamacpp.sh

set -euo pipefail

# build tools
sudo apt update
sudo apt full-upgrade -y
sudo apt install -y build-essential

# Ubuntu 20.04 ships CMake 3.16; llama.cpp requires 3.27+
pip3 install --user --upgrade cmake
export PATH="$HOME/.local/bin:$PATH"

# source
git clone https://github.com/ggml-org/llama.cpp.git ~/llama.cpp

# Xavier-specific build flags
CMAKE_FLAGS=(
  -DCMAKE_BUILD_TYPE=Release          # optimized build, no debug symbols
  -DGGML_CUDA=ON                      # enable GPU acceleration
  -DCMAKE_CUDA_ARCHITECTURES=72       # Xavier GPU is sm_72 (Volta)
  -DGGML_NATIVE=ON                    # optimize for this CPU specifically
  -DGGML_CPU_ARM_ARCH=armv8.2-a+fp16 # enable Carmel FP16 NEON (GCC 9 misses this)
  -DGGML_RPC=ON                       # build rpc-server for remote offload
  -DGGML_CUDA_GRAPHS=OFF              # CUDA Graphs need Ampere+; removes dead code
  -DGGML_LTO=ON                       # link-time optimization across translation units
  -DGGML_CUDA_FORCE_MMQ=ON            # force quantized matmul kernels at all batch sizes
  -DGGML_CUDA_FA_ALL_QUANTS=ON        # compile flash attention for all quant combinations
  -DGGML_OPENMP=ON                    # explicit OpenMP for CPU-side dispatch and thread scheduling
)

# configure and build (~45 min)
cmake -S ~/llama.cpp -B ~/llama.cpp/build "${CMAKE_FLAGS[@]}"
cmake --build ~/llama.cpp/build -j$(nproc)

# add binaries to PATH permanently and verify
if ! grep -q 'llama.cpp/build/bin' ~/.bashrc; then
  echo 'export PATH=$HOME/llama.cpp/build/bin:$PATH' >> ~/.bashrc
fi
export PATH="$HOME/llama.cpp/build/bin:$PATH"
echo
llama-server --version

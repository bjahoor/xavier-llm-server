#!/bin/bash
# 2-setup-llamacpp.sh — install build deps and compile llama.cpp for sm_72 (~45 min)
#
# Usage:
#   sudo bash ./scripts/2-setup-llamacpp.sh

set -euo pipefail

# require sudo
(( EUID == 0 )) || { echo "ERROR: run with sudo" >&2; exit 1; }
# capture the original user (set by sudo); abort if missing so files don't end up root-owned
TARGET_USER="${SUDO_USER:?run via sudo, not as root directly}"
# look up that user's home dir so the build lands in /home/user, not /root
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)

# build tools
sudo apt update
sudo apt full-upgrade -y
sudo apt install -y build-essential

# Ubuntu 20.04 ships CMake 3.16; llama.cpp requires 3.27+ — install as user so it lives in $HOME/.local
sudo -u "$TARGET_USER" -H pip3 install --user --upgrade cmake

# source — clone/pull as user so $HOME/llama.cpp is user-owned
if [ -d "$TARGET_HOME/llama.cpp" ]; then
  sudo -u "$TARGET_USER" -H git -C "$TARGET_HOME/llama.cpp" pull
else
  sudo -u "$TARGET_USER" -H git clone https://github.com/ggml-org/llama.cpp.git "$TARGET_HOME/llama.cpp"
fi

# Xavier-specific build flags
CMAKE_FLAGS=(
  -DCMAKE_BUILD_TYPE=Release          # optimized build, no debug symbols
  -DGGML_CUDA=ON                      # enable GPU acceleration
  -DCMAKE_CUDA_ARCHITECTURES=72       # Xavier GPU is sm_72 (Volta)
  -DGGML_NATIVE=ON                    # optimize for this CPU specifically
  -DGGML_CPU_ARM_ARCH=armv8.2-a+fp16 # enable Carmel FP16 NEON (GCC 9 misses this)
  -DGGML_RPC=ON                       # build rpc-server for remote offload
  -DGGML_RPC_RDMA=OFF                 # skip RDMA transport — Ubuntu 20.04 libibverbs is too old
  -DGGML_CUDA_GRAPHS=OFF              # CUDA Graphs need Ampere+; removes dead code
  -DGGML_LTO=ON                       # link-time optimization across translation units
  -DGGML_CUDA_FORCE_MMQ=ON            # force quantized matmul kernels at all batch sizes
  -DGGML_CUDA_FA_ALL_QUANTS=ON        # compile flash attention for all quant combinations
  -DGGML_OPENMP=ON                    # explicit OpenMP for CPU-side dispatch and thread scheduling
)

# configure and build (~45 min) — run as user so build artifacts are user-owned; sudo strips PATH so set it explicitly to find user-installed cmake
# rm -rf "$TARGET_HOME/llama.cpp/build"  # uncomment to force a clean rebuild
USER_PATH="$TARGET_HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"
sudo -u "$TARGET_USER" -H env PATH="$USER_PATH" cmake -S "$TARGET_HOME/llama.cpp" -B "$TARGET_HOME/llama.cpp/build" "${CMAKE_FLAGS[@]}"
sudo -u "$TARGET_USER" -H env PATH="$USER_PATH" cmake --build "$TARGET_HOME/llama.cpp/build" -j$(nproc)

# add binaries to PATH for login shells (system-wide drop-in)
echo 'export PATH=$HOME/llama.cpp/build/bin:$PATH' > /etc/profile.d/llama-cpp.sh

# free up apt cache and orphaned packages now that all installs are done
sudo apt clean
sudo apt autoremove --purge -y

echo
sudo -u "$TARGET_USER" -H bash -lc 'llama-server --version'

echo
echo "Run: source /etc/profile.d/llama-cpp.sh"

#!/bin/bash
# 0-device-setup.sh — system upgrade, JetPack, jtop, Tailscale
#
# Usage:
#   bash ./scripts/0-device-setup.sh

set -euo pipefail

# system update
sudo apt update
sudo apt upgrade -y
sudo apt full-upgrade -y

# JetPack — CUDA, cuDNN, TensorRT, and Jetson drivers
sudo apt install -y nvidia-jetpack

# max performance clocks, persistent across reboots
sudo nvpmodel -m 0
sudo jetson_clocks
sudo systemctl enable jetson_clocks

# cool fan profile — temperature-responsive, persists across reboots
sudo sed -i 's/^\s*FAN_DEFAULT_PROFILE .*/\tFAN_DEFAULT_PROFILE cool/' /etc/nvfancontrol.conf  # set cool profile in nvfancontrol conf
sudo rm -f /var/lib/nvfancontrol/status  # clear cached state so daemon re-reads conf
sudo systemctl restart nvfancontrol

# jtop — system monitor for Jetson (fan, clocks, power mode)
sudo apt install -y python3-pip
sudo pip3 install -U jetson-stats
sudo systemctl enable --now jtop

# Tailscale — remote access; disable OpenSSH in favour of Tailscale SSH
sudo apt install -y curl
curl -fsSL https://tailscale.com/install.sh | sh
sudo systemctl disable --now ssh

# headless boot — no GUI, frees ~1 GB RAM
sudo systemctl set-default multi-user.target

echo
echo "Next steps:"
echo "  1. sudo tailscale up --auth-key=<your-auth-key> --hostname=<your-hostname> --ssh"
echo "  2. sudo reboot  (next boot will be headless — no GUI)"

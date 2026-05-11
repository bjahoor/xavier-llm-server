#!/bin/bash
# 0-device-setup.sh — system upgrade, JetPack, jtop, Tailscale
#
# Usage:
#   sudo bash ./scripts/0-device-setup.sh

set -euo pipefail

# require sudo
(( EUID == 0 )) || { echo "ERROR: run with sudo" >&2; exit 1; }

# system update
sudo apt update
sudo apt full-upgrade -y

# JetPack — CUDA, cuDNN, TensorRT, and Jetson drivers
sudo apt install -y nvidia-jetpack

# max performance clocks for current session
sudo nvpmodel -m 0
sudo jetson_clocks

# cool fan profile — temperature-responsive, persists across reboots
sudo sed -i 's/^\s*FAN_DEFAULT_PROFILE .*/\tFAN_DEFAULT_PROFILE cool/' /etc/nvfancontrol.conf  # set cool profile in nvfancontrol conf
sudo rm -f /var/lib/nvfancontrol/status  # clear cached state so daemon re-reads conf
sudo systemctl restart nvfancontrol

# jtop — system monitor for Jetson (fan, clocks, power mode)
sudo apt install -y python3-pip
sudo pip3 install -U jetson-stats
sudo systemctl enable --now jtop
sleep 10  # wait for jtop.service socket to be ready
# enable jetson_clocks on every boot via jtop's own config (requires jtop.service running)
sudo python3 -c "from jtop import jtop
with jtop() as j:
    j.jetson_clocks.boot = True"

# Tailscale — remote access; disable OpenSSH in favour of Tailscale SSH
sudo apt install -y curl
curl -fsSL https://tailscale.com/install.sh | sh
sudo systemctl disable ssh  # takes effect after reboot — keeps current session alive

# headless boot — no GUI, frees ~1 GB RAM
sudo systemctl set-default multi-user.target

# free up apt cache and orphaned packages now that all installs are done
sudo apt clean
sudo apt autoremove --purge -y

echo
echo "Next steps:"
echo "  1. sudo tailscale up --auth-key=<your-auth-key> --hostname=<your-hostname> --ssh"
echo "  2. sudo reboot  (next boot will be headless — no GUI)"

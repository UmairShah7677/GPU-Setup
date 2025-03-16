#!/bin/bash

# Absolute path to this script (used for scheduling on reboot)
SCRIPT_PATH="$(realpath "$0")"
# Flag file to indicate that pre‑reboot tasks are done
FLAG_FILE="/tmp/setup_continue.flag"

# Function to remove the @reboot cron job for this script
remove_cron() {
    crontab -l 2>/dev/null | grep -v "@reboot $SCRIPT_PATH" | crontab -
}

if [ -f "$FLAG_FILE" ]; then
  echo "Resuming post‑reboot steps: Installing cuDNN..."
  # Remove flag file and the scheduled cron job so this block runs only once.
  rm -f "$FLAG_FILE"
  remove_cron

  # ---------------------------
  # Post‑Reboot: Install cuDNN
  # ---------------------------
  echo "Downloading cuDNN installer..."
  wget https://developer.download.nvidia.com/compute/cudnn/9.8.0/local_installers/cudnn-local-repo-ubuntu2404-9.8.0_1.0-1_amd64.deb
  echo "Installing cuDNN package..."
  sudo dpkg -i cudnn-local-repo-ubuntu2404-9.8.0_1.0-1_amd64.deb
  echo "Copying cuDNN keyring..."
  sudo cp /var/cudnn-local-repo-ubuntu2404-9.8.0/cudnn-*-keyring.gpg /usr/share/keyrings/
  echo "Updating package lists..."
  sudo apt-get update
  echo "Installing cuDNN..."
  sudo apt-get -y install cudnn
  echo "cuDNN installation completed."
  exit 0
fi

# ---------------------------
# Pre‑Reboot: Install Anaconda and CUDA
# ---------------------------

echo "Starting pre‑reboot setup tasks..."

# --- Anaconda Installation ---
echo "Downloading Anaconda installer..."
wget https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh
echo "Making installer executable..."
chmod +x Anaconda3-2024.10-1-Linux-x86_64.sh
echo "Installing Anaconda (batch mode)..."
# The -b flag installs Anaconda silently.
./Anaconda3-2024.10-1-Linux-x86_64.sh -b
echo "Sourcing ~/.bashrc to update PATH..."
source ~/.bashrc
echo "Anaconda installation completed."

# --- CUDA Installation ---
echo "Downloading CUDA repository pin..."
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin
echo "Moving CUDA pin file..."
sudo mv cuda-ubuntu2404.pin /etc/apt/preferences.d/cuda-repository-pin-600

echo "Downloading CUDA local installer..."
wget https://developer.download.nvidia.com/compute/cuda/12.8.1/local_installers/cuda-repo-ubuntu2404-12-8-local_12.8.1-570.124.06-1_amd64.deb
echo "Installing CUDA repository package..."
sudo dpkg -i cuda-repo-ubuntu2404-12-8-local_12.8.1-570.124.06-1_amd64.deb
echo "Copying CUDA keyring..."
sudo cp /var/cuda-repo-ubuntu2404-12-8-local/cuda-*-keyring.gpg /usr/share/keyrings/
echo "Updating package lists..."
sudo apt-get update
echo "Installing CUDA Toolkit 12.8..."
sudo apt-get -y install cuda-toolkit-12-8

echo "Installing CUDA drivers..."
sudo apt-get install -y cuda-drivers

# ---------------------------
# Prompt for Reboot
# ---------------------------
read -p "CUDA installation requires a reboot to load NVIDIA drivers. Reboot now? (yes/no): " answer
if [ "$answer" = "yes" ]; then
  echo "Scheduling continuation after reboot..."
  # Create a flag file to indicate post-reboot continuation
  touch "$FLAG_FILE"
  # Schedule this script to run at reboot using cron.
  (crontab -l 2>/dev/null; echo "@reboot $SCRIPT_PATH") | crontab -
  echo "Rebooting now..."
  sudo reboot
else
  echo "Reboot skipped. You must reboot manually before installing cuDNN."
  exit 0
fi

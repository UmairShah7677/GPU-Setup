Below is an example **README.md** file for your repository:

---

```markdown
# GPU Setup Script

This repository contains a shell script that automates the installation of key GPU-related software components on Ubuntu 24 servers (e.g., from Hetzner). The script installs:

- **Anaconda** (Anaconda3-2024.10-1)
- **CUDA Toolkit 12.8** (with required NVIDIA drivers)
- **cuDNN 9.8.0**

Because the CUDA installation requires a reboot for the NVIDIA drivers to load correctly, the script is designed to prompt for a reboot. It then automatically resumes on reboot to complete the cuDNN installation.

## Files

- **setup_gpu.sh**  
  The main shell script that installs Anaconda and CUDA, prompts for a reboot, and then installs cuDNN after reboot.

## Prerequisites

- An Ubuntu 24 system (such as those provided by Hetzner).
- Sudo privileges to install packages and modify system settings.
- An active internet connection to download the necessary installers.

## How It Works

1. **Pre-Reboot Tasks:**
   - Downloads and installs **Anaconda** in batch mode.
   - Downloads and installs **CUDA Toolkit 12.8** and the associated NVIDIA drivers.
   - Prompts you to reboot the system so that the new NVIDIA drivers can load.

2. **Post-Reboot Tasks:**
   - On reboot, an `@reboot` cron job automatically re-runs the script.
   - The script detects that it is running post-reboot and installs **cuDNN 9.8.0**.
   - After completing the cuDNN installation, the script cleans up the flag file and cron job to ensure it only runs once.

## Usage

1. **Clone this repository:**

   ```bash
   git clone https://github.com/UmairShah7677/GPU-Setup
   cd server_setup
   ```

2. **Make the script executable:**

   ```bash
   chmod +x setup_gpu.sh
   ```

3. **Run the script:**

   ```bash
   ./setup_gpu.sh
   ```

4. **Follow the prompts:**
   - The script will install Anaconda and CUDA.
   - When prompted, type `yes` to allow the reboot.
   - After reboot, the script will automatically resume and install cuDNN.

## Customization

- **Anaconda Installer:**  
  The script uses the [Anaconda3-2024.10-1-Linux-x86_64.sh](https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh) installer in batch mode. Adjust the script if you need a different version or interactive installation.

- **CUDA and cuDNN Versions:**  
  The script installs CUDA Toolkit 12.8 and cuDNN 9.8.0 based on direct download links and package installation commands. Modify these commands as needed for different versions or if your distribution changes.

## Troubleshooting

- **Reboot Issues:**  
  If the server does not reboot or the post-reboot section does not execute, ensure that:
  - You have the necessary sudo privileges.
  - The cron job is correctly set up (check your crontab with `crontab -l`).
  - The flag file (`/tmp/setup_continue.flag`) exists before reboot and is removed after the post-reboot tasks.

- **Installation Errors:**  
  Review the output logs for error messages. Ensure that network connectivity is available and that all dependencies are met.

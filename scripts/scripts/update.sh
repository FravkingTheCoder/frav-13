#!/bin/bash

# --- Arch Linux Update Script (Interactive with Pause on Lock) ---
# ... (comments) ...

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Starting System Update Process ---"
echo "Timestamp: $(date)"
echo ""

# --- 1. Create Timeshift Backup ---
echo "[TASK] Creating Timeshift backup..."
# ... (rest of your timeshift command) ...
sudo timeshift --create --comments "Pre-update backup $(date +'%Y-%m-%d %H:%M:%S')"
echo "[SUCCESS] Timeshift backup created successfully."
echo ""

# --- 2. Update Official Repositories (pacman) ---
echo "[TASK] Updating official repository packages (pacman)..."
# ... (rest of your pacman command) ...
sudo yay -Syu
echo "[SUCCESS] Pacman update complete."
echo ""

# --- 3. Update AUR Packages (using yay) ---
# ... (rest of your yay section) ...

# --- 4. Update Flatpak Packages ---
# ... (rest of your flatpak section) ...

echo "--- System Update Process Finished ---"
echo "You can close this terminal."
read -p "Press Enter to close..."

exit 0



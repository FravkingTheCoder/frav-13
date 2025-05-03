#!/bin/bash
#  --- Arch Linux Update Script (Interactive with Pause on Lock) ---
# ... (comments) ...

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Check Screen Lock Status and Wait if Locked ---
SESSION_ID=$XDG_SESSION_ID
if [ -z "$SESSION_ID" ]; then
  echo "Error: Could not determine session ID. Cannot check lock status." >&2
  # Decide how to handle: exit or proceed? Exiting is safer.
  read -p "Could not check lock status due to missing session ID. Press Enter to exit..."
  exit 1
fi

# Initial check
LOCKED_HINT=$(loginctl show-session "$SESSION_ID" -p LockedHint --value)

if [ "$LOCKED_HINT" = "yes" ]; then
  echo "Screen is locked. Pausing script until screen is unlocked..."
  echo "(Will check status every 60 seconds)"

  # Loop while the screen is locked
  while [ "$LOCKED_HINT" = "yes" ]; do
    sleep 60 # Wait for 60 seconds before checking again
    # Re-check the lock status
    LOCKED_HINT=$(loginctl show-session "$SESSION_ID" -p LockedHint --value)
    # Optional: Add a timestamp or dot to show it's still checking
    # echo -n "." # Prints a dot without a newline
  done

  # This point is reached only when the loop exits (screen unlocked)
  echo "" # Newline after any dots printed
  echo "Screen unlocked! Resuming update process..."
  echo ""
else
  # Screen was not locked initially
  echo "Screen is unlocked. Proceeding with update..."
  echo ""
fi
# --- End Check Screen Lock Status ---


# --- Arch Linux Update Script (Interactive) ---
# 1. Create Timeshift backup
# 2. Update pacman packages
# 3. Update AUR packages (using yay)
# 4. Update Flatpak packages

echo "--- Starting System Update Process ---"
echo "Timestamp: $(date)"
echo ""

# --- 1. Create Timeshift Backup ---
echo "[TASK] Creating Timeshift backup..."
if ! command -v timeshift &> /dev/null; then
    echo "[ERROR] 'timeshift' command not found. Please install Timeshift."
    read -p "Press Enter to exit..." # Pause for user
    exit 1
fi
# Create a new backup with a comment including the date
# Sudo will prompt for password in the kitty terminal
sudo timeshift --create --comments "Pre-update backup $(date +'%Y-%m-%d %H:%M:%S')"
echo "[SUCCESS] Timeshift backup created successfully."
echo ""

# --- 2. Update Official Repositories (pacman) ---
echo "[TASK] Updating official repository packages (pacman)..."
# Interactive: will ask for confirmation and sudo password if needed
sudo pacman -Syu
echo "[SUCCESS] Pacman update complete."
echo ""

# --- 3. Update AUR Packages (using yay) ---
if command -v yay &> /dev/null; then
    echo "[TASK] Updating AUR packages (yay)..."
    # Interactive: will ask for confirmation
    yay -Sua
    echo "[SUCCESS] AUR update complete."
    echo ""
else
    echo "[INFO] 'yay' command not found. Skipping AUR update."
    echo "       (If you use a different AUR helper, please edit this script)."
    echo ""
fi

# --- 4. Update Flatpak Packages ---
if command -v flatpak &> /dev/null; then
    echo "[TASK] Updating Flatpak packages..."
    # Interactive: will ask for confirmation
    flatpak update
    echo "[SUCCESS] Flatpak update complete."
    echo ""
else
    echo "[INFO] 'flatpak' command not found. Skipping Flatpak update."
    echo ""
fi

echo "--- System Update Process Finished ---"
echo "You can close this terminal."
# Add a pause at the end so the user can see the final output
read -p "Press Enter to close..."

exit 0


#!/bin/bash

# --- Configuration ---
SCREENSHOT_DIR="$HOME/Pictures/Screenshots" # !!! CHANGE THIS IF NEEDED !!!
FILENAME_PREFIX="screenshot"
# --- End Configuration ---

# Check if wl-copy is installed
if ! command -v wl-copy &> /dev/null; then
    notify-send "Screenshot Error" "wl-copy is not installed. Cannot copy to clipboard."
    # Decide if you want the script to exit or just skip copying
    # exit 1 # Uncomment to exit if wl-copy is missing
fi

# Create the directory if it doesn't exist
mkdir -p "$SCREENSHOT_DIR"

# Generate a unique filename with timestamp
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
OUTPUT_FILE="$SCREENSHOT_DIR/${FILENAME_PREFIX}_${TIMESTAMP}.png"

# Capture the screenshot
CAPTURE_SUCCESSFUL=false
ACTION_TAKEN=""

if [ "$1" == "region" ]; then
    if grim -g "$(slurp)" "$OUTPUT_FILE"; then
        CAPTURE_SUCCESSFUL=true
        ACTION_TAKEN="Region"
    fi
elif [ "$1" == "window" ]; then
    if command -v hyprctl &> /dev/null && command -v jq &> /dev/null; then
        GEOMETRY=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        if [ -n "$GEOMETRY" ] && grim -g "$GEOMETRY" "$OUTPUT_FILE"; then
            CAPTURE_SUCCESSFUL=true
            ACTION_TAKEN="Active window"
        else
            notify-send "Screenshot Error" "Failed to get window geometry or capture window. Taking full screen."
            if grim "$OUTPUT_FILE"; then
                CAPTURE_SUCCESSFUL=true
                ACTION_TAKEN="Full screen (fallback)"
            fi
        fi
    else
        notify-send "Screenshot Error" "hyprctl or jq not found for window capture. Taking full screen."
        if grim "$OUTPUT_FILE"; then
            CAPTURE_SUCCESSFUL=true
            ACTION_TAKEN="Full screen (fallback)"
        fi
    fi
else # Default to full screen
    if grim "$OUTPUT_FILE"; then
        CAPTURE_SUCCESSFUL=true
        ACTION_TAKEN="Full screen"
    fi
fi

# If capture was successful, notify and copy to clipboard
if [ "$CAPTURE_SUCCESSFUL" = true ]; then
    notify-send "Screenshot Taken" "$ACTION_TAKEN saved to $(basename "$OUTPUT_FILE")" -i "$OUTPUT_FILE"

    # Copy to clipboard if wl-copy is available
    if command -v wl-copy &> /dev/null; then
        wl-copy < "$OUTPUT_FILE"
        # You can add another notification for clipboard copy if desired
        # notify-send "Screenshot" "Copied to clipboard" -i "$OUTPUT_FILE"
    fi
else
    notify-send "Screenshot Error" "Failed to capture screenshot."
fi

exit 0


#!/bin/bash

# --- Configuration ---
CAVA_CONFIG_PATH="$HOME/.config/cava/cava_i3blocks_config"
FIFO_PATH="/tmp/cava_fifo"
MAX_BAR_HEIGHT=12 # Should match 'ascii_max_range' in Cava config
NUM_BARS=$(grep -Po '^bars\s*=\s*\K\d+' "$CAVA_CONFIG_PATH") # Read from Cava config

# Characters to represent bar heights (from empty to full)
# Ensure your i3bar font supports these!
# Example using block characters:
BAR_CHARS=(" " "▂" "▃" "▄" "▅" "▆" "▇" "█")
# Example using simple dots/lines (more universally supported):
# BAR_CHARS=(" " "." ":" "|" "¦" "‖" "█")
# Example using Braille (can look very cool if font supports it well):
# You'd need a more complex mapping for Braille as each char has 8 dots

NUM_LEVELS=${#BAR_CHARS[@]}

# --- Functions ---
cleanup() {
    echo "Cleaning up Cava script..."
    kill "$CAVA_PID" >/dev/null 2>&1
    rm -f "$FIFO_PATH"
    exit 0
}

# Trap signals to ensure cleanup
trap cleanup EXIT INT TERM

# --- Main Logic ---

# Create FIFO if it doesn't exist
[ -p "$FIFO_PATH" ] || mkfifo "$FIFO_PATH"

# Start Cava in the background, redirecting its stdout/stderr
# Ensure Cava uses the correct config
cava -p "$CAVA_CONFIG_PATH" >/dev/null 2>&1 &
CAVA_PID=$!

# Check if Cava started (optional, basic check)
sleep 0.5 # Give Cava a moment to start or fail
if ! ps -p $CAVA_PID > /dev/null; then
    echo "Error: Cava failed to start."
    rm -f "$FIFO_PATH"
    exit 1
fi

# Continuously read from FIFO and update i3blocks
while true; do
    if read -r line < "$FIFO_PATH"; then
        output_string=""
        # Split the line by the delimiter (semicolon by default)
        IFS=';' read -ra bar_values <<< "$line"

        for raw_value in "${bar_values[@]}"; do
            # Ensure raw_value is a number and within expected range
            if [[ "$raw_value" =~ ^[0-9]+$ ]] && [ "$raw_value" -le "$MAX_BAR_HEIGHT" ]; then
                # Scale the value to an index for BAR_CHARS
                # Example: if MAX_BAR_HEIGHT is 12 and NUM_LEVELS is 8
                # scaled_index = (raw_value * (8-1)) / 12
                scaled_index=$(( raw_value * (NUM_LEVELS - 1) / MAX_BAR_HEIGHT ))

                # Clamp index to be within array bounds
                if [ "$scaled_index" -ge "$NUM_LEVELS" ]; then
                    scaled_index=$((NUM_LEVELS - 1))
                elif [ "$scaled_index" -lt 0 ]; then
                    scaled_index=0
                fi
                output_string+="${BAR_CHARS[$scaled_index]}"
            else
                output_string+="${BAR_CHARS[0]}" # Default to empty if value is bad
            fi
        done
        echo "$output_string"
        # Add a small sleep to prevent high CPU if Cava updates very fast
        # and to control i3blocks update rate if interval=persist
        # sleep 0.03 # Corresponds to ~30 FPS
    else
        # FIFO might have been closed or Cava died
        # Basic re-check for Cava process
        if ! ps -p $CAVA_PID > /dev/null; then
            echo "Cava died. Exiting."
            break # Exit the while loop
        fi
        sleep 0.1 # Wait a bit before trying to read again
    fi
done

# Fallback cleanup if loop breaks unexpectedly
cleanup



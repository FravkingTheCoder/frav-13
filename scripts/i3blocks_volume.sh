#!/bin/bash

# --- Configuration ---
SINK="@DEFAULT_SINK@"
VOLUME_STEP=5
MAX_VOLUME=100 # Define maximum desired volume

VOL_ICON_MUTED="󰖁 "
VOL_ICON_OFF="󰕾 "
VOL_ICON_LOW=" "
VOL_ICON_MEDIUM=" "
VOL_ICON_HIGH=" "
# --- End Configuration ---

# Function to get volume and mute status using pactl
get_volume_info() {
    local pactl_output
    pactl_output=$(pactl get-sink-volume "$SINK" && pactl get-sink-mute "$SINK")

    if [[ -z "$pactl_output" ]]; then
        SINK_NUM=$(pactl info | grep 'Default Sink:' | awk '{print $3}')
        if [[ -n "$SINK_NUM" ]]; then
             pactl_output=$(pactl --server "$PULSE_SERVER" get-sink-volume "$SINK_NUM" && pactl --server "$PULSE_SERVER" get-sink-mute "$SINK_NUM")
        fi
        if [[ -z "$pactl_output" ]]; then
            echo "  Error"
            exit 1
        fi
    fi

    VOLUME_PERCENT=$(echo "$pactl_output" | grep 'Volume:' | head -n1 | awk '{print $5}' | sed 's/%//')
    IS_MUTED=$(echo "$pactl_output" | grep 'Mute:' | awk '{print $2}')
}

# Handle clicks and scrolls
case "$BLOCK_BUTTON" in
    1) pavucontrol & disown ;;
    3) pactl set-sink-mute "$SINK" toggle ;;
    4) # Scroll up: increase volume
        get_volume_info # Get current volume first
        if [[ "$IS_MUTED" == "yes" ]]; then
            pactl set-sink-mute "$SINK" false # Unmute first if muted
            # Optionally set to a minimum volume if unmuting from 0, e.g., VOLUME_STEP
            # pactl set-sink-volume "$SINK" "${VOLUME_STEP}%"
        elif (( VOLUME_PERCENT < MAX_VOLUME )); then
            NEW_VOL=$((VOLUME_PERCENT + VOLUME_STEP))
            if (( NEW_VOL > MAX_VOLUME )); then
                NEW_VOL=$MAX_VOLUME
            fi
            pactl set-sink-volume "$SINK" "${NEW_VOL}%"
        fi
        ;;
    5) # Scroll down: decrease volume
        get_volume_info # Get current volume first
        if [[ "$IS_MUTED" == "no" ]]; then # Only decrease if not muted
            NEW_VOL=$((VOLUME_PERCENT - VOLUME_STEP))
            if (( NEW_VOL < 0 )); then
                NEW_VOL=0
            fi
            pactl set-sink-volume "$SINK" "${NEW_VOL}%"
        fi
        ;;
esac

# Get current volume and mute status to update display
get_volume_info

# Determine icon based on volume and mute status
ICON="$VOL_ICON_HIGH"
if [[ "$IS_MUTED" == "yes" ]]; then
    ICON="$VOL_ICON_MUTED"
elif (( VOLUME_PERCENT == 0 )); then
    ICON="$VOL_ICON_OFF"
elif (( VOLUME_PERCENT < 34 )); then
    ICON="$VOL_ICON_LOW"
elif (( VOLUME_PERCENT < 67 )); then
    ICON="$VOL_ICON_MEDIUM"
fi

# Output for i3blocks
if [[ "$IS_MUTED" == "yes" ]]; then
    echo "$ICON Muted"
else
    echo "$ICON $VOLUME_PERCENT%"
fi


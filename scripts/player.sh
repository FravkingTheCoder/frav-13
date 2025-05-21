#!/bin/bash

# List of preferred players in order
players=("spotify" "spotifyd" "vlc" "mpv")

# Loop through players to find an active one
for player in "${players[@]}"; do
    status=$(playerctl -p "$player" status 2>/dev/null)
    if [[ "$status" == "Playing" || "$status" == "Paused" ]]; then
        current_player=$player
        break
    fi
done

# If no valid player found, show fallback
if [[ -z "$current_player" ]]; then
    echo "  No media"
    exit
fi

# Get metadata
title=$(playerctl -p "$current_player" metadata title 2>/dev/null)
artist=$(playerctl -p "$current_player" metadata artist 2>/dev/null)
album=$(playerctl -p "$current_player" metadata xesam:album 2>/dev/null)

# Filter bad titles (like weird bracket placeholders)
if [[ -z "$title" || "$title" =~ \[.*\] ]]; then
    echo "  No media"
    exit
fi

# Status icon
if [[ "$status" == "Playing" ]]; then
    icon=""  # Nerd Font pause icon
else
    icon=""  # Nerd Font play icon
fi

# Format display differently for Spotify
if [[ "$current_player" == "spotify" || "$current_player" == "spotifyd" ]]; then
    info="$artist – $title – $album"
else
    info="$title"
fi

# Truncate long display string
max_length=50
if (( ${#info} > max_length )); then
    info="${info:0:max_length}…"
fi

# Final output
echo "  [$info] $icon"


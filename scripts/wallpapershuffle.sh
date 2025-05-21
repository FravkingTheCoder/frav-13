#!/bin/bash

WALLPAPER_DIR="/home/frav/Pictures/Wallpapers"

# Find a random file within the directory
# -maxdepth 1: only look in the WALLPAPER_DIR, not subdirectories
# -type f: only select regular files (not directories, links, etc.)
# -print0: separate filenames with null character (safer)
# shuf -z -n 1: read null-separated input, pick one
# xargs -0 -r echo: print the selected filename (or nothing if no file found)
# -r for xargs: don't run echo if input is empty
FULL_IMG_PATH=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f -print0 | shuf -z -n 1 | xargs -0 -r echo)

if [ -n "$FULL_IMG_PATH" ]; then
  swww img "$FULL_IMG_PATH" --transition-type wipe --transition-fps 144 --transition-angle 45
else
  echo "Error: No image found in $WALLPAPER_DIR or failed to select one."
fi


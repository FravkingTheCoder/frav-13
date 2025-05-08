#!/usr/bin/env bash

# --- Configuration ---
# Set the directory where your wallpapers are stored
WALLPAPER_DIR="$HOME/Pictures/Wallpapers" # !!! CHANGE THIS TO YOUR WALLPAPER FOLDER !!!

# Optional: swww transition settings (leave empty for default)
# Example: SWWW_TRANSITION="--transition-type wipe --transition-angle 30 --transition-step 90"
SWWW_TRANSITION="--transition-type wipe --transition-angle 30 --transition-fps 144"

# Rofi prompt
ROFI_PROMPT="🖼️ Wallpaper:"

# --- Script Logic ---

# Check if swww daemon is running
if ! pgrep -x swww-daemon > /dev/null; then
    rofi -e "swww daemon is not running! Please start it first (e.g., swww init)."
    exit 1
fi

# Check if wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    rofi -e "Wallpaper directory not found: $WALLPAPER_DIR"
    exit 1
fi

# Get list of image files (full paths)
# Using find with -print0 and reading into an array for safety with special characters
IMAGE_FILES=()
while IFS= read -r -d $'\0' file; do
    IMAGE_FILES+=("$file")
done < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.webp" \) -print0 | sort -z)

if [ ${#IMAGE_FILES[@]} -eq 0 ]; then
    rofi -e "No images found in $WALLPAPER_DIR"
    exit 1
fi

# Prepare options for Rofi
# Format: "DisplayName\0icon\x1f/full/path/to/image.png"
# We'll use the filename as DisplayName and the full path as the icon for preview
# We also need to map the DisplayName back to the full path for swww
declare -A FILENAME_TO_FULLPATH_MAP
ROFI_OPTIONS_STRING=""

for fullpath in "${IMAGE_FILES[@]}"; do
    filename=$(basename "$fullpath")
    FILENAME_TO_FULLPATH_MAP["$filename"]="$fullpath"
    # Rofi uses \0icon\x1f to separate the display text from the icon path
    ROFI_OPTIONS_STRING+="${filename}\0icon\x1f${fullpath}\n"
done

# Remove trailing newline from ROFI_OPTIONS_STRING if it exists
ROFI_OPTIONS_STRING=${ROFI_OPTIONS_STRING%\\n}

# Show Rofi and get selection (selected filename)
# -dmenu: Read from stdin, output selected to stdout
# -p: Prompt text
# -i: Case-insensitive search
# -show-icons: Crucial for displaying the previews
# -icon-theme: Optional, but good to specify if your theme relies on it for other things
# -theme: Specify your Rofi theme that's configured for image previews
SELECTED_FILENAME=$(echo -e "$ROFI_OPTIONS_STRING" | rofi \
    -dmenu \
    -p "$ROFI_PROMPT" \
    -i \
    -show-icons \
    -theme /home/frav/.config/rofi/themes/wallpapertheme.rasi \
    )
    # The -theme-str lines are examples; you should put these in your actual theme file

# If a wallpaper was selected (user didn't press Esc), set it
if [ -n "$SELECTED_FILENAME" ]; then
    FULL_PATH_TO_SET="${FILENAME_TO_FULLPATH_MAP["$SELECTED_FILENAME"]}"
    if [ -n "$FULL_PATH_TO_SET" ]; then
        swww img "$FULL_PATH_TO_SET" $SWWW_TRANSITION
        # notify-send "Wallpaper Changed" "Set to $(basename "$FULL_PATH_TO_SET")"
    else
        rofi -e "Error: Could not find full path for '$SELECTED_FILENAME'"
    fi
fi

exit 0


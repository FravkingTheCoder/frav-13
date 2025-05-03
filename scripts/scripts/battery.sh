#!/bin/bash

status=$(acpi -b)
if [[ -z "$status" ]]; then
    echo "  No battery"
    exit
fi

percentage=$(echo "$status" | grep -oP '\d+%' | tr -d '%')
state=$(echo "$status" | grep -oP 'Charging|Discharging|Full')

# Choose icon based on charge level
if (( percentage >= 95 )); then icon=""
elif (( percentage >= 70 )); then icon=""
elif (( percentage >= 45 )); then icon=""
elif (( percentage >= 20 )); then icon=""
else icon=""; fi

# Append charging symbol
[[ "$state" == "Charging" ]] && icon=" $icon"

echo "$icon  $percentage%"


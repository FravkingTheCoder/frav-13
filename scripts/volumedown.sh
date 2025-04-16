#!/bin/bash

pamixer -d 5
vol=$(pamixer --get-volume)
mute=$(pamixer --get-mute)

if [ "$mute" = "true" ]; then
    notify-send -u low -r 9992 -i audio-volume-muted "Volume Muted"
else
    notify-send -u low -r 9992 -h int:value:"$vol" -i audio-volume-low "Volume ↓" "$vol%"
fi


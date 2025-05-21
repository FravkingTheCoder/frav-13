#!/bin/bash

pamixer -t
vol=$(pamixer --get-volume)
mute=$(pamixer --get-mute)

if [ "$mute" = "true" ]; then
    notify-send -u low -r 9992 -i audio-volume-muted "Volume Muted"
else
    notify-send -u low -r 9992 -h int:value:"$vol" -i audio-volume-medium "Volume Unmuted" "$vol%"
fi

DWMBLOCKS_SIGNAL=1
pkill -SIGRTMIN+$DWMBLOCKS_SIGNAL dwmblocks

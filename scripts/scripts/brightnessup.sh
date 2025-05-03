#!/bin/sh

brightnessctl set +10%
level=$(brightnessctl | grep -oP '\(\K[0-9]+(?=%)')

# Send or update notification
notify-send -u low -r 9991 -h int:value:"$level" -i display-brightness "Brightness ↑" "$level%"





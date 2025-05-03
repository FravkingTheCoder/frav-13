#!/bin/bash
fd . ~ | rofi -dmenu -i -p "Find File:" | xargs -r xdg-open


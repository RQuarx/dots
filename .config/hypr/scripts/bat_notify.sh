#!/bin/sh

while true; do
    battery=$(upower -i "$(upower -e | grep BAT)" | grep -E "percentage" | awk '{print $2}' | tr -d '%')
    if [ "$battery" -le "20" ]; then
        dunstify "LOW BATTERY!" "Battery low!"
        sleep 240
    else
        sleep 120
    fi
done
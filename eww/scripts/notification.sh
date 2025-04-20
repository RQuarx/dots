#!/usr/bin/env bash

echo "$(dunstctl history | jq -r ".data[0]" | tr -d '\n')"
prev_history_amount=$(dunstctl count history)

while true; do
    current_history_amount=$(dunstctl count history)

    if [[ $prev_history_amount -ne $current_history_amount ]]; then
        echo "$(dunstctl history | jq -r ".data[0]" | tr -d '\n')"
    fi
    sleep 0.5
done
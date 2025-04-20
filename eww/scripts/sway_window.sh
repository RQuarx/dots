#!/usr/bin/env bash

swaymsg -m -t subscribe '[ "window", "workspace" ]' | while read -r _; do
    echo "$(swaymsg -t get_tree -r | jq -r ".. | select(.type?) | select(.focused==true).name")"
done
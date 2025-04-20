#!/usr/bin/env bash

swaymsg -m -t subscribe '[ "workspace" ]' | while read -r line; do
    current_workspace=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused == true) | .name')
    echo "$current_workspace"
done
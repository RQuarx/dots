#!/usr/bin/env bash

while true; do
    networks=$(nmcli -f IN-USE,SSID dev wifi list)

    json_output="["

    while IFS= read -r line; do
        if [[ "$line" == *"IN-USE"* ]]; then
            continue
        fi

        # Use awk to capture the entire line and split it correctly
        in_use=$(echo "$line" | awk '{print $1}')
        ssid=$(echo "$line" | awk '{$1=""; print substr($0,2)}') # Remove the first field and print the rest

        in_use_bool=$([[ "$in_use" == "*" ]] && echo true || echo false)

        json_output+="{\"in_use\":$in_use_bool,\"ssid\":\"$ssid\"},"
    done <<< "$networks"

    json_output="${json_output%,}]"

    echo "$json_output"

    sleep 5
done
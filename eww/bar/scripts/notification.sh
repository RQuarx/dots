#!/bin/env bash
noti=$(dunstctl history)

output=$(echo $noti | jq '.[] | message')
echo $output
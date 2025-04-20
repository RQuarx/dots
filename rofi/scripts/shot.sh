#!/usr/bin/env bash

set -e

function send_notification() {
    local message="Image saved, and copied to the clipboard."
    [ $CLIPBOARD -eq 1 ] && message="Image copied to the clipboard"

    notify-send "Screenshot saved" "${message}" -t "$NOTIF_TIMEOUT" -i "${1}" -a Hyprshot
}

function trim() {
    local geometry="${1}"
    local xy_str=$(echo "${geometry}" | cut -d' ' -f1)
    local wh_str=$(echo "${geometry}" | cut -d' ' -f2)
    local x=$(echo "${xy_str}" | cut -d',' -f1)
    local y=$(echo "${xy_str}" | cut -d',' -f2)
    local width=$(echo "${wh_str}" | cut -dx -f1)
    local height=$(echo "${wh_str}" | cut -dx -f2)

    local max_width=$(hyprctl monitors -j | jq -r '[.[] | if (.transform % 2 == 0) then (.x + .width) else (.x + .height) end] | max')
    local max_height=$(hyprctl monitors -j | jq -r '[.[] | if (.transform % 2 == 0) then (.y + .height) else (.y + .width) end] | max')
    local min_x=$(hyprctl monitors -j | jq -r '[.[] | (.x)] | min')
    local min_y=$(hyprctl monitors -j | jq -r '[.[] | (.y)] | min')

    local cropped_x=$x
    local cropped_y=$y
    local cropped_width=$width
    local cropped_height=$height

    ((x + width > max_width)) && cropped_width=$((max_width - x))
    ((y + height > max_height)) && cropped_height=$((max_height - y))
    ((x < min_x)) && { cropped_x="$min_x"; cropped_width=$((cropped_width + x - min_x)); }
    ((y < min_y)) && { cropped_y="$min_y"; cropped_height=$((cropped_height + y - min_y)); }

    local cropped=$(printf "%s,%s %sx%s\n" "${cropped_x}" "${cropped_y}" "${cropped_width}" "${cropped_height}")
    echo "${cropped}"
}

function save_geometry() {
    local geometry="${1}"

    mkdir -p "$SAVEDIR"
    grim -g "${geometry}" "$SAVE_FULLPATH"
    wl-copy --type image/png < "$SAVE_FULLPATH"
    [ -n "$COMMAND" ] && "$COMMAND" "$SAVE_FULLPATH"

    send_notification "$SAVE_FULLPATH"
}

function checkRunning() {
    sleep 1
    while pgrep slurp > /dev/null; do
        sleep 1
    done
    pkill hyprpicker
}

function begin_grab() {
    local geometry
    case $1 in
        output)
            geometry=$([ $CURRENT -eq 1 ] && grab_active_output || slurp -or)
            ;;
        region)
            geometry=$(slurp -d)
            ;;
        window)
            geometry=$([ $CURRENT -eq 1 ] && grab_active_window || grab_window)
            geometry=$(trim "${geometry}")
            ;;
    esac

    # Check if geometry is valid before proceeding
    if [[ -z "$geometry" || "$geometry" == *"invalid geometry"* ]]; then
        echo "Invalid geometry detected. Exiting."
        exit 1
    fi

    # Ensure DELAY is set to a default value if not already set
    DELAY=${DELAY:-0}
    [ ${DELAY} -gt 0 ] && sleep ${DELAY}
    save_geometry "${geometry}"
}

function grab_active_output() {
    local active_workspace=$(hyprctl -j activeworkspace)
    local monitors=$(hyprctl -j monitors)
    local current_monitor=$(echo "$monitors" | jq -r 'first(.[] | select(.activeWorkspace.id == '$(echo "$active_workspace" | jq -r '.id')'))')
    echo "$current_monitor" | jq -r '"\(.x),\(.y) \(.width/.scale|round)x\(.height/.scale|round)"'
}

function grab_selected_output() {
    local monitor=$(hyprctl -j monitors | jq -r '.[] | select(.name == "'$1'")')
    echo "$monitor" | jq -r '"\(.x),\(.y) \(.width/.scale|round)x\(.height/.scale|round)"'
}

function grab_window() {
    local monitors=$(hyprctl -j monitors)
    local active_workspace_ids=$(echo "$monitors" | jq -r 'map(.activeWorkspace.id)')

    local clients=$(hyprctl -j clients | jq -r --argjson active_ids "$active_workspace_ids" '
        .[] | select(.workspace.id as $id | $active_ids | index($id)) |
        "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1]) \(.title)"
    ')

    slurp -r <<< "$clients"
}

function grab_active_window() {
    local active_window=$(hyprctl -j activewindow)
    local box=$(echo "$active_window" | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | cut -f1,2 -d' ')
    echo "$box"
}

function parse_mode() {
    case $1 in
        window | region | output)
            OPTION=$1
            ;;
        active)
            CURRENT=1
            ;;
        *)
            hyprctl monitors -j | jq -re '.[] | select(.name == "'$1'")' &>/dev/null && SELECTED_MONITOR=$1
            ;;
    esac
}

function args() {
    local options=$(getopt -o hf:o:m:D:dszr:t: --long help,filename:,output-folder:,mode:,delay:,clipboard-only: -- "$@")
    eval set -- "$options"

    while true; do
        case "$1" in
            -o | --output-folder)
                shift
                SAVEDIR=$1
                ;;
            -m | --mode)
                shift
                parse_mode "$1"
                ;;
            --)
                shift
                COMMAND=${@:2}
                break
                ;;
        esac
        shift
    done

    if [ -z "$OPTION" ]; then

        exit 2
    fi
}

if [ -z "$1" ]; then
    help_message
    exit
fi

CLIPBOARD=0
NOTIF_TIMEOUT=5000
CURRENT=0
[ -z "$XDG_PICTURES_DIR" ] && type xdg-user-dir &> /dev/null && XDG_PICTURES_DIR=$(xdg-user-dir PICTURES)
FILENAME="$(date +'%Y-%m-%d-%H%M%S_hyprshot.png')"
[ -z "$HYPRSHOT_DIR" ] && SAVEDIR=${XDG_PICTURES_DIR:=~} || SAVEDIR=${HYPRSHOT_DIR}

args "$@"

SAVE_FULLPATH="$SAVEDIR/$FILENAME"
begin_grab "$OPTION" & checkRunning
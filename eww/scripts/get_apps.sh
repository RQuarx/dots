#!/usr/bin/env bash

data_dir=$(echo $XDG_DATA_DIRS)
home_dir=$(echo $HOME)
data_dir+=":$home_dir/.local/share"

IFS=':' read -ra paths <<< "$data_dir"
json="{\"apps\":["

for path in "${paths[@]}"; do
    path+="/applications"

    if [ -d "$path" ]; then
        app_details=()

        while IFS= read -r file; do
            if grep -q "^Exec=" "$file" && grep -q "^Type=Application" "$file" && ! grep -q "^NoDisplay=true" "$file"; then
                name=$(grep -m 1 "^Name=" "$file" | cut -d'=' -f2-)
                exec_path=$(grep -m 1 "^Exec=" "$file" | cut -d'=' -f2-)

                app_details+=("{\"name\":\"$name\",\"exec\":\"$exec_path\"}")
            fi
        done < <(find "$path" -type f -name "*.desktop" -print)

        if [ ${#app_details[@]} -gt 0 ]; then
            json+=$(IFS=,; echo "${app_details[*]}")
            json+=","
        fi
    fi
done

json="${json%,}"
json+="]}"

echo "$json"
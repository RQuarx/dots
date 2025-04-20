import subprocess


modes: list[str] = ["output", "region", "window"]
options: list[str] = [' ', '󰆞 ', ' ']

chosen = subprocess.run(
    ["rofi", "-dmenu", "-markup-rows", "-theme", "~/.config/rofi/screenshot.rasi"],
    input="\n".join(options).encode(), stdout=subprocess.PIPE, check=True
).stdout.decode()[0]

subprocess.run(["hyprshot", "-o", "/home/rquarx/Pictures/Screenshots", "-m", modes[[option[0] for option in options].index(chosen)]])

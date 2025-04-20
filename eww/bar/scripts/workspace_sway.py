import subprocess
import json

def get_focused_workspace_number():
    result = subprocess.run(['swaymsg', '-t', 'get_workspaces'], capture_output=True, text=True)
    focused = next((ws for ws in json.loads(result.stdout) if ws['focused']), None)
    if focused:
        print(focused['num'], flush=True)
    else:
        print("No focused workspace found.", flush=True)

get_focused_workspace_number()
process = subprocess.Popen(['swaymsg', '-t', 'subscribe', '["workspace"]', '--monitor'], stdout=subprocess.PIPE, text=True)

try:
    while True:
        if process.stdout.readline():
            get_focused_workspace_number()
except KeyboardInterrupt:
    process.terminate()
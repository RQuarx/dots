import subprocess
import json
import os

if __name__ == "__main__":
    result = subprocess.run(['hyprctl', 'monitors', '-j'], capture_output=True, text=True, check=True)
    focused_workspace_id = next(
        (m['activeWorkspace']['id'] for m in json.loads(result.stdout) if m.get('focused')),
        None
    )

    print(focused_workspace_id, flush=True)

    socket_path = os.path.join(os.environ['XDG_RUNTIME_DIR'], 'hypr', os.environ['HYPRLAND_INSTANCE_SIGNATURE'], '.socket2.sock')

    with subprocess.Popen(f"stdbuf -o0 socat -u UNIX-CONNECT:{socket_path} -", shell=True, stdout=subprocess.PIPE, text=True) as proc:
        for line in proc.stdout:
            if line.startswith("workspace>>"):
                print(line.split('>>')[1].strip(), flush=True)
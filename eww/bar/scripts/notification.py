import subprocess
import json


if __name__ == "__main__":
    json = json.loads(subprocess.run(["dunstctl", "history"], stdout=subprocess.PIPE, text=True).stdout)
    print(json)
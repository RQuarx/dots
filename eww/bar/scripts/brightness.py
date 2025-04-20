import subprocess


def Get_Brightness() -> str:
    result = subprocess.run(['brightnessctl', 'get'], stdout=subprocess.PIPE, text=True)
    return result.stdout.splitlines()[0]


if __name__ == "__main__":
    last_brightness: str = ""

    while True:
        current_brightness = Get_Brightness()
        if (current_brightness and current_brightness != last_brightness):
            print(current_brightness, flush=True)
            last_brightness = current_brightness
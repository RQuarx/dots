import subprocess


def Get_Volume() -> str:
    result = subprocess.run(['amixer', 'get', 'Master'], stdout=subprocess.PIPE, text=True)
    volume = result.stdout.splitlines()
    for line in volume:
        if '%' in line:
            return line.split()[4].strip('[]%')
    return None


def Listen_Volume() -> None:
    last_volume = None

    while True:
        current_volume = Get_Volume()
        if current_volume and current_volume != last_volume:
            print(current_volume, flush=True)
            last_volume = current_volume



if __name__ == "__main__":
    Listen_Volume()
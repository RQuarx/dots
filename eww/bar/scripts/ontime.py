import subprocess


def Get_Volume() -> str:
    result = subprocess.run(['uptime', '-p'], stdout=subprocess.PIPE, text=True)
    part: List[str] = result.stdout.split()
    temp = []

    minute: int = 0
    hour: int = 0

    for i in range(0, len(part)):
        if part[i].isdigit():
            temp.append(part[i])
    
    if len(temp) == 1:
        return f"{temp[0]}"
    else:
        if temp[1] == 0:
            return f"{temp[0]}"
        return f"{temp[0]}:{temp[1]}"


if __name__ == "__main__":
    last_respond = None

    while True:
        current_respond = Get_Volume()
        if current_respond and current_respond != last_respond:
            print(current_respond, flush=True)
            last_respond = current_respond
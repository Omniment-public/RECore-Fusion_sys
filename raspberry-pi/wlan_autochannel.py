import subprocess
import sys

stdout = subprocess.check_output("sudo iwlist wlan0 scan | grep 'Channel:'", shell=True)
stdstr = stdout.decode().rstrip()
stdstr = [line.lstrip('Channel:').strip('"') for line in stdstr.split()]

channel_list = [0] * 13

for i in stdstr:
    if(int(i) < 13):
        channel_list[int(i) - 1] += 1

print(channel_list)

use_ch = channel_list.index(min(channel_list)) + 1
print(use_ch)
sys.exit(0)

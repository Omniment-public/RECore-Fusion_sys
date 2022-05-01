import subprocess
import re

stdout = subprocess.check_output("sudo iwlist wlan0 scan | grep 'Channel:'", shell=True)
stdstr = stdout.decode().rstrip()
stdstr = [line.lstrip('Channel:').strip('"') for line in stdstr.split()]

channel_list = [0] * 13

for i in stdstr:
    channel_list[int(i) - 1] += 1

print(channel_list)

use_ch = channel_list.index(min(channel_list)) + 1

conf = open('/etc/hostapd/hostapd.conf',mode='r')
write_conf = conf.read()
conf.close()

re.search('channel=[0-9]{,2}',write_conf)
write_conf = re.sub('channel=[0-9]{,2}','channel='+str(use_ch),write_conf)

conf = open('/etc/hostapd/hostapd.conf',mode='w')
conf.write(write_conf)
conf.close()

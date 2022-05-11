import json
import subprocess
import re

#check registered ssid
conf = open('/etc/wpa_supplicant/wpa_supplicant.conf',mode='r')
read_conf = conf.read()
conf.close()
ssid_list = re.findall('ssid=.*\n',read_conf)

trim_list = []
for pick_ssid in ssid_list:
	trim_list.append(pick_ssid.strip().replace('ssid=','').replace('"',''))


stdout = subprocess.check_output("sudo iwlist wlan0 scan | grep 'ESSID:\".\+\"'",shell=True)
stdstr = stdout.decode().rstrip()
ssid_list = [line.lstrip('ESSID:').strip('"') for line in stdstr.split()]

for pick_ssid in trim_list:
	ssid_list.remove(pick_ssid)

ssid_json = []

for ssid in ssid_list:
	ssid_json.append({'ssid':ssid})

print(json.dumps(ssid_json),end='')

import subprocess
import re
import json

conf = open('/etc/hostapd/hostapd.conf',mode='r')
read_conf = conf.read()
conf.close()

ssid = re.search('ssid=.*\n',read_conf).group().strip().replace('ssid=','')

ssid_json = []
ssid_json.append({'ap_ssid':ssid})

print(json.dumps(ssid_json), end= '')

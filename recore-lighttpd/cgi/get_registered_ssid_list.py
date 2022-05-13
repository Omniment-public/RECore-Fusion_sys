import re
import json

conf = open('/etc/wpa_supplicant/wpa_supplicant.conf',mode='r')
read_conf = conf.read()
conf.close()

ssid_list = re.findall('ssid=.*\n',read_conf)

registered_ssid_ssid_json = []
for pick_ssid in ssid_list:
	registered_ssid_ssid_json.append({'registered_ssid':pick_ssid.strip().replace('ssid=','').replace('"','')})

print(json.dumps(registered_ssid_ssid_json), end= '')

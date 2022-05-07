import re
import json

# ap_ssid_load
conf = open('/etc/hostapd/hostapd.conf',mode='r')
read_conf = conf.read()
conf.close()

ssid = re.search('ssid=.*\n',read_conf).group().strip('"').replace('ssid=','')

# hostname load
conf = open('/etc/hostname',mode='r')
read_conf = conf.read()
conf.close()

hostname = read_conf.rstrip()

state_json = []
state_json.append({'ap_ssid':ssid})
state_json.append({'hostname':hostname})

print(json.dumps(state_json), end= '')

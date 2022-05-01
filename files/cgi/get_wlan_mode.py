import json
import sys

conf = open('/usr/local/bin/wlan_mode',mode='r')
read_conf = conf.read()
conf.close()

state_json = []
state_json.append({'wlan_mode':read_conf})

print(json.dumps(state_json), end= '')

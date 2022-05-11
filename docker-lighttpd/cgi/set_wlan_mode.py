import json
import sys

rec_data = sys.stdin.read()
rec_json = json.loads(rec_data)

set_state = rec_json['wlan_mode']

conf = open('/usr/local/bin/recore/files/wlan_mode',mode='w')
conf.write(str(set_state))
conf.close()

print("Status: 204 No Content\r\n\r\n")

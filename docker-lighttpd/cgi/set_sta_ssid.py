import json
import sys

rec_data = sys.stdin.read()
rec_json = json.loads(rec_data)

set_ssid = rec_json['ssid']
set_pass = rec_json['pass']

conf = open('/etc/wpa_supplicant/wpa_supplicant.conf',mode='a')
conf.writelines('\n')
conf.writelines('network={\n')
conf.writelines('	ssid="'+set_ssid+'"\n')
conf.writelines('	psk="'+set_pass+'"\n')
conf.writelines('}')
conf.close()

#print(json.dumps(respon_json), end= '')
print("Status: 204 No Content\r\n\r\n")

import re
import json
import sys

rec_data = sys.stdin.read()
rec_json = json.loads(rec_data)

set_ssid = rec_json['ssid']
set_pass = rec_json['pass']

conf = open('/etc/hostapd/hostapd.conf',mode='r')
write_conf = conf.read()
conf.close()

write_conf = re.sub('ssid=.*\n','ssid='+str(set_ssid)+'\n',write_conf)
write_conf = re.sub('wpa_passphrase=.*\n','wpa_passphrase='+str(set_pass)+'\n',write_conf)

conf = open('/etc/hostapd/hostapd.conf',mode='w')
conf.write(write_conf)
conf.close()

print("Status: 204 No Content\r\n\r\n")

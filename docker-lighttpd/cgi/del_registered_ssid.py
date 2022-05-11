import re
import json
import sys

conf = open('/etc/wpa_supplicant/wpa_supplicant.conf',mode='r')
read_conf = conf.read()
conf.close()

#get del number
rec_data = sys.stdin.read()
rec_json = json.loads(rec_data)
del_num_list = rec_json['del_num']

ssid_list = re.findall('network=[\s\S\n]*?\}',read_conf)
write_conf = re.sub(ssid_list[del_num_list],'',read_conf)

conf = open('/etc/wpa_supplicant/wpa_supplicant.conf',mode='w')
conf.write(write_conf)
conf.close()

print("Status: 204 No Content\r\n\r\n")

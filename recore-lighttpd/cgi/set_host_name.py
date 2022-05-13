import json
import sys
import re

rec_data = sys.stdin.read()
rec_json = json.loads(rec_data)

set_hostname = rec_json['hostname']

conf = open('/etc/hosts',mode='r')
write_conf = conf.read()
conf.close()

write_conf = re.sub('127.0.1.1.*\n','127.0.1.1\t'+str(set_hostname)+'\n',write_conf)
conf = open('/etc/hosts',mode='w')
conf.write(write_conf)
conf.close()

conf = open('/etc/hostname',mode='w')
conf.write(set_hostname)
conf.close()

print("Status: 204 No Content\r\n\r\n")

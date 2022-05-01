import subprocess
import re

conf = open('/etc/hostname',mode='r')
read_conf = conf.read()
conf.close()

hostname = read_conf.rstrip()

hostname_json = []
hostname_json.append({'ap_ssid':ssid})

print(hostname)

import re
import json

# ap_ssid_load
conf = open('/etc/hostapd/hostapd.conf',mode='r')
read_conf = conf.read()
conf.close()

ssid = re.search('ssid=.*\n',read_conf).group().rstrip().replace('ssid=','')

# hostname load
conf = open('/etc/hostname',mode='r')
read_conf = conf.read()
conf.close()

hostname = read_conf.rstrip()

# sys version load
app_dir="/usr/local/bin/recore/files/app/RECore-Fusion_sys"
app_file = open(app_dir,mode='r')
app_info = app_file.read()
app_file.close()
version = re.search('version=.*\n',app_info).group().rstrip().replace('version=','').replace('"','')

state_json = []
state_json.append({'ap_ssid':ssid})
state_json.append({'hostname':hostname})
state_json.append({'sys_version':version})

print(json.dumps(state_json), end= '')

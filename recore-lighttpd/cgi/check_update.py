import requests
import json
from distutils.version import LooseVersion, StrictVersion
import os
import re

app_dir='/usr/local/bin/recore/files/app'
app_list = os.listdir(path=app_dir)

update_list = {}

for app_name in app_list:
	app_file = open('/usr/local/bin/recore/files/app/'+app_name,mode='r')
	app_info = app_file.read()
	app_file.close()
	version = re.search('version=.*\n',app_info).group().rstrip().replace('version=','').replace('"','')
	repo = re.search('repo=.*\n',app_info).group().rstrip().replace('repo=','').replace('"','')
	try :
		response = requests.get('https://api.github.com/repos/'+repo+'/releases/latest')
	except :
		update_list[app_name] = "Error"
		break
	
	data = response.json()
	try:
		latest_version = data["tag_name"]
	except:
		update_list[app_name] = "Error"
		break
	
	if LooseVersion(latest_version) > LooseVersion(version) :
		update_list[app_name] = version
	else :
		update_list[app_name] = "latest"
	
	print(update_list)

response = requests.get('https://api.github.com/repos/Omniment-public/RECore-Fusion_sys/releases/latest')
data = response.json()

latest_version = data["tag_name"]
latest_link = data["tarball_url"]

read_version = open('/usr/local/bin/recore/files/version',mode='r')
sys_version = read_version.read()
read_version.close()

state_json = []

if LooseVersion(latest_version) > LooseVersion(sys_version) :
	state_json.append({'status':'true'})
	state_json.append({'version':latest_version})
else:
	state_json.append({'status':'false'})
	state_json.append({'version':latest_version})

print(state_json)

response = requests.get('https://api.github.com/repos/Omniment-public/RECore-arduino_tinydfu_tools/releases/latest')

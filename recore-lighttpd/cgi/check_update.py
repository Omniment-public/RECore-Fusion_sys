import requests
import json
from distutils.version import LooseVersion, StrictVersion
import os
import re

app_dir='/usr/local/bin/recore/files/app'
app_list = os.listdir(path=app_dir)

update_list = []

for app_name in app_list:
	app_file = open('/usr/local/bin/recore/files/app/'+app_name,mode='r')
	app_info = app_file.read()
	app_file.close()
	version = re.search('version=.*\n',app_info).group().rstrip().replace('version=','').replace('"','')
	repo = re.search('repo=.*\n',app_info).group().rstrip().replace('repo=','').replace('"','')
	try :
		response = requests.get('https://api.github.com/repos/'+repo+'/releases/latest')
	except :
		update_list.append({'app_name':app_name,'version':'Error'})
		break
	
	if(response.status_code == 200) :
		data = response.json()
	else :
		update_list.append({'app_name':app_name,'version':'Error'})
		break

	try:
		latest_version = data["tag_name"]
	except:
		update_list.append({'app_name':app_name,'version':'Error'})
		break
	
	if LooseVersion(latest_version) > LooseVersion(version) :
		update_list.append({'app_name':app_name,'version':version})
	else :
		update_list.append({'app_name':app_name,'version':'latest'})

print(json.dumps(update_list), end= '')

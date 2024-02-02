import requests
import json
from packaging import version
import os
import re

app_dir='/usr/local/bin/recore/files/app'
app_list = os.listdir(path=app_dir)

update_list = []

for app_name in app_list:
	err_state = False
	app_file = open('/usr/local/bin/recore/files/app/'+app_name,mode='r')
	app_info = app_file.read()
	app_file.close()
	get_version = re.search('version=.*\n',app_info).group().rstrip().replace('version=','').replace('"','')
	repo = re.search('repo=.*\n',app_info).group().rstrip().replace('repo=','').replace('"','')
	try :
		response = requests.get('https://api.github.com/repos/'+repo+'/releases/latest')
	except :
		update_list.append({'app_name':app_name,'version':'Error'})
		continue
	
	if(response.status_code == 200) :
		data = response.json()
	else :
		update_list.append({'app_name':app_name,'version':'Error'})
		continue
	
	try:
		latest_version = data["tag_name"]
	except:
		update_list.append({'app_name':app_name,'version':'Error'})
		continue
	
	if version.parse(latest_version) > version.parse(get_version) :
		update_list.append({'app_name':app_name,'version':latest_version})
	else :
		update_list.append({'app_name':app_name,'version':'latest'})

print(json.dumps(update_list), end= '')

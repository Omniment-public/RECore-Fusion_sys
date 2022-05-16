import requests
import json
from distutils.version import LooseVersion, StrictVersion
import os
import re
import subprocess

app_dir='/usr/local/bin/recore/files/app'
app_list = os.listdir(path=app_dir)

update_list = []
exec_list = []

for app_name in app_list:
	err_state = False
	app_file = open('/usr/local/bin/recore/files/app/'+app_name,mode='r')
	app_info = app_file.read()
	app_file.close()
	version = re.search('version=.*\n',app_info).group().rstrip().replace('version=','').replace('"','')
	repo = re.search('repo=.*\n',app_info).group().rstrip().replace('repo=','').replace('"','')
	try :
		response = requests.get('https://api.github.com/repos/'+repo+'/releases/latest')
	except :
		update_list.append({'app_name':app_name,'version':'Error'})
		continue
	
	if(response.status_code == 200) :
		latest_resp = response.json()
	else :
		update_list.append({'app_name':app_name,'version':'Error'})
		continue
	
	try :
		assets_url = latest_resp["assets_url"]
		latest_version = latest_resp["tag_name"]
	except :
		update_list.append({'app_name':app_name,'version':'Error'})
		continue
	
	try :
		assets_resp = requests.get(assets_url)
	except :
		update_list.append({'app_name':app_name,'version':'Error'})
		continue
	
	installer_url = ""
	assets_json = assets_resp.json()
	for assets_dict in assets_json :
		if(app_name+'-'+latest_version + '.tar.gz' in assets_dict.values()) :
			installer_url = assets_dict['url']
			break
	
	#if(installer_url != ""):
	#	dl_dir = "/usr/local/bin/recore/install/"+app_name
	#	os.mkdir(dl_dir)
	#	subprocess.run("sudo curl -l -o " + dl_dir + "installer.tar.gz " + installer_url, shell = True)
	#	queue = open('/usr/local/bin/recore/install/install_queue',mode='a')
	#	queue.write(app_name)
	#	queue.close()
	#	break
	#else:
	#	update_list[app_name] = "Error"

	if LooseVersion(latest_version) > LooseVersion(version) :
		if(installer_url != ""):
			dl_dir = "/usr/local/bin/recore/install/"+app_name
			try :
				os.mkdir(dl_dir)
			except :
				pass
			subprocess.run("sudo curl -Lo " + dl_dir + "/installer.tar.gz " + "-H 'Accept: application/octet-stream' " + installer_url, shell = True)
			exec_list.append(app_name)
			update_list.append({'app_name':app_name,'version':latest_version})
		else:
			update_list.append({'app_name':app_name,'version':'Error'})
			continue
	else :
		update_list.append({'app_name':app_name,'version':'latest'})
	
queue = open('/usr/local/bin/recore/install/install_queue',mode='w')
for exec_app in exec_list :
	queue.write(exec_app + "\n")

queue.close()

print(json.dumps(update_list), end= '')

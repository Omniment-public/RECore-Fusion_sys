import requests
import json
from distutils.version import LooseVersion, StrictVersion
import os
import re
import subprocess

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
	try :
		latest_version = data["tag_name"]
		latest_link = data["tarball_url"]
	except :
		update_list[app_name] = "Error"
		break
	
	if LooseVersion(latest_version) > LooseVersion(version) :
		# exec update
		try :
			subprocess.run("sudo mkdir /usr/local/bin/recore/install/" + app_name,shell=True)
			subprocess.run("sudo curl -l -o installer.tar.gz " + latest_link, shell = True)
			subprocess.run("sudo bash -c \"echo " + app_name + " >> /usr/local/bin/recore/install/install_queue\"", shell=True)
			subprocess.run("sudo bash -c \"echo recore-jupyter >> /usr/local/bin/recore/install/install_queue\"", shell=True)
		except :
			update_list[app_name] = "Error"
			break
		#update_file = requests.get(latest_link)
		#save_update = open('/usr/local/bin/recore/update/update.tar.gz',mode='wb')
		#save_update.write(update_file.content)
		#save_update.close()
	else :
		update_list[app_name] = "latest"
	
	print(update_list)


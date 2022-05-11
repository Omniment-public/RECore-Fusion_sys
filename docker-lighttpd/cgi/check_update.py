import requests
import json
from distutils.version import LooseVersion, StrictVersion

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

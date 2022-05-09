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

if LooseVersion(sys_version) > LooseVersion(latest_version):
	update_file = requests.get(latest_link)
	save_update = open('/usr/local/bin/recore/update/update.tar.gz',mode='wb')
	save_update.write(update_file.content)
	save_update.close()


import requests

response = requests.get('https://api.github.com/repos/Omniment-public/RECore-Fusion_sys/tarball/v0.0.0')

with open('update.tar.gz', 'wb') as f:
    f.write(response.content)

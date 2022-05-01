import subprocess
import json
import sys

rec_data = sys.stdin.read()
rec_json = json.loads(rec_data)

set_hostname = rec_json['hostname']

subprocess.run("sudo raspi-config nonint do_hostname " + set_hostname, shell=True)

print("Status: 204 No Content\r\n\r\n")

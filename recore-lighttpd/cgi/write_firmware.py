import json
from distutils.version import LooseVersion, StrictVersion
import subprocess

firmware_dir = "/usr/local/bin/recore/recore-firmware/"
state = subprocess.run(firmware_dir + "RECore_uart_writer_silent_aarc64 /dev/ttyAMA0 " + firmware_dir + "RECoreFusion_Firmware.ino.bin 0x80x80000000 104", shell=True)
return_json = []

if(state.returncode == 0) :
	return_json.append({'result':'true'})
else :
	return_json.append({'result':'false'})

print(json.dumps(return_json), end= '')

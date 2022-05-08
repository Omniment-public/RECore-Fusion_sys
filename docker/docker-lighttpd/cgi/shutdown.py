import subprocess

subprocess.run('sudo systemctl poweroff',shell=True)
print("Status: 204 No Content\r\n\r\n")

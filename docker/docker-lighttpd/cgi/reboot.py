import subprocess

subprocess.run('sudo systemctl reboot',shell=True)
print("Status: 204 No Content\r\n\r\n")

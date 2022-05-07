import subprocess

subprocess.run('sudo /sbin/shutdown -h now',shell=True)
print("Status: 204 No Content\r\n\r\n")

import subprocess

subprocess.run('sudo /sbin/shutdown -r now',shell=True)
print("Status: 204 No Content\r\n\r\n")

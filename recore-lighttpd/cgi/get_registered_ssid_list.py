#!/usr/bin/env python3
import subprocess, json, re, sys

def nmcli(*args):
    try:
        return subprocess.check_output(["nmcli", *args], text=True)
    except subprocess.CalledProcessError as e:
        if "not authorized" in (e.output or ""):
            return subprocess.check_output(["sudo", "-n", "nmcli", *args], text=True)
        raise

# --- Wi-Fi プロファイル名一覧 ---
names = nmcli("-t", "-f", "NAME,TYPE", "connection", "show").splitlines()
wifi_names = [
    line.split(":")[0]
    for line in names
    if re.search(r':(wifi|802-11-wireless)$', line)
]

# --- SSID を収集 ---
registered = set()
for n in wifi_names:
    try:
        ssid = nmcli("-g", "802-11-wireless.ssid", "connection", "show", n).strip()
        if ssid:
            registered.add(ssid)
    except subprocess.CalledProcessError:
        pass

print("Content-Type: application/json\n")
print(json.dumps([{"registered_ssid": s} for s in sorted(registered)]), end="")

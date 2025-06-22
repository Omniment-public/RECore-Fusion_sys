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
# ① TYPE が Wi-Fi のものを列挙
names = nmcli("-t", "-f", "NAME,TYPE", "connection", "show").splitlines()

# ② mode が ap でないものだけ残す
wifi_names = []
for line in names:
    if not re.search(r':(wifi|802-11-wireless)$', line):
        continue
    name = line.split(":")[0]
    # mode は '' または 'infrastructure' が STA、'ap' が AP
    try:
        mode = nmcli("-g", "802-11-wireless.mode", "connection", "show", name).strip()
    except subprocess.CalledProcessError:
        mode = ""
    if mode == "ap":
        continue          # AP 用プロファイルはスキップ
    wifi_names.append(name)

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

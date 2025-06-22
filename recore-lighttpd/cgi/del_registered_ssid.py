#!/usr/bin/env python3
"""
del_registered_ssid.py  (NM 版)

stdin(JSON): {"del_num": <int>}
  0 → 一覧の先頭、1 → 次、…  範囲外は NOOP

手順:
 1. nmcli で Wi-Fi プロファイル (sta-*) を列挙
 2. インデックスに対応するプロファイル名を取得
 3. nmcli connection delete <name> で削除
 4. HTTP 204 を返して終了
"""

import json, subprocess, re, sys

WLAN = "wlan0"
AP_PROFILE = "recore-ap"        # 削除対象から除外

# ---------- ユーティリティ ----------
def nmcli(*args):
    return subprocess.check_output(["sudo", "-n", "nmcli", *args], text=True)
    
    #try:
    #    return subprocess.check_output(["sudo","nmcli", *args], text=True)
    #except subprocess.CalledProcessError as e:
    #    if "not authorized" in (e.output or ""):
    #        return subprocess.check_output(["sudo", "-n", "nmcli", *args], text=True)
    #    raise

# ---------- 0. 入力を取得 ----------
try:
    idx = int(json.load(sys.stdin)["del_num"])
except Exception as e:
    print("Status: 400 Bad Request\r\n\r\n")
    sys.stderr.write(f"bad input: {e}\n")
    sys.exit(1)

# ---------- 1. Wi-Fi プロファイル一覧を取得 (AP 用を除外) ----------
names = nmcli("-t","-f","NAME,TYPE","connection","show").splitlines()
wifi_names = [
    line.split(":")[0]
    for line in names
    if re.search(r':(wifi|802-11-wireless)$', line)
       and line.split(":")[0] != AP_PROFILE
]

# ---------- 2. インデックスが範囲内なら削除 ----------
if 0 <= idx < len(wifi_names):
    target = wifi_names[idx]
    nmcli("connection","delete",target)

# ---------- 3. 常に 204 応答 ----------
print("Status: 204 No Content\r\n")

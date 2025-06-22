#!/usr/bin/env python3
"""
set_sta_ssid.py  (NM 版)
stdin(JSON):  {"ssid":"<AP名>", "pass":"<パスフレーズ>"}
動作:
 1. "sta-<SSID>" という ID でプロファイルを検索
 2. 見つかれば ssid/psk を更新、無ければ add
 3. 自動接続=on, 優先度=100
 4. HTTP 204 No Content を返して終了
※ www-data が sudo -n nmcli を実行できる sudoers 行を追加しておくこと
"""

import json, sys, re, subprocess

# ---------- 0. 入力パース ----------
try:
    req = json.load(sys.stdin)
    ssid = req["ssid"]
    psk  = req["pass"]
except Exception as e:
    print("Status: 400 Bad Request\r\n\r\n")
    sys.stderr.write(f"input error: {e}\n")
    sys.exit(1)

# ---------- 1. プロファイル名生成 ----------
def sanitize(s):
    return re.sub(r'[^A-Za-z0-9_-]', '_', s)

name = ("sta-" + sanitize(ssid))[:32]   # NM 名は32文字上限

# ---------- 2. nmcli を安全に呼ぶヘルパー ----------
def nmcli(*args):
    subprocess.check_call(["sudo", "-n", "nmcli", *args])
    #
    #try:
    #    subprocess.check_call(["nmcli", *args])
    #except subprocess.CalledProcessError as e:
    #    # polkit権限不足→sudo で再実行
    ##    if e.stderr and (b"not authorized" in e.stderr or b"Insufficient privileges" in e.stderr):
    #        subprocess.check_call(["sudo", "-n", "nmcli", *args])
    #    else:
    #        raise

# ---------- 3. 既存プロファイル有無を確認 ----------
exists = subprocess.check_output(
    ["sudo","nmcli","-t","-f","NAME","connection","show"], text=True
).splitlines()

if name in exists:
    # 上書き
    nmcli("connection", "modify", name,
          "802-11-wireless.ssid", ssid,
          "802-11-wireless-security.key-mgmt", "wpa-psk",
          "802-11-wireless-security.psk", psk,
          "connection.autoconnect", "yes",
          "connection.autoconnect-priority", "100")
else:
    # 新規追加
    nmcli("connection", "add",
          "type", "wifi",
          "ifname", "wlan0",
          "con-name", name,
          "ssid", ssid,
          "wifi-sec.key-mgmt", "wpa-psk",
          "wifi-sec.psk", psk,
          "ipv4.method", "auto",
          "ipv6.method", "ignore",
          "connection.autoconnect", "yes",
          "connection.autoconnect-priority", "100")

# ---------- 4. 成功応答 ----------
print("Status: 204 No Content\r\n")

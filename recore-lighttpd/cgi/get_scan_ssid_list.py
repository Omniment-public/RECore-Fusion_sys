#!/usr/bin/env python3
"""
get_scan_ssid_list.py  (NetworkManager 版)
  1. nmcli で強制スキャン (--rescan yes) を実行
  2. スキャン結果から SSID を抽出
  3. /etc/wpa_supplicant/*.conf に既登録の SSID を読み取り
  4. 未登録だけを JSON で標準出力
※ sudoers などで www-data が「sudo -n nmcli …」を実行できる前提
"""

import subprocess, re, glob, pathlib, json, os, sys

WLAN = "wlan0"

# ---------- 1. nmcli で再スキャン＆SSID 一覧取得 ----------
def nmcli_scan():
    cmd = ["sudo", "nmcli", "-t", "-f", "SSID", "device", "wifi",
           "list", "--rescan", "yes", "ifname", WLAN]
    try:
        out = subprocess.check_output(cmd, text=True, stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as e:
        # 非 root だと "not authorized" → sudo でリトライ
        if b"not authorized" in e.output.encode():
            cmd.insert(0, "-n")          # sudo -n nmcli …
            cmd.insert(0, "sudo")
            out = subprocess.check_output(cmd, text=True)
        else:
            raise
    # 空行や重複を除外してセット化
    return {line for line in out.splitlines() if line.strip()}

scanned = nmcli_scan()

# ---------- 2. 登録済み SSID セットを作成 ----------
CONF_DIR = pathlib.Path("/etc/wpa_supplicant")
files = ([CONF_DIR / "wpa_supplicant.conf"] if (CONF_DIR / "wpa_supplicant.conf").is_file()
         else glob.glob(str(CONF_DIR / "*.conf")))
files = [p for p in files if pathlib.Path(p).is_file()]

registered = set()
pat = re.compile(r'^\s*ssid="([^"]+)"', re.MULTILINE)
for p in files:
    try:
        with open(p) as f:
            registered.update(pat.findall(f.read()))
    except Exception:
        pass

# ---------- 3. 差集合を JSON で返す ----------
unregistered = sorted(scanned - registered)
print("Content-Type: application/json\n")
print(json.dumps([{"ssid": s} for s in unregistered]), end="")

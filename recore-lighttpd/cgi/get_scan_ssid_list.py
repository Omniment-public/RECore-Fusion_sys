#!/usr/bin/env python3
import subprocess, re, json, glob, pathlib, os, sys

CONF_DIR = pathlib.Path("/etc/wpa_supplicant")

# ---------- 1. 登録済み SSID を収集 ----------
candidates = []

# (a) 単一ファイル方式
if (CONF_DIR / "wpa_supplicant.conf").is_file():
    candidates.append(CONF_DIR / "wpa_supplicant.conf")
else:
    # (b) iface ごとの *.conf ファイル方式
    candidates.extend(glob.glob(str(CONF_DIR / "*.conf")))

files = [p for p in candidates if pathlib.Path(p).is_file()]

registered = set()
pattern = re.compile(r'^\s*ssid="([^"]+)"', re.MULTILINE)

for path in files:
    try:
        with open(path) as f:
            registered.update(pattern.findall(f.read()))
    except Exception as e:
        print(f"warn: cannot read {path}: {e}", file=sys.stderr)

# ---------- 2. 近隣の SSID をスキャン ----------
scan_raw = subprocess.check_output(
    ["sudo", "iw", "dev", "wlan0", "scan"], text=True, stderr=subprocess.DEVNULL
)
scanned = set(re.findall(r'SSID: (.+)', scan_raw))

# ---------- 3. 未登録 SSID を JSON 出力 ----------
unregistered = sorted(scanned - registered)
print(json.dumps([{"ssid": s} for s in unregistered]), end="")

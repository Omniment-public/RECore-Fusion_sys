#!/usr/bin/env python3
"""
get_registered_ssid_list.py
  - Reads every wpa_supplicant *.conf file (ignores directories)
  - Collects ssid="..." entries
  - Outputs JSON list sorted alphabetically
"""
import pathlib, glob, re, json, sys

CONF_DIR = pathlib.Path("/etc/wpa_supplicant")
FILES = []

# (1) 単一ファイル方式
if (CONF_DIR / "wpa_supplicant.conf").is_file():
    FILES.append(CONF_DIR / "wpa_supplicant.conf")
else:
    # (2) iface ごとの *.conf ファイルが存在する場合
    FILES.extend(glob.glob(str(CONF_DIR / "*.conf")))

FILES = [p for p in FILES if pathlib.Path(p).is_file()]

if not FILES:
    print("[]")          # 何も無ければ空 JSON
    sys.exit(0)

registered = set()
pattern = re.compile(r'^\s*ssid="([^"]+)"', re.MULTILINE)

for path in FILES:
    try:
        with open(path) as f:
            registered.update(pattern.findall(f.read()))
    except Exception as e:
        # 読めないファイルは無視して続行
        print(f"warn: cannot read {path}: {e}", file=sys.stderr)

print(json.dumps(
    [{"registered_ssid": s} for s in sorted(registered)]
), end="")

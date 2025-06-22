import re
import json
import subprocess
# ap_ssid_load
#conf = open('/etc/hostapd/hostapd.conf',mode='r')
#read_conf = conf.read()
#conf.close()
ssid=""
def get_nm_ssid(profile_name: str) -> str | None:
    """
    Return SSID string of a NetworkManager connection profile.
    Uses `nmcli -t -f 802-11-wireless.ssid connection show <profile_name>`.
    """
    try:
        # -t (terse) で「<ssid>\n」だけ取得
        ssid = subprocess.check_output(
            ["nmcli", "-g", "802-11-wireless.ssid", "connection", "show", profile_name],
            text=True
        ).strip()
        # 空文字列の場合は未設定
        return ssid or None
    except subprocess.CalledProcessError:
        return None

# ---- SSID ----
ssid = get_nm_ssid("ap-recore")
if ssid is None:
    ssid = "unknown"   # fallback

#ssid = re.search('ssid=.*\n',read_conf).group().rstrip().replace('ssid=','')

# hostname load
conf = open('/etc/hostname',mode='r')
read_conf = conf.read()
conf.close()

hostname = read_conf.rstrip()

# sys version load
app_dir="/usr/local/bin/recore/files/app/RECore-Fusion_sys"
app_file = open(app_dir,mode='r')
app_info = app_file.read()
app_file.close()
version = re.search('version=.*\n',app_info).group().rstrip().replace('version=','').replace('"','')

state_json = []
state_json.append({'ap_ssid':ssid})
state_json.append({'hostname':hostname})
state_json.append({'sys_version':version})

print(json.dumps(state_json), end= '')

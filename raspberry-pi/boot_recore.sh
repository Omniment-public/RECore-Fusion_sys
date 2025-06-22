#!/bin/bash
# ReCore Wi-Fi mode switcher (NM 版)
#   0 → STA   1 → 強制 AP

LED_GREEN=23
LED_RED=24

pinctrl set $LED_GREEN op dl  # LCD off
pinctrl set $LED_RED   op dl

WLAN=wlan0
CON_AP="recore-ap"            # 事前に nmcli で作成
STA_PREFIX="sta-"             # STA プロファイル命名規則
NMCLI=/usr/bin/nmcli

#WLAN=wlan0
SSID="recore-fusion"
AP_IP="192.168.5.1/24"
AP_GW="192.168.5.1"

# アップデータ確認
sudo bash /usr/local/bin/recore/files/update.sh

#無線モード
WLAN_MODE=$(</usr/local/bin/recore/files/wlan_mode)    # 0=STA /1=AP
#logger -t boot_recore "start wlan_mode=$WLAN_MODE"

### 1. STA モード

if [[ "$WLAN_MODE" == "0" ]]; then
    echo "=== STA Mode ==="
	nmcli device set $WLAN managed yes
	if ! nmcli connection up id "${STA_PREFIX}"\*; then
		WLAN_STATE=""
	else
		sleep 6
		WLAN_STATE=$(iwgetid -r || true)
	fi
else
    WLAN_STATE=""
fi

### 2. AP モード (接続失敗 or 強制 AP)
if [[ -z "$WLAN_STATE" ]]; then
    echo "=== AP Mode ==="

	# 自動チャネル選択 (失敗時は ch6)
    best_ch=$(python3 /usr/local/bin/recore/files/wlan_autochannel_nm.py) || best_ch=1
    if [[ $best_ch -ge 1 && $best_ch -le 13 ]]; then
        nmcli connection modify $CON_AP wifi.channel "$best_ch"
        echo "[boot_recore] AP channel set to $best_ch"
    fi

	# AP プロファイルを up （NM が hostapd + 内蔵 dnsmasq を自動起動）
    sudo nmcli connection up $CON_AP

    # LED: 緑=ON 赤=ON
    pinctrl set $LED_GREEN op dh
    pinctrl set $LED_RED   op dh
else
    # STA 成功 → 緑のみ
    pinctrl set $LED_GREEN op dh
    pinctrl set $LED_RED   op dl
fi

### サービス起動
docker start recore-lighttpd
docker start recore-jupyter

#logger -t boot_recore "end mode=$( [[ -z $WLAN_STATE ]] && echo AP || echo STA )"
exit 0

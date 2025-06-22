#!/bin/bash
# create_ap_profile.sh  ― ReCore の AP 用 NetworkManager プロファイルを作成／更新
# Usage: sudo create_ap_profile.sh [<ssid> [<passphrase> [<channel>]]]
# 省略時: ssid=recore-fusion, pass=rec0re@ap, channel=6

set -euo pipefail

WLAN=wlan0
PROFILE="recore-ap"

SSID="${1:-recore-fusion}"
PASS="${2:-recore}"
CHAN="${3:-6}"              # 1,6,11 のいずれかを推奨

# 1. 既存プロファイル確認
if nmcli -t -f NAME connection | grep -qx "$PROFILE"; then
    echo "[create_ap_profile] update existing profile: $PROFILE"
else
    echo "[create_ap_profile] create new profile: $PROFILE"
    nmcli connection add type wifi ifname "$WLAN" con-name "$PROFILE" >/dev/null
fi

# 2. 共通プロパティを設定
nmcli connection modify "$PROFILE" \
    802-11-wireless.mode ap \
    802-11-wireless.ssid "$SSID" \
    802-11-wireless.band bg \
    802-11-wireless.channel "$CHAN" \
    802-11-wireless-security.key-mgmt wpa-psk \
    802-11-wireless-security.psk "$PASS" \
    dhcp-range=192.168.5.2,192.168.5.254,255.255.255.0,12h
    ipv4.method shared \
    ipv6.method ignore \
    connection.autoconnect yes \
    connection.autoconnect-priority 1

# 3. パーミッションを再設定（NM 要件: root:root 600）
CONF_PATH="/etc/NetworkManager/system-connections/${PROFILE}.nmconnection"
if [ -f "$CONF_PATH" ]; then
    chmod 600 "$CONF_PATH"
fi

echo "[create_ap_profile] done → SSID=$SSID  CH=$CHAN"

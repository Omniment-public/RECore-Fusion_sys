#!/bin/bash
set -euo pipefail

# ------------ user-configurable defaults -------------
PROFILE="ap-recore"              # 固定
WLAN="wlan0"                      # Wi-Fi IF name

SSID="${1:-recore-fusion}"        # $1 が空ならデフォルト
PASS="${2:-recorefusion}"         # 8–63 文字。空ならオープン AP
CHAN="${3:-6}"                    # 1 / 6 / 11 推奨
# ------------------------------------------------------

echo "[make_ap_profile] recreate \"$PROFILE\" (SSID=$SSID, CH=$CHAN)"

# 既存プロファイルがあれば削除。無ければエラーだが || true で無視
nmcli connection delete "$PROFILE" >/dev/null 2>&1 || true

# 新規追加 (SSID は必須)
nmcli connection add type wifi ifname "$WLAN" con-name "$PROFILE" ssid "$SSID" >/dev/null

# 共通パラメータ
nmcli connection modify "$PROFILE" \
    802-11-wireless.mode ap \
    802-11-wireless.band bg \
    802-11-wireless.channel "$CHAN" \
    802-11-wireless.ssid "$SSID" \
    ipv4.method shared \
    ipv4.addresses 192.168.5.1/24 \
    ipv6.method ignore \
    connection.autoconnect yes \
    connection.autoconnect-priority 1

# セキュリティ設定
if [[ -z "$PASS" ]]; then
    nmcli connection modify "$PROFILE" 802-11-wireless-security.key-mgmt none
    echo "[make_ap_profile] open network (no PSK)"
else
    nmcli connection modify "$PROFILE" \
        802-11-wireless-security.key-mgmt wpa-psk \
        802-11-wireless-security.psk "$PASS"
    echo "[make_ap_profile] WPA2-PSK set"
fi

# プロファイルを有効化
nmcli connection up "$PROFILE"

echo "[make_ap_profile] complete"

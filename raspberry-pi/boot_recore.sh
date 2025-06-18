#!/bin/bash
# ReCore Wi-Fi mode switcher (NM 版)
#   0 → STA   1 → 強制 AP

LED_GREEN=23
LED_RED=24

pinctrl set $LED_GREEN op dl  # LCD off
pinctrl set $LED_RED   op dl

WLAN=wlan0
SSID="recore-fusion"
AP_IP="192.168.5.1/24"
AP_GW="192.168.5.1"
CON_AP="recore-ap"
CON_STA="recore-sta"          # 既に nmcli で設定済み想定
NMCLI="/usr/bin/nmcli"
CONF=/etc/hostapd/hostapd.conf

# アップデータ確認
sudo bash /usr/local/bin/recore/files/update.sh

#無線モード
wlan_mode=$(</usr/local/bin/recore/files/wlan_mode)

# 自動チャネル選択 (失敗時は ch6)
sudo python3 /usr/local/bin/recore/files/wlan_autochannel.py
#/usr/bin/python3 /usr/local/bin/recore/files/wlan_autochannel.py
rc=$?

if [[ $rc -ne 0 && -f /etc/hostapd/hostapd.conf ]]; then      # Python失敗＋confがある
    echo "[boot_recore] autochannel error (rc=$rc) → fallback to channel 6"
    sed -i 's/^channel=.*/channel=6/' /etc/hostapd/hostapd.conf
elif [[ $rc -ne 0 ]]; then                                    # conf が無いならスキップ
    echo "[boot_recore] autochannel error (rc=$rc) but /etc/hostapd/hostapd.conf not found; skip fallback"
fi

WLAN_MODE=$(</usr/local/bin/recore/files/wlan_mode)    # 0=STA /1=AP
#logger -t boot_recore "start wlan_mode=$WLAN_MODE"

### 1. STA モード
if [[ "$WLAN_MODE" == "0" ]]; then
    echo "=== STA Mode ==="
    # NM に管理を戻し、STA 接続を有効化
    $NMCLI device set $WLAN managed yes
    $NMCLI connection up "$CON_STA" || true   # 失敗しても先へ

    # 不要サービス停止
    systemctl stop hostapd || true
    systemctl stop dnsmasq || true
    ip addr flush dev $WLAN

    # 接続確認 (10 s)
    sleep 10
    WLAN_STATE=$(iwgetid -r || true)
    echo "current SSID: $WLAN_STATE"
else
    WLAN_STATE=""
fi

### 2. AP モード (接続失敗 or 強制 AP)
if [[ -z "$WLAN_STATE" ]]; then
    echo "=== AP Mode ==="
    # NM から一時的に外す（hostapd が直接制御）
    $NMCLI device set $WLAN managed no || true

    # 既存 AP 接続を削除・再作成しても良い
    ip link set $WLAN down
    ip addr flush dev $WLAN
    ip addr add $AP_IP dev $WLAN
    ip link set $WLAN up

    # NAT (重複追加を防止)
    iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null \
        || iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

    # DHCP/DNS (dnsmasq) 起動
    systemctl restart dnsmasq

    # hostapd 起動
    systemctl restart hostapd

    # LED: 緑=ON 赤=ON
    pinctrl set $LED_GREEN op dh
    pinctrl set $LED_RED   op dh
else
    # STA 成功 → 緑のみ
    pinctrl set $LED_GREEN op dh
    pinctrl set $LED_RED   op dl
fi

docker start recore-lighttpd || true
docker start recore-jupyter   || true

#logger -t boot_recore "end mode=$( [[ -z $WLAN_STATE ]] && echo AP || echo STA )"
exit 0

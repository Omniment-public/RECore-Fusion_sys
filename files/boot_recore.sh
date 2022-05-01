#!/bin/bash

echo "23" > /sys/class/gpio/export
echo "24" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio23/direction
echo "out" > /sys/class/gpio/gpio24/direction
echo 0 > /sys/class/gpio/gpio23/value
echo 0 > /sys/class/gpio/gpio24/value

#無線モード
wlan_mode=$(</usr/local/bin/wlan_mode)
sudo systemctl start dhcpcd

if [ $wlan_mode=0 ]
then
	#STA立ち上げ
	echo "STA Mode"
	sudo systemctl stop hostapd
	sudo systemctl stop dnsmasq
	sudo ip addr flush dev wlan0
	sudo systemctl start wpa_supplicant
	#sudo systemctl start dhcpcd

	#接続確認
	sleep 15

	wlan_state=`iwgetid`
	echo "$wlan_state"
else
	wlan_state=""
fi

if [ $wlan_state="" ]
then
	#AP処理
	echo "AP Mode"
	sudo python /usr/local/bin/wlan_autochannel.py
	sudo systemctl stop wpa_supplicant
	sudo systemctl stop dhcpcd
	sudo systemctl start dnsmasq
	sudo systemctl start hostapd
	sudo ip addr flush dev wlan0
	sudo ip addr add 192.168.5.1 dev wlan0
	sudo ip route add default via 192.168.5.1 dev wlan0
	echo 1 > /sys/class/gpio/gpio23/value
	echo 1 > /sys/class/gpio/gpio24/value
else
	echo 1 > /sys/class/gpio/gpio23/value
	echo 0 > /sys/class/gpio/gpio24/value
fi
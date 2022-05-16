#!/bin/bash

LED_GREEN_VAL=/sys/class/gpio/gpio23/value
LED_RED_VAL=/sys/class/gpio/gpio24/value
echo "23" > /sys/class/gpio/export
echo "24" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio23/direction
echo "out" > /sys/class/gpio/gpio24/direction
echo 0 > $LED_GREEN_VAL
echo 0 > $LED_RED_VAL

#無線モード
wlan_mode=$(</usr/local/bin/recore/files/wlan_mode)
sudo systemctl start dhcpcd
sudo iwconfig wlan0 power off
sudo python /usr/local/bin/recore/files/wlan_autochannel.py

if [ $wlan_mode = 0 ]
then
	#STA立ち上げ
	echo "STA Mode"
	cp /usr/local/bin/recore/files/dhcpcd.sta.conf /etc/dhcpcd.conf
	sudo iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE
	service dhcpcd restart

	sudo systemctl stop hostapd
	sudo systemctl stop dnsmasq
	sudo ip addr flush dev wlan0
	sudo systemctl start wpa_supplicant
	#sudo systemctl start dhcpcd

	#接続確認
	sleep 10

	wlan_state=`iwgetid`
	echo "$wlan_state"
else
	echo "Skip STA"
	wlan_state=""
fi

# アップデータ確認
sudo bash /usr/local/bin/recore/files/update.sh

if [ $wlan_state="" ]
then
	# AP処理
	echo "AP Mode"
	sudo systemctl stop wpa_supplicant
	#sudo systemctl stop dhcpcd
	#sudo ifconfig wlan0 up
	sudo systemctl start dnsmasq
	sudo systemctl start hostapd
	sudo ip addr flush dev wlan0
	sudo ip addr add 192.168.5.1 dev wlan0

	cp /usr/local/bin/recore/files/dhcpcd.ap.conf /etc/dhcpcd.conf
	sudo iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE
	sudo service dhcpcd restart
	sudo systemctl restart hostapd.service

	echo 1 > $LED_GREEN_VAL
	echo 1 > $LED_RED_VAL
else
	echo 1 > $LED_GREEN_VAL
	echo 0 > $LED_RED_VAL
fi

docker start recore-lighttpd
docker start recore-jupyter


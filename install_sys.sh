#!/bin/bash
# install recore sys files

NAME="RECore-Fusion_sys"

SYS_DIR="/usr/local/bin/recore/files"
INSTALL_DIR="/usr/local/bin/recore/install/"$NAME
REGIST_DIR=$SYS_DIR"/app"

if [ ! "$(id -u)" = 0 ]; then
	echo "Please run root user"
	exit 1
fi

# apt upgrade
echo "update apt-get"
apt-get -y update
apt-get -y upgrade

# init raspi confing
echo "init raspi config"
apt-get -qy install locales-all
raspi-config nonint do_change_locale ja_JP.UTF-8
raspi-config nonint do_change_timezone Asia/Tokyo
raspi-config nonint do_wifi_country JP
raspi-config nonint do_serial 2

# install fonts
echo "install fonts"
apt-get -qy install fonts-ipaexfont
apt-get -qy install fonts-noto-cjk

# install pip
echo "update pip"
apt-get -y install python3-pip
pip install -U pip

# install apps
echo "install apps"
apt-get -qy install hostapd
apt-get -qy install dnsmasq
apt-get -qy install ifmetric

apt-get -qy install git
apt-get -qy install unzip
apt-get -qy install vim

apt-get -qy install docker.io
#sudo usermod -aG docker $USER
usermod -aG docker recore

# disable hostapd
echo "disable hostapd"
systemctl unmask hostapd
systemctl disable hostapd

# make dir
echo "make dir"

# make working dir
mkdir /home/recore/fusion-files

mkdir /usr/local/bin/recore
mkdir $SYS_DIR
mkdir /usr/local/bin/recore/install
mkdir $REGIST_DIR

# move files
echo "move files"
#move sys file
chmod +x $INSTALL_DIR/raspberry-pi/boot_recore.sh
chmod +x $INSTALL_DIR/raspberry-pi/update.sh
chmod +x $INSTALL_DIR/raspberry-pi/blink.sh
chmod +x $INSTALL_DIR/raspberry-pi/config/rc.local
chmod +x $INSTALL_DIR/raspberry-pi/wlan_autochannel.py

mv -f $INSTALL_DIR/raspberry-pi/boot_recore.sh $SYS_DIR
mv -f $INSTALL_DIR/raspberry-pi/update.sh $SYS_DIR
mv -f $INSTALL_DIR/raspberry-pi/blink.sh $SYS_DIR
mv -f $INSTALL_DIR/raspberry-pi/config/rc.local /etc/
mv -f $INSTALL_DIR/raspberry-pi/config/sysctl.conf /etc/
mv -f $INSTALL_DIR/raspberry-pi/wlan_autochannel.py $SYS_DIR
mv -f $INSTALL_DIR/raspberry-pi/config/dhcpcd.ap.conf $SYS_DIR
mv -f $INSTALL_DIR/raspberry-pi/config/dhcpcd.sta.conf $SYS_DIR

mv -f $INSTALL_DIR/raspberry-pi/config/hostapd.conf /etc/hostapd
mv -f $INSTALL_DIR/raspberry-pi/config/dnsmasq.conf /etc/

sudo bash -c "echo 0 > $SYS_DIR/wlan_mode"
chmod 777 $SYS_DIR/wlan_mode

mv $INSTALL_DIR/raspberry-pi/config/kill-all-containers.service /etc/systemd/system/
systemctl enable kill-all-containers.service
systemctl start kill-all-containers.service

chmod 766 /etc/hostapd/hostapd.conf
chmod 766 /etc/wpa_supplicant/wpa_supplicant.conf
chmod 766 /etc/hosts
chmod 766 /etc/hostname

# swap bluetooth uart port
sudo bash -c "echo 'dtoverlay=miniuart-bt' >> /boot/config.txt"

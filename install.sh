#!/bin/bash

VERSION='v0.0.0'

FUSION_DIR="/usr/local/bin/recore/files"
UPDATE_DIR="/usr/local/bin/recore/update"

cd $UPDATE_DIR

# apt upgrade
echo "update apt-get"
sudo apt-get -y update
sudo apt-get -y upgrade

# init raspi confing
echo "init raspi config"
sudo apt-get -qy install locales-all
sudo raspi-config nonint do_change_locale ja_JP.UTF-8
sudo raspi-config nonint do_change_timezone Asia/Tokyo
sudo raspi-config nonint do_wifi_country JP
sudo raspi-config nonint do_serial 2

# install fonts
echo "install fonts"
sudo apt-get -qy install fonts-ipaexfont
sudo apt-get -qy install fonts-noto-cjk

# install pip
echo "update pip"
sudo apt-get -y install python3-pip
sudo pip install -U pip

# install apps
echo "install apps"
sudo apt-get -qy install hostapd
sudo apt-get -qy install dnsmasq
sudo apt-get -qy install ifmetric

sudo apt-get -qy install git
sudo apt-get -qy install unzip
sudo apt-get -qy install vim

sudo apt-get -qy install docker.io
#sudo usermod -aG docker $USER
sudo usermod -aG docker recore

# disable hostapd
echo "disable hostapd"
sudo systemctl unmask hostapd
sudo systemctl disable hostapd

# make dir
echo "make dir"

# make working dir
mkdir /home/recore/fusion-files
mkdir /home/recore/fusion-files/fusion-notebook
mkdir /home/recore/fusion-files/site-package
sudo chmod 777 /home/recore/fusion-files/*

sudo mkdir /usr/local/bin/recore
sudo mkdir $FUSION_DIR
sudo mkdir /usr/local/bin/recore/update
sudo chmod 777 /usr/local/bin/recore/*

# move files
echo "move files"
#move sys file
sudo mv -f ./raspberry-pi/boot_recore.sh $FUSION_DIR
sudo mv -f ./raspberry-pi/update.sh $FUSION_DIR
sudo mv -f ./raspberry-pi/config/rc.local /etc/
sudo chmod +x $FUSION_DIR/boot_recore.sh
sudo chmod +x /etc/rc.local

sudo mv ./raspberry-pi/blink.sh $FUSION_DIR
sudo chmod +x $FUSION_DIR/blink.sh

sudo mv -f ./raspberry-pi/config/hostapd.conf /etc/hostapd
sudo mv -f ./raspberry-pi/config/dnsmasq.conf /etc/

sudo mv ./raspberry-pi/wlan_autochannel.py $FUSION_DIR
sudo echo 0 > $FUSION_DIR'/wlan_mode'
sudo chmod 777 $FUSION_DIR/wlan_mode

sudo echo $VERSION > $FUSION_DIR'/version'
sudo chmod 774 $FUSION_DIR/version

sudo mv ./raspberry-pi/config/kill-all-containers.service /etc/systemd/system/
sudo systemctl enable kill-all-containers.service
sudo systemctl start kill-all-containers.service

sudo chmod 666 /etc/hostapd/hostapd.conf
sudo chmod 666 /etc/wpa_supplicant/wpa_supplicant.conf
sudo chmod 666 /etc/hosts
sudo chmod 666 /etc/hostname

#!/bin/bash

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
sudo usermod -aG docker $USER

# disable hostapd
echo "disable hostapd"
sudo systemctl unmask hostapd
sudo systemctl disable hostapd

# setup jupyter
echo "setup jupyter"

# make working dir
mkdir /home/recore/fusion-files
mkdir /home/recore/fusion-files/fusion-notebook
mkdir /home/recore/fusion-files/site-package
sudo chmod 777 ~/fusion-files/*

# move files
echo "move files"
#move sys file
sudo mkdir /usr/local/bin/recore
sudo mkdir /usr/local/bin/recore/files
sudo mkdir /usr/local/bin/recore/updater

sudo mv -f ./raspberry-pi/boot_recore.sh /usr/local/bin/recore/files/
sudo mv -f ./raspberry-pi/config/hostapd.conf /etc/hostapd/
sudo mv -f ./raspberry-pi/config/dnsmasq.conf /etc/
sudo mv -f ./raspberry-pi/config/rc.local /etc/
sudo chmod +x /etc/rc.local
sudo chmod +x /usr/local/bin/recore/files/boot_recore.sh

sudo mv ./raspberry-pi/wlan_autochannel.py /usr/local/bin/recore/files/
sudo sh -c "echo 0 >> '/usr/local/bin/recore/files/wlan_mode'"
sudo chmod 777 /usr/local/bin/recore/files/wlan_mode

sudo mv ./raspberry-pi/config/kill-all-containers.service /etc/systemd/system/
sudo systemctl enable kill-all-containers.service
sudo systemctl start kill-all-containers.service

sudo chmod 666 /etc/hostapd/hostapd.conf
sudo chmod 666 /etc/wpa_supplicant/wpa_supplicant.conf
sudo chmod 666 /etc/hosts
sudo chmod 666 /etc/hostname

# setup wlan0
sudo ifconfig wlan0 up

sudo reboot

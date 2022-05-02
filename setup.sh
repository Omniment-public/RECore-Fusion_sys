#!/bin/bash

# apt upgrade
echo "update apt-get"
sudo apt-get -y update
sudo apt-get -y upgrade

# init raspi confing
echo "init raspi config"
sudo apt-get -y install locales-all
sudo raspi-config nonint do_change_locale ja_JP.UTF-8
sudo raspi-config nonint do_change_timezone Asia/Tokyo
sudo raspi-config nonint do_wifi_country JP
sudo raspi-config nonint do_serial 2

# install pip
echo "update pip"
sudo apt-get -y install python3-pip
sudo pip install -U pip

# install apps
echo "install apps"
sudo apt-get -y install git
sudo apt-get install -y jupyter-notebook
sudo apt-get install -y lighttpd
sudo apt-get install -y hostapd dnsmasq
sudo apt-get install -y unzip
sudo apt-get install -y vim
sudo apt-get install -y libopencv-dev
sudo apt-get -y install fonts-ipaexfont
pip install -U numpy
pip install -U pandas
pip install -U scipy
pip install -U picamera
pip install -U opencv-python
pip install -U torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cpu

# disable hostapd
echo "disable hostapd"
sudo systemctl unmask hostapd
sudo systemctl disable hostapd

# setup jupyter
echo "setup jupyter"

# make working dir
sudo mkdir /home/recore/jupyter
sudo chmod 777 ~/jupyter/

# move jupyter service
sudo mv ./files/service/jupyter.service /etc/systemd/system/
jupyter notebook --generate-config -y
sudo mv -f ./files/conf/jupyter_notebook_config.py /home/recore/.jupyter/

# install pyrecore
echo "install pyrecore"
pip install ./files/pyrecore-0.0.0-py3-none-any.whl

# enable jupyter
sudo systemctl enable jupyter
sudo service jupyter force-reload

# install jupyter extention
pip install jupyter-contrib-nbextensions

# setup lighttpd
echo "setup lighttpd"
# move config file
sudo lighttpd-enable-mod cgi
sudo mv -f ./files/conf/lighttpd.conf /etc/lighttpd/
sudo mv -f ./files/conf/10-cgi.conf /etc/lighttpd/conf-available/
sudo chown root ./files/conf/lighttpd-sudo
sudo mv -f ./files/conf/lighttpd-sudo /etc/sudoers.d/
sudo service lighttpd force-reload

# move files
echo "move files"
#move sys file
sudo mv -f ./files/boot_recore.sh /usr/local/bin/
sudo mv -f ./files/conf/hostapd.conf /etc/hostapd/
sudo mv -f ./files/conf/dnsmasq.conf /etc/
sudo mv -f ./files/conf/rc.local /etc/
sudo chmod +x /etc/rc.local
sudo chmod +x /usr/local/bin/boot_recore.sh

# move html file
sudo mv ./web/* /var/www/html/

# move tools
sudo mv ./files/wlan_autochannel.py /usr/local/bin/
sudo sh -c "echo 0 >> '/usr/local/bin/wlan_mode'"
sudo chmod 777 /usr/local/bin/wlan_mode

# move cgi files
sudo mv ./files/cgi/* /usr/lib/cgi-bin/

# start wlan
sudo ifconfig wlan0 up

# set permission
sudo chmod 646 /etc/hostapd/hostapd.conf
sudo chmod 646 /etc/wpa_supplicant/wpa_supplicant.conf

sudo reboot

#!/bin/bash
#RECore Fusion lighttpd install

NAME="RECore-Fusion_sys"
APP_NAME="recore-lighttpd"
IMG_NAME="recore-lighttpd-image.tar.gz"
REPO_INFO="Omniment-public/RECore-Fusion_sys"
VERSION="v0.0.3"

SYS_DIR="/usr/local/bin/recore/files"
INSTALL_FILES="/usr/local/bin/recore/install/"$NAME"/"$APP_NAME
APP_DIR=$SYS_DIR/$APP_NAME
REGIST_DIR=$SYS_DIR"/app"

INFO_DIR=$APP_DIR"/.info"

# check root
if [ ! "$(id -u)" = 0 ]; then
	echo "Please run root user"
	exit 1
fi

# mkdir
mkdir $APP_DIR
mkdir $APP_DIR/.info

# stop old container
OLD_IMG_NAME="$(docker ps -a -f name="$APP_NAME" --format {{.Image}})"
docker rename $APP_NAME $APP_NAME"_"
docker stop $APP_NAME"_"

# load new image
docker load -i $INSTALL_FILES/$IMG_NAME

RUN_STATE=0
docker run -d --privileged --net=host -v /usr/bin/systemctl:/usr/bin/systemctl -v /etc/hostname:/etc/hostname -v /usr/local/bin/recore/files:/usr/local/bin/recore/files -v /usr/local/bin/recore/install:/usr/local/bin/recore/install -v /etc/hostapd/hostapd.conf:/etc/hostapd/hostapd.conf -v /etc/wpa_supplicant/wpa_supplicant.conf:/etc/wpa_supplicant/wpa_supplicant.conf -v /run/systemd/system:/run/systemd/system -v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket -v /sys/fs/cgroup:/sys/fs/cgroup -v /usr/local/bin/recore/files/version:/usr/local/bin/recore/files/version -v /home/recore/fusion-files/:/home/recore/fusion-files/ --name recore-lighttpd recore-lighttpd:$VERSION lighttpd -f /etc/lighttpd/lighttpd.conf -D && RUN_STATE=1

if [ $RUN_STATE = 1 ];then
	docker rm -f $APP_NAME"_"
	docker rmi -f $OLD_IMG_NAME

	# write repo info
	sudo bash -c "echo $REPO_INFO > $INFO_DIR'/repo_info'"
	sudo bash -c "echo $VERSION > $INFO_DIR'/version'"
else
	docker rename $APP_NAME"_" $APP_NAME
	docker start $APP_NAME
fi

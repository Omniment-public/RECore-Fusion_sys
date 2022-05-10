#!/bin/bash

# アップデータ確認
UPDATE_DIR="/usr/local/bin/recore/update"
FUSION_DIR="/usr/local/bin/recore/files"

UPDATER_ARCHIVE="/usr/local/bin/recore/update/update.tar.gz"
UPDATER_README="/usr/local/bin/recore/update/README.md"
UPDATER_INSATLLER="/usr/local/bin/recore/update/install.sh"

UPDATE_STATE="/usr/local/bin/recore/update/update_state"
SYS_VERSION="/usr/local/bin/recore/files/version"
UPDATE_VERSION="/usr/local/bin/recore/update/update_version"
SYS_FILES="/usr/local/bin/recore/update/raspberry-pi"

if [ -e $UPDATER_ARCHIVE ]; then
	echo "Find Update"
	sudo tar -zxvf $UPDATER_ARCHIVE -C $UPDATE_DIR --strip-components 1
	
	cd $UPDATE_DIR
	sudo rm $UPDATER_ARCHIVE

	echo "run update"
	bash $FUSION_DIR/blink.sh &
	sudo bash $UPDATER_INSATLLER

	sudo echo 1 > '/usr/local/bin/recore/update/update_state'
	echo "reboot"
	sudo reboot
fi

# dockerセットアップ確認
DOCKER_SETUP="/usr/local/bin/recore/update/setup_docker.sh"
DOCKER_FILES="/usr/local/bin/recore/update/docker"

if [ -e $DOCKER_SETUP ]; then
	echo "run docker setup"
	bash $FUSION_DIR/blink.sh &
	sudo bash $DOCKER_SETUP
	sudo rm $DOCKER_SETUP
	sudo echo 1 > '/usr/local/bin/recore/update/update_state'
	sudo reboot
fi

# finalise

if [ -e $UPDATE_STATE ]; then

	if [ $(<$UPDATE_STATE) = 1 ]
	then
		echo "update complete"
		#write version
		sudo echo $(<$UPDATE_VERSION) > $SYS_VERSION
		sudo chmod 777 $SYS_VERSION
		sudo rm -rf $UPDATE_DIR/*
	fi
fi

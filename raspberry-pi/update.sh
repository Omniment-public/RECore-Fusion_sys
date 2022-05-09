#!/bin/bash

# アップデータ確認
UPDATE_DIR="/usr/local/bin/recore/update"
UPDATER_ARCHIVE="/usr/local/bin/recore/update/update.tar.gz"
UPDATER_README="/usr/local/bin/recore/update/README.md"
UPDATER_SETUP="/usr/local/bin/recore/update/setup.sh"

UPDATE_STATE="/usr/local/bin/recore/update/update_state"
SYS_VERSION="/usr/local/bin/recore/files/version"
UPDATE_VERSION="/usr/local/bin/recore/update/update_version"

FUSION_FILES="/usr/local/bin/recore/files"

if [ -e $UPDATER_ARCHIVE ]; then
	echo "Find Update"
	sudo tar -zxvf $UPDATER_ARCHIVE -C $UPDATE_DIR --strip-components 1
	
	sudo rm $UPDATER_ARCHIVE
	sudo rm $UPDATER_README
	sudo rm $UPDATER_SETUP
	
	echo "check system updater"
	SYS_UPDATER="/usr/local/bin/recore/update/updater.sh"
	SYS_FILES="/usr/local/bin/recore/update/raspberry-pi"

	SYS_UPDATED=0
	if [ -e $SYS_UPDATER ]; then
		echo "run update"
		bash $FUSION_FILES/blink.sh &
		sudo bash $SYS_UPDATER
		sudo rm $SYS_UPDATER
		SYS_UPDATED=1
  	fi

	sudo rm -rf $SYS_FILES
	echo $SYS_UPDATED

	if [ $SYS_UPDATED -eq 1 ]; then
		sudo echo 1 > '/usr/local/bin/recore/update/update_state'
		echo "reboot"
		sudo reboot
	fi
fi

# dockerセットアップ確認
DOCKER_SETUP="/usr/local/bin/recore/update/setup_docker.sh"
DOCKER_FILES="/usr/local/bin/recore/update/docker"

if [ -e $DOCKER_SETUP ]; then
	echo "run docker setup"
	bash $FUSION_FILES/blink.sh &
	sudo bash $DOCKER_SETUP
	sudo rm $DOCKER_SETUP
	sudo rm -rf $DOCKER_FILES
	sudo echo 1 > '/usr/local/bin/recore/update/update_state'
	sudo reboot
fi

# finalise

if [ -e $UPDATE_STATE ]; then

	if [ $(<$UPDATE_STATE) = 1 ]
	then
		echo "update complete"
		#write version
		sudo echo $(<$UPDATE_VERSION) > '/usr/local/bin/recore/files/version'
		sudo rm $UPDATE_STATE
		sudo rm $UPDATE_VERSION
	fi
fi

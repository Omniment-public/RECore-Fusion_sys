#!/bin/bash

INSTALL_DIR="/usr/local/bin/recore/install"
FUSION_DIR="/usr/local/bin/recore/files"

# アップデートキュー確認

if [ "$(id -u)" -ne 0 ]; then
	echo "Please run root user"
	exit 1
fi

INSTALL_QUEUE=$INSTALL_DIR"/install_queue"
INSTALL_NAME=`sed -n 1P $INSTALL_QUEUE`
INSTALL_STATUS=0

if [ ! $INSTALL_NAME = "" ]; then
	if [ -e $INSTALL_DIR/$INSTALL_NAME/installer.tar.gz ]; then
		echo "Find Installer"
		bash $FUSION_DIR/blink.sh &
		INSTALL_STATUS=1
		#cd $INSTALL_DIR/$INSTALL_NAME
		sudo tar -zxvf $INSTALL_DIR/$INSTALL_NAME/installer.tar.gz -C $INSTALL_DIR/$INSTALL_NAME/ --strip-components 1

		echo "Run Updater"
		sudo bash $INSTALL_DIR/$INSTALL_NAME/install.sh
		if [ $? -eq 2 ]; then
			echo "continue install"
			sudo reboot
			exit 0
		fi

		echo "update finish"
	fi

	# cleanup
	sed 1d -i $INSTALL_QUEUE
	sudo rm -rf $INSTALL_DIR/$INSTALL_NAME

	if [ $INSTALL_STATUS = 1 ]; then
		sudo reboot
	fi
fi

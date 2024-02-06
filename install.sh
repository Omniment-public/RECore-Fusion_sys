#!/bin/bash
#RECore Fusion Sysfile installer

NAME="RECore-Fusion_sys"
NAME_APP="recore-lighttpd"
VERSION="v0.0.6"
REPO_INFO="Omniment-public/RECore-Fusion_sys"

SYS_DIR="/usr/local/bin/recore/files"
INSTALL_DIR="/usr/local/bin/recore/install/"$NAME
APP_DIR=$SYS_DIR/$NAME_APP
REGIST_DIR=$SYS_DIR"/app"

# check root
if [ ! "$(id -u)" = 0 ]; then
	echo "Please run root user"
	exit 1
fi

mkdir $APP_DIR
mkdir $APP_DIR/.info

if [ ! -e $INSTALL_DIR/install_step ]; then
	sudo bash -c "echo 0 > $INSTALL_DIR/install_step"
fi

INSTALL_STEP=$(<$INSTALL_DIR"/install_step")

if [ $INSTALL_STEP = 0 ]; then
	# system file setup
	echo "install system"
	bash $INSTALL_DIR/install_sys.sh
	sudo bash -c "echo 1 > $INSTALL_DIR/install_step"

	# continue
	exit 2
	
	reboot
else
	# lighttpd docker setup
	echo "install lighttpd"
	bash $INSTALL_DIR/$NAME_APP/install.sh

	sudo bash -c "echo 'version=\"'$VERSION'\"' > $REGIST_DIR/$NAME"
	sudo bash -c "echo 'repo=\"'$REPO_INFO'\"' >> $REGIST_DIR/$NAME"
	sudo bash -c "echo 'dir=\"'$APP_DIR'\"' >> $REGIST_DIR/$NAME"
fi

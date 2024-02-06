#!/bin/bash
#argv $1:version
RELEASEDIR=RECore-Fusion_sys-$1

# check args
if [ $# != 1 ]; then
    echo "need version args"
    exit 1
fi

echo "make release package"

# mkdir release
mkdir $RELEASEDIR
mkdir $RELEASEDIR/recore-lighttpd

# cp files
cp install.sh ./$RELEASEDIR
cp install_sys.sh ./$RELEASEDIR
cp -r raspberry-pi ./$RELEASEDIR
cp ./recore-lighttpd/install.sh ./$RELEASEDIR/recore-lighttpd

# build docker
echo "build docker image"
sudo chmod +x ./recore-lighttpd/build_release.sh
sudo ./recore-lighttpd/build_release.sh $1

echo "move package"
mv ./recore-lighttpd/recore-lighttpd-image.tar.gz ./$RELEASEDIR/recore-lighttpd

echo "compress package"
tar -zcvf RECore-Fusion_sys-$1.tar.gz $RELEASEDIR

echo "complete release package make"

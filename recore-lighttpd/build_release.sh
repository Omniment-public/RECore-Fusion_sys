#!/bin/bash

#argv $1:version

# check args
if [ $# != 1 ]; then
    echo "need version args"
    exit 1
fi

cd "$(dirname "$0")"

# build
docker build -t recore-lighttpd:$1 .

echo "export image"
docker save recore-lighttpd:$1 -o "recore-lighttpd-image.tar"

# compress
echo "compress"
tar -zcvf recore-lighttpd-image.tar.gz recore-lighttpd-image.tar

#!/bin/bash

#argv $1:version

# build
docker build -t recore-lighttpd:$1 .
docker save recore-lighttpd:$1 -o "recore-lighttpd-image.tar"

# compress
tar -zcvf recore-lighttpd-image.tar.gz recore-lighttpd-image.tar

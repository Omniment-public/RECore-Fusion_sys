#!/bin/bash

#argv $1:version

# build
docker build -t --no-cache recore-lighttpd:$1 .
docker save recore-lighttpd:$1 -o "recore-lighttpd-image.tar"

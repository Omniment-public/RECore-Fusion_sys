#!/bin/bash

#argv $1:version

# check args
if [ $# != 1 ]; then
    echo "need version args"
    exit 1
fi

cd "$(dirname "$0")"

# build
docker build -t recore-lighttpd-test:$1 .

docker stop recore-lighttpd-test
docker rm recore-lighttpd-test

docker run -d --privileged --net=host \
  -v /usr/bin/systemctl:/usr/bin/systemctl \
  -v /etc/hostname:/etc/hostname \
  -v /etc/hosts:/etc/hosts \
  -v /usr/local/bin/recore/files:/usr/local/bin/recore/files \
  -v /usr/local/bin/recore/install:/usr/local/bin/recore/install \
  -v /etc/hostapd/hostapd.conf:/etc/hostapd/hostapd.conf \
  -v /run/systemd/system:/run/systemd/system \
  -v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket \
  -v /sys/fs/cgroup:/sys/fs/cgroup \
  -v /usr/local/bin/recore/files/version:/usr/local/bin/recore/files/version \
  -v /home/recore/fusion-files/:/home/recore/fusion-files/ \
  -v /etc/NetworkManager/system-connections:/etc/NetworkManager/system-connections:rw \
  -v /var/lib/NetworkManager:/var/lib/NetworkManager \
  -e DBUS_SYSTEM_BUS_ADDRESS=unix:path=/var/run/dbus/system_bus_socket \
  --name recore-lighttpd-test \
  recore-lighttpd-test:$1 \
  lighttpd -f /etc/lighttpd/lighttpd.conf -D && RUN_STATE=1
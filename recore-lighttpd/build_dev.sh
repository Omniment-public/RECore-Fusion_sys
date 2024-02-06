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
docker run -d --privileged --net=host -v /usr/bin/systemctl:/usr/bin/systemctl -v /etc/hostname:/etc/hostname -v /etc/hosts:/etc/hosts -v /usr/local/bin/recore/files:/usr/local/bin/recore/files -v /usr/local/bin/recore/install:/usr/local/bin/recore/install -v /etc/hostapd/hostapd.conf:/etc/hostapd/hostapd.conf -v /etc/wpa_supplicant/wpa_supplicant.conf:/etc/wpa_supplicant/wpa_supplicant.conf -v /run/systemd/system:/run/systemd/system -v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket -v /sys/fs/cgroup:/sys/fs/cgroup -v /usr/local/bin/recore/files/version:/usr/local/bin/recore/files/version -v /home/recore/fusion-files/:/home/recore/fusion-files/ --name recore-lighttpd-test recore-lighttpd-test:$1 lighttpd -f /etc/lighttpd/lighttpd.conf -D && RUN_STATE=1

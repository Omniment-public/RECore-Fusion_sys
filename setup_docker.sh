# setup docker
DOCKER_FILES="/usr/local/bin/recore/update/docker"

# stop and remove old container
docker rm -f jupyter lighttpd

#docker build -t lighttpd-recore:"v0.0.0" $DOCKER_FILES/docker-lighttpd
#docker build -t jupyter-recore:"v0.0.0" $DOCKER_FILES/docker-jupyter

docker build -t recore-lighttpd:"v0.0.0" .
docker build -t recore-jupyter:"v0.0.0" .

docker save recore-lighttpd:"v0.0.0" -o "recore-lighttpd-image.tar"
docker save recore-jupyter:"v0.0.0" -o "recore-jupyter-image.tar"

docker image prune -f

docker run -d --privileged --net=host -v /usr/bin/systemctl:/usr/bin/systemctl -v /etc/hostname:/etc/hostname -v /usr/local/bin/recore/files:/usr/local/bin/recore/files -v /usr/local/bin/recore/updater:/usr/local/bin/recore/updater -v /etc/hostapd/hostapd.conf:/etc/hostapd/hostapd.conf -v /etc/wpa_supplicant/wpa_supplicant.conf:/etc/wpa_supplicant/wpa_supplicant.conf -v /run/systemd/system:/run/systemd/system -v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket -v /sys/fs/cgroup:/sys/fs/cgroup -v /usr/local/bin/recore/files/version:/usr/local/bin/recore/files/version -v /usr/local/bin/recore/update:/usr/local/bin/recore/update --name lighttpd lighttpd-recore lighttpd -f /etc/lighttpd/lighttpd.conf -D
docker run -d --privileged -p8888:8888 -v /dev:/dev -v /home/recore/fusion-files/fusion-notebook:/home/recore/fusion-notebook -v /home/recore/fusion-files/site-package:/home/recore/.local/lib/python3.9/site-packages --name jupyter jupyter-recore jupyter notebook
# docker run -d --privileged -p8888:8888 -v /dev:/dev -v /home/recore/fusion-files/fusion-notebook:/home/recore/fusion-notebook -v /home/recore/fusion-files/jupyter-venv:/home/recore/jupyter-venv --restart=always --name jupyter jupyter-recore bash -c ". /home/recore/jupyter-venv/bin/activate && jupyter notebook"

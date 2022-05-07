# setup docker
docker build -t lighttpd-recore ./docker/docker-lighttpd
docker build -t jupyter-recore ./docker/docker-jupyter

docker run -d --privileged --net=host -p 80:80 -v /etc/hostname:/etc/hostname -v /usr/local/bin/recore/files:/usr/local/bin/recore/files -v /usr/local/bin/recore/updater:/usr/local/bin/recore/updater -v /etc/hostapd/hostapd.conf:/etc/hostapd/hostapd.conf -v /etc/wpa_supplicant/wpa_supplicant.conf:/etc/wpa_supplicant/wpa_supplicant.conf --restart=always --name lighttpd lighttpd-recore lighttpd -f /etc/lighttpd/lighttpd.conf -D
docker run -d --privileged -p8888:8888 -v /dev:/dev -v /home/recore/fusion-files/fusion-notebook:/home/recore/fusion-notebook -v /home/recore/.local/lib/python3.9/site-packages:/home/recore/fusion-files/site-package --restart=always --name jupyter jupyter-recore jupyter notebook

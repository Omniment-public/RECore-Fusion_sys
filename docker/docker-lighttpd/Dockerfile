FROM debian
MAINTAINER OMNIMENT INC.

USER root

RUN apt-get clean
RUN apt-get update

RUN apt-get install -qy apt-utils
RUN apt-get install -qy locales
RUN apt-get install -qy locales-all
RUN locale-gen ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL ja_JP.UTF-8

RUN apt-get install -qy sudo
RUN apt-get install -qy git
RUN apt-get install -qy vim
RUN apt-get install -qy wget
RUN apt-get install -qy unzip
RUN apt-get install -qy python3
RUN apt-get install -qy lighttpd
RUN apt-get install -qy wireless-tools
RUN apt-get install -qy systemctl

# move config file
RUN lighttpd-enable-mod cgi
COPY ./conf/lighttpd.conf /etc/lighttpd/
COPY ./conf/10-cgi.conf /etc/lighttpd/conf-available/
COPY ./conf/lighttpd-sudo /etc/sudoers.d/
RUN chown root /etc/sudoers.d/lighttpd-sudo
RUN chmod 440 /etc/sudoers.d/lighttpd-sudo

# move html file
COPY ./web/ /var/www/html/

# move cgi files
COPY ./cgi/ /usr/lib/cgi-bin/

# add group
RUN groupadd -f -g 20 dialout
RUN usermod -aG dialout www-data

RUN mkdir /usr/local/bin/recore-firmware/
COPY ./firmware/ /usr/local/bin/recore-firmware/

RUN chmod 666 /etc/hosts
RUN chmod 666 /etc/hostname

#docker build -t lighttpd-recore .
#docker run -d --name lighttpd --restart=always --net=host --privileged -p 80:80  -v /etc/hostname:/etc/hostname -v /usr/local/bin/recore/files:/usr/local/bin/recore/files -v /usr/local/bin/recore/updater:/usr/local/bin/recore/updater -v /etc/hostapd/hostapd.conf:/etc/hostapd/hostapd.conf -v /etc/wpa_supplicant/wpa_supplicant.conf:/etc/wpa_supplicant/wpa_supplicant.conf lighttpd-recore lighttpd -f /etc/lighttpd/lighttpd.conf -D

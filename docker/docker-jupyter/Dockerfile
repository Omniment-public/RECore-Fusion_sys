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
RUN apt-get install -qy python3-pip
RUN pip install -U pip

RUN apt-get install -qy jupyter-notebook
RUN apt-get -qy install fonts-noto-cjk
RUN apt-get install -qy fonts-ipaexfont

RUN apt-get -qy autoremove

RUN pip install certifi
RUN pip install chardet
RUN pip install colorzero
RUN pip install distro
RUN pip install gpiozero
RUN pip install idna
# RUN pip install python-apt
RUN pip install requests
RUN pip install RPi.GPIO
RUN pip install setuptools
RUN pip install six
RUN pip install spidev
RUN pip install ssh-import-id
RUN pip install urllib3
RUN pip install wheel
RUN pip install jupyter-contrib-nbextensions

RUN pip install -U numpy
RUN pip install -U pandas
RUN pip install -U scipy
RUN pip install -U picamera
RUN pip install -U opencv-python
RUN pip install -U torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cpu

COPY ./pyrecore-0.0.0-py3-none-any.whl /
RUN pip install pyrecore-0.0.0-py3-none-any.whl

# make user "recore"
ARG UID=1000
ARG GID_primary=1000
ARG GID_root=0
ARG GID_secondary=0,4,20,24,27,29,44,46,60,100,104,106,108,997,998,999

RUN groupadd -f -g 4 adm
RUN groupadd -f -g 20 dialout
RUN groupadd -f -g 24 cdrom
RUN groupadd -f -g 27 sudo
RUN groupadd -f -g 29 audio
RUN groupadd -f -g 44 video
RUN groupadd -f -g 46 plugdev
RUN groupadd -f -g 60 games
RUN groupadd -f -g 100 users
RUN groupadd -f -g 104 input
RUN groupadd -f -g 106 render
RUN groupadd -f -g 108 netdev
RUN groupadd -f -g 997 gpio
RUN groupadd -f -g 998 i2c
RUN groupadd -f -g 999 spi

RUN useradd -m -u ${UID} -g ${GID_root} -G ${GID_secondary} recore
USER recore

# make jupyter directory
RUN mkdir /home/recore/fusion-notebook

RUN jupyter notebook --generate-config -y

RUN mkdir /home/recore/.jupyter/custom/

COPY ./snippets_extensions/custom.js /home/recore/.jupyter/custom/
COPY ./pyrecore-notebook/ /pyrecore-notebook/
RUN jupyter contrib nbextension install --user
RUN jupyter nbextensions_configurator enable --user
RUN jupyter nbextension enable snippets_menu/main --user
RUN jupyter nbextension install pyrecore-notebook --user
RUN jupyter nbextension enable pyrecore-notebook/extension --user

COPY ./jupyter_notebook_config.py /home/recore/.jupyter/

#docker build -t jupyter-recore .
#docker run -d --privileged -v /dev:/dev -v /home/recore/fusion-files/fusion-notebook:/home/recore/fusion-notebook -v /home/recore/.local/lib/python3.9/site-packages:/home/recore/fusion-files/site-package -p8888:8888 --restart=always --name jupyter recore-jupyter jupyter notebook

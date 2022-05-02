#!/bin/bash

cd ./files/

jupyter contrib nbextension install --user
jupyter nbextensions_configurator enable --user

#jupyter nbextension enable snippets/main --user
jupyter nbextension enable snippets_menu/main --user

jupyter nbextension install pyrecore-notebook --user
jupyter nbextension enable pyrecore-notebook/extension --user

mkdir ~/.jupyter/custom/
sudo mv ./extensions/custom.js ~/.jupyter/custom/

sudo reboot
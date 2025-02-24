#!bin/bash

LED_GREEN_VAL=23

pinctrl set $LED_GREEN_VAL op dl

while : ;do
	pinctrl set $LED_GREEN_VAL op dh
	sleep 1
	pinctrl set $LED_GREEN_VAL op dl
	sleep 1
done

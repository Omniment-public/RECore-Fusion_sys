#!bin/bash

LED_GREEN_VAL="/sys/class/gpio/gpio23/value"

while : ;do
	echo 1 > $LED_GREEN_VAL
	sleep 1
	echo 0 > $LED_GREEN_VAL
	sleep 1
done

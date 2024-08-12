#!/bin/sh
if [ $(bluetoothctl show | grep "Powered: yes" | wc -c) -eq 0 ]
then
  echo "%{F#66ffffff}󰂲"
else
  if [ $(echo info | bluetoothctl | grep 'Device ' | wc -c) -eq 0 ]
  then 
    echo "󰂯"
  else
    echo "%{F#2193ff}󰂱 $(pactl list cards sinks | grep codec | sed 's/.*= "\(.*\)"/\1/' | tr '[:lower:]' '[:upper:]')"
  fi
fi


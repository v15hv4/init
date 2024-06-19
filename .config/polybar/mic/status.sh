#!/bin/sh

if [ $(pamixer --default-source --get-mute) == "false" ]; then
  echo "%{F#ffaeea00}󰍬"
else
  echo "%{F#ffff6e40}󰍭"
fi

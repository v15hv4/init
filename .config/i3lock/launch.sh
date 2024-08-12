#!/bin/bash

IMAGE="$HOME/Pictures/.current-blur"

BLANK='#00000000'
CLEAR='#ffffff00'
DEFAULT='#ffffff'
KEY='#000000'
TEXT='#ffffff'
WRONG='#ff5555'
VERIFYING='#414458'

# pause notifs
dunstctl set-paused true

# launch lock screen
i3lock -n -i $IMAGE -L -c $KEY \
    --insidever-color=$CLEAR \
    --ringver-color=$VERIFYING \
    \
    --insidewrong-color=$WRONG \
    --ringwrong-color=$DEFAULT \
    \
    --inside-color=$CLEAR \
    --ring-color=$DEFAULT \
    --line-color=$BLANK \
    --separator-color=$DEFAULT \
    \
    --verif-color=$TEXT \
    --wrong-color=$TEXT \
    --time-color=$TEXT \
    --date-color=$TEXT \
    --layout-color=$TEXT \
    --keyhl-color=$KEY \
    --bshl-color=$WRONG \
    \
    --radius 180 \
    --indicator \
    --clock \
    \
    --time-str="%H:%M" \
    --date-str="%A, %d %B" \
    --time-font="SF Pro Display" \
    --date-font="SF Pro Display" \
    --time-size=64 \
    --date-size=28 \
    --date-pos="tx:ty+40" \
    \
    --verif-text="" \
    --wrong-text="!" \
    --noinput-text="?" \
    \
    --pass-media-keys \
    --pass-volume-keys \
    --pass-screen-keys \
    --pass-power-keys \

# resume notifs
dunstctl set-paused false

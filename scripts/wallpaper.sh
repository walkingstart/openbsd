#!/bin/sh

export DISPLAY=:0
feh --bg-fill --no-fehbg `find /home/zero/picture -type f -exec echo '{}' \; | sed -n "$(($RANDOM%$(ls /home/zero/picture | wc -l)+1))p"`

#feh --bg-fill --randomize /home/zero/picture/*

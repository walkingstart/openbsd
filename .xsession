#!/bin/ksh
# use UTF-8 everywhere
export LANG=en_US.UTF-8
export LC_CTYPE=zh_CN.UTF-8
# specify location of kshrc
export ENV=$HOME/.kshrc

# graphic acceleration for Firefox
export MOZ_ACCELERATED=1
export MOZ_WEBRENDER=1
export HIDPI=1

# allow web assembly in Chromium
export ENABLE_WASM=1

# keep clipboards in sync
 autocutsel -fork
 autocutsel -selection PRIMARY -fork

# suppress blue light at night
redshift -l 40.2732:-76.8867 -g 0.9 &

xset -b &
xset +fp ~/.fonts
for font in /usr/local/share/fonts/*; do
        xset +fp "${font}"
        done
xset fp rehash

# load Xresources file
xrdb -merge $HOME/.Xresources

# set your background color
#xsetroot -solid dimgray

# xidle will lock your display after a period of inactivity
xidle -timeout 300 &

# sadly, xclock has a bug where the font selection is ignored when UTF-8
# is enabled, so we unset LANG here.
#USER=$(whoami)
#HOST=$(hostname -s)
#LANG= xclock -strftime "$USER@$HOST | %m/%d/%Y %H:%M" -geometry -10-10 -render -face "Noto Mono:pixelsize=24" &

# disable system beep
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
#xset s 0 &
xset b 0 0 0
#xset -dpms  &
#setterm -blank 0 &
#xblacklight -set 10 &
urxvtd -q -o -f
feh --bg-fill ~/picture/bird.jpg
compton &
fcitx &

# start cwm!
#exec cwm
exec xterm -geometry 1920x1+0+0 -fa "CodeNewRoman Nerd Font:size=12" -fs 12 -bg "black" -fg "grey" -name termbar -class termbar -T termbar -e /home/zero/scripts/termbar &

#xterm -name termbar -class termbar -e /home/zero/termbar &

#xterm -name termbar -class termbar -e /home/zero/myown/termbar &
exec cwm

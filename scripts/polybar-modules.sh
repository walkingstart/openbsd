#!/bin/ksh

#_blu="#5294e2"
#_grn="#87B158"
#_orn="#EE923A"
#_red="#E25252"
_blu="#50FA7B"
_grn="#69FF94"
_orn="#F1FA8C"
_red="#FF5555"

# Nerd Fonts
set -A _bat "%{F$_grn}" "%{F$_orn}" "%{F$_red}"
set -A _pwr "%{F$_blu}"
#set -A _net "" "直"
set -A _lan "%{F$_blu}"
set -A _wan "%{F$_grn}直" "%{F$_orn}直" "%{F$_red}直"
set -A _nic "em0" "iwm0"
set -A _vol "奄" "奔" "墳"

# Functions ------------------------------------------------------------

function battery {
	[[ $(apm -a) -eq 1 ]] \
	  && echo -n "%{T2}${_pwr[0]}" \
	  || echo -n "%{T2}${_bat[$(apm -b)]}"
	echo -n "%{T-}%{F-} $(apm -l)%"
}

function datetime {
	[[ $(date "+%H") -ge 6 && $(date "+%H") -le 22 ]] \
	  && echo -n "%{F-}" \
	  || echo -n "%{F$_orn}"
	echo -n $(date '+%a. %e %b.  %H:%M')%{F-}
}

function kbdlayout {
	setxkbmap -query | \
	awk '/^layout:/ { printf "%%\{T2\} %%\{T-\} %s", toupper($2) }'
}

function network {
	[[ -z "$(ifconfig ${_nic[0]} | grep 'status: no carrier')" ]] \
		&& echo -n %{T2}${_lan[0]}%{F-}%{T-} && return
	ifconfig ${_nic[1]} | \
	  awk -v g=${_wan[0]} -v o=${_wan[1]} -v r=${_wan[2]} '/ieee80211:/ {
	    if(int($8) < 50)      { printf "%s", r }
	    else if(int($8) < 80) { printf "%s", o }
	    else             { printf "%s", g }
	    { printf "  %%\{F-\} %s %4s", $3, $8 }
	  }'
}

function sensor {
	sysctl -n hw.sensors.cpu0.temp0 | \
	awk -v warn=$_orn -v alrt=$_red '{
	  if($1 < 50)      { printf "%%\{F-}" }
	  else if($1 < 75) { printf "%%\{F%s}", warn }
	  else             { printf "%%\{F%s}", alrt }
	  { printf "%%\{T2}%%\{T-} %4.0d°C%%\{F-}", $1 }
}'
}

function volume {
	_v=$(sndioctl -n output.level | awk '{ print int($0*100) '})
	[[ $(sndioctl -n input.mute) -eq 1 ]] \
		&& echo -n "%{F-}%{F-}  " \
		|| echo -n "%{F$_orn}%{F-}  "
	[[ $(sndioctl -n output.mute) -eq 1 ]] \
		&& echo -n "婢  " \
		|| echo -n "${_vol[$(($_v*3/101))]}  "
	echo -n "$_v%"
}

case $1 in
	"battery") battery;;
	"datetime") datetime;;
	"kbdlayout") kbdlayout;;
	"network") network;;
	"sensor") sensor;;
	"volume") volume;;
	*)
		echo "You forgot to tell me what to do!"
		exit 1
	;;
esac

exit 0
#EOF

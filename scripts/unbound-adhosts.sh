#!/bin/ksh
#
# Using blacklist from pi-hole project https://github.com/pi-hole/
# to enable AD blocking in unbound(8)
#
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"

# Available blocklists - comment line to disable blocklist
_disconad="https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
_discontrack="https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt"
_malwaredom="https://mirror1.malwaredomains.com/files/justdomains"
_stevenblack="https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
_yhosts="https://raw.githubusercontent.com/vokins/yhosts/master/hosts"
_adwars="https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts"
_gooler="https://raw.githubusercontent.com/Goooler/1024_hosts/master/hosts"
_neohost="https://cdn.jsdelivr.net/gh/neoFelhz/neohosts@gh-pages/127.0.0.1/full/hosts"

# Global variables
_tmpfile="$(mktemp)" && echo '' > $_tmpfile
_unboundconf="/var/unbound/etc/unbound-adhosts.conf"

# Remove comments from blocklist
function simpleParse {
  ftp -VMo - $1 | sed -e 's/#.*$//' -e 's/\r//' -e '/^[[:space:]]*$/d' >> $2
}

# Parse MalwareDom
[[ -n ${_malwaredom+x} ]] && simpleParse $_malwaredom $_tmpfile


# Parse ZeusTracker
#[[ -n ${_windyblock+x} ]] && simpleParse $_windyblock $_tmpfile

# Parse DisconTrack
[[ -n ${_discontrack+x} ]] && simpleParse $_discontrack $_tmpfile

# Parse DisconAD
[[ -n ${_disconad+x} ]] &&  simpleParse $_disconad $_tmpfile

# Parse StevenBlack
[[ -n ${_stevenblack+x} ]] && ftp -VMo - $_stevenblack | sed -n '/Start/,$p' | sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' | awk '/^0.0.0.0/ { print $2 }' >> $_tmpfile

# Parse StevenBlack
[[ -n ${_adwars+x} ]] && ftp -VMo - $_adwars | sed -n '/Start/,$p' | sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' | awk '/^127.0.0.1/ { print $2 }' >> $_tmpfile

# Parse StevenBlack
[[ -n ${_gooler+x} ]] && ftp -VMo - $_gooler | sed -n '/Start/,$p' | sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' | awk '/^127.0.0.1/ { print $2 }' >> $_tmpfile

# Parse yhosts
[[ -n ${_yhosts+x} ]] && ftp -VMo - $_yhosts | sed -n '/Start/,$p' | sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' | awk '/^127.0.0.1/ { print $2 }' >> $_tmpfile

# Parse yhosts
[[ -n ${_neohost+x} ]] && ftp -VMo - $_neohost | sed -n '/Start/,$p' | sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' | awk '/^127.0.0.1/ { print $2 }' >> $_tmpfile

# Create unbound(8) local zone file
sort -fu $_tmpfile | grep -v "^[[:space:]]*$" | awk '{
  print "local-zone: \"" $1 "\" redirect"
  print "local-data: \"" $1 " A 127.0.0.1\""
}' > $_unboundconf && rm -f $_tmpfile
#sort -fu $_tmpfile | grep -v "^[[:space:]]*$" | sed -e 's/\r//' | awk '{
#print "local-zone: \"" $1 "\" static"
#}' > $_unboundconf && rm -f $_tmpfile

# Reload unbound(8) blocklist
#doas -u _unbound unbound-checkconf 1>/dev/null && doas -u _unbound unbound-control reload 1>/dev/null

exit 0
#EOF

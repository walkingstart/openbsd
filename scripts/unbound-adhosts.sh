#!/bin/ksh
#
# Using blacklist from pi-hole project https://github.com/pi-hole/
# to enable AD blocking in unbound(8)
#
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"

# Available blocklists - comment line to disable blocklist
_disconad="https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
_discontrack="https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt"
_hostfiles="https://hosts-file.net/ad_servers.txt"
_malwaredom="https://mirror1.malwaredomains.com/files/justdomains"
_stevenblack="https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
_zeustracker="https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist"

# Global variables
_tmpfile="$(mktemp)" && echo '' > $_tmpfile
_unboundconf="/var/unbound/etc/unbound-adhosts.conf"

# Remove comments from blocklist
function simpleParse {
  ftp -VMo - $1 | \
  sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' >> $2
}

# Parse MalwareDom
[[ -n ${_malwaredom+x} ]] && simpleParse $_malwaredom $_tmpfile

# Parse ZeusTracker
[[ -n ${_zeustracker+x} ]] && simpleParse $_zeustracker $_tmpfile

# Parse DisconTrack
[[ -n ${_discontrack+x} ]] && simpleParse $_discontrack $_tmpfile

# Parse DisconAD
[[ -n ${_disconad+x} ]] &&  simpleParse $_disconad $_tmpfile

# Parse StevenBlack
[[ -n ${_stevenblack+x} ]] && \
  ftp -VMo - $_stevenblack | \
  sed -n '/Start/,$p' | \
  sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' | \
  awk '/^0.0.0.0/ { print $2 }' >> $_tmpfile

# Parse hpHosts
[[ -n ${_hostfiles+x} ]] && \
  ftp -VMo - $_hostfiles | \
  sed -n '/START/,$p' | tr -d '^M$' | \
  sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' -e 's/$//' | \
  awk '/^127.0.0.1/ { print $2 }' >> $_tmpfile

# Create unbound(8) local zone file
sort -fu $_tmpfile | grep -v "^[[:space:]]*$" | \
awk '{
  print "local-zone: \"" $1 "\" redirect"
  print "local-data: \"" $1 " A 0.0.0.0\""
}' > $_unboundconf && rm -f $_tmpfile

# Reload unbound(8) blocklist
doas -u _unbound unbound-checkconf 1>/dev/null && \
doas -u _unbound unbound-control reload 1>/dev/null

exit 0
#EOF

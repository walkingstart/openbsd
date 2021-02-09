#   Pf-badhost
28 January 2021

Installation guide on OpenBSD, in 10 simple steps

Create a new user on your system, '\_pfbadhost' as example.

The user should be created with default shell of nologin, home folder set to /var/empty/ with no password specified (logins disabled).

\begin{tcolorbox}

useradd -s /sbin/nologin -d /var/empty \_pfbadhost

Download pf-badhost:

  # ftp https://geoghegan.ca/pub/pf-badhost/0.5/pf-badhost.sh
  
  Install script with appropriate permissions:
  
  # install -m 755 -o root -g bin pf-badhost.sh /usr/local/bin/pf-badhost
  
Create required files:
  
  # install -m 640 -o \_pfbadhost -g wheel /dev/null /etc/pf-badhost.txt
  
  # install -d -m 755 -o root -g wheel /var/log/pf-badhost
  
  # install -m 640 -o \_pfbadhost -g wheel /dev/null /var/log/pf-badhost/pf-badhost.log
  
  # install -m 640 -o \_pfbadhost -g wheel /dev/null /var/log/pf-badhost/pf-badhost.log.0.gz


Give user '_pfbadhost' strict doas permission for the exact commands the script needs run as superuser.

NOTE: Unlike 'sudo', _ALL_ users must be explicitly granted permission to use doas, even the root user. (Create /etc/doas.conf if doesn't exist)


  # cat /etc/doas.conf
  
  permit root
  
  permit nopass _pfbadhost cmd /sbin/pfctl args -nf /etc/pf.conf
  
  permit nopass _pfbadhost cmd /sbin/pfctl args -t pfbadhost -T replace -f /etc/pf-badhost.txt
  
  
  # Optional rule for authlog scanning
  
  permit nopass _pfbadhost cmd /usr/bin/zcat args -f /var/log/authlog /var/log/authlog.0.gz


Add the following lines to your PF's configuration file located usually in /etc/pf.conf: (Putting it higher-up/earlier in the ruleset is recommended)

  …
  table <pfbadhost> persist file "/etc/pf-badhost.txt"
  
  block in quick on egress from <pfbadhost>
  
  block out quick on egress to <pfbadhost>
  …


The lines above in pf.conf do the following things;

Create a table titled "pfbadhost"

Link the table to the contents (IP addresses) in /etc/pf-badhosts.txt

Block both incoming/outgoing traffics coming from those IPs to your server, through egress ('egress' contains the interface(s) that holds the default route(s))


Run the pfbadhost.sh script as user "_pfbadhost" using the "-O openbsd" argument:

  # doas -u \_pfbadhost pf-badhost -O openbsd

Reload your pf rule set:

  # pfctl -f /etc/pf.conf

For good measure, run the pf-badhost.sh script once more:

  # doas -u \_pfbadhost pf-badhost -O openbsd

Edit _pfbadhost user's crontab to run pf-badhost.sh every night at midnight:

  # crontab -u \_pfbadhost -e
  ~ 0~1 * * * -s pf-badhost -O openbsd

Yay! pf-badhost is now installed! With the nightly cron job, the list will be regularly updated with the latest known bad hosts.

Some useful PF commands to manage the PF’s table "pfbadhost"

List the table contents (List of blocked IPs – get ready for a huge list):

  pfctl -t pfbadhost -T show

Manually add IPs into the table pfbadhost:

  pfctl -t pfbadhost -T add 192.16.42.52

  pfctl -t pfbadhost -T add 195.11.0.0/16

Delete IPs:

  pfctl -t pfbadhost -T delete 192.168.0.0/16

Scan IPs inside the table (check if you block a specific IP address):

  pfctl -t pfbadhost -T test 192.16.42.52

Overview of Features from Jordan Geoghegan

Fetching Lists

PF-badhost supports downloading lists in parallel and is able to reattempt failed downloads.

By default PF-badhost will run up to 5 parallel fetch operations and will make an attempt to fetch each list up to 3 times before aborting.

By default, PF-badhost runs in ‘strict’ mode, which means it will abort if it fails to fetch a list upon hitting the maximum specified retry limit.

Parallel fetches, retries and strict mode can be configured within the 'User Configuration Area' or on the command line with the ‘-P’, ‘-R’ and ‘-o’ options respectively. ‘-P’ and ‘-R’ require a positive integer as an argument – if set to 0, then parallelism or retries will be disabled. Strict mode can be enabled/disabled with ‘-o strict’ or ‘-o no-strict’.

Use Alternate Lists

There are several ways to use alternate lists with PF-badhost

Edit config in 'User Configuration Area' at top of script

Specify blocklist URL with ‘-l’ option

Specify path to text file containing a list of one or more URLs with ‘-u’ option

Lists may be fetched via a local path, an HTTP/HTTPS URL or an FTP link.

Multiple fetch utilities are supported, such as ‘curl’, ‘wget’, FreeBSD’s ‘fetch’ and OpenBSD’s ‘ftp’.

Fetch utility preference may be specified with with the ‘-F’ option, otherwise a utility available from the base system is used.

Any URL format may be used, as long as it is supported by your specified fetch utility. Fetched lists may optionally be gzip compressed.
Export

Generated blocklists can easily be exported for external use by using the ‘-x’ option. When ‘-x’ is specified, PF-badhost will print the generated list to stdout.
IP Address Families

IP address families can be configured within the 'User Configuration Area' or from the command line using the ‘-4’, ‘-6’ and ‘-B’ options. ‘-4’ and ‘-6’ are used to generate IPv4-only and IPv6-only lists, and ‘-B’ can be used to generate a mixed list.
Filter by ASN

There are several ways to filter an ASN with PF-badhost:

Edit config in 'User Configuration Area' at top of script

Specify single ASN to block with ‘-a’ option

Specify path to text file containing a list of one or more ASN with ‘-j’ option

PF-badhost can block networks and organizations by ASN (Autonomous System Number). It does this by taking 1 or more specified ASN and finding IP addresses and subnets associated with that ASN by querying the RADb ‘whois’ service. PF-badhost is able to efficiently perform very large queries against the RADb database as a dedicated socket is opened, allowing many queries to be made without the overhead of setting-up and tearing down a connection for each query. It is highly recommended to use subnet aggregation with ASN filtering, as RADb tends to return data in the form of a large number of individual /24 subnets rather than more compact aggregated CIDR notation. If you’re also using IPv6, then the subnet aggregation recommendation becomes even more relevant.

SSH Authlog Analysis / Hail Mary Mitigation

PF-badhost is able to analyze system SSH logs to identify and block brute-forcers. The brute-force failed login limit can be specified to allow the user to tune the blocking threshold to meet their needs.
Subnet Aggregation

If subnet aggregation is enabled (within the 'User Configuration Area' or using the ‘-A’ switch), PF-badhost will opportunistically make use of the ‘aggregate’, ‘aggregate6’ or ‘aggy’ utilities if they are found within the users \$PATH. If none of the supported aggregation utilities are found, then a pure Perl IPv4 aggregator will be used as a fallback option if Perl is installed.

Subnet aggregation is useful as it can greatly reduce the number of items in the PF-badhost table, and thus reduce resource usage and improve performance. This becomes especially relevant on low powered devices. Subnet aggregation works by taking a list of IP addresses and CIDR blocks/subnets and then parsing the data into the smallest possible representation using CIDR notation. It does this by looking for any overlapping ranges or adjacent subnets than can be merged. Subnet aggregation does have a bit of CPU overhead and processing time, but work is currently underway on an experimental aggregation utility written in Go that is approximately 100x faster than the current fastest solution.

Geo-Blocking

There are several ways to geo-block with PF-badhost:

Enable option in 'User Configuration Area' at top of script

Specify ISO-3166 country code to block with ‘-g’ option

PF-badhost supports geo-blocking any country by specifying its ISO-3166 two letter code. Country codes are case insensitive. Geo-blocking data is pulled from official Regional Internet Registry datasets.
Tor Filtering

PF-badhost is able to filter or whitelist Tor. Tor filtering can be configured within the 'User Configuration Area' at the top of the script, or can be invoked with the ‘-T’ option.

The ‘-T’ option requires an argument (case insensitive). Valid options are:

'allow' – whitelist all Tor nodes

'block' – block all Tor nodes

'block\_exit' – block all Tor exit nodes.

Bogon Filtering

PF-badhost is able to filter IPv4 and IPv6 bogons. Bogons are basically unassigned/reserved/private address ranges that should not be communicating on the public internet. IPv4 bogon filtering can be a little dicey as there is barely any unassigned IPv4 space remaining, but it can still have its uses. IPv6 bogon filtering however can make a lot of sense, as only 1/8 of the IPv6 address space is being allocated, and the remaining 7/8 is reserved for future use. This means that over 85% of the IPv6 address space can be safely blocked.

Whitelisting

There are several ways to whitelist addresses and specify custom rules with PF-badhost:

Edit config in 'User Configuration Area' at top of script

Specify single custom PF table entry with ‘-r’ option

Specify path to text file containing list of desired custom PF table entries with ‘-w’ option


Many blocklists contain address ranges within the RFC 3330 and RFC 5156 address space. This can be quite the foot gun, as blocking this address space can have unintended and difficult to debug consequences. By default, PF-badhost now automatically whitelists RFC 3330 and 5156 address space to avoid such issues. If you know what you’re doing and don’t want that address space whitelisted, then you will need to remove the default whitelist entries from within the 'User Configuration Area'.

Logging

PF-badhost logs it’s two most recently generated blocklists within ‘/var/log/pf-badhost/’ and error messages to stderr and ‘/var/log/messages’.


Logging to ‘/var/log/pf-badhost/’ can be enabled or disabled with the ‘-o log’ or ‘-o no-log’ options.

Critical error messages will always be logged. Printing to stderr of info, warning and error messages may however be disabled with the ‘-V’ switch.

If the mail system on your machine is configured, PF-badhost statistics and cron job results can be mailed to you. This is a feature of cron rather than a feature of PF-badhost, so you will have to check the documentation relevant to your system. The premise is simple: just forward all mail for user ‘\_pfbadhost’ to your preferred email account.



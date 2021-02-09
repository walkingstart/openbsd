#   Samba Config
28 January 2021


/etc/samba/smb.conf  example:

  [global]
  
  workgroup = WORKGROUP
  
  netbios name = File Server
  
  server string = OpenBSD Samba Server
  
  max log size = 100
  
  local master = yes
  
  os level = 100
  
  invalid users = nobody root
  
  load printers = no
  
  max connections = 10
  
  preferred master = yes
  
  preserve case = no
  
  disable netbios = yes
  
  dns proxy = no
  
  domain master = yes
  
  default case = lower
  
  encrypt passwords = yes
  
  security = user
  
  hosts allow = 172.16.0.0/24 127.0.0.1 # allow your network to access
  
  hosts deny = all
  
  bind interfaces only = yes
  
  interfaces = jme0 # add the correct interface
  
  guest ok = yes
  
  guest only = yes
  
  socket options = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=65536 SO_SNDBUF=65536
  
  strict sync = no
  
  sync always = no
  
  syslog = 1
  
  syslog only = yes
  
  
  [Files]
  
  comment = files
  
  create mask = 644
  
  path = /home/iglesias/network # change to the directory you want
  
  writeable = yes
  
  valid users = iglesias # change to user you want to give access
  
  read only = no
  
  browseable = yes
  
  
  smbpasswd -a iglesias # username

Restarting the service:

/etc/rc.d/samba restart

nano /etc/rc.local

Add in the last line:

/etc/rc.d/samba start

And now we are ready!


# Softwareraid 
26 January 2021

As with RAIDframe, booting and kernel loading are performed from a hard drive partition outside of the RAID array. But unlike RAIDframe, you don't install bootblocks on your non-RAID hard drives individually. Instead, installboot(8) is run once, using the softraid volume, and the first stage bootloader will be installed on the applicable drives, as sys/dev/softraid.c now tracks when installboot is run against a softraid volume, and magic happens:

     # /usr/mdec/installboot -v /boot /usr/mdec/biosboot sd0 

    boot: /boot proto: /usr/mdec/biosboot device: /dev/rsd0c

    sd0: softraid volume with 2 disk(s)

    sd0: installing boot loader on softraid volume

    /boot is 3 blocks x 16384 bytes

    wd0d: installing boot blocks on /dev/rwd0c, part offset 209744

    master boot record (MBR) at sector 0

    partition 3: type 0xA6 offset 64 size 4193216

    /boot will be written at sector 64

    wd1d: installing boot blocks on /dev/rwd1c, part offset 209744

    master boot record (MBR) at sector 0

    partition 3: type 0xA6 offset 64 size 4193216

    /boot will be written at sector 64


For conversion to softraid from RAIDframe, I used my pre-existing RAID partitions on the hard drives. I backed up the array, booted the RAMDISK kernel, zeroed the first 100 sectors of each RAID partition with dd(1), created the softraid array with bioctl, and restored. The server's non-RAID "a" partitions have kernels in them, but no longer need a copy of the second stage bootloader program.

Bare-metal installs are similar. Start by booting bsd.rd, and then prepare your drives with two partitions. A small "a" partition to hold kernels, and a second partition with fstype RAID for use in the array. Then, create the array, and install onto it. Here is an example with two 2GB disks used in a RAID-1 array, with 100MB "a" partitions to hold kernels:

       Welcome to the OpenBSD/i386 5.0 installation program.

        (I)nstall, (U)pgrade or (S)hell? s

    #cd /dev

    #sh MAKEDEV wd1

    fdisk -iy wd0
        
       Writing MBR at offset 0.

    #fdisk -iy wd1

       Writing MBR at offset 0.

    #disklabel -E wd0

        Label editor (enter '?' for help at any prompt)

        > a a

        offset: [64]

        size: [4193216] 100m

        Rounding to cylinder: 209600

        FS type: [4.2BSD]

        > a d

        offset: [209664]

        size: [3983616]

        FS type: [4.2BSD] raid

        > q

        Write new label?: [y]

    #disklabel wd0 > protofile

    #disklabel -R wd1 protofile

    #bioctl -c 1 -l wd0d,wd1d softraid0

        sd0 at scsibus0 targ 1 lun 0:  SCSI2 0/direct fixed

        sd0: 1944MB, 512 bytes/sector, 3983088 sectors#^D

        erase ^?, werase ^W, kill ^U, intr ^C, status ^T

        Welcome to the OpenBSD/i386 5.0 installation program.
        
        (I)nstall, (U)pgrade or (S)hell? i`
        
Before booting, don't forget to format the two "a" partitions and copy kernels onto them. This can be done before or after you run the installation script. Afterwards might be easier if you did a network install, since the kernels will be local to you now on /mnt/:

    #newfs wd0a

newfs: reduced number of fragments per cylinder group from 13096 to 13040 to enlarge last cylinder group

/dev/rwd0a: 102.3MB in 209600 sectors of 512 bytes

5 cylinder groups of 25.47MB, 1630 blocks, 3328 inodes each

super-block backups (for fsck -b #) at: 32, 52192, 104352, 156512, 208672,

    #newfs wd1a

newfs: reduced number of fragments per cylinder group from 13096 to 13040 to enlarge last cylinder group

 /dev/rwd1a: 102.3MB in 209600 sectors of 512 bytes

 5 cylinder groups of 25.47MB, 1630 blocks, 3328 inodes each super-block backups (for fsck -b #) at:32, 52192, 104352, 156512, 208672,

    #mount /dev/wd0a /mnt2

    #cp /mnt/bsd* /mnt2

    #umount /mnt2

    #mount /dev/wd1a /mnt2

    #cp /mnt/bsd* /mnt2

    #umount /mnt2

  
Reboot, and you're running off a softraid(4) root file system. 
  
  
  
  

Partitioning and File System Considerations
===========================================

After volumes are created and mapped to Swift nodes, they need to be
partitioned and have a file system created on them. For each LUN that
was created on the E-Series storage array create a single, new primary
partition that utilizes the entire capacity available on the LUN.

NetApp recommends the use of ``dm-multipath`` to provide support for
redundant paths between an object storage node and the E-Series storage
controller. For details on how to configure ``dm-multipath``, refer to
the NetApp E-Series Storage Systems Failover Drivers Guide, located at
https://library.netapp.com/ecm/ecm_get_file/ECMP1394845.

Partitioning with Multipath
---------------------------

Assuming that three volumes were created from the disk pool, and if
multipath is enabled, you should see a total of 6 mapped devices, as in
the following example:

::

    root@stlrx300s7-102:~# ls -l /dev/mapper
    total 0
    lrwxrwxrwx 1 root root       7 May  5 15:20 360080e50003220a80000017353450e3f -> ../dm-0
    lrwxrwxrwx 1 root root       7 May  5 15:20 360080e50003222300000019153450e18 -> ../dm-1
    lrwxrwxrwx 1 root root       7 May  5 15:20 360080e50003222300000019053450e18 -> ../dm-2
    crw------- 1 root root 10, 236 May  5 15:20 control

Now we use the ``parted`` command to partition the mapped devices:

::

    root@stlrx300s7-102:/dev/mapper# luns=`ls|grep -v control`
    root@stlrx300s7-102:/dev/mapper# for i in $luns
    > do
    > parted -a optimal -s --  /dev/mapper/$i mklabel gpt mkpart primary xfs 0% 100%
    > done
    root@stlrx300s7-102:/dev/mapper# ls -l /dev/dm-
    dm-0  dm-1  dm-2  dm-3  dm-4  dm-5  dm-6  dm-7  dm-8
    root@stlrx300s7-102:/dev/mapper# ls -l /dev/mapper
    total 0
    lrwxrwxrwx 1 root root       7 May  5 15:29 360080e50003220a80000017353450e3f -> ../dm-0
    lrwxrwxrwx 1 root root       7 May  5 15:29 360080e50003220a80000017353450e3f1 -> ../dm-3
    lrwxrwxrwx 1 root root       7 May  5 15:29 360080e50003220a80000017353450e3f-part1 -> ../dm-4
    lrwxrwxrwx 1 root root       7 May  5 15:29 360080e50003222300000019053450e18 -> ../dm-2
    lrwxrwxrwx 1 root root       7 May  5 15:29 360080e50003222300000019053450e18p1 -> ../dm-5
    lrwxrwxrwx 1 root root       7 May  5 15:29 360080e50003222300000019053450e18-part1 -> ../dm-6
    lrwxrwxrwx 1 root root       7 May  5 15:29 360080e50003222300000019153450e18 -> ../dm-1
    lrwxrwxrwx 1 root root       7 May  5 15:29 360080e50003222300000019153450e18p1 -> ../dm-7
    lrwxrwxrwx 1 root root       7 May  5 15:29 360080e50003222300000019153450e18-part1 -> ../dm-8
    crw------- 1 root root 10, 236 May  5 15:20 control

Swift currently requires that the underlying filesystem have support for
extended attributes of the file system. While this requirement may be
removed in a future release of Swift, as of the Havana release the
recommended filesystem type is XFS.

Internal volumes created in a DDP layout resemble a traditional RAID 6
volume with the following parameters:

-  Configuration: 8+2 RAID 6

-  Segment Size: 128K

-  Stripe Width: 1MB

These parameters can be leveraged to configure the file system for
optimal performance with the LUN. When a file system is created on a
logical volume device, ``mkfs.xfs`` automatically queries the logical
volume to determine appropriate stripe unit and stripe width values,
unless values are passed at the time of filesystem creation; for
example:

::

    # ls -l /dev/mapper/|grep part|awk '{print $9}'
    360080e50003220a80000017353450e3f-part1
    360080e50003222300000019053450e18-part1
    360080e50003222300000019153450e18-part1
    # parts=`ls -l /dev/mapper/|grep part|awk '{print $9}'`
    # for i in $parts
    > do
    > mkfs.xfs -d su=131072,sw=8 -i size=1024 $i
    > done

.. tip::

   You can verify that the partition was successfully created and is
   properly aligned by using the ``parted`` command:

   ::

       # parted /dev/mapper/360a9800043346852563444717a513571 align-check optimal 1
       1 aligned

You can verify that the underlying filesystem has the correct values for
stripe unit and stripe width by using the ``xfs_info`` command::

    mount -t xfs -o nobarrier,noatime,nodiratime,inode64 /dev/mapper/360080e50003220a80000017353450e3f-part1 /disk1
    # xfs_info /disk1
    meta-data=/dev/mapper/360080e50003220a80000017353450e3f-part1 isize=1024   agcount=4, agsize=83623808 blks
             =                       sectsz=512   attr=2
    data     =                       bsize=4096   blocks=334495232, imaxpct=5
             =                       sunit=32     swidth=256 blks
    naming   =version 2              bsize=4096   ascii-ci=0
    log      =internal               bsize=4096   blocks=163328, version=2
             =                       sectsz=512   sunit=32 blks, lazy-count=1
    realtime =none                   extsz=4096   blocks=0, rtextents=0

``sunit`` and ``swidth`` are shown in ``bsize`` (block size) units in
the ``xfs_info`` command output.

::

    stripe unit= 32 sunits * 4096 bsize (block size)= 131072 bytes = 128K
    stripe width= 256 blocks * 4096 bsize = 1M = 128K * 8 drives

The sysctl ``fs.xfs.rotorstep`` can be used to change how many files are
put into an XFS allocation group. Increasing the default number from 1
to 255 reduces seeks to multiple allocation groups. NetApp has observed
improved performance in some cases by increasing this number. You can
put the following line in ``/etc/sysctl.conf`` to ensure this change is
affected on each boot of the system::

    fs.xfs.rotorstep = 255

When mounting the XFS filesystem that resides on the LUNs offered from
the E-Series storage, be sure to use the following mount options::

    mount –t xfs –o “nobarrier,noatime,nodiratime,inode64” \
    /dev/mapper/nodeX /srv/node/sdb1

.. warning::

   The mount points for the account, container, and object storage are
   not managed by Swift; therefore, you must use the standard Linux
   mechanisms (e.g. ``/etc/fstab``) to ensure that the mount points
   exist and are mounted before Swift starts.

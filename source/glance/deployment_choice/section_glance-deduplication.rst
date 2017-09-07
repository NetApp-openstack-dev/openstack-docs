Deployment Choices: Deduplication
=================================

There is a high probability of duplicate blocks in a repository
of virtual machine images.  

.. tip::
   NetApp highly recommends using ONTAP NFS as a Glance backing store and 
   enabling deduplication on the FlexVol volume(s) where the Glance images are
   stored.

The following commands allow you to enable deduplication
as well as check the status of deduplication

::

    ::> volume efficiency on -vserver demo-vserver -volume vol2
    Efficiency for volume "vol2" of Vserver "demo-vserver" is enabled.
    Already existing data could be processed by running
    "volume efficiency start -vserver demo-vserver -volume vol2
    -scan-old-data true".

::

    ::> volume efficiency show -vserver demo-vserver -volume vol2
    Vserver Name: demo-vserver
    Volume Name: vol2
    Volume Path: /vol/vol2
    State: Disabled
    Status: Idle
    Progress: Idle for 00:19:53
    Type: Regular
    Schedule: sun-sat@0
    Efficiency Policy Name: -
    Blocks Skipped Sharing: 0
    Last Operation State: Success
    Last Success Operation Begin:
    Thu Nov 21 14:19:23 UTC 2013
    Last Success Operation End:
    Thu Nov 21 14:20:40 UTC 2013
    Last Operation Begin:
    Thu Nov 21 14:19:23 UTC 2013
    Last Operation End:
    Thu Nov 21 14:20:40 UTC 2013
    Last Operation Size: 0B
    Last Operation Error: -
    Changelog Usage: 0%
    Logical Data Size: 224KB
    Logical Data Limit: 640TB
    Logical Data Percent: 0%
    Queued Job: -
    Stale Fingerprint Percentage: 0
    Compression: false
    Inline Compression: false
    Incompressible Data Detection: false
    Constituent Volume: false
    Compression Quick Check File Size: 524288000


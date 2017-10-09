Theory of Operation: Over-Subscription and Thin-Provisioning
============================================================

Overview
--------

With a thick-provisioned Cinder Volume, an amount of space is
reserved from the backend storage system equal to the size of the
requested volume. Because users typically do not actually consume all
the space in the Cinder Volume, overall storage efficiency is reduced.

With a thin-provisioned Cinder Volume, space is only carved from the
backend storage system as required for actual usage.

Thin-provisioning allows for capacity over-subscription. In other words,
more storage space may be allocated than is available on the storage
controller. 

As example, in a 1TB storage pool, if four 250GB thick-provisioned volumes
are created, it would be necessary to add more storage capacity to the
pool in order to create another Cinder Volume even if the Cinder Volumes
were to remain empty.

::
    Storage Pool: Thick provisioned
    Storage Pool capacity = 1TB
    Cinder Volume One:   250GB allocated
    Cinder Volume Two:   250GB allocated
    Cinder Volume Three: 250GB allocated
    Cinder Volume Four:  250GB allocated
    Storage Pool space consumed = 1TB

Thin-provisioning with over-subscription allows flexibility in capacity
planning and reduces the liklihood of wasted storage capacity.

::
    Storage Pool: Thin provisioned
    Storage Pool capacity = 1TB
    Cinder Volume One:  250GB allocated
    Cinder Volume Two:  250GB allocated
    Cinder Volume Three 250GB allocated
    Cinder Volume Four: 250GB allocated
    Cinder Volume Five: 250GB allocated
    Storage Pool space consumed = ~0GB

.. note::

   Thin provisioning helps maximize storage utilization. However, if
   aggregates are over committed through thin provisioning, usage must
   be monitored, and capacity must be increased as usage nears
   predefined thresholds.

All NetApp drivers conform to the standard
Cinder scheduler-based over-subscription framework
in which the ``max_over_subscription_ratio`` and ``reserved_percentage``
configuration options are used to control the degree of
over-subscription allowed in the relevant storage pool. Note that the
Cinder scheduler only allows over-subscription of a storage pool if the
pool reports the ``thin_provisioning_support`` capability, as described
for each type of NetApp platform below.

Details
-------

Refer to the following snippet in exploring further:

::

    $  cinder get-pools --detail
    +-------------------------------+--------+
    | Property                      | Value  |                                                                                       |
    +-------------------------------+--------+
    ....
    | free_capacity_gb              | 2348.93|
    | max_over_subscription_ratio   | 4.0    |
    | reserved_percentage           | 10     |
    | total_capacity_gb             | 10240.0|
    ....
    +-------------------------------+--------

The attribute ``max_over_subscription_ratio`` controls how much
beyond the reported storage pool capacity may be allocated for
additional Cinder Volumes. 

The attribute ``reserved_percentage`` dictates how much space
is to be discounted from the total_capacity before performing
the maximum_over_subscription calculations. Instead of
considering 10,240GB, consider 9,216GB as the total capacity.

In the example above, the storage pool has a capacity of 10240.0GB.

::

      reserved_percentage   = 10
      max_over_subscription_ratio   =  4.0
      total_capacity_gb   = 10,240GB

The following derives the maximum amount of space that may be
allocated to Cinder Volumes.

::

    ( max_over_subscription_ratio * ( total_capacity_gb - ( total_capacity_gb * ( reserved_percentage / 100  ))))
    ( 4.0 * ( 10240.0 - ( 10240.0 * (10 / 100 )))) = 36,864 GB

Every sixty seconds, the total and free capacity is reported
to the Cinder Scheduler. Between the sixty second updates,
the Cinder Scheduler assumes a pessimistic view of free space.
The allocated capacity of each newly created Cinder Volume
is subtracted from the free space value returned previously
by the Cinder Volume Controller. 

At the time of Cinder Volume creation, the requested Cinder Volume
size must be less than or equal to the amount free space known by the
Cinder scheduler.

The above snippet reports the following free space at the reporting interval:

::

    free_capacity_gb =  2,348.93GB

Consider what happens in the following Cinder Volume creation scenario
where four thin volume creation requests come in back to back within the
reporting interval:

::

   request 1: 2000GB (success: free space goes from 2348GB to 348GB)
   request 2: 200GB  (success: free space drops from 348GB to 148GB)
   request 3: 250GB  (failure: insufficient free space)
   Space Update Occurs
   request 4: 250GB  (success: free space goes from 2348GB to 2098GB)



Data ONTAP Thin Provisioning
----------------------------

The following ``cinder.conf`` configuration settings control thin
provisioning with ONTAP backends.
``nfs_sparsed_volumes``: This setting controls whether 
Cinder Volume backed by NFS backends are sparsely or thickly provisioned.
By default, the options is ``True`` and the volumes are
thinly provisioned.

``netapp_lun_space_reservation``: This setting controls whether
space is initially reserved within the pool for LUNS provisioned by
Cinder when using the iSCSI or FC as the ``storage protocol``.
By default, the options is ``Enabled`` and LUNS are thickly
provisioned.

Thin provisioning is ``True`` in the following scenarios 

::

    NFS Backend
    +==================================================+============+
    | Config Option: nfs_sparsed_volumes               |   True     |
    +--------------------------------------------------+------------+
    | ONTAP Volume Setting: netapp_thin_provisioned    |   True     |
    +--------------------------------------------------+------------+
    | Config Option: max_over_subscription_ratio       |    > 1.0   |
    +--------------------------------------------------+------------+

::

    iSCSI or FCP Backend
    +==================================================+===============+
    | Config Option: netapp_lun_space_reservation      |   disabled    |
    +--------------------------------------------------+---------------+
    | ONTAP Volume Setting: netapp_thin_provisioned    |   True        |
    +--------------------------------------------------+---------------+
    | Config Option: max_over_subscription_ratio       |    > 1.0      |
    +--------------------------------------------------+---------------+


E-Series Thin Provisioning
--------------------------

E-Series thin-provisioned volumes may only be created on Dynamic Disk
Pools (DDP). They have 2 different capacities that are relevant: virtual
capacity, and physical capacity. Virtual capacity is the capacity that
is reported by the volume, while physical (repository), capacity is the
actual storage capacity of the pool being utilized by the volume.
Physical capacity must be defined/increased in 4GB increments. Thin
volumes have two different growth options for physical capacity:
automatic and manual. Automatically expanding thin volumes will increase
in capacity in 4GB increments, as needed. A thin volume configured as
manually expanding must be manually expanded using the appropriate
storage management software.

With E-series, thin-provisioned volumes and thick-provisioned volumes
may be created in the same storage pool, so the
*thin-provisioning-support* and *thick-provisioning-support* may both be
reported to the scheduler for the same storage pool.

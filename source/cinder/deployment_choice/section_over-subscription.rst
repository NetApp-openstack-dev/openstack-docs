Deployment Choices: Over-Subscription and Thin-Provisioning
===========================================================

When a thick-provisioned Cinder volume is created, an amount of space is
reserved from the backend storage system equal to the size of the
requested volume. Because users typically do not actually consume all
the space in the Cinder volume, overall storage efficiency is reduced.
With thin-provisioned Cinder volumes, on the other hand, space is only
carved from the backend storage system as required for actual usage. A
thin-provisioned Cinder volume can grow up to its nominal size, but for
space-accounting only the actual physically used space counts.

Thin-provisioning allows for over-subscription because you can present
more storage space to the hosts connecting to the storage controller
than is actually currently available on the storage controller. As an
example, in a 1TB storage pool, if four 250GB thick-provisioned volumes
are created, it would be necessary to add more storage capacity to the
pool in order to create another 250GB volume, even if all volumes are at
less than 25% utilization. With thin-provisioning, it is possible to
allocate a new volume without exhausting the physical capacity of the
storage pool, as only the utilized storage capacity of the volumes
impacts the available capacity of the pool.

Thin-provisioning with over-subscription allows flexibility in capacity
planning and reduces waste of storage capacity. The storage
administrator is able to simply grow storage pools as needed to fill
capacity requirements.

All NetApp drivers conform to the standard
Cinder scheduler-based over-subscription framework as described
`here <http://docs.openstack.org/admin-guide-cloud/blockstorage_over_subscription.html>`__,
in which the ``max_over_subscription_ratio`` and ``reserved_percentage``
configuration options are used to control the degree of
over-subscription allowed in the relevant storage pool. Note that the
Cinder scheduler only allows over-subscription of a storage pool if the
pool reports the *thin-provisioning-support* capability, as described
for each type of NetApp platform below.

The default ``max_over_subscription_ratio`` for all drivers is 20 and
the default ``reserved_percentage`` is 0. With these values and
*thin-provisioning-support* capability on (see below), if there is 5TB
of actual free space currently available in the backing store for a
Cinder pool, then up to 1,000 Cinder volumes of 100GB capacity may be
provisioned before getting a failure, assuming actual physical space
used averages 5% of nominal capacity.

Data ONTAP Thin Provisioning
----------------------------

In Data ONTAP multiple forms of thin-provisioning are possible. By
default, the ``nfs_sparsed_volumes`` configuration option is True, so
that files that back Cinder volumes with our NFS drivers are sparsely
provisioned, occupying essentially no space when they are created, and
growing as data is actually written into the file. With block drivers,
on the other hand, the default ``netapp_lun_space_reservation``
configuration option is 'enabled' and the corresponding behavior is to
reserve space for the entire LUN backing a cinder volume. For
thick-provisioned Cinder volumes with NetApp drivers, set
``nfs_sparsed_volumes`` to False. For thin-provisioned Cinder volumes
with NetApp block drivers, set ``netapp_lun_space_reservation`` to
'disabled'.

With Data ONTAP, the flexvols that act as storage pools for Cinder
volumes may themselves be thin-provisioned since when these flexvols are
carved from storage aggregates this may be done without space
guarantees, i.e. the flexvols themselves grow up to their nominal size
as actual physical space is consumed.

Data ONTAP drivers report the *thin-provisioning-support* capability if
either the files or LUNs backing cinder volumes in a storage pool are
thin-provisioned, or if the flexvol backing the storage pool itself is
thin-provisioned. Note that with Data ONTAP drivers, the
*thin-provisioning-support* and *thick-provisioning-support*
capabilities are mutually-exclusive.

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

+-----------------------------------+------------+-----------------------------------------------------------------------------------------------------------------+
| Extra spec                        | Type       | Description                                                                                                     |
+===================================+============+=================================================================================================================+
| ``max_over_subscription_ratio``   | ``20.0``   | A floating point representation of the oversubscription ratio when thin-provisioning is enabled for the pool.   |
+-----------------------------------+------------+-----------------------------------------------------------------------------------------------------------------+
| ``reserved_percentage``           | ``0``      | Percentage of total pool capacity that is reserved, not available for provisioning.                             |
+-----------------------------------+------------+-----------------------------------------------------------------------------------------------------------------+

Table 4.12. NetApp supported configuration options for use with
Over-Subscription

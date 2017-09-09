Overview
========

There are several major advantages of using E-Series storage for Swift
object storage nodes. These include:

-  A dramatic reduction in the storage capacity and physical hardware
   required to facilitate data protection through Swift’s consistent
   hashing ring. The unique characteristics of E-series’ Dynamic Disk
   Pools (DDP) enable the use of a parity protection scheme for data
   protection as an alternative to the default approach involving
   creating 3 or more copies of data. Within a single site, the capacity
   required for object storage along with the parity overhead is an
   approximate 1.3 multiple of the object(s) stored. The default Swift
   behavior involves storing a multiple of 3.

-  The reduction of replicas made possible by the use of DDP has the
   effect of significantly reducing a typically major inhibitor to the
   scale a given Swift cluster can achieve. It has been observed that
   the weight of replication traffic can become a limitation to scale in
   certain use cases.

-  The associated storage capacity efficiency associated with employing
   DDP

-  Reduced Swift node hardware requirements: Internal drive requirements
   for storage nodes are reduced, only operating system storage is
   required. Disk space for Swift object data, and optionally the
   operating system itself, is supplied by the E-Series storage array.

-  Reduced rack space, power, cooling and footprint requirements: Since
   a single storage subsystem provides storage space for multiple Swift
   nodes, smaller and possibly lower power 1U nodes can be used in the
   cluster.

.. _swift_compare:

.. figure:: ../images/swift_compare.png
   :alt: Traditional and E-Series Swift Stack Comparison

   Traditional and E-Series Swift Stack Comparison

On the left of :ref:`swift_compare` is a traditional
Swift cluster, which has a total storage capacity of 240TB. This
requires 10 Swift object storage nodes with 12 2TB drives per system,
which results in approximately 80 TB of effective storage capacity
assuming that Swift uses the default replica count of 3.

Compare this traditional system to the E-Series based cluster, shown on
the right in :ref:`swift_compare`. The E-Series
cluster has identical controller and compute nodes as the traditional
system. In the E-Series cluster the effective 80TB storage capacity of
the traditional system can be obtained by using a single 4U storage
subsystem. The dynamic disk pools (DDP) data reconstruction feature on
E-Series replaces the data replication implementation of Swift. As
mentioned above, this enables a 1U server (with similar memory and CPU
resources as the traditional cluster object nodes) to be used in the
E-Series stack. This results in 42% less rack footprint and
approximately 55% in drive savings (120 drives vs. ~54 drives for an
E-Series based cluster). Additionally the number of attached Swift
object storage nodes attached to the E-Series can be increased if
additional object storage processing capacity is required.

    **Tip**

    Swift may also be deployed in conjunction with the NetApp FAS
    product line, as an iSCSI LUN could be used as a block device to
    provide storage for object, container, or account data. This
    deployment may be used in situations where the scale of an object
    storage deployment is small, or if it is desirable to reuse existing
    FAS systems.

E-Series storage can effectively serve as the storage medium for
OpenStack Object Storage. The data reconstruction capabilities
associated with DDP eliminate the need for data replication within
zones. DDP reconstruction provides RAID-6 data protection against
multiple simultaneous drive failures within the storage subsystem. Data
that resides on multiple failed drives is given top priority during
reconstruction. This data has the highest potential for being lost if a
3rd drive failure occurs is reconstructed first on the remaining optimal
drives in the storage subsystem. After this critical data is
reconstructed all other data on the failed drives is reconstructed. This
prioritized data reconstruction dramatically reduces the possibility of
data loss due to drive failure.

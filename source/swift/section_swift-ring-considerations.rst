Swift Ring Considerations with DDP
==================================

A Swift ring represents a mapping between the names of entities stored
on disk and their physical location. There are separate rings for
accounts, containers, and objects. When other components need to perform
any operation on an object, container, or account, they need to interact
with the appropriate ring to determine its location in the cluster.

The ring maintains this mapping using zones, devices, partitions, and
replicas. Each partition in the ring is replicated 3 times, by default,
across the cluster. The locations for a partition are stored in the
mapping maintained by the ring. The ring is also responsible for
determining which devices are used for handoff in failure scenarios.

The number of replicas for partitions within Swift rings is set at the
time the ring is created. To create the Swift rings for the Swift object
types of account, container, and object, use the ``swift-ring-builder``
CLI command with the ``replicas`` parameter set to 1::

    #swift-ring-builder ring-name create part-power replicas min-hours
    swift-ring-builder account.builder create 10 1 1
    swift-ring-builder container.builder create 10 1 1
    swift-ring-builder object.builder create 10 1 1

.. tip::

   When creating the Swift rings, the number of partitions per ring
   must be calculated. However, the default computation for computing
   the number of partitions (expressed by the exponent of 2) -
   otherwise known as the partition power (``part-power``) - is based
   on the number of disks in a Swift cluster.

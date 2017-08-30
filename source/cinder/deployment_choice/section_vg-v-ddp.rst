Deployment Choices: Volume Groups vs. Dynamic Disk Pools (E-Series)
===================================================================

There are two options for defining storage pools on an E-Series storage
array; each have different performance characteristics and features.

**Volume Groups**


-  Disk count will vary depending on the RAID Level selected.

-  Expand/extend options are expensive and cannot be performed
   concurrently or while a volume on the pool is initializing.

-  Higher raw performance compared to DDP.

-  Adding new disks will require an expensive reconstruction operation.

**Dynamic Disk Pools (DDP)**


-  DDP's require a minimum of 11 disks.

-  RAID reconstruction speed upon drive failures is greatly increased
   over Volume Groups.

-  Thin provisioned volumes are supported.

-  Volume expand/extend operations can run concurrently and while
   volumes are initializing.

-  Additional disks can be added with no additional reconstruction
   overhead.

.. note::

   DDP should be used for provisioning storage if many volume extend
   operations are expected, or if thin provisioning is desired. If raw
   performance is the most important requirement, then properly
   provisioned volume groups are the best choice.

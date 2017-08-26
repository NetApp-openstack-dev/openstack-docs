Construct Mappings between Manila and Clustered Data ONTAP
----------------------------------------------------------

**Manila backends and Clustered Data ONTAP**

Storage Virtual Machines (SVMs, formerly known as Vservers) contain one
or more FlexVol volumes and one or more LIFs through which they serve
data to clients.

SVMs securely isolate the shared virtualized data storage and network,
and each SVM appears as a single dedicated storage virtual machine to
clients. Each SVM has a separate administrator authentication domain and
can be managed independently by its SVM administrator.

In a cluster, SVMs facilitate data access. A cluster must have at least
one SVM to serve data. SVMs use the storage and network resources of the
cluster. However, the shares and LIFs are exclusive to the SVM. Multiple
SVMs can coexist in a single cluster without being bound to any node in
a cluster. However, they are bound to the physical cluster on which they
exist.

**Manila shares and FlexVol volumes**

Data ONTAP FlexVol volumes (commonly referred to as volumes) and
OpenStack File Share Storage shares (commonly referred to as Manila
shares) are semantically analogous. A FlexVol volume is a container of
logical data elements (for example: files, Snapshot copies, clones,
LUNs, et cetera) that is abstracted from physical elements (for example:
individual disks, and RAID groups).

**Manila snapshots versus NetApp Snapshots**

A NetApp Snapshot copy is a point-in-time file system image.
Low-overhead NetApp Snapshot copies are made possible by the unique
features of the WAFL storage technology that is part of Data ONTAP. The
high performance of the NetApp Snapshot makes it highly scalable. A
NetApp Snapshot takes only a few seconds to create — typically less than
one second, regardless of the size of the share or the level of activity
on the NetApp storage system. After a Snapshot copy has been created,
changes to data objects are reflected in updates to the current version
of the objects, as if NetApp Snapshot copies did not exist. Meanwhile,
the NetApp Snapshot version of the data remains completely stable. A
NetApp Snapshot incurs no performance overhead; users can comfortably
store up to 255 NetApp Snapshot copies per FlexVol volume, all of which
are accessible as read-only and online versions of the data.

.. important::

   Since NetApp Snapshots are taken at the FlexVol level, they can and
   are directly leveraged within an Manila context, as a user of Manila
   requests a snapshot be taken of a particular Manila share.

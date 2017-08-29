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

.. _manila_scheduling_and_resource_selection:

**Manila scheduling and resource pool selection**

When Manila shares are created, the Manila scheduler selects a resource
pool from the available storage pools: see ":ref:`manila_storage_pools`"
for an overview.

Beginning with Kilo, each of NetApp's Manila drivers report per-pool
capacity to the scheduler.  When a new share is provisioned, the scheduler
capacity filter eliminates too-small pools from consideration.  Similarly,
the scheduler's capability, availability zone and other filters narrow down
the list of potential backends that may receive a new share based on the share
type and other share characteristics.

The scheduler also has an evaluator filter that evaluates an optional arithmetic
expression to determine whether a pool may contain a new share.  Beginning
with Ocata, the Data ONTAP drivers report per-pool controller utilization values
to the scheduler, along with a "filter function" that prevents new shares from
being created on pools that are overutilized.  Controller utilization is computed
by the drivers as a function of CPU utilization and other internal I/O metrics. 
The default filter function supplied by the Data ONTAP drivers is "capabilities.utilization < 70"
A utilization of 70% utilization is a good starting point beyond which I/O throughput
and latency may be adversely affected by additional Manila shares.  The filter function
may be overridden on a per-backend basis in the Manila configuration file.

Each candidate pool that passes the filters is then considered by the scheduler's
weighers so that the optimum one is chosen for a new share.  As stated above, as
of Kilo, the Manila scheduler has per-pool capacity information, and the scheduler
capacity weigher may be configured to spread new shares among backends uniformly
or to fill one backend before using another.

Beginning with Ocata, the Data ONTAP drivers report per-pool controller utilization values
to the scheduler, along with a "goodness function" that allows the scheduler to prioritize
backends that are less utilized.  Controller utilization is reported as a percentage,
and the goodness function is expected to yield a value between 0 and 100, with 100
representing maximum "goodness".  The default goodness function supplied by the Data ONTAP
drivers is "100 - capabilities.utilization", and it may be overridden on a per-backend
basis in the Manila configuration file.

.. note::

    The controller utilization values used by the filter and goodness functions are only
    available when cluster-scoped credentials are supplied in the Manila configuration file.

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

Theory of Operation: Mapping NetApp to OpenStack Terminology
=============================================================

Cinder Backends and Storage Virtual Machines
--------------------------------------------

Storage Virtual Machines (SVMs, formerly known as Vservers) contain data
volumes and one or more LIFs through which they serve data to clients.
SVMs can either contain one or more FlexVol volumes.

SVMs securely isolate the shared virtualized data storage and network,
and each SVM appears as a single dedicated storage virtual machine to
clients. Each SVM has a separate administrator authentication domain and
can be managed independently by its SVM administrator.

In a cluster, SVMs facilitate data access. A cluster must have at least
one SVM to serve data. SVMs use the storage and network resources of the
cluster. However, the volumes and LIFs are exclusive to the SVM.
Multiple SVMs can coexist in a single cluster without being bound to any
node in a cluster. However, they are bound to the physical cluster on
which they exist.

.. important::

   When deploying Cinder with ONTAP, NetApp recommends
   that each Cinder backend refer to a single SVM within a cluster
   through the use of the ``netapp_vserver`` configuration option.
   While the driver can operate without the explicit declaration of a
   mapping between a backend and an SVM, a variety of advanced
   functionality (e.g. volume type extra-specs) will be disabled.

Cinder volumes and FlexVol Volumes
----------------------------------

ONTAP FlexVol volumes (commonly referred to as volumes) and
OpenStack Block Storage volumes (commonly referred to as Cinder volumes)
are not semantically analogous. A FlexVol volume is a container of
logical data elements (for example: files, Snapshot copies, clones,
LUNs, etc.) that is abstracted from physical elements (for example:
individual disks, and RAID groups). A Cinder volume is a block device.
Most commonly, these block devices are made available to OpenStack
Compute instances. NetApp’s various driver options for deployment of FAS
as a provider of Cinder storage place Cinder volumes, snapshot copies,
and clones within FlexVol volumes.

.. important::

   The FlexVol volume is an overarching container for one or more
   Cinder volumes.

.. note::

   NetApp's OpenStack Cinder drivers are not supported for use with
   Infinite Volumes, as ONTAP currently only supports FlexClone
   files and FlexClone LUNs with FlexVol volumes.

Cinder volume Representation within a FlexVol Volume
----------------------------------------------------

A Cinder volume has a different representation in ONTAP when stored
in a FlexVol volume, dependent on storage protocol utilized with Cinder:

-  *iSCSI*: When utilizing the iSCSI storage protocol, a Cinder volume
   is stored as an iSCSI LUN.

-  *NFS*: When utilizing the NFS storage protocol, a Cinder volume is a
   file on an NFS export.

-  *Fibre Channel*: When utilizing the Fibre Channel storage protocol, a
   Cinder volume is stored as a Fibre Channel LUN.

.. _cinder-schedule-resource-pool:

Cinder Scheduling and Resource Pool Selection
---------------------------------------------

When Cinder volumes are created, the Cinder scheduler selects a resource
pool from the available storage pools: see
:ref:`storage-pools` for an overview.
:ref:`Table 4.9, “Behavioral Differences in Cinder volume Placement”
<cinder-theory-table-4.9>` details the behavioral changes in NetApp's
Cinder drivers when scheduling the provisioning of new Cinder volumes.

Beginning with Juno, each of NetApp's Cinder drivers report per-pool
capacity to the scheduler. When a new volume is provisioned, the
scheduler capacity filter eliminates too-small pools from consideration.
Similarly, the scheduler's capability, availability zone and other
filters narrow down the list of potential backends that may receive a
new volume based on the volume type and other volume characteristics.

The scheduler also has an evaluator filter that evaluates an optional
arithmetic expression to determine whether a pool may contain a new
volume. Beginning with Mitaka, the ONTAP drivers report per-pool
controller utilization values to the scheduler, along with a "filter
function" that prevents new volumes from being created on pools that are
overutilized. Controller utilization is computed by the drivers as a
function of CPU utilization and other internal I/O metrics. The default
filter function supplied by the ONTAP drivers is
"capabilities.utilization < 70". A utilization of 70% is a good starting
point beyond which I/O throughput and latency may be adversely affected
by additional Cinder volumes. The filter function may be overridden on a
per-backend basis in the Cinder configuration file. See `Configure and
use driver filter and weighing for
scheduler <http://docs.openstack.org/admin-guide/blockstorage-driver-filter-weighing.html>`__
for details about using the evaluator functions in Cinder.

Each candidate pool that passes the filters is then considered by the
scheduler's weighers so that the optimum one is chosen for a new volume.
As of Juno, the Cinder scheduler has per-pool capacity information, and
the scheduler capacity weigher may be configured to spread new volumes
among backends uniformly or to fill one backend before using another.

Beginning with Mitaka, the ONTAP drivers report per-pool controller
utilization values to the scheduler, along with a "goodness function"
that allows the scheduler to prioritize backends that are less utilized.
Controller utilization is reported as a percentage, and the goodness
function is expected to yield a value between 0 and 100, with 100
representing maximum "goodness". The default goodness function supplied
by the ONTAP drivers is "100 - capabilities.utilization", and it
may be overridden on a per-backend basis in the Cinder configuration
file.

.. note::

   The storage controller utilization metrics are reported by the
   Mitaka Cinder drivers for ONTAP 8.2 or higher, operating in
   either Cluster or 7-mode.

Beginning with Newton, additional information such as aggregate name and
aggregate space utilization is reported to the scheduler and may be used
in filter and weigher expressions. For example, to keep from filling an
aggregate completely, a filter expression of
"capabilities.aggregate_used_percent < 80" might be used.

Beginning with Ocata, additional information such as per-pool
consumption of the ONTAP shared block limit is reported to the
scheduler and may be used in filter and weigher expressions.  For
example, to steer new Cinder volumes away from a FlexVol nearing its
shared block limit, a filter expression of
"capabilities.netapp_dedupe_used_percent < 90" might be used.
 
.. _cinder-theory-table-4.9:

+----------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Driver                           | Scheduling Behavior (as of Juno)                                                                                                                                                                                                  | Scheduling Behavior (as of Mitaka)                                                                                                                                                                                    |
+==================================+===================================================================================================================================================================================================================================+=======================================================================================================================================================================================================================+
| ONTAP                            | Each FlexVol volume’s capacity and SSC data is reported separately as a pool to the Cinder scheduler. The Cinder filters and weighers decide which pool a new volume goes into, and the driver honors that request.               | Same as Juno. Also, per-pool storage controller utilization is reported to the scheduler, along with filter and goodness expressions that take controller utilization into account when making placement decisions.   |
+----------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ONTAP operating in 7-mode        | Each FlexVol volume’s capacity is reported separately as a pool to the Cinder scheduler. The Cinder filters and weighers decide which pool a new volume goes into, and the driver honors that request.                            | Same as Juno. Also, per-pool storage controller utilization is reported to the scheduler, along with filter and goodness expressions that take controller utilization into account when making placement decisions.   |
+----------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| E-Series                         | -  Each dynamic disk pool's and volume group’s capacity is reported separately as a pool to the Cinder scheduler. The Cinder filters and weighers decide which pool a new volume goes into, and the driver honors that request.   | Same as Juno.                                                                                                                                                                                                         |
|                                  |                                                                                                                                                                                                                                   |                                                                                                                                                                                                                       |
|                                  | -  E-Series volume groups are supported as of the Liberty release.                                                                                                                                                                |                                                                                                                                                                                                                       |
+----------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Table 4.9. Behavioral Differences in Cinder volume Placement

Cinder Snapshots versus NetApp Snapshots
----------------------------------------

A NetApp Snapshot copy is a point-in-time file system image.
Low-overhead NetApp Snapshot copies are made possible by the unique
features of the WAFL storage virtualization technology that is part of
ONTAP. The high performance of the NetApp Snapshot makes it highly
scalable. A NetApp Snapshot takes only a few seconds to create —
typically less than one second, regardless of the size of the volume or
the level of activity on the NetApp storage system. After a Snapshot
copy has been created, changes to data objects are reflected in updates
to the current version of the objects, as if NetApp Snapshot copies did
not exist. Meanwhile, the NetApp Snapshot version of the data remains
completely stable. A NetApp Snapshot incurs no performance overhead;
users can comfortably store up to 255 NetApp Snapshot copies per FlexVol
volume, all of which are accessible as read-only and online versions of
the data.

Since NetApp Snapshots are taken at the FlexVol level, they can not be
directly leveraged within an OpenStack context, as a user of Cinder
requests a snapshot be taken of a particular Cinder volume (not the
containing FlexVol volume). As a Cinder volume is represented as either
a file on NFS or as a LUN (in the case of iSCSI or Fibre Channel), the
way that Cinder snapshots are created is through use of ONTAP's'
FlexClone technology. By leveraging the FlexClone technology to
facilitate Cinder snapshots, it is possible to create many thousands of
Cinder snapshots for a single Cinder volume.

FlexClone files or FlexClone LUNs and their parent files or LUNs that
are present in the FlexClone volume continue to share blocks the same
way they do in the parent FlexVol volume. In fact, all the FlexClone
entities and their parents share the same underlying physical data
blocks, minimizing physical disk space usage.

E-Series Snapshots
------------------

The Cinder driver can create hardware-based snapshots on E-Series.
E-Series uses copy-on-write snapshots, which can be created within
seconds. Snapshots on E-Series do not require an additional license.

Each volume may support up to 96 snapshots. Snapshots are defined in
groups of 32 and share a common copy-on-write repository for performance
reasons; older snapshots are dependent on the newer snapshots within the
same group. The E-Series backend does not allow Snapshots on E-Series to
be deleted out of order for this reason (only the oldest snapshot in the
group may be deleted and the storage capacity reclaimed). The Cinder
driver will track snapshots that have been removed from Cinder, and will
purge them from the backend automatically once they are no longer
required by the backend.

E-Series snapshots are typically used for relatively brief operations,
such as making a backup. If you require many snapshots or long-lasting
snapshots, consider FAS.

.. important::

   When Cinder is deployed with ONTAP, Cinder snapshots are
   created leveraging the FlexClone feature of ONTAP. As such, a
   license option for FlexClone must be enabled.

CDOT and 7-mode Consistency Groups
----------------------------------

ONTAP currently has "Consistency Group" snapshot operations, but
their semantics are not identical to Cinder CG operations. Cinder CGs
are tenant-defined sets of Cinder-volumes that act together as a unit
for a snapshot. ONTAP currently has no actual "Consistency Group"
object, but only CG snapshot operations. Moreover, these operations act
on ONTAP volumes, flexvols, which are themselves containers of the
backing files or LUNs for Cinder volumes. In effect, so long as there is
room in a Cinder pool to fit a snapshot or a copy of a consistency
group, that operation will be permitted without any further restriction.

E-Series Consistency Groups
---------------------------

E-Series consistency groups share a 1:1 mapping with Cinder consistency
groups. Each consistency group may have up to 32 snapshots defined; up
to 64 independent snapshots may be defined on a volume if a volume is a
part of a consistency group. The create-from-source operation is
implemented using full volume copies, and such an operation based on a
consistency group containing large volumes may take a long time to
complete.

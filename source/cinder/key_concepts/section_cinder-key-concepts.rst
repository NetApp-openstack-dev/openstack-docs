.. _cinder-key-concepts:

Key Concepts
============

Volume
------

A Cinder volume is the fundamental resource unit allocated by the Block
Storage service. It represents an allocation of persistent, readable,
and writable block storage that could be utilized as the root disk for a
compute instance, or as secondary storage that could be attached and/or
detached from a compute instance. The underlying connection between the
consumer of the volume and the Cinder service providing the volume can
be achieved with the iSCSI, NFS, Fibre Channel or NVMe/TCP storage protocols
(dependent on the support of the Cinder driver deployed).

.. warning::

    A Cinder volume is an abstract storage object that may or may not
    directly map to a "volume" concept from the underlying backend
    provider of storage. It is critically important to understand this
    distinction, particularly in context of a Cinder deployment that
    leverages NetApp storage solutions.

Cinder volumes can be identified uniquely through a UUID assigned by the
Cinder service at the time of volume creation. A Cinder volume may also
be optionally referred to by a human-readable name, though this string
is not guaranteed to be unique within a single tenant or deployment of
Cinder.

The actual blocks provisioned in support of a Cinder volume reside on a
single Cinder backend. Starting in the Havana release, a Cinder volume
can be migrated from one storage backend to another within a deployment
of the Cinder service; refer to the section called ":ref:`cinder-cli`"
for an example of volume migration.

The ``cinder manage`` command allows importing existing storage objects
that are not managed by Cinder into new Cinder volumes. The operation
will attempt to locate an object within a specified Cinder backend and
create the necessary metadata within the Cinder database to allow it to
be managed like any other Cinder volume. The operation will also rename
the volume to a name appropriate to the particular Cinder driver in use.
The imported storage object could be a file, LUN, NVMe namespace or a volume
depending on the protocol (iSCSI/FC/NFS/NVMe). This feature is
useful in migration scenarios where virtual machines or other data need
to be managed by Cinder; refer to the section called
":ref:`cinder-manage`" for an example of the ``cinder manage`` command.

The ``cinder unmanage`` command allows Cinder to cease management of a
particular Cinder volume. All data stored in the Cinder database related
to the volume is removed, but the volume's backing file, LUN, or
appropriate storage object is not deleted. This allows the volume to be
transferred to another environment for other use cases; refer to the
section called ":ref:`cinder-unmanage`" for an example of the
``cinder unmanage`` command.

Snapshot
--------

A Cinder snapshot is a point-in-time, read-only copy of a Cinder volume.
Snapshots can be created from an existing Cinder volume that is
operational and either attached to an instance or in a detached state. A
Cinder snapshot can serve as the content source for a new Cinder volume
when the Cinder volume is created with the *create from snapshot* option
specified or can be used to revert a volume to the most recent snapshot
using the *revert to snapshot* feature (as of the Pike release).

Backend
-------

A Cinder backend is the configuration object that represents a single
provider of block storage upon which provisioning requests may be
fulfilled. A Cinder backend communicates with the storage system through
a Cinder driver. Cinder supports multiple backends to be simultaneously
configured and managed (even with the same Cinder driver) as of the
Grizzly release.

.. note::

   A single Cinder backend may be defined in the ``[DEFAULT]`` stanza
   of ``cinder.conf``; however, NetApp recommends that the
   ``enabled_backends`` configuration option be set to a
   comma-separated list of backend names, and each backend name have
   its own configuration stanza with the same name as listed in the
   ``enabled_backends`` option. Refer to the section called
   ":ref:`cinder`" for an example of the use of this option.

Driver
------

A Cinder driver is a particular implementation of a Cinder backend that
maps the abstract APIs and primitives of Cinder to appropriate
constructs within the particular storage solution underpinning the
Cinder backend.

.. caution::

   The use of the term "driver" often creates confusion given common
   understanding of the behavior of “device drivers” in operating
   systems. The term can connote software that provides a data I/O
   path. In the case of Cinder driver implementations, the software
   provides provisioning and other manipulation of storage devices but
   does not lay in the path of data I/O. For this reason, the term
   "driver" is often used interchangeably with the alternative (and
   perhaps more appropriate) term “provider”.

Volume Type
-----------

A Cinder volume type is an abstract collection of criteria used to
characterize Cinder volumes. They are most commonly used to create a
hierarchy of functional capabilities that represent a tiered level of
storage services; for example, a cloud administrator might define a
``premium`` volume type that indicates a greater level of performance
than a ``basic`` volume type, which would represent a best-effort level
of performance.

The collection of criteria is specified as a list of key/value pairs,
which are inspected by the Cinder scheduler when determining which
Cinder backend(s) are able to fulfill a provisioning request. Individual
Cinder drivers (and subsequently Cinder backends) may advertise
arbitrary key/value pairs (also referred to as capabilities) to the
Cinder scheduler, which are then compared against volume type
definitions when determining which backend will fulfill a provisioning
request.

Extra Spec
----------

An extra spec is a key/value pair, expressed in the style of
``key=value``. Extra specs are associated with Cinder volume types, so
that when users request volumes of a particular volume type, the volumes
are created on storage backends that meet the specified criteria.

.. note::

   The list of default capabilities that may be reported by a Cinder
   driver and included in a volume type definition include:

   -  ``volume_backend_name``: The name of the backend as defined in
      ``cinder.conf``

   -  ``vendor_name``: The name of the vendor who has implemented the
      driver (e.g. ``NetApp``)

   -  ``driver_version``: The version of the driver (e.g. ``1.0``)

   -  ``storage_protocol``: The protocol used by the backend to export
      block storage to clients (e.g. ``iSCSI``, ``fc``, ``nvme`` or ``nfs``)

   For a table of NetApp supported extra specs, refer to
   :ref:`Table 4.11, “NetApp supported Extra Specs for use with Cinder volume Types”<table-4.11>`.

.. note::

   NetApp drivers support multi-attachment of volumes for NFS, iSCSI
   and FC protocols from the Rocky release. This enables attaching a
   volume to multiple servers simultaneously and can be configured
   by creating an extra-spec ``multiattach=True`` for the associated
   Cinder volume type.

.. note::

   In-use volume extension is not supported by NetApp drivers.
   Currently, it is not possible to extend the size of a volume that
   is attached to a server and uses a NetApp backend. Extension can
   only be done by detaching the volume from the server.

Quality of Service
------------------

The Cinder Quality of Service (QoS) support for volumes can be enforced
either at the hypervisor or at the storage subsystem (``backend``), or
both.

**SolidFire**

Within the SolidFire platform, each volume may be configured with
minimum, maximum, and burst IOPS values that are strictly
enforced within the system. The minimum IOPS provides
a guarantee for performance, independent of what other
applications on the system are doing. The maximum and burst
values control the allocation of performance and deliver consistent
performance to workloads.

QoS support for the SolidFire drivers includes the ability to set the
following capabilities in the OpenStack Block Storage API
``cinder.api.contrib.qos_specs_manage`` qos specs extension module:

.. _table-4.1:

+-----------------+-------------------------------------------------------------------------------------+
| Option          | Description                                                                         |
+=================+=====================================================================================+
| minIOPS         | The minimum number of IOPS guaranteed for this volume. Default = 100.               |
+-----------------+-------------------------------------------------------------------------------------+
| maxIOPS         | The maximum number of IOPS allowed for this volume. Default = 15,000.               |
+-----------------+-------------------------------------------------------------------------------------+
| burstIOPS       | The maximum number of IOPS allowed over a short period of time. Default = 15,000.   |
+-----------------+-------------------------------------------------------------------------------------+

Table 4.1a. SolidFire QoS Options

.. note::
   The SolidFire driver utilizes volume-types for QoS settings and
   allows dynamic changes to QoS.

**ONTAP**

The NetApp ONTAP Cinder driver currently supports
QoS by backend QoS specs or via netapp:qos_policy_group assignment
using Cinder Extra-Specs. The NetApp Cinder driver accomplishes this by
using NetApp QoS policy groups, introduced with ONTAP
8.2, and applying these policy groups to Cinder volumes.

-  *netapp:qos_policy_group*: A Cinder extra-spec, which references an
   externally provisioned QoS policy group, provides a means to assign a
   Netapp QoS policy group for a set of Cinder volumes. All Cinder
   volumes associated with a single QoS policy group share the
   throughput value restrictions as a group. The ONTAP
   QoS policy group must be created by the storage administrator on the
   backend prior to specifying the netapp:qos_policy_group option in a
   Cinder extra-spec. Whether the policy group is the adaptive type use the
   Cinder extra-spec netapp:qos_policy_group_is_adaptive. Use the
   netapp:qos_policy_group option when a Service Level Objective (SLO) needs to
   be applied to a set of Cinder volumes. For more information on this, see
   :ref:`Table 4.11, “NetApp supported Extra Specs for use with Cinder volume Types”<table-4.11>`.

-  *QoS Spec*: QoS specifications are added as standalone objects that
   can then be associated with Cinder volume types. A Cinder QoS Spec
   will create a new NetApp QoS policy group for each Cinder volume. A
   Cinder QoS spec can specify either non-adaptive
   (:ref:`Table 4.1b<qos-spec>`) or an adaptive
   (:ref:`Table 4.1c<adaptive-qos-spec>`) QoS throughput values. For the first
   method, it can be a maximum, a minimum or both QoS, using bytes per second
   or IOPS. For the adaptive method, it must set the maximum (peak) and the
   minimum (expected) QoS together, and IOPS values are dynamically set
   according to the volume size. When deleting a Cinder volume that has a QoS
   Spec applied, the NetApp QoS policies associated with that Cinder volume
   will not immediately be deleted. The driver marks the QoS policies for
   deletion by the NetApp QoS policy reaping job. The NetApp QoS policy reaping
   job runs every 60 seconds. Refer to NetApp ONTAP documentation for your
   version of ONTAP to determine NetApp QoS policy group limits. Use the QoS
   Spec feature when a SLO needs to be applied to a single Cinder volume.

.. _qos-spec:

+-----------------+---------------------------------------------------------------------------+
| Option          | Description                                                               |
+=================+===========================================================================+
| maxBPS          | The maximum bytes per second allowed.                                     |
+-----------------+---------------------------------------------------------------------------+
| maxBPSperGiB    | The maximum bytes per second allowed per GiB of Cinder volume capacity.   |
+-----------------+---------------------------------------------------------------------------+
| maxIOPS         | The maximum IOPS allowed.                                                 |
+-----------------+---------------------------------------------------------------------------+
| maxIOPSperGiB   | The maximum IOPS allowed per GiB of Cinder volume capacity.               |
+-----------------+---------------------------------------------------------------------------+
| minIOPS         | The minimum IOPS allowed.                                                 |
+-----------------+---------------------------------------------------------------------------+
| minIOPSperGiB   | The minimum bytes per second allowed per GiB of Cinder volume capacity.   |
+-----------------+---------------------------------------------------------------------------+

Table 4.1b. NetApp Non-Adaptive Supported Backend QoS Spec Options.


.. _adaptive-qos-spec:

+------------------------+--------------------------------------------------------------------------------------------------------------------------------------+
| Option                 | Description                                                                                                                          |
+========================+======================================================================================================================================+
| expectedIOPSperGiB     | The minimum expected IOPS per allocated GiB. ONTAP can only guarantee for AFF platforms.                                             |
+------------------------+--------------------------------------------------------------------------------------------------------------------------------------+
| peakIOPSperGiB         | The maximum expected IOPS per allocated GiB.                                                                                         |
+------------------------+--------------------------------------------------------------------------------------------------------------------------------------+
| expectedIOPSAllocation | Specifies either the allocated-size or the used-size which determines the minimum throughput calculation. Default = allocated-space. |
+------------------------+--------------------------------------------------------------------------------------------------------------------------------------+
| peakIOPSAllocation     | Specifies either the allocated-size or the used-size which determines the maximum throughput calculation. Default = allocated-space. |
+------------------------+--------------------------------------------------------------------------------------------------------------------------------------+
| absoluteMinIOPS        | The absolute minimum number of IOPS.                                                                                                 |
+------------------------+--------------------------------------------------------------------------------------------------------------------------------------+
| blockSize              | The application I/O block size. Values: 8K, 16K, 32K, 64K, ANY. Default = 32K.                                                       |
+------------------------+--------------------------------------------------------------------------------------------------------------------------------------+

Table 4.1c. NetApp Adaptive Supported Backend QoS Spec Options.

.. note::
   The per GiB unit of the non-adaptive method calculates the QoS throughput
   based on the first allocated volume size, it does not change with the extend
   volume operation. While for the adaptive method, the QoS throughput is
   affected by changes on the volume size (or used size).

.. note::
   You can use the ``absoluteMinIOPS`` field with very small storage objects.
   It overrides both ``peakIOPSperGiB`` and/or ``expectedIOPSperGiB`` when
   ``absoluteMinIOPS`` is greater than the calculated ``expectedIOPSperGiB``.
   For example, if you set ``expectedIOPSperGiB`` to 1,000 IOPS/GiB, and the
   volume size is less than 1 GB, the calculated ``expectedIOPSperGiB`` will be
   a fractional IOP. The calculated ``peakIOPSperGiB`` will be an even smaller
   fraction. You can avoid this by setting ``absoluteMinIOPS`` to a realistic
   value.

.. important::
   The non-adaptive QoS minimum is only supported by storage ONTAP All Flash
   FAS (AFF) with version equal or greater than 9.3 for NFS and 9.2 for iSCSI
   and FCP. Select Premium with SSD and C190 storages are also supported
   starting on ONTAP 9.6. The driver reports this support by the capability
   ``netapp_qos_min_support``.

.. important::
   The adaptive QoS specs can only be used with ONTAP version equal to
   or greater than 9.4, excepting the ``expectedIOPSAllocation`` and
   ``blockSize`` specs which require at least 9.5.

.. warning::
   While SolidFire supports volume retyping, ONTAP does not.

.. warning::
   Cinder NVMe/TCP ONTAP driver does not support QoS.

.. _storage-pools:

Storage Pools
-------------

With the Juno release of OpenStack, Cinder has introduced the concept of
"storage pools". The backend storage may present one or more logical
storage resource pools from which Cinder will select as a storage
location when provisioning volumes. In releases prior to Juno, NetApp's
Cinder drivers contained some logic that determined which FlexVol
volume, volume group, or DDP a Cinder volume would be placed into; with
the introduction of pools, all scheduling logic is performed completely
within the Cinder scheduler.

For NetApp's Cinder drivers, a Cinder pool is a single container. The
container that is mapped to a Cinder pool is dependent on the storage
protocol used:

-  *iSCSI, NVMe/TCP and Fibre Channel*: a Cinder pool is created for every FlexVol
   volume within the SVM specified by the configuration option
   ``netapp_vserver``, or for ONTAP, all
   FlexVol volumes within the system unless limited by the configuration
   option ``netapp_pool_name_search_pattern``.

-  *NFS*: a Cinder pool is created for each junction path from FlexVol
   or FlexGroup volumes that are listed in the configuration option
   ``nfs_shares_config``.


For additional information, refer to
:ref:`cinder-schedule-resource-pool`.

Generic Volume Groups
---------------------

With the Newton release of OpenStack, NetApp supports Generic Volume
Groups when ONTAP iSCSI/Fibre Channel and ONTAP NFS
drivers. For SolidFire, Generic Volume Groups support is provided since
the Pike release. Existing consistency group operations will be migrated
to use generic volume group operations in future releases. The existing
Consistency Group construct cannot be extended easily to serve
purposes such as consistent group snapshots across multiple
volumes. A generic volume group makes it possible to group volumes used
in the same application and these volumes do not have to support
consistent group snapshot. It provides a means of managing volumes and
grouping them based on a common factor. Additional information about
volume groups and the proposed migration can be found at
`generic-volume-groups <https://docs.openstack.org/cinder/latest/admin/blockstorage-groups.html>`__

.. note::
   Only Block Storage V3 API supports groups. The minimum version for
   group operations supported by the ONTAP drivers is 3.14. The API
   version can be specified with the following CLI flag
   ``--os-volume-api-version 3.14``

Consistency Groups
------------------

With the Mitaka release of OpenStack, NetApp supports Cinder Consistency
Groups when using ONTAP iSCSI/Fibre
Channel drivers. With the Newton release of OpenStack, NetApp supports
Cinder Consistency Groups when using ONTAP NFS
drivers. Consistency group support allows snapshots of multiple volumes
in the same consistency group to be taken at the same point-in-time to
ensure data consistency. To illustrate the usefulness of consistency
groups, consider a bank account database where a transaction log is
written to Cinder volume V1 and the account table itself is written to
Cinder volume V2. Suppose that $100 is to be transferred from account A
to account B via the following sequence of writes:

1. Log start of transaction.

2. Log remove $100 from account A.

3. Log add $100 to account B.

4. Log commit transaction.

5. Update table A to reflect -$100.

6. Update table B to reflect +$100.

Writes 1-4 go to Cinder volume V1 whereas writes 5-6 go to Cinder volume
V2. To see that we need to keep write order fidelity in both snapshots
of V1 and V2, suppose a snapshot is in progress during writes 1-6, and
suppose that the snapshot completes at a point where writes 1-3 and 5
have completed, but not 4 and 6. Because write 4 (log of commit
transaction) did not complete, the transaction will be discarded. But
write 5 has completed anyways, so a restore from snapshot of the
secondary will result in a corrupt account database, one where account A
has been debited $100 without account B getting the corresponding
credit.

Before using consistency groups, you must change policies for the
consistency group APIs in the ``/etc/cinder/policy.json`` file. By
default, the consistency group APIs are disabled. Enable them before
running consistency group operations. Here are existing policy entries
for consistency groups::

    "consistencygroup:create": "group:nobody",
    "consistencygroup:delete": "group:nobody",
    "consistencygroup:update": "group:nobody",
    "consistencygroup:get": "group:nobody",
    "consistencygroup:get_all": "group:nobody",
    "consistencygroup:create_cgsnapshot" : "group:nobody",
    "consistencygroup:delete_cgsnapshot": "group:nobody",
    "consistencygroup:get_cgsnapshot": "group:nobody",
    "consistencygroup:get_all_cgsnapshots": "group:nobody",

Remove ``group:nobody`` to enable these APIs::

    "consistencygroup:create": "",
    "consistencygroup:delete": "",
    "consistencygroup:update": "",
    "consistencygroup:get": "",
    "consistencygroup:get_all": "",
    "consistencygroup:create_cgsnapshot" : "",
    "consistencygroup:delete_cgsnapshot": "",
    "consistencygroup:get_cgsnapshot": "",
    "consistencygroup:get_all_cgsnapshots": "",

Remember to restart the Block Storage API service after changing
policies.

The NetApp Driver creates consistency group LUN snapshots thick
provisioned.  This can be changed on the backend after the snap
is taken with no effect to Cinder.

.. note::
   Consistency group operations support has been deprecated in
   Block Storage V3 API. Only Block Storage V2 API supports consistency
   groups. Future releases will involve a migration of existing
   consistency group operations to use generic volume group operations.

.. caution::
   Consistency group operations are not supported when the storage pool
   is a FlexGroup volume.

Backup and Restore
------------------

Cinder offers OpenStack tenants self-service backup and restore
operations for their Cinder volumes. These operations are performed on
individual volumes. A Cinder backup operation creates a point-in-time,
read-only set of data and metadata that can be used to restore the
contents of a single Cinder volume either to a new Cinder volume (the
default) or to an existing Cinder volume. In contrast to snapshots,
backups are stored in a dedicated repository, independent of the storage
pool containing the original volume or the storage backend providing its
block storage.

Cinder backup repositories may be implemented either using an object
store (such as Swift) or by using an NFS shared filesystem. The Cinder
backup service uses a single repository, irrespective of the backends
used to provide storage pools for the volumes themselves. For example, a
FlexVol volume exported from an ONTAP storage system using NFS can
serve as a backup repository for multi-backend, heterogeneous Cinder
deployments.

Tenant-controlled, per-volume backup service is complementary to, but
not a replacement for, administrative backups of the storage pools
themselves that hold Cinder volumes. See
http://netapp.github.io/openstack/2015/03/12/cinder-backup-restore/ for
a valuable approach to administrative backups when ONTAP
storage pools are used to host Cinder volumes.

Disaster Recovery
-----------------

In the Newton release of OpenStack, NetApp's Cinder driver for
ONTAP (for FC, NFS, iSCSI) was updated to match Cinder's v2.1 spec
for replication. This makes it possible to replicate an entire backend,
and allow all replicated volumes across different pools to fail over
together. Intended to be a disaster recovery mechanism, it provides a
way to configure one or more disaster recovery partner storage systems
for your Cinder backend. For more details on the configuration and
failover process, refer to `Cinder Replication with
NetApp <http://netapp.io/2016/10/14/cinder-replication-netapp-perfect-cheesecake-recipe/>`__

.. caution::
   The NFS driver with FlexGroup pool can only automatically create the
   disaster recovery partner if the source FlexGroup volume was created using
   the default number of constituents. For custom source FlexGroup pool, the
   administrator has to create the replica FlexGroup volume manually with
   the same custom number of constituents as the source.

Revert to Snapshot
------------------

As of Pike release, Cinder supports revert to snapshot feature. This feature
can be used to overwrite the current state and data of a volume to the most
recent snapshot taken. The volume can not be reverted if it was extended after
taking the snapshot.

An optimized implementation of the revert to snapshot operation is used for
the SolidFire driver. For ONTAP backends, the feature works by using a
generic implementation that works for NFS/iSCSI/FC/NVMe driver modes. From Xena
release, ONTAP NFS, iSCSI and FC drivers are also performed using the storage
with a safer and faster approach.

.. caution::
   Revert to snapshot is not supported when the storage pool
   is a FlexGroup volume.

Storage Assisted Migration
--------------------------

Starting from Xena release, Cinder supports storage assisted migration feature.
This feature can be used to migrate ONTAP NFS/iSCSI/FC drivers within the same
cluster. It can be non-disruptive within a same SVM and disruptive in different
SVMs. On NFS drivers is always disruptive. List of possible scenarios:

.. note::
   Storage Assisted Migration has a time limit to happen. The time is defined
   by ``netapp_migrate_volume_timeout`` driver option. The default value is
   3600 seconds. When the timeout is reached:

   - on disruptive operations, the migration is canceled, the volume goes back
     to original state and the copy on target is deleted.

   - on non-disruptive operations, there is no way of stopping the migration,
     the volume status is set as ```maintenance``. Then the user must watch
     over the migration status and when it succeed, reset the volume state to
     the status before migration using:
     ``cinder reset-state --type volume --state <state> <name|id>`` - must know
     the volume status before migration.

1. Within a Storage Virtual Machine (SVM). This operation is non-disruptive on
   iSCSI and FC drivers. NFS drivers requires the volume to be in `available`
   status.

2. Between SVMs at same cluster. This operation is disruptive in all cases and
   requires the volume to be in `available` status.

3. Between two different clusters is not supported for storage assisted, driver
   will automatically fallback to host assisted migration.

.. note::
   Storage Assisted Migration between backends/stanza requires the cluster
   admin account. Using SVM scoped account, it will fallback to host assisted.

.. caution::
   Storage Assisted Migration is not supported when the storage pool
   is a FlexGroup volume.

Active/Active high availability mode support
--------------------------------------------

Starting from Bobcat release (2023.2), Cinder supports active/active high availability mode feature for NetApp NFS protocol based backends. This feature can be used to failover ONTAP NFS drivers within or across ONTAP clusters. It means, if you have a backend exposed via NFS protocol to cinder, all the cinder volumes reside inside this backend can be automatically failed over to replication targets in OpenStack cluster when the host is down. For Cinder Active/Active support, NetApp uses the replication functionality built over in the previous releases to fail over. 

.. note::
   The support is present only for NetApp NFS driver, and not for iSCSI and FCP drivers. 

1. When you look for Active/Active support, it is important to configure Replication target, and it should be configured properly for the backend resides in primary host. User can use the following options in cinder.conf to configure that:  

``replication_device = backend_id:target_cmodeNfs``

``netapp_replication_aggregate_map = backend_id:target_cmodeNfs,source_aggr_1:destination_aggr_1,source_aggr_2:destination_aggr_2``


2. For replications, if the backend is different between primary and secondary, users should configure relevant vserver & cluster peering properly. This is needed to handle snapmirror relationship operations between source and destination.   

.. note::
   You can refer to this article to know how to configure replication targets for NetApp volumes 
   https://netapp.io/2016/10/14/cinder-replication-netapp-perfect-cheesecake-recipe

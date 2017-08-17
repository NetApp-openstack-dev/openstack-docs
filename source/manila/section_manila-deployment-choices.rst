Theory of Operation & Deployment Choices
========================================

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

Deployment Choice: Utilizing Share Servers
------------------------------------------

Manila offers the capability for shares to be accessible through
tenant-defined networks (defined within Neutron). This is achieved by
defining a share network object, which provides the relationship to the
Neutron network and subnet from which an IP address should be allocated,
as well as configured on the backend storage (along with the appropriate
segmentation approach (e.g. VLAN, VXLAN, GRE, etc).

Offering this capability to end users places certain requirements on
storage platforms that are integrated with Manila to be able to
dynamically configure themselves. Share servers are an object defined by
Manila that manages the relationship between share networks and shares.
In the case of the reference driver implementation, a share server
corresponds to an actual Nova instance that provides the file system
service, with raw capacity provided through attached Cinder block
storage volumes. In the case of the Manila driver for NetApp clustered
Data ONTAP, a share server corresponds to a storage virtual machine
(SVM), also referred to as a Vserver.

.. note::

   One share server is created by Manila for each share network that
   has shares associated with it.

.. important::

   When deploying Manila with NetApp clustered Data ONTAP without share
   server management, NetApp requires that each Manila backend refer to
   a single SVM within a cluster through the use of the
   ``netapp_vserver`` configuration option.

**With Share Servers**

Within the clustered Data ONTAP driver with share server support, a
storage virtual machine will be created for each share server. While
this can provide some advantages with regards to secure multitenancy and
integration with a variety of network services within OpenStack, care
must be taken to ensure that the scale limits are enforced through
Manila quotas. It is a documented best practice to not exceed 200 SVMs
running on a single cluster at any given time to ensure consistent
performance and responsive management operations.

**Without Share Servers**

With the clustered Data ONTAP driver without share server support, data
LIFs are reused and the provisioning of new Manila shares (i.e. FlexVol
volumes) is limited to the scope of a single SVM.

Using Manila Share Types to Create a Storage Service Catalog
------------------------------------------------------------

The Storage Service Catalog (SSC) is a concept that describes a set of
capabilities that enables efficient, repeated, and consistent use and
management of storage resources by the definition of policy-based
services and the mapping of those services to the backend storage
technology. It is meant to abstract away the actual technical
implementations of the features at a storage backend into a set of
simplified configuration options.

The storage features are organized or combined into groups based on the
customer needs to achieve a particular scenario or use case. Based on
the catalog of the storage features, intelligent provisioning decisions
are made by infrastructure or software enabling the storage service
catalog. In OpenStack, this is achieved together by the Manila filter
scheduler and the NetApp driver by making use of share type extra-specs
support together with the filter scheduler.

When the NetApp unified driver is used with a clustered Data ONTAP
storage system, you can leverage extra specs with Manila share types to
ensure that Manila shares are created on storage backends that have
certain properties (e.g. thin provisioning, disk type, RAID type)
configured.

Extra specs are associated with Manila share types, so that when users
request shares of a particular share type, they are created on storage
backends that meet the list of requirements (e.g. available space, extra
specs, etc). You can use the specs in
:ref:`Table 6.10, “NetApp supported Extra Specs for use with Manila Share Types”<table-6.10>`
later in this section when defining Manila share types with the
``manila type-key`` command.

.. _table-6.10:

+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Extra spec                               | Type      | Description                                                                                                                                                                                                                                                                                                                                                                      |
+==========================================+===========+==================================================================================================================================================================================================================================================================================================================================================================================+
| ``netapp_aggregate``                     | String    | Limit the candidate aggregate (pool) list to a specific aggregate.                                                                                                                                                                                                                                                                                                               |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_raid_type``                     | String    | Limit the candidate aggregate (pool) list based on one of the following raid types: ``raid4``, ``raid_dp``.                                                                                                                                                                                                                                                                      |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_disk_type``                     | String    | Limit the candidate aggregate (pool) list based on one of the following disk types: ``ATA``, ``BSAS``, ``EATA``, ``FCAL``, ``FSAS``, ``LUN``, ``MSATA``, ``SAS``, ``SATA``, ``SCSI``, ``XATA``, ``XSAS``, or ``SSD``.                                                                                                                                                            |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_hybrid_aggregate``              | Boolean   | Limit the candidate aggregate (pool) list to hybrid aggregates.                                                                                                                                                                                                                                                                                                                  |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp:dedup``                         | Boolean   | Enable deduplication on the share. *Note that this option is deprecated in favor of the standard Manila extra spec 'dedupe'.*                                                                                                                                                                                                                                                    |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``dedupe``                               | String    | Enable deduplication on the share. This value should be set to ``"<is> True"`` or ``"<is> False"``.                                                                                                                                                                                                                                                                              |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp:compression``                   | Boolean   | Enable compression on the share. When compression is enabled on a share, deduplication is also automatically enabled on that share. *Note that this option is deprecated in favor of the standard Manila extra spec 'compression'.*                                                                                                                                              |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``compression``                          | String    | Enable compression on the share. When compression is enabled on a share, deduplication is also automatically enabled on that share. This value should be set to ``"<is> True"`` or ``"<is> False"``.                                                                                                                                                                             |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp:thin_provisioned``              | Boolean   | Enable thin provisioning (a space guarantee of ``None``) on the share. *Note that this option is deprecated in favor of the standard Manila extra spec 'thin\_provisioning'.*                                                                                                                                                                                                    |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``thin_provisioning``                    | String    | Enable thin provisioning (a space guarantee of ``None``) on the share. This value should be set to ``"<is> True"`` or ``"<is> False"``.                                                                                                                                                                                                                                          |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp:snapshot_policy``               | String    | Apply the specified snapshot policy to the created FlexVol volume. *Note that the snapshots created by applying a policy will not have corresponding Manila snapshot records.*                                                                                                                                                                                                   |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp:language``                      | String    | Apply the specified language to the FlexVol volume that corresponds to the Manila share. The language of the FlexVol volume determines the character set Data ONTAP uses to display file names and data for that volume. The default value for the language of the volume is the language of the SVM.                                                                            |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp:max_files``                     | String    | Change the maximum number of files for the FlexVol volume that corresponds to the Manila share. By default, the maximum number of files is proportional to the size of the share. This spec can be used to increase the number of files for very large shares (greater than 1TB), or to place a smaller limit on the number of files on a given share.                           |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp:split_clone_on_create``         | Boolean   | Choose whether a FlexVol volume that corresponds to the Manila share is immediately split from its parent when creating a share from a snapshot. By default, the FlexVol is not split so that no additional space is consumed. Setting this value to 'true' may be appropriate for shares that are created from a template share and that will encounter high rates of change.   |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``snapshot_support``                     | Boolean   | Choose whether to allow the creation of snapshots for a share type.                                                                                                                                                                                                                                                                                                              |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``create_share_from_snapshot_support``   | Boolean   | Enable the creation of a share from a snapshot.                                                                                                                                                                                                                                                                                                                                  |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``revert_to_snapshot_support``           | Boolean   | Allow a share to be reverted to the most recent snapshot.                                                                                                                                                                                                                                                                                                                        |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Table 6.10. NetApp supported Extra Specs for use with Manila Share Types

.. caution::

   When using the Manila driver without share server management, you
   can specify a value for the ``netapp_login`` option that only has
   SVM administration privileges (rather than cluster administration
   privileges); you should note some advanced features of the driver
   may not work and you may see warnings in the Manila logs, unless
   appropriate permissions are set. See the section called
   ":ref:`account-perm`" for more details on the required access level
   permissions for an SVM admin account.

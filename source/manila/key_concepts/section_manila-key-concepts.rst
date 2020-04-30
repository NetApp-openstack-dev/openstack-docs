Key Concepts
============

Share
-----

A Manila share is the fundamental resource unit allocated by the Shared
File System service. It represents an allocation of a persistent,
readable, and writable filesystem that can be accessed by OpenStack
compute instances, or clients outside of OpenStack (depending on
deployment configuration). The underlying connection between the
consumer of the share and the Manila service providing the share can be
achieved with a variety of protocols, including NFS and CIFS (protocol
support is dependent on the Manila driver deployed and the selection of
the end user).

.. warning::

   A Manila share is an abstract storage object that may or may not
   directly map to a "share" concept from the underlying backend
   provider of storage.

Manila shares can be identified uniquely through a UUID assigned by the
Manila service at the time of share creation. A Manila share may also be
optionally referred to by a human-readable name, though this string is
not guaranteed to be unique within a single tenant or deployment of
Manila.

The actual capacity provisioned in support of a Manila share resides on
a single Manila backend within a single resource pool.

Backend
-------

A Manila backend is the configuration object that represents a single
provider of resource pools upon which provisioning requests for shared
file systems may be fulfilled. A Manila backend communicates with the
storage system through a Manila driver. Manila supports multiple
backends to be configured and managed simultaneously (even with the same
Manila driver).

.. note::

   A single Manila backend may be defined in the ``[DEFAULT]`` stanza
   of ``manila.conf``; however, NetApp recommends that the
   ``enabled_share_backends`` configuration option be set to a
   comma-separated list of backend names, and each backend name have
   its own configuration stanza with the same name as listed in the
   ``enabled_share_backends`` option. Refer to the section called
   ":ref:`manila-conf`" for an example of the use of this option.


.. _manila_storage_pools:

Storage Pools
-------------

With the Kilo release of OpenStack, Manila has introduced the concept of
"storage pools". The backend storage may present one or more logical
storage resource pools from which Manila will select as a storage
location when provisioning shares. In releases prior to Kilo, NetApp's
Manila drivers contained some logic that determined which aggregate a
Manila share would be placed into; with the introduction of pools, all
scheduling logic is performed completely within the Manila scheduler.

.. important::

   For NetApp's Manila drivers, a Manila storage pool is an aggregate
   defined within ONTAP.

.. _manila_driver:

Driver
------

A Manila driver is a particular implementation of a Manila backend that
maps the abstract APIs and primitives of Manila to appropriate
constructs within the particular storage solution underpinning the
Manila backend.

.. caution::

   The use of the term "driver" often creates confusion given common
   understanding of the behavior of “device drivers” in operating
   systems. The term can connote software that provides a data I/O
   path. In the case of Manila driver implementations, the software
   provides provisioning and other manipulation of storage devices but
   does not lay in the path of data I/O. For this reason, the term
   "driver" is often used interchangeably with the alternative (and
   perhaps more appropriate) term “provider”.

A Manila share type is an abstract collection of criteria used to
characterize Manila shares. They are most commonly used to create a
hierarchy of functional capabilities that represent a tiered level of
storage services; for example, a cloud administrator might define a
``premium`` share type that indicates a greater level of performance
than a ``basic`` share type, which would represent a best-effort level
of performance.

The collection of criteria is specified as a list of key/value pairs,
which are inspected by the Manila scheduler when determining which
resource pools are able to fulfill a provisioning request. Individual
Manila drivers (and subsequently Manila backends) may advertise
arbitrary key/value pairs (also referred to as capabilities) to the
Manila scheduler for each pool, which are then compared against share
type definitions when determining which pool will fulfill a provisioning
request.

Extra Spec
----------

An extra spec is a key/value pair, expressed in the style of
``key=value``. Extra specs are associated with Manila share types, so
that when users request shares of a particular share type, the shares
are created on pools within storage backends that meet the specified
criteria.

.. note::

   The list of default capabilities that may be reported by a Manila
   driver and included in a share type definition include:

   -  ``share_backend_name``: The name of the backend as defined in
      ``manila.conf``

   -  ``vendor_name``: The name of the vendor who has implemented the
      driver (e.g. ``NetApp``)

   -  ``driver_version``: The version of the driver (e.g. ``1.0``)

   -  ``storage_protocol``: The protocol used by the backend to export
      block storage to clients (e.g. ``NFS_CIFS``)

   For a table of NetApp supported extra specs, refer to Table 6.10,
   ":ref:`NetApp supported Extra Specs for use with Manila Share Types<table-6.10>`".

Snapshot
--------

A Manila snapshot is a point-in-time, read-only copy of a Manila share.
Snapshots can be created from an existing Manila share that is
operational regardless of whether a client has mounted the file system.
A Manila snapshot can serve as the content source for a new Manila share
when the Manila share is created with the *create from snapshot* option
specified.

.. important::

   In the Mitaka and Newton release of OpenStack, snapshot support is
   enabled by default for a newly created share type. Starting with the
   Ocata release, the ``snapshot_support`` extra spec must be set to
   ``True`` in order to allow snapshots for a share type. If the
   'snapshot\_support' extra\_spec is omitted or if it is set to False,
   users would not be able to create snapshots on shares of this share
   type.

   Other snapshot-related extra specs in the Ocata release (and later)
   include:

   -  ``create_share_from_snapshot_support``: Allow the creation of a
      new share from a snapshot

   -  ``revert_to_snapshot_support``: Allow a share to be reverted to
      the most recent snapshot

   If an extra-spec is left unset, it will default to 'False', but a
   newly created share may or may not end up on a backend with the
   associated capability. Set the extra spec explicitly to ``False``,
   if you would like your shares to be created only on backends that do
   not support the associated capabilities. For a table of NetApp
   supported extra specs, refer to Table 6.10,
   ":ref:`NetApp supported Extra Specs for use with Manila Share Types<table-6.10>`".

.. important::
    From Ussuri release, a share can be created from a snapshot and be placed
    in a pool or backend different from the parent share. To allow shares to
    be placed in other pools or backends, make sure to set
    ``use_scheduler_creating_share_from_snapshot=True`` in the manila
    configuration file.
    To perform the operation across clusters, the replication feature must be
    enabled and the back end property ``replication_domain`` must be
    configured. More details are available :ref:`here <manila-conf-with-replication>`.

Share Group
-----------

A Manila share group is a grouping construct that makes it possible
to group shares. Share groups make it possible to perform actions
on a group of shares, such as generating consistent, point-in-time
snapshots simultaneously. Share group snapshots can be created from
an existing Manila share group. All shares stored in a share group
snapshot can be restored by creating a share group from a share group
snapshot.

.. note::

   When using NetApp's Manila drivers, Share Groups are synonymous
   with the conventional ``Consistency Group`` construct. Beginning
   with the Rocky release, OpenStack recommends the usage of Share
   Groups to create a grouping construct which operates on groups
   of shares.

.. note::

   All shares in a share group must be on the same share network
   and share server.

.. _share-access-rules:

Share Access Rules
------------------

Share access rules define which clients can access a particular Manila
share. Access rules can be declared for NFS shares by listing the valid
IP networks (using CIDR notation) which should have access to the share.
In the case of CIFS shares, the Windows security identifier (SID) can be
specified.

.. important::

   For NetApp's Manila drivers, share access is enforced through the
   use of export policies configured within the NetApp storage
   controller.

.. warning::

   There is an outstanding issue when attempting to add several access
   rules in close succession. There is the possibility that the share
   instance access-rules-status will get changed to a status of
   "updating multiple" on the API after the manager has already checked
   if the status is "updating multiple". This error will cause the
   allow/deny APIs to become stuck for this particular share instance.
   If this behavior is encountered, there are two potential
   workarounds. The least disruptive solution is to deny any already
   applied rule and then add back that same rule as was just deleted.
   The second solution is to restart the Manila driver in order to
   invoke a resync of access rules on the backend driver.

Security Services
-----------------

Security services are the concept in Manila that allow Finer-grained
client access rules to be declared for authentication or authorization
to access share content. External services including LDAP, Active
Directory, Kerberos can be declared as resources that should be
consulted when making an access decision to a particular share. Shares
can be associated to multiple security services.

.. important::

   When creating a CIFS share, the user will need to create a Security
   Service with any of the 3 options (LDAP, Active Directory or
   Kerberos) and then add this Security Service to the already created
   Share Network.

Share Networks
--------------

A share network is an object that defines a relationship between a set of
tenant's networks/subnets (as defined in an OpenStack network service
(Neutron or Nova-network)) and the Manila shares created by the same
tenant; that is, a tenant may find it desirable to provision shares such
that only instances connected to a particular OpenStack-defined network
have access to the share.

.. note::

   As of Kilo, share networks are no longer required arguments when
   creating shares.

Share Network Subnets
---------------------

A share network subnet is an entity that defines a relationship between a
single tenant's network/subnet (as defined in an OpenStack network
service (Neutron)) and the Manila share instance created by the same.
Since Train release, such information that once belonged to the share network
entity, is now under the share network subnet management.
This change led to another change in the share server object, which is now
associated to a share network subnet instead of a share network.

Share Servers
-------------

A share server is a logical entity that manages the shares that are
created on a specific share network. Depending on the implementation of
a specific Manila driver, a share server may be a configuration object
within the storage controller, or it may represent logical resources
provisioned within an OpenStack deployment that are used to support the
data path used to access Manila shares.

Share servers interact with network services to determine the
appropriate IP addresses on which to export shares according to the
related share network. Manila has a pluggable network model that allows
share servers to work with OpenStack environments that have either
Nova-Network or Neutron deployed. In addition, Manila contains an
implementation of a standalone network plugin which manages a pool of IP
addresses for shares that are defined in the ``manila.conf`` file. For
more details on how share servers interact with the various network
services, please refer to :ref:`figure-6.2` and :ref:`figure-6.3`.

.. important::

   Within the NetApp Manila driver, a share server is defined to be a
   storage virtual machine (also known as a Vserver) within the
   ONTAP system that is associated with a particular
   backend. The NetApp Manila driver has two operating "modes":

   1. One that supports the dynamic creation of share servers (SVMs)
      for each share network - this is referred to as the :ref:`NetApp
      Manila driver with share server management<with-share>`.

   2. One that supports the reuse of a single share server (SVM) for
      all shares hosted from a backend - this is referred to as the
      :ref:`NetApp Manila driver without share server management<without-share>`.

.. important::

   Starting from the Stein release, Manila supports managing and unmanaging share
   servers. This makes it possible to import share servers and manage them using
   Manila. For a detailed example, refer to the
   :ref:`Importing and exporting Manila Share servers<manage-share-server>`.

.. note::
   From Train release, the share server is no longer associated to a share
   network, but with the share network subnet instead.

Share Replicas
--------------

Share replicas are a way to mirror share data to another storage pool so
that the data is stored in multiple locations to allow failover in a
disaster situation. Manila currently allows three types of replication:
writable, readable, and DR.

-  Writable - Synchronously replicated shares where all replicas are
   writable. Promotion is not supported and not needed.

-  Readable - Mirror-style replication with a primary (writable) copy
   and one or more secondary (read-only) copies which can become
   writable after a promotion of the secondary.

-  DR (for Disaster Recovery) - Generalized replication with secondary
   copies that are inaccessible. A secondary replica will become the
   primary replica, and accessible, after a promotion.

.. important::

   The NetApp Unified Driver for ONTAP provides DR replication only if you are
   operating *without* Share Server management until Stein Release. From Train
   release, the NetApp Unified Driver for ONTAP *with* Share Server
   management does support DR style replication.

Share Migration
---------------

Starting with the Ocata release, NetApp's Manila driver supports
non-disruptive migration of Manila shares - along with the filesystem
metadata and snapshots, if desired. This can be useful in a variety of
use-cases, such as during maintenance or evacuation.

Share migration is a 2-step process which includes starting the
migration process using the ``manila migration-start`` command, and then
completing the process using the ``manila migration-complete`` command.
For the list of migration commands, refer to
":ref:`Table 6.9, “Manila API Overview - Share Migration<table-6.9>`".

Share Management
----------------

Managing and unmanaging of shares is an admin-only operation that makes it
possible to control the visibility of shared filesystem storage with respect
to Manila. Managing a share refers to registering a non-Manila share with its
size, shared filesystem protocol, share-server and export path into Manila
management. Unmanaging a share refers to unregistering a Manila share and
removing it from Manila's database. The unmanage option can be reverted, thus
making it possible to import the share to Manila control if desired.

.. important::

   When managing a share, Manila assigns a new UUID to the share and renames
   the share on the storage backend to the following format: ``share_<share_instance_id>``.
   This ensures that the same share cannot be managed twice.

Share-server Management
-----------------------

Since share-servers are logical containers that associate shares with share-networks,
there is also a provision to manage and unmanage them. Admin users can manage
share-servers by specifying the host, share-network and the driver-specific identifier
that are used to uniquely identify the share-server. This functionality helps in
importing share-servers and their associated shares and snapshots that were created
in another system/deployment. Similarly, share-servers can also be unmanaged and
removed from Manila's database.

.. important::

   When managing a share-server, Manila assigns a new UUID to the share-server
   and renames the share-server on the storage backend to the following format:
   ``os_<id>``, where ``<id>`` is the newly assigned UUID. This ensures that the
   same share-server cannot be managed twice.

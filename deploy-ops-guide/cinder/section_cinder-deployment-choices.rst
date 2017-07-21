Theory of Operation & Deployment Choices
========================================

**Cinder Backends and Storage Virtual Machines.**

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

    **Important**

    When deploying Cinder with clustered Data ONTAP, NetApp recommends
    that each Cinder backend refer to a single SVM within a cluster
    through the use of the ``netapp_vserver`` configuration option.
    While the driver can operate without the explicit declaration of a
    mapping between a backend and an SVM, a variety of advanced
    functionality (e.g. volume type extra-specs) will be disabled.

**Cinder volumes and FlexVol volumes.**

Data ONTAP FlexVol volumes (commonly referred to as volumes) and
OpenStack Block Storage volumes (commonly referred to as Cinder volumes)
are not semantically analogous. A FlexVol volume is a container of
logical data elements (for example: files, Snapshot copies, clones,
LUNs, et cetera) that is abstracted from physical elements (for example:
individual disks, and RAID groups). A Cinder volume is a block device.
Most commonly, these block devices are made available to OpenStack
Compute instances. NetApp’s various driver options for deployment of FAS
as a provider of Cinder storage place Cinder volumes, snapshot copies,
and clones within FlexVol volumes.

    **Important**

    The FlexVol volume is an overarching container for one or more
    Cinder volumes.

    **Note**

    NetApp's OpenStack Cinder drivers are not supported for use with
    Infinite Volumes, as Data ONTAP currently only supports FlexClone
    files and FlexClone LUNs with FlexVol volumes.

**Cinder volume representation within a FlexVol volume.**

A Cinder volume has a different representation in Data ONTAP when stored
in a FlexVol volume, dependent on storage protocol utilized with Cinder:

-  *iSCSI*: When utilizing the iSCSI storage protocol, a Cinder volume
   is stored as an iSCSI LUN.

-  *NFS*: When utilizing the NFS storage protocol, a Cinder volume is a
   file on an NFS export.

-  *Fibre Channel*: When utilizing the Fibre Channel storage protocol, a
   Cinder volume is stored as a Fibre Channel LUN.

**Cinder Scheduling and resource pool selection.**

When Cinder volumes are created, the Cinder scheduler selects a resource
pool from the available storage pools: see
`??? <#cinder.volume.storage.pools>`__ for an overview.
`table\_title <#cinder.pools.differences>`__ details the behavioral
changes in NetApp's Cinder drivers when scheduling the provisioning of
new Cinder volumes.

Beginning with Juno, each of NetApp's Cinder drivers report per-pool
capacity to the scheduler. When a new volume is provisioned, the
scheduler capacity filter eliminates too-small pools from consideration.
Similarly, the scheduler's capability, availability zone and other
filters narrow down the list of potential backends that may receive a
new volume based on the volume type and other volume characteristics.

The scheduler also has an evaluator filter that evaluates an optional
arithmetic expression to determine whether a pool may contain a new
volume. Beginning with Mitaka, the Data ONTAP drivers report per-pool
controller utilization values to the scheduler, along with a "filter
function" that prevents new volumes from being created on pools that are
overutilized. Controller utilization is computed by the drivers as a
function of CPU utilization and other internal I/O metrics. The default
filter function supplied by the Data ONTAP drivers is
"capabilities.utilization < 70"; 70% utilization is a good starting
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

Beginning with Mitaka, the Data ONTAP drivers report per-pool controller
utilization values to the scheduler, along with a "goodness function"
that allows the scheduler to prioritize backends that are less utilized.
Controller utilization is reported as a percentage, and the goodness
function is expected to yield a value between 0 and 100, with 100
representing maximum "goodness". The default goodness function supplied
by the Data ONTAP drivers is "100 - capabilities.utilization", and it
may be overridden on a per-backend basis in the Cinder configuration
file.

    **Note**

    The storage controller utilization metrics are reported by the
    Mitaka Cinder drivers for Data ONTAP 8.2 or higher, operating in
    either Cluster or 7-mode.

Beginning with Newton, additional information such as aggregate name and
aggregate space utilization is reported to the scheduler and may be used
in filter and weigher expressions. For example, to keep from filling an
aggregate completely, a filter expression of
"capabilities.aggregate\_used\_percent < 80" might be used.

+----------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Driver                           | Scheduling Behavior (as of Juno)                                                                                                                                                                                                  | Scheduling Behavior (as of Mitaka)                                                                                                                                                                                    |
+==================================+===================================================================================================================================================================================================================================+=======================================================================================================================================================================================================================+
| Clustered Data ONTAP             | Each FlexVol volume’s capacity and SSC data is reported separately as a pool to the Cinder scheduler. The Cinder filters and weighers decide which pool a new volume goes into, and the driver honors that request.               | Same as Juno. Also, per-pool storage controller utilization is reported to the scheduler, along with filter and goodness expressions that take controller utilization into account when making placement decisions.   |
+----------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Data ONTAP operating in 7-mode   | Each FlexVol volume’s capacity is reported separately as a pool to the Cinder scheduler. The Cinder filters and weighers decide which pool a new volume goes into, and the driver honors that request.                            | Same as Juno. Also, per-pool storage controller utilization is reported to the scheduler, along with filter and goodness expressions that take controller utilization into account when making placement decisions.   |
+----------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| E-Series                         | -  Each dynamic disk pool's and volume group’s capacity is reported separately as a pool to the Cinder scheduler. The Cinder filters and weighers decide which pool a new volume goes into, and the driver honors that request.   | Same as Juno.                                                                                                                                                                                                         |
|                                  |                                                                                                                                                                                                                                   |                                                                                                                                                                                                                       |
|                                  | -  E-Series volume groups are supported as of the Liberty release.                                                                                                                                                                |                                                                                                                                                                                                                       |
+----------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Table: Behavioral Differences in Cinder Volume Placement

**Cinder snapshots versus NetApp Snapshots.**

A NetApp Snapshot copy is a point-in-time file system image.
Low-overhead NetApp Snapshot copies are made possible by the unique
features of the WAFL storage virtualization technology that is part of
Data ONTAP. The high performance of the NetApp Snapshot makes it highly
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
way that Cinder snapshots are created is through use of Data ONTAP's'
FlexClone technology. By leveraging the FlexClone technology to
facilitate Cinder snapshots, it is possible to create many thousands of
Cinder snapshots for a single Cinder volume.

FlexClone files or FlexClone LUNs and their parent files or LUNs that
are present in the FlexClone volume continue to share blocks the same
way they do in the parent FlexVol volume. In fact, all the FlexClone
entities and their parents share the same underlying physical data
blocks, minimizing physical disk space usage.

**E-Series snapshots.**

The cinder driver can create hardware-based snapshots on E-Series.
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

    **Important**

    When Cinder is deployed with Data ONTAP, Cinder snapshots are
    created leveraging the FlexClone feature of Data ONTAP. As such, a
    license option for FlexClone must be enabled.

**CDOT and 7-mode consistency groups.**

Data ONTAP currently has "Consistency Group" snapshot operations, but
their semantics are not identical to Cinder CG operations. Cinder CGs
are tenant-defined sets of Cinder-volumes that act together as a unit
for a snapshot. Data ONTAP currently has no actual "Consistency Group"
object, but only CG snapshot operations. Moreover, these operations act
on Data ONTAP volumes, flexvols, which are themselves containers of the
backing files or LUNs for Cinder volumes. In effect, so long as there is
room in a Cinder pool to fit a snapshot or a copy of a consistency
group, that operation will be permitted without any further restriction.

**E-Series consistency groups.**

E-Series consistency groups share a 1:1 mapping with Cinder consistency
groups. Each consistency group may have up to 32 snapshots defined; up
to 64 independent snapshots may be defined on a volume if a volume is a
part of a consistency group. The create-from-source operation is
implemented using full volume copies, and such an operation based on a
consistency group containing large volumes may take a long time to
complete.

The NetApp SANtricity Web Services Proxy provides access through
standard HTTPS mechanisms to configuring management services for
E-Series storage arrays. You can install Web Services Proxy on either
Linux or Windows. As Web Services Proxy satisfies the client request by
collecting data or executing configuration change requests to a target
storage array, the Web Services Proxy module issues SYMbol requests to
the target storage arrays. Web Services Proxy provides a Representative
State Transfer (REST)-style API for managing E-Series controllers. The
API enables you to integrate storage array management into other
applications or ecosystems.

When Cinder is used with a NetApp E-Series system, use of the SANtricity
Web Services Proxy is currently required. The SANtricity Web Services
Proxy may be deployed in a highly-available topology using an
active/passive strategy.

While WFA can be utilized in conjunction with the NetApp unified Cinder
driver, a deployment of Cinder and WFA does introduce additional
complexity, management entities, and potential points of failure within
a cloud architecture. If you have an existing set of workflows that are
written within the WFA framework, and are looking to leverage them in
lieu of the default provisioning behavior of the Cinder driver operating
directly against a FAS system, then it may be desirable to use the
intermediated mode.

**SANtricity Web Services Proxy.**

The NetApp SANtricity Web Services Proxy provides access through
standard HTTPS mechanisms to configuring management services for
E-Series storage arrays. You can install Web Services Proxy on either
Linux or Windows. As Web Services Proxy satisfies the client request by
collecting data or executing configuration change requests to a target
storage array, the Web Services Proxy module issues SYMbol requests to
the target storage arrays. Web Services Proxy provides a Representative
State Transfer (REST)-style API for managing E-Series controllers. The
API enables you to integrate storage array management into other
applications or ecosystems.

    **Important**

    As of the Mitaka release, only NetApp SANtricity Web Services Proxy
    version 1.4 and greater are supported by the E-Series Cinder driver.
    If an older version is installed, the user will be notified that an
    upgrade is required upon starting the Cinder-Volume service.

    **Important**

    Unless you have a significant existing investment with OnCommand
    Workflow Automator that you wish to leverage in an OpenStack
    deployment, it is recommended that you start with the *direct* mode
    of operation when deploying Cinder with a NetApp FAS system. When
    Cinder is used with a NetApp E-Series system, use of the SANtricity
    Web Services Proxy in the *intermediated* mode is currently
    required. The SANtricity Web Services Proxy may be deployed in a
    highly-available topology using an active/passive strategy.

**FAS.**

If rich data management, deep data protection, and storage efficiency
are desired and should be availed directly by the storage, the NetApp
FAS product line is a natural fit for use within Cinder deployments.
Massive scalability, nondisruptive operations, proven storage
efficiencies, and a unified architecture (NAS and SAN) are key features
offered by the Data ONTAP storage operating system. These capabilities
are frequently leveraged in existing virtualization deployments and thus
align naturally to OpenStack use cases.

**E-Series.**

For cloud environments where higher performance is critical, or where
higher-value data management features are not needed or are implemented
within an application, the NetApp E-Series product line can provide a
cost-effective underpinning for a Cinder deployment. NetApp E-Series
storage offers a feature called Dynamic Disk Pools, which simplifies
data protection by removing the complexity of configuring RAID groups
and allocating hot spares. Utilization is improved by dynamically
spreading data, parity, and spare capacity across all drives in a pool,
reducing performance bottlenecks due to hot-spots. Additionally, should
a drive failure occur, DDP enables the pool to return to an optimal
state significantly faster than RAID6, while reducing the performance
impact during the reconstruction of a failed drive.

    **Note**

    As of the Icehouse release, NetApp has integrations with Cinder for
    both FAS and E-Series, and either storage solution can be included
    as part of a Cinder deployment to leverage the native benefits that
    either platform has to offer.

Clustered Data ONTAP represents NetApp’s platform for delivering future
innovation in the FAS product line. Its inherent qualities of
virtualization of network interfaces, disk subsystem, and administrative
storage controller map well to OpenStack constructs. The Storage Virtual
Machine storage server (SVM, historically referred to as Vserver) can
span across all nodes of a given clustered Data ONTAP deployment, for
example. The elasticity provided to expand or contract a Storage Virtual
Machine across horizontally scalable resources are capabilities critical
to cloud deployment unique to the clustered Data ONTAP mode of
operation.

The Data ONTAP 7-Mode drivers are primarily provided to allow rapid use
of prior deployed FAS systems for OpenStack block storage requirements.
There is no current intention to enhance the 7-Mode driver’s
capabilities beyond providing basic bug fixes.

    **Important**

    NetApp strongly recommends that all OpenStack deployments built upon
    the NetApp FAS product set leverage clustered Data ONTAP.

A frequent question from customers and partners is whether to utilize
NFS or iSCSI as the storage protocol with a Cinder deployment on top of
the NetApp FAS product line. Both protocol options are TCP/IP-based,
deliver similar throughputs and latencies, support Cinder features,
snapshot copies and cloning are supported to similar degrees, as well as
advertisement of other storage efficienty, data protection, and high
availability features.

**iSCSI.**

-  At the time of publishing, the maximum number of iSCSI LUNs per
   NetApp cluster is either 8,192 or 49,152 - dependent on the FAS model
   number (refer to `Hardware Universe <http://hwu.netapp.com>`__ for
   detailed information for a particular model). Cinder can be
   configured to operate with multiple NetApp clusters via multi-backend
   support to increase this number for an OpenStack deployment.

-  LUNs consume more management resources and some management tools also
   have limitations on the number of LUNs.

-  When Cinder is used independently of OpenStack Compute, use of iSCSI
   is essential to provide direct access to block devices. The Cinder
   driver used in conjunction with NFS relies on libvirt and the
   hypervisor to represent files on NFS as virtual block devices. When
   Cinder is utilized in bare-metal or non-virtualized environments, the
   NFS storage protocol is not an option.

-  The number of volumes on E-Series varies based on platform. The E5x00
   series supports 2048 volume per system while the E2x00 series
   supports 512. In both cases, the number of cinder volumes is limited
   to 256 per physical server. If live migration is enabled, E-Series is
   limited to 256 volumes. See the netapp\_enable\_multiattach option
   for more information.

**NFS.**

-  The maximum number of files in a single FlexVol volume exported
   through NFS is dependent on the size of the FlexVol volume; a 1TB
   FlexVol can have 33,554,432 files (assuming 32k inodes). The
   theoretical maximum of files is roughly two billion.

-  NFS drivers require support from the hypervisor to virtualize files
   and present them as block devices to an instance.

-  As of the Icehouse release, the use of parallel NFS (pNFS) is
   supported with the NetApp unified driver, providing enhanced
   performance and scalability characteristics.

-  You cannot apply Cinder QoS specs to NFS backends on cDOT through an
   SVM-Scoped admin user. In order to do so, you must use a
   Cluster-Scoped admin user.

-  There is no difference in the maximum size of a Cinder volume
   regardless of the storage protocol chosen (a file on NFS or an iSCSI
   LUN are both 16TB).

-  Performance differences between iSCSI and NFS are normally negligible
   in virtualized environments; for a detailed investigation, please
   refer to `NetApp TR3808: VMware vSphere and ESX 3.5 Multiprotocol
   Performance Comparison using FC, iSCSI, and
   NFS <http://www.netapp.com/us/system/pdf-reader.aspx?m=tr-3808.pdf&cc=us>`__.

    **Important**

    Deploying the NetApp Cinder driver with clustered Data ONTAP
    utilizing the NFS storage protocol yields a more scalable OpenStack
    deployment than iSCSI with negligible performance differences. If
    Cinder is being used to provide block storage services independent
    of other OpenStack services, the iSCSI protocol must be utilized.

    **Important**

    The NFS client cache refresh interval can vary depending on how the
    NFS client's default mounting options are configured. In order to
    prevent the issue of being confronted with a stale negative cache
    entry, an additional option must be passed to the NFS mount command
    invoked by the Cinder using an NFS driver. This can be configured by
    adding the line "nfs\_mount\_options = lookupcache=pos" to your
    driver configuration stanza in your cinder.conf file. Alternatively,
    if you are already setting other NFS mount options, then you can
    just add "lookupcache=pos​" to the end of your current
    "nfs\_mount\_options". The effect of this additional option is to
    force the NFS client to ignore any negative entries in its cache and
    always check the NFS host when attempting to confirm the existence
    of a file.

    **Tip**

    A related use case for the use of iSCSI with OpenStack deployments
    involves creating a FlexVol volume to serve as the storage for
    OpenStack compute nodes. As more hypervisor nodes are added, a
    master boot LUN can simply be cloned for each node, and compute
    nodes can become completely stateless. Since the configuration of
    hypervisor nodes are usually nearly identical (except for
    node-specific data like configuration files, logs, etc), the boot
    disk lends well to optimizations like deduplication and compression.

    Currently this configuration must be done outside of the management
    scope of Cinder, but it serves as another example of how the
    differentiated capabilities of NetApp storage can be leveraged to
    ease the deployment and ongoing operation of an OpenStack cloud
    deployment.

There are two options for defining storage pools on an E-Series storage
array; each have different performance characteristics and features.

**Volume Groups.**

-  Disk count will vary depending on the RAID Level selected.

-  Expand/extend options are expensive and cannot be performed
   concurrently or while a volume on the pool is initializing.

-  Higher raw performance compared to DDP.

-  Adding new disks will require an expensive reconstruction operation.

**Dynamic Disk Pools (DDP).**

-  DDP's require a minimum of 11 disks.

-  RAID reconstruction speed upon drive failures is greatly increased
   over Volume Groups.

-  Thin provisioned volumes are supported.

-  Volume expand/extend operations can run concurrently and while
   volumes are initializing.

-  Additional disks can be added with no additional reconstruction
   overhead.

    **Important**

    DDP should be used for provisioning storage if many volume extend
    operations are expected, or if thin provisioning is desired. If raw
    performance is the most important requirement, then properly
    provisioned volume groups are the best choice.

**Options.**

Starting with the Kilo release of OpenStack, deployers of NFS backends
for Cinder have a choice: to enable *NAS security* options, or not.

Cinder traditionally worked on the assumption that the connections from
OpenStack nodes to NFS backends used trusted physical networks and that
OpenStack services run on dedicated nodes whose users and processes were
trusted. Exposure of storage resources to tenants was always mediated by
the hypervisor under control of Cinder and Nova. Operations on the
backing files for Cinder volumes ran as *root* and the files themselves
were readable and writable by any user or process on OpenStack nodes
that mounted the NFS backend shares.

Starting with Kilo, two NAS security options were introduced that enable
the OpenStack operator, in concert with the NAS storage administrator,
to reduce the potential attack surface created by allowing such liberal
access to users and processes running on OpenStack storage and compute
nodes.

+-----------------------------------+------------+-----------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Option                            | Type       | Default Value   | Description                                                                                                                                                                                                                                                                                     |
+===================================+============+=================+=================================================================================================================================================================================================================================================================================================+
| ``nas_secure_file_operations``    | Optional   | "auto"          | Run operations on backing files for Cinder volumes as *cinder* user rather than *root* if 'true'; as *root* if 'false'. If 'auto', run as 'true' if in a "greenfield" environment and run as 'false' if existing volumes are found on startup.                                                  |
+-----------------------------------+------------+-----------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``nas_secure_file_permissions``   | Optional   | "auto"          | Create backing files for Cinder volumes to only be readable and writable by owner and group if 'true'; as readable and writable by owner, group, and world if 'false'. If 'auto', run as 'true' if in a "greenfield" environment and run as 'false' if existing volumes are found on startup.   |
+-----------------------------------+------------+-----------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Table: Configuration options for NFS Security

When ``nas_secure_file_operations`` is set to 'true', Cinder operations
on the backing files for Cinder volumes run as the dedicated *cinder*
user rather than as *root*. With this option enabled, the NFS storage
administrator can export shares with *root* "squashed", i.e. mapped to
an anonymous user without privileges. When the
``nas_secure_file_permissions`` is set to 'true', backing files for
Cinder volumes are only readable and writable by owner and group - mode
0660 rather than 0666. Since Cinder creates these files with both owner
and group *cinder*, only system processes running with uid or gid
*cinder* are allowed to read or write these files, assuming that *root*
has been squashed in the share export.

The default value of both of these options is 'auto'. For backwards
compatibility, if there already exist cinder volumes when Cinder starts
up and the value of one of these options is 'auto', it is set to 'false'
internally, whereas if there is a green field environment, the option is
set to 'true' and a marker file *.cinderSecureEnvIndicator* is created
under the mount directory. On startup, the marker file is checked so
that this automatic green field environment choice will be persisted for
subsequent startups after volumes have been created.

**Setup.**

When NAS security options are deployed, OpenStack Cinder and Nova nodes
must be configured appropriately, as well as Data ONTAP, for Cinder
volume operations and Nova attaches to succeed. For example, if *root*
root is "squashed" and "set uid" is disabled but the NAS security
options are set to 'false', the driver will attempt to run "chown" as
root, read and write backing files as root, and the like and these
operations will fail.

**Filer Side Setup.**

-  Ensure that the filer has *cinder* and *nova* user and group
   identities with *uid* and *gid* that match the corresponding users on
   the OpenStack Cinder and Nova nodes.

-  On the filer, put both the *cinder* and the *nova* users in the
   *cinder* group.

-  Ensure that the exported ONTAP volume has owner *cinder* and group
   *cinder*.

-  Set permissions on the exported share to 0755.

-  "Squash" access on the share for *root* and disable "set uid".

-  See `NetApp TR3850: NFSv4 Enhancements and Best Practices Guide: Data
   ONTAP Implementation <http://www.netapp.com/us/media/tr-3580.pdf>`__
   and `NetApp TR4067: Clustered Data ONTAP NFS Best Practice and
   Implementation Guide <http://www.netapp.com/us/media/tr-4067.pdf>`__,
   as well as the File Access and Protocols Management Guides available
   from the NetApp NOW site for setup information.

**OpenStack Setup.**

-  On Cinder and Nova nodes, for NFSv4, set the *Domain* in
   */etc/idmapd.conf* on both storage and compute nodes to match that of
   the NFS server. Restart idmapd service.

-  On Nova nodes, add the *nova* user to the *cinder* group.

-  On Nova nodes, set "user = 'nova'", "group = 'cinder'", and
   "dynamic\_ownership = 0" in */etc/libvirt/qemu.conf*.

-  On Nova nodes, restart libvirt-bin, qemu-kvm, and nova services (or
   reboot).

The overall objective here is to set up the exported share so that only
OpenStack processes with *cinder* user identity or group identity have
permission to read and write the backing files for cinder volumes, and
set up Cinder and Nova nodes in OpenStack such that Cinder operations on
the backing files run with *cinder* user identity and that Nova/libvirt
operations run with *cinder* group identity.

Cinder includes a Fibre Channel zone manager facility for configuring
zoning in Fibre Channel fabrics, specifically supporting Cisco and
Brocade Fibre Channel switches. The user is required to configure the
zoning parameters in the Cinder configuration file (``cinder.conf``). An
example configuration using Brocade is given below:

::

    zoning_mode=fabric 

    [fc-zone-manager]
    fc_fabric_names=fabricA,fabricB
    zoning_policy=initiator-target
    brcd_sb_connector=cinder.zonemanager.drivers.brocade.brcd_fc_zone_client_cli.BrcdFCZoneClientCLI
    fc_san_lookup_service=cinder.zonemanager.drivers.brocade.brcd_fc_san_lookup_service.BrcdFCSanLookupService
    zone_driver=cinder.zonemanager.drivers.brocade.brcd_fc_zone_driver.BrcdFCZoneDriver

    [fabricA] 
    fc_fabric_address=hostname
    fc_fabric_user=username
    fc_fabric_password=password
    principal_switch_wwn=00:00:00:00:00:00:00:00

    [fabricB] 
    fc_fabric_address=hostname
    fc_fabric_user=username
    fc_fabric_password=password
    principal_switch_wwn=00:00:00:00:00:00:00:00
                

-  This option will need to be set in the ``DEFAULT`` configuration
   stanza and its value must be ``fabric``.

-  Be sure that the name of the stanza matches one of the values given
   in the ``fc_fabric_names`` option in the ``fc-zone-manager``
   configuration stanza.

-  Be sure that the name of the stanza matches the other value given in
   the ``fc_fabric_names`` option in the ``fc-zone-manager``
   configuration stanza.

    **Important**

    While OpenStack has support for several Fibre Channel fabric switch
    vendors, NetApp has validated their drivers with the use of Brocade
    switches. For more information on other vendors, refer to the
    `upstream
    documentation <http://docs.openstack.org/trunk/config-reference/content/section_fc-zoning.html>`__.

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
catalog. In OpenStack, this is achieved together by the Cinder filter
scheduler and the NetApp driver by making use of volume type extra-specs
support together with the filter scheduler. There are some prominent
features which are exposed in the NetApp driver including mirroring,
de-duplication, compression, and thin provisioning.

When the NetApp unified driver is used with clustered Data ONTAP and
E-Series storage systems, you can leverage extra specs with Cinder
volume types to ensure that Cinder volumes are created on storage
backends that have certain properties (e.g. QoS, mirroring, compression)
configured.

Extra specs are associated with Cinder volume types, so that when users
request volumes of a particular volume type, they are created on storage
backends that meet the list of requirements (e.g. available space, extra
specs, etc). You can use the specs in
`table\_title <#cinder.netapp.extra_specs>`__ later in this section when
defining Cinder volume types with the ``cinder type-key`` command.

+-----------------------------------------+-----------+----------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Extra spec                              | Type      | Products Supported               | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
+=========================================+===========+==================================+==============================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================+
| ``netapp_aggregate``                    | String    | Clustered Data ONTAP             | Limit the candidate volume list to only the ones on a specific aggregate.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
+-----------------------------------------+-----------+----------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_raid_type``                    | String    | Clustered Data ONTAP, E-Series   | Limit the candidate volume list based on one of the following raid types: ``raid0``, ``raid1``, ``raid4``, ``raid5``\  [1]_, ``raid6``, ``raidDiskPool``, and ``raid_dp``. Note that ``raid4`` and ``raid_dp`` are for Clustered Data ONTAP only and ``raid0``, ``raid1``, ``raid5``, ``raid6``, and ``raidDiskPool`` are for E-Series only.                                                                                                                                                                                                                                                                                                                                                                                                 |
+-----------------------------------------+-----------+----------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_disk_type``                    | String    | Clustered Data ONTAP, E-Series   | Limit the candidate volume list based on one of the following disk types: ``ATA``, ``BSAS``, ``EATA``, ``FCAL``, ``FSAS``, ``LUN``, ``MSATA``, ``SAS``, ``SATA``, ``SCSI``, ``XATA``, ``XSAS``, or ``SSD``.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
+-----------------------------------------+-----------+----------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_hybrid_aggregate``             | Boolean   | Clustered Data ONTAP             | Limit the candidate volume list to only those on hybrid aggregates.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
+-----------------------------------------+-----------+----------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_eseries_disk_spindle_speed``   | String    | E-Series                         | Limit the candidate volume list based on the spindle speed of the drives. Select from the following options: ``spindleSpeedSSD``, ``spindleSpeed5400``, ``spindleSpeed7200``, ``spindleSpeed10k``, ``spindleSpeed15k``. Note: If mixed spindle speeds are present in the same pool, the filtering behavior is undefined.                                                                                                                                                                                                                                                                                                                                                                                                                     |
+-----------------------------------------+-----------+----------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp:qos_policy_group``\  [2]_      | String    | Clustered Data ONTAP             | Specify the name of a QoS policy group, which defines measurable Service Level Objectives (SLO), that should be applied to the Cinder volume at the time of volume creation. Ensure that the QoS policy group is defined within clustered Data ONTAP before a Cinder volume is created. The QoS policy group specified will be shared among all Cinder volumes whose volume types reference the policy group in their extra specs. Since the SLO is shared with multiple Cinder volumes, the QoS policy group should not be associated with the destination FlexVol volume. If you want to apply an SLO uniquely on a per Cinder volume basis use Cinder backend QoS specs. See `??? <#cinder.key_concepts.qos_supported_backend_opts>`__.   |
+-----------------------------------------+-----------+----------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_disk_encryption``              | Boolean   | E-Series                         | Limit the candidate volume list to only the ones that have Full Disk Encryption (FDE) enabled on the storage controller.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
+-----------------------------------------+-----------+----------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_flexvol_encryption``           | Boolean   | Clustered Data ONTAP             | Limit the candidate volume list to only the ones that have Flexvol Encryption (NVE) enabled on the storage controller. NVE is a software-based technology for encrypting data at rest, one volume at a time.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
+-----------------------------------------+-----------+----------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_eseries_data_assurance``       | Boolean   | E-Series                         | Limit the candidate volume list to only the ones that support the Data Assurance (DA) capability. DA provides an additional level of data integrity by computing a checksum for every block of data that is written to the drives. DA is not supported with iSCSI interconnect.                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
+-----------------------------------------+-----------+----------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_eseries_flash_read_cache``     | Boolean   | E-Series                         | Limit the candidate volume list to only the ones that support being added to a Flash Cache. Adding volumes to a Flash Cache can increase read performance. An SSD cache must be defined on the storage controller for this feature to be available.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
+-----------------------------------------+-----------+----------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp:read_cache``                   | Boolean   | E-Series                         | Explicitly enable or disable read caching for the Cinder volume at the time of volume creation.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
+-----------------------------------------+-----------+----------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp:write_cache``                  | Boolean   | E-Series                         | Explicitly enable or disable write caching for the Cinder volume at the time of volume creation.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
+-----------------------------------------+-----------+----------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_mirrored``                     | Boolean   | Clustered Data ONTAP             | Limit the candidate volume list to only the ones that are mirrored on the storage controller.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
+-----------------------------------------+-----------+----------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_dedup``                        | Boolean   | Clustered Data ONTAP             | Limit the candidate volume list to only the ones that have deduplication enabled on the storage controller.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
+-----------------------------------------+-----------+----------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_compression``                  | Boolean   | Clustered Data ONTAP             | Limit the candidate volume list to only the ones that have compression enabled on the storage controller.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
+-----------------------------------------+-----------+----------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_thin_provisioned``             | Boolean   | Clustered Data ONTAP, E-Series   | Limit the candidate volume list to only the ones that support thin provisioning on the storage controller.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
+-----------------------------------------+-----------+----------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Table: NetApp supported Extra Specs for use with Cinder Volume Types

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

As of the Liberty release, all NetApp drivers conform to the standard
Cinder scheduler-based over-subscription framework as described
`here <http://docs.openstack.org/admin-guide-cloud/blockstorage_over_subscription.html>`__,
in which the ``max_over_subscription_ratio`` and ``reserved_percentage``
configuration options are used to control the degree of
over-subscription allowed in the relevant storage pool. Note that the
Cinder scheduler only allows over-subscription of a storage pool if the
pool reports the *thin-provisioning-support* capability, as described
for each type of NetApp platform below.

The default ``max_over_subscription_ratio`` for all drivers is 20.0, and
the default ``reserved_percentage`` is 0. With these values and
*thin-provisioning-support* capability on (see below), if there is 5TB
of actual free space currently available in the backing store for a
Cinder pool, then up to 1,000 Cinder volumes of 100GB capacity may be
provisioned before getting a failure, assuming actual physical space
used averages 5% of nominal capacity.

**Data ONTAP Thin Provisioning.**

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

**E-Series Thin Provisioning.**

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

Table: NetApp supported configuration options for use with
Over-Subscription

The Challenge Handshake Authentication Protocol (CHAP) enables
authenticated communication between iSCSI initiators and targets. During
the initial stage of an iSCSI session, the initiator sends a login
request to the storage system to begin the session. The login request
includes the initiator’s CHAP user name and password. The storage
system’s configured initiator provides a CHAP response. The storage
system verifies the response and authenticates the initiator.

    **Important**

    For Data ONTAP the use of CHAP authentication requires that TCP port
    22 (SSH) is available on the cluster management LIF. A SSH
    connection, from the driver to the storage system, is required to
    set the credentials on the appropriate iSCSI initiator. For E-Series
    this is not necessary.

**Establishing an iSCSI Session.**

-  Nova obtains the iSCSI Qualified Name (IQN) from the Hypervisor of
   the Compute Node.

-  Nova sends a request to Cinder to initialize the iSCSI initiator.

-  Cinder generates a random CHAP password.

-  Cinder sends a request to the storage backend to add/update the
   initiator for the provided IQN.

-  Nova then provides the Hypervisor with the data needed to establish
   the iSCSI session with the storage backend.

**iSCSI Session Scope.**

Restarting the Cinder services after enabling CHAP authentication in the
Cinder configuration file will not impact an existing iSCSI session. The
hypervisor, in a running compute node, and the storage backend establish
an iSCSI session when the first volume is attached. CHAP authentication
will first be used, after enablement, when any existing iSCSI session is
terminated and a new iSCSI session is established.

**Configuration Options.**

To enable CHAP authentication for the NetApp clustered Data ONTAP,
7-mode, or E-Series iSCSI drivers, the following options should be added
to the appropriate NetApp stanza in the Cinder configuration file
(cinder.conf). This configuration option is only relevant to iSCSI
support.

::

    [myIscsiBackend]
    use_chap_auth =  True
                

.. [1]
   Note that RAID3 is a deprecated RAID type on E-Series storage
   controllers and operates as RAID5.

.. [2]
   Please note that this extra spec has a colon (``:``) in its name
   because it is used by the driver to assign the QoS policy group to
   the OpenStack Block Storage volume after it has been provisioned.

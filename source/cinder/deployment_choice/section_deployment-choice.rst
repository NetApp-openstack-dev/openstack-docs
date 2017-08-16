Deployment Choices
==================

FAS vs. E-Series
----------------

**FAS**

If rich data management, deep data protection, and storage efficiency
are desired and should be availed directly by the storage, the NetApp
FAS product line is a natural fit for use within Cinder deployments.
Massive scalability, nondisruptive operations, proven storage
efficiencies, and a unified architecture (NAS and SAN) are key features
offered by the Data ONTAP storage operating system. These capabilities
are frequently leveraged in existing virtualization deployments and thus
align naturally to OpenStack use cases.

**E-Series**

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

.. note::

   As of the Icehouse release, NetApp has integrations with Cinder for
   both FAS and E-Series, and either storage solution can be included
   as part of a Cinder deployment to leverage the native benefits that
   either platform has to offer.

Clustered Data ONTAP vs. Data ONTAP Operating in 7-Mode
-------------------------------------------------------

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

.. important::

   NetApp strongly recommends that all OpenStack deployments built upon
   the NetApp FAS product set leverage clustered Data ONTAP.

NFS vs. iSCSI
-------------

A frequent question from customers and partners is whether to utilize
NFS or iSCSI as the storage protocol with a Cinder deployment on top of
the NetApp FAS product line. Both protocol options are TCP/IP-based,
deliver similar throughputs and latencies, support Cinder features,
snapshot copies and cloning are supported to similar degrees, as well as
advertisement of other storage efficienty, data protection, and high
availability features.

**iSCSI**

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

**NFS**

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

.. important::

   Deploying the NetApp Cinder driver with clustered Data ONTAP
   utilizing the NFS storage protocol yields a more scalable OpenStack
   deployment than iSCSI with negligible performance differences. If
   Cinder is being used to provide block storage services independent
   of other OpenStack services, the iSCSI protocol must be utilized.

.. important::

   The NFS client cache refresh interval can vary depending on how the
   NFS client's default mounting options are configured. In order to
   prevent the issue of being confronted with a stale negative cache
   entry, an additional option must be passed to the NFS mount command
   invoked by the Cinder using an NFS driver. This can be configured by
   adding the line "nfs\_mount\_options = lookupcache=pos" to your
   driver configuration stanza in your cinder.conf file. Alternatively,
   if you are already setting other NFS mount options, then you can
   just add "lookupcache=pos<200b>" to the end of your current
   "nfs\_mount\_options". The effect of this additional option is to
   force the NFS client to ignore any negative entries in its cache and
   always check the NFS host when attempting to confirm the existence
   of a file.

.. tip::

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

Volume Groups vs. Dynamic Disk Pools (E-Series)
-----------------------------------------------

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

NFS Security
------------

**Options**

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

Tablei 4.10. Configuration options for NFS Security

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

**Setup**

When NAS security options are deployed, OpenStack Cinder and Nova nodes
must be configured appropriately, as well as Data ONTAP, for Cinder
volume operations and Nova attaches to succeed. For example, if *root*
root is "squashed" and "set uid" is disabled but the NAS security
options are set to 'false', the driver will attempt to run "chown" as
root, read and write backing files as root, and the like and these
operations will fail.

**Filer Side Setup**

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

**OpenStack Setup**

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

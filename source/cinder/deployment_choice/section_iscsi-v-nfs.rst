Deployment Choices: NFS vs. iSCSI
=================================

A frequent question from customers and partners is whether to utilize
NFS or iSCSI as the storage protocol with a Cinder deployment on top of
the NetApp FAS product line. Both protocol options are TCP/IP-based,
deliver similar throughputs and latencies, support Cinder features,
snapshot copies and cloning are supported to similar degrees, as well as
advertisement of other storage efficiency, data protection, and high
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

-  The use of parallel NFS (pNFS) is
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

   Deploying the NetApp Cinder driver with ONTAP
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
   adding the line "nfs_mount_options = lookupcache=pos" to your
   driver configuration stanza in your cinder.conf file. Alternatively,
   if you are already setting other NFS mount options, then you can
   just add "lookupcache=pos" to the end of your current
   "nfs_mount_options". The effect of this additional option is to
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

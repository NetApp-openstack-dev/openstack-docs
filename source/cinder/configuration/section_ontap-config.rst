.. _data-ontap-config:

Data ONTAP Configuration
========================

Data ONTAP Prerequisites
------------------------

The prerequisites for Data ONTAP (both clustered Data ONTAP and Data
ONTAP operating in 7-Mode) are:

-  The driver requires a storage controller running Data ONTAP 8.1.1 or
   later.

-  The storage system should have the following licenses applied:

   -  Base

   -  NFS (if the NFS storage protocol is to be used)

   -  iSCSI (if the iSCSI storage protocol is to be used)

   -  FCP (if the Fibre Channel protocol is to be used)

   -  FlexClone

   -  MultiStore (if vFiler units are used with Data ONTAP operating in
      7-Mode)

Storage Virtual Machine Considerations
--------------------------------------

1. Ensure the appropriate licenses (as described previously) are enabled
   on the storage system for the desired use case.

2. The SVM must be created (and associated with aggregates) before it
   can be utilized as a provisioning target for Cinder.

3. FlexVol volumes must be created before the integration with Cinder is
   configured, as there is a many-to-one relationship between Cinder
   volumes and FlexVol volumes (see the section called ":ref:`theory-op`"
   for more information).

4. Regardless of the storage protocol used, data LIFs must be created
   and assigned to SVMs before configuring Cinder.

5. If NFS is used as the storage protocol:

   1. Be sure to enable the NFS service on the SVM.

   2. Be sure to enable the desired version of the NFS protocol (e.g.
      ``v4.0, v4.1-pnfs``) on the SVM.

   3. Be sure to define junction paths from the FlexVol volumes and
      refer to them in the file referenced by the ``nfs_shares_config``
      configuration option in ``cinder.conf``.

6. If iSCSI is used as the storage protocol:

   1. Be sure to enable the iSCSI service on the SVM.

   2. Be sure to set iSCSI as the data protocol on the data LIF.

   3. Note that iSCSI LUNs will be created by Cinder; therefore, it is
      not necessary to create LUNs or igroups before configuring Cinder.

7. If Fibre Channel is used as the storage protocol:

   1. Be sure to enable the FCP service on the SVM.

   2. Be sure to set FCP as the data protocol on the data LIF.

   3. Note that Fibre Channel LUNs will be created by Cinder; therefore,
      it is not necessary to create LUNs or igroups before configuring
      Cinder.

8. Once FlexVol volumes have been created, be sure to configure the
   desired features (e.g. deduplication, compression, SnapMirror
   relationships, etc) before configuring Cinder. While Cinder will
   periodically poll Data ONTAP to discover changes in configuration
   and/or features, there is a delay in time between when changes are
   performed and when they are reflected within Cinder.

9. NetApp does not recommend using the autogrow capability for Data
   ONTAP FlexVol volumes within a Cinder deployment. A FlexVol only
   reports its current size, so the Cinder scheduler is never made aware
   of the autogrow limit that may or may not be enabled for the FlexVol.

.. _account-permissions:

Account Permission Considerations
---------------------------------

The NetApp unified driver talks to ONTAP via ONTAP API and HTTP(S). At a
minimum, the ONTAP SVM administrator (vsadmin) role is required. The
cinder driver requires cluster level rights to support scheduling based
on some of the more advanced features. Such rights cannot be granted to
even the SVM administrators. The following limitations apply when using
a SVM admin role:

-  cinder volume type extra specs which cannot be used, for further
   details, see the section called ":ref:`cinder-api`" and
   the section called ":ref:`theory-op`"

-  QoS support will be disabled and hence QOS specs cannot be used when
   creating volumes (QoS\_support)

-  Disk types considerations will not be possible when creating volumes
   (netapp\_disk\_type)

-  Space Efficieny will not be considered when creating volumes
   (netapp\_dedup, netapp\_compression)

-  Headroom considerations cannot be made when creating volumes,
   effectively, goodness and filter functions are disabled.
   (filter\_function, goodness\_function)

-  Disk protection leves will not be considered when creating volume
   (netapp\_raid\_type)

Creating least privileged role for a Cluster-Scoped Account
-----------------------------------------------------------

1. Create role with appropriate command directory permissions for cinder

   Assign the following persmissions which are exclusive of DR,
   replication, and protocols, each of which will be added next.::

       security login role create -role cluster-scoped-limited-permissions -cmddirname vserver -access readonly
       security login role create -role cluster-scoped-limited-permissions -cmddirname "system node" -access readonly
       security login role create -role cluster-scoped-limited-permissions -cmddirname security -access readonly
       security login role create -role cluster-scoped-limited-permissions -cmddirname "security login role" -access readonly
       security login role create -role cluster-scoped-limited-permissions -cmddirname statistics -access readonly
       security login role create -role cluster-scoped-limited-permissions -cmddirname "statistics catalog counter" -access readonly
       security login role create -role cluster-scoped-limited-permissions -cmddirname "statistics catalog instance" -access readonly
       security login role create -role cluster-scoped-limited-permissions -cmddirname "statistics catalog" -access readonly
       security login role create -role cluster-scoped-limited-permissions -cmddirname "storage disk" -access readonly
       security login role create -role cluster-scoped-limited-permissions -cmddirname "storage aggregate" -access readonly
       security login role create -role cluster-scoped-limited-permissions -cmddirname "network interface" -access readonly
       security login role create -role cluster-scoped-limited-permissions -cmddirname "volume efficiency" -access all
       security login role create -role cluster-scoped-limited-permissions -cmddirname "qos policy-group" -access all
       security login role create -role cluster-scoped-limited-permissions -cmddirname version -access all
       security login role create -role cluster-scoped-limited-permissions -cmddirname event -access all
       security login role create -role cluster-scoped-limited-permissions -cmddirname "volume file clone" -access readonly
       security login role create -role cluster-scoped-limited-permissions -cmddirname "volume file clone split" -access readonly
       security login role create -role cluster-scoped-limited-permissions -cmddirname "volume snapshot" -access all

   Assign the following permissions if NetApp cinder driver is to
   support NFS::

       security login role create -role cluster-scoped-limited-permissions -cmddirname "volume file" -access all

   Assign the following permissions if NetApp cinder driver is to
   support iSCSI and or FC::

       security login role create -role cluster-scoped-limited-permissions -cmddirname "lun" -access all
       security login role create -role cluster-scoped-limited-permissions -cmddirname "lun mapping" -access all
       security login role create -role cluster-scoped-limited-permissions -cmddirname "lun igroup" -access all

   Assign the following permissions if NetApp cinder driver is to
   support iSCSI::

       security login role create -role cluster-scoped-limited-permissions -cmddirname "vserver iscsi interface" -access all
       security login role create -role cluster-scoped-limited-permissions -cmddirname "vserver iscsi security" -access all
       security login role create -role cluster-scoped-limited-permissions -cmddirname "vserver iscsi" -access readonly                                       

   Assign the following permissions if NetApp cinder driver is to
   support FC::

       security login role create -role cluster-scoped-limited-permissions -cmddirname "vserver fcp portname" -access all
       security login role create -role cluster-scoped-limited-permissions -cmddirname "vserver fcp interface" -access readonly
       security login role create -role cluster-scoped-limited-permissions -cmddirname "vserver fcp" -access readonly

   Assign the following permissions if NetApp cinder driver is to
   support replication but not cheesecake DR::

       security login role create -role cluster-scoped-limited-permissions -cmddirname snapmirror -access readonly
       security login role create -role cluster-scoped-limited-permissions -cmddirname volume -access readonly

   Assign the following permissions if NetApp cinder driver is to
   support replication along with cheesecake DR::

       security login role create -role cluster-scoped-limited-permissions -cmddirname "cluster peer" -access all
       security login role create -role cluster-scoped-limited-permissions -cmddirname "cluster peer policy" -access all
       security login role create -role cluster-scoped-limited-permissions -cmddirname "vserver peer" -access all
       security login role create -role cluster-scoped-limited-permissions -cmddirname snapmirror -access all
       security login role create -role cluster-scoped-limited-permissions -cmddirname volume -access all

2. Command to create user with appropriate role::

       security login create –username openstack –application ontapi –authmethod password –role cluster-scoped-limited-permissions

Storage Networking Considerations
---------------------------------

1. Ensure there is segmented network connectivity between the hypervisor
   nodes and the Data LIF interfaces from Data ONTAP.

2. When NFS is used as the storage protocol with Cinder, the node
   running the ``cinder-volume`` process will attempt to mount the NFS
   shares listed in the file referred to within the
   ``nfs_shares_config`` configuration option in ``cinder.conf``. Ensure
   that there is appropriate network connectivity between the
   ``cinder-volume`` node and the Data LIF interfaces, as well as the
   cluster/SVM management interfaces.

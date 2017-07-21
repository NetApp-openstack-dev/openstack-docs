Troubleshooting
===============

Common Problems
===============

Common problems listed below are followed by the ``cinder``, ``manila``,
or ``nova`` CLI command and possible reasons for the occurrence of the
problem.

**1. Create volume operation fails with an error status.**

::

    cinder create size_gb
                        

-  No space left on the NetApp volume or NetApp volume does not have
   sufficient free space to host the specified OpenStack volume. Here
   NetApp volume refers to a FlexVol volume inside the configured
   Storage Virtual Machine (SVM aka Vserver) for Clustered Data ONTAP
   driver. It refers to NetApp volumes filtered in Cinder through
   parameter ``netapp_pool_name_search_pattern`` or NetApp volumes in
   the configured vFiler unit as parameter ``netapp_vfiler`` or system
   wide NetApp volumes for 7-mode storage system.

-  Cinder API service is down.

-  Cinder scheduler service is down.

-  Cinder scheduler reports sufficient available space on NetApp backend
   but Cinder volume fails to create backend:

   -  The Grizzly-based iSCSI driver for Clustered Data ONTAP and 7-mode
      driver report available space as infinite and hence failure may
      occur when no NetApp volume can host the OpenStack volume.

   -  The Grizzly-based NFS driver Clustered Data ONTAP and 7-mode
      report available space as the sum of available space of all
      configured NFS exports and hence failure may occur when no single
      NetApp volume can host the OpenStack volume of the given size.

   -  The Havana-based iSCSI and NFS driver for Clustered Data ONTAP
      report the available capacity for largest NetApp volume in the
      configured Storage Virtual Machine (SVM aka Vserver). Capacity
      mismatch might fail volume creation.

   -  The Havana-based iSCSI and NFS driver for 7-mode storage system
      report the available capacity as sum of available space of all
      configured NetApp volumes and hence failure may occur when no
      single NetApp volume can host the OpenStack volume of the given
      size.

-  The Havana based NFS driver for Clustered Data ONTAP has the
   configuration option ``netapp_vserver`` to specify the Storage
   Virtual Machine (SVM aka Vserver) to use for provisioning. It may so
   happen that the NFS exports specified in the configuration and the
   NetApp volumes in the SVM do not coincide.

-  NFS service is not running on the NetApp storage server in case of
   NFS drivers.

-  NFS mount for exports failed on the Cinder node due to incorrect
   export policy or insufficient privileges in case of NFS drivers.

-  NetApp volumes getting full because snapshots occupying storage
   space.

-  NetApp volumes are shared between OpenStack Cinder and other client
   side applications.

**2. Create volume with volume-type operation fails with error status.**

::

    cinder create --volume-type volume_type size_gb
                        

-  All the reasons mentioned under Item 1 in this appendix.

-  The NetApp backend(s) with available space do not support at least
   one of the extra-specs bound to the volume-type requested. Hence, it
   does not return the extra spec in volume stats call to the Cinder
   scheduler.

-  In Clustered Data ONTAP drivers operation fails due to:

   -  No NetApp volume supports all extra specs bound to the
      volume-type.

   -  The configured storage admin user does not have sufficient
      privileges to query specific storage service catalog features
      required to support the volume-type configuration.

   -  The configured IP address/host name is on a SVM network interface
      but the volume-type support requires cluster wide API access.

**3. Create volume from image-id operation fails with an error status.**

::

    cinder create --image-id image-id size_gb
                        

-  All the reasons mentioned under Item 1 in this appendix.

-  The Grizzly-based NFS driver does not have the mentioned operation
   supported. It may be required to use the latest code from the NetApp
   git repository, from the ``stable/grizzly`` branch in order to get a
   supported version.

-  Glance related services are down.

-  The image could not be downloaded from glance because of download
   error.

-  Havana-based NFS drivers may experience a shortage in storage
   capacity due to space occupied by image cache files. Image cache
   files are files with prefix img-cache, and are periodically cleaned
   by the driver.

**4. Create volume from image-id with volume-type operation fails with
an error status.**

::

    cinder create --image-id image-id --volume-type volume_type size_gb
                        

-  All the reasons mentioned under Items 1, 2, and 3 in this appendix.

**5. Create snapshot operation fails with an error status.**

::

    cinder snapshot-create volume-id
                        

-  The FlexClone license is not installed.

-  The NetApp volume hosting the source OpenStack volume does not have
   sufficient available space.

-  Any maintenance operation by a storage admin directly at the storage
   backend causing LUN or file unavailability.

**6. Create volume from snapshot operation fails with an error status.**

::

    cinder create --snapshot-id snapshot-id size_gb
                        

-  All reason mentioned under Items 1 & 5 in this appendix.

**7. Create cloned volume operation fails with an error status.**

::

    cinder create --source-volid volume-id size_gb
                        

-  All reason mentioned under Items 1 & 5 in this appendix.

**8. Volume attach operation in nova fails.**

::

    nova volume-attach instance-id volume-id path size_gb
                        

-  iSCSI drivers:

   -  The iSCSI license may not be installed.

   -  The iSCSI service on the ``nova-compute`` host may not be running.

   -  The iSCSI portal can not be found. No network interface of type
      iSCSI has been created.

   -  The network is not reachable due to firewall, configuration, or
      transient issues.

**9. Volume extend operation fails for Havana based drivers.**

::

    cinder extend volume-id new_size_gb size_gb
                        

-  The NetApp volume hosting the OpenStack volume has insufficient
   space.

-  iSCSI drivers

   -  Reason mentioned under Item 5 in this appendix.

-  NFS drivers

   -  The disk image format of the Cinder volume is not ``raw`` or
      ``qcow2``.

**10. Volume upload to image operation fails.**

::

    cinder upload-to-image volume-id image size_gb
                        

-  The Glance service is down.

-  All reasons mentioned under Item 8 in this appendix.

**11. Volume backup and restore operation fails.**

::

    cinder backup-create volume-id size_gb
    cinder backup-restore volume-id size_gb
                        

-  The Cinder backup service is not running.

-  All reasons mentioned under Item 8 in this appendix.

**12. Volume migration operation fails.**

::

    cinder migrate volume-id host
                        

-  All reasons mentioned under Item 8 in this appendix.

**13. Volume extend operation fails with E-Series driver.**

::

    cinder extend volume-id new_size_gb size_gb
                        

The volume extend operation will fail on a Cinder volume that is defined
on a Volume Group (as opposed to a DDP), if any of the following
conditions are true:

-  Another volume on the pool is currently being initialized.

-  Another volume extend operation is in progress.

If any of the previous conditions are true, then the extend will result
in an error state for the volume. The error condition can be cleared by
using cinder reset-state. The operation can be retried successfully once
the conflicting operations on the pool are completed. It is recommended
that DDP be used in place of Volume Groups if this is a commonly
utilized operation in your environment, in order to avoid the previously
ascribed limitations. See `??? <#cinder.config.eseries.pools>`__ for a
comparison of storage pool options.

**14. Share replica fails to reach in-sync status..**

::

    manila share-replica-list --share-id id
                        

-  The ONTAP controller and the Manila host system times may not be
   synchronized.

-  The controller hosting the active share replica is having trouble
   communicating with the share replica's host via intercluster LIFs.

Triage and Data Collection
==========================

Please use the NetApp OpenStack Communities site to track or report
issues related to Cinder. In case of issues, the data can be collected
from logs printed by each of the below mentioned process. Logs need to
be collected for Cinder related processes. For Glance and Nova verifying
the service up status is sufficient.

-  ``cinder-api``

-  ``cinder-backup``

-  ``cinder-scheduler``

-  ``cinder-volume``

    **Note**

    You can add the following line to your NetApp backend stanza(s) in
    cinder.conf to capture much more detail about the driver’s
    interaction with Data ONTAP in the cinder-volume log:

    -  ``trace_flags``\ = method,api

    Please note that this tends to bloat up the log files and hence you
    should only do this for problem resolution.

-  ``manila-api``

-  ``manila-scheduler``

-  ``manila-share``

-  ``nova-api``

-  ``nova-scheduler``

-  ``nova-cpu``

-  ``glance-api``

-  ``glance-registry``

-  ``swift-object-server``

-  ``swift-object-replicator``

-  ``swift-object-updator``

-  ``swift-object-auditor``

-  ``swift-container-server``

-  ``swift-container-replicator``

-  ``swift-container-updator``

-  ``swift-container-auditor``

-  ``swift-account-server``

-  ``swift-account-replicator``

-  ``swift-account-auditor``

References
==========

The following references were used in this paper:

-  NIST Cloud Definition http://www.nist.gov

-  OpenStack Foundation http://www.openstack.org

-  Cloud Data Management Interface (CDMI) http://www.snia.org/cdmi

For additional information, visit:

-  For more information on the operation, deployment of, or support for
   NetApp’s OpenStack integrations:
   http://communities.netapp.com/groups/openstack

-  For source code for OpenStack, including NetApp contributions,
   available through Github: http://www.github.com/openstack

-  For more information about NetApp’s participation in OpenStack, visit
   the NetApp Community site: http://www.netapp.com/openstack

-  For more information about OpenStack history:
   http://www.openstack.org or http://en.wikipedia.org/wiki/OpenStack

Support
=======

Community support is available through the NetApp Communities site:
http://communities.netapp.com/groups/openstack.

NetApp’s Interoperability Matrix (IMT) details components and versions
of qualified configurations. Since the majority of OpenStack provides a
control plane it’s not presently explicitly called out, but host
operating system, hypervisor, and other components involved in the data
path should be noted.

http://support.netapp.com/matrix/

The NetApp OpenStack team presently intends to provide maintenance of
the two most recently released versions of OpenStack. For example,
during Juno development, all code that is part of the Havana and
Icehouse official branches are supported. Upon Juno release, direct
maintenance for Havana would be dropped and maintenance for Icehouse is
added.

NetApp can provide customized support options for production
requirements. For more information, please contact your sales team.

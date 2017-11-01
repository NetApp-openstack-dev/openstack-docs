.. _common-probs:

Common Problems
======================

Common problems listed below are followed by the ``cinder``, ``manila``,
or ``nova`` CLI command and possible reasons for the occurrence of the
problem.

1. Volume create operation fails
--------------------------------

::

    $ cinder create size_gb

-  No space left on the NetApp volume or NetApp volume does not have
   sufficient free space to host the specified OpenStack volume. Here
   NetApp volume refers to a FlexVol volume inside the configured
   Storage Virtual Machine (SVM aka Vserver) for ONTAP
   driver. It refers to NetApp volumes filtered in Cinder through
   parameter ``netapp_pool_name_search_pattern`` or NetApp volumes in
   the configured vFiler unit as parameter ``netapp_vfiler`` or system
   wide NetApp volumes for 7-mode storage system.

-  Cinder API service is down.

-  Cinder scheduler service is down.

-  Cinder scheduler reports sufficient available space on NetApp backend
   but Cinder volume fails to create backend:

   -  The Grizzly-based iSCSI driver for ONTAP and 7-mode
      driver report available space as infinite and hence failure may
      occur when no NetApp volume can host the OpenStack volume.

   -  The Grizzly-based NFS driver ONTAP and 7-mode
      report available space as the sum of available space of all
      configured NFS exports and hence failure may occur when no single
      NetApp volume can host the OpenStack volume of the given size.

   -  The Havana-based iSCSI and NFS driver for ONTAP
      report the available capacity for largest NetApp volume in the
      configured Storage Virtual Machine (SVM aka Vserver). Capacity
      mismatch might fail volume creation.

   -  The Havana-based iSCSI and NFS driver for 7-mode storage system
      report the available capacity as sum of available space of all
      configured NetApp volumes and hence failure may occur when no
      single NetApp volume can host the OpenStack volume of the given
      size.

-  The Havana based NFS driver for ONTAP has the
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

2. Volume create with volume-type operation fails
-------------------------------------------------

::

    $ cinder create --volume-type volume_type size_gb

-  All the reasons mentioned under Item 1 in this appendix.

-  The NetApp backend(s) with available space do not support at least
   one of the extra-specs bound to the volume-type requested. Hence, it
   does not return the extra spec in volume stats call to the Cinder
   scheduler.

-  In ONTAP drivers operation fails due to:

   -  No NetApp volume supports all extra specs bound to the
      volume-type.

   -  The configured storage admin user does not have sufficient
      privileges to query specific storage service catalog features
      required to support the volume-type configuration.

   -  The configured IP address/host name is on a SVM network interface
      but the volume-type support requires cluster wide API access.

3. Volume create from image-id operation fails
----------------------------------------------

::

    $ cinder create --image-id image-id size_gb

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

4. Volume create from image-id with volume-type operation fails
---------------------------------------------------------------

::

    $ cinder create --image-id image-id --volume-type volume_type size_gb

-  All the reasons mentioned under Items 1, 2, and 3 in this appendix.

5. Volume snapshot create operation fails
-----------------------------------------

::

    cinder snapshot-create volume-id

-  The FlexClone license is not installed.

-  The NetApp volume hosting the source OpenStack volume does not have
   sufficient available space.

-  Any maintenance operation by a storage admin directly at the storage
   backend causing LUN or file unavailability.

6. Volume create from snapshot operation fails
----------------------------------------------

::

    $ cinder create --snapshot-id snapshot-id size_gb

-  All reason mentioned under Items 1 & 5 in this appendix.

7. Create cloned volume operation fails
---------------------------------------

::

    $ cinder create --source-volid volume-id size_gb

-  All reason mentioned under Items 1 & 5 in this appendix.

8. Volume attach operation in nova fails
----------------------------------------

::

    nova volume-attach instance-id volume-id path size_gb

-  iSCSI drivers:

   -  The iSCSI license may not be installed.

   -  The iSCSI service on the ``nova-compute`` host may not be running.

   -  The iSCSI portal can not be found. No network interface of type
      iSCSI has been created.

   -  The network is not reachable due to firewall, configuration, or
      transient issues.

9. Volume extend operation fails for Havana based drivers
---------------------------------------------------------

::

    cinder extend volume-id new_size_gb size_gb

-  The NetApp volume hosting the OpenStack volume has insufficient
   space.

-  iSCSI drivers

   -  Reason mentioned under Item 5 in this appendix.

-  NFS drivers

   -  The disk image format of the Cinder volume is not ``raw`` or
      ``qcow2``.

10. Volume upload to image operation fails
------------------------------------------

::

    cinder upload-to-image volume-id image size_gb

-  The Glance service is down.

-  All reasons mentioned under Item 8 in this appendix.

11. Volume backup and restore operation fails
---------------------------------------------

::

    cinder backup-create volume-id size_gb
    cinder backup-restore volume-id size_gb

-  The Cinder backup service is not running.

-  All reasons mentioned under Item 8 in this appendix.

12. Volume migration operation fails
------------------------------------

::

    cinder migrate volume-id host

-  All reasons mentioned under Item 8 in this appendix.

13. Volume extend operation fails with E-Series driver
------------------------------------------------------

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
ascribed limitations. See ":ref:`volume_groups_vs_ddp` for a
comparison of storage pool options.

14. Share replica fails to reach in-sync status
-----------------------------------------------

::

    manila share-replica-list --share-id id

-  The ONTAP controller and the Manila host system times may not be
   synchronized.

-  The controller hosting the active share replica is having trouble
   communicating with the share replica's host via intercluster LIFs.

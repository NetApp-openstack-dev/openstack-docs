Theory of Operation & Deployment Choices
========================================

Glance and Clustered Data ONTAP
-------------------------------

Image Formats - ``raw`` vs. ``QCOW2``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

As previously mentioned, Glance supports a variety of image formats;
however ``raw`` and ``QCOW2`` are the most common. While ``QCOW2`` does
provide some benefits (supports copy-on-write, snapshots, dynamic
expansion) over the ``raw`` format, it should be noted that when images
are copied into Cinder volumes, they are converted into the ``raw``
format once stored on a NetApp backend.

.. note::

   Use of the ``QCOW2`` image format is recommended for ephemeral disks
   due to its inherent benefits when taking instance snapshots. Use of
   the ``raw`` image format can be advantageous when Cinder volumes are
   used as persistent boot disks as a conversion from an alternate
   format to ``raw`` that would be performed by Cinder can be avoided.
   Both ``raw`` and ``QCOW2`` formats respond well to NetApp
   deduplication technology which is often utilized with Glance
   deployments.

NFS with Deduplication
^^^^^^^^^^^^^^^^^^^^^^

Since there is a high probability of duplicate blocks in a repository of
virtual machine images, NetApp highly recommends to enable deduplication
on the FlexVol volume(s) where the images are stored. You can check the
status of deduplication for a particular FlexVol volume by issuing the
``volume efficiency show`` command as seen below.

::

    ::> volume efficiency show -vserver demo-vserver -volume vol2

    Vserver Name: demo-vserver
    Volume Name: vol2
    Volume Path: /vol/vol2
    State: Disabled
    Status: Idle
    Progress: Idle for 00:19:53
    Type: Regular
    Schedule: sun-sat@0
    Efficiency Policy Name: -
    Blocks Skipped Sharing: 0
    Last Operation State: Success
    Last Success Operation Begin:
    Thu Nov 21 14:19:23 UTC 2013
    Last Success Operation End:
    Thu Nov 21 14:20:40 UTC 2013
    Last Operation Begin:
    Thu Nov 21 14:19:23 UTC 2013
    Last Operation End:
    Thu Nov 21 14:20:40 UTC 2013
    Last Operation Size: 0B
    Last Operation Error: -
    Changelog Usage: 0%
    Logical Data Size: 224KB
    Logical Data Limit: 640TB
    Logical Data Percent: 0%
    Queued Job: -
    Stale Fingerprint Percentage: 0
    Compression: false
    Inline Compression: false
    Incompressible Data Detection: false
    Constituent Volume: false
    Compression Quick Check File Size: 524288000

    ::> volume efficiency on -vserver demo-vserver -volume vol2
    Efficiency for volume "vol2" of Vserver "demo-vserver" is enabled.
    Already existing data could be processed by running
    "volume efficiency start -vserver demo-vserver -volume vol2
    -scan-old-data true".

.. _enhanced-instance:

Enhanced Instance Creation
--------------------------

NetApp contributed a capability to enhance instance creation which
focuses on booting tenant-requested VM instances by OpenStack Compute
Service (Nova) using persistent disk images in the shortest possible
time and in the most storage capacity efficient manner possible. This
Enhanced Instance Creation feature (sometimes referred to as Rapid
Cloning) is achieved by leveraging NetApp FlexClone technology, as well
as the NetApp Copy Offload tool. The Enhanced Instance Creation feature
can significantly decrease the time elapsed when the Nova service is
fulfilling image provisioning and boot requests.

The NetApp Copy Offload tool was added in the Icehouse release to enable
Glance images to be efficiently copied to a destination Cinder volume.
When Cinder and Glance are configured to use the NetApp Copy Offload
tool, a controller-side copy is attempted before reverting to
downloading the image from Glance. This improves image provisioning
times while reducing the consumption of bandwidth and CPU cycles on the
host(s) running Glance and Cinder. This is due to the copy operation
being performed completely within the storage cluster.

In addition to NFS, Enhanced Instance Creation is supported for iSCSI
and Fibre Channel by utilizing Cinder's Image-Volume cache feature.
Using Cinder's Image-Volume cache feature provides performance gains by
caching persistent disk image-volumes, in a storage efficient manner,
and utilizing NetApp FlexClone technology to rapidly clone Cinder
volumes from cached image-volumes. For maximum Enhanced Instance
Creation performance though, it is recommended to use the NetApp Copy
Offload tool with NFS.

.. tip::

   The NetApp Copy Offload tool requires that:

   -  The storage system must have Data ONTAP v8.2 or greater
      installed.

   -  To configure the copy offload workflow, enable NFS and export it
      from the SVM.

   -  The vStorage feature must be enabled on each storage virtual
      machine (SVM, also known as a Vserver) that is permitted to
      interact with the copy offload client. To set this feature, you
      can use the
      ``nfs modify -vserver openstack_vs1 -vstorage enabled`` CLI
      command.

Figure 5.1, “Enhanced Instance Creation with NetApp Copy Offload Tool
Flowchart” below describes the workflow associated with the Enhanced
Instance Cloning capability of the NetApp NFS driver when using the
NetApp Copy Offload tool.

.. figure:: ../images/rapid_cloning_flowchart.png
   :alt: Enhanced Instance Creation with NetApp Copy Offload Tool Flowchart
   :width: 5.75000in

   Figure 5.1. Enhanced Instance Creation with NetApp Copy Offload Tool Flowchart

.. note::

   In the second decision point in the flowchart described in
   the figure above, Cinder determines if the source image from Glance
   and the destination volume would reside in the same FlexVol volume.
   This can be achieved by creating a directory structure within the
   NFS export to segment the Glance images from Cinder volumes, and
   appropriately setting the ``filesystem_datastore_dir`` and ``nfs_shares_config``.

.. note::

   Refer to :ref:`eic-fas-nfs` for a complete list of
   configuration changes needed for Enhanced Instance Creation and Copy
   Offload tool.

In order to take advantage of the Enhanced Instance Creation feature,
there are several configuration options that must be appropriately set
in both Cinder and Glance. A summary of these steps is provided below.
The comprehensive checklist is available in the section :ref:`eic-fas-nfs`.

Glance
^^^^^^

Modify the glance configuration file ``/etc/glance/glance-api.conf`` as
follows:

-  Set the ``default_store`` configuration option to ``file``.

-  Set the ``filesystem_store_datadir`` configuration option in the
   ``[glance_store]`` stanza to the path to the NFS export from the
   desired FlexVol volume.

-  Set the ``filesystem_store_file_perm`` configuration option in the
   ``[glance_store]`` stanza to be the file permissions to be assigned
   to new Glance images; alternatively, make sure that the effective
   user of the ``cinder-volume`` process has access to read Glance
   images from the NFS export (e.g. add the ``cinder`` user into the
   ``glance`` group).

-  Set the ``show_image_direct_url`` configuration option to ``True`` in
   the ``[default]`` stanza.

-  Set the ``show_multiple_locations`` configuration option to ``True``
   in the ``[default]`` stanza.

-  Set the ``filesystem_store_metadata_file`` configuration option in
   the ``[glance_store]`` stanza to point to a metadata file. The
   metadata file should contain a JSON object that contains the correct
   information about the NFS export used by Glance, similar to:

   .. code:: ini

       {
           "id": "NetApp1",
           "share_location": "nfs://192.168.0.1/myGlanceExport",
           "mountpoint": "/var/lib/glance/images",
           "type": "nfs"
       }

Cinder Configuration for NFS
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Modify the cinder configuration file ``/etc/cinder/cinder.conf`` as
follows:

-  Set the ``netapp_copyoffload_tool_path`` configuration option in
   Cinder (under the appropriate backend stanza) to the path to the
   NetApp Copy Offload binary as installed on the system running
   ``cinder-volume``.

-  Set the ``glance_api_version`` configuration option to ``2``.

There are three tunable parameters within the Cinder driver
configuration that can affect the behavior of how often space utilized
by the NFS image cache managed by the NetApp unified driver is reclaimed
for other uses: namely, ``thres_avl_size_perc_start``,
``thres_avl_size_perc_stop``, and ``expiry_thres_minutes``. For more
information on these parameters, refer to
":ref:`Table 4.14, “Configuration options for clustered Data ONTAP with NFS”<table-4.14>`".

Cinder Configuration for iSCSI or Fibre Channel
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For iSCSI and Fibre Channel the generic Image-Volume cache feature,
available in Cinder, is utilized. This feature does not have a Copy
Offload tool option.

-  Set the ``cinder_internal_tenant_project_id`` configuration option in
   cinder.conf under the DEFAULT or the appropriate backend stanza.

-  Set the ``cinder_internal_tenant_user_id`` configuration option in
   cinder.conf under the DEFAULT or the appropriate backend stanza.

-  Set the ``image_volume_cache_enabled`` configuration option in
   cinder.conf under either the DEFAULT or the appropriate backend
   stanza.

The first time a Cinder volume is created from a Glance image, the image
is downloaded from Glance by the Cinder Volume service to a temporary
location. Next a Cinder volume is created from the downloaded image by
the Cinder Volume service. NetApp FlexClone technology is then used to
create an image-volume of the Glance image in the same NetApp FlexVol.
When the next volume is created, using the same Glance image ID, the
Cinder volume is created by cloning the existing cached image-volume
using using NetApp's FlexClone technology. More information regarding
Image-Volume cache configuration can be found in the `OpenStack
Image-Volume Cache
Reference. <http://docs.openstack.org/admin-guide/blockstorage-image-volume-cache.html>`__

.. tip::

   Leveraging the “boot from image (creates a new volume)” option in
   Nova, you can leverage the enhanced instance creation capabilities
   described previously. Normally volumes created as a result of this
   option are persistent beyond the life of the instance. However, you
   can select the “delete on terminate” option in combination with the
   “boot from image (creates a new volume)” option to create an
   ephemeral volume while still leveraging the enhanced instance
   creation capabilities described previously. This can provide a
   significantly faster provisioning and boot sequence than the normal
   way that ephemeral disks are provisioned, where a copy of the disk
   image is made from Glance to local storage on the hypervisor node
   where the instance resides.

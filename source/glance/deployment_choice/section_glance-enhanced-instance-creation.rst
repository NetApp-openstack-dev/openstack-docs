.. _enhanced-instance:

Theory of Operation:  Enhanced Instance Creation
================================================

The OpenStack compute service allow creation or persistent instances.
When creating a persistent instance from a disk image, the image is
copied to the backing block storage volume.  This copy operation is
typically time and bandwidth intensive.  When backed by ONTAP, the
NetApp unified driver is capable of performing an enhanced instance
creation.

This Enhanced Instance Creation feature is comprised of two distinct
technologies, namely:

::

  1) NetApp Flexclone technology, sometimes referred to as Rapid Cloning
  2) NetApp Copy Offload tool.

The former technology is supported by Cinder volumes backed by
NFS, iSCSI and FC protocols while the latter is supported only
by Cinder volumes backed by  NFS.

NetApp FlexClone technology
---------------------------

The NetApp FlexClone technology is leveraged to rapidly clone Cinder
volumes from cached image-volumes. As said above, this technology is
leveraged regardless of the underlying protocol.

NetApp Copy Offload Tool
------------------------

The NetApp Copy Offload tool was added in the Icehouse release to enable
Glance images to be efficiently copied to a destination Cinder volume.
When Cinder and Glance are configured to use the NetApp Copy Offload
tool, a controller-side copy is attempted before reverting to
downloading the image from Glance. Copy offload improves image provisioning
times while reducing the consumption of bandwidth and CPU cycles on the
host(s) running Glance and Cinder. This is due to the copy operation
being performed completely within the storage cluster.


.. note::

   For maximum Enhanced Instance Creation performance, it is recommended
   to use the NetApp Copy Offload tool with NFS.

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

.. figure:: ../../images/rapid_cloning_flowchart.png
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

   This is an uncommon configuration

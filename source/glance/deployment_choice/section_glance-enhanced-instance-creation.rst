.. _enhanced-instance:

Theory of Operation:  Enhanced Instance Creation
================================================

The OpenStack compute service allow creation of persistent instances.
When creating a persistent instance from a disk image, the image is
copied to the backing block storage volume.  This copy operation is
typically time and bandwidth intensive.  When backed by ONTAP, the
NetApp unified driver is capable of performing an enhanced instance
creation.

This Enhanced Instance Creation feature is comprised of two distinct
technologies, namely:

::

  1) NetApp Flexclone technology, sometimes referred to as Rapid Cloning
  2) NetApp File Copy technology or NetApp Copy Offload tool.

The former technology is supported by Cinder volumes backed by
NFS, iSCSI and FC protocols while the latter is supported only
by Cinder volumes backed by  NFS.

NetApp FlexClone technology
---------------------------

The NetApp FlexClone technology is leveraged to rapidly clone Cinder
volumes from cached image-volumes. As said above, this technology is
leveraged regardless of the underlying protocol.

NetApp Copy Offload Tool or NetApp File Copy
---------------------------------------------

.. caution::

   The Copy Offload tool is deprecated since Zed release. It will be removed
   soon. Please, prefer the method File Copy technology.

The NetApp Copy Offload tool was added in the Icehouse release, while
File Copy approach in the Zed release. Both enable Glance images to be
efficiently copied to a destination Cinder volume. The last was added to
replace the first one.

When Cinder and Glance are configured to use the NetApp Copy Offload tool,
a controller-side copy is attempted before reverting to downloading the image
from Glance.

Copy offload and File Copy improve instance provisioning times while reducing
the consumption of bandwidth and CPU cycles on the host(s) running Glance and
Cinder. This is due to the copy operation being performed completely within
the storage cluster.

.. note::

   The File Copy approach does not require any setup, the driver has the logic
   internally. Just disabling Copy Offload tool makes the File Copy being used.

.. note::

   The NetApp Copy Offload tool requires that:

   -  The storage system must have ONTAP v8.2 or greater
      installed.

   -  The vStorage feature must be enabled on each storage virtual
      machine (SVM, also known as a Vserver) that is permitted to
      interact with the copy offload client. To set this feature:

      ``nfs modify -vserver openstack_vs1 -vstorage enabled``

Figure 5.1, “Enhanced Instance Creation with NetApp Copy Offload Tool
and File Copy Technology Flowchart” below describes the workflow associated
with the Enhanced Instance Cloning capability of the NetApp NFS driver when using the
deprecated NetApp Copy Offload or File Copy technology.

.. figure:: ../../images/rapid_cloning_flowchart.png
   :alt: Enhanced Instance Creation with NetApp Copy Offload Tool and File Copy Technology Flowchart
   :width: 5.75000in
   :align: center

   Figure 5.1. Enhanced Instance Creation with NetApp Copy Offload Tool and File Copy Technology Flowchart

.. note::

   In the second decision point in the flowchart described in
   the figure above, Cinder determines if the source image from Glance
   and the destination volume would reside in the same FlexVol volume.
   This can be achieved by creating a directory structure within the
   NFS export to segment the Glance images from Cinder volumes, and
   appropriately setting the ``filesystem_datastore_dir`` and ``nfs_shares_config``.

   This is not a best practice.

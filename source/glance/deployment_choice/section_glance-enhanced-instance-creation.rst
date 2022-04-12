.. _enhanced-instance:

Theory of Operation:  Enhanced Instance Creation
================================================

The OpenStack compute service allow creation of persistent instances.
When creating a persistent instance from a disk image, the image is
copied to the backing block storage volume.  This copy operation is
typically time and bandwidth intensive.  When backed by ONTAP, the
NetApp unified driver is capable of performing an enhanced instance
creation.

This Enhanced Instance Creation feature is comprised of one distinct
technology, namely:

::

  1) NetApp Flexclone technology, sometimes referred to as Rapid Cloning

The technology is supported by Cinder volumes backed by
NFS, iSCSI and FC protocols while the latter is supported only
by Cinder volumes backed by  NFS.

NetApp FlexClone technology
---------------------------

The NetApp FlexClone technology is leveraged to rapidly clone Cinder
volumes from cached image-volumes. As said above, this technology is
leveraged regardless of the underlying protocol.


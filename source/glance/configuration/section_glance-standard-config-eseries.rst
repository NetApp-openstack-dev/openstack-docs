.. _glance-eseries-config:

Basic Configuration of Glance with E-Series and EF-Series
=========================================================

E-Series and EF-Series storage systems can alternatively be used as the
backing store for Glance images. An E-Series volume should be created
(with SANtricity specifying the desired RAID level and capacity) and
then mapped to the Glance node. After the volume is visible to the host
it is formatted with a file system, mounted, and a directory structure
created on it. This directory path can be specified as the
``filesystem_store_datadir`` in the Glance configuration file
``/etc/glance/glance-api.conf``.

**Steps:**

1. Create the LUN from a disk pool or volume group using SANtricity and
   map it to the host. Assuming that the volume has been mapped to
   ``/dev/sdc`` on the host, create a partition on the volume and then
   create a filesystem on the partition (e.g. ext4)

::

     $ fdisk /dev/sdc

::

     $ mkfs.ext4 /dev/sdc1

::

     $ mount /dev/sdc1 /mnt/sdc1

::

     $ mkdir /mnt/sdc1/glanceImageStore

2. Edit the Glance configuration file ``glance-api.conf`` so that it
   contains the ``filesystem_store_datadir`` option, and ensure the
   value refers to the Glance image store directory created in the
   previous step.

::

     $ filesystem_store_datadir=/mnt/sdc1/glanceImageStore

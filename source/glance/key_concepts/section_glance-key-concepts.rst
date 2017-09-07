Key Concepts
============

**Image**

A virtual machine image is a single file which contains a virtual disk
that has a bootable operating system installed on it. Virtual machine
images come in different formats, such as ``raw`` and ``qcow2``.

**Store**

An image store is where the virtual machine images managed by Glance
reside on a persistent medium. While Glance currently has support for
many different stores, the most commonly deployed stores are ``file``
and ``swift``.

``file``
    This store refers to a directory on a local file system where the
    ``glance-registry`` service is running. The directory could refer
    to:

    -  locally attached storage

    -  a remote, shared filesystem (e.g. NFS) - see
       the section called ":ref:`glance-ontap-config`", or

    -  a remote block device that has been partitioned and a filesystem
       created within a partition - see
       the section called ":ref:`glance-eseries-config`"`

``swift``
    This store refers to an instance of the OpenStack Object Storage
    service (Swift).

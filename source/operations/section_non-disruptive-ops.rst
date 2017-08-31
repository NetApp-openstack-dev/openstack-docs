Non-Disruptive Operations
=========================

NetApp’s clustered Data ONTAP provides these benefits for non-disruptive
operations:

-  The movement of NetApp FlexVol volumes that contain Cinder volumes
   between different pools of disks (aggregates)

-  The movement of Manila shares between different aggregates

In addition, using NetApp Clustered Data ONTAP or E-Series, OpenStack
environments gain these two key differentiators that would not be
possible with volumes residing on Compute nodes:

-  The ability to evacuate OpenStack instances from a Compute node for
   maintenance and upgrades.

-  The ability to migrate Cinder volumes from one backend to another.
   The source and destination backend can be in the same cluster or in
   different clusters. The following is an example of migrating a Cinder
   volume that is in-use across two clustered Data ONTAP hosts::

    nova instance with an attached cinder volume

    # nova show ubuntu-instance
    +--------------------------------------+--------------------------------------------------------+
    | Property                             | Value                                                  |
    +--------------------------------------+--------------------------------------------------------+
    ...
    | name                                 | ubuntu-instance                                        |
    | os-extended-volumes:volumes_attached | [{"id": "195d2581-d650-4618-ad65-a93ea0c3a89e"}]       |
    | status                               | ACTIVE                                                 |
    ...

    The volume resides in the stlrx300s7-107@cinder-lma#10.250.118.49:/cinder_flexvol_OSTK02 clustered Data ONTAP host.

    # cinder show 195d2581-d650-4618-ad65-a93ea0c3a89e
    +--------------------------------+----------------------------------------------------------------+
    |            Property            |                             Value                              |
    +--------------------------------+----------------------------------------------------------------+
    ...
    |               id               |              195d2581-d650-4618-ad65-a93ea0c3a89e              |
    |     os-vol-host-attr:host      | stlrx300s7-107@cinder-lma#10.250.118.49:/cinder_flexvol_OSTK02 |
    |             status             |                             in-use                             |
    ...
    +--------------------------------+----------------------------------------------------------------+


    Migration of the volume to the stlrx300s7-107@cinder-lmb#10.250.118.51:/cinder_flexvol_OSTK09 clustered Data ONTAP host.

    # cinder migrate 195d2581-d650-4618-ad65-a93ea0c3a89 stlrx300s7-107@cinder-lmb#10.250.118.51:/cinder_flexvol_OSTK09


    Upon Completion of migration

    # cinder show 195d2581-d650-4618-ad65-a93ea0c3a89e
    +--------------------------------+----------------------------------------------------------------+
    |            Property            |                             Value                              |
    +--------------------------------+----------------------------------------------------------------+
    ...
    |               id               |              195d2581-d650-4618-ad65-a93ea0c3a89e              |
    |     os-vol-host-attr:host      | stlrx300s7-107@cinder-lmb#10.250.118.51:/cinder_flexvol_OSTK09 |
    | os-vol-mig-status-attr:migstat |                            success                             |
    |             status             |                             in-use                             |
    ...
    +--------------------------------+----------------------------------------------------------------+


.. note::

   Cinder migration has a dependency on the hypervisor. Please verify
   that updating the following packages will not affect your
   environment before proceeding. These packages are for Red
   Hat/CentOS. For other distributions, please update your hypervisor
   accordingly.
   ``yum install -y qemu-kvm libvirt libvirt-python libguestfs-tools virt–install``

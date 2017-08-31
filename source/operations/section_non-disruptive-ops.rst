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
   volume that is in-use across two clustered Data ONTAP hosts

  Nova instance with an attached cinder volume.  Pay particular attention to
  the value associated with the **os-extended-volumes:volumes_attached** field.

  ::

    [~(keystone_admin)]# nova show ubuntu-instance
    +--------------------------------------+--------------------------------------------------------+
    | Property                             | Value                                                  |
    +--------------------------------------+--------------------------------------------------------+
    ...
    | name                                 | ubuntu-instance                                        |
    | os-extended-volumes:volumes_attached | [{"id": "195d2581-d650-4618-ad65-a93ea0c3a89e"}]       |
    | status                               | ACTIVE                                                 |
    ...

  Issue the **cinder show** command against the volume id shown above, 
  notice that the cinder volume is located at
  stlrx300s7-107@cinder-lma#10.250.118.49:/cinder_flexvol_OSTK02.
  This location is of the form *compute node@backend#nfs server:/flexvol*.

  ::

     [~(keystone_admin)]# cinder show 195d2581-d650-4618-ad65-a93ea0c3a89e
     +--------------------------------+----------------------------------------------------------------+
     |            Property            |                             Value                              |
     +--------------------------------+----------------------------------------------------------------+
     ...
     |               id               |              195d2581-d650-4618-ad65-a93ea0c3a89e              |
     |     os-vol-host-attr:host      | stlrx300s7-107@cinder-lma#10.250.118.49:/cinder_flexvol_OSTK02 |
     |             status             |                             in-use                             |
     ...
     +--------------------------------+----------------------------------------------------------------+

  Get the list of available cinder pools, the target pool will be taken from this list

  ::

     [~(keystone_admin)]# cinder get-pools
     +----------+------------------------------------------------------------------------------+
     | Property | Value                                                                        |
     +----------+------------------------------------------------------------------------------+
     | name     | stlrx300s7-107@cinder-lma#10.250.118.49:/cinder_flexvol_OSTK02               |
     +----------+------------------------------------------------------------------------------+
     +----------+------------------------------------------------------------------------------+
     | Property | Value                                                                        |
     +----------+------------------------------------------------------------------------------+
     | name     | stlrx300s7-107@cinder-lmb#10.250.118.51:/cinder_flexvol_OSTK09               |
     +----------+------------------------------------------------------------------------------+

  Migrate the cinder volume identified above to **stlrx300s7-107@cinder-lmb#10.250.118.51:/cinder_flexvol_OSTK09**.

  ::

    [~(keystone_admin)]# cinder migrate 195d2581-d650-4618-ad65-a93ea0c3a89e \
                                        stlrx300s7-107@cinder-lmb#10.250.118.51:/cinder_flexvol_OSTK09

  Upon Completion of migration, note that the cinder volume has migrated as specified.

  ::

    [~(keystone_admin)]# cinder show 195d2581-d650-4618-ad65-a93ea0c3a89e
    +--------------------------------+----------------------------------------------------------------+
    |            Property            |                             Value                              |
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

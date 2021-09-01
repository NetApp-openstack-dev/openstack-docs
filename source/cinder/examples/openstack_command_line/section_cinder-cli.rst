.. _cinder-cli:

Cinder Command Line Interface (CLI)
===================================

Cinder Service Verification
---------------------------

In this section, we use the Cinder CLI to verify that the configuration
presented in the section called ":ref:`cinder-conf`"
has been properly initialized by Cinder.

::

    stack@ostk-controller:~/$ cinder service-list
    +------------------+--------------------------------+------+---------+-------+------------------------+-----------------+
    |      Binary      |            Host                | Zone |  Status | State |         Updated_at     | Disabled Reason |
    +------------------+--------------------------------+------+---------+-------+------------------------+-----------------+
    | cinder-scheduler |         ostk-controller        | nova | enabled |   up  | 2014-05-20T17:14:12.00 |       None      |
    |  cinder-volume   |   ostk-controller@cdot-iscsi   | nova | enabled |   up  | 2014-05-20T17:14:10.00 |       None      |
    |  cinder-volume   |    ostk-controller@cdot-nfs    | nova | enabled |   up  | 2014-05-20T17:14:11.00 |       None      |
    +------------------+--------------------------------+------+---------+-------+------------------------+-----------------+

-  ``ostk-controller@cdot-iscsi`` is the backend defined by the configuration
   stanza ``[cdot-iscsi]``.

-  ``ostk-controller@cdot-nfs`` is the backend defined by the configuration
   stanza ``[cdot-nfs]``.

.. _create-volume:

Creating and Defining Cinder Volume Types
-----------------------------------------

In this section, we create a variety of Cinder volume Types that
leverage both the default capabilities of each driver, as well as the
NetApp specific extra specs described in
:ref:`Table 4.11, “NetApp supported Extra Specs for use with Cinder volume Types”<table-4.11>`

-  The ``iscsi`` type provisions Cinder volumes onto any backend that
   uses the iSCSI storage protocol (in this example, that would be
   ``[cdot-iscsi]``).

-  The ``nfs`` type provisions Cinder volumes onto any backend that uses
   the NFS storage protocol (in this example, that would be
   ``[cdot-nfs]``).

-  The ``gold`` type provisions Cinder volumes onto any pure-SSD pool on
   any backend that has a SnapMirror relationship (in this example, that
   would be ``[cdot-nfs]``, although only one of the four NFS exports
   defined in ``/etc/cinder/nfs_shares`` has this support).

-  The ``silver`` type provisions Cinder volumes onto any backend that
   has deduplication enabled (in this example, that would be
   ``[cdot-nfs]``, although only one of the four NFS exports defined in
   ``/etc/cinder/nfs_shares`` has this support).

-  The ``bronze`` type provisions Cinder volumes onto any backend that
   has compression enabled (in this example, that would be
   ``[cdot-nfs]``, although only one of the four NFS exports defined in
   ``/etc/cinder/nfs_shares`` has this support).

-  The ``encrypted`` type provisions Cinder volumes onto any backend
   that has Flexvol encryption enabled (NVE) (in this example, that
   would be ``[cdot-iscsi]``).

::

    $ cinder type-create iscsi
    +--------------------------------------+-------+
    |                  ID                  |  Name |
    +--------------------------------------+-------+
    | 46cecec0-a040-476c-9475-036ca5577e6a | iscsi |
    +--------------------------------------+-------+

::

    $ cinder type-create nfs
    +--------------------------------------+------+
    |                  ID                  | Name |
    +--------------------------------------+------+
    | 7564ec5c-a81b-4c62-8376-fdcab62037a2 | nfs  |
    +--------------------------------------+------+

::

    $ cinder type-create gold
    +--------------------------------------+------+
    |                  ID                  | Name |
    +--------------------------------------+------+
    | 0ac5c001-d5fa-4fce-a9e3-e2cce7460027 | gold |
    +--------------------------------------+------+

::

    $ cinder type-create silver
    +--------------------------------------+--------+
    |                  ID                  |  Name  |
    +--------------------------------------+--------+
    | f820211a-ee1c-47ff-8f70-2be45112826d | silver |
    +--------------------------------------+--------+

::

    $ cinder type-create bronze
    +--------------------------------------+--------+
    |                  ID                  |  Name  |
    +--------------------------------------+--------+
    | ae110bfc-0f5a-4e93-abe1-1a31856c0ec7 | bronze |
    +--------------------------------------+--------+

::

    $ cinder type-create encrypted
    +--------------------------------------+-----------+
    |                  ID                  |    Name   |
    +--------------------------------------+-----------+
    | a564a421-55aa-238a-a4d3-e1438b4002d1 | encrypted |
    +--------------------------------------+-----------+

::

    $ cinder type-key iscsi set storage_protocol=iSCSI
    $ cinder type-key nfs set storage_protocol=nfs

::

    $ cinder type-key gold set netapp_mirrored=true
    $ cinder type-key gold set netapp_disk_type=SSD
    $ cinder type-key gold set netapp_hybrid_aggregate="<is> False"

::

    $ cinder type-key silver set netapp_dedup=true

::

    $ cinder type-key bronze set netapp_compression=true

::

    $ cinder type-key encrypted set netapp_flexvol_encryption=true

::

    $ cinder extra-specs-list
    +--------------------------------------+-----------+--------------------------------------------+
    |                  ID                  |    Name   |                extra_specs                 |
    +--------------------------------------+-----------+--------------------------------------------+
    | 0ac5c001-d5fa-4fce-a9e3-e2cce7460027 |    gold   | {'netapp_hybrid_aggregate': '<is> False',  |
    |                                      |           |         'netapp_mirrored': 'true',         |
    |                                      |           |           'netapp_disk_type': 'SSD'}       |
    | 46cecec0-a040-476c-9475-036ca5577e6a |   iscsi   |      {u'storage_protocol': u'iSCSI'}       |
    | a564a421-55aa-238a-a4d3-e1438b4002d1 | encrypted | {u'netapp_flexvol_encryption': u'true'}    |
    | 7564ec5c-a81b-4c62-8376-fdcab62037a2 |    nfs    |       {u'storage_protocol': u'nfs'}        |
    | ae110bfc-0f5a-4e93-abe1-1a31856c0ec7 |   bronze  |      {u'netapp_compression': u'true'}      |
    | f820211a-ee1c-47ff-8f70-2be45112826d |   silver  |         {u'netapp_dedup': u'true'}         |
    +--------------------------------------+-----------+--------------------------------------------+

Creating Cinder Volumes with Volume Types
-----------------------------------------

In this section, we create volumes with no type, as well as each of the
previously defined volume types.

::

    $ cinder create --display-name myGold --volume-type gold 1
    +--------------------------------+--------------------------------------+
    |            Property            |                Value                 |
    +--------------------------------+--------------------------------------+
    |          attachments           |                  []                  |
    |       availability_zone        |                 nova                 |
    |            bootable            |                false                 |
    |           created_at           |      2014-05-20T17:23:57.000000      |
    |          description           |                 None                 |
    |           encrypted            |                False                 |
    |               id               | 3678281e-3924-4512-952a-5b89713fac4d |
    |            metadata            |                  {}                  |
    |              name              |                myGold                |
    |     os-vol-host-attr:host      |                 None                 |
    | os-vol-mig-status-attr:migstat |                 None                 |
    | os-vol-mig-status-attr:name_id |                 None                 |
    |  os-vol-tenant-attr:tenant_id  |   f42d5597fb084480a9626c2ca844db3c   |
    |              size              |                  1                   |
    |          snapshot_id           |                 None                 |
    |          source_volid          |                 None                 |
    |             status             |               creating               |
    |            user_id             |   a9ef3a9f935f4761861afb003986bdab   |
    |          volume_type           |                 gold                 |
    +--------------------------------+--------------------------------------+

::

    $ cinder create --display-name mySilver --volume-type silver 1
    +--------------------------------+--------------------------------------+
    |            Property            |                Value                 |
    +--------------------------------+--------------------------------------+
    |          attachments           |                  []                  |
    |       availability_zone        |                 nova                 |
    |            bootable            |                false                 |
    |           created_at           |      2014-05-20T17:24:12.000000      |
    |          description           |                 None                 |
    |           encrypted            |                False                 |
    |               id               | 6dd3e64d-ca02-4156-8532-24294db89329 |
    |            metadata            |                  {}                  |
    |              name              |               mySilver               |
    |     os-vol-host-attr:host      |                 None                 |
    | os-vol-mig-status-attr:migstat |                 None                 |
    | os-vol-mig-status-attr:name_id |                 None                 |
    |  os-vol-tenant-attr:tenant_id  |   f42d5597fb084480a9626c2ca844db3c   |
    |              size              |                  1                   |
    |          snapshot_id           |                 None                 |
    |          source_volid          |                 None                 |
    |             status             |               creating               |
    |            user_id             |   a9ef3a9f935f4761861afb003986bdab   |
    |          volume_type           |                silver                |
    +--------------------------------+--------------------------------------+

::

    $ cinder create --display-name myBronze --volume-type bronze 1
    +--------------------------------+--------------------------------------+
    |            Property            |                Value                 |
    +--------------------------------+--------------------------------------+
    |          attachments           |                  []                  |
    |       availability_zone        |                 nova                 |
    |            bootable            |                false                 |
    |           created_at           |      2014-05-20T17:24:28.000000      |
    |          description           |                 None                 |
    |           encrypted            |                False                 |
    |               id               | 459b388f-ae1d-49bf-9c1d-3fe3b18afad3 |
    |            metadata            |                  {}                  |
    |              name              |               myBronze               |
    |     os-vol-host-attr:host      |                 None                 |
    | os-vol-mig-status-attr:migstat |                 None                 |
    | os-vol-mig-status-attr:name_id |                 None                 |
    |  os-vol-tenant-attr:tenant_id  |   f42d5597fb084480a9626c2ca844db3c   |
    |              size              |                  1                   |
    |          snapshot_id           |                 None                 |
    |          source_volid          |                 None                 |
    |             status             |               creating               |
    |            user_id             |   a9ef3a9f935f4761861afb003986bdab   |
    |          volume_type           |                bronze                |
    +--------------------------------+--------------------------------------+

::

    $ cinder create --display-name myISCSI --volume-type iscsi 1
    +--------------------------------+--------------------------------------+
    |            Property            |                Value                 |
    +--------------------------------+--------------------------------------+
    |          attachments           |                  []                  |
    |       availability_zone        |                 nova                 |
    |            bootable            |                false                 |
    |           created_at           |      2014-05-20T17:25:42.000000      |
    |          description           |                 None                 |
    |           encrypted            |                False                 |
    |               id               | 93ef9627-ac75-46ae-820b-f722765d7828 |
    |            metadata            |                  {}                  |
    |              name              |               myISCSI                |
    |     os-vol-host-attr:host      |                 None                 |
    | os-vol-mig-status-attr:migstat |                 None                 |
    | os-vol-mig-status-attr:name_id |                 None                 |
    |  os-vol-tenant-attr:tenant_id  |   f42d5597fb084480a9626c2ca844db3c   |
    |              size              |                  1                   |
    |          snapshot_id           |                 None                 |
    |          source_volid          |                 None                 |
    |             status             |               creating               |
    |            user_id             |   a9ef3a9f935f4761861afb003986bdab   |
    |          volume_type           |                iscsi                 |
    +--------------------------------+--------------------------------------+

::

    $ cinder create --display-name myNFS --volume-type nfs 1
    +--------------------------------+--------------------------------------+
    |            Property            |                Value                 |
    +--------------------------------+--------------------------------------+
    |          attachments           |                  []                  |
    |       availability_zone        |                 nova                 |
    |            bootable            |                false                 |
    |           created_at           |      2014-05-20T17:26:03.000000      |
    |          description           |                 None                 |
    |           encrypted            |                False                 |
    |               id               | 4ccf1a4c-cfe0-4b35-8435-400547cabcdd |
    |            metadata            |                  {}                  |
    |              name              |                myNFS                 |
    |     os-vol-host-attr:host      |                 None                 |
    | os-vol-mig-status-attr:migstat |                 None                 |
    | os-vol-mig-status-attr:name_id |                 None                 |
    |  os-vol-tenant-attr:tenant_id  |   f42d5597fb084480a9626c2ca844db3c   |
    |              size              |                  1                   |
    |          snapshot_id           |                 None                 |
    |          source_volid          |                 None                 |
    |             status             |               creating               |
    |            user_id             |   a9ef3a9f935f4761861afb003986bdab   |
    |          volume_type           |                 nfs                  |
    +--------------------------------+--------------------------------------+

::

    $ cinder create --display-name myGenericVol 1
    +--------------------------------+--------------------------------------+
    |            Property            |                Value                 |
    +--------------------------------+--------------------------------------+
    |          attachments           |                  []                  |
    |       availability_zone        |                 nova                 |
    |            bootable            |                false                 |
    |           created_at           |      2014-05-20T18:01:02.000000      |
    |          description           |                 None                 |
    |           encrypted            |                False                 |
    |               id               | 12938589-3ca9-49a7-bcd7-003bbcd62895 |
    |            metadata            |                  {}                  |
    |              name              |             myGenericVol             |
    |     os-vol-host-attr:host      |                 None                 |
    | os-vol-mig-status-attr:migstat |                 None                 |
    | os-vol-mig-status-attr:name_id |                 None                 |
    |  os-vol-tenant-attr:tenant_id  |   f42d5597fb084480a9626c2ca844db3c   |
    |              size              |                  1                   |
    |          snapshot_id           |                 None                 |
    |          source_volid          |                 None                 |
    |             status             |               creating               |
    |            user_id             |   a9ef3a9f935f4761861afb003986bdab   |
    |          volume_type           |                 None                 |
    +--------------------------------+--------------------------------------+

::

    $ cinder list
    +--------------------------------------+-----------+--------------+------+-------------+----------+-------------+
    |                  ID                  |   Status  |     Name     | Size | Volume Type | Bootable | Attached to |
    +--------------------------------------+-----------+--------------+------+-------------+----------+-------------+
    | 12938589-3ca9-49a7-bcd7-003bbcd62895 | available | myGenericVol |  1   |     None    |  false   |             |
    | 1f71ccef-781b-4628-b0f7-44030acd8181 | available |   myISCSI    |  1   |    iscsi    |  false   |             |
    | 3678281e-3924-4512-952a-5b89713fac4d | available |    myGold    |  1   |     gold    |  false   |             |
    | 459b388f-ae1d-49bf-9c1d-3fe3b18afad3 | available |   myBronze   |  1   |    bronze   |  false   |             |
    | 4ccf1a4c-cfe0-4b35-8435-400547cabcdd | available |    myNFS     |  1   |     nfs     |  false   |             |
    | 6dd3e64d-ca02-4156-8532-24294db89329 | available |   mySilver   |  1   |    silver   |  false   |             |
    | 93ef9627-ac75-46ae-820b-f722765d7828 | available |   myISCSI    |  1   |    iscsi    |  false   |             |
    +--------------------------------------+-----------+--------------+------+-------------+----------+-------------+

We'll now look at the local NFS mounts that are present on the node that
is running ``cinder-volume`` and look for the volumes that were created
on NFS backends. By mapping the mountpoints to the directories where the
volume files exist, we are able to associate that the volumes were
created in the appropriate FlexVol volume that had the NetApp specific
features enabled that matched the Cinder volume type definitions.

::

    $ mount |grep cinder
    10.63.40.153:/vol2_dedup on /opt/stack/data/cinder/mnt/6fbcc46d69a86a6be25f3df3e6ae55ba type nfs (rw,vers=4,addr=10.63.40.153,clientaddr=192.168.114.157)
    10.63.40.153:/vol3_compressed on /opt/stack/data/cinder/mnt/aac4e6312b50b1fd6ddaf25d8dec8aaa type nfs (rw,vers=4,addr=10.63.40.153,clientaddr=192.168.114.157)
    10.63.40.153:/vol4_mirrored on /opt/stack/data/cinder/mnt/89af08204a543dd0985fa11b16f3d22f type nfs (rw,vers=4,addr=10.63.40.153,clientaddr=192.168.114.157)
    10.63.40.153:/vol5_plain on /opt/stack/data/cinder/mnt/e15a92dcf98a7b3fdb3963e39ed0796f type nfs (rw,vers=4,addr=10.63.40.153,clientaddr=192.168.114.157)
    $ cd /opt/stack/data/cinder/
    $ find . -name volume-\*
    ./mnt/89af08204a543dd0985fa11b16f3d22f/volume-3678281e-3924-4512-952a-5b89713fac4d [1]
    ./mnt/aac4e6312b50b1fd6ddaf25d8dec8aaa/volume-459b388f-ae1d-49bf-9c1d-3fe3b18afad3 [2]
    ./mnt/6fbcc46d69a86a6be25f3df3e6ae55ba/volume-6dd3e64d-ca02-4156-8532-24294db89329 [3]
    ./mnt/6fbcc46d69a86a6be25f3df3e6ae55ba/volume-4ccf1a4c-cfe0-4b35-8435-400547cabcdd [4]

1.  This is the volume of type ``gold`` which was placed on
    ``10.63.40.153:/vol4_mirrored``.

2.  This is the volume of type ``bronze`` which was placed on
    ``10.63.40.153:/vol3_compressed``.

3.  This is the volume of type ``silver`` which was placed on
    ``10.63.40.153:/vol2_dedup``.

4.  This is the volume of type ``nfs`` which was placed on
    ``10.63.40.153:/vol2_dedup``. It could have been placed on
    ``10.63.40.153:/vol3_compressed``, ``10.63.40.153:/vol4_mirrored``,
    or ``10.63.40.153:/vol5_plain`` as any of those destinations would
    have fulfilled the volume type criteria of ``storage_protocol=nfs``.

.. note::

   Note that the volumes of type ``iscsi``, as well
   as the volume created without a type did not appear under the NFS
   mount points because they were created as iSCSI LUNs within the
   NetApp ONTAP systems.

.. _cinder-manage:

Cinder Manage Usage
-------------------

In this section we import an ONTAP iSCSI LUN by specifying it by
name or UUID.

::

    $ cinder get-pools
    +----------+-----------------------+
    | Property |         Value         |
    +----------+-----------------------+
    |   name   | openstack9@iscsi#pool |
    +----------+-----------------------+

::

    $ cinder manage --id-type source-name openstack9@iscsi#pool /vol/vol1/lun1
    +--------------------------------+--------------------------------------+
    |            Property            |                Value                 |
    +--------------------------------+--------------------------------------+
    |          attachments           |                  []                  |
    |       availability_zone        |                 nova                 |
    |            bootable            |                false                 |
    |           created_at           |      2014-08-25T15:11:18.000000      |
    |          description           |                 None                 |
    |           encrypted            |                False                 |
    |               id               | 9a62ce5f-b125-48e8-8c94-79356b27f2a9 |
    |            metadata            |                  {}                  |
    |              name              |                 None                 |
    |     os-vol-host-attr:host      |        openstack9@iscsi#pool         |
    | os-vol-mig-status-attr:migstat |                 None                 |
    | os-vol-mig-status-attr:name_id |                 None                 |
    |  os-vol-tenant-attr:tenant_id  |   8b4ef3cd82f145738ad8195e6bd3942c   |
    |              size              |                  0                   |
    |          snapshot_id           |                 None                 |
    |          source_volid          |                 None                 |
    |             status             |               creating               |
    |            user_id             |   1b1c9e72e33f4a35b73a8e2d43354d1c   |
    |          volume_type           |                 None                 |
    +--------------------------------+--------------------------------------+

::

    $ cinder manage --id-type source-id openstack9@iscsi#pool 013a7fe0-039b-459e-8cc2-7b59c693139d
    +--------------------------------+--------------------------------------+
    |            Property            |                Value                 |
    +--------------------------------+--------------------------------------+
    |          attachments           |                  []                  |
    |       availability_zone        |                 nova                 |
    |            bootable            |                false                 |
    |           created_at           |      2014-08-25T15:13:18.000000      |
    |          description           |                 None                 |
    |           encrypted            |                False                 |
    |               id               | f2c94f4d-adb3-4c3c-a6aa-cb4c52bd2e39 |
    |            metadata            |                  {}                  |
    |              name              |                 None                 |
    |     os-vol-host-attr:host      |        openstack9@iscsi#pool         |
    | os-vol-mig-status-attr:migstat |                 None                 |
    | os-vol-mig-status-attr:name_id |                 None                 |
    |  os-vol-tenant-attr:tenant_id  |   8b4ef3cd82f145738ad8195e6bd3942c   |
    |              size              |                  0                   |
    |          snapshot_id           |                 None                 |
    |          source_volid          |                 None                 |
    |             status             |               creating               |
    |            user_id             |   1b1c9e72e33f4a35b73a8e2d43354d1c   |
    |          volume_type           |                 None                 |
    +--------------------------------+--------------------------------------+

::

    $ cinder list
    +--------------------------------------+----------------+------+------+-------------+----------+-------------+
    |                  ID                  |     Status     | Name | Size | Volume Type | Bootable | Attached to |
    +--------------------------------------+----------------+------+------+-------------+----------+-------------+
    | 9a62ce5f-b125-48e8-8c94-79356b27f2a9 |   available    | None |  1   |     None    |  false   |             |
    +--------------------------------------+----------------+------+------+-------------+----------+-------------+
    | f2c94f4d-adb3-4c3c-a6aa-cb4c52bd2e39 |   available    | None |  1   |     None    |  false   |             |
    +--------------------------------------+----------------+------+------+-------------+----------+-------------+

In this section we import an ONTAP NFS file by specifying its path.

::

    $ cinder get-pools
    +----------+------------------------------+
    | Property |            Value             |
    +----------+------------------------------+
    |   name   | openstack9@nfs#10.0.0.2:/nfs |
    +----------+------------------------------+

::

    $ cinder manage --id-type source-name openstack9@nfs#10.0.0.2:/nfs 10.0.0.2:/nfs/file1
    +--------------------------------+--------------------------------------+
    |            Property            |                Value                 |
    +--------------------------------+--------------------------------------+
    |          attachments           |                  []                  |
    |       availability_zone        |                 nova                 |
    |            bootable            |                false                 |
    |           created_at           |      2014-08-25T15:11:18.000000      |
    |          description           |                 None                 |
    |           encrypted            |                False                 |
    |               id               | f068e1f7-f008-4eb3-8a74-bacb24afb49a |
    |            metadata            |                  {}                  |
    |              name              |                 None                 |
    |     os-vol-host-attr:host      |     openstack9@nfs#10.0.0.2:/nfs     |
    | os-vol-mig-status-attr:migstat |                 None                 |
    | os-vol-mig-status-attr:name_id |                 None                 |
    |  os-vol-tenant-attr:tenant_id  |   8b4ef3cd82f145738ad8195e6bd3942c   |
    |              size              |                  0                   |
    |          snapshot_id           |                 None                 |
    |          source_volid          |                 None                 |
    |             status             |               creating               |
    |            user_id             |   1b1c9e72e33f4a35b73a8e2d43354d1c   |
    |          volume_type           |                 None                 |
    +--------------------------------+--------------------------------------+

::

    $ cinder list
    +--------------------------------------+----------------+------+------+-------------+----------+-------------+
    |                  ID                  |     Status     | Name | Size | Volume Type | Bootable | Attached to |
    +--------------------------------------+----------------+------+------+-------------+----------+-------------+
    | f068e1f7-f008-4eb3-8a74-bacb24afb49a |   available    | None |  1   |     None    |  false   |             |
    +--------------------------------------+----------------+------+------+-------------+----------+-------------+

.. _cinder-unmanage:

Cinder Unmanage Usage
---------------------

In this section we unmanage a Cinder volume by specifying its ID.

::

    $ cinder list
    +--------------------------------------+----------------+------+------+-------------+----------+-------------+
    |                  ID                  |     Status     | Name | Size | Volume Type | Bootable | Attached to |
    +--------------------------------------+----------------+------+------+-------------+----------+-------------+
    | 206a6731-f23b-419d-8131-8bccbbd83647 |   available    | None |  1   |     None    |  false   |             |
    +--------------------------------------+----------------+------+------+-------------+----------+-------------+
    | ad0262e0-bbe6-4b4d-8c36-ea6a361d777a |   available    | None |  1   |     None    |  false   |             |
    +--------------------------------------+----------------+------+------+-------------+----------+-------------+

::

    $ cinder unmanage 206a6731-f23b-419d-8131-8bccbbd83647

::

    $ cinder list
    +--------------------------------------+----------------+------+------+-------------+----------+-------------+
    |                  ID                  |     Status     | Name | Size | Volume Type | Bootable | Attached to |
    +--------------------------------------+----------------+------+------+-------------+----------+-------------+
    | ad0262e0-bbe6-4b4d-8c36-ea6a361d777a |   available    | None |  1   |     None    |  false   |             |
    +--------------------------------------+----------------+------+------+-------------+----------+-------------+

Applying Cinder QoS via the Command Line
----------------------------------------

In this section, we will configure a Cinder volume type, a Cinder QoS
spec, and lastly associate the QoS spec with the volume type.

::

    $ cinder type-create vol_type_qos_demo
    +--------------------------------------+-------------------+
    |                  ID                  |        Name       |
    +--------------------------------------+-------------------+
    | 7b060008-632c-412d-8fdc-a12351f7dfe4 | vol_type_qos_demo |
    +--------------------------------------+-------------------+

::

    $ cinder qos-create qos_demo minIOPS= 50 maxIOPS=100
    +----------+--------------------------------------+
    | Property |                Value                 |
    +----------+--------------------------------------+
    | consumer |               back-end               |
    |    id    | db081cde-1a9a-41bd-a8a3-a0259db7409b |
    |   name   |               qos_demo               |
    |  specs   |              minIOPS: 50             |
    |          |              maxIOPS: 100            |
    +----------+--------------------------------------+

::

    $ cinder qos-associate db081cde-1a9a-41bd-a8a3-a0259db7409b 7b060008-632c-412d-8fdc-a12351f7dfe4

::

    $ cinder qos-list
    +--------------------------------------+----------+----------+----------------------+
    |                  ID                  |   Name   | Consumer |        specs         |
    +--------------------------------------+----------+----------+----------------------+
    | db081cde-1a9a-41bd-a8a3-a0259db7409b | qos_demo | back-end |  minIOPS: 50         |
    |                                      |          |          |  maxIOPS: 100        |
    +--------------------------------------+----------+----------+----------------------+

::

    $ cinder create 1 --volume-type vol_type_qos_demo
    +---------------------------------------+--------------------------------------+
    |                Property               |                Value                 |
    +---------------------------------------+--------------------------------------+
    |              attachments              |                  []                  |
    |           availability_zone           |                 nova                 |
    |                bootable               |                false                 |
    |          consistencygroup_id          |                 None                 |
    |               created_at              |      2015-04-22T13:39:50.000000      |
    |              description              |                 None                 |
    |               encrypted               |                False                 |
    |                   id                  | 66027b97-11d1-4399-b8c6-031ad8e38da0 |
    |                metadata               |                  {}                  |
    |              multiattach              |                False                 |
    |                  name                 |                 None                 |
    |         os-vol-host-attr:host         |                 None                 |
    |     os-vol-mig-status-attr:migstat    |                 None                 |
    |     os-vol-mig-status-attr:name_id    |                 None                 |
    |      os-vol-tenant-attr:tenant_id     |   3149a10c07bd42569bd5094b83aefdfa   |
    |   os-volume-replication:driver_data   |                 None                 |
    | os-volume-replication:extended_status |                 None                 |
    |           replication_status          |               disabled               |
    |                  size                 |                  1                   |
    |              snapshot_id              |                 None                 |
    |              source_volid             |                 None                 |
    |                 status                |               creating               |
    |                user_id                |   322aff449dac4503b7cab8f38440597e   |
    |              volume_type              |          vol_type_qos_demo           |
    +---------------------------------------+--------------------------------------+

After we associate the QoS spec with the volume type, we can use the
volume type just as we did in the section called
:ref:`“Creating and Defining Cinder volume Types”<create-volume>`.
The example below shows how to verify that the QoS policy group has
been created on the NetApp storage controller.

::

    qos policy-group show -policy-group *66027b97-11d1-4399-b8c6-031ad8e38da0*
    Name             Vserver     Class        Wklds Throughput
    ---------------- ----------- ------------ ----- ------------
    openstack-66027b97-11d1-4399-b8c6-031ad8e38da0
                     dustins01   user-defined 1     50-100IOPS

The name of the QoS policy group created on the storage controller
contains the UUID of the Cinder volume that was created previously. This
QoS policy group has been assigned to the file or LUN on the storage
controller to ensure an isolated, independent limit is enforced on a
per-Cinder-volume basis.

Manipulating Cinder Consistency Groups via the Command Line
-----------------------------------------------------------

.. note::

   Support for Consistency groups has been deprecated in Block Storage V3
   API. Only Block Storage V2 API supports consistency groups. Future
   releases will involve a migration of existing consistency group operations
   to use generic volume group operations.

In this section, we will configure a Cinder volume type, associate the
volume type with a backend capable of supporting consistency groups,
create a Cinder consistency group, create a Cinder volume within the
consistency group, take a snapshot of the consistency group, and then
finally create a second consistency group from the snapshot of the first
consistency group.

::

    $ cinder type-create consistency-group-support
    +--------------------------------------+---------------------------+-----------+
    |                  ID                  |            Name           | Is_Public |
    +--------------------------------------+---------------------------+-----------+
    | 313da739-b629-47f6-ba5d-0d5e4ead0635 | consistency-group-support |    True   |
    +--------------------------------------+---------------------------+-----------+

::

    $ cinder type-key consistency-group-support set volume_backend_name=BACKEND_WITH_CG_SUPPORT

::

    $ cinder consisgroup-create consistency-group-support --name cg1
    +-------------------+-------------------------------------------+
    |      Property     |                   Value                   |
    +-------------------+-------------------------------------------+
    | availability_zone |                    nova                   |
    |     created_at    |         2016-02-29T15:57:11.000000        |
    |    description    |                    None                   |
    |         id        |    2cc3d172-af05-421b-babd-01d4cd91078d   |
    |        name       |                    cg1                    |
    |       status      |                 available                 |
    |    volume_types   | [u'313da739-b629-47f6-ba5d-0d5e4ead0635'] |
    +-------------------+-------------------------------------------+

::

    $ cinder create --name vol-in-cg1 --consisgroup-id 2cc3d172-af05-421b-babd-01d4cd91078d --volume-type consistency-group-support 1
    +---------------------------------------+-------------------------------------------+
    |                Property               |                   Value                   |
    +---------------------------------------+-------------------------------------------+
    |              attachments              |                     []                    |
    |           availability_zone           |                    nova                   |
    |                bootable               |                   false                   |
    |          consistencygroup_id          |    2cc3d172-af05-421b-babd-01d4cd91078d   |
    |               created_at              |         2016-02-29T15:59:36.000000        |
    |              description              |                    None                   |
    |               encrypted               |                   False                   |
    |                   id                  |    959e5f9f-67b9-4011-bd60-5dad2ee43200   |
    |                metadata               |                     {}                    |
    |            migration_status           |                    None                   |
    |              multiattach              |                   False                   |
    |                  name                 |                 vol-in-cg1                |
    |         os-vol-host-attr:host         | openstack1@cmodeiSCSI#vol_21082015_132031 |
    |     os-vol-mig-status-attr:migstat    |                    None                   |
    |     os-vol-mig-status-attr:name_id    |                    None                   |
    |      os-vol-tenant-attr:tenant_id     |      b2b6110ec5c3411089e60e928aafbba6     |
    |   os-volume-replication:driver_data   |                    None                   |
    | os-volume-replication:extended_status |                    None                   |
    |           replication_status          |                  disabled                 |
    |                  size                 |                     1                     |
    |              snapshot_id              |                    None                   |
    |              source_volid             |                    None                   |
    |                 status                |                  creating                 |
    |               updated_at              |         2016-02-29T15:59:37.000000        |
    |                user_id                |      12364c2f57ee4d459ae535af100fdf63     |
    |              volume_type              |         consistency-group-support         |
    +---------------------------------------+-------------------------------------------+

::

    $ cinder cgsnapshot-create 2cc3d172-af05-421b-babd-01d4cd91078d --name snap-of-cg1
    +---------------------+--------------------------------------+
    |       Property      |                Value                 |
    +---------------------+--------------------------------------+
    | consistencygroup_id | 2cc3d172-af05-421b-babd-01d4cd91078d |
    |      created_at     |      2016-02-29T16:01:30.000000      |
    |     description     |                 None                 |
    |          id         | cd3770e1-fa59-48a6-ba48-2f3581f2b03b |
    |         name        |             snap-of-cg1              |
    |        status       |               creating               |
    +---------------------+--------------------------------------+

::

    $ cinder consisgroup-create-from-src --name cg2 --cgsnapshot cd3770e1-fa59-48a6-ba48-2f3581f2b03b
    +----------+--------------------------------------+
    | Property |                Value                 |
    +----------+--------------------------------------+
    |    id    | f84529af-e639-477e-a6e7-53dd401ab909 |
    |   name   |                 cg2                  |
    +----------+--------------------------------------+

To delete a consistency group, first make sure that any snapshots of the
consistency group have first been deleted, and that any volumes in the
consistency group have been removed via an update command on the
consistency group.

::

    $ cinder consisgroup-update cg2 --remove-volumes ddb31a53-6550-410c-ba48-a0a912c8ae95

::

    $ cinder delete ddb31a53-6550-410c-ba48-a0a912c8ae95
    Request to delete volume ddb31a53-6550-410c-ba48-a0a912c8ae95 has been accepted.

::

    $ cinder consisgroup-delete cg2

::

    $ cinder cgsnapshot-delete snap-of-cg1

::

    $ cinder consisgroup-update cg1 --remove-volumes 959e5f9f-67b9-4011-bd60-5dad2ee43200

::

    $ cinder delete 959e5f9f-67b9-4011-bd60-5dad2ee43200
    Request to delete volume 959e5f9f-67b9-4011-bd60-5dad2ee43200 has been accepted.

::

    $ cinder consisgroup-delete cg1


Manipulating Cinder Groups via the Command Line
-----------------------------------------------------------
In this section, we will configure a Cinder volume type, associate the
volume type with a backend capable of supporting groups, create a Cinder
group type, create a Cinder group, create a Cinder volume within the group,
take a snapshot of the group, and then finally create a group from the
snapshot of the first group.

.. note::
   Currently only the Block Storage V3 API supports group operations. The
   minimum version for group operations supported by the ONTAP drivers is
   3.14. The API version can be specified with the following CLI flag
   ``--os-volume-api-version 3.14``. Optionally an environment variable can
   be set: ``export OS_VOLUME_API_VERSION=3.14``

.. note::
   The Cinder community plans to migrate existing consistency group operations
   to group operations in an upcoming release. Please review Cinder
   release notes for upgrade instructions prior to using group operations.

.. note::
   The ONTAP volume drivers support the consistent_group_snapshot_enabled
   group type. By default Cinder group snapshots take individual snapshots
   of each Cinder volume in the group. To enable consistency group snapshots set
   ``consistent_group_snapshot_enabled="<is> True"`` in the group type used.
   Be aware that only one consistency group snapshot per storage pool (i.e.
   flexvol) can be performed at a time. Overlapping consistency group snapshot
   operations can fail.

::

    $ cinder type-create volume-support
    +--------------------------------------+----------------+-------------+-----------+
    | ID                                   | Name           | Description | Is_Public |
    +--------------------------------------+----------------+-------------+-----------+
    | 52c62136-4c87-4ec1-9e29-1132e975eab9 | volume-support | -           | True      |
    +--------------------------------------+----------------+-------------+-----------+

::

    $ cinder type-key volume-support set volume_backend_name=BACKEND_WITH_CG_SUPPORT

::

    $ cinder --os-volume-api-version 3.14 group-type-create group-support
    +--------------------------------------+---------------+-------------+
    | ID                                   | Name          | Description |
    +--------------------------------------+---------------+-------------+
    | bc910903-35d8-49cd-842e-77c77c1d52f5 | group-support | -           |
    +--------------------------------------+---------------+-------------+

::

    $ cinder --os-volume-api-version 3.14 group-type-key group-support set consistent_group_snapshot_enabled="<is> True"

::

    $ cinder --os-volume-api-version 3.14 group-create --name group1 group-support volume-support
    +-------------------+-------------------------------------------+
    | Property          | Value                                     |
    +-------------------+-------------------------------------------+
    | availability_zone | nova                                      |
    | created_at        | 2017-09-08T22:24:57.000000                |
    | description       | None                                      |
    | group_snapshot_id | None                                      |
    | group_type        | 5bf45d12-0ea3-4061-b6b9-287965edce41      |
    | id                | 68ea5b1d-0b09-44ae-ad9f-5e6d9672cc93      |
    | name              | group1                                    |
    | source_group_id   | None                                      |
    | status            | creating                                  |
    | volume_types      | [u'0ca68595-7218-4d44-a992-9f6db4b75143'] |
    +-------------------+-------------------------------------------+

::

    $ cinder --os-volume-api-version 3.14 create --name vol-in-group1 --group-id 68ea5b1d-0b09-44ae-ad9f-5e6d9672cc93 --volume-type volume-support 1
    +--------------------------------+--------------------------------------+
    | Property                       | Value                                |
    +--------------------------------+--------------------------------------+
    | attachments                    | []                                   |
    | availability_zone              | nova                                 |
    | bootable                       | false                                |
    | consistencygroup_id            | None                                 |
    | created_at                     | 2017-09-08T22:30:11.000000           |
    | description                    | None                                 |
    | encrypted                      | False                                |
    | group_id                       | 68ea5b1d-0b09-44ae-ad9f-5e6d9672cc93 |
    | id                             | e982211e-1c34-4996-bee4-af30c5661d8a |
    | metadata                       | {}                                   |
    | migration_status               | None                                 |
    | multiattach                    | False                                |
    | name                           | vol-in-group1                        |
    | os-vol-host-attr:host          | None                                 |
    | os-vol-mig-status-attr:migstat | None                                 |
    | os-vol-mig-status-attr:name_id | None                                 |
    | os-vol-tenant-attr:tenant_id   | a9a7c9d88ad34fa889fd3b63c3d03292     |
    | replication_status             | None                                 |
    | size                           | 1                                    |
    | snapshot_id                    | None                                 |
    | source_volid                   | None                                 |
    | status                         | creating                             |
    | updated_at                     | None                                 |
    | user_id                        | f7d1f04baac34064a238a45dc5a6aa1b     |
    | volume_type                    | volume-support                       |
    +--------------------------------+--------------------------------------+

::

    $ cinder --os-volume-api-version 3.14 group-snapshot-create group1 --name group1-snapshot1
    +---------------+--------------------------------------+
    | Property      | Value                                |
    +---------------+--------------------------------------+
    | created_at    | 2017-09-08T22:32:06.000000           |
    | description   | None                                 |
    | group_id      | 68ea5b1d-0b09-44ae-ad9f-5e6d9672cc93 |
    | group_type_id | 5bf45d12-0ea3-4061-b6b9-287965edce41 |
    | id            | 3ac3a4cc-658a-4b1a-96c5-6272756ea60e |
    | name          | group1-snapshot1                     |
    | status        | creating                             |
    +---------------+--------------------------------------+

::

    $ cinder --os-volume-api-version 3.14 group-create-from-src --group-snapshot group1-snapshot1 --name group2
    +----------+--------------------------------------+
    | Property | Value                                |
    +----------+--------------------------------------+
    | id       | 66c4d2a0-13b7-49a2-a144-89fcc4cf3362 |
    | name     | group2                               |
    +----------+--------------------------------------+


Thin Provisioning
-----------------
In this section, we will configure a Cinder volume type, associate
the ``thin_provisioning_support`` attribute and then create a thin
provisioned Cinder volume. To check if the driver configuration
supports Thin Provisioning, refer to ":ref:`over-subscription`".

::

    $ cinder type-create thin
    $ cinder type-key thin set thin_provisioning_support="<is> True"

::

    $ cinder create --name cinder-vol-a --volume-type thin 5000


Revert to Snapshot
------------------
In this section, we will create a new volume, take a snapshot from it and
revert to that last snapshot.

.. note::
   This command is only available starting from Xena release.

.. note::
   You can only revert the volume to the last snapshot taken. If you need to
   revert to an earlier snapshot, you have to delete snapshots until that one
   is the most recent.

.. note::
   The snapshot being reverted to must have the same size of the volume.

::

    $ cinder create --name cinder-vol-1 --volume-type cmodeNFS 1
    +--------------------------------+--------------------------------------+
    | Property                       | Value                                |
    +--------------------------------+--------------------------------------+
    | attachments                    | []                                   |
    | availability_zone              | nova                                 |
    | bootable                       | false                                |
    | consistencygroup_id            | None                                 |
    | created_at                     | 2018-10-15T11:49:59.000000           |
    | description                    | None                                 |
    | encrypted                      | False                                |
    | id                             | c4913fc6-1dc9-4380-8372-9d290c23f32e |
    | metadata                       | {}                                   |
    | migration_status               | None                                 |
    | multiattach                    | False                                |
    | name                           | cinder-vol-1                         |
    | os-vol-host-attr:host          | None                                 |
    | os-vol-mig-status-attr:migstat | None                                 |
    | os-vol-mig-status-attr:name_id | None                                 |
    | os-vol-tenant-attr:tenant_id   | 3810b2bf356f430d9a06019cd9e56cc2     |
    | replication_status             | None                                 |
    | size                           | 1                                    |
    | snapshot_id                    | None                                 |
    | source_volid                   | None                                 |
    | status                         | creating                             |
    | updated_at                     | None                                 |
    | user_id                        | 90d2c8d154594c2eb51929a89474c753     |
    | volume_type                    | cmodeNFS                             |
    +--------------------------------+--------------------------------------+

::

    $ cinder snapshot-create --name cinder-snapshot-1 cinder-vol-1
    +-------------+--------------------------------------+
    | Property    | Value                                |
    +-------------+--------------------------------------+
    | created_at  | 2018-10-20T11:51:11.943346           |
    | description | None                                 |
    | id          | a2dee3cd-d14a-4920-8a73-17a3a8ca8fdc |
    | metadata    | {}                                   |
    | name        | cinder-snapshot-1                    |
    | size        | 1                                    |
    | status      | creating                             |
    | updated_at  | None                                 |
    | volume_id   | c4913fc6-1dc9-4380-8372-9d290c23f32e |
    +-------------+--------------------------------------+

::

    $ cinder --os-volume-api-version=3.62 revert-to-snapshot a2dee3cd-d14a-4920-8a73-17a3a8ca8fdc

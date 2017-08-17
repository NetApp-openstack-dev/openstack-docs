Manila Command Line Interface (CLI)
-----------------------------------

In this section, we use the Manila CLI to verify that the configuration
presented in
`section\_title <#manila.examples.manila_conf.single_svm>`__ has been
properly initialized by Manila.

::

    [stack@scspr0030615001 devstack]$ manila service-list
    +----+------------------+-------------------------------+------+---------+-------+----------------------------+
    | Id | Binary           | Host                          | Zone | Status  | State | Updated_at                 |
    +----+------------------+-------------------------------+------+---------+-------+----------------------------+
    | 1  | manila-scheduler | scspr0030615001               | nova | enabled | up    | 2015-03-25T12:25:12.000000 |
    | 2  | manila-share     | scspr0030615001@cdotSingleSVM | nova | enabled | up    | 2015-03-25T12:25:15.000000 |
    +----+------------------+-------------------------------+------+---------+-------+----------------------------+
                    

In this section, we create a variety of Manila Share Types that leverage
both the default capabilities of each driver, as well as the NetApp
specific extra specs described in `??? <#manila.netapp.extra_specs>`__.

-  The ``general`` type provisions Manila shares onto the cDOT backend
   using all the default settings, including snapshot support.

-  The ``flash`` type provisions Manila shares onto any pool that
   contains only SSD disks within the aggregate.

-  The ``archive`` type provisions Manila shares onto any pool that
   contains SAS drives within the aggregate, and also creates thin
   provisioned FlexVol volumes.

-  The ``default`` type provisions Manila shares onto any pool of any
   driver without share server management and snapshot support.

::

    [stack@scspr0030615001 devstack]$ manila type-create general False
    +--------------------------------------+---------+------------+------------+--------------------------------------+
    | ID                                   | Name    | Visibility | is_default | required_extra_specs                 |
    +--------------------------------------+---------+------------+------------+--------------------------------------+
    | deadeebf-19a2-47b1-9d7f-1c3806cfcb72 | general | public     | -          | driver_handles_share_servers : False |
    +--------------------------------------+---------+------------+------------+--------------------------------------+
    [stack@scspr0030615001 devstack]$ manila type-create flash False
    +--------------------------------------+---------+------------+------------+--------------------------------------+
    | ID                                   | Name    | Visibility | is_default | required_extra_specs                 |
    +--------------------------------------+---------+------------+------------+--------------------------------------+
    | 37fb9f7e-4ffe-4900-8dba-c6d4251e588f | flash   | public     | -          | driver_handles_share_servers : False |
    +--------------------------------------+---------+------------+------------+--------------------------------------+
    [stack@scspr0030615001 devstack]$ manila type-create archive False
    +--------------------------------------+---------+------------+------------+--------------------------------------+
    | ID                                   | Name    | Visibility | is_default | required_extra_specs                 |
    +--------------------------------------+---------+------------+------------+--------------------------------------+
    | 20e4b58d-aab6-42ae-8e9b-8f9d44f17276 | archive | public     | -          | driver_handles_share_servers : False |
    +--------------------------------------+---------+------------+------------+--------------------------------------+

    **Important**

    In the Mitaka and Newton release of OpenStack, snapshot support is
    enabled by default for a newly created share type. Starting with the
    Ocata release, the ``snapshot_support`` extra spec must be set to
    ``True`` in order to allow snapshots for a share type. If the
    'snapshot\_support' extra\_spec is omitted or if it is set to False,
    users would not be able to create snapshots on shares of this share
    type.

    Other snapshot-related extra specs in the Ocata release (and later)
    include:

    -  ``create_share_from_snapshot_support``: Allow the creation of a
       new share from a snapshot

    -  ``revert_to_snapshot_support``: Allow a share to be reverted to
       the most recent snapshot

    If an extra-spec is left unset, it will default to 'False', but a
    newly created share may or may not end up on a backend with the
    associated capability. Set the extra spec explicitly to ``False``,
    if you would like your shares to be created only on backends that do
    not support the associated capabilities. For a table of NetApp
    supported extra specs, refer to
    `??? <#manila.netapp.extra_specs>`__.

::


    [stack@scspr0030615001 devstack]$ manila type-key general set share_backend_name=cdotSingleSVM
    [stack@scspr0030615001 devstack]$ manila type-key general set snapshot_support=True
    [stack@scspr0030615001 devstack]$ manila type-key general set revert_to_snapshot_support=True
    [stack@scspr0030615001 devstack]$ manila type-key general set create_share_from_snapshot_support=True

    [stack@scspr0030615001 devstack]$ manila type-key default set snapshot_support=False

    [stack@scspr0030615001 devstack]$ manila type-key flash set netapp_disk_type=SSD
    [stack@scspr0030615001 devstack]$ manila type-key flash set netapp_hybrid_aggregate="<is> False"

    [stack@scspr0030615001 devstack]$ manila type-key archive set thin_provisioning="<is> True" netapp_disk_type=SAS

    [stack@scspr0030615001 devstack]$ manila extra-specs-list
    +--------------------------------------+---------+--------------------------------------------+
    | ID                                   | Name    | all_extra_specs                            |
    +--------------------------------------+---------+--------------------------------------------+
    | 20e4b58d-aab6-42ae-8e9b-8f9d44f17276 | archive | driver_handles_share_servers : False       |
    |                                      |         | netapp_disk_type : SAS                     |
    |                                      |         | thin_provisioning : <is> True        |
    | 37fb9f7e-4ffe-4900-8dba-c6d4251e588f | flash   | netapp_disk_type : SSD                     |
    |                                      |         | netapp_hybrid_aggregate : <is> False |
    |                                      |         | driver_handles_share_servers : False       |
    | 447732be-4cf2-42b0-83dc-4b6f4ed5368d | default | driver_handles_share_servers : False       |
    |                                      |         | snapshot_support : False                   |
    | deadeebf-19a2-47b1-9d7f-1c3806cfcb72 | general | share_backend_name : cdotSingleSVM         |
    |                                      |         | driver_handles_share_servers : False       |
    |                                      |         | snapshot_support : True                    |
    |                                      |         | revert_to_snapshot_support : True          |
    |                                      |         | create_share_from_snapshot_support : True  |
    +--------------------------------------+---------+--------------------------------------------+
                    

In this section, we create shares with the default type, as well as each
of the previously defined share types.

::

    [stack@scspr0030615001 devstack]$ manila create --name myDefault NFS 1
    +-------------------+--------------------------------------+
    | Property          | Value                                |
    +-------------------+--------------------------------------+
    | status            | creating                             |
    | description       | None                                 |
    | availability_zone | nova                                 |
    | share_network_id  | None                                 |
    | share_server_id   | None                                 |
    | host              | None                                 |
    | snapshot_id       | None                                 |
    | is_public         | False                                |
    | snapshot_support  | False                                |
    | id                | 63bd5bef-298d-4e49-bea0-49a4cfb143f9 |
    | size              | 1                                    |
    | name              | myDefault                            |
    | share_type        | 447732be-4cf2-42b0-83dc-4b6f4ed5368d |
    | created_at        | 2015-03-25T12:44:11.794842           |
    | share_proto       | NFS                                  |
    | project_id        | 5bf3e15106dd4333b1f55742fa08f90e     |
    | metadata          | {}                                   |
    +-------------------+--------------------------------------+

    [stack@scspr0030615001 devstack]$ manila create --name myGeneral --share-type general NFS 1
    +-------------------+--------------------------------------------------------+
    | Property          | Value                                                  |
    +-------------------+--------------------------------------------------------+
    | status                              | creating                             |
    | description                         | None                                 |
    | availability_zone                   | nova                                 |
    | share_network_id                    | None                                 |
    | share_server_id                     | None                                 |
    | host                                | None                                 |
    | snapshot_id                         | None                                 |
    | is_public                           | False                                |
    | snapshot_support                    | True                                 |
    | revert_to_snapshot_support          | True                                 |
    | create_share_from_snapshot_support  | True                                 |
    | id                                  | 95f49ca6-723f-42d0-92f3-4be79c9ad7e6 |
    | size                                | 1                                    |
    | name                                | myGeneral                            |
    | share_type                          | deadeebf-19a2-47b1-9d7f-1c3806cfcb72 |
    | created_at                          | 2015-03-25T12:44:47.223548           |
    | share_proto                         | NFS                                  |
    | project_id                          | 5bf3e15106dd4333b1f55742fa08f90e     |
    | metadata                            | {}                                   |
    +-------------------+--------------------------------------------------------+

    [stack@scspr0030615001 devstack]$ manila create --name myFlash --share-type flash NFS 1
    +-------------------+--------------------------------------+
    | Property          | Value                                |
    +-------------------+--------------------------------------+
    | status            | creating                             |
    | description       | None                                 |
    | availability_zone | nova                                 |
    | share_network_id  | None                                 |
    | share_server_id   | None                                 |
    | host              | None                                 |
    | snapshot_id       | None                                 |
    | is_public         | False                                |
    | id                | ec5d2ddb-4573-4ee1-a1e8-2c8532c68e3d |
    | size              | 1                                    |
    | name              | myFlash                              |
    | share_type        | 37fb9f7e-4ffe-4900-8dba-c6d4251e588f |
    | created_at        | 2015-03-25T12:44:59.374780           |
    | share_proto       | NFS                                  |
    | project_id        | 5bf3e15106dd4333b1f55742fa08f90e     |
    | metadata          | {}                                   |
    +-------------------+--------------------------------------+

    [stack@scspr0030615001 devstack]$ manila create --name myArchive --share-type archive NFS 1
    +-------------------+--------------------------------------+
    | Property          | Value                                |
    +-------------------+--------------------------------------+
    | status            | creating                             |
    | description       | None                                 |
    | availability_zone | nova                                 |
    | share_network_id  | None                                 |
    | share_server_id   | None                                 |
    | host              | None                                 |
    | snapshot_id       | None                                 |
    | is_public         | False                                |
    | id                | e4774a70-3e70-4a7c-ab76-886f010efe0a |
    | size              | 1                                    |
    | name              | myArchive                            |
    | share_type        | 20e4b58d-aab6-42ae-8e9b-8f9d44f17276 |
    | created_at        | 2015-03-25T12:45:11.124722           |
    | share_proto       | NFS                                  |
    | project_id        | 5bf3e15106dd4333b1f55742fa08f90e     |
    | metadata          | {}                                   |
    +-------------------+--------------------------------------+

::

    [stack@scspr0030615001 devstack]$ manila list
    +--------------------------------------+-----------+------+-------------+-----------+-----------+-----------------+-------------------------------------+-------------------+
    | ID                                   | Name      | Size | Share Proto | Status    | Is Public | Share Type Name | Host                                | Availability Zone |
    +--------------------------------------+-----------+------+-------------+-----------+-----------+-----------------+-------------------------------------+-------------------+
    | 63bd5bef-298d-4e49-bea0-49a4cfb143f9 | myDefault | 1    | NFS         | available | False     | default         | scspr0030615001@cdotSingleSVM#aggr1 | nova              |
    | 95f49ca6-723f-42d0-92f3-4be79c9ad7e6 | myGeneral | 1    | NFS         | available | False     | general         | scspr0030615001@cdotSingleSVM#aggr1 | nova              |
    | e4774a70-3e70-4a7c-ab76-886f010efe0a | myArchive | 1    | NFS         | available | False     | archive         | scspr0030615001@cdotSingleSVM#aggr1 | nova              |
    | ec5d2ddb-4573-4ee1-a1e8-2c8532c68e3d | myFlash   | 1    | NFS         | error     | False     | flash           | None                                | nova              |
    +--------------------------------------+-----------+------+-------------+-----------+-----------+-----------------+-------------------------------------+-------------------+

We'll now look at the CLI output from the Data ONTAP cluster to see what
FlexVol volumes were created for the Manila share objects, as well as
the provisioning strategy (thin or thick) for each share. Note how the
name of the FlexVol volume corresponds to the share UUID as defined by
Manila. You can see that share ``e4774a70_3e70_4a7c_ab76_886f010efe0a``
was thin provisioned, as declared by the ``archive`` share type. The
rest of the shares were thick provisioned. Also note that the share of
type ``myFlash`` failed to create, as this SVM does not have any
aggregates with SSD drives, as seen in the command output below.

::

    cluster-1::> volume show -vserver manila-vserver
    Vserver   Volume       Aggregate    State      Type       Size  Available Used%
    --------- ------------ ------------ ---------- ---- ---------- ---------- -----
    manila-vserver
              share_63bd5bef_298d_4e49_bea0_49a4cfb143f9
                           aggr1        online     RW          1GB    972.7MB    5%
    manila-vserver
              share_95f49ca6_723f_42d0_92f3_4be79c9ad7e6
                           aggr1        online     RW          1GB    972.7MB    5%
    manila-vserver
              share_e4774a70_3e70_4a7c_ab76_886f010efe0a
                           aggr1        online     RW          1GB    972.7MB    5%
    manila-vserver
              vol1         aggr1        online     RW         20MB    18.88MB    5%
    4 entries were displayed.

    cluster-1::>

    cluster-1::> volume show -vserver manila-vserver -space-guarantee none
    Vserver   Volume       Aggregate    State      Type       Size  Available Used%
    --------- ------------ ------------ ---------- ---- ---------- ---------- -----
    manila-vserver
              share_e4774a70_3e70_4a7c_ab76_886f010efe0a
                           aggr1        online     RW          1GB    972.7MB    5%

    cluster-1::> volume show -vserver manila-vserver -space-guarantee volume
    Vserver   Volume       Aggregate    State      Type       Size  Available Used%
    --------- ------------ ------------ ---------- ---- ---------- ---------- -----
    manila-vserver
              share_63bd5bef_298d_4e49_bea0_49a4cfb143f9
                           aggr1        online     RW          1GB    972.7MB    5%
    manila-vserver
              share_95f49ca6_723f_42d0_92f3_4be79c9ad7e6
                           aggr1        online     RW          1GB    972.7MB    5%
    manila-vserver
              vol1         aggr1        online     RW         20MB    18.88MB    5%
    3 entries were displayed.

    cluster-1::>

    cluster-1::> disk show -type SSD
    There are no entries matching your query.
                    

We'll now add access rules for any IP-connected client to mount these
NFS shares with full read/write privileges.

::

    [stack@scspr0030615001 devstack]$ manila access-allow 63bd5bef-298d-4e49-bea0-49a4cfb143f9 ip 0.0.0.0/0
    +--------------+--------------------------------------+
    | Property     | Value                                |
    +--------------+--------------------------------------+
    | share_id     | 63bd5bef-298d-4e49-bea0-49a4cfb143f9 |
    | deleted      | False                                |
    | created_at   | 2015-03-25T13:25:24.577736           |
    | updated_at   | None                                 |
    | access_type  | ip                                   |
    | access_to    | 0.0.0.0/0                            |
    | access_level | rw                                   |
    | state        | new                                  |
    | deleted_at   | None                                 |
    | id           | c400bdd7-7e4f-49a4-b73d-5aa417af95c3 |
    +--------------+--------------------------------------+
    [stack@scspr0030615001 devstack]$ manila access-allow 95f49ca6-723f-42d0-92f3-4be79c9ad7e6 ip 0.0.0.0/0
    +--------------+--------------------------------------+
    | Property     | Value                                |
    +--------------+--------------------------------------+
    | share_id     | 95f49ca6-723f-42d0-92f3-4be79c9ad7e6 |
    | deleted      | False                                |
    | created_at   | 2015-03-25T13:25:47.417271           |
    | updated_at   | None                                 |
    | access_type  | ip                                   |
    | access_to    | 0.0.0.0/0                            |
    | access_level | rw                                   |
    | state        | new                                  |
    | deleted_at   | None                                 |
    | id           | 09f8f699-1cec-4519-8aaa-a30d346ad54c |
    +--------------+--------------------------------------+
    [stack@scspr0030615001 devstack]$ manila access-allow e4774a70-3e70-4a7c-ab76-886f010efe0a ip 0.0.0.0/0
    +--------------+--------------------------------------+
    | Property     | Value                                |
    +--------------+--------------------------------------+
    | share_id     | e4774a70-3e70-4a7c-ab76-886f010efe0a |
    | deleted      | False                                |
    | created_at   | 2015-03-25T13:26:03.344004           |
    | updated_at   | None                                 |
    | access_type  | ip                                   |
    | access_to    | 0.0.0.0/0                            |
    | access_level | rw                                   |
    | state        | new                                  |
    | deleted_at   | None                                 |
    | id           | d0565115-8369-455e-ad8f-3dd7c56037ea |
    +--------------+--------------------------------------+

We'll now list the export location(s) for one of the new shares to see
its network path. There may be multiple export locations for a given
share, at least one of which should be listed as preferred; clients
should use the preferred path for optimum performance.

::

    [stack@scspr0030615001 devstack]$ manila share-export-location-list 63bd5bef-298d-4e49-bea0-49a4cfb143f9 --columns Path,Preferred
    +-------------------------------------------------------------+-----------+
    | Path                                                        | Preferred |
    +-------------------------------------------------------------+-----------+
    | 192.168.228.110:/share_6fae2eb7_9eea_4a0f_b215_1f405dbcc4d4 | True      |
    +-------------------------------------------------------------+-----------+

As previously noted, creation of a CIFS share requires the co-deployment
of one of three security services (LDAP, Active Directory, or Kerberos).
This section demonstrates the share network and security service setup
necessary before creating the CIFS share.

::

    manila share-network-create --neutron-net-id <neutron-net-id> --neutron-subnet-id <neutron-subnet-id> --name <share_network_name>

    manila security-service-create active_directory --dns-ip <dns_ip> --domain <dns_domain> --user <user_name> --password <password> --name <security_service_name>

    +-------------+--------------------------------------+
    | Property    | Value                                |
    +-------------+--------------------------------------+
    | status      | new                                  |
    | domain      | stack1.netapp.com                    |
    | password    | secrete                              |
    | name        | ac10                                 |
    | dns_ip      | 10.250.XXX.XXX                       |
    | created_at  | 2015-10-15T19:02:19.309255           |
    | updated_at  | None                                 |
    | server      | None                                 |
    | user        | Administrator                        |
    | project_id  | b568323d304046d8a8abaa8e822f17e3     |
    | type        | active_directory                     |
    | id          | 259a203d-9e11-49cd-83d7-e5c986c01221 |
    | description | None                                 |
    +-------------+--------------------------------------+

    manila share-network-security-service-add <share_network> <security_service>

    manila create CIFS 1 --share-network <share_network_name> --share-type general

    +-----------------------------+--------------------------------------+
    | Property                    | Value                                |
    +-----------------------------+--------------------------------------+
    | status                      | None                                 |
    | share_type_name             | general                              |
    | description                 | None                                 |
    | availability_zone           | None                                 |
    | share_network_id            | None                                 |
    | share_server_id             | None                                 |
    | host                        | None                                 |
    | snapshot_id                 | None                                 |
    | is_public                   | False                                |
    | task_state                  | None                                 |
    | snapshot_support            | True                                 |
    | id                          | 4b4e512a-a1dd-45e6-a6c2-5eed978a29f0 |
    | size                        | 1                                    |
    | name                        | None                                 |
    | share_type                  | deadeebf-19a2-47b1-9d7f-1c3806cfcb72 |
    | created_at                  | 2015-10-19T15:10:30.314544           |
    | share_proto                 | CIFS                                 |
    | consistency_group_id        | None                                 |
    | source_cgsnapshot_member_id | None                                 |
    | project_id                  | b568323d304046d8a8abaa8e822f17e3     |
    | metadata                    | {}                                   |
    +-----------------------------+--------------------------------------+

In this section, we use the admin-only ``manage`` command to bring
storage resources under Manila management. A share is a Data ONTAP
FlexVol, and we must tell Manila which host, backend and pool contain
the FlexVol. It may be useful to list the Manila pools to get the
correct format. Also note that the FlexVol must be specified in the
format Manila uses to report share export locations. For NFS this format
is ``address:/path``, where ``address`` is that of any NFS LIF where the
FlexVol is accessible and ``path`` is the junction path of the FlexVol.
For CIFS this format is ``\\address\name``, where ``address`` is that of
any CIFS LIF where the FlexVol is accessible and ``name`` is the name of
the FlexVol.

::

    [stack@scspr0030615001 devstack]$ manila pool-list
    +-------------------------------------+---------+----------------------+--------+
    | Name                                | Host    | Backend              | Pool   |
    +-------------------------------------+---------+----------------------+--------+
    | liberty@cmode_single_svm_nfs#manila | liberty | cmode_single_svm_nfs | manila |
    +-------------------------------------+---------+----------------------+--------+
                    

::

    [stack@scspr0030615001 devstack]$ manila manage liberty@cmode_single_svm_nfs#manila NFS 192.168.228.102:/myvol
    +-------------------+--------------------------------------+
    | Property          | Value                                |
    +-------------------+--------------------------------------+
    | status            | manage_starting                      |
    | description       | None                                 |
    | availability_zone | None                                 |
    | share_network_id  | None                                 |
    | export_locations  | 192.168.228.102:/myvol               |
    | share_server_id   | None                                 |
    | host              | liberty@cmode_single_svm_nfs#manila  |
    | snapshot_id       | None                                 |
    | is_public         | False                                |
    | snapshot_support  | False                                |
    | id                | 6e42c910-67a8-47fd-885f-b03d1756675f |
    | size              | None                                 |
    | name              | None                                 |
    | share_type        | default                              |
    | created_at        | 2015-08-13T20:27:09.000000           |
    | share_proto       | NFS                                  |
    | project_id        | 75dbed01579f4a7e8df2878de25fbc49     |
    | metadata          | {}                                   |
    +-------------------+--------------------------------------+
                    

::

    [stack@scspr0030615001 devstack]$ manila show 6e42c910-67a8-47fd-885f-b03d1756675f
    +-------------------+-------------------------------------------------------------+
    | Property          | Value                                                       |
    +-------------------+-------------------------------------------------------------+
    | status            | available                                                   |
    | description       | None                                                        |
    | availability_zone | None                                                        |
    | share_network_id  | None                                                        |
    | export_locations  | 192.168.228.102:/share_6e42c910_67a8_47fd_885f_b03d1756675f |
    |                   | 10.0.0.100:/share_6e42c910_67a8_47fd_885f_b03d1756675f      |
    | share_server_id   | None                                                        |
    | host              | liberty@cmode_single_svm_nfs#manila                         |
    | snapshot_id       | None                                                        |
    | is_public         | False                                                       |
    | snapshot_support  | False                                                       |
    | id                | 6e42c910-67a8-47fd-885f-b03d1756675f                        |
    | size              | 1                                                           |
    | name              | None                                                        |
    | share_type        | default                                                     |
    | created_at        | 2015-08-13T20:27:09.000000                                  |
    | share_proto       | NFS                                                         |
    | project_id        | 75dbed01579f4a7e8df2878de25fbc49                            |
    | metadata          | {}                                                          |
    +-------------------+-------------------------------------------------------------+
                    

    **Important**

    FlexVols that are part of a snapmirror relationship cannot be
    brought under Manila's management. Snapmirror relationships must be
    removed before attempting to ``manage`` the FlexVol.

We'll now remove a share from Manila management using the admin-only
``unmanage`` CLI command.

::

    [stack@scspr0030615001 devstack]$ manila unmanage 6e42c910-67a8-47fd-885f-b03d1756675f
                

In this section, we'll create and work with consistency groups and
consistency group (CG) snapshots. First we'll list the share types and
create a CG using one of the existing types.

::

    $ manila type-list
    +--------------------------------------+---------+------------+------------+--------------------------------------+
    | ID                                   | Name    | Visibility | is_default | required_extra_specs                 |
    +--------------------------------------+---------+------------+------------+--------------------------------------+
    | 08d3b20f-3685-4f83-ba4f-efe9276e922c | zoom    | public     | -          | driver_handles_share_servers : False |
    | 30abd1a6-0f5f-426b-adb4-13e0062d3183 | default | public     | YES        | driver_handles_share_servers : False |
    | d7f70347-7464-4297-8d8e-12fa13e64775 | nope    | public     | -          | driver_handles_share_servers : False |
    +--------------------------------------+---------+------------+------------+--------------------------------------+

    $ manila cg-create --name cg_1 --description "cg_1 consistency group" --share_type "type_1"
    +----------------------+--------------------------------------+
    | Property             | Value                                |
    +----------------------+--------------------------------------+
    | status               | creating                             |
    | description          | cg_1 consistency group               |
    | source_cgsnapshot_id | None                                 |
    | created_at           | 2015-08-18T17:36:36.088532           |
    | share_network_id     | None                                 |
    | share_server_id      | None                                 |
    | host                 | None                                 |
    | project_id           | f55f22cc74b347f6992a9f969eeb40a1     |
    | share_types          | 45ff1d79-0dd7-4309-b259-652c5f9e3b41 |
    | id                   | 9379f22c-a5c0-4455-bd25-ad373e93d7c3 |
    | name                 | cg_1                                 |
    +----------------------+--------------------------------------+

    $ manila cg-list
    +--------------------------------------+------+------------------------+-----------+
    | id                                   | name | description            | status    |
    +--------------------------------------+------+------------------------+-----------+
    | 9379f22c-a5c0-4455-bd25-ad373e93d7c3 | cg_1 | cg_1 consistency group | available |
    +--------------------------------------+------+------------------------+-----------+

    $ manila cg-show 9379f22c-a5c0-4455-bd25-ad373e93d7c3
    +----------------------+--------------------------------------+
    | Property             | Value                                |
    +----------------------+--------------------------------------+
    | status               | available                            |
    | description          | cg_1 consistency group               |
    | source_cgsnapshot_id | None                                 |
    | created_at           | 2015-08-18T17:36:36.000000           |
    | share_network_id     | None                                 |
    | share_server_id      | None                                 |
    | host                 | ubuntu@cmode_single_svm_nfs#aggr1    |
    | project_id           | f55f22cc74b347f6992a9f969eeb40a1     |
    | share_types          | 45ff1d79-0dd7-4309-b259-652c5f9e3b41 |
    | id                   | 9379f22c-a5c0-4455-bd25-ad373e93d7c3 |
    | name                 | cg_1                                 |
    +----------------------+--------------------------------------+

Next we'll create two shares in the new consistency group.

::

    $ manila create --name share_1 --consistency-group "cg_1" --share_type "type_1" NFS 1
    +-----------------------------+--------------------------------------+
    | Property                    | Value                                |
    +-----------------------------+--------------------------------------+
    | status                      | creating                             |
    | description                 | None                                 |
    | availability_zone           | nova                                 |
    | share_network_id            | None                                 |
    | share_server_id             | None                                 |
    | host                        | None                                 |
    | snapshot_id                 | None                                 |
    | is_public                   | False                                |
    | id                          | 01eab865-a15b-4443-84e9-68b9c5fc3634 |
    | size                        | 1                                    |
    | name                        | None                                 |
    | share_type                  | type_1                               |
    | created_at                  | 2015-08-18T17:40:16.996290           |
    | share_proto                 | NFS                                  |
    | consistency_group_id        | 9379f22c-a5c0-4455-bd25-ad373e93d7c3 |
    | source_cgsnapshot_member_id | None                                 |
    | project_id                  | f55f22cc74b347f6992a9f969eeb40a1     |
    | metadata                    | {}                                   |
    +-----------------------------+--------------------------------------+

    $ manila create --name share_2 --consistency-group "cg_1" --share_type "type_1" NFS 1
    +-----------------------------+--------------------------------------+
    | Property                    | Value                                |
    +-----------------------------+--------------------------------------+
    | status                      | creating                             |
    | description                 | None                                 |
    | availability_zone           | nova                                 |
    | share_network_id            | None                                 |
    | share_server_id             | None                                 |
    | host                        | None                                 |
    | snapshot_id                 | None                                 |
    | is_public                   | False                                |
    | id                          | f60520d9-73e4-4755-a4e7-cec027d0dbad |
    | size                        | 1                                    |
    | name                        | share_2                              |
    | share_type                  | type_1                               |
    | created_at                  | 2015-08-18T17:44:48.290880           |
    | share_proto                 | NFS                                  |
    | consistency_group_id        | 9379f22c-a5c0-4455-bd25-ad373e93d7c3 |
    | source_cgsnapshot_member_id | None                                 |
    | project_id                  | f55f22cc74b347f6992a9f969eeb40a1     |
    | metadata                    | {}                                   |
    +-----------------------------+--------------------------------------+

Next we'll create two CG snapshots of the new consistency group.

::

    $ manila cg-snapshot-create --name snapshot_1 --description 'first snapshot of cg-1' 'cg_1'
    +----------------------+--------------------------------------+
    | Property             | Value                                |
    +----------------------+--------------------------------------+
    | status               | creating                             |
    | name                 | snapshot_1                           |
    | created_at           | 2015-08-18T17:49:11.441552           |
    | consistency_group_id | 9379f22c-a5c0-4455-bd25-ad373e93d7c3 |
    | project_id           | f55f22cc74b347f6992a9f969eeb40a1     |
    | id                   | 9fc2c246-b5dc-4cae-97b5-f136aff6abdc |
    | description          | first snapshot of cg-1               |
    +----------------------+--------------------------------------+

    $ manila cg-snapshot-list
    +--------------------------------------+------------+------------------------+-----------+
    | id                                   | name       | description            | status    |
    +--------------------------------------+------------+------------------------+-----------+
    | 9fc2c246-b5dc-4cae-97b5-f136aff6abdc | snapshot_1 | first snapshot of cg-1 | available |
    +--------------------------------------+------------+------------------------+-----------+

    $ manila cg-snapshot-show 'snapshot_1'
    +----------------------+--------------------------------------+
    | Property             | Value                                |
    +----------------------+--------------------------------------+
    | status               | available                            |
    | name                 | snapshot_1                           |
    | created_at           | 2015-08-18T17:49:12.000000           |
    | consistency_group_id | 9379f22c-a5c0-4455-bd25-ad373e93d7c3 |
    | project_id           | f55f22cc74b347f6992a9f969eeb40a1     |
    | id                   | 9fc2c246-b5dc-4cae-97b5-f136aff6abdc |
    | description          | first snapshot of cg-1               |
    +----------------------+--------------------------------------+

    $ manila cg-snapshot-create --name snapshot_2 --description 'second snapshot of cg-1' 'cg_1'
    +----------------------+--------------------------------------+
    | Property             | Value                                |
    +----------------------+--------------------------------------+
    | status               | creating                             |
    | name                 | snapshot_2                           |
    | created_at           | 2015-08-18T17:51:01.319632           |
    | consistency_group_id | 9379f22c-a5c0-4455-bd25-ad373e93d7c3 |
    | project_id           | f55f22cc74b347f6992a9f969eeb40a1     |
    | id                   | c671dcc5-10bf-4445-b96e-b12723ade738 |
    | description          | second snapshot of cg-1              |
    +----------------------+--------------------------------------+

    $ manila cg-snapshot-list
    +--------------------------------------+------------+-------------------------+-----------+
    | id                                   | name       | description             | status    |
    +--------------------------------------+------------+-------------------------+-----------+
    | 9fc2c246-b5dc-4cae-97b5-f136aff6abdc | snapshot_1 | first snapshot of cg-1  | available |
    | c671dcc5-10bf-4445-b96e-b12723ade738 | snapshot_2 | second snapshot of cg-1 | available |
    +--------------------------------------+------------+-------------------------+-----------+

Finally we'll create a new CG from one of the CG snapshots we created
above.

::

    $ manila cg-create --name cg_3 --source-cgsnapshot-id 9fc2c246-b5dc-4cae-97b5-f136aff6abdc
    +----------------------+--------------------------------------+
    | Property             | Value                                |
    +----------------------+--------------------------------------+
    | status               | creating                             |
    | description          | None                                 |
    | source_cgsnapshot_id | 9fc2c246-b5dc-4cae-97b5-f136aff6abdc |
    | created_at           | 2015-08-18T19:26:46.419836           |
    | share_network_id     | None                                 |
    | share_server_id      | None                                 |
    | host                 | ubuntu@cmode_single_svm_nfs#aggr1    |
    | project_id           | f55f22cc74b347f6992a9f969eeb40a1     |
    | share_types          | 45ff1d79-0dd7-4309-b259-652c5f9e3b41 |
    | id                   | d4a282dc-d28d-4d51-b0b0-64766cc099c6 |
    | name                 | cg_3                                 |
    +----------------------+--------------------------------------+

In this section, we'll create and work with share replicas. First we'll
create a share type that supports replication.

::

    $ manila type-create replication false
    +----------------------+--------------------------------------+
    | Property             | Value                                |
    +----------------------+--------------------------------------+
    | required_extra_specs | driver_handles_share_servers : False |
    | Name                 | replication                          |
    | Visibility           | public                               |
    | is_default           | -                                    |
    | ID                   | ce1709ef-0b20-4cbf-9fc0-2b75adfee9b8 |
    +----------------------+--------------------------------------+

    $ manila type-key replication set replication_type=dr snapshot_support=True

Next we'll create a share.

::

    $ manila create NFS 1 --share-type replication
    +-----------------------------+--------------------------------------+
    | Property                    | Value                                |
    +-----------------------------+--------------------------------------+
    | status                      | creating                             |
    | share_type_name             | replication                          |
    | description                 | None                                 |
    | availability_zone           | None                                 |
    | share_network_id            | None                                 |
    | share_server_id             | None                                 |
    | host                        |                                      |
    | access_rules_status         | active                               |
    | snapshot_id                 | None                                 |
    | is_public                   | False                                |
    | task_state                  | None                                 |
    | snapshot_support            | True                                 |
    | id                          | f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc |
    | size                        | 1                                    |
    | name                        | None                                 |
    | share_type                  | ce1709ef-0b20-4cbf-9fc0-2b75adfee9b8 |
    | has_replicas                | False                                |
    | replication_type            | dr                                   |
    | created_at                  | 2016-03-23T18:16:22.000000           |
    | share_proto                 | NFS                                  |
    | consistency_group_id        | None                                 |
    | source_cgsnapshot_member_id | None                                 |
    | project_id                  | 3d1d93550b1448f094389d6b5df9659e     |
    | metadata                    | {}                                   |
    +-----------------------------+--------------------------------------+

    manila show f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc
    +-----------------------------+-------------------------------------------------------------------+
    | Property                    | Value                                                             |
    +-----------------------------+-------------------------------------------------------------------+
    | status                      | available                                                         |
    | share_type_name             | replication                                                       |
    | description                 | None                                                              |
    | availability_zone           | nova                                                              |
    | share_network_id            | None                                                              |
    | export_locations            |                                                                   |
    |                             | path = 172.20.124.230:/share_11265e8a_200c_4e0a_a40f_b7a1117001ed |
    |                             | preferred = True                                                  |
    |                             | is_admin_only = False                                             |
    |                             | id = d9634102-e859-42ab-842e-687c209067e3                         |
    |                             | share_instance_id = 11265e8a-200c-4e0a-a40f-b7a1117001ed          |
    | share_server_id             | None                                                              |
    | host                        | openstack2@cmodeSSVMNFS#aggr3                                     |
    | access_rules_status         | active                                                            |
    | snapshot_id                 | None                                                              |
    | is_public                   | False                                                             |
    | task_state                  | None                                                              |
    | snapshot_support            | True                                                              |
    | id                          | f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc                              |
    | size                        | 1                                                                 |
    | name                        | None                                                              |
    | share_type                  | ce1709ef-0b20-4cbf-9fc0-2b75adfee9b8                              |
    | has_replicas                | False                                                             |
    | replication_type            | dr                                                                |
    | created_at                  | 2016-03-23T18:16:22.000000                                        |
    | share_proto                 | NFS                                                               |
    | consistency_group_id        | None                                                              |
    | source_cgsnapshot_member_id | None                                                              |
    | project_id                  | 3d1d93550b1448f094389d6b5df9659e                                  |
    | metadata                    | {}                                                                |
    +-----------------------------+-------------------------------------------------------------------+

When a share is created with a share type that has the replication\_type
extra spec, it will be treated as the primary/'active' replica. Let's
list the replicas.

::

    $ manila share-replica-list --share-id f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc
    +--------------------------------------+-----------+---------------+--------------------------------------+-------------------------------------+-------------------+----------------------------+
    | ID                                   | Status    | Replica State | Share ID                             | Host                                | Availability Zone | Updated At                 |
    +--------------------------------------+-----------+---------------+--------------------------------------+-------------------------------------+-------------------+----------------------------+
    | 11265e8a-200c-4e0a-a40f-b7a1117001ed | available | active        | f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc | openstack2@cmodeSSVMNFS#aggr3       | nova              | 2016-03-23T18:16:34.000000 |
    +--------------------------------------+-----------+---------------+--------------------------------------+-------------------------------------+-------------------+----------------------------+

Next we'll create a replica of the share.

::

    $ manila share-replica-create f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc
    +-------------------+--------------------------------------+
    | Property          | Value                                |
    +-------------------+--------------------------------------+
    | status            | creating                             |
    | share_id          | f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc |
    | availability_zone | None                                 |
    | created_at        | 2016-03-23T18:19:13.712615           |
    | updated_at        | None                                 |
    | share_network_id  | None                                 |
    | share_server_id   | None                                 |
    | host              |                                      |
    | replica_state     | None                                 |
    | id                | b3191744-cee9-478b-b906-c5a7a3934adb |
    +-------------------+--------------------------------------+

    manila share-replica-show b3191744-cee9-478b-b906-c5a7a3934adb
    +-------------------+--------------------------------------+
    | Property          | Value                                |
    +-------------------+--------------------------------------+
    | status            | available                            |
    | share_id          | f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc |
    | availability_zone | nova                                 |
    | created_at        | 2016-03-23T18:19:13.000000           |
    | updated_at        | 2016-03-23T18:19:23.000000           |
    | share_network_id  | None                                 |
    | share_server_id   | None                                 |
    | host              | openstack2@cmodeSSVMNFS2#aggr4       |
    | replica_state     | out_of_sync                          |
    | id                | b3191744-cee9-478b-b906-c5a7a3934adb |
    +-------------------+--------------------------------------+

Now we will list the replicas for the share. As you can see, the active
replica is located on the pool 'openstack2@cmodeSSVMNFS#aggr3' and the
new replica is located on 'openstack2@cmodeSSVMNFS2#aggr4'. The new
replica has a replica state of 'out\_of\_sync', this means that the
share data has not been synchronized within the replication window,
which is one hour for the cDOT driver.

::

    $ manila share-replica-list --share-id f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc
    +--------------------------------------+-----------+---------------+--------------------------------------+-------------------------------------+-------------------+----------------------------+
    | ID                                   | Status    | Replica State | Share ID                             | Host                                | Availability Zone | Updated At                 |
    +--------------------------------------+-----------+---------------+--------------------------------------+-------------------------------------+-------------------+----------------------------+
    | 11265e8a-200c-4e0a-a40f-b7a1117001ed | available | active        | f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc | openstack2@cmodeSSVMNFS#aggr3       | nova              | 2016-03-23T18:16:34.000000 |
    | b3191744-cee9-478b-b906-c5a7a3934adb | available | out_of_sync   | f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc | openstack2@cmodeSSVMNFS2#aggr4      | nova              | 2016-03-23T18:19:23.000000 |
    +--------------------------------------+-----------+---------------+--------------------------------------+-------------------------------------+-------------------+----------------------------+

Manila checks the status of a replica based on the
``replica_state_update_interval`` configuration option. If we wait a
short while, the replica will become in sync. If the replica does not
become in-sync, refer to `??? <#appendix.debug.common_problems>`__.

::

    $ manila share-replica-list --share-id f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc
    +--------------------------------------+-----------+---------------+--------------------------------------+-------------------------------------+-------------------+----------------------------+
    | ID                                   | Status    | Replica State | Share ID                             | Host                                | Availability Zone | Updated At                 |
    +--------------------------------------+-----------+---------------+--------------------------------------+-------------------------------------+-------------------+----------------------------+
    | 11265e8a-200c-4e0a-a40f-b7a1117001ed | available | active        | f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc | openstack2@cmodeSSVMNFS#aggr3       | nova              | 2016-03-23T18:16:34.000000 |
    | b3191744-cee9-478b-b906-c5a7a3934adb | available | in_sync       | f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc | openstack2@cmodeSSVMNFS2#aggr4      | nova              | 2016-03-23T18:27:57.000000 |
    +--------------------------------------+-----------+---------------+--------------------------------------+-------------------------------------+-------------------+----------------------------+

Finally, let us failover to our other replica.

::

    $ manila share-replica-promote b3191744-cee9-478b-b906-c5a7a3934adb

    $ manila share-replica-list --share-id f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc
    +--------------------------------------+--------------------+---------------+--------------------------------------+-------------------------------------+-------------------+----------------------------+
    | ID                                   | Status             | Replica State | Share ID                             | Host                                | Availability Zone | Updated At                 |
    +--------------------------------------+--------------------+---------------+--------------------------------------+-------------------------------------+-------------------+----------------------------+
    | 11265e8a-200c-4e0a-a40f-b7a1117001ed | available          | active        | f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc | openstack2@cmodeSSVMNFS#aggr3       | nova              | 2016-03-23T18:16:34.000000 |
    | b3191744-cee9-478b-b906-c5a7a3934adb | replication_change | in_sync       | f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc | openstack2@cmodeSSVMNFS2#aggr4      | nova              | 2016-03-23T18:31:08.000000 |
    +--------------------------------------+--------------------+---------------+--------------------------------------+-------------------------------------+-------------------+----------------------------+

    $ manila share-replica-list --share-id f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc
    +--------------------------------------+-----------+---------------+--------------------------------------+-------------------------------------+-------------------+----------------------------+
    | ID                                   | Status    | Replica State | Share ID                             | Host                                | Availability Zone | Updated At                 |
    +--------------------------------------+-----------+---------------+--------------------------------------+-------------------------------------+-------------------+----------------------------+
    | 11265e8a-200c-4e0a-a40f-b7a1117001ed | available | out_of_sync   | f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc | openstack2@cmodeSSVMNFS#aggr3       | nova              | 2016-03-23T18:31:35.000000 |
    | b3191744-cee9-478b-b906-c5a7a3934adb | available | active        | f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc | openstack2@cmodeSSVMNFS2#aggr4      | nova              | 2016-03-23T18:31:35.000000 |
    +--------------------------------------+-----------+---------------+--------------------------------------+-------------------------------------+-------------------+----------------------------+

In this section, we'll migrate a share from one pool to another.

::

            $ manila migration-start myFlash ocata@cmode_multi_svm_nfs#manila --writable False --preserve-snapshots True --preserve-metadata True --nondisruptive True
            

We can check the migration progress by using the
``migration-get-progress`` command.

::

            $ manila migration-get-progress myFlash
            +----------------+-------------------------------+
            | Property       | Value                         |
            +----------------+-------------------------------+
            | task_state     | migration_driver_in_progress  |
            | total_progress | 99                            |
            +----------------+-------------------------------+
            

Once the task state has transitioned to
``migration_driver_phase1_done``, we can complete the migration process

::

            $ manila migration-complete myFlash

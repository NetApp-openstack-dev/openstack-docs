Manila Command Line Interface (CLI)
===================================

Manila Service Verification
---------------------------

In this section, we use the Manila CLI to verify that the configuration
presented in the section called ":ref:`manila-conf-ex`" has been
properly initialized by Manila.

::

    $ manila service-list
    +----+------------------+-------------------------------+------+---------+-------+----------------------------+
    | Id | Binary           | Host                          | Zone | Status  | State | Updated_at                 |
    +----+------------------+-------------------------------+------+---------+-------+----------------------------+
    | 1  | manila-scheduler | ostk-controller               | nova | enabled | up    | 2017-09-01T12:25:12.000000 |
    | 2  | manila-share     | ostk-controller@cdotSingleSVM | nova | enabled | up    | 2017-09-01T12:25:15.000000 |
    | 2  | manila-share     | ostk-controller@cdoMultiSVM   | nova | enabled | up    | 2017-09-01T12:25:15.000000 |
    +----+------------------+-------------------------------+------+---------+-------+----------------------------+

Creating and Defining Manila Share Types
----------------------------------------

In this section, we create a variety of Manila Share Types that leverage
both the default capabilities of each driver, as well as the NetApp
specific extra specs described in
:ref:`Table 6.10, “NetApp supported Extra Specs for use with Manila Share Types”<table-6.10>`.

-  The ``general`` type provisions Manila shares onto the cDOT backend
   using all the default settings, including snapshot support.

-  The ``flash`` type provisions Manila shares onto any pool that
   contains only SSD disks within the aggregate.

-  The ``archive`` type provisions Manila shares onto any pool that
   contains SAS drives within the aggregate, and also creates thin
   provisioned FlexVol volumes.

- The ``shared`` type provisions Manila a new SVM for each share
  network object.  Snapshot support is enabled.

-  The ``default`` type provisions Manila shares onto any pool of any
   driver without share server management and snapshot support.

::

    $ manila type-create general False
    +--------------------------------------+---------+------------+------------+--------------------------------------+
    | ID                                   | Name    | Visibility | is_default | required_extra_specs                 |
    +--------------------------------------+---------+------------+------------+--------------------------------------+
    | deadeebf-19a2-47b1-9d7f-1c3806cfcb72 | general | public     | -          | driver_handles_share_servers : False |
    +--------------------------------------+---------+------------+------------+--------------------------------------+

::

    $ manila type-create flash False
    +--------------------------------------+---------+------------+------------+--------------------------------------+
    | ID                                   | Name    | Visibility | is_default | required_extra_specs                 |
    +--------------------------------------+---------+------------+------------+--------------------------------------+
    | 37fb9f7e-4ffe-4900-8dba-c6d4251e588f | flash   | public     | -          | driver_handles_share_servers : False |
    +--------------------------------------+---------+------------+------------+--------------------------------------+

::

    $ manila type-create archive False
    +--------------------------------------+---------+------------+------------+--------------------------------------+
    | ID                                   | Name    | Visibility | is_default | required_extra_specs                 |
    +--------------------------------------+---------+------------+------------+--------------------------------------+
    | 20e4b58d-aab6-42ae-8e9b-8f9d44f17276 | archive | public     | -          | driver_handles_share_servers : False |
    +--------------------------------------+---------+------------+------------+--------------------------------------+

::

    $ manila type-create --snapshot_support True shared True
    +--------------------------------------+---------+------------+------------+--------------------------------------+
    | ID                                   | Name    | Visibility | is_default | required_extra_specs                 |
    +--------------------------------------+---------+------------+------------+--------------------------------------+
    | db589d3e-09e9-49a2-a5be-05471d178eaa | shared  | public     | -          | driver_handles_share_servers : True  |
    +--------------------------------------+---------+------------+------------+--------------------------------------+


.. important::

   In the Mitaka and Newton release of OpenStack, snapshot support is
   enabled by default for a newly created share type. Starting with the
   Ocata release, the ``snapshot_support`` extra spec must be set to
   ``True`` in order to allow snapshots for a share type. If the
   ``snapshot_support`` extra_spec is omitted or if it is set to False,
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
   :ref:`Table 6.10, “NetApp supported Extra Specs for use with Manila Share Types”<table-6.10>`.

::

    $ manila type-key general set share_backend_name=cdotSingleSVM
    $ manila type-key general set snapshot_support=True
    $ manila type-key general set revert_to_snapshot_support=True
    $ manila type-key general set create_share_from_snapshot_support=True

::

    $ manila type-key default set snapshot_support=False

::

    $ manila type-key flash set netapp_disk_type=SSD
    $ manila type-key flash set netapp_hybrid_aggregate="<is> False"

::

    $ manila type-key archive set thin_provisioning="<is> True" netapp_disk_type=SAS

::

    $ manila type-key shared set snapshot_support=True

::

    $ manila extra-specs-list
    +--------------------------------------+---------+--------------------------------------------+
    | ID                                   | Name    | all_extra_specs                            |
    +--------------------------------------+---------+--------------------------------------------+
    | 20e4b58d-aab6-42ae-8e9b-8f9d44f17276 | archive | driver_handles_share_servers : False       |
    |                                      |         | netapp_disk_type : SAS                     |
    |                                      |         | thin_provisioning : <is> True              |
    | 37fb9f7e-4ffe-4900-8dba-c6d4251e588f | flash   | netapp_disk_type : SSD                     |
    |                                      |         | netapp_hybrid_aggregate : <is> False       |
    |                                      |         | driver_handles_share_servers : False       |
    | 447732be-4cf2-42b0-83dc-4b6f4ed5368d | default | driver_handles_share_servers : False       |
    |                                      |         | snapshot_support : False                   |
    | deadeebf-19a2-47b1-9d7f-1c3806cfcb72 | general | share_backend_name : cdotSingleSVM         |
    |                                      |         | driver_handles_share_servers : False       |
    |                                      |         | snapshot_support : True                    |
    |                                      |         | revert_to_snapshot_support : True          |
    |                                      |         | create_share_from_snapshot_support : True  |
    | db589d3e-09e9-49a2-a5be-05471d178eaa | shared  | snapshot_support : True                    |
    |                                      |         | driver_handles_share_servers : True        |
    +--------------------------------------+---------+--------------------------------------------+

Creating Manila Share Network Objects
-------------------------------------

In this section, we create two manila share network objects, doing so
to demonstrate that share-network-objects are used only with share servers.

Network Plugin: NeutronNetworkPlugin
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In this scenario the configurable Neutron Network Plugin is in use.
As such each share network object is free to us any appropriate
neutron network.  In this particular case, we are using a provider
network.

::

    $ cat /etc/manila/manila.conf
    ...
    network_api_class = manila.network.neutron.neutron_network_plugin.NeutronNetworkPlugin
    ...

::

    $ neutron net-list
    +--------------------------------------+------------------+-----------------------------------------------------+
    | id                                   | name             | subnets                                             |
    +--------------------------------------+------------------+-----------------------------------------------------+
    ...
    | 0ba4ac4a-1408-4fa6-84d6-fd6db8113382 | storage-provider | 1f9ec07c-085a-437d-82f0-7390d706758b 192.168.0.0/16 |
    ...
    +--------------------------------------+------------------+-----------------------------------------------------+

::

    $ manila share-network-create --neutron-subnet-id 1f9ec07c-085a-437d-82f0-7390d706758b \
                                  --neutron-net-id 0ba4ac4a-1408-4fa6-84d6-fd6db8113382 \
                                  --name storage-provider-network
    +-------------------+--------------------------------------+
    | Property          | Value                                |
    +-------------------+--------------------------------------+
    | network_type      | None                                 |
    | name              | storage-provider-network             |
    | segmentation_id   | None                                 |
    | created_at        | 2017-09-01T10:16:16.999826           |
    | neutron_subnet_id | 1f9ec07c-085a-437d-82f0-7390d706758b |
    | updated_at        | None                                 |
    | mtu               | None                                 |
    | gateway           | None                                 |
    | neutron_net_id    | 0ba4ac4a-1408-4fa6-84d6-fd6db8113382 |
    | ip_version        | None                                 |
    | nova_net_id       | None                                 |
    | cidr              | None                                 |
    | project_id        | 37ceaca2938c409d8a6172f2da2ba788     |
    | id                | 557243e9-aad6-4b63-8d86-70239ecf4993 |
    | description       | None                                 |
    +-------------------+--------------------------------------+

::

    $ manila share-network-list
    +--------------------------------------+--------------------------+
    | id                                   | name                     |
    +--------------------------------------+--------------------------+
    | 557243e9-aad6-4b63-8d86-70239ecf4993 | storage-provider-network |
    +--------------------------------------+--------------------------+

::

    $ manila share-network-show storage-provider-network
    +-------------------+--------------------------------------+
    | Property          | Value                                |
    +-------------------+--------------------------------------+
    | network_type      | flat                                 |
    | name              | storage-provider-network             |
    | segmentation_id   | None                                 |
    | created_at        | 2017-09-01T10:16:16.000000           |
    | neutron_subnet_id | 1f9ec07c-085a-437d-82f0-7390d706758b |
    | updated_at        | 2017-09-01T10:19:25.000000           |
    | mtu               | 1500                                 |
    | gateway           | None                                 |
    | neutron_net_id    | 0ba4ac4a-1408-4fa6-84d6-fd6db8113382 |
    | ip_version        | 4                                    |
    | nova_net_id       | None                                 |
    | cidr              | 192.168.0.0/16                       |
    | project_id        | 37ceaca2938c409d8a6172f2da2ba788     |
    | id                | 557243e9-aad6-4b63-8d86-70239ecf4993 |
    | description       | None                                 |
    +-------------------+--------------------------------------+

Network Plugin: NeutronSingleNetworkPlugin
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In this scenario the simple Neutron Network Plugin is in use.
As such each share network will use the Neutron Network and
Neutron Subnet configured in the /etc/manila/manila.conf.

::

    $ cat /etc/manila/manila.conf
    ...
    network_api_class = manila.network.neutron.neutron_network_plugin.NeutronSingleNetworkPlugin
    neutron_net_id = 0ba4ac4a-1408-4fa6-84d6-fd6db8113382
    neutron_subnet_id = 1f9ec07c-085a-437d-82f0-7390d706758b
    ...

::

    $ manila share-network-create --name storage-provider-network-2
    +-------------------+--------------------------------------+
    | Property          | Value                                |
    +-------------------+--------------------------------------+
    | network_type      | None                                 |
    | name              | storage-provider-network-2           |
    | segmentation_id   | None                                 |
    | created_at        | 2017-09-01T10:50:55.000000           |
    | neutron_subnet_id | None                                 |
    | updated_at        | None                                 |
    | mtu               | None                                 |
    | gateway           | None                                 |
    | neutron_net_id    | None                                 |
    | ip_version        | None                                 |
    | nova_net_id       | None                                 |
    | cidr              | None                                 |
    | project_id        | 37ceaca2938c409d8a6172f2da2ba788     |
    | id                | e6a05868-fdfd-4da9-a914-6beab07b3121 |
    | description       | None                                 |
    +-------------------+--------------------------------------+

::

    $ manila share-network-list
    +--------------------------------------+----------------------------+
    | id                                   | name                       |
    +--------------------------------------+----------------------------+
    | 557243e9-aad6-4b63-8d86-70239ecf4993 | storage-provider-network   |
    | e6a05868-fdfd-4da9-a914-6beab07b3121 | storage-provider-network-2 |
    +--------------------------------------+----------------------------+

::

    $ manila share-network-show storage-provider-network-2
    +-------------------+--------------------------------------+
    | Property          | Value                                |
    +-------------------+--------------------------------------+
    | network_type      | flat                                 |
    | name              | storage-provider-network-2           |
    | segmentation_id   | None                                 |
    | created_at        | 2017-09-01T10:50:55.000000           |
    | neutron_subnet_id | 1f9ec07c-085a-437d-82f0-7390d706758b |
    | updated_at        | 2017-09-01T10:52:29.000000           |
    | mtu               | 1500                                 |
    | gateway           | None                                 |
    | neutron_net_id    | 0ba4ac4a-1408-4fa6-84d6-fd6db8113382 |
    | ip_version        | 4                                    |
    | nova_net_id       | None                                 |
    | cidr              | 192.168.0.0/16                       |
    | project_id        | 37ceaca2938c409d8a6172f2da2ba788     |
    | id                | e6a05868-fdfd-4da9-a914-6beab07b3121 |
    | description       | None                                 |
    +-------------------+--------------------------------------+


.. important::
    Since Train release, a share network is able to span multiple subnets
    in different availability zones. Network information is now stored on
    entities called share network subnets that can be associated to a specific
    availability zone or to a default one. A share network can have multiple
    subnets linked to different neutron networks. In this new design, a share
    network subnet will be automatically created by the shared file system for
    each new share network creation request, allowing the users to specify an
    associated availability zone if they want to. When showing a share network,
    manila will also list the subnets that are part of the specified share
    network.
    When deleting a share network, you must make sure that it does not contain
    more than one share network subnet attached and all its subnets can not
    contain any related resource such as shares, share servers and so on.

Creating Manila Share Network Subnets
-------------------------------------

In this section, we create a manila share network subnet in the previously
created share network, a feature available since Train release. It
demonstrates the usage of the introduced share network subnets.

::

    $ manila share-network-subnet-create storage-provider-network \
                    --neutron-net-id 51615112-b7c1-4e66-9f9b-bd3dd2dc711b \
                    --neutron-subnet-id c2a30101-52f9-4634-ac68-875f37583714 \
                    --availability-zone nova2
    +--------------------+--------------------------------------+
    | Property           | Value                                |
    +--------------------+--------------------------------------+
    | id                 | 8240a732-1713-4070-b863-042e794cc852 |
    | availability_zone  | nova2                                |
    | share_network_id   | d9e443b6-a6fe-4443-a1ef-661af09e4a66 |
    | share_network_name | storage-provider-network             |
    | created_at         | 2020-01-22T19:07:22.000000           |
    | segmentation_id    | None                                 |
    | neutron_subnet_id  | c2a30101-52f9-4634-ac68-875f37583714 |
    | updated_at         | None                                 |
    | neutron_net_id     | 51615112-b7c1-4e66-9f9b-bd3dd2dc711b |
    | ip_version         | None                                 |
    | cidr               | None                                 |
    | network_type       | None                                 |
    | mtu                | None                                 |
    | gateway            | None                                 |
    +--------------------+--------------------------------------+

Now, when requesting to show a share network, we can see in the below output
that it contains an attribute called ``share_network_subnets`` which consists
in a list of all the share network subnets created under the
'storage-provider-network'.

::

    $ manila share-network-show storage-provider-network
    +-----------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Property              | Value                                                                                                                                                                                                                                                                                                                                                                                                        |
    +-----------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | id                    | d9e443b6-a6fe-4443-a1ef-661af09e4a66                                                                                                                                                                                                                                                                                                                                                                         |
    | name                  | storage-provider-network                                                                                                                                                                                                                                                                                                                                                                                     |
    | project_id            | 4040a74271824f34a7bde610dcd705d1                                                                                                                                                                                                                                                                                                                                                                             |
    | created_at            | 2020-01-20T19:16:13.000000                                                                                                                                                                                                                                                                                                                                                                                   |
    | updated_at            | None                                                                                                                                                                                                                                                                                                                                                                                                         |
    | description           | None                                                                                                                                                                                                                                                                                                                                                                                                         |
    | share_network_subnets | [{'id': '8240a732-1713-4070-b863-042e794cc852', 'availability_zone': 'nova2', 'created_at': '2020-01-22T19:07:22.000000', 'updated_at': '2020-01-22T19:07:36.000000', 'segmentation_id': None, 'neutron_net_id': '51615112-b7c1-4e66-9f9b-bd3dd2dc711b', 'neutron_subnet_id': 'c2a30101-52f9-4634-ac68-875f37583714', 'ip_version': None, 'cidr': None, 'network_type': None, 'mtu': None, 'gateway': None}] |
    +-----------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Then, let's show the created share network subnet.

::

    $ manila share-network-subnet-show storage-provider-network \
                                        8240a732-1713-4070-b863-042e794cc852

    +--------------------+--------------------------------------+
    | Property           | Value                                |
    +--------------------+--------------------------------------+
    | id                 | 8240a732-1713-4070-b863-042e794cc852 |
    | availability_zone  | nova2                                |
    | share_network_id   | d9e443b6-a6fe-4443-a1ef-661af09e4a66 |
    | share_network_name | storage-provider-network             |
    | created_at         | 2020-01-22T19:07:22.000000           |
    | segmentation_id    | None                                 |
    | neutron_subnet_id  | c2a30101-52f9-4634-ac68-875f37583714 |
    | updated_at         | 2020-01-22T19:07:36.000000           |
    | neutron_net_id     | 51615112-b7c1-4e66-9f9b-bd3dd2dc711b |
    | ip_version         | None                                 |
    | cidr               | None                                 |
    | network_type       | None                                 |
    | mtu                | None                                 |
    | gateway            | None                                 |
    +--------------------+--------------------------------------+

Finally, it is possible to delete a share network subnet running the command
below.

::

    $ manila share-network-subnet-delete storage-provider-network \
                                        8240a732-1713-4070-b863-042e794cc852

Creating Manila Shares with Share Types
---------------------------------------

Without Share Server Management
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In this section, we create shares with the default type, as well as
all but the shared share type.

::

    $ manila create --name myDefault NFS 1
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
    | created_at        | 2017-09-01T12:44:11.794842           |
    | share_proto       | NFS                                  |
    | project_id        | 5bf3e15106dd4333b1f55742fa08f90e     |
    | metadata          | {}                                   |
    +-------------------+--------------------------------------+

::

    $ manila create --name myGeneral --share-type general NFS 1
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
    | created_at                          | 2017-09-01T12:44:47.223548           |
    | share_proto                         | NFS                                  |
    | project_id                          | 5bf3e15106dd4333b1f55742fa08f90e     |
    | metadata                            | {}                                   |
    +-------------------+--------------------------------------------------------+

::

    $ manila create --name myFlash --share-type flash NFS 1
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
    | created_at        | 2017-09-01T12:44:59.374780           |
    | share_proto       | NFS                                  |
    | project_id        | 5bf3e15106dd4333b1f55742fa08f90e     |
    | metadata          | {}                                   |
    +-------------------+--------------------------------------+

::

    $ manila create --name myArchive --share-type archive NFS 1
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
    | created_at        | 2017-09-01T12:45:11.124722           |
    | share_proto       | NFS                                  |
    | project_id        | 5bf3e15106dd4333b1f55742fa08f90e     |
    | metadata          | {}                                   |
    +-------------------+--------------------------------------+

::

    $ manila list
    +-------------------------------------+----------+----+------------+----------+-----------+-----------------+------------------------------------+------------------+
    | ID                                  | Name     |Size| Share Proto| Status   | Is Public | Share Type Name | Host                               | Availability Zone|
    +-------------------------------------+----------+----+------------+----------+-----------+-----------------+------------------------------------+------------------+
    | 63bd5bef-298d-4e49-bea0-49a4cfb143f9| myDefault| 1  | NFS        | available| False     | default         | scspr0030615001@cdotSingleSVM#aggr1| nova             |
    | 95f49ca6-723f-42d0-92f3-4be79c9ad7e6| myGeneral| 1  | NFS        | available| False     | general         | scspr0030615001@cdotSingleSVM#aggr1| nova             |
    | e4774a70-3e70-4a7c-ab76-886f010efe0a| myArchive| 1  | NFS        | available| False     | archive         | scspr0030615001@cdotSingleSVM#aggr1| nova             |
    | ec5d2ddb-4573-4ee1-a1e8-2c8532c68e3d| myFlash  | 1  | NFS        | error    | False     | flash           | None                               | nova             |
    +-------------------------------------+----------+----+------------+----------+-----------+-----------------+------------------------------------+------------------+

With Share Server Management
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In this section we create three shares, two on the share network object built upon
the Simple Neutron Network Plugin and one built upon the Configurable Neutron
Network Plugin.

::

    $ manila create  --share-network storage-provider-network  --share-type shared --name shared1 NFS 1
    +-----------------------------+--------------------------------------+
    | Property                    | Value                                |
    +-----------------------------+--------------------------------------+
    | status                      | creating                             |
    | share_type_name             | shared                               |
    | description                 | None                                 |
    | availability_zone           | None                                 |
    | share_network_id            | 557243e9-aad6-4b63-8d86-70239ecf4993 |
    | host                        |                                      |
    | access_rules_status         | active                               |
    | snapshot_id                 | None                                 |
    | is_public                   | False                                |
    | task_state                  | None                                 |
    | snapshot_support            | True                                 |
    | id                          | df8e63b1-3bb1-4c28-aad7-b29a80ac3e04 |
    | size                        | 1                                    |
    | user_id                     | 0c96b73302674429918df682c7d20f22     |
    | name                        | shared1                              |
    | share_type                  | db589d3e-09e9-49a2-a5be-05471d178eaa |
    | has_replicas                | False                                |
    | replication_type            | None                                 |
    | created_at                  | 2017-09-01T11:20:21.000000           |
    | share_proto                 | NFS                                  |
    | consistency_group_id        | None                                 |
    | source_cgsnapshot_member_id | None                                 |
    | project_id                  | 37ceaca2938c409d8a6172f2da2ba788     |
    | metadata                    | {}                                   |
    +-----------------------------+--------------------------------------+

::

    $ manila create  --share-network storage-provider-network-2  --share-type shared --name shared2 NFS 1
    +-----------------------------+--------------------------------------+
    | Property                    | Value                                |
    +-----------------------------+--------------------------------------+
    | status                      | creating                             |
    | share_type_name             | shared                               |
    | description                 | None                                 |
    | availability_zone           | None                                 |
    | share_network_id            | e6a05868-fdfd-4da9-a914-6beab07b3121 |
    | host                        |                                      |
    | access_rules_status         | active                               |
    | snapshot_id                 | None                                 |
    | is_public                   | False                                |
    | task_state                  | None                                 |
    | snapshot_support            | True                                 |
    | id                          | 4f54f4e8-80f1-4b21-9fda-c0882f7837aa |
    | size                        | 1                                    |
    | user_id                     | 0c96b73302674429918df682c7d20f22     |
    | name                        | shared2                              |
    | share_type                  | db589d3e-09e9-49a2-a5be-05471d178eaa |
    | has_replicas                | False                                |
    | replication_type            | None                                 |
    | created_at                  | 2017-09-01T11:21:55.000000           |
    | share_proto                 | NFS                                  |
    | consistency_group_id        | None                                 |
    | source_cgsnapshot_member_id | None                                 |
    | project_id                  | 37ceaca2938c409d8a6172f2da2ba788     |
    | metadata                    | {}                                   |
    +-----------------------------+--------------------------------------+

::

    $ manila create  --share-network storage-provider-network-2  --share-type shared --name shared3 NFS 1
    +-----------------------------+--------------------------------------+
    | Property                    | Value                                |
    +-----------------------------+--------------------------------------+
    | status                      | creating                             |
    | share_type_name             | shared                               |
    | description                 | None                                 |
    | availability_zone           | None                                 |
    | share_network_id            | e6a05868-fdfd-4da9-a914-6beab07b3121 |
    | host                        |                                      |
    | access_rules_status         | active                               |
    | snapshot_id                 | None                                 |
    | is_public                   | False                                |
    | task_state                  | None                                 |
    | snapshot_support            | True                                 |
    | id                          | 9c05879a-a063-487b-bed4-5c039d26e26a |
    | size                        | 1                                    |
    | user_id                     | 0c96b73302674429918df682c7d20f22     |
    | name                        | shared3                              |
    | share_type                  | db589d3e-09e9-49a2-a5be-05471d178eaa |
    | has_replicas                | False                                |
    | replication_type            | None                                 |
    | created_at                  | 2017-09-01T11:28:15.000000           |
    | share_proto                 | NFS                                  |
    | consistency_group_id        | None                                 |
    | source_cgsnapshot_member_id | None                                 |
    | project_id                  | 37ceaca2938c409d8a6172f2da2ba788     |
    | metadata                    | {}                                   |
    +-----------------------------+--------------------------------------+

::

    $ manila list
    +-------------------------------------+--------+------+------------+-----------+-----------+-----------------+-----------------------------------+------------------+
    | ID                                  | Name   | Size | Share Proto| Status    | Is Public | Share Type Name | Host                              | Availability Zone|
    +-------------------------------------+--------+------+------------+-----------+-----------+-----------------+-----------------------------------+------------------+
    | 4f54f4e8-80f1-4b21-9fda-c0882f7837aa| shared2| 1    | NFS        | available | False     | shared          | scspr0030615001@cdotMultiSVM#aggr1| nova             |
    | 9c05879a-a063-487b-bed4-5c039d26e26a| shared3| 1    | NFS        | available | False     | shared          | scspr0030615001@cdotMultiSVM#aggr1| nova             |
    | df8e63b1-3bb1-4c28-aad7-b29a80ac3e04| shared1| 1    | NFS        | available | False     | shared          | scspr0030615001@cdotMultiSVM#aggr1| nova             |
    +-------------------------------------+--------+------+------------+-----------+-----------+-----------------+-----------------------------------+------------------+

Viewing Share Servers
---------------------

Shares created against any one share network are placed on the same SVM.
Notice that there are two share-servers for the three shares.

.. note::

    Admin privileges are required to see or delete share-servers.
    Notice the vserver names in the manila share-server-show command

::

    $ manila share-server-list
    +--------------------------------------+-----------------------+--------+----------------------------+----------------------------------+----------------------------+
    | Id                                   | Host                  | Status | Share Network              | Project Id                       | Updated_at                 |
    +--------------------------------------+-----------------------+--------+----------------------------+----------------------------------+----------------------------+
    | c6f2fcbb-8c35-4a42-8f0a-e8ac81605d88 | chadcloud1@cdot_multi | active | storage-provider-network   | 37ceaca2938c409d8a6172f2da2ba788 | 2017-09-01T10:19:34.000000 |
    | c3c6bbfb-c71d-416d-84f3-600575746a36 | chadcloud1@cdot_multi | active | storage-provider-network-2 | 37ceaca2938c409d8a6172f2da2ba788 | 2017-09-01T10:52:32.000000 |
    +--------------------------------------+-----------------------+--------+----------------------------+----------------------------------+----------------------------+

::

    $ manila share-server-show c6f2fcbb-8c35-4a42-8f0a-e8ac81605d88
    +----------------------+-------------------------------------------------+
    | Property             | Value                                           |
    +----------------------+-------------------------------------------------+
    | status               | active                                          |
    | created_at           | 2017-09-01T10:19:24.000000                      |
    | updated_at           | 2017-09-01T10:19:34.000000                      |
    | share_network_name   | storage-provider-network                        |
    | host                 | scspr0030615001@cdotMultiSVM                    |
    | share_network_id     | 557243e9-aad6-4b63-8d86-70239ecf4993            |
    | project_id           | 37ceaca2938c409d8a6172f2da2ba788                |
    | id                   | c6f2fcbb-8c35-4a42-8f0a-e8ac81605d88            |
    | details:vserver_name | cdot_multi_c6f2fcbb-8c35-4a42-8f0a-e8ac81605d88 |
    +----------------------+-------------------------------------------------+

::

    $ manila share-server-show c3c6bbfb-c71d-416d-84f3-600575746a36
    +----------------------+-------------------------------------------------+
    | Property             | Value                                           |
    +----------------------+-------------------------------------------------+
    | status               | active                                          |
    | created_at           | 2017-09-01T10:52:28.000000                      |
    | updated_at           | 2017-09-01T10:52:32.000000                      |
    | share_network_name   | storage-provider-network-2                      |
    | host                 | scspr0030615001@cdotMultiSVM                    |
    | share_network_id     | e6a05868-fdfd-4da9-a914-6beab07b3121            |
    | project_id           | 37ceaca2938c409d8a6172f2da2ba788                |
    | id                   | c3c6bbfb-c71d-416d-84f3-600575746a36            |
    | details:vserver_name | cdot_multi_c3c6bbfb-c71d-416d-84f3-600575746a36 |
    +----------------------+-------------------------------------------------+

Viewing Flexvols
----------------

We'll now look at the CLI output from the ONTAP cluster to see what
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

::

    cluster-1::> volume show -vserver manila-vserver -space-guarantee none
    Vserver   Volume       Aggregate    State      Type       Size  Available Used%
    --------- ------------ ------------ ---------- ---- ---------- ---------- -----
    manila-vserver
              share_e4774a70_3e70_4a7c_ab76_886f010efe0a
                           aggr1        online     RW          1GB    972.7MB    5%

::

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

::

    cluster-1::> disk show -type SSD
    There are no entries matching your query.


Granting Access To Shares
-------------------------

We'll now add access rules for any IP-connected client to mount these
NFS shares with full read/write privileges.

::

    $ manila access-allow 63bd5bef-298d-4e49-bea0-49a4cfb143f9 ip 0.0.0.0/0
    +--------------+--------------------------------------+
    | Property     | Value                                |
    +--------------+--------------------------------------+
    | share_id     | 63bd5bef-298d-4e49-bea0-49a4cfb143f9 |
    | deleted      | False                                |
    | created_at   | 2017-09-01T13:25:24.577736           |
    | updated_at   | None                                 |
    | access_type  | ip                                   |
    | access_to    | 0.0.0.0/0                            |
    | access_level | rw                                   |
    | state        | queued_to_apply                      |
    | deleted_at   | None                                 |
    | id           | c400bdd7-7e4f-49a4-b73d-5aa417af95c3 |
    +--------------+--------------------------------------+

::

    $ manila access-allow 95f49ca6-723f-42d0-92f3-4be79c9ad7e6 ip 0.0.0.0/0
    +--------------+--------------------------------------+
    | Property     | Value                                |
    +--------------+--------------------------------------+
    | share_id     | 95f49ca6-723f-42d0-92f3-4be79c9ad7e6 |
    | deleted      | False                                |
    | created_at   | 2017-09-01T13:25:47.417271           |
    | updated_at   | None                                 |
    | access_type  | ip                                   |
    | access_to    | 0.0.0.0/0                            |
    | access_level | rw                                   |
    | state        | queued_to_apply                      |
    | deleted_at   | None                                 |
    | id           | 09f8f699-1cec-4519-8aaa-a30d346ad54c |
    +--------------+--------------------------------------+

::

    $ manila access-allow e4774a70-3e70-4a7c-ab76-886f010efe0a ip 0.0.0.0/0
    +--------------+--------------------------------------+
    | Property     | Value                                |
    +--------------+--------------------------------------+
    | share_id     | e4774a70-3e70-4a7c-ab76-886f010efe0a |
    | deleted      | False                                |
    | created_at   | 2017-09-01T13:26:03.344004           |
    | updated_at   | None                                 |
    | access_type  | ip                                   |
    | access_to    | 0.0.0.0/0                            |
    | access_level | rw                                   |
    | state        | queued_to_apply                      |
    | deleted_at   | None                                 |
    | id           | d0565115-8369-455e-ad8f-3dd7c56037ea |
    +--------------+--------------------------------------+

Viewing Export Locations
------------------------

We'll now list the export location(s) for one of the new shares to see
its network path. There may be multiple export locations for a given
share, at least one of which should be listed as preferred; clients
should use the preferred path for optimum performance.

::

    $ manila share-export-location-list 63bd5bef-298d-4e49-bea0-49a4cfb143f9 \
             --columns Path,Preferred
    +-------------------------------------------------------------+-----------+
    | Path                                                        | Preferred |
    +-------------------------------------------------------------+-----------+
    | 192.168.228.110:/share_6fae2eb7_9eea_4a0f_b215_1f405dbcc4d4 | True      |
    +-------------------------------------------------------------+-----------+


Manila Quality of Service
-------------------------
Manila Administrators have the ability to create share types with throughput
limits specified for each share that users create. The following examples
demonstrate creating two share types with two different QoS specs. For all
supported specs refer to
":ref:`Table 6.11, “NetApp specific QoS Extra Specs<table-6.11>`"

::

    $ manila type-create platinum True --extra-specs qos=True netapp:maxiopspergib=100 snapshot_support=True create_share_from_snapshot_support=True
    +----------------------+-------------------------------------------+
    | Property             | Value                                     |
    +----------------------+-------------------------------------------+
    | required_extra_specs | driver_handles_share_servers : True       |
    | Name                 | platinum                                  |
    | Visibility           | public                                    |
    | is_default           | -                                         |
    | ID                   | c6e8d62f-f827-4fc8-af94-789d370abac7      |
    | optional_extra_specs | netapp:maxiopspergib : 100                |
    |                      | qos : True                                |
    |                      | create_share_from_snapshot_support : True |
    |                      | snapshot_support : True                   |
    +----------------------+-------------------------------------------+

::

    $ manila type-create gold False --extra-specs qos=True netapp:maxbps=5000 snapshot_support=True create_share_from_snapshot_support=True
    +----------------------+-------------------------------------------+
    | Property             | Value                                     |
    +----------------------+-------------------------------------------+
    | required_extra_specs | driver_handles_share_servers : False      |
    | Name                 | gold                                      |
    | Visibility           | public                                    |
    | is_default           | -                                         |
    | ID                   | 96b45147-ab7c-4f85-8b8e-bdb7e849689e      |
    | optional_extra_specs | create_share_from_snapshot_support : True |
    |                      | snapshot_support : True                   |
    |                      | qos : True                                |
    |                      | netapp:maxbps : 5000                      |
    +----------------------+-------------------------------------------+

::

    $ manila create cifs 50 --share-network project-network-1 --share-type platinum --name myshare1
    +---------------------------------------+--------------------------------------+
    | Property                              | Value                                |
    +---------------------------------------+--------------------------------------+
    | status                                | creating                             |
    | share_type_name                       | platinum                             |
    | description                           | None                                 |
    | availability_zone                     | None                                 |
    | share_network_id                      | 75b18431-6832-4161-964f-e79ce693276b |
    | share_server_id                       | None                                 |
    | share_group_id                        | None                                 |
    | host                                  |                                      |
    | revert_to_snapshot_support            | True                                 |
    | access_rules_status                   | active                               |
    | snapshot_id                           | None                                 |
    | create_share_from_snapshot_support    | True                                 |
    | is_public                             | False                                |
    | task_state                            | None                                 |
    | snapshot_support                      | True                                 |
    | id                                    | dfae168f-ac70-42e0-9779-b1aebc98d0ce |
    | size                                  | 50                                   |
    | source_share_group_snapshot_member_id | None                                 |
    | user_id                               | 75a6db01ffda4ba59637e307e6c768e0     |
    | name                                  | myshare1                             |
    | share_type                            | 2e3734eb-54fe-4e5c-a5ca-6ef9de4c3524 |
    | has_replicas                          | False                                |
    | replication_type                      | None                                 |
    | created_at                            | 2017-08-31T00:17:05.000000           |
    | share_proto                           | CIFS                                 |
    | mount_snapshot_support                | False                                |
    | project_id                            | 4aaa76d5ab2341b6bb84a9a911c1550b     |
    | metadata                              | {}                                   |
    +---------------------------------------+--------------------------------------+

::

    $ manila create nfs 50 --share-type gold --name myshare2
    +---------------------------------------+--------------------------------------+
    | Property                              | Value                                |
    +---------------------------------------+--------------------------------------+
    | status                                | creating                             |
    | share_type_name                       | gold                                 |
    | description                           | None                                 |
    | availability_zone                     | None                                 |
    | share_network_id                      | None                                 |
    | share_server_id                       | None                                 |
    | share_group_id                        | None                                 |
    | host                                  |                                      |
    | revert_to_snapshot_support            | True                                 |
    | access_rules_status                   | active                               |
    | snapshot_id                           | None                                 |
    | create_share_from_snapshot_support    | True                                 |
    | is_public                             | False                                |
    | task_state                            | None                                 |
    | snapshot_support                      | True                                 |
    | id                                    | e423a08d-efbb-4c93-8027-7f22b91946da |
    | size                                  | 50                                   |
    | source_share_group_snapshot_member_id | None                                 |
    | user_id                               | 75a6db01ffda4ba59637e307e6c768e0     |
    | name                                  | myshare2                             |
    | share_type                            | 9ce01f95-122b-4a50-b582-aa8ef0cdb4f0 |
    | has_replicas                          | False                                |
    | replication_type                      | dr                                   |
    | created_at                            | 2017-08-31T00:17:44.000000           |
    | share_proto                           | NFS                                  |
    | mount_snapshot_support                | False                                |
    | project_id                            | 4aaa76d5ab2341b6bb84a9a911c1550b     |
    | metadata                              | {}                                   |
    +---------------------------------------+--------------------------------------+

::

    $ manila list
    +--------------------------------------+----------+------+-------------+-----------+-----------+-----------------+-----------------------------------+-------------------+
    | ID                                   | Name     | Size | Share Proto | Status    | Is Public | Share Type Name | Host                              | Availability Zone |
    +--------------------------------------+----------+------+-------------+-----------+-----------+-----------------+-----------------------------------+-------------------+
    | dfae168f-ac70-42e0-9779-b1aebc98d0ce | myshare1 | 50   | CIFS        | available | False     | platinum        | openstack2@cmodeMSVMNFS#aggr_2    | az_1              |
    | e423a08d-efbb-4c93-8027-7f22b91946da | myshare2 | 50   | NFS         | available | False     | gold            | openstack2@cmodeSSVMNFS_02#aggr_2 | az_2              |
    +--------------------------------------+----------+------+-------------+-----------+-----------+-----------------+-----------------------------------+-------------------+



Creating a Manila CIFS share with security service
--------------------------------------------------

As previously noted, creation of a CIFS share requires the co-deployment
of one of three security services (LDAP, Active Directory, or Kerberos).
This section demonstrates the share network and security service setup
necessary before creating the CIFS share.

::

    $ manila share-network-create --neutron-net-id <neutron-net-id> \
                                  --neutron-subnet-id <neutron-subnet-id> \
                                  --name <share_network_name>

::

    $ manila security-service-create active_directory --dns-ip <dns_ip> \
                                                      --domain <dns_domain> \
                                                      --user <user_name>
                                                      --password <password>
                                                      --name <security_service_name>
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

    $ manila share-network-security-service-add <share_network> <security_service>

::

    $ manila create CIFS 1 --share-network <share_network_name> --share-type general
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


.. _modifying_security_services:

Modifying security services of in-use share networks
----------------------------------------------------

As of Wallaby release, manila supports updating security services for share
networks that are currently being used. In order to do such operation, you must
make sure that all share servers deployed under the share network can handle
being updated. Share networks and share servers now have a new field called
`security_service_update_support`.

.. important::

   For share servers deployed before the Wallaby release, the field
   `security_service_update_support` is going to be set as `False`, and if the
   share backend supports adding/updating security service on its share
   servers, administrators can modify this field using the `manila-manage`
   commands. Manila will only perform adding/updating security services in a
   share network if all share servers pertaining to it can handle this
   operation. The `security_service_update_support` field in the share network
   considers all share servers within it, and it makes it the perfect indicator
   to whether the update is going to be supported or not.

Let's create an empty share network:

::

    $ manila share-network-create --neutron-net-id <neutron-net-id> \
                                  --neutron-subnet-id <neutron-subnet-id> \
                                  --name share-network-1

Now create a new share using the brand new network:

::

    $ manila create cifs 50 --share-network share-network-1 --share-type platinum --name myshare3
    +---------------------------------------+--------------------------------------+
    | Property                              | Value                                |
    +---------------------------------------+--------------------------------------+
    | status                                | creating                             |
    | share_type_name                       | platinum                             |
    | description                           | None                                 |
    | availability_zone                     | None                                 |
    | share_network_id                      | 848366d5-ae20-495e-af78-98f82301173a |
    | share_server_id                       | None                                 |
    | share_group_id                        | None                                 |
    | host                                  |                                      |
    | revert_to_snapshot_support            | True                                 |
    | access_rules_status                   | active                               |
    | snapshot_id                           | None                                 |
    | create_share_from_snapshot_support    | True                                 |
    | is_public                             | False                                |
    | task_state                            | None                                 |
    | snapshot_support                      | True                                 |
    | id                                    | bfa862cb-82a2-4c07-86ab-0c3bbe3459e7 |
    | size                                  | 50                                   |
    | source_share_group_snapshot_member_id | None                                 |
    | user_id                               | 75a6db01ffda4ba59637e307e6c768e0     |
    | name                                  | myshare3                             |
    | share_type                            | 2e3734eb-54fe-4e5c-a5ca-6ef9de4c3524 |
    | has_replicas                          | False                                |
    | replication_type                      | None                                 |
    | created_at                            | 2021-03-31T00:17:05.000000           |
    | share_proto                           | CIFS                                 |
    | mount_snapshot_support                | False                                |
    | project_id                            | 4aaa76d5ab2341b6bb84a9a911c1550b     |
    | metadata                              | {}                                   |
    +---------------------------------------+--------------------------------------+

::

    $ manila list
    +--------------------------------------+----------+------+-------------+-----------+-----------+-----------------+-----------------------------------+-------------------+
    | ID                                   | Name     | Size | Share Proto | Status    | Is Public | Share Type Name | Host                              | Availability Zone |
    +--------------------------------------+----------+------+-------------+-----------+-----------+-----------------+-----------------------------------+-------------------+
    | dfae168f-ac70-42e0-9779-b1aebc98d0ce | myshare1 | 50   | CIFS        | available | False     | platinum        | openstack2@cmodeMSVMNFS#aggr_2    | az_1              |
    | e423a08d-efbb-4c93-8027-7f22b91946da | myshare2 | 50   | NFS         | available | False     | gold            | openstack2@cmodeSSVMNFS_02#aggr_2 | az_2              |
    | bfa862cb-82a2-4c07-86ab-0c3bbe3459e7 | myshare3 | 50   | CIFS        | available | False     | platinum        | openstack2@cmodeMSVMNFS#aggr_2    | az_1              |
    +--------------------------------------+----------+------+-------------+-----------+-----------+-----------------+-----------------------------------+-------------------+

Let's create a security service to be attached in the share network:

::

    $ manila security-service-create kerberos --dns-ip 10.150.XXX.XXX  \
                                              --domain stack1.netapp.com \
                                              --user Administrator \
                                              --password password
                                              --name ac11
    +-------------+--------------------------------------+
    | Property    | Value                                |
    +-------------+--------------------------------------+
    | status      | new                                  |
    | domain      | stack1.netapp.com                    |
    | password    | password                             |
    | name        | ac11                                 |
    | dns_ip      | 10.150.XXX.XXX                       |
    | created_at  | 2021-03-31T00:17:06.000000           |
    | updated_at  | None                                 |
    | server      | None                                 |
    | user        | Administrator                        |
    | project_id  | b568323d304046d8a8abaa8e822f17e3     |
    | type        | kerberos                             |
    | id          | 259a203d-9e11-49cd-83d7-e5c986c01221 |
    | description | None                                 |
    +-------------+--------------------------------------+

Adding security services to in-use share networks
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In order to add or update security servers for share network that are being
used, the user must check if such operation can be handled. If the result of
such checks is positive, manila will allow the user to perform such actions.

Checking if the security service can be added to a share network that is being
used:

::

    $ manila share-network-security-service-add-check \
       share-network-1 \
       ac11
    +---------------------+-----------------------------------------------------------------------------------------------------------------------------------------+
    | Property            | Value                                                                                                                                   |
    +---------------------+-----------------------------------------------------------------------------------------------------------------------------------------+
    | compatible          | None                                                                                                                                    |
    | requested_operation | {'operation': 'add_security_service', 'current_security_service': None, 'new_security_service': '259a203d-9e11-49cd-83d7-e5c986c01221'} |
    +---------------------+-----------------------------------------------------------------------------------------------------------------------------------------+

.. note::

   This operation is asynchronous, considering that there might be dozens of
   share servers in different backends and manila must check if all backends
   are up and can handle the operation. So, the result of whether the update is
   compatible or not might take some time to be completed. To check the result,
   just run the same check command and see the `compatible` field content.

Check the result of the operation:

::

    $ manila share-network-security-service-add-check \
       share-network-1 \
       ac11
    +---------------------+-----------------------------------------------------------------------------------------------------------------------------------------+
    | Property            | Value                                                                                                                                   |
    +---------------------+-----------------------------------------------------------------------------------------------------------------------------------------+
    | compatible          | True                                                                                                                                    |
    | requested_operation | {'operation': 'add_security_service', 'current_security_service': None, 'new_security_service': '259a203d-9e11-49cd-83d7-e5c986c01221'} |
    +---------------------+-----------------------------------------------------------------------------------------------------------------------------------------+

Then, just run the command to add the security service to the share network:

::

    $ manila share-network-security-service-add share-network-1 ac11

Updating security services of in-use share networks
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Let' s create a security service with updated info to replace the former
security service.

::

    $ manila security-service-create kerberos --dns-ip 10.150.XXX.XXX  \
                                              --domain stack1.netapp.com \
                                              --user Administrator \
                                              --password updated_password
                                              --name ac11_updated
    +-------------+--------------------------------------+
    | Property    | Value                                |
    +-------------+--------------------------------------+
    | status      | new                                  |
    | domain      | stack1.netapp.com                    |
    | password    | updated_password                     |
    | name        | ac11_updated                         |
    | dns_ip      | 10.150.XXX.XXX                       |
    | created_at  | 2021-04-23T13:11:19.304355           |
    | updated_at  | None                                 |
    | server      | None                                 |
    | user        | Administrator                        |
    | project_id  | b568323d304046d8a8abaa8e822f17e3     |
    | type        | kerberos                             |
    | id          | 77be4e88-5c96-4724-9cb8-319f63f14390 |
    | description | None                                 |
    +-------------+--------------------------------------+

First, there is need to check if the update for security services of the same
type can be performed:

::

    $ manila share-network-security-service-update-check \
       share-network-1 \
       ac11 \
       ac11_updated
    +---------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Property            | Value                                                                                                                                                                       |
    +---------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | compatible          | None                                                                                                                                                                        |
    | requested_operation | {'operation': 'update_security_service', 'current_security_service': 259a203d-9e11-49cd-83d7-e5c986c01221', 'new_security_service': '77be4e88-5c96-4724-9cb8-319f63f14390'} |
    +---------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

.. note::

   This operation is asynchronous, considering that there might be dozens of
   share servers in different backends and manila must check if all backends
   are up and can handle the operation. So, the result of whether the update is
   compatible or not might take some time to be completed. To check the result,
   just run the same check command and see the `compatible` field content.

Check the result of the operation:

::

    $ manila share-network-security-service-update-check \
       share-network-1 \
       ac11 \
       ac11_updated
    +---------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Property            | Value                                                                                                                                                                        |
    +---------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | compatible          | True                                                                                                                                                                         |
    | requested_operation | {'operation': 'update_security_service', 'current_security_service': '259a203d-9e11-49cd-83d7-e5c986c01221', 'new_security_service': '259a203d-9e11-49cd-83d7-e5c986c01221'} |
    +---------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Then, just run the command which will actually update the security service of
the share network:

::

    $ manila share-network-security-service-update \
        share-network-1 \
        ac11 \
        ac11_updated
    $ manila share-network-security-service-list share-network-1
    +--------------------------------------+--------------+--------+-----------+
    | id                                   | name         | status | type      |
    +--------------------------------------+--------------+--------+-----------+
    | 77be4e88-5c96-4724-9cb8-319f63f14390 | ac11_updated | new    | kerberos  |
    +--------------------------------------+--------------+--------+-----------+

Managing and Unmanaging Manila Shares
-------------------------------------

In this section, we use the admin-only ``manage`` command to bring
storage resources under Manila management. A share is an ONTAP
FlexVol, and we must tell Manila which host, backend and pool contain
the FlexVol. When managing a share in DHSS=True mode, it is also
important to specify the share-server that contains the share. This is not
required for managing a share in DHSS=False mode. It may be useful to list the
Manila pools to get the correct format. Also note that the FlexVol must
be specified in the format Manila uses to report share export locations.
For NFS this format is ``address:/path``, where ``address`` is that of
any NFS LIF where the FlexVol is accessible and ``path`` is the junction
path of the FlexVol. For CIFS this format is ``\\address\name``, where
``address`` is that of any CIFS LIF where the FlexVol is accessible and
``name`` is the name of the FlexVol.

::

    $ manila pool-list
    +----------------------------------+-----------+------------------+----------+
    | Name                             | Host      | Backend          | Pool     |
    +----------------------------------+-----------+------------------+----------+
    | openstack@manila_dhssfalse#aggr1 | openstack | manila_dhssfalse | aggr1    |
    | openstack@tripleo_netapp#aggr1   | openstack | tripleo_netapp   | aggr1    |
    +----------------------------------+-----------+------------------+----------+

First let us attempt to manage a share that is in ``DHSS=False`` mode. For this,
we will use the ``openstack@manila_dhssfalse#aggr1`` storage pool.

::

    $ manila manage openstack@manila_dhssfalse#aggr1 NFS 100.250.119.20:/share_a7601db9_b083_4134_879c_e49512022276 --share-type dhss_false
    +---------------------------------------+--------------------------------------+
    | Property                              | Value                                |
    +---------------------------------------+--------------------------------------+
    | status                                | manage_starting                      |
    | share_type_name                       | dhss_false                           |
    | description                           | None                                 |
    | availability_zone                     | None                                 |
    | share_network_id                      | None                                 |
    | share_server_id                       | None                                 |
    | share_group_id                        | None                                 |
    | host                                  | openstack@manila_dhssfalse#aggr1     |
    | revert_to_snapshot_support            | False                                |
    | access_rules_status                   | active                               |
    | snapshot_id                           | None                                 |
    | create_share_from_snapshot_support    | False                                |
    | is_public                             | False                                |
    | task_state                            | None                                 |
    | snapshot_support                      | False                                |
    | id                                    | eb470d1c-1a10-4025-8384-4fc44e81013a |
    | size                                  | None                                 |
    | source_share_group_snapshot_member_id | None                                 |
    | user_id                               | 3ba400f4c7cd428aad09594d2bd6b6b9     |
    | name                                  | None                                 |
    | share_type                            | dfade3e4-65d0-4f64-8a35-70644e200721 |
    | has_replicas                          | False                                |
    | replication_type                      | None                                 |
    | created_at                            | 2019-03-15T18:31:55.000000           |
    | share_proto                           | NFS                                  |
    | mount_snapshot_support                | False                                |
    | project_id                            | 08633ba3317a45a1a46e90380e0e2ee0     |
    | metadata                              | {}                                   |
    +---------------------------------------+--------------------------------------+

We see here that the share has been assigned a new ``id`` and the share is renamed on
the backend as ``share_<share_instance_id>``.

::

    $ manila show eb470d1c-1a10-4025-8384-4fc44e81013a
    +---------------------------------------+-------------------------------------------------------------------+
    | Property                              | Value                                                             |
    +---------------------------------------+-------------------------------------------------------------------+
    | status                                | available                                                         |
    | share_type_name                       | dhss_false                                                        |
    | description                           | None                                                              |
    | availability_zone                     | nova                                                              |
    | share_network_id                      | None                                                              |
    | export_locations                      |                                                                   |
    |                                       | path = 100.250.119.20:/share_96f46bda_bc60_4171_971d_77a0042b0289 |
    |                                       | preferred = True                                                  |
    |                                       | is_admin_only = False                                             |
    |                                       | id = 50558be7-b0df-4484-8595-c25cbabb5e86                         |
    |                                       | share_instance_id = 96f46bda-bc60-4171-971d-77a0042b0289          |
    | share_server_id                       | None                                                              |
    | share_group_id                        | None                                                              |
    | host                                  | openstack@manila_dhssfalse#aggr1                                  |
    | revert_to_snapshot_support            | False                                                             |
    | access_rules_status                   | active                                                            |
    | snapshot_id                           | None                                                              |
    | create_share_from_snapshot_support    | False                                                             |
    | is_public                             | False                                                             |
    | task_state                            | None                                                              |
    | snapshot_support                      | False                                                             |
    | id                                    | eb470d1c-1a10-4025-8384-4fc44e81013a                              |
    | size                                  | 1                                                                 |
    | source_share_group_snapshot_member_id | None                                                              |
    | user_id                               | 3ba400f4c7cd428aad09594d2bd6b6b9                                  |
    | name                                  | None                                                              |
    | share_type                            | dfade3e4-65d0-4f64-8a35-70644e200721                              |
    | has_replicas                          | False                                                             |
    | replication_type                      | None                                                              |
    | created_at                            | 2019-03-15T18:31:55.000000                                        |
    | share_proto                           | NFS                                                               |
    | mount_snapshot_support                | False                                                             |
    | project_id                            | 08633ba3317a45a1a46e90380e0e2ee0                                  |
    | metadata                              | {}                                                                |
    +---------------------------------------+-------------------------------------------------------------------+

.. important::

   FlexVols that are part of a SnapMirror relationship cannot be
   brought under Manila's management. SnapMirror relationships must be
   removed before attempting to ``manage`` the FlexVol.

Now, let us attempt to manage a share of type ``DHSS=True``. For this, we
would need to pass the ID of the share-server with which this share
will be associated also.

::

    $ manila share-server-list
    +--------------------------------------+--------------------------+--------+---------------+----------------------------------+----------------------------+
    | Id                                   | Host                     | Status | Share Network | Project Id                       | Updated_at                 |
    +--------------------------------------+--------------------------+--------+---------------+----------------------------------+----------------------------+
    | 4c4667d8-9491-4396-b8e9-c2650f981227 | openstack@tripleo_netapp | active | NW1           | 08633ba3317a45a1a46e90380e0e2ee0 | 2019-03-15T18:39:57.000000 |
    +--------------------------------------+--------------------------+--------+---------------+----------------------------------+----------------------------+

::

    $ manila manage openstack@tripleo_netapp#aggr1 NFS 100.250.119.20:/share_af64f5f8_e5e1_46ed_8f65_c578dfc44816 --share-server-id 4c4667d8-9491-4396-b8e9-c2650f981227
    +---------------------------------------+--------------------------------------+
    | Property                              | Value                                |
    +---------------------------------------+--------------------------------------+
    | status                                | manage_starting                      |
    | share_type_name                       | default                              |
    | description                           | None                                 |
    | availability_zone                     | None                                 |
    | share_network_id                      | 055e1697-99d4-482c-9a50-15632c327372 |
    | share_server_id                       | 4c4667d8-9491-4396-b8e9-c2650f981227 |
    | share_group_id                        | None                                 |
    | host                                  | openstack@tripleo_netapp#aggr1       |
    | revert_to_snapshot_support            | False                                |
    | access_rules_status                   | active                               |
    | snapshot_id                           | None                                 |
    | create_share_from_snapshot_support    | False                                |
    | is_public                             | False                                |
    | task_state                            | None                                 |
    | snapshot_support                      | False                                |
    | id                                    | d3ace42c-ab21-4577-af70-475adc811aec |
    | size                                  | None                                 |
    | source_share_group_snapshot_member_id | None                                 |
    | user_id                               | 3ba400f4c7cd428aad09594d2bd6b6b9     |
    | name                                  | None                                 |
    | share_type                            | d6a428cb-0287-47b9-9ab0-32229d477c32 |
    | has_replicas                          | False                                |
    | replication_type                      | None                                 |
    | created_at                            | 2019-03-15T18:44:29.000000           |
    | share_proto                           | NFS                                  |
    | mount_snapshot_support                | False                                |
    | project_id                            | 08633ba3317a45a1a46e90380e0e2ee0     |
    | metadata                              | {}                                   |
    +---------------------------------------+--------------------------------------+

We see here that the share has been assigned a new ``id`` and the share is renamed on
the backend as ``share_<share_instance_id>``.

::

    $ manila show d3ace42c-ab21-4577-af70-475adc811aec
    +---------------------------------------+-------------------------------------------------------------------+
    | Property                              | Value                                                             |
    +---------------------------------------+-------------------------------------------------------------------+
    | status                                | available                                                         |
    | share_type_name                       | default                                                           |
    | description                           | None                                                              |
    | availability_zone                     | nova                                                              |
    | share_network_id                      | 055e1697-99d4-482c-9a50-15632c327372                              |
    | export_locations                      |                                                                   |
    |                                       | path = 100.250.119.22:/share_f40a3fb1_4728_46b2_a277_df37b03080bb |
    |                                       | preferred = True                                                  |
    |                                       | is_admin_only = False                                             |
    |                                       | id = 4ed19ff8-fc97-41d7-a5ca-c71e0bd33894                         |
    |                                       | share_instance_id = f40a3fb1-4728-46b2-a277-df37b03080bb          |
    | share_server_id                       | 4c4667d8-9491-4396-b8e9-c2650f981227                              |
    | share_group_id                        | None                                                              |
    | host                                  | openstack@tripleo_netapp#aggr1                                    |
    | revert_to_snapshot_support            | False                                                             |
    | access_rules_status                   | active                                                            |
    | snapshot_id                           | None                                                              |
    | create_share_from_snapshot_support    | False                                                             |
    | is_public                             | False                                                             |
    | task_state                            | None                                                              |
    | snapshot_support                      | False                                                             |
    | id                                    | d3ace42c-ab21-4577-af70-475adc811aec                              |
    | size                                  | 1                                                                 |
    | source_share_group_snapshot_member_id | None                                                              |
    | user_id                               | 3ba400f4c7cd428aad09594d2bd6b6b9                                  |
    | name                                  | None                                                              |
    | share_type                            | d6a428cb-0287-47b9-9ab0-32229d477c32                              |
    | has_replicas                          | False                                                             |
    | replication_type                      | None                                                              |
    | created_at                            | 2019-03-15T18:44:29.000000                                        |
    | share_proto                           | NFS                                                               |
    | mount_snapshot_support                | False                                                             |
    | project_id                            | 08633ba3317a45a1a46e90380e0e2ee0                                  |
    | metadata                              | {}                                                                |
    +---------------------------------------+-------------------------------------------------------------------+

We'll now remove a share from Manila management using the admin-only
``unmanage`` CLI command. The syntax of the ``unmanage`` command is
the same for ``DHSS=True`` and ``DHSS=False``.

::

    $ manila unmanage eb470d1c-1a10-4025-8384-4fc44e81013a

.. _manage-share-server:

Managing and unmanaging Manila Share Servers
--------------------------------------------

Beginning with the Stein release, Manila supports managing and
unmanaging share servers. Using the admin-only ``manila share-server-manage``
command, share servers can be brought under Manila management.
For NetApp backends, each share server is analogous with a SVM. In
order to manage a share server, the end user should specify the host
which will house the share server. This would be of the
format ``host@backend``. The end user is also required to specify the
share network ID and the driver-specific identifier when managing a share
server. The example given below highlights how the command is invoked.

First, we obtain a list of the available hosts for Manila services.

::

    $ manila service-list
    +----+------------------+----------------------------+------+---------+-------+----------------------------+
    | Id | Binary           | Host                       | Zone | Status  | State | Updated_at                 |
    +----+------------------+----------------------------+------+---------+-------+----------------------------+
    | 1  | manila-scheduler | openstack                  | nova | enabled | up    | 2019-03-14T18:01:23.000000 |
    | 2  | manila-data      | openstack                  | nova | enabled | up    | 2019-03-14T18:01:27.000000 |
    | 3  | manila-share     | openstack@tripleo_netapp   | nova | enabled | up    | 2019-03-14T18:01:26.000000 |
    | 4  | manila-share     | openstack@tripleo_netapp_2 | nova | enabled | up    | 2019-03-14T18:01:26.000000 |
    +----+------------------+----------------------------+------+---------+-------+----------------------------+

Now, let us attempt to manage a share-server to the ``openstack@tripleo_netapp``
host. Given below is a list of SVMs present on the cluster that is defined
in the ``tripleo_netapp`` backend stanza.

::

    cluster1::> vserver show
                               Admin      Operational Root
    Vserver     Type    Subtype    State      State       Volume     Aggregate
    ----------- ------- ---------- ---------- ----------- ---------- ----------
    cluster1    admin   -          -          -           -          -
    cluster1-01 node    -          -          -           -          -
    openstack   data    default    running    running     openstack_ aggr1
                                                        root
    openstack_iscsi
                data    default    running    running     openstack_ aggr1
                                                          iscsi_root
    test_manage_share_server
                data    default    running    running     root       aggr1
    5 entries were displayed.

In order to migrate the ``test_manage_share_server`` SVM as a Manila share server,
it is important to ensure that the SVM has a LIF in the required share network.

::

    $ manila share-network-show 61bf7b38-d9fe-4776-bbf0-172cad2c789e
    +-------------------+--------------------------------------+
    | Property          | Value                                |
    +-------------------+--------------------------------------+
    | network_type      | flat                                 |
    | name              | Engg                                 |
    | segmentation_id   | None                                 |
    | created_at        | 2019-03-14T14:31:54.000000           |
    | neutron_subnet_id | None                                 |
    | updated_at        | 2019-03-14T17:56:26.000000           |
    | mtu               | 1500                                 |
    | gateway           | 100.250.116.1                        |
    | neutron_net_id    | None                                 |
    | ip_version        | 4                                    |
    | cidr              | 100.250.116.0/22                     |
    | project_id        | 08633ba3317a45a1a46e90380e0e2ee0     |
    | id                | 61bf7b38-d9fe-4776-bbf0-172cad2c789e |
    | description       | None                                 |
    +-------------------+--------------------------------------+

We will use the ``Engg`` share network. As a result, the SVM should have a LIF
with an IP address in this network.

::

    cluster1::> net int show -vserver test_manage_share_server
      (network interface show)
                Logical    Status     Network            Current       Current Is
    Vserver     Interface  Admin/Oper Address/Mask       Node          Port    Home
    ----------- ---------- ---------- ------------------ ------------- ------- ----
    test_manage_share_server
                data_lif_1   up/up    100.250.119.21/22  cluster1-01   e0a     true

We can now manage the share server using the ``manila share-server-manage``
command as follows:

::

    $ manila share-server-manage openstack@tripleo_netapp Engg test_manage_share_server
    +--------------------+--------------------------------------+
    | Property           | Value                                |
    +--------------------+--------------------------------------+
    | status             | manage_starting                      |
    | project_id         | 08633ba3317a45a1a46e90380e0e2ee0     |
    | backend_details    | {}                                   |
    | created_at         | 2019-03-14T18:17:11.000000           |
    | updated_at         | None                                 |
    | share_network_name | Engg                                 |
    | host               | openstack@tripleo_netapp             |
    | share_network_id   | 61bf7b38-d9fe-4776-bbf0-172cad2c789e |
    | identifier         | test_manage_share_server             |
    | id                 | b69be361-9dc9-446c-bd93-eb7050e7734d |
    | is_auto_deletable  | False                                |
    +--------------------+--------------------------------------+

We see here that the share server has been assigned a new ``id``
and is renamed on the backend as ``os_<id>``.

::

    $ manila share-server-list
    +--------------------------------------+--------------------------+--------+---------------+----------------------------------+----------------------------+
    | Id                                   | Host                     | Status | Share Network | Project Id                       | Updated_at                 |
    +--------------------------------------+--------------------------+--------+---------------+----------------------------------+----------------------------+
    | b69be361-9dc9-446c-bd93-eb7050e7734d | openstack@tripleo_netapp | active | Engg          | 08633ba3317a45a1a46e90380e0e2ee0 | 2019-03-14T18:17:11.000000 |
    +--------------------------------------+--------------------------+--------+---------------+----------------------------------+----------------------------+

The share server has been imported to Manila management. It is now available to
create shares. Let us now create a share on the newly managed share server. By
specifying the ``Engg`` share network, we ensure that the share will be created
on the newly managed share server.

::

    $ manila create --share-type dhss_true --share-network Engg NFS 1
    +---------------------------------------+--------------------------------------+
    | Property                              | Value                                |
    +---------------------------------------+--------------------------------------+
    | status                                | creating                             |
    | share_type_name                       | dhss_true                            |
    | description                           | None                                 |
    | availability_zone                     | None                                 |
    | share_network_id                      | 61bf7b38-d9fe-4776-bbf0-172cad2c789e |
    | share_server_id                       | None                                 |
    | share_group_id                        | None                                 |
    | host                                  |                                      |
    | revert_to_snapshot_support            | False                                |
    | access_rules_status                   | active                               |
    | snapshot_id                           | None                                 |
    | create_share_from_snapshot_support    | False                                |
    | is_public                             | False                                |
    | task_state                            | None                                 |
    | snapshot_support                      | False                                |
    | id                                    | e5bb02a6-966e-4941-9bbc-2c353af3a09d |
    | size                                  | 1                                    |
    | source_share_group_snapshot_member_id | None                                 |
    | user_id                               | 3ba400f4c7cd428aad09594d2bd6b6b9     |
    | name                                  | None                                 |
    | share_type                            | 63e41034-29cb-413f-96fe-7e9156993864 |
    | has_replicas                          | False                                |
    | replication_type                      | None                                 |
    | created_at                            | 2019-03-14T18:22:54.000000           |
    | share_proto                           | NFS                                  |
    | mount_snapshot_support                | False                                |
    | project_id                            | 08633ba3317a45a1a46e90380e0e2ee0     |
    | metadata                              | {}                                   |
    +---------------------------------------+--------------------------------------+

    $ manila show e5bb02a6-966e-4941-9bbc-2c353af3a09d
    +---------------------------------------+-------------------------------------------------------------------+
    | Property                              | Value                                                             |
    +---------------------------------------+-------------------------------------------------------------------+
    | status                                | available                                                         |
    | share_type_name                       | dhss_true                                                         |
    | description                           | None                                                              |
    | availability_zone                     | nova                                                              |
    | share_network_id                      | 61bf7b38-d9fe-4776-bbf0-172cad2c789e                              |
    | export_locations                      |                                                                   |
    |                                       | path = 100.250.119.21:/share_51fd3b96_5e66_4369_a725_d575b759d1ce |
    |                                       | preferred = True                                                  |
    |                                       | is_admin_only = False                                             |
    |                                       | id = 533718d0-4ac1-41e1-b482-0a92590fe974                         |
    |                                       | share_instance_id = 51fd3b96-5e66-4369-a725-d575b759d1ce          |
    | share_server_id                       | b69be361-9dc9-446c-bd93-eb7050e7734d                              |
    | share_group_id                        | None                                                              |
    | host                                  | openstack@tripleo_netapp#aggr1                                    |
    | revert_to_snapshot_support            | False                                                             |
    | access_rules_status                   | active                                                            |
    | snapshot_id                           | None                                                              |
    | create_share_from_snapshot_support    | False                                                             |
    | is_public                             | False                                                             |
    | task_state                            | None                                                              |
    | snapshot_support                      | False                                                             |
    | id                                    | e5bb02a6-966e-4941-9bbc-2c353af3a09d                              |
    | size                                  | 1                                                                 |
    | source_share_group_snapshot_member_id | None                                                              |
    | user_id                               | 3ba400f4c7cd428aad09594d2bd6b6b9                                  |
    | name                                  | None                                                              |
    | share_type                            | 63e41034-29cb-413f-96fe-7e9156993864                              |
    | has_replicas                          | False                                                             |
    | replication_type                      | None                                                              |
    | created_at                            | 2019-03-14T18:22:54.000000                                        |
    | share_proto                           | NFS                                                               |
    | mount_snapshot_support                | False                                                             |
    | project_id                            | 08633ba3317a45a1a46e90380e0e2ee0                                  |
    | metadata                              | {}                                                                |
    +---------------------------------------+-------------------------------------------------------------------+

The created share is available and we see the ``share_server_id``
corresponds to the managed share server.

To unmanage a share server, all shares present on the share
server should either be unmanaged or deleted. Once all the
shares present on the share server have been removed from
the Manila database, the share server can be unmanaged. It
can be done by calling the ``manila share-server-unmanage``
command, which is an admin-only operation.

::

    $ manila share-server-unmanage b69be361-9dc9-446c-bd93-eb7050e7734d


.. important::
    Since Train release, the Neutron network information that pertained to the
    share network entity was moved to the share network subnet entity. So you
    will also need to specify a share network subnet while managing a share
    server.

Creating Manila Share Groups
----------------------------

In this section, we'll create and work with share groups and
share group (SG) snapshots. First we list the share types
that are available and create a share group type. This will
be subsequently used to create a SG.

::

    $ manila type-list
    +--------------------------------------+---------+------------+------------+--------------------------------------+
    | ID                                   | Name    | Visibility | is_default | required_extra_specs                 |
    +--------------------------------------+---------+------------+------------+--------------------------------------+
    | 08d3b20f-3685-4f83-ba4f-efe9276e922c | zoom    | public     | -          | driver_handles_share_servers : False |
    | 30abd1a6-0f5f-426b-adb4-13e0062d3183 | default | public     | YES        | driver_handles_share_servers : False |
    | d7f70347-7464-4297-8d8e-12fa13e64775 | ontap   | public     | -          | driver_handles_share_servers : False |
    +--------------------------------------+---------+------------+------------+--------------------------------------+

::

    $ manila share-group-type-create type1 ontap
    +------------+--------------------------------------+
    | Property   | Value                                |
    +------------+--------------------------------------+
    | is_default | -                                    |
    | ID         | 516a089b-d9f6-40cf-8596-8b71feed9dba |
    | Visibility | public                               |
    | Name       | type1                                |
    +------------+--------------------------------------+

::

    $ manila share-group-type-list
    +--------------------------------------+---------+------------+------------+
    | ID                                   | Name    | visibility | is_default |
    +--------------------------------------+---------+------------+------------+
    | 516a089b-d9f6-40cf-8596-8b71feed9dba | sgtype1 | public     | -          |
    +--------------------------------------+---------+------------+------------+

Now we create a share group.

::

    $ manila share-group-create --name sg_1 --description "sg_1 share group" --share_group_type sgtype1 --share-type ontap
    +--------------------------------+--------------------------------------+
    | Property                       | Value                                |
    +--------------------------------+--------------------------------------+
    | status                         | creating                             |
    | description                    | sg_1 share group                     |
    | availability_zone              | None                                 |
    | created_at                     | 2018-08-15T18:52:14.285127           |
    | source_share_group_snapshot_id | None                                 |
    | share_network_id               | None                                 |
    | share_server_id                | None                                 |
    | host                           | None                                 |
    | share_group_type_id            | 516a089b-d9f6-40cf-8596-8b71feed9dba |
    | consistent_snapshot_support    | None                                 |
    | project_id                     | 0694797dd8b94fe3b862e34782d3cf39     |
    | share_types                    | e9ad1532-7592-4f73-b18c-93f67e7a6072 |
    | id                             | 0c30788d-8139-4c8f-b351-94fdd81a62fd |
    | name                           | sg_1                                 |
    +--------------------------------+--------------------------------------+

::

    $ manila share-group-list
    +--------------------------------------+------+-----------+------------------+
    | ID                                   | Name | Status    | Description      |
    +--------------------------------------+------+-----------+------------------+
    | 0c30788d-8139-4c8f-b351-94fdd81a62fd | sg_1 | available | sg_1 share group |
    +--------------------------------------+------+-----------+------------------+

::

    $ manila manila share-group-show 0c30788d-8139-4c8f-b351-94fdd81a62fd
    +--------------------------------+--------------------------------------+
    | Property                       | Value                                |
    +--------------------------------+--------------------------------------+
    | status                         | available                            |
    | description                    | sg_1 share group                     |
    | availability_zone              | az1                                  |
    | created_at                     | 2018-08-15T18:52:14.000000           |
    | source_share_group_snapshot_id | None                                 |
    | share_network_id               | None                                 |
    | share_server_id                | None                                 |
    | host                           | ubuntu@cmode_single_svm_nfs#aggr1    |
    | share_group_type_id            | 516a089b-d9f6-40cf-8596-8b71feed9dba |
    | consistent_snapshot_support    | host                                 |
    | project_id                     | 0694797dd8b94fe3b862e34782d3cf39     |
    | share_types                    | e9ad1532-7592-4f73-b18c-93f67e7a6072 |
    | id                             | 0c30788d-8139-4c8f-b351-94fdd81a62fd |
    | name                           | sg_1                                 |
    +--------------------------------+--------------------------------------+

Next we'll create two shares in the new share group.

::

    $ manila create --name share_1 --share-group "sg_1" --share_type "ontap" NFS 1
    +---------------------------------------+--------------------------------------+
    | Property                              | Value                                |
    +---------------------------------------+--------------------------------------+
    | status                                | creating                             |
    | share_type_name                       | ontap                                |
    | description                           | None                                 |
    | availability_zone                     | az1                                  |
    | share_network_id                      | None                                 |
    | share_server_id                       | None                                 |
    | share_group_id                        | 0c30788d-8139-4c8f-b351-94fdd81a62fd |
    | host                                  | ubuntu@cmode_single_svm_nfs#aggr1    |
    | revert_to_snapshot_support            | True                                 |
    | access_rules_status                   | active                               |
    | snapshot_id                           | None                                 |
    | create_share_from_snapshot_support    | True                                 |
    | is_public                             | False                                |
    | task_state                            | None                                 |
    | snapshot_support                      | True                                 |
    | id                                    | 781442fe-aadb-41ae-9b01-43bac0513344 |
    | size                                  | 1                                    |
    | source_share_group_snapshot_member_id | None                                 |
    | user_id                               | fb1433ad5aa844059b812cb07ac43e89     |
    | name                                  | share_1                              |
    | share_type                            | e9ad1532-7592-4f73-b18c-93f67e7a6072 |
    | has_replicas                          | False                                |
    | replication_type                      | None                                 |
    | created_at                            | 2018-08-15T18:53:54.000000           |
    | share_proto                           | NFS                                  |
    | mount_snapshot_support                | False                                |
    | project_id                            | 0694797dd8b94fe3b862e34782d3cf39     |
    | metadata                              | {}                                   |
    +---------------------------------------+--------------------------------------+

::

    $ manila create --name share_2 --share-group "sg_1" --share_type "ontap" NFS 1
    +---------------------------------------+--------------------------------------+
    | Property                              | Value                                |
    +---------------------------------------+--------------------------------------+
    | status                                | creating                             |
    | share_type_name                       | ontap                                |
    | description                           | None                                 |
    | availability_zone                     | az1                                  |
    | share_network_id                      | None                                 |
    | share_server_id                       | None                                 |
    | share_group_id                        | 0c30788d-8139-4c8f-b351-94fdd81a62fd |
    | host                                  | ubuntu@cmode_single_svm_nfs#aggr1    |
    | revert_to_snapshot_support            | True                                 |
    | access_rules_status                   | active                               |
    | snapshot_id                           | None                                 |
    | create_share_from_snapshot_support    | True                                 |
    | is_public                             | False                                |
    | task_state                            | None                                 |
    | snapshot_support                      | True                                 |
    | id                                    | b60160f7-1b76-42e2-b9d7-e9bfd64d043c |
    | size                                  | 1                                    |
    | source_share_group_snapshot_member_id | None                                 |
    | user_id                               | fb1433ad5aa844059b812cb07ac43e89     |
    | name                                  | share_2                              |
    | share_type                            | e9ad1532-7592-4f73-b18c-93f67e7a6072 |
    | has_replicas                          | False                                |
    | replication_type                      | None                                 |
    | created_at                            | 2018-08-15T18:54:10.000000           |
    | share_proto                           | NFS                                  |
    | mount_snapshot_support                | False                                |
    | project_id                            | 0694797dd8b94fe3b862e34782d3cf39     |
    | metadata                              | {}                                   |
    +---------------------------------------+--------------------------------------+

Next we'll create two SG snapshots of the new share group.

::

    $ manila share-group-snapshot-create --name snapshot_1 --description 'first snapshot of sg-1' 'sg_1'
    +----------------+--------------------------------------+
    | Property       | Value                                |
    +----------------+--------------------------------------+
    | status         | creating                             |
    | name           | snapshot_1                           |
    | created_at     | 2018-08-15T18:55:03.250498           |
    | share_group_id | 0c30788d-8139-4c8f-b351-94fdd81a62fd |
    | project_id     | 0694797dd8b94fe3b862e34782d3cf39     |
    | id             | a83e8c4b-435f-4185-aeb4-193448006d21 |
    | description    | first snapshot of sg_1               |
    +----------------+--------------------------------------+

::

    $ manila share-group-snapshot-list
    +--------------------------------------+------------+-----------+------------------------+
    | id                                   | name       | status    | description            |
    +--------------------------------------+------------+-----------+------------------------+
    | a83e8c4b-435f-4185-aeb4-193448006d21 | snapshot_1 | available | first snapshot of sg_1 |
    +--------------------------------------+------------+-----------+------------------------+

::

    $ manila share-group-snapshot-show a83e8c4b-435f-4185-aeb4-193448006d21
    +----------------+--------------------------------------+
    | Property       | Value                                |
    +----------------+--------------------------------------+
    | status         | available                            |
    | name           | snapshot_1                           |
    | created_at     | 2018-08-15T18:55:03.000000           |
    | share_group_id | 0c30788d-8139-4c8f-b351-94fdd81a62fd |
    | project_id     | 0694797dd8b94fe3b862e34782d3cf39     |
    | id             | a83e8c4b-435f-4185-aeb4-193448006d21 |
    | description    | first snapshot of sg_1               |
    +----------------+--------------------------------------+

::

    $ manila share-group-snapshot-create --name snapshot_2 --description 'second snapshot of sg-1' 'sg_1'
    +----------------+--------------------------------------+
    | Property       | Value                                |
    +----------------+--------------------------------------+
    | status         | creating                             |
    | name           | snapshot_2                           |
    | created_at     | 2018-08-15T18:57:40.225911           |
    | share_group_id | 0c30788d-8139-4c8f-b351-94fdd81a62fd |
    | project_id     | 0694797dd8b94fe3b862e34782d3cf39     |
    | id             | 0b53bd61-309a-47df-8c07-91d14fa7f21f |
    | description    | second snapshot of sg_1              |
    +----------------+--------------------------------------+

::

    $ manila share-group-snapshot-list
    +--------------------------------------+------------+-----------+-------------------------+
    | id                                   | name       | status    | description             |
    +--------------------------------------+------------+-----------+-------------------------+
    | 0b53bd61-309a-47df-8c07-91d14fa7f21f | snapshot_2 | available | second snapshot of sg_1 |
    | a83e8c4b-435f-4185-aeb4-193448006d21 | snapshot_1 | available | first snapshot of sg_1  |
    +--------------------------------------+------------+-----------+-------------------------+

Finally we'll create a new SG from one of the SG snapshots we created
above.

::

    $  manila share-group-create --name sg_2 --source-share-group-snapshot 0b53bd61-309a-47df-8c07-91d14fa7f21f --share-group-type sgtype1
    +--------------------------------+--------------------------------------+
    | Property                       | Value                                |
    +--------------------------------+--------------------------------------+
    | status                         | creating                             |
    | description                    | None                                 |
    | availability_zone              | az1                                  |
    | created_at                     | 2018-08-15T18:59:47.844886           |
    | source_share_group_snapshot_id | 0b53bd61-309a-47df-8c07-91d14fa7f21f |
    | share_network_id               | None                                 |
    | share_server_id                | None                                 |
    | host                           | ubuntu@cmode_single_svm_nfs#aggr1    |
    | share_group_type_id            | 516a089b-d9f6-40cf-8596-8b71feed9dba |
    | consistent_snapshot_support    | None                                 |
    | project_id                     | 0694797dd8b94fe3b862e34782d3cf39     |
    | share_types                    | e9ad1532-7592-4f73-b18c-93f67e7a6072 |
    | id                             | 5156c78b-a540-4d32-9249-70f7ccb7167d |
    | name                           | sg_2                                 |
    +--------------------------------+--------------------------------------+

Creating Manila Share Replicas
------------------------------

Starting from Train release, manila allows the creation of share replicas in
both 'driver_handles_share_servers' True and False modes. In this section,
we'll create and use share replicas. Most operations are equal for both
'driver_handles_share_servers' True and False modes, however the creation of
the share is different, as shown below.

.. note::

    The examples below are using ``dr`` replication type, but starting from Xena
    release, the user can also set ``replication_type`` to ``readable``.

Creating a Share Replica Without Share Server management
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We'll start creating a share replica
operating under `driver_handles_share_servers=False` mode. Then, we'll start
creating a share type.

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

Assign replication_type and snapshot_support attributes to the replication share-type.

::

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

::

    $ manila show f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc
    +----------------------------+-----------------------------------------------------------------+
    | Property                   |Value                                                            |
    +----------------------------+-----------------------------------------------------------------+
    | status                     |available                                                        |
    | share_type_name            |replication                                                      |
    | description                |None                                                             |
    | availability_zone          |nova                                                             |
    | share_network_id           |None                                                             |
    | export_locations           |                                                                 |
    |                            |path = 172.20.124.230:/share_11265e8a_200c_4e0a_a40f_b7a1117001ed|
    |                            |preferred = True                                                 |
    |                            |is_admin_only = False                                            |
    |                            |id = d9634102-e859-42ab-842e-687c209067e3                        |
    |                            |share_instance_id = 11265e8a-200c-4e0a-a40f-b7a1117001ed         |
    | share_server_id            |None                                                             |
    | host                       |openstack2@cmodeSSVMNFS#aggr3                                    |
    | access_rules_status        |active                                                           |
    | snapshot_id                |None                                                             |
    | is_public                  |False                                                            |
    | task_state                 |None                                                             |
    | snapshot_support           |True                                                             |
    | id                         |f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc                             |
    | size                       |1                                                                |
    | name                       |None                                                             |
    | share_type                 |ce1709ef-0b20-4cbf-9fc0-2b75adfee9b8                             |
    | has_replicas               |False                                                            |
    | replication_type           |dr                                                               |
    | created_at                 |2016-03-23T18:16:22.000000                                       |
    | share_proto                |NFS                                                              |
    | consistency_group_id       |None                                                             |
    | source_cgsnapshot_member_id|None                                                             |
    | project_id                 |3d1d93550b1448f094389d6b5df9659e                                 |
    | metadata                   |{}                                                               |
    +----------------------------+-----------------------------------------------------------------+

When a share is created with a share type that has the replication\_type
extra spec, it will be treated as the primary/'active' replica. Let's
list the replicas.

::

    $ manila share-replica-list --share-id f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc
    +--------------------------------------+-----------+---------------+--------------------------------------+------------------------------+-------------------+----------------------------+
    | ID                                   | Status    | Replica State | Share ID                             | Host                         | Availability Zone | Updated At                 |
    +--------------------------------------+-----------+---------------+--------------------------------------+------------------------------+-------------------+----------------------------+
    | 11265e8a-200c-4e0a-a40f-b7a1117001ed | available | active        | f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc | openstack2@cmodeSSVMNFS#aggr3| nova              | 2016-03-23T18:16:34.000000 |
    +--------------------------------------+-----------+---------------+--------------------------------------+------------------------------+-------------------+----------------------------+

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

::

    $ manila share-replica-show b3191744-cee9-478b-b906-c5a7a3934adb
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
become in-sync, refer to the section called :ref:`common-probs`.

::

    $ manila share-replica-list --share-id f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc
    +--------------------------------------+-----------+---------------+--------------------------------------+-------------------------------------+-------------------+----------------------------+
    | ID                                   | Status    | Replica State | Share ID                             | Host                                | Availability Zone | Updated At                 |
    +--------------------------------------+-----------+---------------+--------------------------------------+-------------------------------------+-------------------+----------------------------+
    | 11265e8a-200c-4e0a-a40f-b7a1117001ed | available | active        | f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc | openstack2@cmodeSSVMNFS#aggr3       | nova              | 2016-03-23T18:16:34.000000 |
    | b3191744-cee9-478b-b906-c5a7a3934adb | available | in_sync       | f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc | openstack2@cmodeSSVMNFS2#aggr4      | nova              | 2016-03-23T18:27:57.000000 |
    +--------------------------------------+-----------+---------------+--------------------------------------+-------------------------------------+-------------------+----------------------------+

Creating a Share Replica With Share Server management
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Now, let's see how it works when manila is operating under
`driver_handles_share_servers=True` mode. In the below example, a share
replica will be created on the availability zone ``nova2``, however there is no
need to specify an availability zone. In order to make this operation work when
you are specifying an availability zone, you must make sure that the source
share's share network contains a default share network subnet, or a share
network subnet in the availability zone which you're willing to create the
share replica. So let's start creating a compatible share type.

::

    $ manila type-create replication_dhss_true true
    +----------------------+--------------------------------------+
    | Property             | Value                                |
    +----------------------+--------------------------------------+
    | ID                   | c228657c-49e6-4649-80d2-24fa025c4984 |
    | Name                 | replication_dhss_true                |
    | Visibility           | public                               |
    | is_default           | -                                    |
    | required_extra_specs | driver_handles_share_servers : True  |
    | optional_extra_specs |                                      |
    | Description          | None                                 |
    +----------------------+--------------------------------------+

Assign replication_type and snapshot_support properties to the
replication_dhss_true share-type

::

    $ manila type-key replication_dhss_true set replication_type=dr \
                                                snapshot_support=True

Next we'll create a share.

::

    $ manila create NFS 1 --share-type replication_dhss_true \
                            --name source_share \
                            --share-network storage-provider-network
    +---------------------------------------+--------------------------------------+
    | Property                              | Value                                |
    +---------------------------------------+--------------------------------------+
    | id                                    | e903ea09-46fa-4f25-98d1-4d12634325e6 |
    | size                                  | 1                                    |
    | availability_zone                     | None                                 |
    | created_at                            | 2020-01-22T17:32:58.000000           |
    | status                                | creating                             |
    | name                                  | source_share                         |
    | description                           | None                                 |
    | project_id                            | 3d1d93550b1448f094389d6b5df9659e     |
    | snapshot_id                           | None                                 |
    | share_network_id                      | d9e443b6-a6fe-4443-a1ef-661af09e4a66 |
    | share_proto                           | NFS                                  |
    | metadata                              | {}                                   |
    | share_type                            | c228657c-49e6-4649-80d2-24fa025c4984 |
    | is_public                             | False                                |
    | snapshot_support                      | False                                |
    | task_state                            | None                                 |
    | share_type_name                       | replication_dhss_true                |
    | access_rules_status                   | active                               |
    | replication_type                      | dr                                   |
    | has_replicas                          | False                                |
    | user_id                               | 2a828565129b4949aaf7e692fc9b1ad8     |
    | create_share_from_snapshot_support    | False                                |
    | revert_to_snapshot_support            | False                                |
    | share_group_id                        | None                                 |
    | source_share_group_snapshot_member_id | None                                 |
    | mount_snapshot_support                | False                                |
    | share_server_id                       | None                                 |
    | host                                  |                                      |
    +---------------------------------------+--------------------------------------+

Next, we'll create a new share network subnet under the source share's share
network, specifying the desired availability zone, which is `nova2`.

::

    $ manila share-network-subnet-create storage-provider-network \
                --neutron-net-id 51615112-b7c1-4e66-9f9b-bd3dd2dc711b \
                --neutron-subnet-id c2a30101-52f9-4634-ac68-875f37583714 \
                --availability-zone nova2
    +--------------------+--------------------------------------+
    | Property           | Value                                |
    +--------------------+--------------------------------------+
    | id                 | a98e815e-4c86-4e97-846c-36b449079cd9 |
    | availability_zone  | nova2                                |
    | share_network_id   | d9e443b6-a6fe-4443-a1ef-661af09e4a66 |
    | share_network_name | storage-provider-network             |
    | created_at         | 2020-01-22T17:36:13.000000           |
    | segmentation_id    | None                                 |
    | neutron_subnet_id  | c2a30101-52f9-4634-ac68-875f37583714 |
    | updated_at         | None                                 |
    | neutron_net_id     | 51615112-b7c1-4e66-9f9b-bd3dd2dc711b |
    | ip_version         | None                                 |
    | cidr               | None                                 |
    | network_type       | None                                 |
    | mtu                | None                                 |
    | gateway            | None                                 |
    +--------------------+--------------------------------------+

Now, let's create the share replica specifying the availability zone we want
the replica to be placed.

::

    $ manila share-replica-create source_share --availability-zone nova2
    +------------------------+--------------------------------------+
    | Property               | Value                                |
    +------------------------+--------------------------------------+
    | id                     | d053c972-e171-4550-92ce-09b77567102f |
    | share_id               | e903ea09-46fa-4f25-98d1-4d12634325e6 |
    | availability_zone      | nova2                                |
    | created_at             | 2020-01-22T19:07:33.152431           |
    | status                 | creating                             |
    | share_network_id       | d9e443b6-a6fe-4443-a1ef-661af09e4a66 |
    | replica_state          | None                                 |
    | updated_at             | None                                 |
    | share_server_id        | None                                 |
    | host                   |                                      |
    | cast_rules_to_readonly | False                                |
    +------------------------+--------------------------------------+

::

    $ manila share-replica-show d053c972-e171-4550-92ce-09b77567102f
    +------------------------+--------------------------------------+
    | Property               | Value                                |
    +------------------------+--------------------------------------+
    | id                     | d053c972-e171-4550-92ce-09b77567102f |
    | share_id               | e903ea09-46fa-4f25-98d1-4d12634325e6 |
    | availability_zone      | nova2                                |
    | created_at             | 2020-01-22T19:07:33.000000           |
    | status                 | available                            |
    | share_network_id       | d9e443b6-a6fe-4443-a1ef-661af09e4a66 |
    | replica_state          | out_of_sync                          |
    | updated_at             | 2020-01-22T19:10:05.000000           |
    | share_server_id        | 343ff007-d399-4ede-b8ea-d43c5a516544 |
    | host                   | openstack2@cmodeMSVMNFS2#aggr1       |
    | cast_rules_to_readonly | False                                |
    | export_locations       | []                                   |
    +------------------------+--------------------------------------+

Now, we will list all the replicas of the 'source_share'. We will realize that
the new replica is located on 'openstack2@cmodeMSVMNFS2#aggr1' pool. The brand
new replica has a replica state of 'out\_of\_sync', which means that the share
data has not been synchronized within the replication window, which is one
hour for the cDOT driver.

::

    $ manila share-replica-list
    +--------------------------------------+-----------+---------------+--------------------------------------+--------------------------------+-------------------+----------------------------+
    | ID                                   | Status    | Replica State | Share ID                             | Host                           | Availability Zone | Updated At                 |
    +--------------------------------------+-----------+---------------+--------------------------------------+--------------------------------+-------------------+----------------------------+
    | 3bdc6dad-0470-4b9b-bb05-80d8e412c8ba | available | active        | e903ea09-46fa-4f25-98d1-4d12634325e6 | openstack2@cmodeMSVMNFS1#aggr1 | nova              | 2020-01-22T17:33:01.000000 |
    | d053c972-e171-4550-92ce-09b77567102f | creating  | out_of_sync   | e903ea09-46fa-4f25-98d1-4d12634325e6 | openstack2@cmodeMSVMNFS2#aggr1 | nova2             | 2020-01-22T19:07:34.000000 |
    +--------------------------------------+-----------+---------------+--------------------------------------+--------------------------------+-------------------+----------------------------+

Manila checks the status of a replica based on the
``replica_state_update_interval`` configuration option. If we wait for a
short while, the replica will become in sync. If the replica does not
become in sync, refer to the section called :ref:`common-probs`.

::

    $ manila share-replica-list --share-id e903ea09-46fa-4f25-98d1-4d12634325e6
    +--------------------------------------+-----------+---------------+--------------------------------------+-------------------------------+-------------------+----------------------------+
    | ID                                   | Status    | Replica State | Share ID                             | Host                          | Availability Zone | Updated At                 |
    +--------------------------------------+-----------+---------------+--------------------------------------+-------------------------------+-------------------+----------------------------+
    | 3bdc6dad-0470-4b9b-bb05-80d8e412c8ba | available | active        | e903ea09-46fa-4f25-98d1-4d12634325e6 | devstack2@cmodeMSVMNFS1#aggr1 | nova              | 2020-01-22T17:33:01.000000 |
    | d053c972-e171-4550-92ce-09b77567102f | available | in_sync       | e903ea09-46fa-4f25-98d1-4d12634325e6 | devstack2@cmodeMSVMNFS2#aggr1 | nova2             | 2020-01-22T19:10:05.000000 |
    +--------------------------------------+-----------+---------------+--------------------------------------+-------------------------------+-------------------+----------------------------+

Promoting a share replica
~~~~~~~~~~~~~~~~~~~~~~~~~

Finally, let's see the promote process for the share replica. This operation
is the same for both 'driver_handles_share_servers' True and False modes.

::

    $ manila share-replica-promote b3191744-cee9-478b-b906-c5a7a3934adb

::

    $ manila share-replica-list --share-id f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc
    +--------------------------------------+--------------------+---------------+--------------------------------------+-------------------------------------+-------------------+----------------------------+
    | ID                                   | Status             | Replica State | Share ID                             | Host                                | Availability Zone | Updated At                 |
    +--------------------------------------+--------------------+---------------+--------------------------------------+-------------------------------------+-------------------+----------------------------+
    | 11265e8a-200c-4e0a-a40f-b7a1117001ed | available          | active        | f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc | openstack2@cmodeSSVMNFS#aggr3       | nova              | 2016-03-23T18:16:34.000000 |
    | b3191744-cee9-478b-b906-c5a7a3934adb | replication_change | in_sync       | f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc | openstack2@cmodeSSVMNFS2#aggr4      | nova              | 2016-03-23T18:31:08.000000 |
    +--------------------------------------+--------------------+---------------+--------------------------------------+-------------------------------------+-------------------+----------------------------+

::

    $ manila share-replica-list --share-id f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc
    +--------------------------------------+-----------+---------------+--------------------------------------+-------------------------------------+-------------------+----------------------------+
    | ID                                   | Status    | Replica State | Share ID                             | Host                                | Availability Zone | Updated At                 |
    +--------------------------------------+-----------+---------------+--------------------------------------+-------------------------------------+-------------------+----------------------------+
    | 11265e8a-200c-4e0a-a40f-b7a1117001ed | available | out_of_sync   | f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc | openstack2@cmodeSSVMNFS#aggr3       | nova              | 2016-03-23T18:31:35.000000 |
    | b3191744-cee9-478b-b906-c5a7a3934adb | available | active        | f49d7f1f-15e7-484a-83d9-5eb5fb6ad7fc | openstack2@cmodeSSVMNFS2#aggr4      | nova              | 2016-03-23T18:31:35.000000 |
    +--------------------------------------+-----------+---------------+--------------------------------------+-------------------------------------+-------------------+----------------------------+

Migrating Manila Shares
-----------------------

In this section, we'll migrate a share from one pool to another.

::

    $ manila migration-start myFlash ocata@cmode_multi_svm_nfs#manila --writable False \
                                                                      --preserve-snapshots True \
                                                                      --preserve-metadata True \
                                                                      --nondisruptive True

We can check the migration progress by using the ``migration-get-progress`` command.

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

Migrating Manila Share Servers
------------------------------

Starting from Victoria release, manila supports the migration of share servers
across and within back ends. As with share migration, this operation was built
to operate in two different phases, which involves at least two operations
to be requested, the "start" and "complete" operations.

In this section, we'll migrate a share server to a new back end, that is placed
in a different cluster.

.. note::
   NetApp driver only supports share server migration across clusters, that
   must be peered in advance.

Before starting the share server migration, we can use the
``share-server-migration-check`` operation to check if the destination back end
is compatible with our existing share server.

::

    $ manila share-server-migration-check f3089d4f-89e8-4730-b6e6-7cab553df071 openstack2@cmodeMSVMNFS2 \
                                                                               --nondisruptive False \
                                                                               --writable True \
                                                                               --preserve_snapshots True
    +------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Property               | Value                                                                                                                                                                                         |
    +------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | compatible             | True                                                                                                                                                                                          |
    | requested_capabilities | {'writable': 'True', 'nondisruptive': 'False', 'preserve_snapshots': 'True', 'share_network_id': None, 'host': 'openstack2@cmodeMSVMNFS2'}                                                    |
    | supported_capabilities | {'writable': True, 'nondisruptive': False, 'preserve_snapshots': True, 'share_network_id': 'ac8e103f-c21a-4442-bddc-fdadee093099', 'migration_cancel': True, 'migration_get_progress': False} |
    +------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

.. note::
   Until Wallaby release, the NetApp ONTAP driver for Manila only supports
   disruptive share server migration.

.. note::
   As from Xena release, the NetApp ONTAP driver supports non-disruptive
   migrations if no network changes were identified and the preconditions
   described :ref:`here <server_migration_with_svm_migrate>` are met.

Now that we know that the destination back end is compatible with our share
server, we can start the migration, using the same parameters.

::

    $ manila share-server-migration-start f3089d4f-89e8-4730-b6e6-7cab553df071 openstack2@cmodeMSVMNFS2 \
                                                                               --nondisruptive False \
                                                                               --writable True \
                                                                               --preserve_snapshots True

After starting the migration we can check its progress and current task state
using the command ``share-server-migration-get-progress``.

::

    $ manila share-server-migration-get-progress f3089d4f-89e8-4730-b6e6-7cab553df071
    +-----------------------------+--------------------------------------+
    | Property                    | Value                                |
    +-----------------------------+--------------------------------------+
    | total_progress              | 0                                    |
    | task_state                  | migration_driver_in_progress         |
    | destination_share_server_id | f3fb808f-c2a4-4caa-9805-7caaf55c0522 |
    +-----------------------------+--------------------------------------+

And finally, once that the task state has transitioned to
``migration_driver_phase1_done``, we can complete the migration process.

::

    $ manila share-server-migration-complete f3089d4f-89e8-4730-b6e6-7cab553df071
    +-----------------------------+--------------------------------------+
    | Property                    | Value                                |
    +-----------------------------+--------------------------------------+
    | destination_share_server_id | f3fb808f-c2a4-4caa-9805-7caaf55c0522 |
    +-----------------------------+--------------------------------------+

.. note::
   The share server migration can be canceled using the command
   ``share-server-migration-cancel``, while the operation remains in the 1st
   phase, with its task state at ``migration_driver_in_progress`` or
   ``migration_driver_phase1_done``.

Setting up share server with multiple subnets
---------------------------------------------

Starting from Yoga release, manila supports the share network AZ containing
multiple share network subnets. As result, the share server created in
this share network and AZ will be configured with allocation of each subnet.

In this section, we'll create a share network with multiple share network
subnets. Then, we'll trigger a creation of share with its share server. This
share server will have allocation of each subnet.

.. note::

   NetApp driver only supports multiple share network subnets on the same
   VLAN segment.


The neutron has a network called ``private`` in the VLAN segment ``3371``, as
shows:

::

    $ openstack network show private
    +---------------------------+----------------------------------------------------------------------------+
    | Field                     | Value                                                                      |
    +---------------------------+----------------------------------------------------------------------------+
    | admin_state_up            | UP                                                                         |
    | availability_zone_hints   |                                                                            |
    | availability_zones        |                                                                            |
    | created_at                | 2023-01-19T01:07:13Z                                                       |
    | description               |                                                                            |
    | dns_domain                | None                                                                       |
    | id                        | fafb5141-bbd8-4905-aacc-ffaa382f5595                                       |
    | ipv4_address_scope        | None                                                                       |
    | ipv6_address_scope        | None                                                                       |
    | is_default                | None                                                                       |
    | is_vlan_transparent       | None                                                                       |
    | mtu                       | 1500                                                                       |
    | name                      | private                                                                    |
    | port_security_enabled     | True                                                                       |
    | project_id                | 3d70d4a77f80405783505b0841b7d06f                                           |
    | provider:network_type     | vlan                                                                       |
    | provider:physical_network | public                                                                     |
    | provider:segmentation_id  | 3371                                                                       |
    | qos_policy_id             | None                                                                       |
    | revision_number           | 3                                                                          |
    | router:external           | Internal                                                                   |
    | segments                  | None                                                                       |
    | shared                    | False                                                                      |
    | status                    | ACTIVE                                                                     |
    | subnets                   | 960bca38-0b9a-4d4b-9709-e94e0d088e75, deacbbee-761a-4ffb-8a6e-637f076233a6 |
    | tags                      |                                                                            |
    | tenant_id                 | 3d70d4a77f80405783505b0841b7d06f                                           |
    | updated_at                | 2023-02-28T12:05:28Z                                                       |
    +---------------------------+----------------------------------------------------------------------------+

The ``private`` network has two subnets, the first one:

::

    $ openstack subnet show 960bca38-0b9a-4d4b-9709-e94e0d088e75
    +----------------------+--------------------------------------+
    | Field                | Value                                |
    +----------------------+--------------------------------------+
    | allocation_pools     | 10.0.0.2-10.0.0.62                   |
    | cidr                 | 10.0.0.0/26                          |
    | created_at           | 2023-01-19T01:10:33Z                 |
    | description          |                                      |
    | dns_nameservers      |                                      |
    | dns_publish_fixed_ip | None                                 |
    | enable_dhcp          | True                                 |
    | gateway_ip           | 10.0.0.1                             |
    | host_routes          |                                      |
    | id                   | 960bca38-0b9a-4d4b-9709-e94e0d088e75 |
    | ip_version           | 4                                    |
    | ipv6_address_mode    | None                                 |
    | ipv6_ra_mode         | None                                 |
    | name                 | private_sub_ipv4                     |
    | network_id           | fafb5141-bbd8-4905-aacc-ffaa382f5595 |
    | project_id           | 3d70d4a77f80405783505b0841b7d06f     |
    | revision_number      | 0                                    |
    | segment_id           | None                                 |
    | service_types        |                                      |
    | subnetpool_id        | 008fb194-7098-4f24-bd27-ea66b3e463b7 |
    | tags                 |                                      |
    | updated_at           | 2023-01-19T01:10:33Z                 |
    +----------------------+--------------------------------------+

The ``private`` network has two subnets, the second one:

::

    $ openstack subnet show deacbbee-761a-4ffb-8a6e-637f076233a6
    +----------------------+--------------------------------------+
    | Field                | Value                                |
    +----------------------+--------------------------------------+
    | allocation_pools     | 10.0.0.66-10.0.0.126                 |
    | cidr                 | 10.0.0.64/26                         |
    | created_at           | 2023-02-28T12:05:28Z                 |
    | description          |                                      |
    | dns_nameservers      |                                      |
    | dns_publish_fixed_ip | None                                 |
    | enable_dhcp          | True                                 |
    | gateway_ip           | 10.0.0.65                            |
    | host_routes          |                                      |
    | id                   | deacbbee-761a-4ffb-8a6e-637f076233a6 |
    | ip_version           | 4                                    |
    | ipv6_address_mode    | None                                 |
    | ipv6_ra_mode         | None                                 |
    | name                 | private_sub2_ipv4                    |
    | network_id           | fafb5141-bbd8-4905-aacc-ffaa382f5595 |
    | project_id           | 3d70d4a77f80405783505b0841b7d06f     |
    | revision_number      | 0                                    |
    | segment_id           | None                                 |
    | service_types        |                                      |
    | subnetpool_id        | 008fb194-7098-4f24-bd27-ea66b3e463b7 |
    | tags                 |                                      |
    | updated_at           | 2023-02-28T12:05:28Z                 |
    +----------------------+--------------------------------------+

With this neutron configuration, we can create a Manila share network called
``my_test_net`` in the AZ ``nova`` containing the first subnet of the
``private`` neutron network:

::

    $ manila share-network-create --name my_test_net --neutron-net-id fafb5141-bbd8-4905-aacc-ffaa382f5595 \
                                                                               --neutron-subnet-id 960bca38-0b9a-4d4b-9709-e94e0d088e75 \
                                                                               --availability-zone nova

The ``my_test_net`` has one share network subnet in the ``nova`` AZ.
Now, we add the second neutron subnet:

::

    $ manila share-network-subnet-create my_test_net --neutron-net-id fafb5141-bbd8-4905-aacc-ffaa382f5595 \
                                                                               --neutron-subnet-id deacbbee-761a-4ffb-8a6e-637f076233a6 \
                                                                               --availability-zone nova

As result, the ``my_test_net`` in the ``nova`` AZ has two share network
subnets. Then, we create a share that will trigger the creation of a share
server with the multiple allocations (one for each subnet):

::

    $ manila create NFS 1 --share-type dhss_true --share-network my_test_net --availability-zone nova

The share server ``85016a6d-2e71-45bf-85ce-4a98b9ccb80a`` has been created.
It has one allocation of each subnet as the field
``details:ports`` shows:

::

    $ manila share-server-show 85016a6d-2e71-45bf-85ce-4a98b9ccb80a
    +-----------------------------------+-----------------------------------------------------------------------------------------------------------+
    | Property                          | Value                                                                                                     |
    +-----------------------------------+-----------------------------------------------------------------------------------------------------------+
    | id                                | 85016a6d-2e71-45bf-85ce-4a98b9ccb80a                                                                      |
    | project_id                        | 3d70d4a77f80405783505b0841b7d06f                                                                          |
    | updated_at                        | 2023-02-28T12:37:20.203149                                                                                |
    | status                            | active                                                                                                    |
    | host                              | 55-felipen-vm@netapp1                                                                                     |
    | share_network_name                | my_test_net                                                                                               |
    | share_network_id                  | 8b04355a-e6c6-45e6-8fbb-77e2ee3a637f                                                                      |
    | created_at                        | 2023-02-28T12:37:10.814669                                                                                |
    | is_auto_deletable                 | True                                                                                                      |
    | identifier                        | 85016a6d-2e71-45bf-85ce-4a98b9ccb80a                                                                      |
    | task_state                        | None                                                                                                      |
    | source_share_server_id            | None                                                                                                      |
    | security_service_update_support   | True                                                                                                      |
    | share_network_subnet_ids          | ['4e93a90b-886b-4fcc-a0a7-df27903d9b0a', '54421e94-9091-4a6f-9834-c40f11ed81f6']                          |
    | network_allocation_update_support | True                                                                                                      |
    | details:vserver_name              | felipen_85016a6d-2e71-45bf-85ce-4a98b9ccb80a                                                              |
    | details:ports                     | {"beb6dd0a-28ce-4221-aef7-f5082e58e712": "10.0.0.96", "3036c494-9c04-43fb-89f9-a74e84370ecf": "10.0.0.8"} |
    | details:nfs_config                | {"tcp-max-xfer-size": "65536", "udp-max-xfer-size": "32768"}                                              |
    +-----------------------------------+-----------------------------------------------------------------------------------------------------------+

In ONTAP side, we can see that the equivalent vserver has the interfaces for
each subnet (all being on the same VLAN segment):

::

    OSTK-select25::> network interface show -vserver felipen_85016a6d-2e71-45bf-85ce-4a98b9ccb80a
                Logical    Status     Network            Current       Current Is
    Vserver     Interface  Admin/Oper Address/Mask       Node          Port    Home
    ----------- ---------- ---------- ------------------ ------------- ------- ----
    felipen_85016a6d-2e71-45bf-85ce-4a98b9ccb80a
                os_3036c494-9c04-43fb-89f9-a74e84370ecf
                             up/up    10.0.0.8/26        OSTK-select25-01
                                                                       e0b-3371
                                                                               true
                os_beb6dd0a-28ce-4221-aef7-f5082e58e712
                            up/up    10.0.0.96/26       OSTK-select25-01
                                                                       e0b-3371
                                                                               true

Adding subnet for existing share server
-------------------------------------------

Starting from Yoga release, manila supports the share network AZ containing
multiple share network subnets. As result, an existing share server with
a single share network subnet can be updated with a new subnet.

In this section, we'll add a new share network subnet for a share network that
contains a share server. It will trigger an update of share server allocations
adding a new one for the added share network subnet.

.. note::
   NetApp driver only supports multiple share network subnets on the same
   VLAN segment.

The neutron has a network called ``private`` in the VLAN segment ``3371``, as
shows:

::

    $ openstack network show private
    +---------------------------+----------------------------------------------------------------------------+
    | Field                     | Value                                                                      |
    +---------------------------+----------------------------------------------------------------------------+
    | admin_state_up            | UP                                                                         |
    | availability_zone_hints   |                                                                            |
    | availability_zones        |                                                                            |
    | created_at                | 2023-01-19T01:07:13Z                                                       |
    | description               |                                                                            |
    | dns_domain                | None                                                                       |
    | id                        | fafb5141-bbd8-4905-aacc-ffaa382f5595                                       |
    | ipv4_address_scope        | None                                                                       |
    | ipv6_address_scope        | None                                                                       |
    | is_default                | None                                                                       |
    | is_vlan_transparent       | None                                                                       |
    | mtu                       | 1500                                                                       |
    | name                      | private                                                                    |
    | port_security_enabled     | True                                                                       |
    | project_id                | 3d70d4a77f80405783505b0841b7d06f                                           |
    | provider:network_type     | vlan                                                                       |
    | provider:physical_network | public                                                                     |
    | provider:segmentation_id  | 3371                                                                       |
    | qos_policy_id             | None                                                                       |
    | revision_number           | 3                                                                          |
    | router:external           | Internal                                                                   |
    | segments                  | None                                                                       |
    | shared                    | False                                                                      |
    | status                    | ACTIVE                                                                     |
    | subnets                   | 960bca38-0b9a-4d4b-9709-e94e0d088e75, deacbbee-761a-4ffb-8a6e-637f076233a6 |
    | tags                      |                                                                            |
    | tenant_id                 | 3d70d4a77f80405783505b0841b7d06f                                           |
    | updated_at                | 2023-02-28T12:05:28Z                                                       |
    +---------------------------+----------------------------------------------------------------------------+

The ``private`` network has two subnets, the first one:

::

    $ openstack subnet show 960bca38-0b9a-4d4b-9709-e94e0d088e75
    +----------------------+--------------------------------------+
    | Field                | Value                                |
    +----------------------+--------------------------------------+
    | allocation_pools     | 10.0.0.2-10.0.0.62                   |
    | cidr                 | 10.0.0.0/26                          |
    | created_at           | 2023-01-19T01:10:33Z                 |
    | description          |                                      |
    | dns_nameservers      |                                      |
    | dns_publish_fixed_ip | None                                 |
    | enable_dhcp          | True                                 |
    | gateway_ip           | 10.0.0.1                             |
    | host_routes          |                                      |
    | id                   | 960bca38-0b9a-4d4b-9709-e94e0d088e75 |
    | ip_version           | 4                                    |
    | ipv6_address_mode    | None                                 |
    | ipv6_ra_mode         | None                                 |
    | name                 | private_sub_ipv4                     |
    | network_id           | fafb5141-bbd8-4905-aacc-ffaa382f5595 |
    | project_id           | 3d70d4a77f80405783505b0841b7d06f     |
    | revision_number      | 0                                    |
    | segment_id           | None                                 |
    | service_types        |                                      |
    | subnetpool_id        | 008fb194-7098-4f24-bd27-ea66b3e463b7 |
    | tags                 |                                      |
    | updated_at           | 2023-01-19T01:10:33Z                 |
    +----------------------+--------------------------------------+

The ``private`` network has two subnets, the second one:

::

    $ openstack subnet show deacbbee-761a-4ffb-8a6e-637f076233a6
    +----------------------+--------------------------------------+
    | Field                | Value                                |
    +----------------------+--------------------------------------+
    | allocation_pools     | 10.0.0.66-10.0.0.126                 |
    | cidr                 | 10.0.0.64/26                         |
    | created_at           | 2023-02-28T12:05:28Z                 |
    | description          |                                      |
    | dns_nameservers      |                                      |
    | dns_publish_fixed_ip | None                                 |
    | enable_dhcp          | True                                 |
    | gateway_ip           | 10.0.0.65                            |
    | host_routes          |                                      |
    | id                   | deacbbee-761a-4ffb-8a6e-637f076233a6 |
    | ip_version           | 4                                    |
    | ipv6_address_mode    | None                                 |
    | ipv6_ra_mode         | None                                 |
    | name                 | private_sub2_ipv4                    |
    | network_id           | fafb5141-bbd8-4905-aacc-ffaa382f5595 |
    | project_id           | 3d70d4a77f80405783505b0841b7d06f     |
    | revision_number      | 0                                    |
    | segment_id           | None                                 |
    | service_types        |                                      |
    | subnetpool_id        | 008fb194-7098-4f24-bd27-ea66b3e463b7 |
    | tags                 |                                      |
    | updated_at           | 2023-02-28T12:05:28Z                 |
    +----------------------+--------------------------------------+

With this neutron configuration, we can create a Manila share network called
``my_test_net`` in the AZ ``nova`` containing the first subnet of the
``private`` neutron network:

::

    $ manila share-network-create --name my_test_net --neutron-net-id fafb5141-bbd8-4905-aacc-ffaa382f5595 \
                                                                               --neutron-subnet-id 960bca38-0b9a-4d4b-9709-e94e0d088e75 \
                                                                               --availability-zone nova

The ``my_test_net`` has one share network subnet in the ``nova`` AZ.
Then, we create a share that will trigger the creation of a share
server:

::

    $ manila create NFS 1 --share-type dhss_true --share-network my_test_net --availability-zone nova

The share server ``85016a6d-2e71-45bf-85ce-4a98b9ccb80a`` has been created.
It has one allocation of the share network subnet as the field
``details:ports`` shows:

::

    $ manila share-server-show ef872a6e-dd98-42e4-9a2b-21fb499a7b36
    +-----------------------------------+--------------------------------------------------------------+
    | Property                          | Value                                                        |
    +-----------------------------------+--------------------------------------------------------------+
    | id                                | ef872a6e-dd98-42e4-9a2b-21fb499a7b36                         |
    | project_id                        | 3d70d4a77f80405783505b0841b7d06f                             |
    | updated_at                        | 2023-02-28T12:58:31.430079                                   |
    | status                            | active                                                       |
    | host                              | 55-felipen-vm@netapp1                                        |
    | share_network_name                | my_test_net                                                  |
    | share_network_id                  | 6680600e-5416-476b-8727-8af932137aad                         |
    | created_at                        | 2023-02-28T12:58:23.672379                                   |
    | is_auto_deletable                 | True                                                         |
    | identifier                        | ef872a6e-dd98-42e4-9a2b-21fb499a7b36                         |
    | task_state                        | None                                                         |
    | source_share_server_id            | None                                                         |
    | security_service_update_support   | True                                                         |
    | share_network_subnet_ids          | ['884f9c41-d568-4cb5-b2a5-0ffdbb761275']                     |
    | network_allocation_update_support | True                                                         |
    | details:vserver_name              | felipen_ef872a6e-dd98-42e4-9a2b-21fb499a7b36                 |
    | details:ports                     | {"d6c0398b-5404-4473-a829-226c44b0ebb9": "10.0.0.58"}        |
    | details:nfs_config                | {"tcp-max-xfer-size": "65536", "udp-max-xfer-size": "32768"} |
    +-----------------------------------+--------------------------------------------------------------+


In ONTAP side, we can see that the equivalent vserver has one interface:

::

    OSTK-select25::> network interface show -vserver felipen_ef872a6e-dd98-42e4-9a2b-21fb499a7b36
                Logical    Status     Network            Current       Current Is
    Vserver     Interface  Admin/Oper Address/Mask       Node          Port    Home
    ----------- ---------- ---------- ------------------ ------------- ------- ----
    felipen_ef872a6e-dd98-42e4-9a2b-21fb499a7b36
                os_d6c0398b-5404-4473-a829-226c44b0ebb9
                             up/up    10.0.0.58/26       OSTK-select25-01
                                                                       e0b-3371
                                                                               true


To add the second share network subnet for the existing share server, we
must call the check command to validate the possibility:

::

    $ manila share-network-subnet-create-check my_test_net --neutron-net-id fafb5141-bbd8-4905-aacc-ffaa382f5595 \
                                                                               --neutron-subnet-id deacbbee-761a-4ffb-8a6e-637f076233a6 \
                                                                               --availability-zone nova

We need to trigger the previous call until the Manila response ``compatible``
is ``True`` or ``False``:

::

    $ manila share-network-subnet-create-check my_test_net --neutron-net-id fafb5141-bbd8-4905-aacc-ffaa382f5595 \
                                                                               --neutron-subnet-id deacbbee-761a-4ffb-8a6e-637f076233a6 \
                                                                               --availability-zone nova
    +--------------------+-----------------------------------+
    | Property           | Value                             |
    +--------------------+-----------------------------------+
    | compatible         | True                              |
    | hosts_check_result | {'55-felipen-vm@netapp1': True}   |
    +--------------------+-----------------------------------+

Given that the host is compatible with the new share network subnet, we can
trigger the actual creation:

::

    $ manila share-network-subnet-create my_test_net --neutron-net-id fafb5141-bbd8-4905-aacc-ffaa382f5595 \
                                                                               --neutron-subnet-id deacbbee-761a-4ffb-8a6e-637f076233a6 \
                                                                               --availability-zone nova

The operation can take some time. The share network and share server are
locked while the update of new share network subnet runs. After it finishes,
we can see that the share server has two allocations as the field
``details:ports`` shows:

::

    $ manila share-server-show ef872a6e-dd98-42e4-9a2b-21fb499a7b36
    +-----------------------------------+------------------------------------------------------------------------------------------------------------+
    | Property                          | Value                                                                                                      |
    +-----------------------------------+------------------------------------------------------------------------------------------------------------+
    | id                                | ef872a6e-dd98-42e4-9a2b-21fb499a7b36                                                                       |
    | project_id                        | 3d70d4a77f80405783505b0841b7d06f                                                                           |
    | updated_at                        | 2023-02-28T13:12:31.610506                                                                                 |
    | status                            | active                                                                                                     |
    | host                              | 55-felipen-vm@netapp1                                                                                      |
    | share_network_name                | my_test_net                                                                                                |
    | share_network_id                  | 6680600e-5416-476b-8727-8af932137aad                                                                       |
    | created_at                        | 2023-02-28T12:58:23.672379                                                                                 |
    | is_auto_deletable                 | True                                                                                                       |
    | identifier                        | ef872a6e-dd98-42e4-9a2b-21fb499a7b36                                                                       |
    | task_state                        | None                                                                                                       |
    | source_share_server_id            | None                                                                                                       |
    | security_service_update_support   | True                                                                                                       |
    | share_network_subnet_ids          | ['884f9c41-d568-4cb5-b2a5-0ffdbb761275', 'a155f233-aeb3-42d6-a353-1d8b558650db']                           |
    | network_allocation_update_support | True                                                                                                       |
    | details:vserver_name              | felipen_ef872a6e-dd98-42e4-9a2b-21fb499a7b36                                                               |
    | details:ports                     | {"d6c0398b-5404-4473-a829-226c44b0ebb9": "10.0.0.58", "f8326404-fd1c-4ba8-994a-0ae11e1606c5": "10.0.0.73"} |
    | details:nfs_config                | {"tcp-max-xfer-size": "65536", "udp-max-xfer-size": "32768"}                                               |
    +-----------------------------------+------------------------------------------------------------------------------------------------------------+

In the ONTAP side, the equivalent vserver now has two logical interfaces:

::

    OSTK-select25::> network interface show -vserver felipen_ef872a6e-dd98-42e4-9a2b-21fb499a7b36
                Logical    Status     Network            Current       Current Is
    Vserver     Interface  Admin/Oper Address/Mask       Node          Port    Home
    ----------- ---------- ---------- ------------------ ------------- ------- ----
    felipen_ef872a6e-dd98-42e4-9a2b-21fb499a7b36
                os_d6c0398b-5404-4473-a829-226c44b0ebb9
                             up/up    10.0.0.58/26       OSTK-select25-01
                                                                       e0b-3371
                                                                               true
                os_f8326404-fd1c-4ba8-994a-0ae11e1606c5
                             up/up    10.0.0.73/26       OSTK-select25-01
                                                                       e0b-3371
                                                                               true

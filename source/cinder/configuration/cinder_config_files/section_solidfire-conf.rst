.. _solidfire:

NetApp Driver for SolidFire
===========================

SolidFire Cinder Driver Configuration
-------------------------------------

The OpenStack Cinder driver enables communication between OpenStack
SolidFire storage system. The user can use information from
the SF-Series cluster to configure the driver by modifying the
``/etc/cinder/cinder.conf`` service file on the controller host.
For more information on the configuration and best practices please visit
the following link: http://www.netapp.com/us/media/tr-4620.pdf

Table 4.18 lists the required storage system attributes used in the
``/etc/cinder/cinder.conf`` configuration file.

.. _table-4.18:

+--------------------------------------+----------------------------+---------------------------------------------+
| SolidFire Attribute                  | Default                    | Description                                 |
+======================================+============================+=============================================+
| ``san_ip``                           | None                       | SolidFire cluster MVIP                      |
+--------------------------------------+----------------------------+---------------------------------------------+
| ``san_login``                        | None                       | SolidFire cluster administrative user       |
+--------------------------------------+----------------------------+---------------------------------------------+
| ``san_password``                     | None                       | SolidFire cluster administrative password   |
+--------------------------------------+----------------------------+---------------------------------------------+

Table 4.18. Required SolidFire Attributes

Add the following lines to the file, replacing login and password with
the cluster admin login credentials

::

    [solidfire]
    volume_backend_name=solidfire
    volume_driver=cinder.volume.drivers.solidfire.SolidFireDriver
    san_ip=172.17.1.182
    san_login=login
    san_password=password

    [DEFAULT]
    enabled_backends=solidfire

Optional Cinder Configuration Attributes
----------------------------------------
You can optionally use the following attributes specific to SolidFire
in the ``[solidfire]`` section of the ``/etc/cinder/cinder.conf``
configuration file to control the interaction between the storage
system and the OpenStack Cinder service. (See Table 4.19.)

.. _table-4.19:

+--------------------------------------+----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| SolidFire Attribute                  | Default                    | Description                                                                                                                                                                                                     |
+======================================+============================+=================================================================================================================================================================================================================+
| ``sf_account_prefix``                | None                       | Create storage system accounts with this prefix. The default is no prefix.                                                                                                                                      |
+--------------------------------------+----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``sf_allow_tenant_qos``              | False                      | Allow individual tenants to specify QoS on volume creation. Setting this value to True disables dynamic QOS as well as administrative control over QOS. Changing from the default is not recommended.           |
+--------------------------------------+----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``sf_api_port``                      | 443                        | The SolidFire storage system API port. Change this value if the device API is behind a proxy on a different port.                                                                                               |
+--------------------------------------+----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``sf_emulate_512``                   | True                       | Set 512-byte emulation on volume creation. Note: The default is to enable 512 emulation. Required for KVM hypervisors.                                                                                          |
+--------------------------------------+----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``sf_enable_vag``                    | False                      | Use volume access groups on a per tenant basis instead of using CHAP secrets.                                                                                                                                   |
+--------------------------------------+----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``sf_svip``                          | None                       | Overrides the default cluster SVIP with the one specified. This option should only be used when multiple OpenStack instances are accessing the storage cluster from non-default VLANs.                          |
+--------------------------------------+----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``sf_volume_prefix``                 | ``UUID-``                  | Create volumes on the cluster with this prefix. Volumes use the prefix format ``<sf_volume_prefix><cindervolume-id>``. The default is to use the prefix ``UUID-``.                                              |
+--------------------------------------+----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``replication_device``               | None                       | SolidFire Target Cluster for Replication. This option uses the format ``backend_id:<backend-id>,mvip:<target-mvip>,login:<target-login>,password:<target-password>``                                            |
+--------------------------------------+----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``sf_provisioning_calc``             | ``maxProvisionedSpace``    | Change how SolidFire reports used space and provisioning calculations. If this parameter is set to ``usedSpace``, the  driver will report correct values as expected by Cinder thin provisioning.               |
+--------------------------------------+----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``sf_cluster_pairing_timeout``       | 60                         | Set time in seconds to wait for cluster to complete pairing                                                                                                                                                     |
+--------------------------------------+----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``sf_volume_pairing_timeout``        | 3600                       | Set time in seconds to wait for a migrating volume to complete pairing and sync                                                                                                                                 |
+--------------------------------------+----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``sf_api_request_timeout``           | 30                         | Set time in seconds to wait for an api request to complete                                                                                                                                                      |
+--------------------------------------+----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``sf_volume_clone_timeout``          | 600                        | Set time in seconds to wait for a clone of a volume or snapshot to complete                                                                                                                                     |
+--------------------------------------+----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``sf_volume_create_timeout``         | 60                         | Sets time in seconds to wait for a create volume operation to complete                                                                                                                                          |
+--------------------------------------+----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Table 4.19. Optional SolidFire Attributes

.. note::

    SolidFire timeout attributes are used to wait an amount of time for 
    several tasks completion in order to avoid sync or blocking errors, 
    be careful modifying its values.

.. note::

    SolidFire internal image caching feature is deprecated
    since Queens release, thenceforth generalized Cinder global
    caching feature is used. 
    Therefore, sf_allow_template_caching and sf_template_account_name
    attributes are not used anymore.
 
Multiple OpenStack Cloud Instances
----------------------------------
There are several facilities in the SolidFire driver that can
accommodate scenarios involving multiple OpenStack cloud instances
using a single SolidFire cluster. These features include account
prefixes, volume prefixes, virtual networks, and multiple virtual
interfaces (VIFs).

You can configure an account prefix using the variable
``sf_account_prefix`` in the ``/etc/cinder/cinder.conf`` file. You
can set this variable differently for each OpenStack cloud
instance, allowing the storage cluster administrator to
distinguish between accounts for each OpenStack instance.
By default, the ``sf_account_prefix`` variable is not set,
and account names have no prefix.

The OpenStack Mitaka release introduced the ``sf_volume_prefix``
variable to allow creation of unique volume prefixes for each
OpenStack cloud instance.

The default value of the ``sf_volume_prefix`` variable is
UUID-, which automatically configures the driver to work
as it has prior to the OpenStack Mitaka release. If you have multiple
OpenStack cloud instances attached to a single SolidFire system,
NetApp recommends that you change this variable for each instance
using the SolidFire system.

.. note::

   The variable ``sf_volume_prefix`` should not be changed within a
   cloud after a volume has been provisioned on the SolidFire storage
   system with OpenStack.

You can use VLANs and multiple VIFs to separate multiple OpenStack
cloud instances. Element OS supports multiple storage virtual
interfaces (SVIPs) on separate virtual networks. Each OpenStack cloud
instance accesses the storage system through the shared management
port. NetApp recommends that you configure each OpenStack cloud
instance with a unique cluster admin account.

.. note::

   When you use a single SVIP with OpenStack, the SolidFire
   driver acquires the SVIP by querying the cluster. If multiple SVIP
   addresses are configured, the query returns the default SVIP on
   the native virtual network. You can configure an alternate virtual
   network for the OpenStack cloud instance by modifying the
   ``/etc/cinder/cinder.conf`` file. Set the ``sf_svip`` variable in the
   ``[solidfire]`` section of the ``/etc/cinder/cinder.conf`` file for that
   OpenStack cloud instance to the IP address you want the iSCSI
   initiator to use to access volumes on the storage system.

SolidFire Replication Setup
---------------------------

In order to use SolidFire with Replication enabled you must have a secondary
target backend configured and being referenced by primary host under
``replication_device`` attribute. Example:

::

    [solidfire]
    volume_backend_name=solidfire
    volume_driver=cinder.volume.drivers.solidfire.SolidFireDriver
    san_ip=172.17.1.182
    san_login=login
    san_password=password
    replication_device=backend_id:solidfire2,mvip:172.17.1.142,login:login2,password:password2

    [solidfire-2]
    volume_backend_name=solidfire2
    volume_driver=cinder.volume.drivers.solidfire.SolidFireDriver
    san_ip=172.17.1.142
    san_login=login2
    san_password=password2

    [DEFAULT]
    enabled_backends=solidfire

.. note::

   The secondary cluster is not required to be in the ``enabled_backends``
   like in the example above.

You also need a volume type with ``replication_enabled=<is> True`` set as an
extra-spec:

::

    $ cinder type-show solidfire

    +---------------------------------+--------------------------------------+
    | Property                        | Value                                |
    +---------------------------------+--------------------------------------+
    | description                     | None                                 |
    | extra_specs                     | replication_enabled : <is> True      |
    |                                 | volume_backend_name : solidfire      |
    | id                              | 6910843e-0d49-4f8b-84f5-288d3672699d |
    | is_public                       | True                                 |
    | name                            | solidfire                            |
    | os-volume-type-access:is_public | True                                 |
    | qos_specs_id                    | None                                 |
    +---------------------------------+--------------------------------------+

When using SolidFire with Replication enabled you can use three different
replication modes:

- Real-time (Asynchronous): Writes are acknowledged to the client after they
  are committed on the source cluster.
- Real-time (Synchronous): Writes are acknowledged to the client after they
  are committed on both the source and target clusters.
- Snapshot-Only: Only snapshots created on the source cluster are replicated.
  Active writes from the source volume are not replicated.

.. important::
    From Ussuri release, the support for Active/Active (including replication)
    was added to the SolidFire driver. So the replication can also happen in
    clustered environments.

The default mode is ``Real-time (Asynchronous)``, and a new volume type extra-spec
must be set in order to change it. This extras-spec is
``solidfire:replication_mode`` and its possible values are ``Sync``, ``Async``
and ``SnapshotsOnly``. For example:

::

    $ cinder type-show solidfire

    +---------------------------------+--------------------------------------+
    | Property                        | Value                                |
    +---------------------------------+--------------------------------------+
    | description                     | None                                 |
    | extra_specs                     | replication_enabled : <is> True      |
    |                                 | solidfire:replication_mode : Sync    |
    |                                 | volume_backend_name : solidfire      |
    | id                              | 6910843e-0d49-4f8b-84f5-288d3672699d |
    | is_public                       | True                                 |
    | name                            | solidfire                            |
    | os-volume-type-access:is_public | True                                 |
    | qos_specs_id                    | None                                 |
    +---------------------------------+--------------------------------------+

SolidFire Storage Assisted Migration
------------------------------------

Starting on Victoria Release, NetApp SolidFire implements support for Storage
Assisted Migration. With storage-assisted migration, the operation is optimized
because it is managed by the storage driver instead of OpenStack Block Storage
service.

More details about Volume Migration can be found under the official OpenStack
Documentation in the following link: https://docs.openstack.org/cinder/victoria/contributor/migration.html

There are a few requirements to perform a storage-assisted migration:

- The volume status must be ``available``.
- Storage-assisted migration can not be performed on replicated volumes.
- If the destination backend or cluster is the one where the volume is
  currently placed, nothing will be done.

Here is an example using cinder retype:

::

    $ cinder list

    +--------------------------------------+-----------+------+------+--------------+----------+-------------+
    | ID                                   | Status    | Name | Size | Volume Type  | Bootable | Attached to |
    +--------------------------------------+-----------+------+------+--------------+----------+-------------+
    | ed841a96-4692-4368-a011-5c792aa47020 | available | v1   | 10   | solidfire-1  | false    |             |
    +--------------------------------------+-----------+------+------+--------------+----------+-------------+

    $ cinder retype --migration-policy on-demand v1 solidfire-2

    +--------------------------------------+-----------+------+------+---------------+----------+-------------+
    | ID                                   | Status    | Name | Size | Volume Type   | Bootable | Attached to |
    +--------------------------------------+-----------+------+------+---------------+----------+-------------+
    | caa7f059-f2e4-44bc-a6c2-c2fdba41d986 | available | v1   | 10   | solidfire-2   | false    |             |
    | ed841a96-4692-4368-a011-5c792aa47020 | retyping  | v1   | 10   | solidfire-1   | false    |             |
    +--------------------------------------+-----------+------+------+---------------+----------+-------------+

    $ cinder show ed841a96-4692-4368-a011-5c792aa47020

    +--------------------------------+--------------------------------------+
    | Property                       | Value                                |
    +--------------------------------+--------------------------------------+
    | attached_servers               | []                                   |
    | attachment_ids                 | []                                   |
    | availability_zone              | nova                                 |
    | bootable                       | false                                |
    | consistencygroup_id            | None                                 |
    | created_at                     | 2021-01-08T16:22:27.000000           |
    | description                    | None                                 |
    | encrypted                      | False                                |
    | id                             | ed841a96-4692-4368-a011-5c792aa47020 |
    | metadata                       |                                      |
    | migration_status               | migrating                            |
    | multiattach                    | False                                |
    | name                           | v1                                   |
    | os-vol-host-attr:host          | host1@solidfire-1#solidfire-1        |
    | os-vol-mig-status-attr:migstat | migrating                            |
    | os-vol-mig-status-attr:name_id | None                                 |
    | os-vol-tenant-attr:tenant_id   | 08d8fe03a3e74032afd1c4ee665ff2bc     |
    | replication_status             | None                                 |
    | size                           | 10                                   |
    | snapshot_id                    | None                                 |
    | source_volid                   | None                                 |
    | status                         | retyping                             |
    | updated_at                     | 2021-01-08T16:23:56.000000           |
    | user_id                        | a5a3b146f67447b1abea8f1a929afdce     |
    | volume_type                    | solidfire-1                          |
    +--------------------------------+--------------------------------------+

    +--------------------------------+--------------------------------------+
    | Property                       | Value                                |
    +--------------------------------+--------------------------------------+
    | attached_servers               | []                                   |
    | attachment_ids                 | []                                   |
    | availability_zone              | nova                                 |
    | bootable                       | false                                |
    | consistencygroup_id            | None                                 |
    | created_at                     | 2021-01-08T16:22:27.000000           |
    | description                    | None                                 |
    | encrypted                      | False                                |
    | id                             | ed841a96-4692-4368-a011-5c792aa47020 |
    | metadata                       |                                      |
    | migration_status               | success                              |
    | multiattach                    | False                                |
    | name                           | v1                                   |
    | os-vol-host-attr:host          | host1@solidfire-2#solidfire-2        |
    | os-vol-mig-status-attr:migstat | success                              |
    | os-vol-mig-status-attr:name_id | caa7f059-f2e4-44bc-a6c2-c2fdba41d986 |
    | os-vol-tenant-attr:tenant_id   | 08d8fe03a3e74032afd1c4ee665ff2bc     |
    | replication_status             | None                                 |
    | size                           | 10                                   |
    | snapshot_id                    | None                                 |
    | source_volid                   | None                                 |
    | status                         | available                            |
    | updated_at                     | 2021-01-08T16:24:25.000000           |
    | user_id                        | a5a3b146f67447b1abea8f1a929afdce     |
    | volume_type                    | solidfire-2                          |
    +--------------------------------+--------------------------------------+

    $ cinder list

    +--------------------------------------+-----------+------+------+---------------+----------+-------------+
    | ID                                   | Status    | Name | Size | Volume Type   | Bootable | Attached to |
    +--------------------------------------+-----------+------+------+---------------+----------+-------------+
    | ed841a96-4692-4368-a011-5c792aa47020 | available | v1   | 10   | solidfire-2   | false    |             |
    +--------------------------------------+-----------+------+------+---------------+----------+-------------+

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
| ``sf_allow_template_caching``        | True                       | Create an internal cache of image copies when a bootable volume is created to eliminate the fetch from OpenStack Glance and QEMU conversion on subsequent calls.                                                |
+--------------------------------------+----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``sf_allow_tenant_qos``              | False                      | Allow individual tenants to specify QoS on volume creation. Setting this value to True disables dynamic QOS as well as administrative control over QOS. Changing from the default is not recommended.           |
+--------------------------------------+----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``sf_api_port``                      | 443                        | The SolidFire storage system API port. Change this value if the device API is behind a proxy on a different port.                                                                                               |
+--------------------------------------+----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``sf_emulate_512``                   | True                       | Set 512-byte emulation on volume creation. Note: The default is to enable 512 emulation. Required for KVM hypervisors.                                                                                          |
+--------------------------------------+----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``sf_enable_vag``                    | False                      | Use volume access groups on a per tenant basis instead of using CHAP secrets.                                                                                                                                   |
+--------------------------------------+----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``sf_enable_volume_mapping``         | True                       | Create an internal mapping of volume IDs and accounts. This option optimizes look-ups and performance at the expense of memory. Use with caution. For very large deployments, this can cause performance issues.|
+--------------------------------------+----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``sf_svip``                          | None                       | Overrides the default cluster SVIP with the one specified. This option should only be used when multiple OpenStack instances are accessing the storage cluster from non-default VLANs.                          |
+--------------------------------------+----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``sf_template_account_name``         | ``openstack-vtemplate``    | The account name on the SF-Series cluster to use as the owner of the template and cache volumes.                                                                                                                |
+--------------------------------------+----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``sf_volume_prefix``                 | ``UUID-``                  | Create volumes on the cluster with this prefix. Volumes use the prefix format ``<sf_volume_prefix><cindervolume-id>``. The default is to use the prefix ``UUID-``.                                              |
+--------------------------------------+----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``replication_device``               | None                       | SolidFire Target Cluster for Replication. This option uses the format ``backend_id:<backend-id>,mvip:<target-mvip>,login:<target-login>,password:<target-password>``                                            |
+--------------------------------------+----------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Table 4.19. Optional SolidFire Attributes

.. note::

    Set sf_allow_template_caching to False and use the
    generalized Cinder global caching feature instead
    of the SolidFire internal image caching feature.

.. tip::

   NetApp recommends the use of the generalized Cinder global caching
   feature over the SolidFire internal image cache.  As of the Queens
   release, the default value of sf_allow_template_caching will be
   set to False.  Also in the Queens release, the SolidFire internal
   image caching feature will be deprecated.
 
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
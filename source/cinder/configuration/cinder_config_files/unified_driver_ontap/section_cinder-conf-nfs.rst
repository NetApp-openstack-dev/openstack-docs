.. _cdot-nfs:

NetApp Unified Driver for ONTAP with NFS
=============================================================

The NetApp unified driver for ONTAP with NFS is a driver
interface from OpenStack block storage to a ONTAP cluster system to
accomplish provisioning and management of OpenStack volumes on NFS
exports provided by the ONTAP cluster system. The NetApp unified
driver for the ONTAP cluster does not require any additional
management software to achieve the desired functionality. It uses NetApp
APIs to interact with the ONTAP cluster.

To set up the NetApp ONTAP NFS driver for Cinder, the
following stanza should be added to the Cinder configuration file
(``cinder.conf``)::

    [myNfsBackend]
    volume_backend_name=myNfsBackend
    volume_driver=cinder.volume.drivers.netapp.common.NetAppDriver
    netapp_server_hostname=hostname
    netapp_server_port=80
    netapp_storage_protocol=nfs
    netapp_storage_family=ontap_cluster
    netapp_login=admin_username
    netapp_password=admin_password
    netapp_vserver=svm_name
    nfs_shares_config=path_to_nfs_exports_file
    max_over_subscription_ratio=1.0
    reserved_percentage=5
    nfs_mount_options=lookupcache=pos

-  Be sure that the value of the ``enabled_backends`` option in the
   ``[DEFAULT]`` stanza includes the name of the stanza you chose for
   the backend.

.. caution::

   Please note that exported qtrees are not supported by Cinder.

.. note::

   The file referenced in the ``nfs_shares_config`` configuration
   option should contain the NFS exports in the ``ip:/share`` format,
   for example::

      10.63.165.215:/nfs/test
      10.63.165.215:/nfs2/test2

   where ``ip`` corresponds to the IP address assigned to a Data LIF,
   and ``share`` refers to a junction path for a FlexVol volume within
   an SVM (starting from Wallaby cycle, it may refer to a FlexGroup
   volume: see :ref:`FlexGroup Pool<flexgroup-pool>`). Make sure that
   volumes corresponding to exports have read/write permissions set on the
   ONTAP controllers. Do *not* put mount options in the ``nfs_shares_config``
   file; use ``nfs_mount_options`` instead. For more information on that and
   other parameters available to affect the behavior of NetApp's NFS
   driver, please refer to
   http://docs.openstack.org/trunk/config-reference/content/nfs-driver-options.html.

Table 4.20, “Configuration options for ONTAP with NFS” below lists
the configuration options available for the unified driver for an
ONTAP deployment that uses the NFS storage protocol.

.. _table-4.20:

+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Option                             | Type       | Default Value                | Description                                                                                                                                                                                                                                                                                                                                                                                                             |
+====================================+============+==============================+=========================================================================================================================================================================================================================================================================================================================================================================================================================+
| ``netapp_server_hostname``         | Required   |                              | The hostname or IP address for the storage system or proxy server. *The value of this option should be the IP address of either the cluster management LIF or the SVM management LIF.*                                                                                                                                                                                                                                  |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_server_port``             | Optional   |                              | The TCP port to use for communication with the storage system or proxy server. If not specified, ONTAP drivers will use 80 for HTTP and 443 for HTTPS.                                                                                                                                                                                                                                                                  |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_login``                   | Required   |                              | Administrative user account name used to access the storage system or proxy server.                                                                                                                                                                                                                                                                                                                                     |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_password``                | Required   |                              | Password for the administrative user account specified in the ``netapp_login`` option.                                                                                                                                                                                                                                                                                                                                  |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_storage_protocol``        | Required   |                              | The storage protocol to be used. Valid options are ``nfs``, ``iscsi``, ``nvme``  or ``fc``.                                                                                                                                                                                                                                                                                                                             |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_transport_type``          | Required   | ``http``                     | Transport protocol for communicating with the storage system or proxy server. Valid options include ``http`` and ``https``.                                                                                                                                                                                                                                                                                             |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_copyoffload_tool_path``   | Optional   |                              | This option specifies the path of the NetApp copy offload tool binary. Ensure that the binary has execute permissions set which allow the effective user of the ``cinder-volume`` process to execute the file. ``Deprecated since Zed Release``: NFS driver has an internal implementation for performing the efficient clone image, not requiring the legacy tool.                                                     |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_vserver``                 | Required   |                              | This option specifies the storage virtual machine (previously called a Vserver) name on the storage cluster on which provisioning of block storage volumes should occur.                                                                                                                                                                                                                                                |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_storage_family``          | Optional   | ``ontap_cluster``            | The storage family type used on the storage system; valid values are ``ontap_cluster`` for ONTAP systems.                                                                                                                                                                                                                                                                                                               |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``nfs_shares_config``              | Required   | ``/etc/cinder/nfs_shares``   | The file referenced by this configuration option should contain a list of NFS shares, each on their own line, to which the driver should attempt to provision new Cinder volumes into.                                                                                                                                                                                                                                  |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``trace_flags``                    | Optional   |                              | This option is a comma-separated list of options (valid values include ``method`` and ``api``) that controls which trace info is written to the Cinder logs when the debug level is set to ``True``.                                                                                                                                                                                                                    |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_api_trace_pattern``       | Optional   | ``(.+)``                     | A regular expression to limit the API tracing. This option is honored only if enabling ``api`` tracing with the ``trace_flags`` option. By default, all APIs will be traced.                                                                                                                                                                                                                                            |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``nfs_sparsed_volumes``            | Optional   | ``True``                     | Controls whether Cinder volumes backed by NFS backends are sparsely or thickly provisioned.  True == sparse, False == Thick.                                                                                                                                                                                                                                                                                            |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``nfs_mount_options``              | Optional   | None                         | Mount options passed to the nfs client. See section of the nfs man page for details.                                                                                                                                                                                                                                                                                                                                    |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``nas_secure_file_permissions``    | Optional   | ``auto``                     | If 'false', backing files for cinder volumes are readable by owner, group, and world; if 'true', only by owner and group. If 'auto' and there are existing Cinder volumes, value will be set to 'false' (for backwards compatibility); if 'auto' and there are no existing Cinder volumes, the value will be set to 'true'.                                                                                             |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``nas_secure_file_operations``     | Optional   | ``auto``                     | If 'false', operations on the backing files run as root; if 'true', operations on the backing files for cinder volumes run unprivileged, as the cinder user, and are allowed to succeed even when root is squashed. If 'auto' and there are existing Cinder volumes, value will be set to 'false' (for backwards compatibility); if 'auto' and there are no existing Cinder volumes, the value will be set to 'true'.   |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``thres_avl_size_perc_start``      | Optional   | ``20``                       | If the percentage of available space for an NFS share has dropped below the value specified by this option, the NFS image cache will be cleaned.                                                                                                                                                                                                                                                                        |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``thres_avl_size_perc_stop``       | Optional   | ``60``                       | When the percentage of available space on an NFS share has reached the percentage specified by this option, the driver will stop clearing files from the NFS image cache that have not been accessed in the last M minutes, where M is the value of the ``expiry_thres_minutes`` configuration option.                                                                                                                  |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``expiry_thres_minutes``           | Optional   | ``720``                      | This option specifies the threshold for last access time for images in the NFS image cache. When a cache cleaning cycle begins, images in the cache that have not been accessed in the last M minutes, where M is the value of this parameter, will be deleted from the cache to create free space on the NFS share.                                                                                                    |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``reserved_percentage``            | Optional   | ``0``                        | This option represents the amount of total capacity of a storage pool that will be reserved and cannot be utilized for provisioning Cinder volumes.                                                                                                                                                                                                                                                                     |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``max_over_subscription_ratio``    | Optional   | ``20.0``                     | This option is defined as a float, and specifies the amount of over-provisioning to allow when thin provisioning is being used in the storage pool. A value of 1.0 will mean that the provisioned capacity will not be able to exceed the total capacity, while larger values will result in increased levels of allowed over-provisioning.                                                                             |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``filter_function``                | Optional   | (see description)            | This option may be used to override the default filter function, which prevents Cinder from placing new volumes on storage controllers that may become overutilized. The default value is "capabilities.utilization < 70".                                                                                                                                                                                              |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``goodness_function``              | Optional   | (see description)            | This option may be used to override the default goodness function, which allows Cinder to place new volumes on lesser-utilized storage controllers. The default value is "100 - capabilities.utilization".                                                                                                                                                                                                              |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``nfs_snapshot_support``           | Optional   | ``False``                    | This option only affects the NFS driver with FlexGroup pool, enabling support for snapshots. Platforms using Libvirt < 1.2.7 will encounter issues with snapshots and FlexGroup pool.                                                                                                                                                                                                                                   |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_migrate_volume_timeout``  | Optional   | ``3600``                     | This option sets time in seconds to wait for a volume Storage Assisted Migration to complete. It's minimum value is 30 seconds.                                                                                                                                                                                                                                                                                         |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_use_legacy_client``       | Optional   | ``True``                     | Select which ONTAP client to use for retrieving and modifying data on the storage. The legacy client relies on ZAPI calls. If set to ``False``, the new REST client is used, which runs REST calls if supported, otherwise falls back to the equivalent ZAPI call.                                                                                                                                                      |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_async_rest_timeout``      | Optional   | ``60``                       | The maximum time in seconds to wait for completing a REST asynchronous operation.                                                                                                                                                                                                                                                                                                                                       |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_ssl_cert_path``           | Optional   | (see description)            | The path to a CA_BUNDLE file or directory with certificates of trusted CA. If set to a directory, it must have been processed using the ``c_rehash`` utility supplied with OpenSSL. If not informed, it will use the Mozilla's carefully curated collection of Root Certificates for validating the trustworthiness of SSL certificates. Only applies when enabling the REST client.                                    |
+------------------------------------+------------+------------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Table 4.20. Configuration options for ONTAP with NFS

.. important::

   The option ``netapp_use_legacy_client`` can only be set to ``False``
   (storage communication through REST API) when using ONTAP storage 9.11.1
   or newer.

.. caution::

   If you specify an account in the ``netapp_login`` option that only
   has SVM administration privileges (rather than cluster
   administration privileges), some advanced features of the NetApp
   unified driver will not work and you may see warnings in the Cinder
   logs. See the section called ":ref:`account-permissions`"
   for more details on the required access level permissions for an SVM
   admin account.

.. include:: ../../../common/nfs-cache-warning.rst

.. _flexgroup-pool:

FlexGroup Pool
--------------------------------------

An ONTAP FlexGroup volume is a scale-out NAS container that provides high
performance along with automatic load distribution and scalability. A FlexGroup
volume can provision a massive single namespace using the entire cluster
resources. While the FlexVol is associated to one of the cluster's
aggregates, the FlexGroup may be associated to several aggregates in the same
cluster.

Starting from Wallaby cycle, the NFS driver can have a Cinder Pool as a
FlexGroup volume. This operation does not require any different cinder
configuration, only providing the ``nfs_shares_config`` with NFS exports
pointing to a FlexGroup volume.

The FlexGroup pool has a different view of aggregate capabilities,
replacing a single element by a list of elements. They are
``netapp_aggregate``, ``netapp_raid_type``, ``netapp_disk_type`` and
``netapp_hybrid_aggregate``. The ``netapp_aggregate_used_percent``
capability is an average of the used percentage of all FlexGroup's aggregates.

Given that the FlexClone file is not supported within FlexGroup volume,
the operations of clone volume, create snapshot and create volume from an
image do not rely on the ONTAP storage to perform them, using the host
with the NFS generic driver implementation. As consequence, there will be a
significant performance penalty.

.. important::

    Consistency Groups, Multi-Attach and Revert to Snapshot operations for
    FlexGroup volumes are currently not supported.

.. important::

   The ``utilization`` metric is currently unsupported for FlexGroup pools and
   is not calculated. It's value is always set to the default of 50.

.. important::

    The :ref:`enhanced instance creation<enhanced-instance>` feature cannot
    be accomplished with NFS driver over FlexGroup pools. It can use the Cinder
    image cache for avoiding downloading image twice, though.

.. important::

    The FlexGroup pool is only supported using ONTAP 9.8 or newer.

.. caution::

    A driver with FlexGroup pools has snapshot support disabled by default,
    following the NFS generic driver implementation. To enable, you must set
    ``nfs_snapshot_support`` to ``True`` in the backend's configuration section
    of the cinder configuration file.

    Given that snapshot is provided by the NFS Generic driver, there is a known
    bug while attaching a volume with snapshots:
    https://bugzilla.redhat.com/show_bug.cgi?id=1361592

    So, for working with snapshots over FlexGroup pool, you should configure
    the environment as:

    1) The Libvirt, Qemu, and KVM run as a user belonging to the same group as
    the OpenStack. The security layer ``security_driver`` should be disabled,
    setting as ``none``.
    Edit the QEMU config */etc/libvirt/qemu.conf* as::

       ...
       security_driver = "none"
       ...
       #user = "root"
       user = "your_user_name"
       ...
       #group = "root"
       group = "your_group_name"
       ...
       #dynamic_ownership = 1
       dynamic_ownership = 0
       ...

    2) Set the ``nas_secure_file_operations`` and
    ``nas_secure_file_permissions`` to ``false``. Make changes to
    */etc/cinder/cinder.conf* in the backend's configuration stanza::

       [replace-with-nfs-backend]
       ...
       nas_secure_file_operations = false
       nas_secure_file_permissions = false
       nfs_snapshot_support = true
       ...

    3) After making the configuration changes, restart the Libvirt, QEMU, KVM
    and OpenStack processes. It is a disruptive operation that may require
    planning depending on your environment.

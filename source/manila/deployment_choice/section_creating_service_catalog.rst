Theory of Operation: Storage Service Catalog and Manila Share Types
===================================================================

The Storage Service Catalog (SSC) is a concept that describes a set of
capabilities that enables efficient, repeated, and consistent use and
management of storage resources by the definition of policy-based
services and the mapping of those services to the backend storage
technology. It is meant to abstract away the actual technical
implementations of the features at a storage backend into a set of
simplified configuration options.

The storage features are organized or combined into groups based on the
customer needs to achieve a particular scenario or use case. Based on
the catalog of the storage features, intelligent provisioning decisions
are made by infrastructure or software enabling the storage service
catalog. In OpenStack, this is achieved together by the Manila filter
scheduler and the NetApp driver by making use of share type extra-specs
support together with the filter scheduler.

When the NetApp unified driver is used with an ONTAP
storage system, you can leverage extra specs with Manila share types to
ensure that Manila shares are created on storage backends that have
certain properties (e.g. thin provisioning, disk type, RAID type, QoS Support)
configured.

Extra specs are associated with Manila share types, so that when users
request shares of a particular share type, they are created on storage
backends that meet the list of requirements (e.g. available space, extra
specs, etc). You can use the specs in
:ref:`Table 6.10, “NetApp supported Extra Specs for use with Manila Share Types”<table-6.10>`
when defining Manila share types with the ``manila type-key`` command.

.. _table-6.10:

+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Extra spec                               | Type      | Description                                                                                                                                                                                                                                                                                                                                                                      |
+==========================================+===========+==================================================================================================================================================================================================================================================================================================================================================================================+
| ``netapp_aggregate``                     | String    | Limit the candidate aggregate (pool) list to a specific aggregate.                                                                                                                                                                                                                                                                                                               |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_raid_type``                     | String    | Limit the candidate aggregate (pool) list based on one of the following raid types: ``raid4``, ``raid_dp``.                                                                                                                                                                                                                                                                      |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_disk_type``                     | String    | Limit the candidate aggregate (pool) list based on one of the following disk types: ``ATA``, ``BSAS``, ``EATA``, ``FCAL``, ``FSAS``, ``LUN``, ``MSATA``, ``SAS``, ``SATA``, ``SCSI``, ``XATA``, ``XSAS``, or ``SSD``.                                                                                                                                                            |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_hybrid_aggregate``              | Boolean   | Limit the candidate aggregate (pool) list to hybrid aggregates.                                                                                                                                                                                                                                                                                                                  |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp:dedup``                         | Boolean   | Enable deduplication on the share. *Note that this option is deprecated in favor of the standard Manila extra spec 'dedupe'.*                                                                                                                                                                                                                                                    |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``dedupe``                               | String    | Enable deduplication on the share. This value should be set to ``"<is> True"`` or ``"<is> False"``.                                                                                                                                                                                                                                                                              |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp:compression``                   | Boolean   | Enable compression on the share. When compression is enabled on a share, deduplication is also automatically enabled on that share. *Note that this option is deprecated in favor of the standard Manila extra spec 'compression'.*                                                                                                                                              |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``compression``                          | String    | Enable compression on the share. When compression is enabled on a share, deduplication is also automatically enabled on that share. This value should be set to ``"<is> True"`` or ``"<is> False"``.                                                                                                                                                                             |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp:thin_provisioned``              | Boolean   | Enable thin provisioning (a space guarantee of ``None``) on the share. *Note that this option is deprecated in favor of the standard Manila extra spec 'thin\_provisioning'.*                                                                                                                                                                                                    |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``thin_provisioning``                    | String    | Enable thin provisioning (a space guarantee of ``None``) on the share. This value should be set to ``"<is> True"`` or ``"<is> False"``.                                                                                                                                                                                                                                          |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp:snapshot_policy``               | String    | Apply the specified snapshot policy to the created FlexVol volume. *Note that the snapshots created by applying a policy will not have corresponding Manila snapshot records.*                                                                                                                                                                                                   |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp:hide_snapdir``                  | Boolean   | Control visibility of the ``.snapshot`` directory for each newly created share. By default, each share allows access to its ``.snapshot`` directory, which contains files of each snapshot that is taken. To restrict access to the directory, this option should be set to ``True``. For shares that have already been created, refer [#f2]_.                                   |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp:language``                      | String    | Apply the specified language to the FlexVol volume that corresponds to the Manila share. The language of the FlexVol volume determines the character set ONTAP uses to display file names and data for that volume. The default value for the language of the volume is the language of the SVM.                                                                                 |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp:max_files``                     | String    | Change the maximum number of files for the FlexVol volume that corresponds to the Manila share. By default, the maximum number of files is proportional to the size of the share. This spec can be used to increase the number of files for very large shares (greater than 1TB), or to place a smaller limit on the number of files on a given share.                           |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp:split_clone_on_create``         | Boolean   | Choose whether a FlexVol volume that corresponds to the Manila share is immediately split from its parent when creating a share from a snapshot. By default, the FlexVol is not split so that no additional space is consumed. Setting this value to 'true' may be appropriate for shares that are created from a template share and that will encounter high rates of change.   |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``snapshot_support``                     | Boolean   | Choose whether to allow the creation of snapshots for a share type.                                                                                                                                                                                                                                                                                                              |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``create_share_from_snapshot_support``   | Boolean   | Enable the creation of a share from a snapshot.                                                                                                                                                                                                                                                                                                                                  |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``revert_to_snapshot_support``           | Boolean   | Allow a share to be reverted to the most recent snapshot.                                                                                                                                                                                                                                                                                                                        |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp_flexvol_encryption``            | Boolean   | Create FlexVol with NVE encryption at rest enabled.                                                                                                                                                                                                                                                                                                                              |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``qos``                                  | Boolean   | Allow scheduling to an aggregate (pool) that supports defining QoS. See how this is determined by the driver in [#f1]_. See the NetApp driver specific QoS extra-specs in :ref:`Table 6.11, ?~@~\NetApp QoS Specs for use with Manila Share Types?~@~]<table-6.11>`.                                                                                                             |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``netapp:adaptive_qos_policy_group``     | String    | Apply the specified adaptive QoS policy group to the FlexVol volume that corresponds to the Manila Share. *Note that the provided adaptive qos policy group must be created in advance in all SVMs managed by Manila.* Check [#f3]_ for restrictions included with this feature.                                                                                                 |
+------------------------------------------+-----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Table 6.10. NetApp supported Extra Specs for use with Manila Share Types

.. _table-6.11:

+------------------------------------------+-----------+-----------------------------------------------------------------------+
| QoS Extra spec                           | Type      | Description                                                           |
+==========================================+===========+=======================================================================+
| ``netapp:maxiops``                       | String    | The maximum IOPS allowed.                                             |
+------------------------------------------+-----------+-----------------------------------------------------------------------+
| ``netapp:maxbps``                        | String    | The maximum bytes per second allowed.                                 |
+------------------------------------------+-----------+-----------------------------------------------------------------------+
| ``netapp:maxiopspergib``                 | String    | The maximum IOPS allowed per GiB of the Manila share size.            |
+------------------------------------------+-----------+-----------------------------------------------------------------------+
| ``netapp:maxbpspergib``                  | String    | The maximum bytes per second allowed per GiB of the Manila share size.|
+------------------------------------------+-----------+-----------------------------------------------------------------------+

Table 6.11. NetApp specific QoS Extra Specs for use with Manila Share Types that have ``qos=True``.

.. caution::

   When using the Manila driver without share server management, you
   can specify a value for the ``netapp_login`` option that only has
   SVM administration privileges (rather than cluster administration
   privileges); you should note some advanced features of the driver
   may not work and you may see warnings in the Manila logs, unless
   appropriate permissions are set. See the section called
   ":ref:`account-perm`" for more details on the required access level
   permissions for an SVM admin account.

.. rubric:: Footnotes

.. [#f1] ``qos`` is reported as a capability by the Manila driver to
         the Manila scheduler for each ONTAP aggregate (Manila storage pool).
         This value will either be True (QoS is supported) or
         False (QoS is not supported) for all aggregates belonging
         to a backend.

         Defining QoS throughput limits is supported by all platforms
         running ONTAP > 8.2 with no additional license.
         However, you must configure the Manila ONTAP driver with an ONTAP user
         that has permissions to create and modify ONTAP QoS policy groups if
         you want the driver to support Manila QoS.
         (See ":ref:`account-perm`"). Be aware that ONTAP Users with Vsadmin
         (SVM administrator) role do not have permission to create or
         modify QoS policy groups.

.. [#f2] To hide the ``.snapshot`` directory of shares that have already been
         created, the ``netapp_reset_snapdir_visibility`` config option can be
         set to ``hidden`` for the associated backend in ``manila.conf``. Upon
	 restarting the Manila service, the changes will take effect. The config
         option may be set to ``visible`` to make the ``.snapshot`` directory of
         shares visible. The config option can be set to ``default`` to retain the
         current value for existing Manila shares on subsequent restarts of the Manila
         service.

.. [#f3] ``netapp:adative_qos_policy_group`` capability expects that the
         provided adaptive qos policy group has already been created in the
         storage system. This feature is only supported on ONTAP version 9.4 or
         higher and needs a cluster scoped account configured in driver
         options. This feature is only supported by
         ``driver_handles_share_servers`` set to ``False`` and does not work
         with ``Share Replication``.

         When creating a share using this capability, certify that all backends
         have the proper Adaptive QoS Policy Group configured in advance. You
         can also  make use of other backend capabilities to force the
         scheduler to choose the desired backend (e.g. ``share_backend_name``).




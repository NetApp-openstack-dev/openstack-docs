.. _cinder-api:

API Overview
============

This section describes some of the most commonly used Cinder API calls
and their corresponding CLI commands. It is not meant to be a
comprehensive list that is representative of all functionality present
in Cinder; for more information, please refer to the `OpenStack
Configuration
Reference. <http://docs.openstack.org/icehouse/config-reference/content/config_overview.html>`__

.. note::

   Block Storage V2 API has been deprecated. To ensure Cinder does not
   use the V2 API, update ``enable_v2_api=false`` and ``enable_v3_api=true``
   in your cinder.conf file. 

Volume API
----------

Table 4.2, “Cinder API Overview - Volume” specifies the valid
operations that can be performed on Cinder volumes. Please note that
Cinder volumes are identified as CLI command arguments by either their
names or UUID.

+-------------------+------------------------------+-----------------------------------------------------------------------------------------------------------------------------------+
| Operation         | CLI Command                  | Description                                                                                                                       |
+===================+==============================+===================================================================================================================================+
| Create            | ``cinder create``            | Create a Cinder volume of specified size; optional name, availability zone, volume type                                           |
+-------------------+------------------------------+-----------------------------------------------------------------------------------------------------------------------------------+
| Delete            | ``cinder delete``            | Delete an existing Cinder volume; the ``cinder force-delete`` command may be required if the Cinder volume is in an error state   |
+-------------------+------------------------------+-----------------------------------------------------------------------------------------------------------------------------------+
| Edit              | ``cinder metadata``          | Set or unset metadata on a Cinder volume                                                                                          |
+-------------------+------------------------------+-----------------------------------------------------------------------------------------------------------------------------------+
| Extend            | ``cinder extend``            | Increase the capacity of a Cinder volume to the specified size                                                                    |
+-------------------+------------------------------+-----------------------------------------------------------------------------------------------------------------------------------+
| List              | ``cinder list``              | List all Cinder volumes                                                                                                           |
+-------------------+------------------------------+-----------------------------------------------------------------------------------------------------------------------------------+
| Migrate           | ``cinder migrate``           | Move a Cinder volume to a new Cinder backend (specified by name)                                                                  |
+-------------------+------------------------------+-----------------------------------------------------------------------------------------------------------------------------------+
| Show              | ``cinder show``              | Show details about a Cinder volume                                                                                                |
+-------------------+------------------------------+-----------------------------------------------------------------------------------------------------------------------------------+
| Upload as image   | ``cinder upload-to-image``   | Upload a Cinder volume to the OpenStack Image Service                                                                             |
+-------------------+------------------------------+-----------------------------------------------------------------------------------------------------------------------------------+
| Manage            | ``cinder manage``            | Bring an existing storage object under Cinder management                                                                          |
+-------------------+------------------------------+-----------------------------------------------------------------------------------------------------------------------------------+
| Unmanage          | ``cinder unmanage``          | Cease management of an existing Cinder volume without deleting the backing storage object                                         |
+-------------------+------------------------------+-----------------------------------------------------------------------------------------------------------------------------------+

Table 4.2. Cinder API Overview - Volume

.. note::

   Cinder supports extension of attached volumes from the Rocky release. It
   is now possible to extend the size of a volume that is in the ``in-use``
   state.

Snapshot API
------------

Table 4.3, “Cinder API Overview - Snapshot” specifies the valid
operations that can be performed on Cinder snapshots. Please note that
Cinder snapshots are identified as CLI command arguments by either their
display name or UUID.

+---------------+-----------------------------------+--------------------------------------------------------+
| Operation     | CLI Command                       | Description                                            |
+===============+===================================+========================================================+
| Create        | ``cinder snapshot-create``        | Create a Cinder snapshot of a specific Cinder volume   |
+---------------+-----------------------------------+--------------------------------------------------------+
| Delete        | ``cinder snapshot-delete``        | Delete a Cinder snapshot                               |
+---------------+-----------------------------------+--------------------------------------------------------+
| Edit          | ``cinder snapshot-metadata``      | Set or unset metadata on a Cinder snapshot             |
+---------------+-----------------------------------+--------------------------------------------------------+
| List          | ``cinder snapshot-list``          | List all Cinder snapshots                              |
+---------------+-----------------------------------+--------------------------------------------------------+
| Rename        | ``cinder snapshot-rename``        | Change the display-name of a Cinder snapshot           |
+---------------+-----------------------------------+--------------------------------------------------------+
| Reset State   | ``cinder snapshot-reset-state``   | Reset the state of a Cinder snapshot                   |
+---------------+-----------------------------------+--------------------------------------------------------+
| Show          | ``cinder snapshot-show``          | Show details about a Cinder snapshot                   |
+---------------+-----------------------------------+--------------------------------------------------------+

Table 4.3. Cinder API Overview - Snapshot

Consistency Group API
---------------------

Table 4.4, “Cinder API Overview - Consistency Groups” specifies the
valid operations that can be performed on Cinder consistency groups.
Please note that Cinder consistency groups and cgsnapshots are
identified as CLI command arguments by either their display name or
UUID. There is a plan, in the Cinder community, to migrate existing
consistency group operations to use Cinder group operations in an
OpenStack release after Pike.

.. note::
   Consistency group operations support has been deprecated in 
   Block Storage V3 API. Only Block Storage V2 API supports consistency
   groups. Future releases will involve a migration of existing 
   consistency group operations to use generic volume group operations. 

+-----------------------------------------------------------------------------+------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------+
| Operation                                                                   | CLI Command                              | Description                                                                                                                        |
+=============================================================================+==========================================+====================================================================================================================================+
| Create                                                                      | ``cinder consisgroup-create``            | Create a consistency group with support for at least one volume type                                                               |
+-----------------------------------------------------------------------------+------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------+
| Show                                                                        | ``cinder consisgroup-show``              | Display details for a specified consistency group                                                                                  |
+-----------------------------------------------------------------------------+------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------+
| List                                                                        | ``cinder consisgroup-list``              | Show a list of all created consistency groups                                                                                      |
+-----------------------------------------------------------------------------+------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------+
| Create a volume and add it to a consistency group                           | ``cinder create``                        | Expand a consistency group to have another volume by creating a volume with the ``--consisgroup-id`` parameter                     |
+-----------------------------------------------------------------------------+------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------+
| Create a cgsnapshot                                                         | ``cinder cgsnapshot-create``             | Generate a snapshot of a consistency group                                                                                         |
+-----------------------------------------------------------------------------+------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------+
| Show a snapshot of a consistency group                                      | ``cinder cgsnapshot-show``               | Display details for the cgsnapshot of consistency group                                                                            |
+-----------------------------------------------------------------------------+------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------+
| List consistency group snapshots                                            | ``cinder cgsnapshot-list``               | Display all cgsnapshots for a consistency group                                                                                    |
+-----------------------------------------------------------------------------+------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------+
| Delete a snapshot of a consistency group                                    | ``cinder cgsnapshot-delete``             | Remove a cgsnapshot                                                                                                                |
+-----------------------------------------------------------------------------+------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------+
| Delete a consistency group                                                  | ``cinder consisgroup-delete``            | The ``--force`` flag is required when volumes are inside the consistency group                                                     |
+-----------------------------------------------------------------------------+------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------+
| Modify a consistency group                                                  | ``cinder consisgroup-update``            | Add or remove volumes from a consistency group with ``--add-volumes [UUID-list]`` or ``--remove-volumes [UUID-list]`` parameters   |
+-----------------------------------------------------------------------------+------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------+
| Create a consistency group from the snapshot of another consistency group   | ``cinder consisgroup-create-from-src``   | Use a cgsnapshot to generate a new consistency group                                                                               |
+-----------------------------------------------------------------------------+------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------+
| Create a consistency group from a source consistency group                  | ``cinder consisgroup-create-from-src``   | Copy a consistency group                                                                                                           |
+-----------------------------------------------------------------------------+------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------+

Table 4.4. Cinder API Overview - Consistency Groups

Backup API
----------

Table 4.5, “Cinder API Overview - Backup” specifies the valid
operations that can be performed on Cinder backups. Please note that
Cinder backups are identified as CLI command arguments by either their
display name or UUID.

+-------------+-----------------------------+------------------------------------------------+
| Operation   | CLI Command                 | Description                                    |
+=============+=============================+================================================+
| Create      | ``cinder backup-create``    | Create a Cinder backup                         |
+-------------+-----------------------------+------------------------------------------------+
| Delete      | ``cinder backup-delete``    | Delete a Cinder backup                         |
+-------------+-----------------------------+------------------------------------------------+
| List        | ``cinder backup-list``      | List all Cinder backups                        |
+-------------+-----------------------------+------------------------------------------------+
| Restore     | ``cinder backup-restore``   | Restore a Cinder backup into a Cinder volume   |
+-------------+-----------------------------+------------------------------------------------+
| Show        | ``cinder backup-show``      | Show details about a Cinder backup             |
+-------------+-----------------------------+------------------------------------------------+

Table 4.5. Cinder API Overview - Backup


Group API
----------------

Table 4.6, "Cinder API Overview - Group" specifies the valid
operations that can be performed on Cinder groups. Please note that
Cinder groups are identified as CLI command arguments by either their
display name or UUID.

.. note::

   Currently only the Block Storage V3 API supports group operations. The
   minimum version for group operations supported by the ONTAP drivers is
   3.14. The API version can be specified with the following CLI flag
   ``--os-volume-api-version 3.14``

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

+-------------------------------------+-----------------------------------+---------------------------------------------------------------------+
| Operation                           | CLI Command                       | Description                                                         |
+=====================================+===================================+=====================================================================+
| Create                              | ``cinder group-create``           | Creates a group.                                                    |
+-------------------------------------+-----------------------------------+---------------------------------------------------------------------+
| Create a group from a source group  | ``cinder group-create-from-src``  | Creates a group from a group snapshot or a source group.            |
+-------------------------------------+-----------------------------------+---------------------------------------------------------------------+
| Delete                              | ``cinder group-delete``           | Removes one or more groups.                                         |
+-------------------------------------+-----------------------------------+---------------------------------------------------------------------+
| List                                | ``cinder group-list``             | Lists all groups.                                                   |
+-------------------------------------+-----------------------------------+---------------------------------------------------------------------+
| Show                                | ``cinder group-show``             | Shows details of a group.                                           |
+-------------------------------------+-----------------------------------+---------------------------------------------------------------------+
| Update                              | ``cinder group-update``           | Updates a group.                                                    |
+-------------------------------------+-----------------------------------+---------------------------------------------------------------------+
| Create group snapshot               | ``cinder group-snapshot-create``  | Creates a group snapshot.                                           |
+-------------------------------------+-----------------------------------+---------------------------------------------------------------------+
| Delete group snapshot               | ``cinder group-snapshot-delete``  | Removes one or more group snapshots.                                |
+-------------------------------------+-----------------------------------+---------------------------------------------------------------------+
| List group snapshot                 | ``cinder group-snapshot-list``    | Lists all group snapshots.                                          |
+-------------------------------------+-----------------------------------+---------------------------------------------------------------------+
| Show group snapshot                 | ``cinder group-snapshot-show``    | Shows group snapshot details.                                       |
+-------------------------------------+-----------------------------------+---------------------------------------------------------------------+
| Create group type                   | ``cinder group-type-create``      | Creates a group type.                                               |
+-------------------------------------+-----------------------------------+---------------------------------------------------------------------+
| Delete group type                   | ``cinder group-type-delete``      | Deletes group type or types.                                        |
+-------------------------------------+-----------------------------------+---------------------------------------------------------------------+
| List default group type             | ``cinder group-type-default``     | List the default group type.                                        |
+-------------------------------------+-----------------------------------+---------------------------------------------------------------------+
| List group types                    | ``cinder group-type-list``        | Lists available 'group types'. (Admin only will see private types)  |
+-------------------------------------+-----------------------------------+---------------------------------------------------------------------+
| Show group type                     | ``cinder group-type-show``        | Show group type details.                                            |
+-------------------------------------+-----------------------------------+---------------------------------------------------------------------+
| Update group type                   | ``cinder group-type-update``      | Updates group type name, description, and/or is_public.             |
+-------------------------------------+-----------------------------------+---------------------------------------------------------------------+
| List group specs                    | ``cinder group-specs-list``       | Lists current group types and specs.                                |
+-------------------------------------+-----------------------------------+---------------------------------------------------------------------+
| Set group specs                     | ``cinder group-type-key``         | Set or unset group_spec for a group type.                           |
+-------------------------------------+-----------------------------------+---------------------------------------------------------------------+


Table 4.6. Cinder API Overview - Volume Group


Volume Type API
---------------

Table 4.7, “Cinder API Overview - Volume Type” specifies the valid
operations that can be performed on Cinder volume types. Please note
that Cinder volume types are identified as CLI command arguments by
either their display name or UUID.

+-------------+--------------------------+------------------------------------+
| Operation   | CLI Command              | Description                        |
+=============+==========================+====================================+
| Create      | ``cinder type-create``   | Create a Cinder volume type        |
+-------------+--------------------------+------------------------------------+
| Delete      | ``cinder type-delete``   | Delete a Cinder volume type        |
+-------------+--------------------------+------------------------------------+
| List        | ``cinder type-list``     | List existing Cinder volume type   |
+-------------+--------------------------+------------------------------------+

Table 4.7. Cinder API Overview - Volume Type

Volume Type Extra Specs API
---------------------------

Table 4.8, “Cinder API Overview - Volume Type Extra Specs” specifies
the valid operations that can be performed on Cinder volume type extra
specs. Please note that Cinder volume type extra specs are properties of
Cinder volume types and are identified by their parent object.

+---------------------+-----------------------------------+----------------------------------------------+
| Operation           | CLI Command                       | Description                                  |
+=====================+===================================+==============================================+
| Set extra specs     | ``cinder type-key vtype set``     | Assign extra specs to Cinder volume type     |
+---------------------+-----------------------------------+----------------------------------------------+
| Unset extra specs   | ``cinder type-key vtype unset``   | Remove extra specs from Cinder volume type   |
+---------------------+-----------------------------------+----------------------------------------------+

Table 4.8. Cinder API Overview - Volume Type Extra Specs

Volume Type QoS Specs API
-------------------------

Table 4.9, “Cinder API Overview - Volume Type QoS Specs” specifies the
valid operations that can be performed on Cinder volume type QoS specs.
Please note that Cinder volume type QoS specs are created independently
of Cinder volume types and are subsequently associated with a Cinder
volume type.

+--------------------------+-------------------------------+------------------------------------------------------------+
| Operation                | CLI Command                   | Description                                                |
+==========================+===============================+============================================================+
| Create QoS specs         | ``cinder qos-create``         | Create a Cinder QoS Spec                                   |
+--------------------------+-------------------------------+------------------------------------------------------------+
| Delete QoS specs         | ``cinder qos-delete``         | Delete a Cinder QoS Spec                                   |
+--------------------------+-------------------------------+------------------------------------------------------------+
| List QoS specs           | ``cinder qos-list``           | List existing Cinder QoS Specs                             |
+--------------------------+-------------------------------+------------------------------------------------------------+
| Show                     | ``cinder qos-show``           | Show details about a Cinder QoS Spec                       |
+--------------------------+-------------------------------+------------------------------------------------------------+
| Associate QoS specs      | ``cinder qos-associate``      | Associate a Cinder QoS Spec with a Cinder volume type      |
+--------------------------+-------------------------------+------------------------------------------------------------+
| Disassociate QoS specs   | ``cinder qos-disassociate``   | Disassociate a Cinder QoS Spec from a Cinder volume type   |
+--------------------------+-------------------------------+------------------------------------------------------------+
| Edit QoS spec            | ``cinder qos-key``            | Set or unset specifications for a Cinder QoS Spec          |
+--------------------------+-------------------------------+------------------------------------------------------------+

Table 4.9. Cinder API Overview - Volume Type QoS Specs

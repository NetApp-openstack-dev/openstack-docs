API Overview
============

This section describes some of the most commonly used Manila API calls
and their corresponding CLI commands. It is not meant to be a
comprehensive list that is representative of all functionality present
in Manila; for more information, please refer to the help text from
running ``manila help``.

Share API
---------

Table 6.1, “Manila API Overview - Share” specifies the valid
operations that can be performed on Manila shares. Please note that
Manila shares are identified as CLI command arguments by either their
names or UUID.

+-------------+-----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Operation   | CLI Command           | Description                                                                                                                                                                                                                                                                                     |
+=============+=======================+=================================================================================================================================================================================================================================================================================================+
| Create      | ``manila create``     | Create a Manila share of specified size; optional name, availability zone, share type, share network, source snapshot. The ``create_share_from_snapshot_support`` extra spec must be set to true for the associated share type in order to allow a snapshot to be the source of the new share   |
+-------------+-----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Delete      | ``manila delete``     | Delete an existing Manila share; the ``manila force-delete`` command may be required if the Manila share is in an error state                                                                                                                                                                   |
+-------------+-----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Edit        | ``manila metadata``   | Set or unset metadata on a Manila share                                                                                                                                                                                                                                                         |
+-------------+-----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Extend      | ``manila extend``     | Increase the size of a Manila share                                                                                                                                                                                                                                                             |
+-------------+-----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| List        | ``manila list``       | List all Manila shares                                                                                                                                                                                                                                                                          |
+-------------+-----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Manage      | ``manila manage``     | Bring an existing storage object under Manila management as a file share                                                                                                                                                                                                                        |
+-------------+-----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Show        | ``manila show``       | Show details about a Manila share                                                                                                                                                                                                                                                               |
+-------------+-----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Shrink      | ``manila shrink``     | Decrease the size of a Manila share                                                                                                                                                                                                                                                             |
+-------------+-----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Unmanage    | ``manila unmanage``   | Cease management of an existing Manila share without deleting the backing storage object                                                                                                                                                                                                        |
+-------------+-----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Table 6.1. Manila API Overview - Share

Share Access API
----------------

Table 6.2, “Manila API Overview - Share Access” specifies the valid
access operations that can be performed on Manila shares. Please note
that Manila shares are identified as CLI command arguments by either
their names or UUID.

.. warning::

    Please refer to the caveat as explained in
    the section called ":ref:`share-access-rules`".

+-------------+---------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------+
| Operation   | CLI Command               | Description                                                                                                                                             |
+=============+===========================+=========================================================================================================================================================+
| Allow       | ``manila access-allow``   | Allow access to the specified share for the specified access type and value (IP address or IP network address in CIDR notation or Windows user name).   |
+-------------+---------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------+
| Deny        | ``manila access-deny``    | Deny access to the specified share for the specified access type and value (IP address or IP network address in CIDR notation or Windows user name).    |
+-------------+---------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------+
| List        | ``manila access-list``    | List all Manila share access rules                                                                                                                      |
+-------------+---------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------+

Table 6.2. Manila API Overview - Share Access

Share Export Location API
-------------------------

Table 6.3, “Manila API Overview - Share Export Location” specifies the
operations that can be performed to get export locations of Manila
shares. Please note that Manila shares are identified as CLI command
arguments by either their names or UUID. There may be multiple export
locations for a given share, at least one of which should be listed as
preferred; clients should use the preferred path for optimum
performance.

+-------------+-----------------------------------------+-------------------------------------------------+
| Operation   | CLI Command                             | Description                                     |
+=============+=========================================+=================================================+
| List        | ``manila share-export-location-list``   | List export locations of the specified share.   |
+-------------+-----------------------------------------+-------------------------------------------------+
| Show        | ``manila share-export-location-show``   | Show details for a specific export location.    |
+-------------+-----------------------------------------+-------------------------------------------------+

Table 6.3. Manila API Overview - Share Export Location

Snapshot API
------------

Table 6.4, “Manila API Overview - Snapshot” specifies the valid
operations that can be performed on Manila snapshots. Please note that
Manila snapshots are identified as CLI command arguments by either their
display name or UUID.

.. important::

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
   :ref:`Table 6.10, “NetApp supported Extra Specs for use with Manila Share Types”<table-6.10>`.

+----------------------+-----------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Operation            | CLI Command                       | Description                                                                                                                                                                          |
+======================+===================================+======================================================================================================================================================================================+
| Create               | ``manila snapshot-create``        | Create a Manila snapshot of a specific Manila share                                                                                                                                  |
+----------------------+-----------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Delete               | ``manila snapshot-delete``        | Delete a Manila snapshot                                                                                                                                                             |
+----------------------+-----------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| List                 | ``manila snapshot-list``          | List all Manila snapshots                                                                                                                                                            |
+----------------------+-----------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Manage               | ``manila snapshot-manage``        | Bring an existing storage object snapshot under Manila management, specifying the snapshot name as the provider location                                                             |
+----------------------+-----------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Rename               | ``manila snapshot-rename``        | Change the display-name of a Manila snapshot                                                                                                                                         |
+----------------------+-----------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Reset State          | ``manila snapshot-reset-state``   | Reset the state of a Manila snapshot                                                                                                                                                 |
+----------------------+-----------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Show                 | ``manila snapshot-show``          | Show details about a Manila snapshot                                                                                                                                                 |
+----------------------+-----------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Unmanage             | ``manila snapshot-unmanage``      | Cease management of an existing Manila snapshot without deleting the backing storage object snapshot                                                                                 |
+----------------------+-----------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Revert to SnapShot   | ``manila revert-to-snapshot``     | Revert a Manila share (in place) to the latest snapshot. The ``snapshot_support`` and ``revert_to_snapshot_support`` extra specs must be set to True for the associated share type   |
+----------------------+-----------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Table 6.4. Manila API Overview - Snapshot

Share Type API
--------------

Table 6.5, “Manila API Overview - Share Type” specifies the valid
operations that can be performed on Manila share types. Please note that
Manila share types are identified as CLI command arguments by either
their display name or UUID. Creation or deletion of share types normally
requires administrative privileges.

+-------------+--------------------------+-----------------------------------+
| Operation   | CLI Command              | Description                       |
+=============+==========================+===================================+
| Create      | ``manila type-create``   | Create a Manila share type        |
+-------------+--------------------------+-----------------------------------+
| Delete      | ``manila type-delete``   | Delete a Manila share type        |
+-------------+--------------------------+-----------------------------------+
| List        | ``manila type-list``     | List existing Manila share type   |
+-------------+--------------------------+-----------------------------------+

Table 6.5. Manila API Overview - Share Type

Share Type Extra Specs API
--------------------------

Table 6.6, “Manila API Overview - Share Type Extra Specs” specifies
the valid operations that can be performed on Manila share type extra
specs. Please note that Manila share type extra specs are properties of
Manila share types and are identified by their parent object. Modifying
extra specs or viewing the contents of a share type normally requires
administrative privileges.

+---------------------+-----------------------------------+------------------------------------------------------------------+
| Operation           | CLI Command                       | Description                                                      |
+=====================+===================================+==================================================================+
| List extra specs    | ``manila extra-specs-list``       | Print the values of extra specs assigned to Manila share types   |
+---------------------+-----------------------------------+------------------------------------------------------------------+
| Set extra specs     | ``manila type-key stype set``     | Assign extra specs to Manila share type                          |
+---------------------+-----------------------------------+------------------------------------------------------------------+
| Unset extra specs   | ``manila type-key stype unset``   | Remove extra specs from Manila share type                        |
+---------------------+-----------------------------------+------------------------------------------------------------------+

Table 6.6. Manila API Overview - Share Type Extra Specs

Consistency Group API
---------------------

+----------------------------+--------------------------------------+-------------------------------------------------------------------+
| Operation                  | CLI Command                          | Description                                                       |
+============================+======================================+===================================================================+
| Create                     | ``manila cg-create``                 | Create a Manila consistency group                                 |
+----------------------------+--------------------------------------+-------------------------------------------------------------------+
| Delete                     | ``manila cg-delete``                 | Delete a Manila consistency group                                 |
+----------------------------+--------------------------------------+-------------------------------------------------------------------+
| List                       | ``manila cg-list``                   | List all Manila consistency groups                                |
+----------------------------+--------------------------------------+-------------------------------------------------------------------+
| Reset state                | ``manila cg-reset-state``            | Update the state of a Manila consistency group                    |
+----------------------------+--------------------------------------+-------------------------------------------------------------------+
| Show                       | ``manila cg-show``                   | Show details about a Manila consistency group                     |
+----------------------------+--------------------------------------+-------------------------------------------------------------------+
| Update                     | ``manila cg-update``                 | Update details of a Manila consistency group                      |
+----------------------------+--------------------------------------+-------------------------------------------------------------------+
| Create CG Snapshot         | ``manila cg-snapshot-create``        | Create a snapshot of a consistency group and all of it's shares   |
+----------------------------+--------------------------------------+-------------------------------------------------------------------+
| Delete CG Snapshot         | ``manila cg-snapshot-delete``        | Delete a snapshot of a consistency group                          |
+----------------------------+--------------------------------------+-------------------------------------------------------------------+
| List CG Snapshot           | ``manila cg-snapshot-list``          | List all consistency group snapshots                              |
+----------------------------+--------------------------------------+-------------------------------------------------------------------+
| Show CG Snapshot members   | ``manila cg-snapshot-members``       | Get member details for a consistency group snapshot.              |
+----------------------------+--------------------------------------+-------------------------------------------------------------------+
| Reset CG Snapshot state    | ``manila cg-snapshot-reset-state``   | Update the state of a Manila consistency group snapshot           |
+----------------------------+--------------------------------------+-------------------------------------------------------------------+
| Show CG Snapshot           | ``manila cg-snapshot-show``          | Show details about a consistency group snapshot.                  |
+----------------------------+--------------------------------------+-------------------------------------------------------------------+
| Update CG Snapshot         | ``manila cg-snapshot-update``        | Update details of a consistency group snapshot.                   |
+----------------------------+--------------------------------------+-------------------------------------------------------------------+

Table 6.7. Manila API Overview - Consistency Groups

Share Replication API
---------------------

+---------------------------+------------------------------------------------+---------------------------------------------------------------------+
| Operation                 | CLI Command                                    | Description                                                         |
+===========================+================================================+=====================================================================+
| Create Share Replica      | ``manila share-replica-create``                | Create a Manila share replica.                                      |
+---------------------------+------------------------------------------------+---------------------------------------------------------------------+
| Delete                    | ``manila share-replica-delete``                | Delete a Manila share replica.                                      |
+---------------------------+------------------------------------------------+---------------------------------------------------------------------+
| List                      | ``manila share-replica-list``                  | List all Manila Share replicas.                                     |
+---------------------------+------------------------------------------------+---------------------------------------------------------------------+
| Show                      | ``manila share-replica-show``                  | Show detailed information for the specified replica.                |
+---------------------------+------------------------------------------------+---------------------------------------------------------------------+
| Promote                   | ``manila share-replica-promote``               | Change the specified replica to the ACTIVE replica for the share.   |
+---------------------------+------------------------------------------------+---------------------------------------------------------------------+
| Resync                    | ``manila share-replica-resync``                | Tell Manila to initiate an update for the replica.                  |
+---------------------------+------------------------------------------------+---------------------------------------------------------------------+
| Reset Replica Status      | ``manila share-replica-reset-state``           | Update the status attribute of a replica.                           |
+---------------------------+------------------------------------------------+---------------------------------------------------------------------+
| Reset Replication State   | ``manila share-replica-reset-replica-state``   | Update the replica\_state attribute of a replica.                   |
+---------------------------+------------------------------------------------+---------------------------------------------------------------------+

Table: 6.8. Manila API Overview - Share Replication

Share Migration API
-------------------

.. _table-6.9:

+----------------+-------------------------------------+--------------------------------------------------------------------------------------------------------------------+
| Operation      | CLI Command                         | Description                                                                                                        |
+================+=====================================+====================================================================================================================+
| Start          | ``manila migration-start``          | Start the share-migration process.                                                                                 |
+----------------+-------------------------------------+--------------------------------------------------------------------------------------------------------------------+
| Get Progress   | ``manila migration-get-progress``   | Show the migration progress information for a share.                                                               |
+----------------+-------------------------------------+--------------------------------------------------------------------------------------------------------------------+
| Complete       | ``manila migration_complete``       | Complete the migration process by removing the source share, and setting the destination share to ``available``.   |
+----------------+-------------------------------------+--------------------------------------------------------------------------------------------------------------------+
| Cancel         | ``manila migration-cancel``         | Cancel the migration of a share.                                                                                   |
+----------------+-------------------------------------+--------------------------------------------------------------------------------------------------------------------+

Table 6.9. Manila API Overview - Share Migration

.. note::

   Several parameters need to be specified when starting migration for
   a share. For a list of supported parameters, refer to the help text
   from running ``manila help migration-start``. For example, the
   NetApp driver supports preserving snapshots and file system
   metadata, and can perform in-Vserver migrations non-disruptively. In
   order to do so, ``preserve_metadata``, ``preserve_snapshots``, and
   ``nondisruptive`` must be set to ``True``.

NFS Backup Configuration
========================

By default, the Swift object store is used for the backup repository. To
use an NFS export as the backup repository, the Cinder backup service
must be restarted after adding at least the following two configuration
lines to the ``[DEFAULT]`` section of the Cinder configuration file
``cinder.conf``::

    backup_driver=cinder.backup.drivers.nfs
    backup_share=HOST:EXPORT_PATH

Other configuration options may be specified in the ``[DEFAULT]``
section as appropriate. Table 4.23, “Configuration options for NFS backup service”
below lists the configuration options available for the Cinder Backup service
when an NFS export is leveraged as the backup repository.

+------------------------------------+------------+-----------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Option                             | Type       | Default Value                     | Description                                                                                                                                                               |
+====================================+============+===================================+===========================================================================================================================================================================+
| ``backup_driver``                  | Required   | ``cinder.backup.drivers.swift``   | Determines the driver that the backup service will load. [1]_                                                                                                             |
+------------------------------------+------------+-----------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``backup_share``                   | Required   |                                   | Set to HOST:EXPORT\_PATH. [2]_                                                                                                                                            |
+------------------------------------+------------+-----------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``backup_mount_options``           | Optional   |                                   | Comma separated list of options to be specified when mounting the NFS export specified in ``backup_share``\  [3]_.                                                        |
+------------------------------------+------------+-----------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``backup_compression_algorithm``   | Optional   | ``zlib``                          | The compression algorithm to be used when sending backup data to the repository. Valid values are ``zlib``, ``bz2``, and ``None``. [4]_                                   |
+------------------------------------+------------+-----------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``backup_file_size``               | Optional   | ``1999994880``                    | Data from Cinder volumes larger than this will be stored as multiple files in the backup repository. This option must be a multiple of ``backup_sha_block_size_bytes``.   |
+------------------------------------+------------+-----------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``backup_sha_block_size_bytes``    | Optional   | ``32768``                         | Size of Cinder volume blocks for digital signature calculation.                                                                                                           |
+------------------------------------+------------+-----------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Table 4.23. Configuration options for NFS backup service

.. [1]
   Set the value of the ``backup_driver`` option to
   ``cinder.backup.drivers.nfs`` to enable the NFS backup driver.

.. [2]
   Set HOST to the IP address via which the NFS share is exported (for
   example, the address on the appropriate NFS data LIF on a Data ONTAP
   storage system). Set PATH to the export path used to mount the share.

.. [3]
   Mount options such as ``nfsvers`` should be specified appropriately
   according to the configuration of the NFS server. For example, if an
   AltaVault appliance is acting as the backup repository, the appliance
   will recommend these mount options:
   ``rw,nolock,hard,intr,nfsvers=3,tcp,rsize=131072,wsize=131072,bg``

.. [4]
   NetApp recommends that the ``backup_compression_algorithm`` option be
   set to ``None`` in order to avoid consuming excess CPU on the Cinder
   backup node, and that purpose-built deduplication and compression
   features be enabled on the Data ONTAP storage system providing the
   backup repository to achieve storage efficiency.

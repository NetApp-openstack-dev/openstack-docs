.. _shares-conf:

Sample nfs.shares file
----------------------

This section provides an example Cinder configuration file
(``nfs.shares``) that contains four pools (known as flexvols within ONTAP)
The nfs.shares file is required by Cinder when using the NFS storage protocol.
The nfs.shares file is referenced via nfs_shares_config=/etc/cinder/nfs.shares 

The contents of the nfs.shares file is as such:

::

    10.63.40.153:/vol2_dedup
    10.63.40.153:/vol3_compressed
    10.63.40.153:/vol4_mirrored
    10.63.40.153:/vol5_plain


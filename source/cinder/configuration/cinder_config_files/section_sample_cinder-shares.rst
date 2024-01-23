.. _shares-conf:

Sample nfs_shares file
======================

This section provides an example Cinder configuration file
(``nfs_shares``) that contains four pools (known as flexvols within ONTAP).
The nfs_shares file is required by Cinder when using the NFS storage protocol.
The nfs_shares file is referenced via nfs_shares_config=/etc/cinder/nfs_shares 

The contents of the nfs_shares file is as such:

::

    10.63.40.153:/vol2_dedup
    10.63.40.153:/vol3_compressed
    10.63.40.153:/vol4_mirrored
    10.63.40.153:/vol5_plain


This below section provides examples of Cinder configuration files used in RHOSP17 when multiple nfs backends are deployed.

The nfs_shares1 file is referenced via nfs_shares_config=/etc/cinder/nfs_shares1 and the contents of the nfs_shares1 file is as such:

::

    <lif_ip>:/nfs_vol1

The nfs_shares2 file is referenced via nfs_shares_config=/etc/cinder/nfs_shares2 and the contents of the nfs_shares2 file is as such:

::

    <lif_ip>:/nfs_vol2    

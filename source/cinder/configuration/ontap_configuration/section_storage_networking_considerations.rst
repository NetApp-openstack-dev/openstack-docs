.. _storage_networking_considerations:

Storage Networking Considerations
=================================

1. Ensure there is segmented network connectivity between the hypervisor
   nodes and the Data LIF interfaces from ONTAP.

2. When NFS is used as the storage protocol with Cinder, the node
   running the ``cinder-volume`` process will attempt to mount the NFS
   shares listed in the file referred to within the
   ``nfs_shares_config`` configuration option in ``cinder.conf``. Ensure
   that there is appropriate network connectivity between the
   ``cinder-volume`` node and the Data LIF interfaces, as well as the
   cluster/SVM management interfaces.

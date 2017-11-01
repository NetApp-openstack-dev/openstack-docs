.. _storage_virtual_machined_considerations:

Storage Virtual Machine Considerations
======================================

1. Ensure the appropriate licenses (as described in ":ref:`data-ontap-config`") 
   are enabled on the storage system for the desired use case.

2. The SVM must be created (and associated with aggregates) before it
   can be utilized as a provisioning target for Cinder.

3. FlexVol volumes must be created before the integration with Cinder is
   configured, as there is a many-to-one relationship between Cinder
   volumes and FlexVol volumes (see the section called ":ref:`theory-op`"
   for more information).

4. Regardless of the storage protocol used, data LIFs must be created
   and assigned to SVMs before configuring Cinder.

5. If NFS is used as the storage protocol:

   1. Be sure to enable the NFS service on the SVM.

   2. Be sure to enable the desired version of the NFS protocol (e.g.
      ``v4.0, v4.1-pnfs``) on the SVM.  

   3. Be sure to define junction paths from the FlexVol volumes and
      refer to them in the file referenced by the ``nfs_shares_config``
      configuration option in ``cinder.conf``.

6. If iSCSI is used as the storage protocol:

   1. Be sure to enable the iSCSI service on the SVM.

   2. Be sure to set iSCSI as the data protocol on the data LIF.

   3. Note that iSCSI LUNs will be created by Cinder; therefore, it is
      not necessary to create LUNs or igroups before configuring Cinder.

7. If Fibre Channel is used as the storage protocol:

   1. Be sure to enable the FCP service on the SVM.

   2. Be sure to set FCP as the data protocol on the data LIF.

   3. Note that Fibre Channel LUNs will be created by Cinder; therefore,
      it is not necessary to create LUNs or igroups before configuring
      Cinder.

8. Once FlexVol volumes have been created, be sure to configure the
   desired features (e.g. deduplication, compression, SnapMirror
   relationships, etc) before configuring Cinder. While Cinder will
   periodically poll ONTAP to discover changes in configuration
   and/or features, there is a delay in time between when changes are
   performed and when they are reflected within Cinder.

9. NetApp does not recommend using the autogrow capability for
   ONTAP FlexVol volumes within a Cinder deployment. A FlexVol only
   reports its current size, so the Cinder scheduler is never made aware
   of the autogrow limit that may or may not be enabled for the FlexVol.

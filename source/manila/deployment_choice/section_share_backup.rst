.. _enabling_share_backups:

Deployment Choice: Enabling Share Backup
========================================

For NetApp specific shares, the NetApp unified driver has been updated
to create/delete/restore backups using ONTAP replication engine (SnapVault 
relationship). It effectively uses all the ONTAP concepts like snapshot, peering of 
vservers, peering of clusters and replication engine.

The ``manila.conf`` file contains a set of configuration options
specified as ``enabled_backup_types``\ = ``[stanza_name]``. This ``[stanza_name]`` is 
actually referred as backup_type. The other backup related configuration options are grouped
into this stanza, denoted by ``[stanza_name]``. It should contain the backup specific
configuration parameters such as ``backup_type_name``, ``netapp_backup_backend_section_name``, 
``netapp_backup_vserver``, ``netapp_backup_share``, ``netapp_snapmirror_job_timeout``.  
This backup_type config is applied to a specific Manila backend mentioned in ``netapp_backup_backend_section_name``. 
Configuration options that are associated with a particular Manila backend should be placed in a 
separate stanza as how we do earlier. .


.. note::
   The sample config will look like this: 
   ``eng_backup`` is the backup_type here.::

       [eng_backup]
       backup_type_name=my_backup
       netapp_backup_backend_section_name = ontap2
       netapp_backup_vserver = backup_vserver_name
       netapp_backup_share = backup_volume_name_inside_vserver 
       netapp_snapmirror_job_timeout = 180

       [ontap_cluster_1]
       vendor_name = NetApp
       share_driver = manila.share.drivers.netapp.common.NetAppDriver
       driver_handles_share_servers = False
       netapp_login = admin
       ....
       ....
       enabled_backup_types = eng_backup


   If the option ``netapp_backup_share`` is set to empty value, the backup volume (destination 
   volume) would be created automatically by the driver inside the vserver. 
   
   On the backend configuration, if driver_handles_share_servers is set to false, and if 
   netapp_backup_vserver is empty in backup_type stanza (here it is [eng_backup]), the 
   vserver would be created automatically. In such cases, the destination volume also would be 
   created automatically with the specified pattern mentioned in the backend.   


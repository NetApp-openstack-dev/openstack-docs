SolidFire Configuration
=======================

Configuring the OpenStack Software Driver
-----------------------------------------

The OpenStack software driver enables communication between the OpenStack software and a SolidFire 
storage system. You can use information from the SF-Series cluster to configure the driver. You can 
configure the driver by modifying the /etc/cinder/cinder.conf service configuration file on the
controller host. The OpenStack Cinder software uses the cluster admin account you created in the section "Adding a Cluster Admin Account"
to manage storage on the cluster

Example proceedure for configuring cinder
-----------------------------------------

1.  Edit /etc/cinder/cinder.conf

2.  Make the following changes to the [lvm], [solidfire], and [DEFAULT] sections:

::

 [lvm]                                                                     
 volume_group=lvm cinder volumes                                           
 volume_driver=cinder.volume.drivers.lvm.LVMISCSIDriver                    
 volume_backend_name=LVM_iSCSI                                             
                                                                           
 [solidfire]                                                               
 volume_driver=cinder.volume.drivers.solidfire.SolidFireDriver             
 san_ip=172.17.1.182                                                       
 san_login=openstack-admin                                                  
 san_password=superduperpassword                                           
 volume_backend_name=SolidFire                                             
                                                                           
 [DEFAULT]                                                                 
 enabled_backends=lvm,solidfire                                            


3. Restart the OpenStack Cinder volume service by issuing one of the following commands:


   - *service cinder-volume restart*
  
   - *systemctl  restart  openstack-cinder-volume*

..

4. Restart the OpenStack Cinder scheduler service by issuing one of the following commands:


   - *service cinder-scheduler restart*

   - *systemctl  restart  openstack-cinder-scheduler*

..


For the latest documentation on the configuration and best practices for the cinder driver with SolidFire please
please visit NetApp.com


`NetApp SolidFire Storage for OpenStack Configuration Guide <http://www.netapp.com/us/media/tr-4620.pdf>`_ 

.. 

`Netapp SolidFire Field Portal <https://fieldportal.netapp.com/content/563204>`_

..

.. Source URLS
.. http://www.netapp.com/us/media/tr-4620.pdf
.. https://fieldportal.netapp.com/content/563204




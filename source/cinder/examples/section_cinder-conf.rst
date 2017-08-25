.. _cinder-conf:

Sample cinder.conf
----------------------

This section provides an example Cinder configuration file
(``cinder.conf``) that contains three backends - one for clustered Data
ONTAP with the NFS storage protocol, one for clustered Data ONTAP with
the iSCSI storage protocol, and one for an E-Series deployment
(leveraging iSCSI).

::

    [DEFAULT]
    rabbit_password=netapp123
    rabbit_hosts=192.168.33.40
    rpc_backend=cinder.openstack.common.rpc.impl_kombu
    notification_driver=cinder.openstack.common.notifier.rpc_notifier
    periodic_interval=60
    lock_path=/opt/stack/data/cinder
    state_path=/opt/stack/data/cinder
    osapi_volume_extension=cinder.api.contrib.standard_extensions
    rootwrap_config=/etc/cinder/rootwrap.conf
    api_paste_config=/etc/cinder/api-paste.ini
    sql_connection=mysql://root:netapp123@127.0.0.1/cinder?charset=utf8
    iscsi_helper=tgtadm
    my_ip=192.168.33.40
    volume_name_template=volume-%s
    verbose=True
    debug=True
    auth_strategy=keystone
    #ceilometer settings
    cinder_volume_usage_audit=True
    cinder_volume_usage_audit_period=hour
    control_exchange=cinder

    enabled_backends=cdot-iscsi,cdot-nfs,eseries-iscsi

    [cdot-iscsi]
    volume_backend_name=cdot-iscsi
    volume_driver=cinder.volume.drivers.netapp.common.NetAppDriver
    netapp_server_hostname=10.63.40.150
    netapp_server_port=80
    netapp_storage_protocol=iscsi
    netapp_storage_family=ontap_cluster
    netapp_login=admin
    netapp_password=netapp123
    netapp_vserver=demo-iscsi-svm

    [cdot-nfs]
    volume_backend_name=cdot-nfs
    volume_driver=cinder.volume.drivers.netapp.common.NetAppDriver
    netapp_server_hostname=10.63.40.150
    netapp_server_port=80
    netapp_storage_protocol=nfs
    netapp_storage_family=ontap_cluster
    netapp_login=admin
    netapp_password=netapp123
    netapp_vserver=demo-nfs-svm
    nfs_shares_config=/etc/cinder/nfs.shares

    [eseries-iscsi]
    volume_backend_name=eseries-iscsi
    volume_driver=cinder.volume.drivers.netapp.common.NetAppDriver
    netapp_server_hostname=10.63.165.26
    netapp_server_port=8080
    netapp_transport_type=http
    netapp_storage_protocol=iscsi
    netapp_storage_family=eseries
    netapp_login=admin
    netapp_password=netapp123
    netapp_sa_password=password
    netapp_controller_ips=10.63.215.225,10.63.215.226
    netapp_pool_name_search_pattern=(cinder_pool_[\d]+)
